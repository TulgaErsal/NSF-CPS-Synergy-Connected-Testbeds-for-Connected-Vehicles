close all;
clear all;
clc;

restoredefaultpath
addpath(genpath(pwd))

%% set datafile filenames and other control parameters
test_date = '11202020';
test_folder = ['E:\~Umich\aftertreatmentproject\02022017-AFTThermal\2019DynoTest\',test_date,'HILTest'];
Test_i = 2;  % 5,7,8,9

Dell_filename_part = ['Test',num2str(Test_i),'\','*Test',num2str(Test_i),'.mat'];
Thinkpad_filename_part = ['Test',num2str(Test_i),'\','Solver_Test_',num2str(Test_i),'.mat'];
BBK_filename_part = ['HIL_*Test',num2str(Test_i),'_',test_date,'.mat'];
INCA_filename_part = sprintf(['NSF_',test_date(5:8),'_',test_date(1:2),'_',test_date(3:4),'_Test%02d.dat'], 3);
Puma_filename_part = ['*Report',num2str(Test_i),'.txt']; 
figure_prefix = ['Test',num2str(Test_i)];

DoPlot = false; 

pre_ftp_dtime = 1*(1377+60)-396; %  length before the "FTP" to be analyzed


%% unit change ratios:
kmph2mps = 0.277778;
mg2g = 1e-3;
gps2kgph = 3.6;
m2mile = 0.000621371;
gallon2kg = 3.1492918;                % related to diesel fuel density


%% LoadTestData and align time
LoadTestData


%% Plot test trace
PlotTestTrace


%% MPC:
f = fieldnames(solver_PARS);
for i = 1:length(f)
    MD.PARS.(f{i}) = solver_PARS.(f{i});
end
 
if exist('Thinkpad_filename', 'var')
    Process_Plot_MdlSolverPair;
end


%% repeatability tests:

idx_start_ic = idx_Puma2MD;
cycle_length = length(Data.Time) - idx_start_ic;
idx_start_ic_BBK = idx_BBK2MD;
cycle_length_BBK = length(Data_BBK.Time) - idx_start_ic_BBK;

num_cycles = 1;
num_cycles_list = [1:num_cycles];
Range.tspan = [0, 1400];
Range.Temperature = [150, 320];

idx_start_e2c = (pre_ftp_dtime + 506)*10;
idx_e2c_length = 8720;

Plot_Repeatability_Test


