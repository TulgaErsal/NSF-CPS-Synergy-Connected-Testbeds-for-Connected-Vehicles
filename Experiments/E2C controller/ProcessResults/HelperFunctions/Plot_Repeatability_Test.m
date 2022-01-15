%% Set up indices:
colormap = [0.2 0.1 0.5
    0.1 0.5 0.8
    0.2 0.7 0.6
    0.8 0.7 0.3
    0.9 1 0];
colormaps = interp1([1:5],colormap,[1:0.5:5]);

idx_post_NOx_exceed = find(Data.ECU_urd_nox_post_scr>448);

if MD.PARS.bEgoFol  % MPC case
    if idx_start_e2c >= MD.PARS.t_StartSimulation
        legend_note = sprintf('w=%0.1f',MD.PARS.weight_TTB);
    else
        legend_note = 'ACC FTP';
    end
else
    legend_note = 'ACC FTP';
end


%% BBK, PUMA and MD comparison 
set(0, 'DefaultLineLineWidth', 1);
t_shift = 0.12;

for i = num_cycles_list
    figurename = ['Plot_BBK_PUMA_Dell',num2str(i)];
    f = figure('name',figurename);
    f.Position = [1,30,1200,570];

    idx_start_BBK = idx_start_ic_BBK + cycle_length_BBK * (i-1);
    idx_end_BBK = idx_start_BBK + cycle_length_BBK;
    idx_start = idx_start_ic + cycle_length * (i-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(3,1,1);hold on;
    namels={'engineSpeedActual','engineSpeedDemand'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK)-Data_BBK.myTime(idx_start_BBK) - pre_ftp_dtime,...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start)+t_shift - pre_ftp_dtime, Data.SPEED(idx_start:idx_end),'-','displayname',[legend_note,' SPEED']);
    plot(MD.time - pre_ftp_dtime, MD.NE, '-.','displayname', 'Simulink SPEED');
    plot(Data.Time(idx_start_e2c)*[1,1] - pre_ftp_dtime, [0,3000],'k--')
    plot(Data.Time(idx_start_e2c+idx_e2c_length)*[1,1] - pre_ftp_dtime, [0,3000],'k--')
    legend('show');ylabel('Speed');
    title([legend_note,' BBK and PUMA test ',num2str(i)]);
    
    ax(2)=subplot(3,1,2);hold on;
    namels={'throttleDemand'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK) - Data_BBK.myTime(idx_start_BBK) - pre_ftp_dtime,...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start)+t_shift - pre_ftp_dtime,...
        Data.ALPHA(idx_start:idx_end),'-','displayname',...
        [legend_note,' ALPHA']);
    plot(MD.time - pre_ftp_dtime, MD.Pedal*100,'-.','displayname','Simulink Pedal')
    legend('show');
    ylabel('Alpha');
        
    ax(3)=subplot(3,1,3);hold on;
    namels={'engineTorqueActual'};
    for  j = 1:length(namels)
        plot(Data_BBK.myTime(idx_start_BBK:idx_end_BBK)-Data_BBK.myTime(idx_start_BBK) - pre_ftp_dtime,...
            Data_BBK.(namels{j})(idx_start_BBK:idx_end_BBK),'-','color',colormaps(j,:),...
            'displayname',['BBK ',strrep(namels{j},'_','\_')]);
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start)+t_shift - pre_ftp_dtime,...
        Data.TORQUE(idx_start:idx_end),'-','displayname',...
        [legend_note,' TORQUE'])
    plot(MD.time - pre_ftp_dtime, MD.Trq,'-.','displayname','Simulink Trq')
    ylabel('Torque [Nm]');
    legend('show');
    linkaxes(ax,'x');xlim(Range.tspan);xlim(Range.tspan);
    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end


%% repeatability tests:

figurename = 'PlotTest';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
for i = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (i-1);
    idx_end = idx_start + cycle_length;
    
    
    ax(1)=subplot(3,1,1);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, Data.SPEED(idx_start:idx_end),'-','displayname',legend_note);
    ylabel('Speed [rpm]');
    ax(2)=subplot(3,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,Data.ALPHA(idx_start:idx_end),'-','displayname',...
        [legend_note,'\_',num2str(i)]);
    ylabel('Alpha');
    ax(3)=subplot(3,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,Data.TORQUE(idx_start:idx_end),'-','displayname',...
        [legend_note,'\_',num2str(i)])
    ylabel('Torque [Nm]');
    legend('show');
    linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end

