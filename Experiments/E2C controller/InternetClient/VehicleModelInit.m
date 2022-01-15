restoredefaultpath

clear all
close all
addpath('Solverpair_Client_package');
addpath('BBKpair_Server_package');
addpath('RealtimeBlocks');
addpath('VehicleModelSetting');
addpath('Data');
addpath('Helpers');


%% initialize for follower model
vesim_init;
mass = 3123*1.3;
x0.Ne=600; %RPM
x0.VESP=0;%mph
VESP_MD = x0.VESP;


load('sldemo_autotrans_data.mat')
tq = PedalMapMD.Torque;
for i = 1:16
    for j = 2:17
        tq(i,j) = max(tq(i,j),tq(i,j-1));
    end
end
PedalMapMD.Torque = tq;
tq = PedalMapMD.Fuel;
for i = 1:16
    for j = 2:17
        tq(i,j) = max(tq(i,j),tq(i,j-1));
    end
end
PedalMapMD.Fuel = tq;


%% initialize for Eco controller
load('SpeedAcceMap8.mat')
data_import_11092017
Inp.FordData = FordData;
Inp.sf_Forddata = sf_Forddata;
Inp.effi = effi;


%% create (Ne,pedal)->mexh, TTBss maps
% interpolation gridpoints are PedalMapMD.Y,X
% Inp.FordData.spd, throttle
PedalMapMD.mexh = 0*PedalMapMD.Torque;
for i = 1:length(PedalMapMD.Y)
    if isempty(find(Inp.FordData.throttle(2:end,i)-Inp.FordData.throttle(1:end-1,i)<=0, 1))
        len = length(PedalMapMD.X);
    else
        len = min(find(Inp.FordData.throttle(2:end,i)-Inp.FordData.throttle(1:end-1,i)<=0));
    end
    PedalMapMD.mexh(i,:) = interp1([Inp.FordData.throttle(1,i)-1;Inp.FordData.throttle(1:len,i);Inp.FordData.throttle(len,i)+1],...
        [Inp.FordData.mf_exh(1,i);Inp.FordData.mf_exh(1:len,i);Inp.FordData.mf_exh(len,i)],PedalMapMD.X);
end
PedalMapMD.Teu = 0*PedalMapMD.Torque;
for i = 1:length(PedalMapMD.Y)
    if isempty(find(Inp.FordData.throttle(2:end,i)-Inp.FordData.throttle(1:end-1,i)<=0))
        len = length(PedalMapMD.X);
    else
        len = min(find(Inp.FordData.throttle(2:end,i)-Inp.FordData.throttle(1:end-1,i)<=0));
    end
    PedalMapMD.Teu(i,:) = interp1([Inp.FordData.throttle(1,i)-1;Inp.FordData.throttle(1:len,i);Inp.FordData.throttle(len,i)+1],...
        [Inp.FordData.t_eu(1,i);Inp.FordData.t_eu(1:len,i);Inp.FordData.t_eu(len,i)],PedalMapMD.X);
end

%%
% FTP_speed_once = PstPrcs.VSpeed(1:10:end);
FTP_speed_once = load_FTP_DC;
Idle_speed_once = zeros(60,1);
FTP_speed_1sec = [FTP_speed_once.speed;Idle_speed_once;FTP_speed_once.speed;Idle_speed_once;FTP_speed_once.speed]; % FTP_speed_once.speed; % 
% FTP_speed_1sec(1:7)=[];
% FTP_speed_1sec(1371:1377)=0;
% remove_first = 0;

remove_first = 396; % 425+7;
FTP_speed_1sec(1:remove_first)=[];
FTP_speed_1sec(end+1:end+remove_first)=0;

disp(' ----- set up PARS.t_StartSimulation in solver as: ')
disp(506-remove_first) % 506-remove_first + length(Idle_speed_once) + length(FTP_speed_once.speed)
disp(' ----- set up PARS.t_EndSimulation in solver as: ')
disp(double(length(FTP_speed_1sec)))

%% PARS: SolverInit and VehicleModelInit should agree
% --------------------- Store in PARS: Do not change these below!!!!!!!!-----------------
% should not change these!!!!!, they are used as constants already:
PARS.base_dT = 0.020;
PARS.NP = 40;                       % prediction horizon in s

