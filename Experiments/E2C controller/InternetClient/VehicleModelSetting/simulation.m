% Predefined simulation parameters and onstants

rpm2rads = 2*pi/60;		% Conversion from rpm to rad/s
ms2mph = 2.23694;			% Conversion from m/s to mph
time_step = 0.01;			% Time step for storage
time_step_fast = 0.001;	% Time step for fine storage
start_time = 0;			% Start of simulation
end_time = 140;			% End of simulation
num_points = (end_time-start_time)/time_step;			
num_points_fast = (end_time-start_time)/time_step_fast;
