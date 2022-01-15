clc
clear all
close all

load('MPGTest_Res.mat');
%% Computing the vehicle mpg
N = 101;

lead_mpg = [];
lead_v = [];

follow_mpg = [];
follow_v = [];
platoon_mpg = [];

for i = 1:1:N-1
    Index_temp = find(Time > 150*i-20 & Time < 150*i);
    lead_v = [lead_v mean(Lead_Vehicle_Speed(Index_temp))];
    lead_mpg = [lead_mpg mean(Lead_Vehicle_MPG(Index_temp))];
    follow_v = [follow_v mean(Follow_Vehicle_Speed(Index_temp))];
    follow_mpg = [follow_mpg mean(Follow_Vehicle_MPG(Index_temp))];
    platoon_mpg = [platoon_mpg mean(Platoon_MPG(Index_temp))];
end

figure
plot(lead_v,lead_mpg,'-.')
xlabel('Lead Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on

figure
plot(follow_v,follow_mpg,'-.')
xlabel('Follow Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on

figure
plot(Time,Lead_Vehicle_Speed,'-')
xlabel('Time [s]')
ylabel('Lead Vehicle Speed [mph]')
grid on

figure
plot(Time,Follow_Vehicle_Speed,'-')
xlabel('Time [s]')
ylabel('Follow Vehicle Speed [mph]')
grid on

figure
plot(lead_v,platoon_mpg,'-r')
xlabel('Platoon Speed [mph]')
ylabel('Net Fuel Efficiency [mpg]')
grid on

figure
plot(Time,Headway,'-')
xlabel('Time [s]')
ylabel('Headway [m]')
grid on

save('MPGTest_Res_Cal.mat','lead_mpg','lead_v','follow_mpg','follow_v','platoon_mpg')
