clear all
close all
clc


% w12 = 49.95;
% w21 = 39.45;
% w23 = 70.8;
% w32 = 60.8;
% w34 = 103.04;
% w43 = 88.04;

w12 = 44.95;
w21 = 39.45;
w23 = 65.8;
w32 = 60.8;
w34 = 93.04;
w43 = 88.04;

dw12 = 50.41;
dw21 = 50.41;
dw23 = 77.75;
dw32 = 77.75;
dw34 = 118.26;
dw43 = 98.26;

throt = 0:0.01:1;

ws12 = w12 + dw12*throt;
ws21 = w21 + dw21*throt;
ws23 = w23 + dw23*throt;
ws32 = w32 + dw32*throt;
ws34 = w34 + dw34*throt;
ws43 = w43 + dw43*throt;

figure;
plot(ws12,throt,'-b',ws23,throt,'-b',ws34,throt,'-b')
hold on
plot(ws21,throt,'--r',ws32,throt,'--r',ws43,throt,'--r')
xlabel('Transmission Speed [rad/s]')
ylabel('Throttle [-]')
grid on