% version 03282017
% add bsfc table

% clear all


%% load 20170508measurement (steady state data points)
% and INCA data (02142017 dyno INCA data)
% load_steady_state_dyno_points

%% 20170517measurement (4 transient data points)
% load_transient_dyno_points

%%
% load('w863_hc_sns_pre_post_doc_verl1_ftp75_bag_1_2_11aug16_1.UofM.mat')

%%
% efficiency table
% ef_Tin = [1, 130,153,180,205,230,258,280,330,380,430, 480]';
% ef_perc = [5, 5,22,48,72,85,91,92,91,85,74,54]';
ef_Tin = [1, 130,155,180,208,230,260,280,330,380,430, 480]';
ef_perc = [5, 20,57,85,95,97.5,97.5,96,94,88.5,78,61]';
effi = table(ef_Tin,ef_perc);


%%
% % load('20150310_061W670_FTP74_SDPF_wTC_v2')
% figure('Name','SDPF data');
% ax1 = subplot(5,1,1);
% plot(time,Epm_nEng,'linewidth',1)
% grid on;
% title('20150310\_061W670\_FTP74\_SDPF\_wTC\_v2')
% legend('Ne [rpm]')
% ax2 = subplot(5,1,2);
% plot(time,PthSet_trqInrSet,'linewidth',1)
% grid on;
% legend('PthSetTq [Nm]')
% ax3 = subplot(5,1,3);
% plot(time,urd_exhflow_gsec,'linewidth',1)
% grid on;
% legend('mf exh [g/s]')
% ax4 = subplot(5,1,4);
% plot(time,urd_qty_mgsec_return,'linewidth',1)
% grid on;
% legend('Urea [mg/s]')
% 
% SDPF_Front = mean([SDPF_Front_Bottom, SDPF_Front_Center, SDPF_Front_Left, SDPF_Front_Right, SDPF_Front_Top]')';
% SDPF_Rear = mean([SDPF_Rear_Bottom, SDPF_Rear_Center, SDPF_Rear_Left, SDPF_Rear_Right, SDPF_Rear_Top]')';
% 
% ax5 = subplot(5,1,5);
% hold on;
% plot(time,t_pre_sdpf,'b','linewidth',1)
% plot(time,t_post_sdpf,'k','linewidth',1)
% plot(time,SDPF_Front,'r--','linewidth',1)
% plot(time,SDPF_Mid2_Center,'m--','linewidth',1)
% plot(time,SDPF_Rear,'g--','linewidth',1)
% grid on;
% hold off;
% legend('Gas us','Gas ds','Block us','Block mid','Block ds')
% linkaxes([ax1,ax2,ax3,ax4,ax5],'x')

%% report 2 (ford dyno data, maps)

[data,~]=xlsread('forddata_03282017.xlsx');
% i = 1;
% while i < length(data(:,2))+1
%     if data(i,2) >300
%         data(i,:) = [];
%         i=i-1;
%     end
%     i=i+1;
% end
% data(1:6,:) = [];
% 
data(:,1) = round(data(:,1)/100)*100;
data(:,2) = round(data(:,2)/50)*50;
data = sortrows(data,[1,2]);

% 
% i = 2;
% while i <= (length(data(:,1)))
%     if data(i,1) == 0
%         data(i,:) = [];
%         i=i-1;
%     end
%     i=i+1;
% end


spd_data = data(:,1); % Engine speed [RPM]
tq_data = data(:,2); % 
t_amb_data = data(:,3); % ambient temperature [deg C]
mf_exh_data = data(:,4)/3600; % exhaust flow rate [kg/s]
C_NOx_eu_data = data(:,5);%  feedgas NOx [ppm] 
C_O2_data = data(:,6); % feedgas O2 [%] 
p_eu_data = data(:,7); % turbo outlet pressure [kpa] 
t_eu_data = data(:,8); % turbo outlet temperature [deg C] 
bsfc_data = data(:,9); % bsfc [g/kw-h] 
fuelflow_data = data(:,10); % fuelflow rate [kg/hr] not from ECU
throttle_data = data(:,11);
injsys_qtot_data = data(:,12);
T_turbo_in_data = data(:,13);
Torque_data = data(:,14);% Is it engine output torque [Nm]? Torque*Ne=fuelflom/bsfc
Power_data = data(:,15); % unit kW

clear data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fit the curves instead of using interp2
% sf_fuel = fit([spd_data,tq_data],fuelflow_ecu_data,'poly33')
% figure;plot(sf_fuel,[spd_data,tq_data],fuelflow_ecu_data)
% figure;plot((sf_fuel([spd_data,tq_data])-fuelflow_ecu_data)./fuelflow_ecu_data)
% sf_meu = fit([spd_data,tq_data],mf_exh_data,'poly23')
% figure;plot(sf_meu,[spd_data,tq_data],mf_exh_data)
% figure;plot((sf_meu([spd_data,tq_data])-mf_exh_data)./mf_exh_data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clear tq_points  spd_points
i = 2;
tq_points = 0;
while i<length(spd_data)
    if tq_data(i) > tq_points(end)
        if  tq_data(i) == 950
            tq_data(i) = 1000;
        end
        if  tq_data(i) == 850
            tq_data(i) = 900;
        end
        tq_points = [tq_points;tq_data(i)];
    end
    i=i+1;
end
% has one 950 and one 850. The table is not very accurate. 
% make 950 to 1000, 850 to 900

i=2;
spd_points = spd_data(1);
amount = [];
while i<length(spd_data)
    if spd_data(i) > spd_data(i-1)
        spd_points = [spd_points;spd_data(i)];
        amount = [amount,i-1];
    end
    i = i + 1;
end
amount = [amount,length(spd_data)];
amount = [amount(1),diff(amount)];

clear FordTqCal
FordTqCal.Torque = Torque_data;
FordTqCal.PthsetTq = tq_data;
FordTqCal.Ne = spd_data;
for i=1:1:length(amount)
    FordTqCal.Ne = [FordTqCal.Ne; spd_data(sum(amount(1:i-1))+1)];
    FordTqCal.Torque = [FordTqCal.Torque;-1000];
    FordTqCal.PthsetTq = [FordTqCal.PthsetTq ;0];
end


spd_points;
tq_points;

% data for simulink table

% 07182017
[spd_points,tq_points] = meshgrid(spd_points,tq_points);   
% change spd_points, tq_points into meshgrid. before these are vectors

t_amb_points = generatetable(t_amb_data, tq_points,spd_points, amount); % [deg C]
mf_exh_points = generatetable(mf_exh_data, tq_points,spd_points, amount); % [kg/s]
C_NOx_eu_points = generatetable(C_NOx_eu_data, tq_points,spd_points, amount); % [mol/m3]
C_O2_points = generatetable(C_O2_data, tq_points,spd_points, amount); %[%]
p_eu_points = generatetable(p_eu_data, tq_points,spd_points, amount) / 100; % change from kpa to [bar]
t_eu_points = generatetable(t_eu_data, tq_points,spd_points, amount); % [deg C]
bsfc_points = generatetable(bsfc_data, tq_points,spd_points, amount); % [g/kw-h]
fuelflow_points = generatetable(fuelflow_data, tq_points,spd_points, amount); % [kg/hr]
throttle_points = generatetable(throttle_data, tq_points,spd_points, amount); % [%]
injsys_qtot_points  = generatetable(injsys_qtot_data, tq_points,spd_points, amount); % [kg/hr]
T_turbo_in_points   = generatetable(T_turbo_in_data, tq_points,spd_points, amount);  % [degC]
Torque_points   = generatetable(Torque_data, tq_points,spd_points, amount);  % [Nm]
Power_points   = generatetable(Power_data, tq_points,spd_points, amount);  % [Nm]

% figure;surf(spd_points,tq_points,T_turbo_in_points);title('turbo-in')
clear i amount 

% 07182017
clear FordData
FordData = table;
FordData.spd = spd_points;
FordData.tq = tq_points;
FordData.t_amb = t_amb_points;
FordData.mf_exh = mf_exh_points;
FordData.C_NOx_eu = C_NOx_eu_points;
FordData.C_O2 = C_O2_points;
FordData.p_eu = p_eu_points;
FordData.t_eu = t_eu_points;
FordData.bsfc = bsfc_points;
FordData.fuelflow = fuelflow_points;
FordData.throttle = throttle_points;
FordData.injsys_qtot = injsys_qtot_points;
FordData.Torque = Torque_points;
FordData.Power = Power_points;
FordData.TurboIn = T_turbo_in_points;
FordData.t_eu_modify = FordData.TurboIn*[0.7600]+[-0.0036]*FordData.tq+ 23.5073;
[T_turbo_in_data, tq_data, ones(length(tq_data),1)]\t_eu_data;
% figure;plot([T_turbo_in_data, tq_data, ones(length(tq_data),1)]* [0.7600; -0.0036; 23.5073])
% hold on;plot(t_eu_data)
% figure;surf(FordData.TurboIn)
% figure;surf(FordData.t_eu_modify)

clear spd_points tq_points t_amb_points mf_exh_points C_NOx_eu_points C_O2_points p_eu_points...
    t_eu_points bsfc_points fuelflow_points throttle_points injsys_qtot_points Torque_points...
    Power_points

power_Ne.Ne = [500:10:2800]';
power_Ne.Tq = interp1([500,1200,2600,2800], [0, 400, 500, 1350], power_Ne.Ne);
power_Ne.Torque = interp2(FordData.spd, FordData.tq, FordData.Torque, power_Ne.Ne, power_Ne.Tq);
power_Ne.power = 2*pi/60*power_Ne.Ne.*power_Ne.Torque/1e3;
power_Ne.mexh = interp2(FordData.spd, FordData.tq, FordData.mf_exh, power_Ne.Ne, power_Ne.Tq);
% for extrapolation
power_Ne.power = [-1000;power_Ne.power;1000];
power_Ne.mexh = [power_Ne.mexh(1);power_Ne.mexh;power_Ne.mexh(end)];




% change these meshgrids into one table: FordData
% before these are separate variables. hard to put into functions


% fit functions for some of the engine outputs: sf_Forddata
    sf_fuel = fit([spd_data,tq_data], fuelflow_data,'poly33') ;
    sf_meu = fit([spd_data,tq_data],mf_exh_data,'poly23');
    sf_C_NOx_eu = fit([spd_data,tq_data],C_NOx_eu_data,'poly44');
	sf_T_TB_o = fit([spd_data,tq_data],t_eu_data,'poly24');
    sf_Forddata = {sf_fuel, sf_meu, sf_C_NOx_eu, sf_T_TB_o};
    clear sf_T_TB_o sf_C_NOx_eu sf_meu sf_fuel


%% generating maps from speed pedal to fuel, speed fuel to torque
% throttle_data;
% spd_data;
% tq_data;
% 
% % from speed torque -> fuel
% [speed,torque] = meshgrid(500:100:3400, 0:50:1350);
% vq = griddata(spd_data,tq_data,injsys_qtot_data,speed,torque);
% figure;mesh(speed,torque,vq)
% title('speed torque -> fuel')
% 
% from speed throttle -> torque
[SPDthrotq,spdTHROtq] = meshgrid(500:100:3400, 0:5:100);
% vq2 = griddata(spd_data,throttle_data,tq_data,speed,throttle);
spdthroTQ = griddata(spd_data,throttle_data,tq_data,SPDthrotq,spdTHROtq);
% figure;mesh(SPDthrotq,spdTHROtq,spdthroTQ)
% xlabel('speed')
% ylabel('throttle')
% title('speed throttle -> torque')
% 
% % from speed fuel[mg/stk] --> torque
% [speed,fuel] = meshgrid(500:100:3400, 0:5:120); % max(injsys_qtot_data)=117
% vq3 = griddata(spd_data,injsys_qtot_data,tq_data,speed,fuel);
% figure;mesh(speed,fuel,vq3)
% title('speed fuel --> torque')
% 
% % from speed throttle --> fuel[mg/stk]
% [speed,throttle] = meshgrid(500:100:3400, 0:5:100);
% vq4 = griddata(spd_data,throttle_data,fuelflow_ecu_data,speed,throttle);
% figure;mesh(speed,throttle,vq4)
% title('speed throttle --> fuel')
% 
% xlabel('speed [rpm]')
% ylabel('torque [Nm]')
% title('feedgas O2 [%]')

%% 
% clearvars -except dyno spd_points tq_points mf_exh_points p_eu_points C_NOx_eu_points t_amb_points t_eu_points C_O2_points bsfc_points fuelflow_ecu_points throttle_points vq vq2 vq3 vq4 T_turbo_in_points
clearvars amount i X Y 

%% thermal properties table
i=0;
while (i==0)

    t_boil_table1 = [17.51
24.1
28.98
32.9
36.18
39.02
41.53
43.79
45.83
60.09
69.13
75.89
81.35
85.95
89.96
93.51
96.71
99.63
102.32
104.81
107.13
109.32
111.37
113.32
115.17
116.93
118.62
120.23
123.27
126.09
128.73
131.2
133.54
138.87
143.63
147.92
151.85
155.47
158.84
161.99
164.96
167.76
170.42
172.94
175.36
177.67
179.88
184.06
187.96
191.6
195.04
198.28
201.37
204.3
207.11
209.79
212.37
214.85
217.24
219.55
221.78
223.94
226.03
228.06
230.04
231.96
233.84
235.66
237.44
239.18
240.88
242.54
244.16
245.75
247.31
248.84
250.33
251.8
253.24
254.66
256.05
257.41
258.76
260.08
261.38
262.66
263.92
265.16
266.38
267.58
268.77
269.94
271.09
272.23
273.36
274.47
275.56
276.64
277.71
278.76
279.8
280.83
281.85
282.85
283.85
284.83
285.8
286.76
287.71
288.65
289.59
290.51
291.42
292.32
293.22
294.1
294.98
295.85
296.71
297.56
298.4
299.24
300.07
300.89
301.71
302.51
303.31
304.11
304.89
305.67
306.45
307.22
307.98
308.73
309.48
310.22
310.96
];
t_boil_table2 = [0.02
0.03
0.04
0.05
0.06
0.07
0.08
0.09
0.1
0.2
0.3
0.4
0.5
0.6
0.7
0.8
0.9
1
1.1
1.2
1.3
1.4
1.5
1.6
1.7
1.8
1.9
2
2.2
2.4
2.6
2.8
3
3.5
4
4.5
5
5.5
6
6.5
7
7.5
8
8.5
9
9.5
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
];
i=1;
end
t_boil_table = [t_boil_table1 t_boil_table2];
t_boil_table = dataset({t_boil_table 'data','point'});   % t_boil(pressure[bar])
i=1;
while (i==1)
    r_v_H2O_1 = [2460.19
2444.65
2433.1
2423.82
2416.01
2409.24
2403.25
2397.85
2392.94
2358.4
2336.13
2319.23
2305.42
2293.64
2283.3
2274.05
2265.65
2257.92
2250.76
2244.08
2237.79
2231.86
2226.23
2220.87
2215.75
2210.84
2206.13
2201.59
2192.98
2184.91
2177.3
2170.08
2163.22
2147.35
2132.95
2119.71
2107.42
2095.9
2085.03
2074.73
2064.92
2055.53
2046.53
2037.86
2029.49
2021.4
2013.56
1998.55
1984.31
1970.73
1957.73
1945.24
1933.19
1921.55
1910.27
1899.31
1888.65
1878.25
1868.11
1858.2
1848.49
1838.98
1829.66
1820.5
1811.5
1802.65
1793.94
1785.36
1776.9
1768.56
1760.33
1752.2
1744.17
1736.24
1728.39
1720.62
1712.94
1705.33
1697.79
1690.32
1682.91
1675.57
1668.29
1661.06
1653.89
1646.77
1639.7
1632.68
1625.7
1618.77
1611.88
1605.03
1598.21
1591.43
1584.69
1577.98
1571.31
1564.66
1558.04
1551.45
1544.89
1538.36
1531.85
1525.36
1518.9
1512.45
1506.03
1499.63
1493.25
1486.89
1480.54
1474.21
1467.9
1461.61
1455.32
1449.06
1442.8
1436.56
1430.33
1424.11
1417.91
1411.71
1405.52
1399.35
1393.18
1387.02
1380.87
1374.73
1368.59
1362.46
1356.34
1350.22
1344.11
1338
1331.89
1325.79
1319.69
];
r_v_H2O_2 = [0.02
0.03
0.04
0.05
0.06
0.07
0.08
0.09
0.1
0.2
0.3
0.4
0.5
0.6
0.7
0.8
0.9
1
1.1
1.2
1.3
1.4
1.5
1.6
1.7
1.8
1.9
2
2.2
2.4
2.6
2.8
3
3.5
4
4.5
5
5.5
6
6.5
7
7.5
8
8.5
9
9.5
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
];
i=2;
end
r_v_H2O_table = [r_v_H2O_1 r_v_H2O_2];
r_v_H2O_table = dataset({r_v_H2O_table 'data','point'});
i=2;
while (i==2)
    c_p_H2O_l_1 = [4.217
4.213
4.21
4.207
4.205
4.202
4.2
4.198
4.196
4.194
4.192
4.191
4.189
4.188
4.187
4.186
4.185
4.184
4.183
4.182
4.182
4.181
4.181
4.18
4.18
4.18
4.179
4.179
4.179
4.179
4.178
4.178
4.178
4.178
4.178
4.178
4.178
4.178
4.178
4.179
4.179
4.179
4.179
4.179
4.179
4.18
4.18
4.18
4.18
4.181
4.181
4.181
4.182
4.182
4.182
4.183
4.183
4.183
4.184
4.184
4.185
4.185
4.186
4.186
4.187
4.187
4.188
4.188
4.189
4.189
4.19
4.19
4.191
4.192
4.192
4.193
4.194
4.194
4.195
4.196
4.196
4.197
4.198
4.199
4.2
4.2
4.201
4.202
4.203
4.204
4.205
4.206
4.207
4.208
4.209
4.21
4.211
4.212
4.213
4.214
4.216
];
c_p_H2O_l_2 = [0
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
];
i=3;
end
c_p_H2O_l_table = [c_p_H2O_l_1 c_p_H2O_l_2];
c_p_H2O_l_table = dataset({c_p_H2O_l_table 'data','point'});

% interp1(c_p_H2O_l_table.point,c_p_H2O_l_table.data,3)

clear r_v_H2O_1 r_v_H2O_2 t_boil_table1 t_boil_table2 c_p_H2O_l_1 c_p_H2O_l_2
clear i
clear tq_data bsfc_data  C_NOx_eu_data  C_O2_data  fuelflow_data  injsys_qtot_data  mf_exh_data  p_eu_data  Power_data  spd_data  t_amb_data  t_boil_table  t_eu_data  T_turbo_in_data  throttle_data  Torque_data
clear T_turbo_in_points  ef_Tin  ef_perc  c_p_H2O_l_table
clear power_Ne  spdthroTQ  spdTHROtq  SPDthrotq  r_v_H2O_table



