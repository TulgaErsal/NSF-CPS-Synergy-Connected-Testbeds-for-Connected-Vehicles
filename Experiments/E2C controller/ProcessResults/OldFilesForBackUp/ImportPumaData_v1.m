% close all;
clear all;

%% load BBK data 
BBK_filename = 'HIL_09102020_Test2.mat';
load(BBK_filename);

data_headers = {'Time','engineSpeedActual','engineTorqueActual',...
    'engineSpeedDemand','throttleDemand','engineSpeedSet',...
    'throttleSet','myTime','beginExperiment','engineTDOCINActual'};

Data_BBK = table(data(1,:)',data(2,:)',data(3,:)',data(4,:)',...
    data(5,:)',data(6,:)',data(7,:)',data(8,:)',...
    data(9,:)',data(10,:)',...
    'VariableNames',data_headers);


%% load PUMA data (slow!)

% ************ Specify the file, variable names here ************
Puma_filename = 'Report3.txt'; %'Test_112619.txt';% 'Test_112619.txt'; % 'Report9.txt'; %  'Report8.txt'; %  
opts = detectImportOptions(Puma_filename);
opts.SelectedVariableNames = ...
    {'ALPHA','BMEP','BSFC','CO2_1','ECU_Exh_tOxiCatDs','ECU_Exh_tOxiCatUs',...
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


Data = readtable(Puma_filename,opts);
idx = min(find(isnan(Data.ALPHA)));
if ~ isempty(idx)
Data = Data(1:idx-1,:);
end
Data.Time = [0:0.1:(height(Data)-1)*0.1]';

% Data.Properties.VariableNames
clearvars -except Data Filename
Ts = 0.1;

%% unit change ratios:
kmph2mps = 0.277778;
mg2g = 1e-3;
gps2kgph = 3.6;
m2mile = 0.000621371;
gallon2kg = 3.1492918;                % related to diesel fuel density

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


%%
set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'PlotTest';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(3,1,1);hold on;
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
ylabel('Speed');
ax(2)=subplot(3,1,2);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno']);
ylabel('Alpha');
ax(3)=subplot(3,1,3);
plot(Data.Time,Data.TORQUE,'b-','displayname',...
    ['Dyno'])
ylabel('Torque [Nm]');
linkaxes(ax,'x');xlabel('Time [s]');



%%
set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'PlotTest';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
ylabel('Speed');
ax(2)=subplot(4,1,2);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno']);
ylabel('Alpha');
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.TORQUE,'b-','displayname',...
    ['Dyno'])
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.engoutNOx_g,'b-','displayname',...
    ['Dyno'])
ylabel('EngNOx\_g/s');
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.T_DOC_IN,'b-','displayname','T\_DOC\_IN');
ylabel('Temperature [degC]');ylim([100 350]);
linkaxes(ax,'x');xlabel('Time [s]');

%%
set(0, 'DefaultLineLineWidth', 1);
figurename = 'PlotTest'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
ylabel('Speed');
ax(2)=subplot(4,1,2);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno'])
ylabel('Alpha');
ax(3)=subplot(4,1,3);hold on;
% plot(Data.Time,Data.engoutNOx_g,'b-','displayname',['Dyno'])
% plot(Data.Time,Data.tailpipeNOx_g,'r-','displayname',['Dyno'])
% plot(Data.Time,Data.tailpipeNOx_g_bench,'m-','displayname',['Dyno'])
namels={'ECU_urd_nox_pre_scr'
'ECU_urd_nox_post_scr';'ECU_urd_qty_mgsec'
'NOX_1'
'NH3_1'};
for  i = 1:5
plot(Data.Time,Data.(namels{i}),'-','displayname',[strrep(namels{i},'_','\_')]);
end
% ylim([0 200]);
legend('show')
ylabel('NOx\_ppm');
ax(4)=subplot(4,1,4);hold on;
namels={'T_TB_O','T_DOC_IN','ECU_Exh_tOxiCatUs','ECU_Exh_tOxiCatDs',...
    'T_SCRMIXER_IN','T_SCRMIXER_OUT','TESCR_FrontCtr','T_SCR_OUT','ECU_Exh_tPFltUs'...
    };
for i = 1:length(namels)
plot(Data.Time,Data.(namels{i}),'-','displayname',[strrep(namels{i},'_','\_')]);
end
legend('show')
ylabel('Temperature [degC]');
% ylim([100 350]);
linkaxes(ax,'x');xlabel('Time [s]');



