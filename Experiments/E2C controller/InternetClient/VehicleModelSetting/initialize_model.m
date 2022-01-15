% First we need to specify which model version we're using
model_vers = 1; % For the normal model. This is the 7-state model with varstep solver
% model_vers = 2; % For the above model with a fixed-step solver. This is much slower
% model_vers = 3; % For the 13 state (temps, BGFs added) model with variable step solver

% Now initialize this as appropriate for the model
switch model_vers
    case 1
        if exist('fit_pars','var')
            disp('Fit pars already loaded, skipping load...')
        else
            disp('Loading fit_pars_7s...')
            load fit_pars_7s
            % the new "most recent one is fit_pars_v7_18-Dec-2014
        end
    case 2
        if exist('fit_pars','var')
            disp('Fit pars already loaded, skipping load...')
        else
            disp('Loading fit_pars_7s...')
            load fit_pars_7s
        end
    case 3
        load fit_pars_13s
        q_gain=fit_pars.cl_tune.q_gain;
end

% Specify a leak size, if so desired.
r_im_leak=0;
r_ems_leak=0;
r_eml_leak=0;

% These are the closed-loop tuning parameters
eta_gain=fit_pars.cl_tune.eta_gain;
wg_gain = fit_pars.cl_tune.w_gain;
egr_gain=fit_pars.cl_tune.egr_gain;
comp_gain=fit_pars.cl_tune.wc_gain;

% time constants
if isfield(fit_pars,'taus')
    V_im = fit_pars.taus.V_im;
    V_ems = fit_pars.taus.V_ems;
    V_eml = fit_pars.taus.V_eml;
    V_ex = fit_pars.taus.V_ex;
    J_tc = fit_pars.taus.J_tc;
else
    %V_im=1.54e-4;
    V_im=1.54e-2;
    V_ems=1.1e-3;
    V_eml=8.7e-4;    
    %V_ems=1.1e-4;
    %V_eml=8.7e-5;
    V_ex=9.2e-5;
    J_tc=3.864e-4;
end

% set all the miscellaneous (non-tuning) parameters
setPar;