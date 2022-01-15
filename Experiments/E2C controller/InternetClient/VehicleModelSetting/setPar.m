%% Header
%!Name:          setPar.m
%!Project:       DDC: DD13
%!Author:        Erik Hellström
%!Version:       1.0
%!Date:          May 23, 2013
%!Description:   {Generates the parameter struct with all of the model 
%                 simulation parameters. Many of the parameters here are
%                 now obsolete, but don't interfere with anything.}

%% Body

%
% Initial conditions
%
clear par
global par
par.init.im.P       = 2.9e5; % (Pa)
par.init.im.X       = 0.35;  % (-)
par.init.em.small.P = 3.4e5; % (Pa)
par.init.em.small.X = 0.9;   % (Pa)
par.init.em.large.P  = 3.4e5; % (Pa)
par.init.em.large.X  = 0.9;   % (Pa)
par.init.tc.om      = 1e4;   % (rad/s)
par.init.exh.P      = 1.135; % (Pa)
%
% Fluid properties
%
%
% Air
par.gas.air.R = 287;      % (J/kg/K)
par.gas.air.gamma = 1.40; % (-)
par.gas.air.cp = par.gas.air.R*par.gas.air.gamma/(par.gas.air.gamma-1); % (J/kg/K)
%
% Exhaust
par.gas.exh.R = 286;      % (J/kg/K)
par.gas.exh.gamma = 1.27; % (-)
par.gas.exh.cp = par.gas.exh.R*par.gas.exh.gamma/(par.gas.exh.gamma-1); % (J/kg/K)
%
% In-cylinder gas
par.gas.cyl.gamma = 1.35; % (-)
%
% Fuel
par.fuel.qlhv = 42.7e6;   % (J/kg)
par.fuel.AFs  = 14.5;     % (-)

%
% Ambient
%
par.amb.P  = 0.993e5; % (Pa)
par.amb.T  = 298;     % (K)


%
% Engine geometry
%
par.geom.CR = 17.3;       % compression ratio (-)
par.geom.a  = 0.5*156e-3; % crank radius and half the stroke (m)
par.geom.B  = 132e-3;     % bore (m)
par.geom.l  = 268e-3;     % connecting rod length (m)
par.geom.ncyl = 6;        % no. of cylinders
% Precomputed fields
par.geom.Vd = pi*(par.geom.B/2)^2*(2*par.geom.a); % volume (m^3/cylinder)
par.geom.VD = par.geom.Vd*par.geom.ncyl;          % total volume (m^3)
par.geom.Vc = par.geom.Vd/(par.geom.CR-1);        % clearance volume (m^3)

%
% Intake manifold
%
%par.im.V = 0.015; % (m^3)
par.im.T = 313.54; % (K)
%
% Exhaust manifolds
%
par.em.small.V = 0.01;  % (m^3)
par.em.large.V  = 0.012; % (m^3)

%
% Exhaust System (a guess for now)
%
par.exh.V = 0.007;  %   (m^3)


par.ic.T_cool_offset=0;
par.ec.T_cool = 362;
%
% EGR
%
par.egr.psi  = [-0.25526967633406672 0.021541576205203 0.448440895909732];
par.egr.area = [-0.80752299568604158 1.538926560450818 0.3532433781469817];
par.egr.cooler.T = 97.2+273.15;
par.egr.coolant.T = 273.15+38.78;
%
% Cylinder
%
% Torque
par.cyl.etac = 0.729255154879624;
par.cyl.fric = [...
    0.88780170080410414 ...
    -1.9963781159967444 ...
    1.8230200401376506];

%Torque paramerers, added by RSL

par.IMEP_fit=[...
    0.0918693397006871...
    7.69437841853186e-06...
    -0.000281447947048086];


par.FRTQ_fit=[...
    9.86808117858135 ...
    -0.270939188836854 ...
    -0.774365614480246 ...
    -29.6718255124596 ...
    5.95982499571539 ...
    0.000205142862861543 ...
    0.0200041871606669 ...
    -1139.71902287145 ...
    -0.225804792773361 ...
    -5.53870547480757e-08 ...
    -0.000119434846150306];

par.FRTQ_fit_new=[...
    9.82786397808720...
    -0.259060990676280 ...
    -0.460793032253126 ...
    0.000216760674892844 ...
    -0.0228688597374106 ...
    -6.75338929385302e-08 ...
    9.42460509816160e-05 ...
    -0.2558 ...
    6.718...
    -37.22];



% Flow
par.cyl.etav = [...
    -0.088840598884320568 ...
    0.011435345623693985 ...
    -0.00034767216693082565 ...
    0.0050466668442875505 ...
    -5.3316872745733654E-6];
%%***Added by RSL***********
par.cyl.etav_rsl = [...
    7.13419959369145 ...
    -5.79054100492100 ...
    4.59103231189264 ...
    -1.16381368971454 ...
    0.00832027151714558 ...
    -0.429751039829503 ...
    -9.42330308961665e-07 ...
    0.00756299359532151];

% Exhaust temperature
par.cyl.Texlim = [400 inf];
par.cyl.Tex = [...
    1316.3097365426079 ...
    -542.59085157271511 ...
    8190.7605996226948 ...
    -3.4714079646968483];

% Exhaust temperature RSL

par.T_eng = [...
    482.144713949273 ...
    1.03719445692724 ...
    6.11680971944903 ...
    -103.346293170191 ...
    8.73908314493942 ...
    -2.75245229755125 ...
    -2.84601704418425 ...
    0.0526923487211971];



% Turbo charger
%
par.tc.inert = 3.864e-4;        % (kgm^2)
%par.tc.inert = 1e-5;          % (kgm^2)
par.tc.fric  = 0;             % (Nms/rad)
par.tc.omlim = [0.1 1.5]*1e4; % (rad/s)
%
% Compressor
par.tc.comp.D = 95e-3;      % (m)
par.tc.comp.Tref = 298;     % (K)
par.tc.comp.Pref = 0.993e5; % (Pa)
% Model constraints
par.tc.comp.Wclim  = [0.01 0.60]; % (kg/s)
par.tc.comp.etalim = [0.2 0.9];   % (-)
% Flow
par.tc.comp.flow = [...
    0.24212731958416028 ...
    -0.059991894059697508 ...
    0.0017815403181418651 ...
    -1.9488130675309459  ...
    0.93491829006169624 ...
    -0.25670458183593331 ...
    0.17928748663826566 ...
    -0.015962229342363871  ...
    -0.0054274011722823751];
% Efficiency
par.tc.comp.eta = [...
    -204.00969335913106 ...
    69.0181284716354 ...
    2.673776954723635 ...
    30478.0001245447  ...
    21067.000162089087 ...
    3622.9980090379108 ...
    1.2717645310892074 ...
    -0.97907194625132055  ...
    3.1569652455161625];
%Added By RSL*************
par.tc.comp.SD_Crt=[4842,6526,7789,8842,9684,10315,10947,11789];

%Added By RSL*************
par.tc.com.CF_Flow=[0.152575279390341,0.121491790480191,0.157285086373632,0.184942285063992,0.121857072472815,0.237381055210604,0.562573966257149,0.627257935120527;...
    -0.396274397775360,-0.284462320820379,-0.419817244255301,-0.541587733368187,-0.309498312219266,-0.745506962963428,-1.89430109795702,-2.20942621301231;...
    0.513012555920358,0.397163772210401,0.572541156551108,0.746970475801979,0.466548943274939,1.00246116238490,2.34133333633821,2.80306600673217;...
    -0.236589549915015,-0.198551665414996,-0.272074775798866,-0.350303929815972,-0.238295901488417,-0.453451315863109,-0.969462592677486,-1.18441043100596];

%Added By RSL*************
par.tc.com.CF_Eta=[1.26954208451744,0.826770599487823,1.13432997659280,1.24601687658652,0.722487708084503,1.96384656758144,5.47712853274776,5.32306149945274;...
    -4.05712741109272,-2.43042822399823,-3.57765400024062,-4.14162517809189,-2.07999206659551,-6.43779070014201,-18.5411028045333,-18.6433185044438;...
    6.70944128676312,4.81514084342471,6.17273088713478,6.96015272397476,4.24742683431922,9.24663064720464,23.0272319106067,23.8750826766560;...
    -3.18969048043914,-2.45443465588720,-2.97217075757470,-3.30947881667928,-2.14770466041114,-4.03895970917878,-9.24048467799810,-9.87017373110824];

par.tc.com.CF_Flow2=[-0.0265381352701279,0.900214306307257];

par.tc.com.CF_Flow3=[-0.0044,1.0869];

% Turbine
par.tc.turb.D = 87.37e-3; % (m)
par.tc.turb.Tref = 873;   % (K)
% Model constraints
par.tc.turb.Wclim   = [.05 5]; % (kg sqrt(K) / s bar)
par.tc.turb.etalim  = [0.1 0.9]; % (-)
%par.tc.turb.smarlim = [0.0 0.8]; % (-)
par.tc.turb.smarlim = [.2 2]; % (-)
% Efficiency
par.tc.turb.eta = [-1.9302777790004726 2.47029439814518 -0.019258761167664062];

%Tuned for variable T_im = 0.9135
%Tuned for const    T_im = 0.9083
par.tc.turb.etagain = 0.9083;
% Mach number ratio
par.tc.turb.smar = [...
    10.243916948735984 ...
    -16.283410990545473 ...
    -3.5427109451624514 ...
    10.081178168024294  ...
    -0.0031708737558325648 ...
    0.0024863238381408561 ...
    -0.0021356195941063072  ...
    0.0031188389352239171];
% Small scroll flow
par.tc.turb.small.flow = [...
    0.14352656222773688 ...
    2.4584264974877055 ...
    1.8656277784379598 ...
    -1.7212020331496252];
% Large scroll flow
par.tc.turb.large.flow = [...
    3.4879180672991121 ...
    -2.2454226906081405 ...
    1.9755712657140805 ...
    -0.30166720935325686];
%
% Wastegate
%Ps is the spring pressure of the valve spring
%k is a proportionality constant that relates the areaxlength of the actuator to
%the valve, : Ps=k(u_wg*P_l-P_a)+P_em-P_ex
%P_l=90 psi, P_a=1 bar
%par.tc.wg.Ps     =   487.8058822; % [kPa]
%par.tc.wg.K      =   1.413508131; % []

%Tuned for variable T_im = 0.9096
%Tuned for const    T_im = 0.8830
par.tc.wg.gain_tune=0.8830;
par.tc.wg.Ps = 4.2302*100;                        % "Spring pressure" (kPa)
par.tc.wg.K  = 1.2591;                        % Waste gate constant (-)
par.tc.wg.Pl = 90*6.8948;% + par.amb.P*1e-3; % Line pressure (kPa)
par.tc.wg.R  = 286;                           % [J/(kg*K)]
fudge=1;
%par.tc.wg.Area_coeff=[1.2052e-3, 2.9395,  -0.2893];
%par.tc.wg.A  = 6.5917e-04;                    % Effective area (m^2)
%par.tc.wg.Flow_coeff=[-13.5120535913522,-0.0508180271992412,0.826192371835650,0.0669614553436067];
%par.tc.wg.Flow_coeff=[-12.3351895785453,-0.0740655449823687,0.00350866561989470,0.509502354029517];
%par.tc.wg.Area_coeff =[5.58818065382390,3.49192647320867,0.343051737025727,10.4731087813824];
par.tc.wg.Area_coeff =[1.80447976503466,1.10928655799383,0.368582086983677,10.5542661849286];
% Exhaust System 
%
par.exh.ori.c       = 1.01*1.1220e10;
par.exh.ori.P_lin   =100;%2.2e3; %Pa

% Gsd Properties and Chemistry
par.AFRs= 14.5;
par.y       =   (12.011*par.AFRs -34.56*4)/(34.56-1.008*par.AFRs); %[]
par.a       =   12; %Based on ~C12H23 average
par.b       =   par.y*par.a;
par.amount_prod    =   par.a*(1+3.773)+par.b*(.5+.25*3.773);
par.gases      =   struct;
par.gases.cp_air   =   1005;   %[J/(kg*K)]
par.gases.cp_fuel  =   1750;   %[J/(kg*K)]--check on this
par.gases.molar_mass_air   =   28.97;  %[g/mol]
par.gases.molar_mass_fuel  =   233;    %[g/mol] (according to EPA)
par.gases.molar_mass_CO2   =   44.01;  %[g/mol]
par.gases.molar_mass_H2O   =   18.02;  %[g/mol]
par.gases.molar_mass_N2    =   28.02;  %[g/mol]

%Gas Constant
par.gases.R       =   287;        %[J/(kg*K)]
par.gases.R_N2    =   287;
par.gases.R_CO2   =   189;
par.gases.R_H2O   =   462;
par.gases.R_O2    =   260;

par.gases.cp_CO2   =   846;   %[J/(kg*K)]
par.gases.cp_H2O   =   1864;  %[J/(kg*K)]
par.gases.cp_N2    =   1040;  %[J/(kg*K)]

temp=par.gases;
par.gases.molar_mass_prod  =   ...
    (temp.molar_mass_CO2*par.a + ...
    temp.molar_mass_H2O*par.b/2 + ...
    temp.molar_mass_N2*3.773*(par.a+par.b/4))...
    /par.amount_prod;    %[g/mol]

par.gases.cp_prod    =   (par.a*par.gases.cp_CO2+...
                            par.b/2*par.gases.cp_H2O+...
                            (par.a+par.b/4)*3.773*par.gases.cp_N2)/par.amount_prod; % [J/(kg*K)]
                        
par.gases.R_prod     =   (par.a*par.gases.R_CO2+...
                            par.b/2*par.gases.R_H2O+...
                            (par.a+par.b/4)*3.773*par.gases.R_N2)/par.amount_prod; % [J/(kg*K)]
                        
%Parameters for Sensitivity analysis. Added by Rasoul
par.Sens.C_egr=1;
par.Sens.C_WG=1;
par.Sens.C_EttaTurbine=1;
par.Sens.C_compflow=1;
par.Sens.C_ExhFlow=1;

