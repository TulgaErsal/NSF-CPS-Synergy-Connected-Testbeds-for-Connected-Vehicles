restoredefaultpath

clear all
close all
addpath('Solverpair_Server_package');
addpath('RealtimeBlocks');


%% initialize for follower model
W = 0.0
load('Data/SpeedAcceMap8.mat')

%% PARS: SolverInit and VehicleModelInit should agree
% --------------------- Store in PARS: Do not change these below!!!!!!!!-----------------
% should not change these!!!!!, they are used as constants already:
PARS.base_dT = 0.020;
PARS.NP = 40;                       % prediction horizon in s
PARS.bUseCollo = false;   % removed collocation method and only use non-collocation method. 

PARS.t_StartSimulation = 0; % 74; % 506+60+1377; %  This number comes from VehMdlInit.m. length(Idle_speed_once) + length(FTP_speed_once);
PARS.t_EndSimulation = 2814; % 2814; % double(length(FTP_speed_1sec));        % 3000: total simulation time [s]
PARS.b_E2C_inloop = 1;     % Set to 1!!! 0 for debug.
PARS.bEgoFol = true;                        % do Ego E2C if bEgoFol = true && t>PARS.t_StartSimulation;

% ---------------- Inputs: From workspace ------------------------------
% parameters will be changed during tests:
PARS.weight_TTB = W;               % set weight on NOx
PARS.E2C_tiSolverPeriod_C = single(1);
PARS.E2C_DeltaT = single(0.3);
PARS.w_epsilon_lin = 0.1*double(PARS.NP);       % linear cost on slack variable for constraint violation
PARS.T_TB_thr = double(260);
PARS.V_max = double(30);                    % [v_max] in m/s
PARS.V_min = double(0);  
PARS.d_HDW = double([-0 5]);
PARS.t_HDW = double([1 1]);
PARS.dz_term = double(1e-3);
PARS.df_term = double(1e-5);
PARS.Max_iter = int8(50);

PARS.w_delta_u = 0.1;
PARS.c_dTB = 3.3; %10; % 
PARS.c2_dTB = 0.001;

% other parameters not to be changed during test:
PARS.U_lim = [-5.99 5.99];
PARS.deltaU = 0.1;
PARS.deltaV= 0.1;


%%
E2C_DeltaT = Simulink.Parameter;  
E2C_DeltaT.Value = PARS.E2C_DeltaT;
E2C_tiSolverPeriod_C = Simulink.Parameter;  
E2C_tiSolverPeriod_C.Value = PARS.E2C_tiSolverPeriod_C;
t_StartSimulation = Simulink.Parameter; 
t_StartSimulation.Value = PARS.t_StartSimulation;


%% calibration varaibles

E2C_bEgoFol = Simulink.Parameter;                  % boolean. true:turn on MPC
E2C_bEgoFol.Value = PARS.bEgoFol;                  
E2C_weight_TTB = Simulink.Parameter;               % double. 0~6
E2C_weight_TTB.Value = PARS.weight_TTB*10;            % small -> fuel efficient.Large -> NOx efficient
E2C_w_epsilon_lin = Simulink.Parameter;            % double. weight on slack var
E2C_w_epsilon_lin.Value = PARS.w_epsilon_lin ;     
E2C_T_TB_thr = Simulink.Parameter;                 % double, 240 [degC], T_TB threshold
E2C_T_TB_thr.Value = PARS.T_TB_thr;                
E2C_V_max = Simulink.Parameter;                    % double. [m/s]. Max Ego speed
E2C_V_max.Value = PARS.V_max;                      
E2C_V_min = Simulink.Parameter;                    % double. [m/s]. Min Ego speed
E2C_V_min.Value = PARS.V_min;                      
E2C_U_max = Simulink.Parameter;
E2C_U_max.Value = PARS.U_lim(2); % 
E2C_U_min = Simulink.Parameter;
E2C_U_min.Value = PARS.U_lim(1); % 

E2C_d_HDW1 = Simulink.Parameter;                   % double [m],headway
E2C_d_HDW1.Value = PARS.d_HDW(1);                  % d_HDW1+t_HDW1*v_ego<=d<=d_HDW2+t_HDW2*v_ego
E2C_d_HDW2 = Simulink.Parameter;    
E2C_d_HDW2.Value = PARS.d_HDW(2);  
E2C_t_HDW1 = Simulink.Parameter;                   % double, [s], time headway
E2C_t_HDW1.Value = PARS.t_HDW(1);  
E2C_t_HDW2 = Simulink.Parameter;
E2C_t_HDW2.Value = PARS.t_HDW(2);  
E2C_df_term = Simulink.Parameter;                  % SQP termination criterion 
E2C_df_term.Value = PARS.df_term;                  % stop SQP if d(cost)<=df_term && ||d(z)||_{inf}<=dz_term 
E2C_dz_term = Simulink.Parameter;
E2C_dz_term.Value = PARS.dz_term;  
E2C_Max_iter = Simulink.Parameter;                 % SQP max iteration
E2C_Max_iter.Value = PARS.Max_iter;  
t_EndSimulation = Simulink.Parameter;          % total simulation time, ~3000s.
t_EndSimulation.Value = PARS.t_EndSimulation;
E2C_bUseCollo = Simulink.Parameter;     
E2C_bUseCollo.Value = PARS.bUseCollo;

E2C_c_dTB = Simulink.Parameter;   
E2C_c_dTB.Value = PARS.c_dTB; 
E2C_c2_dTB = Simulink.Parameter;   
E2C_c2_dTB.Value = PARS.c2_dTB; 


E2C_w_delta_u = Simulink.Parameter;   
E2C_w_delta_u.Value = PARS.w_delta_u; 

base_dT = Simulink.Parameter;
base_dT.Value = PARS.base_dT; %

E2C_deltaU = Simulink.Parameter;
E2C_deltaU.Value = PARS.deltaU;
E2C_deltaV = Simulink.Parameter;
E2C_deltaV.Value = PARS.deltaV;


%% other constants/maps:
NP_trial = Simulink.Parameter;
NP_trial.Value = PARS.NP;

Inp_mf_exh_par = Simulink.Parameter;
Inp_mf_exh_par.Value = Inp.mf_exh(1:PARS.deltaU/0.1:end,1:PARS.deltaV/0.1:301); % 
Inp_t_eu_par = Simulink.Parameter;
Inp_t_eu_par.Value = Inp.t_eu(1:PARS.deltaU/0.1:end,1:PARS.deltaV/0.1:301); % 

keyboard;

%%
if 1

MdlName = 'Solver'
uiopen(MdlName,1);
% load_system(MdlName)

keyboard
sim(MdlName)

if 0
    %%
solver_n_Test = 10; % Record test number
solver_stateflow_note='Do 1 dosolver in 1 base_dT'
    
nameFile = sprintf([MdlName,'_%s.mat'],datestr(clock,'yy_mm_dd_HH_MM'));
solver_PARS = PARS;
% save(namePath,'solver_stSolve','solver_stGrad','solver_start_time','solver_end_time','solver_sendSimTime','solver_stateflow_note','nameFile','solver_ctr','solver_V_Opt_Array','solver_ReadClient_vpre','Solver_f_nonl_new')
mkdir(nameFile(1:end-4))
namePath = fullfile(nameFile(1:end-4), nameFile)
save(namePath,'-regexp', 'solver_.*', 'Solver_.*', 'nameFile')
movefile('packetsServer_Solver.txt',nameFile(1:end-4))
movefile('packetsClient_Solver.txt',nameFile(1:end-4))
movefile('logSolver.txt',nameFile(1:end-4))

%%
end
end