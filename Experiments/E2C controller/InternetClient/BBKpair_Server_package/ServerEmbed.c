/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

#include <stdio.h>
#include <string.h>
#include <winsock2.h>
#include <math.h>
#include <time.h>
#include "LongHaul.h"

FILE *ofp; // Output file pointer. This file records messages. Use this file for debugging and monitoring
FILE *tfp; //Client data file pointer. This file records the Client packets
FILE *ufp; //Server data file pointer. This file records the Server packets

const char * serverIPAddress = "141.212.177.60";// PC ME-ERSALLAB06
// const char * serverIPAddress = "35.3.106.192";// Dell laptop
const char * clientIPAddress = "141.212.177.51";// PC Assanislab43

int UDPPort = 5100;
float timeHorizon = 0.0;

#ifndef __LONG_HAUL_REMOTE_DECLARATIONS__
#define __LONG_HAUL_REMOTE_DECLARATIONS__
typedef struct
{
    SOCKET        sockfd ;
    SOCKADDR_IN  	recvAddr;
    SOCKADDR_IN  	fromAddr;
    int           fromSize ;
    LARGE_INTEGER	LIstartTime ;
    LARGE_INTEGER	LIeventTimeStamp ;
    LARGE_INTEGER	LIticksPerSecond ;
    bool replySent ;

    float  timeSinceLastUpdate ;
    int    currentEvent ;
    int    lastEventReceived ;
    float  arrivalTime ;
    int    packetsSent ;
    int    packetsReceived ;
    float  throttle ;
    float  engineSpeed ;
    float  d_rel ;
    float  T_TB ;
    float  v_lead ;
    float  v_ego ;
    float  v_lead_pre[2] ; //modify here NP
} LH_SharedData;
#endif //__LONG_HAUL_REMOTE_DECLARATIONS__

LH_SharedData G;

typedef struct
{
    double simTime;
    double engineTorque;
    double v_opt_array[2]; //modify server

} myInputs;

int firstPacket = 1 ;
int noOfFunctionCalls = 1; //Number of function calls per major integration step: ode5->6, ode4->4
int tick;

LARGE_INTEGER tickCPU;   // A point in time
LARGE_INTEGER initialTick;  //The tick value at the start of the simulation
double actualTime;   // For converting tick into real time

int udpServer_Initialize ()
{
    // Connect a UDP socket
    WSADATA wsaData;
    SOCKADDR_IN  	recvAddr;
    SOCKET  	sockfd ;
    struct fd_set selectFds ;
    struct timeval selWaitTime ;

    int	n;
    int i ;
    int iResult ;
    unsigned long ioctlIn = 1 ; // For non-blocking socket.

    int rttPacket ;
    double rttDelay ;

    ofp = fopen("logServer.txt","w");
    tfp = fopen("packetsClient_server.txt","w");
    ufp = fopen("packetsServer_server.txt","w");
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
    // Create the address structure.
    memset(&G.recvAddr, 0, sizeof(G.recvAddr));
    G.recvAddr.sin_family      = AF_INET;
    G.recvAddr.sin_addr.s_addr = inet_addr( serverIPAddress ); // htonl(INADDR_ANY); //
    G.recvAddr.sin_port        = htons(UDPPort);
    fprintf (ofp,"Created address structure\n");

    //-----------------------------
    // Bind to the receive address
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
    // Make the socket non-blocking.
    ioctlIn = 1 ; // For non-blocking socket.
    n = ioctlsocket(G.sockfd, FIONBIO, &ioctlIn) ;
    if (n == SOCKET_ERROR)
    {	int error = WSAGetLastError() ;
    fprintf (ofp,"Error calling ioctlsocket().  WSAGetLastError() returned %i\n", error);
    }
    else
        fprintf (ofp,"Socket made non-blocking successfully!\n");


    //----------------------------------------------
    // Get the clock resolution and the initial time.
    QueryPerformanceFrequency(&(G.LIticksPerSecond)) ;
    if (!QueryPerformanceCounter(&(G.LIstartTime)) )
        fprintf (ofp,"Error: High resolution clock not available.\n");
    else
        fprintf (ofp,"Clock resolution is %f ns.\n", 1.0E9 / (double)G.LIticksPerSecond.QuadPart);

    G.replySent = true;
    G.currentEvent = 0;
    G.packetsSent = 0;
    G.packetsReceived = 0;
    firstPacket = 1;
    tick = noOfFunctionCalls;

    fprintf (ofp,"Initialization completed.\n\n");
    return 0; // Indicate that the function was initialized successfully.
}

