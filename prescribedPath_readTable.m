function [Xalm,Xpy,Xspss,Xgr,mgNumModeled,V_Grt,headers,data] = ...
    prescribedPath_readTable(loopOutputTable,therinName)

% TheriakPTpath_readTable.m
% This function reads the output from the theriak loop table (e.g.,
% 'ThkTab.txt') during the run.

%% Check that the program is working
fid = fopen(loopOutputTable,'r'); 
    % If the loop table was not created, the previous 
    % call to theriak probably failed.  The following 
    % 'if' statement should help the user find the mistake.
if fid < 0
    copyfile('therin_initial.txt',therinName);
    errorMess1 = strcat(loopOutputTable,' not found.  This probably means that');
    errorMess2 = 'the call to theriak failed.';
    errorMess3 = 'Check the params file for the correct path and dataset.';
    errorMess4 = 'Intitial therin file has been restored.';
    error('\n%s\n%s\n%s\n%s\n\n',...
        errorMess1,errorMess2,errorMess3,errorMess4)
else
    headerline = fgetl(fid);
    headers = textscan(headerline,'%s','Delimiter',',');
    data = csvread(loopOutputTable, 1, 0);
end
fclose(fid);

%% Get the data
% get all the garnet values
% this assumes there is always some alm, py component in garnet
% tests for cases where there is no spss or gr
% Some code cleaned up for newer versions of Matlab
x_alm_alm = data(end,ismember(headers{1,1}, 'x_alm_[alm]','legacy'));
x_py_alm = data(end,ismember(headers{1,1}, 'x_py_[alm]','legacy'));
x_spss_alm = data(end,ismember(headers{1,1}, 'x_spss_[alm]','legacy'));
x_gr_alm = data(end,ismember(headers{1,1}, 'x_gr_[alm]','legacy'));
mgNum_alm = data(end,ismember(headers{1,1}, 'Mg#_[alm]','legacy'));
V_alm = data(end,ismember(headers{1,1}, 'V_[alm]','legacy'));
if isempty(x_spss_alm)
    x_spss_alm = 0;
end
if isempty(x_gr_alm)
    x_gr_alm = 0;
end

x_alm_py = data(end,ismember(headers{1,1}, 'x_alm_[py]','legacy'));
x_py_py = data(end,ismember(headers{1,1}, 'x_py_[py]','legacy'));
x_spss_py = data(end,ismember(headers{1,1}, 'x_spss_[py]','legacy'));
x_gr_py = data(end,ismember(headers{1,1}, 'x_gr_[py]','legacy'));
mgNum_py = data(end,ismember(headers{1,1}, 'Mg#_[py]','legacy'));
V_py = data(end,ismember(headers{1,1}, 'V_[py]','legacy'));
if isempty(x_spss_py)
    x_spss_py = 0;
end
if isempty(x_gr_py)
    x_gr_py = 0;
end

x_alm_spss = data(end,ismember(headers{1,1}, 'x_alm_[spss]','legacy'));
x_py_spss = data(end,ismember(headers{1,1}, 'x_py_[spss]','legacy'));
x_spss_spss = data(end,ismember(headers{1,1}, 'x_spss_[spss]','legacy'));
x_gr_spss = data(end,ismember(headers{1,1}, 'x_gr_[spss]','legacy'));
mgNum_spss = data(end,ismember(headers{1,1}, 'Mg#_[spss]','legacy'));
V_spss = data(end,ismember(headers{1,1}, 'V_[spss]','legacy'));
if isempty(x_spss_spss)
    x_spss_spss = 0;
end
if isempty(x_gr_spss)
    x_gr_spss = 0;
end

x_alm_gr = data(end,ismember(headers{1,1}, 'x_alm_[gr]','legacy'));
x_py_gr = data(end,ismember(headers{1,1}, 'x_py_[gr]','legacy'));
x_spss_gr = data(end,ismember(headers{1,1}, 'x_spss_[gr]','legacy'));
x_gr_gr = data(end,ismember(headers{1,1}, 'x_gr_[gr]','legacy'));
mgNum_gr = data(end,ismember(headers{1,1}, 'Mg#_[gr]','legacy'));
V_gr = data(end,ismember(headers{1,1}, 'V_[gr]','legacy'));
if isempty(x_spss_gr)
    x_spss_gr = 0;
end
if isempty(x_gr_gr)
    x_gr_gr = 0;
end

if isempty(x_alm_alm)
    x_alm_alm = 0;
    x_py_alm = 0;
    x_spss_alm = 0;
    x_gr_alm = 0;
    mgNum_alm = 0;
    V_alm = 0;
end
if isempty(x_alm_py)
    x_alm_py = 0;
    x_py_py = 0;
    x_spss_py = 0;
    x_gr_py = 0;
    mgNum_py = 0;
    V_py = 0;
end
if isempty(x_alm_spss)
    x_alm_spss = 0;
    x_py_spss = 0;
    x_spss_spss = 0;
    x_gr_spss = 0;
    mgNum_spss = 0;
    V_spss = 0;
end
if isempty(x_alm_gr)
    x_alm_gr = 0;
    x_py_gr = 0;
    x_spss_gr = 0;
    x_gr_gr = 0;
    mgNum_gr = 0;
    V_gr = 0;
end

%define garnet end-members
Xalm = x_alm_alm+x_alm_py+x_alm_spss+x_alm_gr;
Xpy = x_py_alm+x_py_py+x_py_spss+x_py_gr;
Xspss = x_spss_alm+x_spss_py+x_spss_spss+x_spss_gr;
Xgr = x_gr_alm+x_gr_py+x_gr_spss+x_gr_gr;
mgNumModeled = mgNum_alm+mgNum_py+mgNum_spss+mgNum_gr;
V_Grt = V_alm + V_py + V_spss + V_gr;
      
% convert alm zeros to large number        
Xalm(Xalm==0)=1000;

end
