

Solver_receive_headers = {'Solver_sim_time','DropRate','Trig_SQP','rtt','Client_sim_time',...
    'VehMdl_sim_time','d_rel','T_TB','v_lead','v_ego',...
    'v_lead_pre'};

for i = 1:length(Solver_receive_headers)-1
    Solver.Receive.(Solver_receive_headers{i}) = solver_client_receive.Data(:,i);
end
Solver.Receive.(Solver_receive_headers{end}) = solver_client_receive.Data(:,i+1:end);


%%
MPCPair_client_receive_headers = {'actualTime','DropRate',...
    'SQP_StartTime','rtt','v_opt_array'};
for i = 1:length(MPCPair_client_receive_headers)-1
    VehMdl.clientReceive.(MPCPair_client_receive_headers{i}) = Sim_MPCPair_client_receive.signals.values(:,i);
end
VehMdl.clientReceive.(MPCPair_client_receive_headers{end}) = Sim_MPCPair_client_receive.signals.values(:,i+1:end);


MPCPair_client_send_headers = {'Trig_SQP','actualTime',...
    'd_rel','T_TB','v_lead','v_ego','v_lead_pre'};
for i = 1:length(MPCPair_client_send_headers)-1
    VehMdl.clientSend.(MPCPair_client_send_headers{i}) = Sim_MPCPair_client_send.signals.values(:,i);
end
VehMdl.clientSend.(MPCPair_client_send_headers{end}) = Sim_MPCPair_client_send.signals.values(:,i+1:end);


%% Analysis of solver result

figurename = 'Plot_Communication';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1) = subplot(2,2,1);hold on;
plot(VehMdl.clientReceive.actualTime, VehMdl.clientReceive.rtt,...
    'displayname','rtt')
grid on; legend('show')
ax(2) = subplot(2,2,3);hold on;
plot(VehMdl.clientReceive.actualTime, VehMdl.clientReceive.DropRate,...
    'displayname','Drop rate')
grid on; legend('show')
linkaxes(ax,'x');xlabel('Time [s]')
if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
end

subplot(2,2,2);
xbins1 = 0:0.005:0.6;
h = histogram(VehMdl.clientReceive.rtt,...
    xbins1,'Normalization','probability');
xlim([0,0.2]);
title('histogram of rtt')
subplot(2,2,4);
cdfplot(VehMdl.clientReceive.rtt);
xlim([0,0.2]);
title('CDF of rtt')
if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
end


idxx = find(diff([0;VehMdl.clientReceive.SQP_StartTime])>0);
figurename = 'Plot_Speed_Optim';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ax(1)=subplot(2,1,1);hold on;
for i = 1:2:length(idxx)
    plot(VehMdl.clientReceive.SQP_StartTime(idxx(i))+[0:1:39],...
        VehMdl.clientReceive.v_opt_array(idxx(i),:),'.-');
end
p1 = plot(MD.time, MD.v_lead_to_E2C,'k-','displayname','v\_lead\_act');
p2 = plot(MD.time, MD.v_ego_demand,'g--','displayname','v\_ego\_tgt','linewidth',1);
p3 = plot(MD.time, MD.VESP_mph*0.44704,'r-','displayname','v\_ego');
legend([p1,p2,p3],p1.DisplayName,p2.DisplayName,p3.DisplayName);
ylabel('[m/s]');
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

ax(2)=subplot(2,1,2);hold on;
plot(VehMdl.clientSend.actualTime, VehMdl.clientSend.d_rel,'displayname','distance');
plot(MD.time, [MD.PARS.t_HDW(1)*MD.VESP_mph*0.44704 + MD.PARS.d_HDW(1),...
    MD.PARS.t_HDW(2)*MD.VESP_mph*0.44704 + MD.PARS.d_HDW(2)],'k--',...
    'displayname','d constraints');
if isfield(MD.PARS,'c_acc_hdw')
    if MD.PARS.b_use_acc
        plot(MD.time, MD.PARS.c_acc_d_hdw+MD.PARS.c_acc_hdw*MD.VESP_mph*0.44704,...
            '--','color',0.5*[1,1,1],'displayname','target ACC headway');
    end
end
ylabel('[m]')
legend('show')
xlabel('Time [s]')
if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
end