%% load FTP data
load('PlatoonModel_Chunan_2016b_112119T1155_19_11_26_00_09','MD');
idx_start = 1;

load('PlatoonModel_Chunan_2016b_112119T1155_19_11_21_13_40','MD');
idx_start = 13919;

cd E:\~Umich\aftertreatmentproject\PlatoonModelSimu\PlatoonModel_Chunan_2016b_120519T1123
load('PlatoonModel_Chunan_2016b_120519T1123_19_12_05_14_17','MD');
idx_start = 13919+4;

cd E:\~Umich\aftertreatmentproject\02022017-AFTThermal\02022017-02082017_model-DOC_reference\Data\FTP75data_from_Michiel
load('w863_hc_sns_pre_post_doc_verl1_ftp75_bag_1_2_11aug16_1.UofM2.mat');
Ford_Fuel_kg_hr = (InjCtl_qSetUnBal)*8./(60./Epm_nEng*2)*mg2g*gps2kgph;
Ford_Bag2_Fuel = sum((Epm_nEng_time(4981:end)-Epm_nEng_time(4980:end-1)).*Ford_Fuel_kg_hr(4981:end)/gps2kgph);

%% Load demand and match time
load('VehicleModel_20_09_10_12_24_Test2.mat')

idx_start = 6.4650e+03; % 1070;
idx_start = 12721;

idx_end = length(MD.time) + idx_start - 1;
idx_end = min(height(Data), idx_end);
Data = Data(idx_start:idx_end,:);
Data.Time = Data.Time-Data.Time(1);
Range.tspan = [0, (idx_end-idx_start+100)*Ts];
Range.Temperature = [150, 320];

%%


set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'Dyn'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
hold on;plot(MD.time, MD.NE,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
ylabel('Ne [rpm]')
ylim([500 3000])
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno'])
hold on;plot(MD.time, MD.Pedal*100,'r--','displayname',...
    ['Simulink']);
legend('show','Orientation','Horizontal');
ylabel('Pedal [%]');
ylim([0 100]);
ax(4)=subplot(4,1,4);
plot(Data.Time,Data.TORQUE,'b-','displayname',...
    ['Dyno'])
hold on;plot(MD.time, MD.Trq,'r--','displayname',...
    ['Simulink']);
ylim([-400,1000])
ylabel('Torque [Nm]');
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim(Range.tspan);
% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')



set(0, 'DefaultLineLineWidth', 1);
figurename = 'Fuel'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
hold on;plot(MD.time, MD.NE,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
ylabel('Ne [rpm]')
ylim([500 3000])
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.Fuel_kg_hr,'b-','displayname',...
    ['Dyno, ',num2str(sum(Data.Fuel_kg_hr(4981:end)/gps2kgph*Ts),'%.2f'),'[g]'])
hold on;plot(MD.time, MD.FuelRate*gps2kgph,'r--','displayname',...
    ['Simulink, ',num2str(sum(MD.FuelRate(4981:end)*Ts),'%.2f'),'[g]']);
legend('show','Orientation','Horizontal');
ylabel('FuelRate [kg/hr]');
ylim([0 30]);
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.T_DOC_IN,'b-','displayname','T\_DOC\_IN');
hold on;
plot(Data.Time, Data.T_TB_O,'c-','displayname','T\_TB\_O')
plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
grid on;
ylabel('Temperature [degC]');ylim(Range.Temperature);
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim(Range.tspan);
% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')


set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'NOx'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.T_DOC_IN,'b-','displayname','T\_DOC\_IN');
hold on;
plot(Data.Time, Data.T_TB_O,'c-','displayname','T\_TB\_O')
plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
ylabel('T\_TB [degC]');ylim(Range.Temperature);
grid on;
ax(3)=subplot(4,1,3);
plot(Data.Time, Data.T_SCRMIXER_IN,'b-','displayname','T\_SCRMIXER\_IN');
hold on;
plot(Data.Time, Data.T_SCRMIXER_OUT,'c-','displayname','T\_SCRMIXER\_OUT')
plot(Data.Time, Data.T_SCR_OUT,'g-','displayname','T\_SCR\_OUT')
plot(Data.Time, Data.ECU_Exh_tPFltUs,'-','color',[0.47,0.67,0.19],...
    'displayname','ECU\_Exh\_tPFltUs')
