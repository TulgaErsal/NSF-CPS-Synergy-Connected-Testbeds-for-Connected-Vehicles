%% set datafile filenames
clear all

i = 1; % [46,52,57,58]

Dell_filename_part = ['*Test',num2str(i),'.mat'];
    
BBK_filename_part = ['HIL_*Test',num2str(i),'_10202020.mat'];
Puma_filename_part = ['*Report',num2str(i),'.txt']; 
% test_folder = 'E:\~Umich\aftertreatmentproject\02022017-AFTThermal\2019DynoTest\09102020HILTest\Test2';


%% unit change ratios:
kmph2mps = 0.277778;
mg2g = 1e-3;
gps2kgph = 3.6;
m2mile = 0.000621371;
gallon2kg = 3.1492918;                % related to diesel fuel density


%% load BBK data 
fstruct = dir(['.\BBK_data\',BBK_filename_part]);
assert(1==length(fstruct),'--------- BBK file not unique! ---------')
BBK_filename = fstruct.name(1:end-4);
load(['.\BBK_data\',BBK_filename]);
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

%% load Dell data:
fstruct = dir(['.\Dell_data\',Dell_filename_part]);
assert(1==length(fstruct),'--------- Dell file not unique! ---------')
Dell_filename = fstruct.name;
load(['.\Dell_data\',Dell_filename]);


%% load PUMA data (slow!)
fstruct = dir(['.\Puma_data\',Puma_filename_part]);
assert(1==length(fstruct),'--------- Puma file not unique! ---------')
Puma_filename = fstruct.name;

% ************ Specify the file, variable names here ************
opts = detectImportOptions(['.\Puma_data\',Puma_filename]);
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
    'EGR_Rate_i60','EGR_Rate_wet_i60','ECU_EGRVlv_rAct',...
    'C2H2_1','C2H4_1','C2H6_1','C3H6_1','C3H8_1','C4H6_1','CH4_1',...
    'P_IM','P_IM_L','P_IM_R','EGR_Rate_i60',...
    'T_IM_AVG','T_IM_IN','T_IM_L','T_IM_R',...
    'TEDOC_BackCtr','TEDOC_BackEdge','TEDOC_Front','TESCR_BackCtr','TESCR_FrontCtr','TESCR_FrontEdge'};
% **************************'************************************


Data = readtable(['.\Puma_data\',Puma_filename],opts);
idx = min(find(isnan(Data.ALPHA)));
if ~ isempty(idx)
Data = Data(1:idx-1,:);
end
Data.Time = [0:0.1:(height(Data)-1)*0.1]';

% Data.Properties.VariableNames
Ts = 0.1;


%% Additional calculated variables:
Data.Fuel_kg_hr = (Data.ECU_InjCrv_qM1Des + Data.ECU_InjCrv_qPil1Des_mp +...
    Data.ECU_InjCrv_qPil2Des_mp + Data.ECU_InjCrv_qPoI1Des_mp + Data.ECU_InjCrv_qPoI2Des_mp)...
    *8./(60./Data.SPEED*2)*mg2g*gps2kgph;
Data.MF_EXH = Data.MF_AIR*gps2kgph + Data.Fuel_kg_hr; % exhaust flow rate [kg/hr]

Data.engoutNOx_g = max(0,(Data.ECU_urd_nox_pre_scr.*(Data.MF_EXH/gps2kgph*1e-3)...
    * 1e-3)*31.6/29); % remove Ts * in the equation!
Data.tailpipeNOx_g = max(0,(Data.ECU_urd_nox_post_scr.*(Data.MF_EXH/gps2kgph*1e-3)...
    *1e-3)*31.6/29);

Data.tailpipeNOx_g_bench = max(0,(Data.NOX_1.*(Data.MF_EXH/gps2kgph*1e-3)...
     *1e-3)*31.6/29);
Data.NH3_g_bench = max(0,(Data.NH3_1.*(Data.MF_EXH/gps2kgph*1e-3)...
     *1e-3)*31.6/29);
Data.CHs = max(0,Data.C2H2_1)+max(0,Data.C2H4_1)+max(0,Data.C2H6_1)+...
    max(0,Data.C3H6_1)+max(0,Data.C3H8_1)+max(0,Data.C4H6_1)+max(0,Data.CH4_1);


%% Auto-alignment

dt_BBK2MD = Sim_BBKPair_server_receive.signals.values(1,5);
[~, idx_BBK2MD] = min(abs(Data_BBK.Time - dt_BBK2MD));


idx_Puma2BBK_end = length(Data.Time);
[b,a] = butter(2,0.1);
BBK_filtered = filtfilt(b,a,interp1(Data_BBK.Time,Data_BBK.engineSpeedActual,Data.Time(1:idx_Puma2BBK_end),'linear','extrap'));
correlation = xcorr([diff(BBK_filtered);0], [diff(Data.SPEED(1:idx_Puma2BBK_end));0]);

[~,idx_Puma2BBK_start]= max(correlation(1:idx_Puma2BBK_end));
idx_Puma2BBK = idx_Puma2BBK_end - idx_Puma2BBK_start;

[~, idx_Puma2MD1] = min(abs(Data.Time - dt_BBK2MD));
idx_Puma2MD = idx_Puma2BBK + idx_Puma2MD1;


%% Close loop:
figurename = ['PlotTest_',num2str(i)];
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
if MD.PARS.bEgoFol
    plot(MD.time, MD.v_lead_tgt,'b-','displayname','v\_lead\_tgt');
    plot(MD.time, MD.v_ego_demand,'g-','displayname','v\_ego\_demand');
    plot(MD.time, MD.VESP_mph*0.44704,'r-','displayname','actual');
else
    plot(MD.speed_ramp.time, MD.speed_ramp.speed,'b-','displayname','target');
    plot(MD.time, MD.VESP_mph*0.44704,'r-','displayname','actual');
end
plot(MD.time, MD.GL,'c--','displayname','GL');
grid on;ylabel('VSpeed [m/s]');
legend('show','Orientation','Horizontal','Location','Best');
title([strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_'),', Drive mdl:', ...
        num2str(MD.PARS.Driver_TuneG1),' ',...
        num2str(MD.PARS.Driver_TuneG2),' ',...
        num2str(MD.PARS.Driver_TuneG3)]);
    
ax(2)=subplot(4,1,2);hold on;
plot(MD.time, MD.NE,'b-','displayname','Ne VehMdl demand');
plot(Data_BBK.Time - Data_BBK.Time(idx_BBK2MD), Data_BBK.engineSpeedDemand,'g','displayname','Ne BBK demand');
plot(Data_BBK.Time - Data_BBK.Time(idx_BBK2MD), Data_BBK.engineSpeedActual,'r','displayname','Ne BBK actual');
plot(Data.Time-Data.Time(idx_Puma2MD), Data.SPEED,'m','displayname','Ne Puma');
ylabel('Ne [rpm]');ylim([550,2000]);grid on;
legend('show','Orientation','Horizontal','Location','Best');

ax(3)=subplot(4,1,3);hold on;
plot(MD.time, MD.Pedal,'b-','displayname',...
    ['Pedal VehMdl demand']);
plot(Data_BBK.Time - Data_BBK.Time(idx_BBK2MD), Data_BBK.throttleDemand/100,'g','displayname','Pedal BBK demand');
plot(Data.Time-Data.Time(idx_Puma2MD), Data.ALPHA/100,'m','displayname','Ne Puma');
ylabel('Alpha');grid on;
legend('show','Orientation','Horizontal','Location','Best');

ax(4)=subplot(4,1,4);hold on;
plot(Data_BBK.Time - Data_BBK.Time(idx_BBK2MD), Data_BBK.engineTorqueActual,...
    'r-','displayname',...
    ['Trq BBK actual'])
plot(Data.Time-Data.Time(idx_Puma2MD), Data.TORQUE,...
    'm','displayname','Trq Puma');
plot(Sim_BBKPair_server_receive.time,Sim_BBKPair_server_receive.signals.values(:,7),...
    'c-','displayname',...
    ['Trq VehMdl meas (before filter)'])
plot(MD.time, MD.EngineTorque,'color',[0.49,0.18,0.56],...
    'displayname',['Trq VehMdl meas (after filter)'])
plot(MD.time, MD.Trq,'color','b','displayname',...
    ['Sim Trq from engine map'])
ylabel('Torque [Nm]');ylim([-300 1200]);grid on;
legend('show','Orientation','Horizontal','Location','Best');

linkaxes(ax,'x');xlabel('Time [s]');
xlim([0, min(min(MD.time(end), Data.Time(end)),Data_BBK.Time(end))]);

% print(f,'-dpng','-r400',fullfile('PlotFigures',[BBK_filename, '.png']))
% savefig(f, fullfile('PlotFigures',[BBK_filename, '.fig']));


%% Compare sim torque and measure torque:

J_Eng = 1.53;
Ne_act = Sim_BBKPair_server_receive.signals.values(:,3);
[b,a] = butter(2,0.1);
Ne_act_filter = filtfilt(b,a,Ne_act);


figurename = ['Plot_torque_difference'];
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(2,1,1);hold on
plot(MD.time, MD.EngineTorque,'color',[0.49,0.18,0.56],...
    'displayname',['Trq VehMdl meas (after filter)'])
plot(MD.time, MD.Trq,'color','b','displayname',...
    ['Sim Trq from engine map'])
% plot(Data.Time-Data.Time(idx_Puma2MD), ...
%     interp2(Inp.FordData.spd, Inp.FordData.tq, Inp.FordData.Torque, ...
%     Data.SPEED, Data.ECU_PthSet_trqInrSet));
grid on;legend('show','Orientation','Horizontal','Location','Best');
title([strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_')]);

ax(2)=subplot(2,1,2);hold on
plot(MD.time, MD.Trq - MD.EngineTorque,'displayname',...
    ['Sim Trq - filter meas torque'])
plot(MD.time, [diff(Ne_act_filter);0]/MD.time(2)*J_Eng,'displayname',...
    ['J\_Eng * d(Ne\_meas)']);
grid on;legend('show','Orientation','Horizontal','Location','Best');
linkaxes(ax,'x');xlabel('Time [s]');
xlim([0, min(min(MD.time(end), Data.Time(end)),Data_BBK.Time(end))]);

% print(f,'-dpng','-r400',fullfile('PlotFigures',[BBK_filename, '_TqDiff.png']))
% savefig(f, fullfile('PlotFigures',[BBK_filename, '_TqDiff.fig']));


%% Find start index for puma

set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'PlotTest';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(3,1,1);hold on;
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
ylabel('Speed');
TITLE = [BBK_filename, '. ', Data.x_iDescription{1}];
title(strrep(TITLE,'_','\_'))
ax(2)=subplot(3,1,2);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno']);
ylabel('Alpha');
ax(3)=subplot(3,1,3);
plot(Data.Time,Data.TORQUE,'b-','displayname',...
    ['Dyno'])
ylabel('Torque [Nm]');
linkaxes(ax,'x');xlabel('Time [s]');



%% repeatability tests:
Plot_Repeatability_Test


