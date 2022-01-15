clear
clc
%**********Basic settings and data loading**************
% make sure you are in the root director (DD13ModelForCustomer)
addpath(genpath('.'));
[CurrentDirectory,~,~]=fileparts(mfilename('fullpath'));
addpath(genpath(CurrentDirectory))
Data_Directory = ['.\Data'];
Data_Directory2 = ['G:' filesep 'Engine_Data'];
if isdir(Data_Directory) 
    collected_data = [Data_Directory filesep 'Collected_Data' filesep];
    DDC_data = [Data_Directory filesep 'DDC_Data' filesep];
else
    error('Invalid data path, please double check location')
end
which_engine=13;
LoadCollected;
initialize_model;