if EBH_measured
    namels={'ECU_urd_nox_pre_scr'
        'ECU_urd_nox_post_scr'
        'NOX_1'};
    figure;hold on
    for  i = 1:length(namels)
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.(namels{i})(idx_start:idx_end),'-',...
        'displayname',[strrep(namels{i},'_','\_')]);
    end
    legend('show')
end
 
    
%
figurename = 'PlotTest2'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
for ii = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    ax(1)=subplot(4,1,1);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.SPEED(idx_start:idx_end),'b-','displayname',legend_note);
    ylabel('Speed [rpm]');
    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.ALPHA(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(i)])
    ylabel('Alpha');
    ax(3)=subplot(4,1,3);hold on;
    
    
    if EBH_measured
        namels={'ECU_urd_nox_pre_scr'
            'ECU_urd_nox_post_scr';'ECU_urd_qty_mgsec'
            'NOX_1'
            'NH3_1'};
    else
        namels={'ECU_urd_nox_pre_scr'
            'ECU_urd_nox_post_scr';'ECU_urd_qty_mgsec'};
    end
    for  i = 1:length(namels)
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.(namels{i})(idx_start:idx_end),'-','displayname',[strrep(namels{i},'_','\_')],'color',colormaps(i,:));
    end
    if ~isempty(idx_post_NOx_exceed)
        plot(Data.Time(intersect([idx_start:idx_end],idx_post_NOx_exceed)) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.ECU_urd_nox_post_scr(intersect([idx_start:idx_end],idx_post_NOx_exceed)),'r*',...
            'displayname','Exceed TPNOx','color',colormaps(i,:));
    end
    % ylim([0 200]);
    legend('show')
    ylabel('NOx\_ppm');
    ax(4)=subplot(4,1,4);hold on;
    namels={'T_TB_O','T_DOC_IN','ECU_Exh_tOxiCatUs','ECU_Exh_tOxiCatDs',...
        'T_SCRMIXER_IN','T_SCRMIXER_OUT','TESCR_FrontCtr','T_SCR_OUT','ECU_Exh_tPFltUs'...
        };
    for i = 1:length(namels)
        if ~strcmp(Data.(namels{i})(1),'**')
            plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
                Data.(namels{i})(idx_start:idx_end),'-','displayname',[strrep(namels{i},'_','\_')],'color',colormaps(i,:));
        end
    end
    legend('show');grid on
    ylabel('Temperature [degC]');
    % ylim([100 350]);
    linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end


%
figurename = 'Fuel'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    
    idx_bag2 = idx_start+idx_start_e2c:idx_start+idx_start_e2c+idx_e2c_length;

    ax(1)=subplot(4,1,1);hold on;
    plot(MD.time - pre_ftp_dtime, MD.v_lead_to_E2C,'m-','displayname','v\_lead\_to\_E2C');
    plot(MD.time - pre_ftp_dtime, MD.v_ego_demand,'r-','displayname','v\_ego\_demand');
    plot(MD.time - pre_ftp_dtime, MD.VESP_mph*0.44704,'b-','displayname','v\_ego\_actual');
    ylabel('VSpeed [m/s]');ylim([0 30]);
    legend('show','Orientation','Horizontal');
    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, Data.SPEED(idx_start:idx_end),'b-','displayname',legend_note);
    legend('show','Orientation','Horizontal');
    ylabel('Ne [rpm]')
    ylim([500 3000])
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.Fuel_kg_hr(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' , ',num2str(sum(Data.Fuel_kg_hr(idx_bag2)/gps2kgph*Ts),'%.2f'),'[g]'])
    legend('show','Orientation','Horizontal');
    ylabel('FuelRate [kg/hr]');
    ylim([0 30]);
    ax(4)=subplot(4,1,4);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_DOC_IN(idx_start:idx_end),'b-','displayname','T\_DOC\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.T_TB_O(idx_start:idx_end),'c-','displayname','T\_TB\_O')
    legend('show','Orientation','Horizontal');
    grid on;
    ylabel('Temperature [degC]');ylim(Range.Temperature);
    linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    
    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end


