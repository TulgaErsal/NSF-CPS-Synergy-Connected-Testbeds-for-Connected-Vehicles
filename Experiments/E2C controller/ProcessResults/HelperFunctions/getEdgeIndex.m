function [out] = getEdgeIndex(data, edgetype, initialcondition)
if nargin == 2
    % edgetype: 'rising','falling'
    if  strcmp('rising',edgetype)
        out = find(diff([data(1)+1;data])>0);

    elseif strcmp('falling',edgetype)
        out = find(diff([data(1)-1;data])<0);
    else
        disp('------ ERROR: getEdgeIndex. edgetype input is wrong!!!! ------')
        out = [];
    end
elseif nargin == 3
    if  strcmp('rising',edgetype)
        out = find(diff([initialcondition;data])>0);

    elseif strcmp('falling',edgetype)
        out = find(diff([initialcondition;data])<0);
    else
        disp('------ ERROR: getEdgeIndex. edgetype input is wrong!!!! ------')
        out = [];
    end
end