int udpServer_CommunicateThroughUDP (double *inarr, int inputs, double *outarr, int outputs, int major)
{

    myInputs myIns;

    SOCKADDR_IN fromAddr;
    int fromSize ;
    LARGE_INTEGER LItSend ;
    //static int tick = 0 ;
    //int packetNo = 0 ;

    float RTT ;
    int n ;
    int iResult;
    int thereIsNewPacket = false; // 122819T1229

    ToClient   fromServer ;
    ToServer  fromClient ;

    int myMajor=0;

    myIns.simTime = inarr[0];
    myIns.engineTorque = inarr[1];
    //myIns.v_opt_array
    int iloop;
    for (iloop = 1; iloop < 3; iloop++) { //modify server NP+1
        myIns.v_opt_array[iloop-1] = inarr[iloop+1];}
    

    //fprintf(ofp,"simTime = %f, ",myIns.simTime);
    if (tick++ % noOfFunctionCalls == 0)
        myMajor = 1;
    //fprintf(ofp,"major = %i\n",myMajor);
    if (myMajor)
    {
        if (myIns.simTime == 0)
            outarr[2]  = 0;

		//find the actual time;
        QueryPerformanceCounter(&tickCPU);
        if (myIns.simTime == 0)
            initialTick = tickCPU;
        // convert the tick number into the number of seconds since the system was started...
        actualTime = (tickCPU.QuadPart-initialTick.QuadPart)/(double)G.LIticksPerSecond.QuadPart;
        while (myIns.simTime > actualTime*1)
        {
            QueryPerformanceCounter(&tickCPU);
            actualTime = (tickCPU.QuadPart-initialTick.QuadPart)/(double)G.LIticksPerSecond.QuadPart;
        }
        // Server site is driven by the receipt of a packet from the client site
        fromSize = sizeof(SOCKADDR_IN) ;
        n = recvfrom(G.sockfd, (char*)&fromClient, sizeof(fromClient), 0, (struct sockaddr*)&fromAddr, &fromSize);
        if (n == SOCKET_ERROR)
        {	int error = WSAGetLastError() ;
        if (error != WSAEWOULDBLOCK)
            fprintf (ofp,"Error reading socket.  WSAGetLastError() returned %i\n", error);
        }
        else
        {
            // Make sure there are no further packets waiting in line
            while (n != SOCKET_ERROR)
            {
                if (fromClient.packetNumber > G.currentEvent)
                {
                    thereIsNewPacket = true;
                    G.currentEvent = fromClient.packetNumber ;
                }
                n = recvfrom(G.sockfd, (char*)&fromClient, sizeof(fromClient), 0, (struct sockaddr*)&fromAddr, &fromSize);
            } // 122819T1229

            LARGE_INTEGER LItRecv ;

            G.fromAddr = fromAddr ;
            G.fromSize = fromSize ;
            G.packetsReceived++ ;

            // Verify that ICDs are consistent by confirming the version tag.
            if (firstPacket)
            {
                if ( strcmp( fromClient.icdVersion, LONG_HAUL_ICD_VERSION ) != 0 )
                {
                    fprintf (ofp,"ERROR: Local and Remote ICDs do not match. Remote = %s, Local = %s\n", fromServer.icdVersion, LONG_HAUL_ICD_VERSION);
                    return 1;
                }
                firstPacket = 0 ;
            }

            // Internalize data if packet contains new information
            //outputStream << "Received packet number " << fromClient.packetNumber << "\n";
            //outputStream << "Current event is " << G.currentEvent << "\n";
            //if (fromClient.packetNumber > G.currentEvent) // 122819T1229
            if (thereIsNewPacket) // 122819T1229
            {
                //fprintf (ofp,"Server sim time = %fs;\n", myIns.simTime);
                //fprintf (ofp,"Received Packet %i: Client sim time = %fs, throttle = %f, shaft speed = %f\n", fromClient.packetNumber, fromClient.sendSimTime, fromClient.throttle, fromClient.shaftSpeed);

                // Register packet arrival event.
                G.arrivalTime = myIns.simTime ;
                G.LIeventTimeStamp = fromClient.sendTimeStamp ;
                G.currentEvent     = fromClient.packetNumber ;
                G.timeSinceLastUpdate = 0.0 ;
                G.replySent = false ;

                // Populate the output terminals
                outarr[0] = fromClient.engineSpeed;
                outarr[1] = fromClient.throttle;
                outarr[2]  = fromClient.sendSimTime;
                outarr[3] = fromClient.dropRate;
                outarr[4] = fromClient.rtt;
                outarr[6] = fromClient.d_rel;
                outarr[7] = fromClient.T_TB;
                outarr[8] = fromClient.v_lead;
                outarr[9] = fromClient.v_ego;
                //outarr[10] = fromClient.v_lead_pre[0];
                //outarr[11] = fromClient.v_lead_pre[1];
                int iloop;
                for (iloop = 1; iloop < 3; iloop++) { //modify here NP+1
                    outarr[iloop+9] = fromClient.v_lead_pre[iloop-1];}


            }
        }

        //outputStream << "G.timeSinceLastUpdate = " << G.timeSinceLastUpdate << ", G.replySent = " << G.replySent << "\n";
        if (!G.replySent)
        {
            double tSend ;
            LARGE_INTEGER dt ;
            int selRet ;
            // Query the high resolution clock
            // QueryPerformanceCounter(&LItSend) ;

            // Fill the packet with the data to be sent

            // Header info.
            strcpy(fromServer.icdVersion, LONG_HAUL_ICD_VERSION) ;
            fromServer.packetNumber  = G.currentEvent ;
            fromServer.sendTimeStamp = G.LIeventTimeStamp ;

            // Control signals.
            fromServer.engineTorque   = myIns.engineTorque;
            int iloop;
            for (iloop = 1; iloop < 3; iloop++) { //modify server NP+1
                fromServer.v_opt_array[iloop-1]   = myIns.v_opt_array[iloop-1];}

            // Information signals.
            fromServer.sendSimTime        = myIns.simTime;


            // Send the packet back to a different port.
            G.fromAddr.sin_port = htons(5101) ;

            iResult = sendto(
            G.sockfd, (char*)&fromServer, sizeof(fromServer), 0,
            (struct sockaddr*)&(G.fromAddr), fromSize
            );
            G.packetsSent++ ;
            G.replySent = true ;
            //if (iResult != SOCKET_ERROR)
            //	outputStream << "Packet of size " << iResult << " bytes sent successfully!\n";

            //Record Client packet
            fprintf (tfp,"%i\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n",fromClient.packetNumber, actualTime, myIns.simTime, fromClient.sendSimTime, fromClient.throttle, fromClient.engineSpeed, fromClient.dropRate, fromClient.rtt);
            //Record Server packet
            fprintf (ufp,"%d\t%f\t%f\t%f\t%f\t%f\n", fromServer.packetNumber, actualTime, fromServer.sendSimTime, fromServer.engineTorque, fromServer.v_opt_array[0], fromServer.v_opt_array[1]);

        }

        G.timeSinceLastUpdate = myIns.simTime-G.arrivalTime ;

        //output the actual time;
        outarr[5] = actualTime;
    }

    return 0; //Indicate that communication was successful.
}

int udpServer_Terminate ()
{
    int error;
    fprintf (ofp,"Terminating...\n");
    error = closesocket(G.sockfd);
    if (!error)
        fprintf (ofp,"Socket closed.\n");
    else
        fprintf (ofp,"Error in closesocket: %i\n",WSAGetLastError());

    error = WSACleanup();
    if (!error)
        fprintf (ofp,"Termination completed.");
    else
        fprintf (ofp,"Error in WSACleanup(): %i",WSAGetLastError());

    fclose(ofp);
    fclose(tfp);
    fclose(ufp);
    return 0; // Indicate that the function was terminated successfully.
}
