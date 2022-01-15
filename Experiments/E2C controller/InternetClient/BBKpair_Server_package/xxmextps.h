/**********************************************************
 * This file is generated by 20-sim ANSI-C Code Generator
 *
 *  file:  xxmextps.h
 *  subm:  InternetUM
 *  model: export to Simulink - UM
 *  expmt: export to Simulink - UM
 *  date:  October 15, 2009
 *  time:  4:00:28 pm
 *  user:  Laboratory License
 *  from:  University of Michigan - Automated Modeling Lab.
 *  build: 4.1.0.4
 **********************************************************/

#ifndef XX_MEXTPS_H
#define XX_MEXTPS_H

/* macro definition to get the current simulation time.
 * probably the double is not necessary.
 * use a global structure here which must be given the correct
 * value when this function is called.
 */
#define xx_time (XXDouble)ssGetT(MyS)
#define xx_major   ssIsMajorTimeStep(MyS)

#endif

