/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  Internet.c
 *  subm:  Internet
 *  model: export to Simulink - TARDEC
 *  expmt: export to Simulink - TARDEC
 *  date:  October 10, 2008
 *  time:  8:25:19 pm
 *  user:  Student License
 *  from:  University of Michigan - Automated Modeling Lab.
 *  build: 4.0.1.3
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
#define S_FUNCTION_NAME Internet

/* matlab include files */
#include <simstruc.h>
#include <math.h>

/* 20-sim include files */
#include "xxtypes.h"
#include "xxmatrix.h"
#include "motionprofiles.h"
#include "EulerAngles.h"

//Tulga include files
#include "TARDECembedOld.h"

/* global simulation structure */
SimStruct *MyS = NULL;

/* the submodel io variables */
XXInteger xx_number_of_inputs = 3;                                          // *****(7);(6),[TH,BR,ST]*2
XXInteger xx_number_of_outputs = 8;                                        // ***(6),[UG,X,Y,PSI]*2+#TireLiftOff,PacketDelay,RTT,DropRate,ActualTime
XXInteger xx_number_of_favorite_parameters = 0;
XXInteger xx_number_of_favorite_variables = 0;

/* the variable arrays */
XXDouble xx_C[0 + 1];		/* constants */
XXDouble xx_P[2 + 1];		/* parameters */
XXDouble xx_I[0 + 1];		/* initial values */
XXDouble xx_V[50 + 1];		/* variables */
XXDouble xx_s[0 + 1];		/* states */
XXDouble xx_R[0 + 1];		/* rates (or new states) */
XXMatrix xx_M[2 + 1];		/* matrices */
XXDouble xx_U[17 + 1];		/* unnamed */
XXDouble xx_workarray[0 + 1];
XXDouble xx_F[0 + 1];	/* favorite parameters */
XXDouble xx_f[0 + 1];		/* favorite variables */

/* the names of the variables as used in the arrays above
   uncomment this part if you need these names
XXString xx_input_names[] = {
	"accel",
	"brake",
	"dist2D",
	"dist3D",
	"distOdometer",
	"LFwheelSlip",
	"localReady",
	"LRwheelSlip",
	"RFwheelSlip",
	"RRwheelSlip",
	"shaft.f",
	"speed",
	"steer",
	"terrainElevation",
	"terrainGrade",
	"accel"
,	NULL
};
XXString xx_output_names[] = {
	"dropRate",
	"engineSpeed",
	"engineTorque",
	"fuelRate",
	"injectionPressure",
	"injectionTiming",
	"needleLift",
	"remoteReady",
	"rtt",
	"shaft.e",
	"throttleSetting",
	"torqueConvSpeed",
	"torqueConvTorque",
	"transGear",
	"transGearRatio",
	"transSpeed",
	"transTorque"
,	NULL
};
XXString xx_constant_names[] = {
	NULL,	NULL
};
XXString xx_parameter_names[] = {
	"dll_name",
	"function_name"
,	NULL
};
XXString xx_initial_value_names[] = {
	NULL,	NULL
};
XXString xx_variable_names[] = {
	"accel",
	"shaft.e",
	"shaft.f",
	"remoteReady",
	"engineSpeed",
	"engineTorque",
	"throttleSetting",
	"fuelRate",
	"injectionTiming",
	"injectionPressure",
	"needleLift",
	"torqueConvSpeed",
	"torqueConvTorque",
	"transSpeed",
	"transTorque",
	"transGear",
	"transGearRatio",
	"localReady",
	"brake",
	"steer",
	"dist2D",
	"dist3D",
	"distOdometer",
	"speed",
	"accel",
	"terrainElevation",
	"terrainGrade",
	"LFwheelSlip",
	"RFwheelSlip",
	"LRwheelSlip",
	"RRwheelSlip",
	"dropRate",
	"rtt",
	"in[1,1]",
	"in[1,2]",
	"in[1,3]",
	"in[1,4]",
	"in[1,5]",
	"in[1,6]",
	"in[1,7]",
	"in[1,8]",
	"in[1,9]",
	"in[1,10]",
	"in[1,11]",
	"in[1,12]",
	"in[1,13]",
	"in[1,14]",
	"in[1,15]",
	"in[1,16]",
	"in[1,17]"
,	NULL
};
XXString xx_state_names[] = {
	NULL,	NULL
};
XXString xx_rate_names[] = {
	NULL,	NULL
};
XXString xx_matrix_names[] = {
	"in",
	"xx_U1"
,	NULL
};
XXString xx_favorite_par_names[] = {
	NULL, NULL
};
XXString xx_favorite_var_names[] = {
	NULL, NULL
};
*/

