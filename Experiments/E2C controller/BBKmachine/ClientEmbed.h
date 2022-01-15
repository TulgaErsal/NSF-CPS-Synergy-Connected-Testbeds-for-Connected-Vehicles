/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

// This file defines the functions necessary for UDP communication

#ifndef Client_H
#define Client_H

int udpClient_Initialize ();
int udpClient_CommunicateThroughUDP (double *inarr, int inputs, double *outarr, int outputs, int major);
int udpClient_Terminate ();

#endif //Client_H
