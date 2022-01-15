%% Plot close loop test

figurename = ['PlotTest_',num2str(Test_i)];
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(4,1,1);hold on;
if MD.PARS.b_E2C_inloop
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
if isfield(MD.PARS,'c_acc_hdw')
    TITLE = [strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_'),', Drive mdl:', ...
        num2str(MD.PARS.Driver_TuneG1),' ',...
        num2str(MD.PARS.Driver_TuneG2),' ',...
        num2str(MD.PARS.Driver_TuneG3),'. ',...
        'ACC:', num2str(MD.PARS.c_acc_hdw),'s, ',num2str(MD.PARS.c_acc_d_hdw),'m'];
else
    TITLE = [strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_'),', Drive mdl:', ...
        num2str(MD.PARS.Driver_TuneG1),' ',...
        num2str(MD.PARS.Driver_TuneG2),' ',...
        num2str(MD.PARS.Driver_TuneG3)];
end
title(TITLE);
    
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
ylim([-0.3 1.3])
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
ylim([-200 800])
linkaxes(ax,'x');xlabel('Time [s]');
xlim([0, min(min(MD.time(end), Data.Time(end)),Data_BBK.Time(end))]);

if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '.fig']));
end


%% Plot distance 

figurename = ['PlotDistance_',num2str(Test_i)];
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(3,1,1);hold on;
if MD.PARS.b_E2C_inloop
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
if isfield(MD.PARS,'c_acc_hdw')
    TITLE = [strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_'),', Drive mdl:', ...
        num2str(MD.PARS.Driver_TuneG1),' ',...
        num2str(MD.PARS.Driver_TuneG2),' ',...
        num2str(MD.PARS.Driver_TuneG3),'. ',...
        'ACC:', num2str(MD.PARS.c_acc_hdw),'s, ',num2str(MD.PARS.c_acc_d_hdw),'m'];
else
    TITLE = [strrep(BBK_filename,'_','\_'),',  ',...
        strrep(Data.x_iDescription{1},'_','\_'),', Drive mdl:', ...
        num2str(MD.PARS.Driver_TuneG1),' ',...
        num2str(MD.PARS.Driver_TuneG2),' ',...
        num2str(MD.PARS.Driver_TuneG3)];
end
title(TITLE);

ax(2)=subplot(3,1,2);hold on;
plot(MD.time, MD.Sim_d_rel,'displayname','distance');
plot(MD.time, [solver_PARS.t_HDW(1)*MD.VESP_mph*0.44704 + solver_PARS.d_HDW(1),...
    solver_PARS.t_HDW(2)*MD.VESP_mph*0.44704 + solver_PARS.d_HDW(2)],'k--',...
    'displayname','d constraints');
if isfield(MD.PARS,'c_acc_hdw')
    
    plot(MD.time, MD.PARS.c_acc_d_hdw+MD.PARS.c_acc_hdw*MD.VESP_mph*0.44704,...
        '--','color',0.5*[1,1,1],'displayname','target ACC headway');
    
end
ylabel('[m]');grid on;legend('show')

ax(3)=subplot(3,1,3);hold on
plot(MD.time, MD.Pedal,'m','displayname','Pedal');
ylabel('Alpha');grid on;
legend('show')

linkaxes(ax,'x');
xlim([0, min(min(MD.time(end), Data.Time(end)),Data_BBK.Time(end))]);
xlabel('Time [s]')

if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figurename, '.fig']));
end

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

if 0
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_TqDiff.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_TqDiff.fig']));
end