/* boolean indicating initialization phase */
XXBoolean xx_initialize;

/* just include c-sources to make the mex command work on a single file */
/* 20-sim c-include files */
#include "xxmexfcs.c"
#include "xxmatrix.c"
#include "xxinverse.c"
#include "EulerAngles.c"
#include "MotionProfiles.c"

//Tulga c-include files
#include "TARDECembedOld.c"

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

	/* what kind of model do we have? */
	if (XXFALSE)
	{
		/* discrete time model */
		ssSetNumContStates (S, 0);    			        /* number of continuous states */
		ssSetNumDiscStates (S, 0);	    /* number of discrete states */
	}
	else
	{
		/* continuous time model */
		ssSetNumContStates (S, 1);                      /* number of continuous states */
		ssSetNumDiscStates (S, 0);                      /* number of discrete states */
	}
	ssSetNumInputs (S, xx_number_of_inputs);    /* number of inputs */
	ssSetNumOutputs (S, xx_number_of_outputs);  /* number of outputs */
	ssSetDirectFeedThrough (S, XXFALSE);   /* direct feedthrough flag */
	ssSetNumSampleTimes (S, 1);                         /* number of sample times */
	ssSetNumSFcnParams (S, xx_number_of_favorite_parameters);		/* number of input arguments */
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
 *      
 *
 *  or you can specify that the sample time is inherited from the driving
 *  block in which case the S-function can have only one sample time:
 *    [CONTINUOUS_SAMPLE_TIME    0    ]
 */
static void mdlInitializeSampleTimes (SimStruct *S)
{
	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* what kind of model do we have? */
	if (XXFALSE)
	{
		/* discrete time model */
		ssSetSampleTime (S, 0, 0.01);                                      
	}
	else
	{
		/* continuous time model */
		ssSetSampleTime (S, 0, CONTINUOUS_SAMPLE_TIME);
	}
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

	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* set the model constants */


	/* set the model parameters */
	xx_P[0] = XXString2Double ("udpTARDEC.dll");		/* dll_name */
	xx_P[1] = XXString2Double ("CommunicateThroughUDP");		/* function_name */


	/* set the model initial values */


	/* set the model states */


	/* set the model matrices */
	xx_M[0].mat = &xx_V[33];		/* in */
	xx_M[0].rows = 1;
	xx_M[0].columns = 4;                                                   // *****(8);(7)
	xx_M[1].mat = &xx_U[0];		/* xx_U1 */
	xx_M[1].rows = 1;
	xx_M[1].columns = 8;                                                   // ***(6)


	/* set the favorites */



	/* indicate initial model computations */
	xx_initialize = XXTRUE;

	/* obtain the favorite parameters from Simulink */
	for (index = 0; index < xx_number_of_favorite_parameters; index++)
		xx_F[index] = mxGetPr(ssGetSFcnParam(S, index))[0];

	/* the favorite parameters equations */


/* the initial model equations */
	udpTARDEC_Initialize ();


	/* the static model equations */


	/* the input model equations */
	//Tulga addition. If you don't do that, Simulink remembers the final values from the previous run and sends those.
	xx_M[0].mat[0] = 0; //time
	xx_M[0].mat[1] = 0; //FV_Spd
	xx_M[0].mat[2] = 0; //FV_FuelRate
	xx_M[0].mat[3] = 0; //ClientOffset
    
	//End Tulga addition

	/* copy the initial state values of the model into the supplied vector x0 */
	if (0 > 0)
		memcpy (x0, xx_s, 0 * sizeof (XXDouble));

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

	/* is this a continuous-time model? */
	if (!XXFALSE)
	{

	/* copy the supplied state vector x to the model states */
	if (0 > 0)
		memcpy (xx_s, x, 0 * sizeof (XXDouble));


	/* dynamic model equations */
	/* in = [time, accel, shaft.f, localReady, brake, steer, dist2D, dist3D, distOdometer, speed, accel, terrainElevation, terrainGrade, LFwheelSlip, RFwheelSlip, LRwheelSlip, RRwheelSlip]; */
	xx_M[0].mat[0] = xx_time;                                                
	xx_M[0].mat[1] = u[0]; //FV_Spd
	xx_M[0].mat[2] = u[1]; //FV_FuelRate
    xx_M[0].mat[3] = u[2]; //ClientOffset

	/* copy the model rates into the supplied rate vector dx */
	if (0 > 0)
		memcpy (dx, xx_R, 0 * sizeof (XXDouble));
	}
}


