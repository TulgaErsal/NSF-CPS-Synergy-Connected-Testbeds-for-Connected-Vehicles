

%% load txt saved in solver folder
Filename = ['packetsClient_Solver'];
Filefullpath = fullfile(test_folder,'Solver_data',['Test',num2str(Test_i)], Filename);
Data_c_s = readtable(Filefullpath);
% fromClient.packetNumber, actualTime, abstimeNow, myIns.simTime, ...
% fromClient.sendSimTime, fromClient.throttle, fromClient.engineSpeed, 
% fromClient.dropRate, fromClient.rtt);
Data_c_s.Properties.VariableNames{'Var1'} = 'packetNumber';
Data_c_s.Properties.VariableNames{'Var2'} = 'actualTime';
Data_c_s.Properties.VariableNames{'Var3'} = 'absActualTime';
Data_c_s.Properties.VariableNames{'Var4'} = 'solver_sim_time';
Data_c_s.Properties.VariableNames{'Var5'} = 'client_sim_time';
Data_c_s.Properties.VariableNames{'Var6'} = 'client_time_read';
Data_c_s.Properties.VariableNames{'Var7'} = 'trigSQP';
Data_c_s.Properties.VariableNames{'Var8'} = 'pkgdr';  % package drop rate
Data_c_s.Properties.VariableNames{'Var9'} = 'rtt'; 

Filename = ['packetsServer_Solver'];
% Filefullpath = Filename;
% Filename = ['Test',num2str(Test_i),'_','packetsServer_Solver'];
Filefullpath = fullfile(test_folder,'Solver_data',['Test',num2str(Test_i)], Filename);
Data_s_s = readtable(Filefullpath);
% fromServer.packetNumber, actualTime, abstimeNow, fromServer.sendSimTime, 
% fromServer.engineTorque, fromServer.v_opt_array[0], fromServer.v_opt_array[1]
Data_s_s.Properties.VariableNames{'Var1'} = 'packetNumber';
Data_s_s.Properties.VariableNames{'Var2'} = 'actualTime';
Data_s_s.Properties.VariableNames{'Var3'} = 'absActualTime';
Data_s_s.Properties.VariableNames{'Var4'} = 'solver_sim_time';
Data_s_s.Properties.VariableNames{'Var5'} = 'SQP_start_time_in_client';
Data_s_s.Properties.VariableNames{'Var6'} = 'v_opt_array_0';
Data_s_s.Properties.VariableNames{'Var7'} = 'v_opt_array_1';


%% load txt saved in client folder

Filename = ['packetsClient_client'];
% Filefullpath = Filename;
% Filename = ['Test',num2str(Test_i),'_','packetsClient_client'];
Filefullpath = fullfile(test_folder,'VehMdl_data',['Test',num2str(Test_i)], Filename);
Data_c_c = readtable(Filefullpath);
Data_c_c.Properties.VariableNames{'Var1'} = 'packetNumber';
Data_c_c.Properties.VariableNames{'Var2'} = 'timeNow';
Data_c_c.Properties.VariableNames{'Var3'} = 'abstimeNow';
Data_c_c.Properties.VariableNames{'Var4'} = 'client_sim_time';
Data_c_c.Properties.VariableNames{'Var5'} = 'client_time_sent';
Data_c_c.Properties.VariableNames{'Var6'} = 'trigSQP';
Data_c_c.Properties.VariableNames{'Var7'} = 'pkgdr';  % package drop rate
Data_c_c.Properties.VariableNames{'Var8'} = 'rtt'; 
Data_c_c.Properties.VariableNames{'Var9'} = 'd_rel'; 
Data_c_c.Properties.VariableNames{'Var10'} = 'T_TB'; 
Data_c_c.Properties.VariableNames{'Var11'} = 'v_lead'; 
Data_c_c.Properties.VariableNames{'Var12'} = 'v_ego'; 


Filename = ['packetsServer_client'];
Filefullpath = fullfile(test_folder,'VehMdl_data',['Test',num2str(Test_i)], Filename);
% record server package in ClientEmbed.c:
% fromServer.packetNumber, timeNow, fromClient.sendSimTime, fromServer.sendSimTime, ...
%     fromServer.engineTorque, fromServer.v_opt_array[0], fromServer.v_opt_array[39])
Data_s_c = readtable(Filefullpath);
Data_s_c.Properties.VariableNames{'Var1'} = 'packetNumber';
Data_s_c.Properties.VariableNames{'Var2'} = 'timeNow';
Data_s_c.Properties.VariableNames{'Var3'} = 'abstimeNow';
Data_s_c.Properties.VariableNames{'Var4'} = 'client_sim_time';
Data_s_c.Properties.VariableNames{'Var5'} = 'solver_sim_time';
Data_s_c.Properties.VariableNames{'Var6'} = 'solver_start_time';
Data_s_c.Properties.VariableNames{'Var7'} = 'v_opt_array_0';
Data_s_c.Properties.VariableNames{'Var8'} = 'v_opt_array_39';


%% Check real-time
figure;hold on
cdfplot(Data_s_s.solver_sim_time - Data_s_s.actualTime - ...
    max(Data_s_s.solver_sim_time - Data_s_s.actualTime))
cdfplot(Data_c_c.client_sim_time - Data_c_c.timeNow - ...
    max(Data_c_c.client_sim_time - Data_c_c.timeNow))
legend('Solver','Client')

%% ------- analysis computation time in client --- 