legend('show','Orientation','Horizontal');
ylabel('T\_AFT [degC]');ylim(Range.Temperature);
legend('show','Orientation','Horizontal');
grid on;
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.engoutNOx_g,'b-','displayname',...
    ['Dyno bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
hold on;  
plot(Data.Time, Data.tailpipeNOx_g,'c-','displayname',...
    ['Dyno bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
%plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
ylabel('NOx [g/s]');ylim([0 0.1]);
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim(Range.tspan);

% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')

%
set(0, 'DefaultLineLineWidth', 0.5);
figurename = 'Urea-NOx'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.T_SCRMIXER_IN,'b-','displayname','T\_SCRMIXER\_IN');
hold on;
plot(Data.Time, Data.T_SCRMIXER_OUT,'c-','displayname','T\_SCRMIXER\_OUT')
plot(Data.Time, Data.T_SCR_OUT,'g-','displayname','T\_SCR\_OUT')
plot(Data.Time, Data.ECU_Exh_tPFltUs,'-','color',[0.47,0.67,0.19],...
    'displayname','ECU\_Exh\_tPFltUs')
legend('show','Orientation','Horizontal');
ylabel('T\_AFT [degC]');ylim(Range.Temperature);
legend('show','Orientation','Horizontal');
grid on;
ax(3)=subplot(4,1,3);
plot(Data.Time, Data.ECU_urd_qty_mgsec,'b-','displayname',...
    'Dyno urea\_inj');
hold on;
plot(Data.Time, Data.NH3_g_bench*1e3,'g-','displayname',...
    'Dyno NH3\_EBH');
legend('show','Orientation','Horizontal');
ylabel('Urea [mg/s]');ylim([0 100])
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.engoutNOx_g*1e3,'b-','displayname',...
    ['Dyno bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
hold on;  
plot(Data.Time, Data.tailpipeNOx_g*1e3,'c-','displayname',...
    ['Dyno bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
plot(Data.Time, Data.tailpipeNOx_g_bench*1e3,'g-','displayname',...
    ['Dyno bg2 EBH TPNOx, ',num2str(sum(Data.tailpipeNOx_g_bench(4981:end)*Ts),'%.2f'),'[g]']);
legend('show','Orientation','Horizontal');
ylabel('NOx [mg/s]');ylim([0 100]);
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim(Range.tspan);
% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')


%% For comparison: compare two Dynos (Dyno and Dyno_2)

set(0, 'DefaultLineLineWidth', 1);
figurename = 'Dyn'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
hold on;plot(MD.time, MD.NE,'r--','displayname','Simulink');
plot(Data_2.Time, Data_2.SPEED,'c-','displayname','Dyno\_2');
legend('show','Orientation','Horizontal');
ylabel('Ne [rpm]')
ylim([500 3000])
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.ALPHA,'b-','displayname',...
    ['Dyno'])
hold on;plot(MD.time, MD.Pedal*100,'r--','displayname',...
    ['Simulink']);
plot(Data_2.Time,Data_2.ALPHA,'c-','displayname',...
    ['Dyno\_2'])
legend('show','Orientation','Horizontal');
ylabel('Pedal [%]');
ylim([0 100]);
ax(4)=subplot(4,1,4);
plot(Data.Time,Data.TORQUE,'b-','displayname',...
    ['Dyno'])
hold on;plot(MD.time, MD.Trq,'r--','displayname',...
    ['Simulink']);
plot(Data_2.Time,Data_2.TORQUE,'c-','displayname',...
    ['Dyno\_2'])
ylim([-400,1000])
ylabel('Torque [Nm]');
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim([0 1400]);


%

set(0, 'DefaultLineLineWidth', 1);
figurename = 'Fuel'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.SPEED,'b-','displayname','Dyno');
hold on;
%plot(MD.time, MD.NE,'r--','displayname','Simulink');
plot(Data_2.Time, Data_2.SPEED,'c-','displayname','Dyno\_2');
legend('show','Orientation','Horizontal');
ylabel('Ne [rpm]')
ylim([500 3000])
ax(3)=subplot(4,1,3);
plot(Data.Time,Data.Fuel_kg_hr,'b-','displayname',...
    ['Dyno, ',num2str(sum(Data.Fuel_kg_hr(4981:end)/gps2kgph*Ts),'%.2f'),'[g]'])
hold on;
% plot(MD.time, MD.FuelRate*gps2kgph,'r--','displayname',...
%    ['Simulink, ',num2str(sum(MD.FuelRate(4981:end)*Ts),'%.2f'),'[g]']);
plot(Data_2.Time,Data_2.Fuel_kg_hr,'c-','displayname',...
    ['Dyno\_2, ',num2str(sum(Data_2.Fuel_kg_hr(4981:end)/gps2kgph*Ts),'%.2f'),'[g]'])
legend('show','Orientation','Horizontal');
ylabel('FuelRate [kg/hr]');
ylim([0 30]);
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.T_DOC_IN,'b-','displayname','T\_DOC\_IN, Dyno');
hold on;
plot(Data_2.Time, Data_2.T_DOC_IN,'c-','displayname','T\_DOC\_IN, Dyno\_2')
%plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
grid on;
ylabel('Temperature [degC]');ylim(Range.Temperature);
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',10);
xlim([0 1400]);


%
set(0, 'DefaultLineLineWidth', 1);
figurename = 'NOx'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(4,1,2);
plot(Data.Time, Data.T_DOC_IN,'b-','displayname','T\_DOC\_IN, Dyno');
hold on;
plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
plot(Data_2.Time, Data_2.T_DOC_IN,'c-','displayname','T\_DOC\_IN, Dyno\_2')
legend('show','Orientation','Horizontal');
ylabel('T\_TB [degC]');ylim(Range.Temperature);
grid on;
ax(3)=subplot(4,1,3);
plot(Data.Time, Data.T_SCRMIXER_IN,'b-','displayname','T\_SCRMIXER\_IN, Dyno');
hold on;
plot(Data.Time, Data.T_SCRMIXER_OUT,'c-','displayname','T\_SCRMIXER\_OUT, Dyno')
plot(Data.Time, Data.ECU_Exh_tPFltUs,'-','color',[0.47,0.67,0.19],...
    'displayname','ECU\_Exh\_tPFltUs, Dyno')
plot(Data_2.Time, Data_2.T_SCRMIXER_IN,'r-','displayname','T\_SCRMIXER\_IN, Dyno\_2');
hold on;
plot(Data_2.Time, Data_2.T_SCRMIXER_OUT,'m-','displayname','T\_SCRMIXER\_OUT, Dyno\_2')
plot(Data_2.Time, Data_2.ECU_Exh_tPFltUs,'-','color',[0.93,0.69,0.13],...
    'displayname','ECU\_Exh\_tPFltUs, Dyno\_2')
legend('show','Orientation','Horizontal');
ylabel('T\_AFT [degC]');ylim(Range.Temperature);
legend('show','Orientation','Horizontal');
grid on;
ax(4)=subplot(4,1,4);
plot(Data.Time, Data.engoutNOx_g,'b-','displayname',...
    ['Dyno bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
hold on;  
plot(Data.Time, Data.tailpipeNOx_g,'c-','displayname',...
    ['Dyno bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
plot(Data_2.Time, Data_2.engoutNOx_g,'r-','displayname',...
    ['Dyno\_2 bg2 EngNOx, ',num2str(sum(Data_2.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
plot(Data_2.Time, Data_2.tailpipeNOx_g,'m-','displayname',...
    ['Dyno\_2 bg2 TPNOx, ',num2str(sum(Data_2.tailpipeNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
%plot(MD.time, MD.T_TB_ego,'r--','displayname','Simulink');
legend('show','Orientation','Horizontal');
ylabel('NOx [g/s]');ylim([0 0.01]);
linkaxes(ax,'x');xlabel('Time [s]');
set(findall(gcf,'-property','FontSize'),'FontSize',8);
xlim([0 1400]);

% 
set(0, 'DefaultLineLineWidth', 1);

plotlist = {'ECU_InjCrv_phiMI1Des',...
    'ECU_InjCrv_phiPiI1Des','ECU_InjCrv_phiPiI2Des',...
    'ECU_InjCrv_phiPoI1Des','ECU_InjCrv_phiPoI2Des',...
    'ECU_InjCrv_qM1Des','ECU_InjCrv_qPil1Des_mp',...
    'ECU_InjCrv_qPil2Des_mp','ECU_InjCrv_qPoI1Des_mp',...
    'ECU_InjCrv_qPoI2Des_mp'};
figurename = 'misl'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(7,2,1);hold on;
plot(MD.time, MD.VESP_mph/2.236,'r--')
ylabel('VSpeed [m/s]');ylim([0 30]);
title({strrep(MD.nameFile,'_','\_')})
ax(2)=subplot(7,2,2);
plot(Data.Time, Data.engoutNOx_g,'b-','displayname',...
    ['Dyno bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
hold on;  
plot(Data_2.Time, Data_2.engoutNOx_g,'r--','displayname',...
    ['Dyno\_2 bg2 EngNOx, ',num2str(sum(Data_2.engoutNOx_g(4981:end)*Ts),'%.2f'),'[g]']);
ylim([0 0.01]);legend('show');
ax(3)=subplot(7,2,3);
plot(Data.Time, Data.T_CEO,'b-','displayname',...
    'Dyno bg2 T\_CEO');
hold on;  
plot(Data_2.Time, Data_2.T_CEO,'r--','displayname',...
    'Dyno\_2 bg2 T\_CEO');
legend('show');
ylim([Range.Temperature])
ax(4)=subplot(7,2,4);
% plot(Data.Time, Data.EGR_Rate_i60,'b-','displayname',...
%     'Dyno EGR\_Rate\_i60');
hold on;  
plot(Data_2.Time, Data_2.EGR_Rate_i60,'r--','displayname',...
    'Dyno\_2 EGR\_Rate\_i60');
legend('show');
for i = 1:5
    ax(4+2*i)=subplot(7,2,4+2*i);
    hold on;
    plot(Data.Time, Data.(plotlist{i}),'b-','displayname',...
    ['Dyno', strrep(plotlist{i},'_','\_')]);
    plot(Data.Time, Data_2.(plotlist{i}),'r--','displayname',...
    ['Dyno\_2', strrep(plotlist{i},'_','\_')]);
    legend('show');
    if i == 1
        ylim([ -25 25]);
    else
        ylim([ -45 45]);
    end
end

for i = 6:10
    ax(3+2*(i-5))=subplot(7,2,3+2*(i-5));
    hold on;
    plot(Data.Time, Data.(plotlist{i}),'b-','displayname',...
    ['Dyno', strrep(plotlist{i},'_','\_')]);
    plot(Data.Time, Data_2.(plotlist{i}),'r--','displayname',...
    ['Dyno\_2', strrep(plotlist{i},'_','\_')]);
    legend('show')
    if i == 6
        ylim([0 100])
    else
        ylim([0 20])
    end
end



%% Repeatability test:
colormap = [0.2 0.1 0.5
    0.1 0.5 0.8
    0.2 0.7 0.6
    0.8 0.7 0.3
    0.9 1 0];
colormaps = interp1([1:5],colormap,[1:0.5:5]);


idx_start_ic = 526; % 771;
cycle_length = 13713; % 13712;
idx_start_ic_BBK = min(find(diff(Data_BBK.myTime)>0)); % 771;
cycle_length_BBK = 342806; % 13712;
num_cycles = 2;


%% BBK, PUMA and MD comparison, done
for  i = 1
    
    figurename = ['Plot_BBK_PUMA',num2str(i)];
    f = figure('name',figurename);
    f.Position = [1,30,1200,570];

    idx_start_BBK = idx_start_ic_BBK + cycle_length_BBK * (i-1);
    idx_end_BBK = idx_start_BBK + cycle_length_BBK;
    idx_start = idx_start_ic + cycle_length * (i-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(3,1,1);hold on;
    namels={'engineSpeedActual','engineSpeedDemand'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK),...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), Data.SPEED(idx_start:idx_end),'-','displayname','Dyno SPEED');
    plot(MD.time, MD.NE, '.','displayname', 'Simulink SPEED')
    legend('show');ylabel('Speed');
    title(['Dyno BBK and PUMA test ',num2str(i)])
    
    ax(2)=subplot(3,1,2);hold on;
    namels={'throttleDemand'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK),...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),Data.ALPHA(idx_start:idx_end),'-','displayname',...
        ['Dyno ALPHA']);
    plot(MD.time, MD.Pedal*100,'.','displayname','Simulink Pedal')
    legend('show');
    ylabel('Alpha');
    
    
    ax(3)=subplot(3,1,3);hold on;
    namels={'engineTorqueActual'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK),...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),Data.TORQUE(idx_start:idx_end),'-','displayname',...
        ['Dyno TORQUE'])
    plot(MD.time, MD.Trq,'.','displayname','Simulink Trq')
    ylabel('Torque [Nm]');
    legend('show');
    linkaxes(ax,'x');
    
end


%% repeatability tests:
figurename = 'PlotTest';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
for i = 2:num_cycles
    idx_start = idx_start_ic + cycle_length * (i-1);
    idx_end = idx_start + cycle_length;
    
    
    ax(1)=subplot(3,1,1);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), Data.SPEED(idx_start:idx_end),'-','displayname','Dyno');
    ylabel('Speed');
    ax(2)=subplot(3,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),Data.ALPHA(idx_start:idx_end),'-','displayname',...
        ['Dyno\_',num2str(i)]);
    ylabel('Alpha');
    ax(3)=subplot(3,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),Data.TORQUE(idx_start:idx_end),'-','displayname',...
        ['Dyno\_',num2str(i)])
    ylabel('Torque [Nm]');
    legend('show');
    linkaxes(ax,'x');xlabel('Time [s]');
end


%
figurename = 'PlotTest'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
for ii = 2:num_cycles
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    ax(1)=subplot(4,1,1);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.SPEED(idx_start:idx_end),'b-','displayname','Dyno');
    ylabel('Speed');
    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.ALPHA(idx_start:idx_end),'b-','displayname',...
        ['Dyno\_',num2str(i)])
    ylabel('Alpha');
    ax(3)=subplot(4,1,3);hold on;
    
    namels={'ECU_urd_nox_pre_scr'
    'ECU_urd_nox_post_scr';'ECU_urd_qty_mgsec'
    'NOX_1'
    'NH3_1'};
    for  i = 1:5
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.(namels{i})(idx_start:idx_end),'-','displayname',[strrep(namels{i},'_','\_')],'color',colormaps(i,:));
    end
    % ylim([0 200]);
    legend('show')
    ylabel('NOx\_ppm');
    ax(4)=subplot(4,1,4);hold on;
    namels={'T_TB_O','T_DOC_IN','ECU_Exh_tOxiCatUs','ECU_Exh_tOxiCatDs',...
        'T_SCRMIXER_IN','T_SCRMIXER_OUT','TESCR_FrontCtr','T_SCR_OUT','ECU_Exh_tPFltUs'...
        };
    for i = 1:length(namels)
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.(namels{i})(idx_start:idx_end),'-','displayname',[strrep(namels{i},'_','\_')],'color',colormaps(i,:));
    end
    legend('show')
    ylabel('Temperature [degC]');
    % ylim([100 350]);
    linkaxes(ax,'x');xlabel('Time [s]');
end


%
figurename = 'Fuel'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = 2:num_cycles
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(4,1,1);hold on;
    
    ylabel('VSpeed [m/s]');ylim([0 30]);
    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), Data.SPEED(idx_start:idx_end),'b-','displayname','Dyno');
    legend('show','Orientation','Horizontal');
    ylabel('Ne [rpm]')
    ylim([500 3000])
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.Fuel_kg_hr(idx_start:idx_end),'b-','displayname',...
        ['Dyno\_',num2str(ii),' , ',num2str(sum(Data.Fuel_kg_hr(idx_start+4981:idx_end)/gps2kgph*Ts),'%.2f'),'[g]'])
    legend('show','Orientation','Horizontal');
    ylabel('FuelRate [kg/hr]');
    ylim([0 30]);
    ax(4)=subplot(4,1,4);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_DOC_IN(idx_start:idx_end),'b-','displayname','T\_DOC\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.T_TB_O(idx_start:idx_end),'c-','displayname','T\_TB\_O')
    legend('show','Orientation','Horizontal');
    grid on;
    ylabel('Temperature [degC]');ylim(Range.Temperature);
    linkaxes(ax,'x');xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    xlim(Range.tspan);
    % saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
    % saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')
