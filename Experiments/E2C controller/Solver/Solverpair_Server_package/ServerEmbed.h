/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

// This file defines the functions necessary for accessing the MEX files

#ifndef Server_H
#define Server_H

int udpServer_Initialize ();
int udpServer_CommunicateThroughUDP (double *inarr, int inputs, double *outarr, int outputs, int major);
int udpServer_Terminate ();

#endif //Server_H
