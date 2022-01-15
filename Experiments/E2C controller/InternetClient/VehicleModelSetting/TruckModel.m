%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ******************Simulation codes for GVSETS paper*****
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%******************PART 1- Data processing/assignment****** 
clc
clear;
%Setting path for MATLAB to locate the files
addpath(genpath('.'));
[CurrentDirectory,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(CurrentDirectory))
%*********************** Loading data***********
initialize_model;
setPar_WHR;
load('FTP_Cycle');
MPGTest = load('MPGTest.dat'); 
%****Assigning initial conditions
x0 = struct();
x0.Ntc = 10000;
x0.Pim = 1.2e5;
x0.Pems = 1.4e5;
x0.Peml = 1.3e5;
x0.Pex = 1.05e5;
x0.Fim = .2;
x0.Fems =.6;
x0.Tem=400;
x0.Tw=400;
x0.Ne=900; %RPM
x0.VESP=10;%mps
x0.GL=1;% initial gear
Tamb=400;
Pamb=1e5;
% Shared parametrers for GVSETS paper
Lam_crit=1.1;
Fuel_lim=1;  % 1 for enabling and 2  for disabling
%GL=2;
mf_meas_Enbl=1;
c_r  = 0.008;
mass = 80000*0.453592; % kg GVW for Frieghtliner Cascadia evolution
%mass = 47627; % kg for an fully loaded LIN trailer +  M915A3 tractor
%mass = 13273; % kg for an empty LIN trailer +  M915A3 tractor
c_w  = 0.7;
A_a  = 10;
%gear_ratio = [14.56,9.42,6.24,4.63,3.40,2.53,1.83,1.36,1.00,0.74];  % From Eaton
%gear_levels=[1,2,3,4,5,6,7,8,9,10]; % From Eaton
gear_ratio = [4.70,2.21,1.53,1.00,0.76,0.67]; %Alisson 4500SP transmission
gear_levels=[1,2,3,4,5,6]; %Alisson 4500SP transmission
i_f = 3.4;
r_w = 0.57; % For M915A3 tracotr
rho=1;
Tshift=80;
V_step=5;
AlphaC_V2=[0.866,1,1.035,0.84;1,1.01,0.941,1;0.7,1,0.968,0.908;1,1,0.995,0.915;0.861,1,1,0.996;1,1,1,1];
AlphaT_V2=[0.891,1,0.974,0.929;1,0.987,0.949,1;0.901,1,0.970,0.9569;1,1,0.982,0.956;0.921,1,1,0.983;1,1,1,1];