%
figurename = 'AFT'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    idx_bag2 = idx_start+idx_start_e2c:idx_start+idx_start_e2c+idx_e2c_length;

    ax(1)=subplot(4,1,1);hold on;
    plot(MD.time - pre_ftp_dtime, MD.v_ego_demand,'r-','displayname','v\_ego\_demand');
    plot(MD.time - pre_ftp_dtime, MD.VESP_mph*0.44704,'b-','displayname','v\_ego\_actual');
    ylabel('VSpeed [m/s]');ylim([0 30]);
    legend('show','Orientation','Horizontal');
    ax(2)=subplot(4,1,2);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.T_DOC_IN(idx_start:idx_end),'b-','displayname','T\_DOC\_IN');
    hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.T_TB_O(idx_start:idx_end),'c-','displayname','T\_TB\_O')
    legend('show','Orientation','Horizontal');
    ylabel('T\_TB [degC]');ylim(Range.Temperature);
    grid on;
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_SCRMIXER_IN(idx_start:idx_end),'b-','displayname','T\_SCRMIXER\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_SCRMIXER_OUT(idx_start:idx_end),'c-','displayname','T\_SCRMIXER\_OUT')
    if ~strcmp(Data.T_SCR_OUT(1),'**')
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.T_SCR_OUT(idx_start:idx_end),'g-','displayname','T\_SCR\_OUT')
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.ECU_Exh_tPFltUs(idx_start:idx_end),'-','color',[0.47,0.67,0.19],...
        'displayname','ECU\_Exh\_tPFltUs')
    legend('show','Orientation','Horizontal');
    ylabel('T\_AFT [degC]');ylim(Range.Temperature);
    legend('show','Orientation','Horizontal');
    grid on;
    ax(4)=subplot(4,1,4);hold on;  
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.engoutNOx_g(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f'),'[g]']);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.tailpipeNOx_g(idx_start:idx_end),'c-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(idx_bag2)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g(idx_bag2)*Ts)/sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f')]);
    if ~isempty(idx_post_NOx_exceed)
        plot(Data.Time(intersect([idx_start:idx_end],idx_post_NOx_exceed)) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.tailpipeNOx_g(intersect([idx_start:idx_end],idx_post_NOx_exceed)),'r*',...
            'displayname','Exceed TPNOx','color',colormaps(i,:));
    end
    legend('show','Orientation','Horizontal');
    ylabel('NOx [g/s]');ylim([0 0.1]);
    linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    

    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end

%
figurename = 'NOx'
f = figure('name',figurename);
f.Position = [1,30,1200,570];

