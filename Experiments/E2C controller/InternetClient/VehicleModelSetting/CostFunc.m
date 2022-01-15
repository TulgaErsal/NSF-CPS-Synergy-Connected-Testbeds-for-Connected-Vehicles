clear all
clc
close all

load MPGTest_Res_Cal.mat;

v = lead_v;
mpg = platoon_mpg;

figure
plot(v,mpg)
xlabel('Platoon Speed [mph]')
ylabel('Net Fuel Efficiency [mpg]')
grid on

%% Quadratic
y_q = [];
y_q_tot = [];
for i = 1:1:5;
   
    beta(i) = 0.0005*i;
    y_q(i,:) = beta(i)*(60^2-(v-60).^2); 
    y_q_tot(i,:) = y_q(i,:)+mpg;
end

figure
plot(v,y_q)
legend( ['\beta = ' num2str(beta(1))],['\beta = ' num2str(beta(2))],...
        ['\beta = ' num2str(beta(3))],['\beta = ' num2str(beta(4))],...
        ['\beta = ' num2str(beta(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Penalization for Speed')
grid on

figure
plot(v,y_q_tot)
legend( ['\beta = ' num2str(beta(1))],['\beta = ' num2str(beta(2))],...
        ['\beta = ' num2str(beta(3))],['\beta = ' num2str(beta(4))],...
        ['\beta = ' num2str(beta(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on

%% Sine
y_s = [];
y_s_tot = [];
for i = 1:1:5;
   
    gamma(i) = i;
    y_s(i,:) = gamma(i)*sin(pi/2/60*v); 
    y_s_tot(i,:) = y_s(i,:)+mpg;
end

figure
plot(v,y_s)
legend( ['\gamma = ' num2str(gamma(1))],['\gamma = ' num2str(gamma(2))],...
        ['\gamma = ' num2str(gamma(3))],['\gamma = ' num2str(gamma(4))],...
        ['\gamma = ' num2str(gamma(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Penalization for Speed')
grid on

figure
plot(v,y_s_tot)
legend( ['\gamma = ' num2str(gamma(1))],['\gamma = ' num2str(gamma(2))],...
        ['\gamma = ' num2str(gamma(3))],['\gamma = ' num2str(gamma(4))],...
        ['\gamma = ' num2str(gamma(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on

%% Exp
y_e = [];
y_e_tot = [];
for i = 1:1:5;
   
    rho(i) = 0.01*i;
    y_e(i,:) = 5*(1-exp(-rho(i)*v)); 
    y_e_tot(i,:) = y_e(i,:)+mpg;
end

figure
plot(v,y_e)
legend( ['\rho = ' num2str(rho(1))],['\rho = ' num2str(rho(2))],...
        ['\rho = ' num2str(rho(3))],['\rho = ' num2str(rho(4))],...
        ['\rho = ' num2str(rho(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Penalization for Speed')
grid on

figure
plot(v,y_e_tot)
legend( ['\rho = ' num2str(rho(1))],['\rho = ' num2str(rho(2))],...
        ['\rho = ' num2str(rho(3))],['\rho = ' num2str(rho(4))],...
        ['\rho = ' num2str(rho(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on


%% ND
y_n = [];
y_n_tot = [];
for i = 1:1:5;
   
    sigma(i) = 8*i;
    y_n(i,:) = 10*exp(-(v-60).^2/2/(sigma(i))^2); 
    y_n_tot(i,:) = y_n(i,:)+mpg;
end

figure
plot(v,y_n)
legend( ['\sigma = ' num2str(sigma(1))],['\sigma = ' num2str(sigma(2))],...
        ['\sigma = ' num2str(sigma(3))],['\sigma = ' num2str(sigma(4))],...
        ['\sigma = ' num2str(sigma(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Penalization for Speed')
grid on

figure
plot(v,y_e_tot)
legend( ['\sigma = ' num2str(sigma(1))],['\sigma = ' num2str(sigma(2))],...
        ['\sigma = ' num2str(sigma(3))],['\sigma = ' num2str(sigma(4))],...
        ['\sigma = ' num2str(sigma(5))],'location','best')
xlabel('Vehicle Speed [mph]')
ylabel('Fuel Efficiency [mpg]')
grid on