% ------- for trigSQPs sent by client and got result -----
idx = find(diff([0;Data_s_c.solver_start_time])>0);
% Calculate time delay from client (from send trig to receive result)
figurename = 'Delay_analysis';
f = figure('name',figurename);
f.Position = [1,30,1200,570];
ay(1) = subplot(2,2,1); hold on;
plot(Data_s_c.solver_start_time(idx), ...
    Data_s_c.client_sim_time(idx)-Data_s_c.solver_start_time(idx), '-*', ...
    'displayname', 'Client sim delay from SQP demanded to result received');
ylabel('Delay [s in simulation]');
xlabel('client\_sim\_time when trig demand received by Solver [s in simulation]');

ay(2) = subplot(2,2,2); hold on;
plot(interp1(Data_c_c.client_sim_time, Data_c_c.timeNow, ...
    Data_s_c.solver_start_time(idx)), ...
    Data_s_c.timeNow(idx) - ...
    interp1(Data_c_c.client_sim_time, Data_c_c.timeNow, ...
    Data_s_c.solver_start_time(idx)) , '-*', ...
    'displayname', 'Delay from SQP demanded to result received');
ylabel('Delay [s in world time]');
xlabel('Time when trig demand received by Solver [s in world time]');

% ------- analysis computation time in solver --- 
% sqp_start_time is solver time when SQP computation starts (one timestep 
% after trig received)
sqp_start_time = MD.PARS.base_dT + interp1(Data_c_s.client_time_read, ...
    Data_c_s.solver_sim_time, Data_s_c.solver_start_time(idx));
% Note, sqp_start_time also equal to 
% sqp_start_time1 = Data_c_s.solver_sim_time(idx_solver_get_trig)+MD.PARS.base_dT;
% but sqp_start_time1 may have one more element at the end than sqp_start_time.
% This means the last result is not received by client before client ends simulation. 
idx_sqp_end_time = 0*sqp_start_time;
for i = 1:length(sqp_start_time)
    idx_solver_end_time_jump = find(diff([0;solver_end_time.Data])>0);
    idx_sqp_end_time_raw = intersect(idx_solver_end_time_jump,...
        find((solver_end_time.Time-sqp_start_time(i)).*(solver_end_time.Time - sqp_start_time(i)-2) <= 0));
    % Select the first element if there are more than 1
    idx_sqp_end_time(i) = idx_sqp_end_time_raw(1);
end
sqp_end_time = solver_end_time.Time(idx_sqp_end_time);  % solver time when SQP ends and sends command.

ay(1) = subplot(2,2,1);hold on
plot(Data_s_c.solver_start_time(idx), ...
    sqp_end_time - sqp_start_time, '-*', ...
    'displayname', 'Solver sim delay from SQP computation starts to ends');
legend('show')
ylabel('Delay [s in simulation]');
xlabel('client\_sim\_time when trig demand received by Solver [s in simulation]');

ay(2) = subplot(2,2,2); hold on;
plot(interp1(Data_c_c.client_sim_time, Data_c_c.timeNow, ...
    Data_s_c.solver_start_time(idx)), ...
    interp1(Data_c_s.solver_sim_time, Data_c_s.actualTime, ...   % This interp1 is solver world time when sqp_end
    sqp_end_time) - ...
    interp1(Data_c_s.solver_sim_time, Data_c_s.actualTime, ...   % This interp1 is solver world time when sqp_start
    sqp_start_time) , '-*', ...
    'displayname', 'Delay from SQP computation starts to ends');
legend('show')
ylabel('Delay [s in world time]');
xlabel('Time when trig demand received by Solver [s in world time]');

% Plot hists
ay(3) = subplot(2,2,3);hold on
xbins1 = 0:0.02:2;
h1 = histogram(Data_s_c.client_sim_time(idx)-Data_s_c.solver_start_time(idx),...
    xbins1,'Normalization','probability','FaceColor',[0,0.45,0.74],...
    'displayname', 'SQP computation+communication');
h2 = histogram(sqp_end_time - sqp_start_time,...
    xbins1,'Normalization','probability','FaceColor',[0.85 0.33 0.1],...
    'displayname', 'SQP computation');
% h3 = histogram((Data_s_c.client_sim_time(idx)-Data_s_c.solver_start_time(idx)) - (sqp_end_time - sqp_start_time),...
h3 = histogram(h1.Data - h2.Data,...
    xbins1,'Normalization','probability','FaceColor',[0.93 0.69 0.13],...
    'displayname', 'SQP communication');
legend('show')
xlabel('Delay [s in simulation]');
ylabel('Probability')

ay(4) = subplot(2,2,4);hold on
xbins1 = 0:0.02:2;
hh1 = histogram(...
    Data_s_c.timeNow(idx) - ...
    interp1(Data_c_c.client_sim_time, Data_c_c.timeNow, ...
    Data_s_c.solver_start_time(idx)) ,...
    xbins1,'Normalization','probability','FaceColor',[0,0.45,0.74],...
    'displayname', 'SQP computation+communication');
hh2 = histogram(...
    interp1(Data_c_s.solver_sim_time, Data_c_s.actualTime, ...   % This interp1 is solver world time when sqp_end
    sqp_end_time) - ...
    interp1(Data_c_s.solver_sim_time, Data_c_s.actualTime, ...   % This interp1 is solver world time when sqp_start
    sqp_start_time),...
    xbins1,'Normalization','probability','FaceColor',[0.85 0.33 0.1],...
    'displayname', 'SQP computation');
hh3 = histogram(hh1.Data - hh2.Data,...
    xbins1,'Normalization','probability','FaceColor',[0.93 0.69 0.13],...
    'displayname', 'SQP communication');
legend('show')
xlabel('Delay [s in world time]');
ylabel('Probability')
if DoPlot
    print(f,'-dpng','-r400',fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.png']))
    savefig(f, fullfile(test_folder,'PlotFigures',[figure_prefix, '_', figurename, '.fig']));
end