% ---------------- Inputs: From workspace ------------------------------
% Select sources:
PARS.b_Engine_in_loop = 1;  % use engine map torque or measured torque
PARS.b_TTB_in_loop = 1;  % use simulate T_TB or measured T_TB
PARS.b_Ne_in_loop = 0;  % Set to 0 in test! Use simulated Ne or measured Ne.

% Select controller parameters:
PARS.t_StartSimulation = 506-remove_first; %  106; % % 73 + length(Idle_speed_once) + length(FTP_speed_once);
PARS.t_EndSimulation = 2814; % 1000; % 2814; % double(length(FTP_speed_1sec));        % 3000: total simulation time [s]
PARS.b_E2C_inloop = 1;     % Set to 1!!! 0 for debug and follow predefined trace.
PARS.bEgoFol = true;       % Agree with Solver! do Ego E2C if bEgoFol = true && t>PARS.t_StartSimulation;
PARS.b_use_acc = int8(~PARS.bEgoFol);  % use triditional acc if not using MPC (if PARS.bEgoFol = false)
PARS.b_use_acc_hardset = int8(true);  % use triditional acc if not using MPC (if PARS.bEgoFol = false)
PARS.c_acc_hdw = 1.6; % headway for triditional acc
PARS.c_acc_d_hdw = 5; % Set to be in PARS.d_HDW
PARS.b_initialize_distance_t_startsim = 0;   % [0/1]: initialize distance to be E2C_initializeRelDist at t_StartSimulation


PARS.p_lead_ini = double(5);  % Initial lead position with ego at 0. p_lead_ini shoud <= d_HDW(2)
PARS.V_max = double(30);                    % [v_max] in m/s
PARS.V_min = double(0);  
PARS.T_TB_OffSet = 30;
PARS.c_dTB = 3.3; %10; % 
PARS.c2_dTB = 0.001;

% Time constants for low pass filters
PARS.tau_Ne = 0.02;
PARS.tau_pedal_dem = 0.1;
PARS.tau_EngTorque = 0.24;
PARS.d_Ne_max = 600;
PARS.d_Ne_min = -600;

% other parameters not to be changed during test:
PARS.v_ego_ini = VESP_MD;
PARS.T_TB_ego_ini = 200;
PARS.deltaU = 0.1;
PARS.deltaV= 0.1;


% Driver model: from commit 59d14663b7b119b8a1d5fd64e8bda04b6003aa64
PARS.Driver_TuneG1 = 0.007; 
PARS.Driver_TuneG2 = 2.0;  
PARS.Driver_TuneG3 = 0; % DId not help much
PARS.Driver_TuneG_aw = 4;

% Note: CC track v_lead <=> [ACC_TuneG1=0, ACC_TuneG2=1]
PARS.ACC_TuneG1=0.05;  % Par on d-d_rel
PARS.ACC_TuneG2=0.05;   % Par on \dot{d} 

PARS.T_ACC_TuneG1.data = PARS.ACC_TuneG1*[1, 1, 1.2, 1.5, 2];
PARS.T_ACC_TuneG1.breakpoints = [-1, 0.5, 3, 8.1, 50];
PARS.T_ACC_TuneG2.data = PARS.ACC_TuneG2*[6, 3, 2, 1, 1];
PARS.T_ACC_TuneG2.breakpoints = [-1,0.5, 3, 8.1, 50];

% Engine model:
PARS.c_EngFricCoef = 0.0;
c_EngFricCoef = PARS.c_EngFricCoef ;
PARS.c_EngFricCoefd = 0.000;
c_EngFricCoefd = PARS.c_EngFricCoefd;


%% set up speed
E2C_SpeedShape = Simulink.Parameter;                 
E2C_SpeedShape.Value = 3;
E2C_CycleTimespan = Simulink.Parameter;                
E2C_CycleTimespan.Value = 30;
E2C_Trap_CycleAcceStartAlpha = Simulink.Parameter;      
E2C_Trap_CycleAcceStartAlpha.Value = 0.15;
E2C_Trap_CycleAcceEndAlpha = Simulink.Parameter;               
E2C_Trap_CycleAcceEndAlpha.Value = 0.3;
E2C_Trap_CycleDeceStartAlpha = Simulink.Parameter;               
E2C_Trap_CycleDeceStartAlpha.Value = 0.5;
E2C_Trap_CycleDeceEndAlpha = Simulink.Parameter;            
E2C_Trap_CycleDeceEndAlpha.Value = 0.65;
E2C_V_High_kmh = Simulink.Parameter;            
E2C_V_High_kmh.Value = 44;   %kmhr
E2C_V_Low_kmh = Simulink.Parameter;         
E2C_V_Low_kmh.Value = 30;   % kmhr
t_StartSimulation = Simulink.Parameter; 
t_StartSimulation.Value = PARS.t_StartSimulation;


