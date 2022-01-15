%% load BBK data 
fstruct = dir([test_folder,'\BBK_data\',BBK_filename_part]);
assert(1==length(fstruct),'--------- BBK file not unique! ---------')
BBK_filename = [myInclusiveExtractBefore(BBK_filename_part,'\'),fstruct.name(1:end-4)];
load([test_folder,'\BBK_data\',BBK_filename]);
if contains(BBK_filename, 'Tulga')
    data_headers = {'Time','engineTorqueActual','engineSpeedDemand',...
        'throttleDemand','fuelrate_gps','GL_MD','egoSpeed_mph','egoSpeed_tgt_mph',...
        'dynoSpeed','engineSpeedSet','throttleSet','egoSpeedErr','myTime'};
    Data_BBK = array2table(data','VariableNames',data_headers);
else
    data_headers = {'Time','engineSpeedActual','engineTorqueActual',...
        'engineSpeedDemand','throttleDemand','engineSpeedSet',...
        'throttleSet','myTime','beginExperiment','engineTDOCINActual'};
    Data_BBK = table(data(1,:)',data(2,:)',data(3,:)',data(4,:)',...
        data(5,:)',data(6,:)',data(7,:)',data(8,:)',...
        data(9,:)',data(10,:)',...
        'VariableNames',data_headers);
end
disp('--------- BBK file loaded! ---------')


%% load Dell data:
fstruct = dir([test_folder,'\VehMdl_data\',Dell_filename_part]);
% fstruct = dir([test_folder,'\Dell_data\',Dell_filename_part]);
assert(1==length(fstruct),'--------- VehMdl file not unique! ---------')
Dell_filename = [myInclusiveExtractBefore(Dell_filename_part,'\'),fstruct.name];
load([test_folder,'\VehMdl_data\',Dell_filename]);
disp('--------- VehMdl file loaded! ---------')


%% load PUMA data (slow!)
fstruct = dir([test_folder,'\Puma_data\',Puma_filename_part]);
assert(1==length(fstruct),'--------- Puma file not unique! ---------')
Puma_filename = fstruct.name;

% ************ Specify the file, variable names here ************
opts = detectImportOptions([test_folder,'\Puma_data\',Puma_filename]);
opts.SelectedVariableNames = {...
    'x_iStartTime','x_iCompleteTime','x_iDescription','x_iName',...
    'ALPHA','BMEP','BSFC','CO2_1','ECU_Exh_tOxiCatDs','ECU_Exh_tOxiCatUs',...
    'ECU_Exh_tPFltUs','ECU_Exh_tPFltDs','ECU_InjCrv_phiMI1Des',...
    'ECU_InjCrv_phiPiI1Des','ECU_InjCrv_phiPiI2Des',...
    'ECU_InjCrv_phiPoI1Des','ECU_InjCrv_phiPoI2Des',...
    'ECU_InjCrv_qM1Des','ECU_InjCrv_qPil1Des_mp',...
    'ECU_InjCrv_qPil2Des_mp','ECU_InjCrv_qPoI1Des_mp',...
    'ECU_InjCrv_qPoI2Des_mp','ECU_N','ECU_PthSet_trqInrSet',...
    'ECU_urd_nox_post_scr','ECU_urd_nox_pre_scr','ECU_urd_qty_mgsec',...
    'MF_AIR','MF_FUEL','NH3_1','NO2_1','NO_1','NOX_1','T_AIR',...
    'T_DOC_IN','T_SCR_OUT','T_SCRMIXER_IN','T_SCRMIXER_OUT',...
    'T_TB_IL','T_TB_IR','T_TB_O','T_CEO','SPEED','TORQUE',...
    'EGR_Rate_i60','EGR_Rate_wet_i60','ECU_EGRVlv_rAct','EGRP',...
    'C2H2_1','C2H4_1','C2H6_1','C3H6_1','C3H8_1','C4H6_1','CH4_1',...
    'P_IM','P_IM_L','P_IM_R','EGR_Rate_i60',...
    'T_IM_AVG','T_IM_IN','T_IM_L','T_IM_R',...
    'TEDOC_BackCtr','TEDOC_BackEdge','TEDOC_Front','TESCR_BackCtr','TESCR_FrontCtr','TESCR_FrontEdge'};
% **************************'************************************
% Here is a list of all variables:
% {'Time','iCompleteFlag','iCompleteTime','Id','iDeleteBeforeArchivingFlag',
% 'iDescription','iDontReplicateFlag','$iInvalidFlag','$iName','$iReleased',
% '$iReleaseTime','$iRemindData','$iRetentionTime','$iStartCondition',
% '$iStartConditionTime','iStartTime','iStopCondition','iStopConditionTime',
% 'iTimeBase','iType','iVersion','rTest',
% 'AF_LFE','AHC_1','ALPHA','BMEP','BP_V_FB','BSFC',
% 'C2H2_1','C2H4_1','C2H6_1','C3H6_1','C3H8_1','C4H6_1','CH4_1','CO2_1','CO2_1_dry',
% 'CO2EGR_F','CO_1','ECU_Air_tAFS','ECU_ALPHA','ECU_EGRVlv_rAct',
% 'ECU_Exh_tOxiCatDs','ECU_Exh_tOxiCatUs','ECU_Exh_tPFltDs','ECU_Exh_tPFltUs',
% 'ECU_InjCrv_phiMI1Des','ECU_InjCrv_phiPiI1Des','ECU_InjCrv_phiPiI2Des',
% 'ECU_InjCrv_phiPoI1Des','ECU_InjCrv_phiPoI2Des','ECU_InjCrv_qM1Des',
% 'ECU_InjCrv_qPil1Des_mp','ECU_InjCrv_qPil2Des_mp','ECU_InjCrv_qPoI1Des_mp',
% 'ECU_InjCrv_qPoI2Des_mp','ECU_N','ECU_PthSet_trqInrSet','ECU_urd_nox_post_scr',
% 'ECU_urd_nox_pre_scr','ECU_urd_qty_mgsec','EGR_Rate_i60','EGR_Rate_wet_i60',
% 'EGRP','EXH_LAMBDA','H2O_1','HCHO_1','HCN_1','HCOOH_1','HFR500_CHANNEL1_AVG',
% 'HFR500_CHANNEL2_AVG','HNCO_1','IMEP1','IMEP2','IMEP3','IMEP4','IMEP5',
% 'IMEP6','IMEP7','IMEP8','LFE_DP_V','MECHO_1','MF_AIR','MF_COOL','MF_F_STK',
% 'MF_FUEL','MF_FUEL_CORR','MF_FUEL_mA','MFB10_1','MFB10_2','MFB10_3',
% 'MFB10_4','MFB10_5','MFB10_6','MFB10_7','MFB10_8','MFB50_1','MFB50_2',
% 'MFB50_3','MFB50_4','MFB50_5','MFB50_6','MFB50_7','MFB50_8','MFB5_1',
% 'MFB5_2','MFB5_3','MFB5_4','MFB5_5','MFB5_6','MFB5_7','MFB5_8','MFB90_1',
% 'MFB90_2','MFB90_3','MFB90_4','MFB90_5','MFB90_6','MFB90_7','MFB90_8',
% 'N2O_1','N_dem_D','N_dem_E','NC8_1','NH3_1','NO2_1','NO_1','NOX_1','O2_1',
% 'P','P_AIR','P_CP_I','P_CP_O','P_DPF_O','P_DPLFE','P_EGR_MC','P_EGR_PC',
% 'P_FUEL_I','P_FUEL_R','P_IC_O','P_IM','P_IM_L','P_IM_R','P_OILGAL','P_OILSMP',
% 'P_TB_IL','P_TB_IR','P_TB_O','PHI','PMAX1','PMAX2','PMAX3','PMAX4','PMAX5',
% 'PMAX6','PMAX7','PMAX8','RAW_RH','RAW_TAIR','SO2_1','SPEED','T_AIR',
% 'T_AIR_IN','T_CEGRHI','T_CEGRHO','T_CEGRLO','T_CEI','T_CEO','T_CIC_I',
% 'T_CP_I','T_CP_O','T_dem_D','T_dem_E','T_DOC_IN','T_EGR_I','T_EGR_MC',
% 'T_EGR_PC','T_EX_CY1','T_EX_CY2','T_EX_CY3','T_EX_CY4','T_EX_CY5','T_EX_CY6','T_EX_CY7','T_EX_CY8',
% 'T_EXH','T_FUEL_I','T_FUEL_R','T_IC_O','T_IM_AVG','T_IM_IN','T_IM_L','T_IM_R',
% 'T_OILGAL','T_OILSMP','T_SCR_OUT','T_SCRMIXER_IN','T_SCRMIXER_OUT','T_set_D',
% 'T_TB_IL','T_TB_IR','T_TB_O','TC_SPEED','TEDOC_BackCtr','TEDOC_BackEdge',
% 'TEDOC_Front','TESCR_BackCtr','TESCR_FrontCtr','TESCR_FrontEdge','THC_1',
% 'TORQUE','V1_FB','V2_FB','V3_FB','VGT_DTY'}


%%
Data = readtable([test_folder,'\Puma_data\',Puma_filename],opts);
idx = min(find(isnan(Data.ALPHA)));
if ~ isempty(idx)
Data = Data(1:idx-1,:);
end
Data.Time = [0:0.1:(height(Data)-1)*0.1]';

% Data.Properties.VariableNames
Ts = 0.1;

% Additional calculated variables:
Data.Fuel_kg_hr = (Data.ECU_InjCrv_qM1Des + Data.ECU_InjCrv_qPil1Des_mp +...
    Data.ECU_InjCrv_qPil2Des_mp + Data.ECU_InjCrv_qPoI1Des_mp + Data.ECU_InjCrv_qPoI2Des_mp)...
    *8./(60./Data.SPEED*2)*mg2g*gps2kgph;
Data.MF_EXH = Data.MF_AIR*gps2kgph + Data.Fuel_kg_hr; % exhaust flow rate [kg/hr]

Data.engoutNOx_g = max(0,(Data.ECU_urd_nox_pre_scr.*(Data.MF_EXH/gps2kgph*1e-3)...
    * 1e-3)*31.6/29); % remove Ts * in the equation!
Data.tailpipeNOx_g = max(0,(Data.ECU_urd_nox_post_scr.*(Data.MF_EXH/gps2kgph*1e-3)...
    *1e-3)*31.6/29);

EBH_measured = false;
EBH_list = {'NH3_1','NO2_1','NO_1','NOX_1','C2H2_1','C2H4_1','C2H6_1','C3H6_1','C3H8_1','C4H6_1','CH4_1'};
EBH_delay = 3.6;

if ~iscell(Data.NOX_1) % ~strcmp(Data.NOX_1{1},'**')
    % [TODO]: need to interpolate ebh measurements to match time!!!!
    EBH_measured = true;
    for iname = 1:numel(EBH_list)
        fname = EBH_list{iname};
        l1 = floor(length(Data.Time)/2);
        Data.(fname) = interp1(Data.Time(1:2:2*l1-1), max(0, Data.(fname)(1:l1)), Data.Time);
        Data.(fname) = interp1(Data.Time-EBH_delay, Data.(fname), Data.Time);
    end
    Data.tailpipeNOx_g_bench = max(0,(Data.NOX_1.*(Data.MF_EXH/gps2kgph*1e-3)...
         *1e-3)*31.6/29);
    Data.NH3_g_bench = max(0,(Data.NH3_1.*(Data.MF_EXH/gps2kgph*1e-3)...
         *1e-3)*31.6/29);
    Data.CHs = max(0,Data.C2H2_1)+max(0,Data.C2H4_1)+max(0,Data.C2H6_1)+...
        max(0,Data.C3H6_1)+max(0,Data.C3H8_1)+max(0,Data.C4H6_1)+max(0,Data.CH4_1);
end
disp('--------- Puma file loaded! ---------')


%% load Thinkpad data:
fstruct = dir([test_folder,'\Solver_data\',Thinkpad_filename_part]);
if isempty(fstruct)
    disp('--------- Solver file not exist! ---------')
elseif length(fstruct)>1
    disp('--------- Solver file not unique! ---------')
else
    Thinkpad_filename = [myInclusiveExtractBefore(Thinkpad_filename_part,'\'),fstruct.name];
    
    
    load([test_folder,'\Solver_data\',Thinkpad_filename]);
    disp('--------- Solver file loaded! ---------')
end


%% load INCA data:
filename_INCA = fullfile(test_folder,'INCA_data',INCA_filename_part);

if exist(filename_INCA, 'file') == 2
    INCA_exists = true;
    dtmin = Ts;
    Import_INCA_dat_files   % gives: INCA_data
    clearvars filename_INCA dtmin
    disp('--------- INCA file loaded! ---------')
    
    [~,~,T_FaultCodes]=xlsread('DFDM4_NSF_INCA_Faultcodes.xls');
    disp('--------- INCA fault code table loaded! ---------')

else
    clearvars filename_INCA
    disp('--------- INCA file does not exist! ---------')

end


%% Auto-alignment

dt_BBK2MD = Sim_BBKPair_server_receive.signals.values(1,5);
[~, idx_BBK2MD] = min(abs(Data_BBK.Time - dt_BBK2MD));


idx_Puma2BBK_end = length(Data.Time);
[b,a] = butter(2,0.1);
BBK_filtered = filtfilt(b,a,interp1(Data_BBK.Time,Data_BBK.engineSpeedActual,Data.Time(1:idx_Puma2BBK_end),'linear','extrap'));
correlation = xcorr([diff(BBK_filtered);0], [diff(Data.SPEED(1:idx_Puma2BBK_end));0]);
% correlation = xcorr( [(BBK_filtered);0], [(Data.SPEED(1:idx_Puma2BBK_end));0]);

[~,idx_Puma2BBK_start]= max(correlation(1:idx_Puma2BBK_end));
idx_Puma2BBK = abs(idx_Puma2BBK_end - idx_Puma2BBK_start);

[~, idx_Puma2MD1] = min(abs(Data.Time - dt_BBK2MD));
idx_Puma2MD = idx_Puma2BBK + idx_Puma2MD1;

% [TODO] manual fix!!! Not sure why the code above does not work well in
% the following cases.
if contains(test_folder,'10302020')
    if strcmp(Puma_filename,'Report1.txt')
        idx_Puma2MD = 192;
    elseif strcmp(Puma_filename,'Report3.txt')
        idx_Puma2MD =1431;
    elseif strcmp(Puma_filename,'Report4.txt')
        idx_Puma2MD = 431;
    elseif strcmp(Puma_filename,'Report8.txt')
        idx_Puma2MD = 447;
    end
end

if INCA_exists
    % use INCA_data.n and MD.NE to match
    MD_filtered = filtfilt(b,a,interp1(MD.time, MD.NE, ...
        INCA_data.Time,'linear','extrap'));
    correlation = xcorr([diff(MD_filtered);0], [diff(INCA_data.n);0]);
    idx_INCA2MD_end = length(INCA_data.Time);

    [~,idx_INCA2MD_start]= max(correlation(1:idx_INCA2MD_end));
    idx_INCA2MD = (idx_INCA2MD_end - idx_INCA2MD_start);
    % delete INCA data before MD starts. Then INCA and MD are aligned. 
    fnames = fieldnames(INCA_data);
    for i = 1:numel(fnames)
        INCA_data.(fnames{i})(1:idx_INCA2MD) = [];
    end
    INCA_data.Time = INCA_data.Time - INCA_data.Time(1);
end

