/**********************************************************
 * Copyright by Tulga Ersal (tersal@umich.edu)
 * University of Michigan
 * 26 Apr 2019
 **********************************************************/

/* This file implements the Simulink S-Function framework */

/* Note1: Not all variables are needed for the calculation of the outputs
   of the submodel. The OUTPUT_EQUATIONS calculate all variables that do
   not contribute to the dynamics of the model (only depend on its results).
   Specially for Simulink a new set of output equations is made
   called OUTPUT2_EQUATIONS that only calculates the outputs of the submodel
   and not all these variables. Since the calculation of the other variables is
   not really necessary, it is removed from the template for performance reasons.

   The user may also include the computation of these additional variables by
   calculating them just after the dynamic equations inside mdlDynamic()
   like this:

   DYNAMIC_EQUATIONS
   OUTPUT_EQUATIONS
*/

/* Note2: Alias variables are the result of full optimization
   of the model in 20-sim. As a result, only the real variables
   are used in the model for speed. The user may also include
   the alias variables by adding them to the the template like this:
   (don't forget to add % signs around the following token names)

   XXDouble VARPREFIXvariables[NUMBER_VARIABLES + NUMBER_ALIAS_VARIABLES + 1];
   XXString VARPREFIXvariable_names[] = {
   VARIABLE_NAMES,	ALIAS_VARIABLE_NAMES,	NULL
   };

   and calculate them directly after the reduced output equations in mdlOutputs()
   like this:

   OUTPUT2_EQUATIONS
   ALIAS_EQUATIONS
*/

/* the name of your S-Function */
#define S_FUNCTION_NAME InternetServer

/* matlab include files */
#include <simstruc.h>
#include <math.h>

/* 20-sim include files */
#include "xxtypes.h"
#include "xxmatrix.h"

//Tulga include files
#include "ServerEmbed.h"

/* global simulation structure */
SimStruct *MyS = NULL;

/* the submodel io variables */
const XXInteger xx_number_of_inputs = 3;//modify server 1*1+1*(NP=40)
const XXInteger xx_number_of_outputs = 12;//modify here 6*1+1*(NP=40)+4
const XXInteger xx_number_of_favorite_parameters = 0;
const XXInteger xx_number_of_favorite_variables = 0;

/* the variable arrays */
XXDouble xx_P[2];		/* parameters */
XXDouble xx_V[17];		/* variables *///modify here //modify server xx_number_of_outputs+xx_number_of_inputs+2
XXMatrix xx_M[2];		/* matrices */
XXDouble xx_U[12];		/* unnamed */ //modify here xx_number_of_outputs

/* start and finish time */
const XXDouble xx_start_time = 0.0;
const XXDouble xx_finish_time = 400.0;

/* the names of the variables as used in the arrays above
   uncomment this part if you need these names
XXString xx_input_names[] = {
	"engine.e"
,	NULL
};
XXString xx_output_names[] = {
	"actualTime",
	"dropRate",
	"engine.f",
	"rtt",
	"sendSimTime",
	"throttle",
    "throttle"
,	NULL
};
XXString xx_parameter_names[] = {
	"dll_name",
	"function_name"
,	NULL
};
XXString xx_variable_names[] = {
	"engine.e",
	"engine.f",
	"throttle",
	"sendSimTime",
	"dropRate",
	"rtt",
	"actualTime",
	"in[1,1]",
	"in[1,2]"
,	NULL
};
XXString xx_matrix_names[] = {
	"in",
	"xx_U1"
,	NULL
};
*/

/* boolean indicating initialization phase */
XXBoolean xx_initialize;

/* just include c-sources to make the mex command work on a single file */
/* 20-sim c-include files */
#include "xxfuncs.c"
#include "xxmatrix.c"
#include "xxinverse.c"

//Tulga c-include files
#include "ServerEmbed.c"

/* mdlInitializeSizes - initialize the sizes array
 *
 * The sizes array is used by SIMULINK to determine the S-function blocks
 * characteristics (number of inputs, outputs, states, etc.).
 *
 * The direct feedthrough flag can be either 1=yes or 0=no. It should be
 * set to 1 if the input, "u", is used is the mdlOutput function. Setting this
 * to 0 is asking to making a promise that "u" will not be used in the mdlOutput
 * function. If you break the promise, then unpredictable results will occur.
 */
