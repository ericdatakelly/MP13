function [T,P,Xalm,Xpy,Xspss,Xgr] = ...
    SurfaceMisfit_readTable(loopOutputTable)

% SurfaceMisfit_readTable.m
% This function reads the output from the theriak loop table (e.g.,
% 'ThkTab.txt').

%% Read the file
fid = fopen(loopOutputTable,'r');
headerline = fgetl(fid);
headers = textscan(headerline,'%s','Delimiter',',');
data = csvread(loopOutputTable, 1, 0);
fclose(fid);

%% Get the data
T = data(1:end,ismember(headers{1,1}, ':Temperature','legacy'));
P = data(1:end,ismember(headers{1,1}, ':Pressure','legacy'));
Xalm = data(1:end,ismember(headers{1,1}, 'x_alm_[alm]','legacy'));
Xpy = data(1:end,ismember(headers{1,1}, 'x_py_[alm]','legacy'));
Xspss = data(1:end,ismember(headers{1,1}, 'x_spss_[alm]','legacy'));
Xgr = data(1:end,ismember(headers{1,1}, 'x_gr_[alm]','legacy'));

% convert alm zeros to NaN to avoid plotting        
Xalm(Xalm==0)=NaN;

end