end


%
figurename = 'AFT'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = 2:num_cycles
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(4,1,1);hold on;
    ylabel('VSpeed [m/s]');ylim([0 30]);
    ax(2)=subplot(4,1,2);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.T_DOC_IN(idx_start:idx_end),'b-','displayname','T\_DOC\_IN');
    hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.T_TB_O(idx_start:idx_end),'c-','displayname','T\_TB\_O')
    legend('show','Orientation','Horizontal');
    ylabel('T\_TB [degC]');ylim(Range.Temperature);
    grid on;
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCRMIXER_IN(idx_start:idx_end),'b-','displayname','T\_SCRMIXER\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCRMIXER_OUT(idx_start:idx_end),'c-','displayname','T\_SCRMIXER\_OUT')
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCR_OUT(idx_start:idx_end),'g-','displayname','T\_SCR\_OUT')
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.ECU_Exh_tPFltUs(idx_start:idx_end),'-','color',[0.47,0.67,0.19],...
        'displayname','ECU\_Exh\_tPFltUs')
    legend('show','Orientation','Horizontal');
    ylabel('T\_AFT [degC]');ylim(Range.Temperature);
    legend('show','Orientation','Horizontal');
    grid on;
    ax(4)=subplot(4,1,4);hold on;  
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.engoutNOx_g(idx_start:idx_end),'b-','displayname',...
        ['Dyno\_',num2str(ii),' bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981+idx_start:idx_end)*Ts),'%.2f'),'[g]']);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.tailpipeNOx_g(idx_start:idx_end),'c-','displayname',...
        ['Dyno\_',num2str(ii),' bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(4981+idx_start:idx_end)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g(4981+idx_start:idx_end)*Ts)/sum(Data.engoutNOx_g(4981+idx_start:idx_end)*Ts),'%.2f')]);
    legend('show','Orientation','Horizontal');
    ylabel('NOx [g/s]');ylim([0 0.1]);
    linkaxes(ax,'x');xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    xlim(Range.tspan);

% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')
end

%
figurename = 'NOx'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = 2:num_cycles
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(4,1,1);hold on;
    ylabel('VSpeed [m/s]');ylim([0 30]);

    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCRMIXER_IN(idx_start:idx_end),'b-','displayname','T\_SCRMIXER\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCRMIXER_OUT(idx_start:idx_end),'c-','displayname','T\_SCRMIXER\_OUT')
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.T_SCR_OUT(idx_start:idx_end),'g-','displayname','T\_SCR\_OUT')
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.ECU_Exh_tPFltUs(idx_start:idx_end),'-','color',[0.47,0.67,0.19],...
        'displayname','ECU\_Exh\_tPFltUs')
    legend('show','Orientation','Horizontal');
    ylabel('T\_AFT [degC]');ylim(Range.Temperature);
    legend('show','Orientation','Horizontal');
    grid on;
    
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.ECU_urd_qty_mgsec(idx_start:idx_end),'b-','displayname',...
        ['Dyno\_',num2str(ii),' urea\_inj']);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.NH3_g_bench(idx_start:idx_end)*1e3,'g-','displayname',...
        ['Dyno\_',num2str(ii),' NH3\_EBH']);
    legend('show','Orientation','Horizontal');
    ylabel('Urea [mg/s]');ylim([0 100])

    ax(4)=subplot(4,1,4);hold on;  
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start),...
        Data.engoutNOx_g(idx_start:idx_end),'b-','displayname',...
        ['Dyno\_',num2str(ii),' bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(4981+idx_start:idx_end)*Ts),'%.2f'),'[g]']);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.tailpipeNOx_g(idx_start:idx_end),'c-','displayname',...
        ['Dyno\_',num2str(ii),' bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(4981+idx_start:idx_end)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g(4981+idx_start:idx_end)*Ts)/sum(Data.engoutNOx_g(4981+idx_start:idx_end)*Ts),'%.2f')]);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
        Data.tailpipeNOx_g_bench(idx_start:idx_end),'g-','displayname',...
        ['Dyno\_',num2str(ii),' bg2 TPNOx EBH, ',num2str(sum(Data.tailpipeNOx_g_bench(4981+idx_start:idx_end)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g_bench(4981+idx_start:idx_end)*Ts)/sum(Data.engoutNOx_g(4981+idx_start:idx_end)*Ts),'%.2f')]);
    legend('show','Orientation','Horizontal');
    ylabel('NOx [g/s]');ylim([0 0.1]);
    linkaxes(ax,'x');xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    xlim(Range.tspan);

% saveas(gcf,[Filename(1:end-4),'_',figurename],'fig')
% saveas(gcf,[Filename(1:end-4),'_',figurename],'jpg')
end