%% Analysis of SQP termination (flag)
% figure;plot(solver_start_time,'displayname','solver_start_time')
% hold on
% plot(solver_end_time,'displayname','solver_end_time')
% plot(Solver_f_nonl_new,'displayname','Solver_f_nonl_new')
% plot(solver_stGrad,'displayname','solver_stGrad')
% plot(solver_stSolve,'displayname','solver_stSolve')
% % plot(solver_vals,'displayname','solver_vals')
% plot(solver_ctr,'displayname','solver_ctr')
% plot(solver_b_exitQP,'displayname','solver_b_exitQP')
% plot(solver_b_termQP,'displayname','solver_b_termQP')
% 
% plot(solver_vals.Time, squeeze(solver_vals.Data(2,:,:)))
% plot(solver_vals.Time, squeeze(solver_vals.Data(1,:,:)))
% 

% find sqp trigger received in solver:
% solver_state_flag: 
%   0 - b_QP ==0
%   -4 - does not find corresponding solver_end_time
%   -2 - b_exitQP ==1
%   1 - solved with b_termQP ==1
%   2 - b_termQP ==0, df < df_term
%   3 - b_termQP ==0, dz < dz_term

% check if sqp is finished within 1 sec:
if solver_PARS.bEgoFol == 0
    Solver.Receive.idx_sqp_start = getEdgeIndex(solver_start_time.Data,'rising',0);
    Solver.Receive.idx_sqp_start = Solver.Receive.idx_sqp_start(1:end-1);
    Solver.Receive.idx_sqp_end = 0*Solver.Receive.idx_sqp_start;
    Solver.Receive.solver_state_flag = 0*Solver.Receive.idx_sqp_start;
else
    Solver.Receive.idx_sqp_start = getEdgeIndex(solver_start_time.Data,'rising',0);
    % Only consider the part when MPC is on:
    Solver.Receive.idx_sqp_start = intersect(Solver.Receive.idx_sqp_start, find(solver_start_time.Data>solver_PARS.t_StartSimulation));
    Solver.Receive.idx_sqp_start = Solver.Receive.idx_sqp_start(1:end-1);
    Solver.Receive.idx_sqp_end = 0*Solver.Receive.idx_sqp_start;
    Solver.Receive.solver_state_flag = 0*Solver.Receive.idx_sqp_start;

    for ind1 = 1:length(Solver.Receive.idx_sqp_start)
        i = Solver.Receive.idx_sqp_start(ind1);
        sqp_end_1 = getEdgeIndex(solver_end_time.Data(i:...
            i - 1 + (solver_PARS.E2C_tiSolverPeriod_C-solver_PARS.E2C_DeltaT)/solver_PARS.base_dT),...
            'rising',solver_end_time.Data(i));
        if isempty(sqp_end_1)
            % placeholder
            Solver.Receive.idx_sqp_end(ind1) = i;
            Solver.Receive.solver_state_flag(ind1) = -4;
        else
            Solver.Receive.idx_sqp_end(ind1) = sqp_end_1(1) + i - 1;
            if solver_b_exitQP.Data( Solver.Receive.idx_sqp_end(ind1) ) == 1
                Solver.Receive.solver_state_flag(ind1) = -2;
%             elseif solver_b_termQP.Data( Solver.Receive.idx_sqp_end(ind1) ) == 1
%                 Solver.Receive.solver_state_flag(ind1) = 1;
            elseif solver_vals.Data(2,1,Solver.Receive.idx_sqp_end(ind1)) < solver_PARS.df_term ...
                    && ...
                    solver_vals.Data(1,1,Solver.Receive.idx_sqp_end(ind1)) < solver_PARS.dz_term
                
                Solver.Receive.solver_state_flag(ind1) = 1;
            elseif solver_vals.Data(2,1,Solver.Receive.idx_sqp_end(ind1)) < solver_PARS.df_term
                Solver.Receive.solver_state_flag(ind1) = 2;
            elseif solver_vals.Data(1,1,Solver.Receive.idx_sqp_end(ind1)) < solver_PARS.dz_term
                Solver.Receive.solver_state_flag(ind1) = 3;
            end
        end
    end
end


figure;
histogram(Solver.Receive.solver_state_flag,'Normalization','probability')
figure;
histogram(solver_ctr.Data(Solver.Receive.idx_sqp_end),'Normalization','probability')


%% Analyze delay
if MD.PARS.bEgoFol == 1
    disp('--------- Doing bEgoFol, now run Analysis_communication.m ---------')
    Analysis_communication
else
    disp('--------- Not doing bEgoFol, skip run Analysis_communication.m ---------')
end