for ii = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    
    ax(1)=subplot(4,1,1);hold on;
    plot(MD.time - pre_ftp_dtime, MD.v_ego_demand,'r-','displayname','v\_ego\_demand');
    plot(MD.time - pre_ftp_dtime, MD.VESP_mph*0.44704,'b-','displayname','v\_ego\_actual');
    ylabel('VSpeed [m/s]');ylim([0 30]);
    legend('show','Orientation','Horizontal');

    ax(2)=subplot(4,1,2);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_SCRMIXER_IN(idx_start:idx_end),'b-','displayname','T\_SCRMIXER\_IN');
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_SCRMIXER_OUT(idx_start:idx_end),'c-','displayname','T\_SCRMIXER\_OUT')
    if ~strcmp(Data.T_SCR_OUT(1),'**')
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.T_SCR_OUT(idx_start:idx_end),'g-','displayname','T\_SCR\_OUT')
    end
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.ECU_Exh_tPFltUs(idx_start:idx_end),'-','color',[0.47,0.67,0.19],...
        'displayname','ECU\_Exh\_tPFltUs')
    legend('show','Orientation','Horizontal');
    ylabel('T\_AFT [degC]');ylim(Range.Temperature);
    legend('show','Orientation','Horizontal');
    grid on;
    
    ax(3)=subplot(4,1,3);hold on;
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.ECU_urd_qty_mgsec(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' urea\_inj']);
    if EBH_measured
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.NH3_g_bench(idx_start:idx_end)*1e3,'g-','displayname',...
            [legend_note,'\_',num2str(ii),' NH3\_EBH']);
    end
    legend('show','Orientation','Horizontal');
    ylabel('Urea [mg/s]');ylim([0 100])

    ax(4)=subplot(4,1,4);hold on;  
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.engoutNOx_g(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f'),'[g]']);
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.tailpipeNOx_g(idx_start:idx_end),'c-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 TPNOx, ',num2str(sum(Data.tailpipeNOx_g(idx_bag2)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g(idx_bag2)*Ts)/sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f')]);
    if ~isempty(idx_post_NOx_exceed)
        plot(Data.Time(intersect([idx_start:idx_end],idx_post_NOx_exceed)) - Data.Time(idx_start) - pre_ftp_dtime,...
            Data.tailpipeNOx_g(intersect([idx_start:idx_end],idx_post_NOx_exceed)),'r*',...
            'displayname','Exceed TPNOx','color',colormaps(i,:));
    end
    if EBH_measured
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.tailpipeNOx_g_bench(idx_start:idx_end),'g-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 TPNOx EBH, ',num2str(sum(Data.tailpipeNOx_g_bench(idx_bag2)*Ts),'%.2f'),'[g]',...
        ', Effi, ',num2str(1-sum(Data.tailpipeNOx_g_bench(idx_bag2)*Ts)/sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f')]);
    end
    legend('show','Orientation','Horizontal');
    ylabel('NOx [g/s]');ylim([0 0.1]);
    linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
    set(findall(gcf,'-property','FontSize'),'FontSize',10);
    

    if DoPlot
        print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
        savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
    end
end

%%
set(0, 'DefaultLineLineWidth', 1);

plotlist = {'ECU_InjCrv_phiMI1Des',...
    'ECU_InjCrv_phiPiI1Des','ECU_InjCrv_phiPiI2Des',...
    'ECU_InjCrv_phiPoI1Des','ECU_InjCrv_phiPoI2Des',...
    'ECU_InjCrv_qM1Des','ECU_InjCrv_qPil1Des_mp',...
    'ECU_InjCrv_qPil2Des_mp','ECU_InjCrv_qPoI1Des_mp',...
    'ECU_InjCrv_qPoI2Des_mp'};


figurename = 'PlotEngCondition'
f = figure('name',figurename);
f.Position = [1,30,1200,570];
axis_height_d = 0.1213;
for ii = num_cycles_list
    idx_start = idx_start_ic + cycle_length * (ii-1);
    idx_end = idx_start + cycle_length;
    idx_bag2 = idx_start+idx_start_e2c:idx_start+idx_start_e2c+idx_e2c_length;

    ax(1)=subplot(7,2,1);
    hold on;

    plot(MD.time - pre_ftp_dtime, MD.VESP_mph/2.236,'r-','displayname','Speed')
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_AIR(idx_start:idx_end),'c','displayname',...
        [legend_note,'\_',num2str(ii),' T\_AIR']);
    ylim([0 30]);
    xlim(Range.tspan);
    legend('show')
    title({strrep(MD.nameFile,'_','\_')})
    
    ax(2)=subplot(7,2,2);
    hold on;  
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.engoutNOx_g(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 EngNOx, ',num2str(sum(Data.engoutNOx_g(idx_bag2)*Ts),'%.2f'),'[g]']);
    
    ylim([0 0.05]);legend('show');
    ax(3)=subplot(7,2,3);
    hold on; 
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime,...
        Data.T_CEO(idx_start:idx_end),'b-','displayname',...
        [legend_note,'\_',num2str(ii),' bg2 T\_CEO']);
   
    legend('show');
    
    ax(4)=subplot(7,2,4);
    hold on;
    
    plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
        Data.ECU_EGRVlv_rAct(idx_start:idx_end),'r--','displayname',...
        [legend_note,'\_',num2str(ii), ' ECU\_EGRVlv\_rAct']);
%     plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start), ...
%         Data.EGR_Rate_wet_i60(idx_start:idx_end),'r--','displayname',...
%         ['Dyno\_',num2str(ii), ' EGR\_Rate\_i60']);
    legend('show');
    for i1 = 1:5
        ax(4+2*i1)=subplot(7,2,4+2*i1);
        hold on; 
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
            Data.(plotlist{i1})(idx_start:idx_end),'b-','displayname',...
            ['', strrep(plotlist{i1},'_','\_')]);
        legend('show');
        if i1 == 1
            ylim([ -25 25]);
        else
            ylim([ -45 45]);
        end
    end
    xlabel('Time [s]')
    
    for i1 = 6:10
        ax(3+2*(i1-5))=subplot(7,2,3+2*(i1-5));
        hold on;
        plot(Data.Time(idx_start:idx_end) - Data.Time(idx_start) - pre_ftp_dtime, ...
            Data.(plotlist{i1})(idx_start:idx_end),'b-','displayname',...
        ['', strrep(plotlist{i1},'_','\_')]);
        
        legend('show')
        if i1 == 6
            ylim([0 100])
        else
            ylim([0 20])
        end
    end
    xlabel('Time [s]')
end
ax(1).Position = [0.0421875 0.837678571428571 0.44 0.0873214285714287];
ax(2).Position = [0.5215625 0.837678571428571 0.44 0.0873214285714288];
ax(3).Position = ax(1).Position + [0,-axis_height_d,0,0];
ax(4).Position = ax(2).Position + [0,-axis_height_d,0,0];
for i1 = 1:5
    ax(4+2*i1).Position = ax(4).Position + [0,-axis_height_d*i1,0,0];
end
for i1 = 6:10
    ax(3+2*(i1-5)).Position = ax(3).Position + [0,-axis_height_d*(i1-5),0,0];
end
linkaxes(ax,'x');xlim(Range.tspan);xlabel('Time [s]');
if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
end