%% Set simulink parameters
b_E2C_inloop = Simulink.Parameter;  
b_E2C_inloop.Value = PARS.b_E2C_inloop;
b_Engine_in_loop = Simulink.Parameter;  
b_Engine_in_loop.Value = PARS.b_Engine_in_loop;
b_Ne_in_loop = Simulink.Parameter;  
b_Ne_in_loop.Value = PARS.b_Ne_in_loop;
b_TTB_in_loop = Simulink.Parameter;  
b_TTB_in_loop.Value = PARS.b_TTB_in_loop;


%% ACC parameters:
ACC_TuneG1 = Simulink.Parameter;                  
ACC_TuneG1.Value = PARS.ACC_TuneG1;                  
ACC_TuneG2 = Simulink.Parameter;                  
ACC_TuneG2.Value = PARS.ACC_TuneG2;                  
T_ACC_TuneG1_data = Simulink.Parameter;        % Datapoints for ACC K_I gain (on d)                         
T_ACC_TuneG1_data.Value = PARS.T_ACC_TuneG1.data;                  
T_ACC_TuneG1_pt = Simulink.Parameter;          % Breakpoints for ACC K_I gain (on d)                
T_ACC_TuneG1_pt.Value = PARS.T_ACC_TuneG1.breakpoints;                  
T_ACC_TuneG2_data = Simulink.Parameter;        % Datapoints for ACC K_P gain (on v)          
T_ACC_TuneG2_data.Value = PARS.T_ACC_TuneG2.data;                  
T_ACC_TuneG2_pt = Simulink.Parameter;          % Breakpoints for ACC K_P gain (on v)                
T_ACC_TuneG2_pt.Value = PARS.T_ACC_TuneG2.breakpoints;                  


%% calibration varaibles

Driver_TuneG1 = PARS.Driver_TuneG1;
Driver_TuneG2 = PARS.Driver_TuneG2;
Driver_TuneG3 = PARS.Driver_TuneG3;
Driver_TuneG_aw = PARS.Driver_TuneG_aw;

tau_Ne = Simulink.Parameter;                  % [s]. Time constant
tau_Ne.Value = PARS.tau_Ne;                  
tau_pedal_dem = Simulink.Parameter;                  % [s]. Time constant
tau_pedal_dem.Value = PARS.tau_pedal_dem; 
tau_EngTorque = Simulink.Parameter;                  % [s]. Time constant
tau_EngTorque.Value = PARS.tau_EngTorque; 
d_Ne_max = Simulink.Parameter;                
d_Ne_max.Value = PARS.d_Ne_max; 
d_Ne_min = Simulink.Parameter;                
d_Ne_min.Value = PARS.d_Ne_min; 

c_acc_hdw = Simulink.Parameter;                  % turn on ACC
c_acc_hdw.Value = PARS.c_acc_hdw;                  
c_acc_d_hdw = Simulink.Parameter;                  % turn on ACC
c_acc_d_hdw.Value = PARS.c_acc_d_hdw;                  
b_use_acc = Simulink.Parameter;                  % boolean. true:turn on MPC
b_use_acc.Value = PARS.b_use_acc;                  
b_use_acc_hardset = Simulink.Parameter;   
b_use_acc_hardset.Value = PARS.b_use_acc_hardset; 
b_initialize_distance_t_startsim = Simulink.Parameter;     % [int, 0/1]
b_initialize_distance_t_startsim.Value = PARS.b_initialize_distance_t_startsim;

T_TB_OffSet = Simulink.Parameter;                 % double, 40 [degC], T_TB offset
T_TB_OffSet.Value = PARS.T_TB_OffSet;                

