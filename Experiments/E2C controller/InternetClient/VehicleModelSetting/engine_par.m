% Parameters of the engine speed controller and the vehicle speed controller

engine_inertia=0.53;		% kg-m^2
% trq_scale = 1.0;			% Egine scaling parameter
trq_scale = 0.5;			% Egine scaling parameter
rpm_idle = 750;			    % Engine idle speed
rpm0 = 800*rpm2rads;        % Engine initial speed (rad/s)
rpm_rated = 3300;			% Engine rated speed (rpm)
rpm_hi_idle=rpm_rated+200;  % Engine hi idle speed (rpm)
no_cyl=8;                   % Number of engine cylinders
Kp_rpm=2.7013;				% Engine-idle-speed-PID-controller's parameter
Ti_rpm=0.6464;				% Engine-idle-speed-PID-controller's parameter 
Tt_rpm=Ti_rpm/8.;	 		% Engine-idle-speed-controller's parameter
rpm0_c=1000;				% Engine initial speed (rpm) used in controller
rpm_max_c=rpm_rated;		% Engine maximum speed (rpm) used in controller