/* mdlOutputs - compute the outputs
 *
 * In this function, you compute the outputs of your S-function
 * block.  The outputs are placed in the y variable.
 */
static void mdlOutputs (double *y, double *x, double *u, SimStruct *S, int tid)
{
	int index;

	/* copy the SimStruct pointer S to the global variable */
	MyS = S;

	/* copy the supplied state vector x to the model states */
	if (0 > 0)
		memcpy (xx_s, x, 0 * sizeof (XXDouble));

	/* is there a direct relation between inputs and outputs? */
	if (XXTRUE)
	{
	

	/* output equations */

	/* in = [time, accel, shaft.f, localReady, brake, steer, dist2D, dist3D, distOdometer, speed, accel, terrainElevation, terrainGrade, LFwheelSlip, RFwheelSlip, LRwheelSlip, RRwheelSlip]; */
// 	xx_M[0].mat[0] = xx_time;
// 	xx_M[0].mat[1] = u[0]; //S1
// 	xx_M[0].mat[2] = u[1]; //S1_Derivative
// 	xx_M[0].mat[3] = u[2]; //S2
// 	xx_M[0].mat[4] = u[3]; //S2_Derivative
//  xx_M[0].mat[5] = u[4]; //acc
// 	xx_M[0].mat[6] = u[5]; //dec

    udpTARDEC_CommunicateThroughUDP (xx_M[0].mat, 4, xx_M[1].mat, 8, xx_major);  // ***** udpTARDEC_CommunicateThroughUDP (xx_M[0].mat, 8, xx_M[1].mat, 6, xx_major);

	/* copy the model outputs into the supplied output vector y */
	y[0] = 	xx_M[1].mat[0];		// Ref_Spd
    y[1] = 	xx_M[1].mat[1];		// LV_Spd
	y[2] = 	xx_M[1].mat[2];		// LV_Pos
    y[3] = 	xx_M[1].mat[3];		// packetDelay                              // ***
    y[4] =  xx_M[1].mat[4];    // RTT
    y[5] =  xx_M[1].mat[5];    // dropRate
    y[6] =  xx_M[1].mat[6];    // ActualTime
    y[7] =  xx_M[1].mat[7];    // ServerOffset


	/* set the favorite variables */


	/* obtain the favorite parameters from Simulink */
	for (index = 0; index < xx_number_of_favorite_parameters; index++)
		xx_F[index] = mxGetPr(ssGetSFcnParam(S, index))[0];

	/* use the favorites parameters */


	/* input model equations for the next call to mdlDynamic */
    }

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

	/* is this a discrete time model? */
	if (XXFALSE)
	{
		/* copy the calculated new states into the supplied state vector x */
		if (0 > 0)
			memcpy (x, xx_R, 0 * sizeof (XXDouble));
	}
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
	udpTARDEC_Terminate ();

}

/* Is this file being compiled as a MEX-file? */
#ifdef	MATLAB_MEX_FILE

/* MEX-file interface mechanism */
#include "simulink.c"

#else

/* code generation registration function */
#include "cg_sfun.h"

#endif                                 