E2C_V_max = Simulink.Parameter;                    % double. [m/s]. Max Ego speed
E2C_V_max.Value = PARS.V_max;                      
E2C_V_min = Simulink.Parameter;                    % double. [m/s]. Min Ego speed
E2C_V_min.Value = PARS.V_min;                      
t_EndSimulation = Simulink.Parameter;          % total simulation time, ~3000s.
t_EndSimulation.Value = PARS.t_EndSimulation;

E2C_c_dTB = Simulink.Parameter;   
E2C_c_dTB.Value = PARS.c_dTB; 
E2C_c2_dTB = Simulink.Parameter;   
E2C_c2_dTB.Value = PARS.c2_dTB; 

base_dT = Simulink.Parameter;
base_dT.Value = PARS.base_dT; %

E2C_deltaU = Simulink.Parameter;
E2C_deltaU.Value = PARS.deltaU;
E2C_deltaV = Simulink.Parameter;
E2C_deltaV.Value = PARS.deltaV;


%% other constants/maps:

NP_trial = Simulink.Parameter;
NP_trial.Value = PARS.NP;
T_TB_ego_ini = Simulink.Parameter;
T_TB_ego_ini.Value = PARS.T_TB_ego_ini; % 
E2C_initializeRelDist = Simulink.Parameter;        % double, >0. initial distance 
E2C_initializeRelDist.Value = PARS.p_lead_ini;     
Inp_mf_exh_par = Simulink.Parameter;
Inp_mf_exh_par.Value = Inp.mf_exh(1:PARS.deltaU/0.1:end,1:PARS.deltaV/0.1:301); % 
Inp_t_eu_par = Simulink.Parameter;
Inp_t_eu_par.Value = Inp.t_eu(1:PARS.deltaU/0.1:end,1:PARS.deltaV/0.1:301); % 


%% Error sources for simulation tests:
torque_input_trace.time=0;
torque_input_trace.tq=0;


%% Speed sources:
% Ramp 1
% speed_ramp.speed = [0,0,10,10,0,0]';
% speed_ramp.time = [0,10,60,120,170,200]';
% 
% speed_ramp.speed = [0,0,15,15,0,0]';
% speed_ramp.time = [0,10,60,120,170,200]';

% % Ramp 2
% speed_ramp.speed = [0,0,20,20,0,0]';
% speed_ramp.time = [0,10,60,120,170,200]';
% % Ramp 3
% speed_ramp.speed = [0,0,20,20,0,0]';
% speed_ramp.time = [0,10,30,90,140,170]';
% % FTP part 1: the first hump
% speed_ramp.time = [0:136-1]';
% speed_ramp.speed = FTP_speed_1sec(1:136);
% % FTP part 2: the 2nd and 3rd hump
% speed_ramp.time = [0:270-1]';
% speed_ramp.speed = [zeros(10,1);FTP_speed_1sec(146:395);zeros(10,1)];
% 
speed_ramp.time = [0:length(FTP_speed_1sec)-1]';
speed_ramp.speed = FTP_speed_1sec;

PARS.FTP_speed_1sec = FTP_speed_1sec;

keyboard;

%%
if 1
MdlName = 'VehicleModel'
uiopen(MdlName,1)
% load_system(MdlName)

keyboard
sim(MdlName)

if 0
%%
clear MD
MD.speed_ramp=speed_ramp;

MD.time = VESP_MD_mph.time;
MD.Pedal = Pedal_MD.signals.values;
MD.VESP_mph = VESP_MD_mph.signals.values;
MD.GL = GL_MD.signals.values;
MD.Trq = Trq_MD.signals.values;
MD.NE = NE_MD.signals.values;
MD.Ne_demand = Ne_rpm_dem.signals.values;
MD.FuelRate = FuelRate_MD.signals.values;
MD.T_TB_ego = T_TB_ego.signals.values;
MD.T_TB_ego_Sim = T_TB_ego_Sim.signals.values;
MD.p_lead_to_E2C = p_lead_to_E2C.signals.values;
MD.v_lead_to_E2C = v_lead_to_E2C.signals.values;
% MD.v_lead_act = v_lead_act.signals.values;
MD.v_lead_tgt = v_lead_tgt.signals.values;
MD.Sim_d_rel = Sim_d_rel.signals.values;

