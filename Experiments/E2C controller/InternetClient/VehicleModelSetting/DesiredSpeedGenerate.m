clear all
clc

%% Acc
N = 301;
Speed = [];
Speed_List = linspace(0,60,N);
Time_Index = [];


for i = 1:1:N
    
    Speed = [Speed Speed_List(i)*ones(1,150)];
    Time_Index = [Time_Index linspace(150*(i-1)+1,150*i,150)];
    
end

Speed = Speed';
Time_Index = Time_Index';
Results = [Time_Index Speed];


% %% Dec
% N = 301;
% Speed = [];
% Speed_List = linspace(60,0,N);
% Time_Index = [];
% 
% 
% for i = 1:1:N
%     
%     Speed = [Speed Speed_List(i)*ones(1,150)];
%     Time_Index = [Time_Index 100+linspace(150*(i-1)+1,150*i,150)];
%     
% end
% 
% Speed = Speed';
% Time_Index = Time_Index';
% Results = [Time_Index Speed];
% Results = [[[1:100]' 60*ones(100,1)]; Results];