static void mdlInitializeSizes (SimStruct *S)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* continuous time model */
	ssSetNumContStates (S, 0);                          /* number of continuous states */
	ssSetNumDiscStates (S, 0);                          /* number of discrete states */
	ssSetNumInputs (S, xx_number_of_inputs);            /* number of inputs */
	ssSetNumOutputs (S, xx_number_of_outputs);          /* number of outputs */
	ssSetDirectFeedThrough (S, XXTRUE);                 /* direct feedthrough flag */
	ssSetNumSampleTimes (S, 1);                         /* number of sample times */
	ssSetNumSFcnParams (S, xx_number_of_favorite_parameters); /* number of input arguments */
	ssSetNumRWork (S, 0);                               /* number of real work vector elements */
	ssSetNumIWork (S, 0);                               /* number of integer work vector elements */
	ssSetNumPWork (S, 0);                               /* number of pointer work vector elements */

	/* check the amount of favorite parameters */
	if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
	{
		/* give an error */
		ssSetErrorStatus (S, "wrong number of parameters given by Simulink");
		return;
	}
}


/* mdlInitializeSampleTimes - initialize the sample times array
 *
 * This function is used to specify the sample time(s) for your S-function.
 * You must register the same number of sample times as specified in
 * ssSetNumSampleTimes. If you specify that you have no sample times, then
 * the S-function is assumed to have one inherited sample time.
 *
 * The sample times are specified period, offset pairs. The valid pairs are:
 *
 *   [CONTINUOUS_SAMPLE_TIME   0     ]  : Continuous sample time.
 *   [period                   offset]  : Discrete sample time where
 *                                        period > 0.0 and offset < period or
 *                                        equal to 0.0.
 *   [VARIABLE_SAMPLE_TIME     0     ]  : Variable step discrete sample time
 *                                        where mdlGetTimeOfNextVarHit is
 *                                        called to get the time of the next
 *                                        sample hit.
 *
 *  or you can specify that the sample time is inherited from the driving
 *  block in which case the S-function can have only one sample time:
 *    [CONTINUOUS_SAMPLE_TIME    0    ]
 */
static void mdlInitializeSampleTimes (SimStruct *S)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* continuous time model */
	ssSetSampleTime (S, 0, CONTINUOUS_SAMPLE_TIME);
	ssSetOffsetTime (S, 0, 0.0);
}

/* mdlInitializeConditions - initialize the states
 *
 * In this function, you should initialize the continuous and discrete
 * states for your S-function block.  The initial states are placed
 * in the x0 variable.  You can also perform any other initialization
 * activities that your S-function may require.
 */
static void mdlInitializeConditions (double *x0, SimStruct *S)
{
	int index;
    int iloop;
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;
	/* set the model parameters */
	xx_P[0] = XXString2Double ("udpUM.dll");		/* dll_name */
	xx_P[1] = XXString2Double ("CommunicateThroughUDP");		/* function_name */


	/* set the model matrices */
	xx_M[0].mat = &xx_V[13];		/* in */ //modify here xx_number_of_outputs+1
	xx_M[0].rows = 1;
	xx_M[0].columns = 4;  //modify server xx_number_of_inputs+1
	xx_M[1].mat = &xx_U[0];		/* xx_U1 */
	xx_M[1].rows = 1;
	xx_M[1].columns = 12;  //modify here xx_number_of_outputs


	/* indicate initial model computations */
	xx_initialize = XXTRUE;

	/* the initial model equations */
	udpServer_Initialize ();


	/* the static model equations */


	/* the input model equations */
    xx_M[0].mat[0] = 0;
	xx_M[0].mat[1] = 0;
    iloop = 1;
    for (iloop = 1; iloop < 3; iloop++) {  //modify server iloop<NP+1
        xx_M[0].mat[iloop+1] = 0.0;}
    
	/* done with initialization */
	xx_initialize = XXFALSE;
}


/* mdlDerivatives - compute the derivatives
 *
 * In this function, you compute the S-function blocks derivatives.
 * The derivatives are placed in the dx variable.
 */
static void mdlDerivatives (double *dx, double *x, double *u, SimStruct *S, int tid)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;
    int iloop;
    
	/* Continuous-time model */

	/* copy the supplied input vector u to the model inputs */
	xx_V[0] = u[0];		/* engine.e */
    iloop = 1;
    for (iloop = 1; iloop < 3; iloop++) {  //modify server iloop<NP+1
        //xx_V[iloop+12] = u[iloop];}
        xx_V[iloop] = u[iloop];}

	/* dynamic model equations */
	/* in = [time, engine.e]; */
	xx_M[0].mat[0] = xx_time;
	xx_M[0].mat[1] = xx_V[0];
    iloop = 1;
    for (iloop = 1; iloop < 3; iloop++) {  //modify server iloop<NP+1
        //xx_M[0].mat[iloop+1] = xx_V[iloop+12];
        xx_M[0].mat[iloop+1] = xx_V[iloop];}

}


/* mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs (double *y, double *x, double *u, SimStruct *S, int tid)
{
	int index;
    int iloop;
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* is there a direct relation between inputs and outputs? */
	if (XXTRUE)
	{
	/* copy the supplied input vector u to the model inputs */
	xx_V[0] = u[0];		/* engine.e */
    iloop = 1;
    for (iloop = 1; iloop < 3; iloop++) {  //modify server iloop<NP+1
        //xx_V[iloop+12] = u[iloop];}
        xx_V[iloop] = u[iloop];}
	}

	/* output equations */

	/* in = [time, engine.e]; */
	xx_M[0].mat[0] = xx_time;
	xx_M[0].mat[1] = xx_V[0];
    iloop = 1;
    for (iloop = 1; iloop < 3; iloop++) {  //modify server iloop<NP+1
        xx_M[0].mat[iloop+1] = xx_V[iloop];}
        //xx_M[0].mat[iloop+1] = xx_V[iloop+12];}
    
    
	/* [engine.f, throttle, sendSimTime, dropRate, rtt, actualTime] = dll (dll_name, function_name, in); */
	udpServer_CommunicateThroughUDP (xx_M[0].mat, 4, xx_M[1].mat, 12, xx_major);
    //modify here xx_M[1].mat, xx_number_of_outputs
    //modify server xx_M[0].mat, xx_number_of_inputs+1
	/* [engine.f, throttle, sendSimTime, dropRate, rtt, actualTime] = dll (dll_name, function_name, in); */
	xx_V[1] = xx_M[1].mat[0];
	xx_V[2] = xx_M[1].mat[1];
	xx_V[3] = xx_M[1].mat[2];
	xx_V[4] = xx_M[1].mat[3];
	xx_V[5] = xx_M[1].mat[4];
	xx_V[6] = xx_M[1].mat[5];
    xx_V[7] = xx_M[1].mat[6];
    xx_V[8] = xx_M[1].mat[7];
    xx_V[9] = xx_M[1].mat[8];
    xx_V[10] = xx_M[1].mat[9];
    //xx_V[11] = xx_M[1].mat[10];
    //xx_V[12] = xx_M[1].mat[11];
    for (iloop = 1; iloop < 3; iloop++) {  //modify here NP+1
        xx_V[iloop+10] = xx_M[1].mat[iloop+9];}

	/* copy the model outputs into the supplied output vector y */
	y[0] = 	xx_V[6];		/* actualTime */
	y[1] = 	xx_V[4];		/* dropRate */
	y[2] = 	xx_V[1];		/* engine.f */
	y[3] = 	xx_V[5];		/* rtt */
	y[4] = 	xx_V[3];		/* sendSimTime */
	y[5] = 	xx_V[2];		/* throttle */
    y[6] = 	xx_V[7];		/* d_rel */
    y[7] = 	xx_V[8];		/* T_TB */
    y[8] = 	xx_V[9];		/* v_lead */
    y[9] = 	xx_V[10];		/* v_ego */
    //y[10] = xx_V[11];		/* v_ego */
    //y[11] = xx_V[12];		/* v_ego */
    for (iloop = 1; iloop < 3; iloop++) { //modify here NP+1
        y[iloop+9] = xx_V[iloop+10];}



	/* input model equations for the next call to mdlDynamic */

}


/* mdlUpdate - perform action at major integration time step
 *
 * This function is called once for every major integration time step.
 * Discrete states are typically updated here, but this function is useful
 * for performing any tasks that should only take place once per integration
 * step.
 */
static void mdlUpdate (double *x, double *u, SimStruct *S, int tid)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

}


/* mdlTerminate - called when the simulation is terminated.
 *
 * In this function, you should perform any actions that are necessary
 * at the termination of a simulation.  For example, if memory was allocated
 * in mdlInitializeConditions, this is the place to free it.
 */
static void mdlTerminate (SimStruct *S)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* final model equations */
	udpServer_Terminate ();

}

/* Is this file being compiled as a MEX-file? */
#ifdef	MATLAB_MEX_FILE

/* MEX-file interface mechanism */
#include "simulink.c"

#else

/* code generation registration function */
#include "cg_sfun.h"

#endif
