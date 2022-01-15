%% Rename files:
clear all

for iName = 1:numel(names)
    load(names{iName})
    origName = sprintf('%s',names{iName});
    newName  = sprintf('Test%d.mat', MD.nTest);
    movefile(origName, newName);
end


%%
iName = 8
names = {'logSolver','packetsClient_Solver','packetsServer_Solver'};
% names = {'logServer','logClient','packetsClient_server','packetsServer_server','packetsClient_client','packetsServer_client'};

for i = 1:3
    name = names{i}
    origName = sprintf('%s.txt',name)
    newName  = sprintf('Test%d_%s.txt', iName, name)
    movefile(origName, newName);
end
