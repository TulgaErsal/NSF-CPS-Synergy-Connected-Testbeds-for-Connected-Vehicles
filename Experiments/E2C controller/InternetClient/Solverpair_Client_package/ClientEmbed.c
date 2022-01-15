/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

#include <stdio.h>
#include <string.h>
#include "winsock2.h"
#include <math.h>
#include <time.h>
#include "LongHaul.h"

FILE *ofp; // Output file pointer. This file records messages. Use this file for debugging and monitoring
FILE *tfp; //Client data file pointer. This file records the Client packets
FILE *ufp; //Server data file pointer. This file records the Server packets

const char * serverIPAddress = "127.0.0.1";// This PC, original IPAddress
const char * clientIPAddress = "127.0.0.1";// This PC 

int UDPPort = 5100;
int RecvUDPPort = 5101;
int SendEveryNthPacket = 1;

#ifndef __LONG_HAUL_DECLARATIONS__
#define __LONG_HAUL_DECLARATIONS__
typedef struct
{
    SOCKET	sockfd ;
    SOCKADDR_IN  	sendAddr;
	SOCKADDR_IN  	recvAddr;
    LARGE_INTEGER	LIstartTime ;
    LARGE_INTEGER	LIticksPerSecond ;

    int    currentEvent ;
    int    lastEventReceived ;
    float  arrivalTime ;
    int    packetsSent ;
    int    packetsReceived ;
    float  engineTorque ;
    float  v_opt_array[40]; //modify server
    
} LH_SharedData;
#endif //__LONG_HAUL_DECLARATIONS__

LH_SharedData G;

typedef struct
{
    double simTime;
    double engineSpeed;
	double throttle;
    double d_rel; //????
    double T_TB;
    double v_lead;
    double v_ego;
    double v_lead_pre[40]; //modify here
      
} myInputs;

int packetNo;
int tick;
int simStep;
int firstPacket;
int firstPacketNumber;
float RTT;
double dropRate;
int noOfFunctionCalls = 1; //Number of function calls per major integration step: ode5->6, ode4->4
bool timedOut;
double timeOut = 1;
double nominalTorque = 100;
bool newTarget;
double timeHorizon = 0.02;
double lastTorque;
double simDeltaT = 0.004;
int iFades;
double torqueStep;
int fadeSteps;
double timeNow;
double abstimeNow;
double timeLastReceived;

int udpClient_Initialize ()
{
    // Connect a UDP socket
    WSADATA wsaData;
    struct fd_set selectFds ;
    struct timeval selWaitTime ;

    int	n;
    int i ;
    int iResult ;
    unsigned long ioctlIn = 1 ; // For non-blocking socket.

    ofp = fopen("logClient.txt","w");
    tfp = fopen("packetsClient_client.txt","w");
    ufp = fopen("packetsServer_client.txt","w");
    fprintf (ofp,"Initializing...\n");

    //-----------------------------
    // Initialize Winsock2.
    iResult = WSAStartup( MAKEWORD(2,2), &wsaData );
    if ( iResult != NO_ERROR )
    {	fprintf (ofp,"Error at WSAStartup()\n");
    return 1;
    }
    else
        fprintf (ofp,"Winsock2 initialized successfully!\n");

    //-----------------------------
    // Create a socket.
    G.sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if ( G.sockfd == INVALID_SOCKET )
    {
        WSACleanup();
        fprintf (ofp,"Error at socket(): %i\n",WSAGetLastError());
        return 1;
    }
    else
        fprintf (ofp,"Socket created successfully!\n");

	  //-----------------------------
  // Bind the socket to the recv port.
  // Nornally we would let this be an ephemeral port (kernel chooses), however,
  // because WinRelay is a one-way packet forwarder, we need a well known port
  // on the client side as well.  In this way we can run two sessions of WinRelay
  // one for each direction and we do not have to manually enter the ephemeral port
  // each time.
  G.recvAddr.sin_family 	   = AF_INET;
  G.recvAddr.sin_addr.s_addr = inet_addr( clientIPAddress ); // htonl(INADDR_ANY);
  G.recvAddr.sin_port 	   = htons(RecvUDPPort);
  n = bind( G.sockfd, (struct sockaddr*)&(G.recvAddr), sizeof(SOCKADDR_IN) ) ;
  if (n == SOCKET_ERROR)
    {	int error = WSAGetLastError() ;
    fprintf (ofp,"Error calling bind().  WSAGetLastError() returned %i\n",error);
    WSACleanup();
    return 1;
    }
    else
        fprintf (ofp,"Bound to the receive address successfully!\n");

    //-----------------------------
    // Create the address structure.
    G.sendAddr.sin_family 	= AF_INET;
    G.sendAddr.sin_addr.s_addr = inet_addr( serverIPAddress );
    G.sendAddr.sin_port 	= htons( UDPPort );
    fprintf (ofp,"Created address structure\n");


    //-----------------------------
    // Make the socket non-blocking.
    n = ioctlsocket(G.sockfd, FIONBIO, &ioctlIn) ;
    if (n == SOCKET_ERROR)
    {
        fprintf (ofp,"Error calling ioctlsocket().  WSAGetLastError() returned %i\n", WSAGetLastError());
        closesocket(G.sockfd);
        WSACleanup();
        return 1;
    }
    else
        fprintf (ofp,"Socket made non-blocking successfully!\n");


    //----------------------------------------------
    // Get the clock resolution and the initial time.
    QueryPerformanceFrequency(&(G.LIticksPerSecond)) ;
    if (!QueryPerformanceCounter(&(G.LIstartTime)) )
        fprintf (ofp,"Error: High resolution clock not available.\n");
    else {
        fprintf (ofp,"Clock resolution is %f ns.\n", 1.0E9 / (double)G.LIticksPerSecond.QuadPart);
        
        fprintf(ofp,"G.LIstartTime.QuadPart is %f .\n",G.LIstartTime.QuadPart);
//         fprintf(ofp,"((double)(LItNow.QuadPart - G.LIstartTime.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)) is %f .\n",
//                 ((double)(LItNow.QuadPart - G.LIstartTime.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)));
    }
    //----------------------------------------------

    G.currentEvent = 0;
    G.packetsSent = 0;
    G.packetsReceived = 0;
    packetNo = 0;
    tick = 0;
    simStep = noOfFunctionCalls;
    firstPacket = 1;
	firstPacketNumber = 0;
	RTT = 0;
	dropRate = 0;
	timedOut = false;
	newTarget = false;
	lastTorque = 0;
	iFades = 0;

    fprintf (ofp,"Initialization completed.\n\n");
    return 0; // Indicate that the function was initialized successfully.
}

