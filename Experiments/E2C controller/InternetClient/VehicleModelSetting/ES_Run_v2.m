clear all
close all
clc

vesim_init;
SimTime = 1e4;

%% parameters for extremum seeking

k = 10;
omega_l = 0.0005;
omega_h = 0.0005;
a = 0.01;
omega = 0.01;

sim('ES_Test_v2')

figure
plot(Time,Lead_Vehicle_Speed,'-r',Time,Follow_Vehicle_Speed,'--b')
xlabel('Time [s]')
ylabel('Vehicle Speed [mph]')
legend('Lead Vehicle','Follow Vehicle','location','best')

figure
plot(Time,UtilityFunc)
xlabel('Time [s]')
ylabel('Utility Function')

figure
plot(Time,Headway)
xlabel('Time [s]')
ylabel('Headway [m]')

figure
plot(Time,Theta_hat)
xlabel('Time [s]')
ylabel('$\hat{\theta}$','Interpreter','LaTex')