MD.p_ego_to_E2C = p_ego_to_E2C.signals.values;
MD.Comm_Start_time = Comm_Start_time.signals.values;
MD.v_ego_demand = v_ego_demand.signals.values;
MD.Brake_MD = Brake_MD.signals.values;
MD.b_idle_control_out = b_idle_control_out.signals.values;
MD.GearRatio_MD = GearRatio_MD.signals.values;
MD.EngineTorque = EngineTorque.signals.values;
MD.TorqueConverterOuts = TorqueConverterOuts.signals.values;
MD.PARS = PARS;

MD.d_ACC_rel = d_ACC_rel.signals.values;
MD.b_acc_on = b_acc_on.signals.values;
MD.Des_speed_ACC_mps = Des_speed_ACC_mps.signals.values;
MD.brake_ACC = brake_ACC.signals.values;
MD.brake_CC = brake_CC.signals.values;
MD.alpha_raw_ACC = alpha_raw_ACC.signals.values;
MD.alpha_raw_CC = alpha_raw_CC.signals.values;
MD.alpha_raw = alpha_raw.signals.values;


MD.MdlName = MdlName;
MD.nTest = 15;
ME.PARS.Note = '';
% record parameters in TC:
MD.PARS.time_duration = [0.7,0.7,0.6,0.5,0.5,0.5] +  0.4;

if exist('Tracename')
    MD.Trace = Tracename;
end
clear Tracename

nameFile = sprintf([MdlName,'_%s.mat'],datestr(clock,'yy_mm_dd_HH_MM'));
nameFile
MD.nameFile = nameFile;
MD.changeNote = 'Keep idle threshold to 0.01. Ne_in_loop setted wrongly before. Fixed since this test.';
namePath = fullfile(nameFile(1:end-4), nameFile);

mkdir(nameFile(1:end-4));
save(namePath,'-regexp','Sim_','MD','nameFile')

movefile('logServer.txt',nameFile(1:end-4));
movefile('packetsClient_server.txt',nameFile(1:end-4));
movefile('packetsServer_server.txt',nameFile(1:end-4));
movefile('packetsClient_client.txt',nameFile(1:end-4));
movefile('packetsServer_client.txt',nameFile(1:end-4));
movefile('logClient.txt',nameFile(1:end-4));

%%
% save(namePath,'-regexp','MD','nameFile')
% save(namePath,'MD_withnoise','-append')
end
end


%% Post-process and simulate fuel and TPNOx:
% keyboard;

if 0
computername = 'laptop';
matfile_folder = 'E:\~Umich\aftertreatmentproject\PlatoonModel\HIL_internet\HIL_internet\HIL_internet_test\InternetClient';


if strcmp(computername, 'laptop')
    cd E:\~Umich\aftertreatmentproject\02022017-AFTThermal\Matlabexperiments\06082018
else
    cd \\engin-labs.m.storage.umich.edu\huangchu\windat.v2\Desktop\Newfolder\06082018
end
load('FTP_res.mat')
FTP.time = FTP.PstPrcs.time;

Mph2Mps = 0.44704;
cd E:\~Umich\aftertreatmentproject\02022017-AFTThermal\Matlabfiles
OUTPUT_postprocessed = SimVehOutput(MD.time, MD.VESP_mph*Mph2Mps);

disp(' ') ;
PstPrcs = OUTPUT_postprocessed.PstPrcs;
disp(['***** Processed Gear -- fuel =' num2str(PstPrcs.FuelCnsmpt_bag2_kg*1000) ', FTP fuel = ' num2str(FTP.PstPrcs.FuelCnsmpt_bag2_kg*1000)]) ;
disp(['***** Processed Gear -- Engine NOx ' num2str(PstPrcs.engoutNOx_bag2_g) ', FTP EngNOx = ' num2str(FTP.PstPrcs.engoutNOx_bag2_g)]) ;
disp(['***** Processed Gear -- TP NOx ' num2str(PstPrcs.tailpipeNOx_bag2_g) ', FTP TP NOx = ' num2str(FTP.PstPrcs.tailpipeNOx_bag2_g)]) ;
disp(['***** Simulink -- fuel =', num2str(sum(PARS.base_dT*MD.FuelRate(24901:end)))]);

cd(matfile_folder);
save(nameFile,'OUTPUT_postprocessed','-append')
end
