% --------- NOTE:  ----------------------
% This script reads .dat files (filename: filename_INCA) from INCA recordings
% INPUTS: 
% - filename_INCA: file name.
% - dtmin: desired sampling time used for interpolating the data.
% Developed using MATLAB 2016b

% This script is developed based on Cory Hendrickson's, shared with
% Chunan during internship. 
% --------- NOTE END  ----------------------

current_vars = who;
current_vars{end+1} = 'current_vars';

clearvars('-except',current_vars{:})

mdfimport(filename_INCA);

INCA_varnames = who;
% Remove the filename_INCA var. All others are INCA measurements
INCA_varnames(ismember(INCA_varnames,current_vars)) = [];  


INCA_des_names = {''};  % load all INCA vars

% Move all INCA variables starting with INCA_des_names into structure
% and generate time_min and time_max
INCAoutputs = {};
tmin = NaN;  tmax = NaN;
for ct = 1:numel(INCA_varnames)
    if startsWith(INCA_varnames{ct},'time') || any(startsWith(INCA_varnames{ct},INCA_des_names))
        % Save the variable to structure if 
        % - it is a time variable, or 
        % - it is inside desired names/prefix
        INCAoutputs.(INCA_varnames{ct}) = evalin('base', INCA_varnames{ct});
        
        % Get time_min and time_max for all variables
        if startsWith(INCA_varnames{ct},'time')
            tmin = min(tmin, INCAoutputs.(INCA_varnames{ct})(1));
            tmax = max(tmax, INCAoutputs.(INCA_varnames{ct})(end));
        end
    end
    
    clearvars(INCA_varnames{ct})
    % dtmin
end

tcom = (tmin:dtmin:tmax)' - tmin;             % Common time vector
tmaxShift = tmax-tmin;

% fnames: cell array of all variable names (not including time arrays)
varnmload = fieldnames(INCAoutputs);
varnmload(startsWith(varnmload,'time')) = [];
INCA_data = {};
INCA_data.Time = tcom;
count=0;
% Find indices of each variable to map to the common time vector
for mm = 1:length(varnmload)
    
    % varname in field: varnmload{mm,1}
    
    ind_separate = find(ismember(varnmload{mm,1},'_'));
    ind_separate = ind_separate(end);
    ind_time_str = varnmload{mm,1}(ind_separate+1:end);
    ttmp = INCAoutputs.(['time','_',ind_time_str]) - tmin;  % Original time vector of variable
    % Special case of 0 time
    if max(ttmp)==0 || length(ttmp)<=2
        % INCAoutputs = rmfield(INCAoutputs, varnmload{mm,1});
        count = count + 1;
        continue
    end    
    % Special case of repeated indices at 0s
    while ttmp(2)==0
        ttmp = ttmp(2:end);
        INCAoutputs.(varnmload{mm,1}) = INCAoutputs.(varnmload{mm,1})(2:end);
    end
    idxtmp = floor(interp1(ttmp,(1:length(ttmp))',tcom));        % Indices for common time vector

    % Clean up NaN indices. The original time vector will not span the
    % entire common time vector so there will be NaN indices to remove.
    % Front NaN from common time starting before variable time

    idxtmp(1:ceil(ttmp(1)/dtmin)) =  idxtmp(ceil(ttmp(1)/dtmin)+1);
    % Back NaN from common time ending after variable time
    idxshort = floor(max((tmaxShift-ttmp(end))/dtmin,0));        
    idxtmp(end-idxshort:end) = idxtmp(end-idxshort-1);

    
    INCA_data.(varnmload{mm,1}(1:ind_separate-1)) = INCAoutputs.(varnmload{mm,1})(idxtmp);  
    
end

if count + numel(fieldnames(INCA_data)) - 1 == numel(varnmload)
    current_vars{end+1} = 'INCA_data';
    clearvars('-except',current_vars{:})
    disp(' ---------- INCA data processing finished! ------- ');
else
    disp(' ---------- ERROR! Some INCA data lost when processing! ------- ');
end