int udpClient_CommunicateThroughUDP (double *inarr, int inputs, double *outarr, int outputs, int major)
{

    myInputs myIns;
    LARGE_INTEGER LItSend ;
	LARGE_INTEGER LItNow ;
    int n ;
    int iResult;

    ToClient   fromServer ;
    ToServer  fromClient ;

    myIns.simTime = inarr[0];
	myIns.engineSpeed = inarr[1];
    myIns.throttle = inarr[2];
    myIns.d_rel = inarr[3];  
    myIns.T_TB = inarr[4];
    myIns.v_lead = inarr[5];
    myIns.v_ego = inarr[6];
    //myIns.v_lead_pre[0] = inarr[7];
    //myIns.v_lead_pre[1] = inarr[8];
    // myIns.v_lead_pre = inarr[7:46];
    int iloop;
    for (iloop = 1; iloop < 41; iloop++) { //modify here NP+1
        myIns.v_lead_pre[iloop-1] = inarr[iloop+6];}
    
    //fprintf(ofp,"simTime = %f, simStep = %i\n",myIns.simTime,simStep);
	if (myIns.simTime == 0) //initialize output terminals
	{
		outarr[0]  = 0;
		outarr[1]  = 0;
		outarr[2]  = 0;
		outarr[3]  = 0;
        
        for (iloop = 1; iloop < 41; iloop++) { //modify server NP+1
            outarr[iloop+3] = 0.0;}
	}

	//Note the current time
	QueryPerformanceCounter(&LItNow) ;
	// Tulga's code: 
    timeNow = ((double)(LItNow.QuadPart - G.LIstartTime.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)) ;
    // Chunan change this:
    abstimeNow = (double)(LItNow.QuadPart)/(double)G.LIticksPerSecond.QuadPart;
    while (myIns.simTime > timeNow*1)
     {
         QueryPerformanceCounter(&LItNow);
         timeNow = ((double)(LItNow.QuadPart - G.LIstartTime.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)) ;
         abstimeNow = (double)(LItNow.QuadPart)/(double)G.LIticksPerSecond.QuadPart;
     }

  if (simStep++ % noOfFunctionCalls == 0) //if this is a major calculation
    {
        /* Send a UDP packet every "SendEveryNthPacket" ticks */
        if (tick++ % SendEveryNthPacket == 0)
        {
            double tSend ;
            LARGE_INTEGER dt ;
            int selRet ;

            packetNo++ ;

            // Query the high resolution clock
            QueryPerformanceCounter(&LItSend) ;

            // Fill the packet with the data to be sent
            // Header info.
            strcpy(fromClient.icdVersion, LONG_HAUL_ICD_VERSION) ;
            fromClient.packetNumber  = packetNo ;
            fromClient.sendTimeStamp = LItSend ;

            // Control signals.
            fromClient.throttle      = myIns.throttle;
            fromClient.engineSpeed    = myIns.engineSpeed;
            fromClient.d_rel           = myIns.d_rel;
            fromClient.T_TB            = myIns.T_TB;
            fromClient.v_lead          = myIns.v_lead;
            fromClient.v_ego           = myIns.v_ego;
            iloop=1;
            for (iloop = 1; iloop < 41; iloop++) { //modify here NP+1
                fromClient.v_lead_pre[iloop-1] = myIns.v_lead_pre[iloop-1];}
            //fromClient.v_lead_pre[0]      = myIns.v_lead_pre[0];
            //fromClient.v_lead_pre[1]      = myIns.v_lead_pre[1];
            //fromClient.v_lead_pre      = myIns.v_lead_pre;

            // Information signals
            fromClient.sendSimTime      = myIns.simTime;
			fromClient.rtt			   = RTT;
			fromClient.dropRate		   = dropRate;



            // Send the packet.
            //fprintf(ofp, "Sending packet %i: throttle = %f, speed = %f, time = %f\n",packetNo, myIns.throttle, myIns.engineSpeed, myIns.simTime);
            iResult = sendto(
            G.sockfd, (char*)&fromClient, sizeof(fromClient), 0,
            (struct sockaddr*)&(G.sendAddr), sizeof(SOCKADDR_IN)
            );
            if (iResult == SOCKET_ERROR)
                fprintf(ofp, "Socket error while sending packet: %i\n", WSAGetLastError());
            G.packetsSent++ ;
			 //Record Client packet
            
            fprintf (tfp,"%i\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n",fromClient.packetNumber, timeNow, abstimeNow, fromClient.sendSimTime, fromClient.throttle, fromClient.engineSpeed, fromClient.dropRate, fromClient.rtt, fromClient.d_rel, fromClient.T_TB, fromClient.v_lead, fromClient.v_ego);
        }

        // Receive the packet of data from the Server
        n = recvfrom(G.sockfd, (char*)&fromServer, sizeof(fromServer), 0, NULL, NULL);
        if (n == SOCKET_ERROR || n == 0)
        {	int error = WSAGetLastError() ;
        if (error != WSAEWOULDBLOCK && error != WSAECONNRESET)
            fprintf(ofp, "Error reading socket.  WSAGetLastError() returned %i\n", error);
        }
        else
        {
            LARGE_INTEGER LItRecv ;

            // Get the time of arrival and compute the RTT.
            QueryPerformanceCounter(&LItRecv) ;
			timeLastReceived = ((double)(LItRecv.QuadPart - G.LIstartTime.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)) ;
            
            
            RTT = ((double)(LItRecv.QuadPart - fromServer.sendTimeStamp.QuadPart)) / ((double)(G.LIticksPerSecond.QuadPart)) ;
            G.packetsReceived++ ;

            // Verify that ICDs are consistent by confirming the version tag.
            if (firstPacket)
            {
                if ( strcmp( fromServer.icdVersion, LONG_HAUL_ICD_VERSION ) != 0 )
                {
                    fprintf(ofp, "ERROR: Local and Remote ICDs do not match. Remote = %s, Local = %s\n", fromServer.icdVersion, LONG_HAUL_ICD_VERSION);
                    return 1;
                }
                firstPacket = 0;
				firstPacketNumber = fromServer.packetNumber;
            }

			if (!firstPacket)
				dropRate = (double)(G.packetsSent-firstPacketNumber+1-G.packetsReceived)/(G.packetsSent-firstPacketNumber+1);

            //fprintf(ofp, "Received packet %i: Torque = %f\n", fromServer.packetNumber, fromServer.engineTorque);
            //fprintf(ofp, "Server simulation time = %f s\n", fromServer.sendSimTime);
            // Internalize data if packet contains new information
            if (fromServer.packetNumber > G.currentEvent)
            {
                // Register packet arrival event.
                //G.arrivalTime = simTime ;
				newTarget = true ;
				timedOut = false ;

                // Populate the output terminals
                outarr[0]  = fromServer.engineTorque;
				outarr[2]  = dropRate;
				outarr[3]  = RTT;
                // int iloop;
                for (iloop = 1; iloop < 41; iloop++) { //modify server NP+1
                    outarr[iloop+3] = fromServer.v_opt_array[iloop-1];}
            }
            else
            {
                //fprintf(ofp, "Ignoring outdated packet.\n");
            }
			//Record Server packet
			fprintf (ufp,"%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", fromServer.packetNumber, timeNow, abstimeNow, fromClient.sendSimTime, fromServer.sendSimTime, fromServer.engineTorque, fromServer.v_opt_array[0], fromServer.v_opt_array[39]);
        }
    }
	// This code implements a time-out if a packet is not received before timeOut seconds.
  // If a packet is not received, the torque defaults to a nominal torque value
  if ( timeNow > timeLastReceived + timeOut && !timedOut && firstPacketNumber != 0)
  {
	timedOut = true ;
	fprintf(ofp,"WARNING: Connection timed out!\n");
  }


  //Output the actual time
	outarr[1] = timeNow;

    return 0;
}

int udpClient_Terminate ()
{
    int error;
    fprintf (ofp,"\nTerminating...\n");
    error = closesocket(G.sockfd);
    if (!error)
        fprintf (ofp,"Socket closed.\n");
    else
        fprintf (ofp,"Error in closesocket: %i\n",WSAGetLastError());

    error = WSACleanup();
    if (!error)
        fprintf (ofp,"Termination completed.\n");
    else
        fprintf (ofp,"Error in WSACleanup(): %i\n",WSAGetLastError());

    fclose(ofp);
	fclose(tfp);
	fclose(ufp);
    return 0; // Indicate that the function was terminated successfully.
}
