/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

/* LongHaul.h , Version 1.0 */

/* This header file defines the interface control document between
 * Client and Server for the long-haul integration.
 * For data transferred, SI units should be used.
 */

#ifndef _LONG_HAUL_H_
#define _LONG_HAUL_H_

#define LONG_HAUL_ICD_VERSION	"1.0"

// From Client to Server
#pragma pack(push,1)
typedef struct
{ // Header information
  char icdVersion[8] ;		// Should be set to LONG_HAUL_ICD_VERSION and checked at remote site.
  int  packetNumber ;   	// Monotonically increasing integer
  LARGE_INTEGER sendTimeStamp ;	// Set by Local, value from QueryPerformanceCounter()
  LARGE_INTEGER echoTimeStamp ;	// Value copied directly from ToClient.sendTimeStamp.

  // Control Signals
  float throttle ;		// Driver command, [unitless, 0 - 1], 1 = full throttle.
  				// Remote site will clamp the throttle to 0.1 to stop sputtering.
  float engineSpeed ;		// At output of engine, [rad/sec], + = forward.
  float d_rel ;	//??
  float T_TB ; 
  float v_lead ; 
  float v_ego ; 
  float v_lead_pre[2] ; //modify here
  //float v_lead_pre[40] ; 
  
  // Health and status signals
  float dropRate ; 		// Packet counts: (sent - received) / sent, [unitless], >0
  float rtt ;			// Round trip time as measured by local, [sec], >0

  // Information signals
  float sendSimTime ;		// Simulation time that the sample was sent. [sec]

} ToServer ;
#pragma pack(pop)

// From Server to Client
#pragma pack(push,1)
typedef struct
{ // Header information
  char icdVersion[8] ;		// Should be set to LONG_HAUL_ICD_VERSION and checked at local site.
  int  packetNumber ;   	// Copied from ToServer packet.
  LARGE_INTEGER sendTimeStamp ;	// Set by Remote, value from QueryPerformanceCounter()
  LARGE_INTEGER echoTimeStamp ;	// Value copied directly from ToServer.sendTimeStamp.

  // Control Signals
  float engineTorque ;		// At output of engine, [N-m], + = forward.
  float v_opt_array[2] ;  //modify server
  
  // Information signals
  float sendSimTime ;		// Simulation time that the sample was sent. [sec]

} ToClient ;
#pragma pack(pop)

#endif
