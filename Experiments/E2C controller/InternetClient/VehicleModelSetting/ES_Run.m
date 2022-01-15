clear all
close all
clc

vesim_init;
SimTime = 2e4;

%% parameters for extremum seeking

k = 0.2;
omega_l = 0.01;
omega_h = 0.01;
a = 0.3;
omega = 0.2;

sim('ES_Test')

figure
plot(time,Vehicle_Speed)
xlabel('Time [s]')
ylabel('Speed [mph]')

figure
plot(time,Vehicle_MPG)
xlabel('Time [s]')
ylabel('Fuel Efficiency [mpg]')

figure
plot(time,Theta_hat)
xlabel('Time [s]')
ylabel('$\hat{\theta}$','Interpreter','LaTex')

% figure
% plot(time,Vehicle_Accel)
% xlabel('Time [s]')
% ylabel('Throttle: Acceleration')
% 
% figure
% plot(time,Vehicle_Decel)
% xlabel('Time [s]')
% ylabel('Throttle: Deceleration')