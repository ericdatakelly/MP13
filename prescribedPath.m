% prescribedPath.m
% This program calculates rock conditions along a (non-linear) path and
% fractionates garnet at each step.

% Enter rock name, input datafile name, therin name, and P-T points.

fprintf('\n\nRunning...\n')

clear variables

%% Input
rockName = 'PM3';
inputDataFile = 'PM3Profile.txt';
therinName = 'PM3_therin.txt';

% P-T path
PTpath = [
543.016	4593.459
543.154	4593.832
543.170	4603.954
543.401	4591.553
543.819	4588.841
543.940	4590.007
543.977	4565.892
544.432	4560.825
544.733	4553.831
544.740	4547.540
544.748	4539.964
545.014	4515.775
545.527	4507.874
545.999	4503.655
546.488	4484.419
547.212	4490.379
548.415	4502.890
548.917	4492.203
549.592	4478.783
550.228	4461.055
550.787	4434.418
551.353	4408.720
551.843	4392.436
552.499	4347.563
553.154	4331.803
553.956	4306.392
554.503	4263.746
555.259	4243.068
555.940	4207.078
556.620	4171.088
557.187	4136.088
557.687	4101.088
558.137	4066.088
558.537	4031.088
558.887	3996.088
559.212	3961.088
559.512	3926.088
559.787	3891.088
560.037	3856.088
560.262	3821.088
560.462	3786.088
];

%% Make some variables
theriakDominoPath = 'C:\Users\Eric\TheriakDomino\Programs\';
datasetName = 'tcdb55c2d_PMb.txt';
loopOutputTable = 'ThkTab.txt';
allCompsForTDName = strcat(rockName,'_allCompsForTD.txt');
nodeOutputName = strcat(rockName,'_allInfoFromNode.txt');

%% Write batch and input files for theriak commands
fid = fopen('prescribedPath.bat','wt');
fprintf(fid,'set THERDOM=%s\n',theriakDominoPath);
fprintf(fid,'set PATH=%%THERDOM%%;%%path%%\ntheriak < prescribedPathInput.dat\n');
fclose(fid);

fid = fopen('prescribedPathInput.dat','wt');
fprintf(fid,'%s\nprescribedPathCommands.txt\nInfo.txt\n',datasetName);
fclose(fid);

%% Read rock conditions

% Get initial composition from therin file
if exist(therinName, 'file') == 2
    fid = fopen(therinName);
    icomp = textscan(fid,'%s',1,'delimiter','\n', 'headerlines', 42);
    fclose(fid);
    icomp = regexprep(icomp{1,1}{1,1},'[()]',' ');
    icomp = textscan(icomp,'%*f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %*s');
    node(1,1).blk_SI = icomp{1,1};
    node(1,1).blk_AL = icomp{1,2};
    node(1,1).blk_FE = icomp{1,3};
    node(1,1).blk_MG = icomp{1,4};
    node(1,1).blk_MN = icomp{1,5};
    node(1,1).blk_CA = icomp{1,6};
    node(1,1).blk_NA = icomp{1,7};
    node(1,1).blk_K = icomp{1,8};
    node(1,1).blk_TI = icomp{1,9};
    node(1,1).blk_H = icomp{1,10};
else
    errMess1 = 'Bulk composition file ';
    errMess2 = ' seems to be missing.';
    errMess3 = 'Aborting...';
    error('\n%s%s%s\n%s\n',errMess1,userTherinName,errMess2,errMess3)
end

% Get the garnet zoning data and determine the number of steps in the profile
if exist(inputDataFile, 'file') == 2
    garnetcomp = importdata(inputDataFile);
    mgNumMeasured = garnetcomp.data(1,3)./...
        (garnetcomp.data(1,3)+garnetcomp.data(1,2));
else
    errMess1 = 'Garnet zoning file ';
    errMess2 = ' seems to be missing.';
    errMess3 = 'Aborting...';
    error('\n%s%s%s\n%s\n',errMess1,inputDataFile,errMess2,errMess3)
end

% Check length of profile and compare with PT Path (must be same)
if length(garnetcomp.data(:,1)) ~= length(PTpath(:,1))
    errMess1 = 'Garnet zoning file must be same length as PT path.';
    errMess2 = 'Aborting...';
    error('\n%s\n%s\n',errMess1,errMess2)
end

% Save therin
if exist('therin.txt', 'file') == 2
    copyfile('therin.txt','therin_initial.txt');
    therinExist = 1;
else
    therinExist = 0;
end

%% Calculate the conditions at the starting point
    % For the first step, calculate the conditions and record them to the
    % node.  On subsequent steps, fractionation will occur because new PT
    % conditions will be given.
        T1 = PTpath(1,1);
        P1 = PTpath(1,2);
        
        % write therin.txt with new composition
        fid = fopen('therin.txt', 'w+');
        fprintf(fid, '    000     0000\n0   SI(%.4f)AL(%.4f)FE(%.4f)MG(%.4f)MN(%.4f)CA(%.4f)NA(%.4f)K(%.4f)TI(%.4f)H(%.0f)O(?)  *\n',...
            icomp{1,1},...
            icomp{1,2},...
            icomp{1,3},...
            icomp{1,4},...
            icomp{1,5},...
            icomp{1,6},...
            icomp{1,7},...
            icomp{1,8},...
            icomp{1,9},...
            icomp{1,10});
        fclose(fid);
    
    % Write first set of commands to determine the conditions at the
    % starting P-T (no fractionation, one P-T point)
    fid = fopen('prescribedPathCommands.txt', 'w+');
    fprintf(fid, 'REMOVE  GARNET  0\nTP  %f  %f\nTP  %f  %f  1\n',...
        T1, P1, T1, P1);
    fclose(fid);
    
    %run theriak
    [~,~] = system('prescribedPath.bat'); % Windows or Unix(?) compatible
    
    % Read the new values produced from the search
    [Xalm,Xpy,Xspss,Xgr,mgNumModeled,V_Grt,headers,data] = ...
        prescribedPath_readTable(loopOutputTable,therinName);
    
    % record information in node structure
    node(1,1).T =      data(end,ismember(headers{1,1}, ':Temperature','legacy'));
    node(1,1).P =      data(end,ismember(headers{1,1}, ':Pressure','legacy'));
    node(1,1).blk_AL = data(end,ismember(headers{1,1}, 'blk_AL','legacy'));
    node(1,1).blk_SI = data(end,ismember(headers{1,1}, 'blk_SI','legacy'));
    node(1,1).blk_FE = data(end,ismember(headers{1,1}, 'blk_FE','legacy'));
    node(1,1).blk_MG = data(end,ismember(headers{1,1}, 'blk_MG','legacy'));
    node(1,1).blk_MN = data(end,ismember(headers{1,1}, 'blk_MN','legacy'));
    node(1,1).blk_CA = data(end,ismember(headers{1,1}, 'blk_CA','legacy'));
    node(1,1).blk_NA = data(end,ismember(headers{1,1}, 'blk_NA','legacy'));
    node(1,1).blk_K =  data(end,ismember(headers{1,1}, 'blk_K','legacy'));
    node(1,1).blk_TI = data(end,ismember(headers{1,1}, 'blk_TI','legacy'));
    node(1,1).blk_H =  data(end,ismember(headers{1,1}, 'blk_H','legacy'));
    node(1,1).Xalm =   Xalm;
    node(1,1).Xpy =    Xpy;
    node(1,1).Xspss =  Xspss;
    node(1,1).Xgr =    Xgr;
    node(1,1).mgNumMeasured = mgNumMeasured;
    node(1,1).mgNumModeled = mgNumModeled;
    node(1,1).feNumMeasured = 1 - mgNumMeasured;
    node(1,1).feNumModeled = 1 - mgNumModeled;
    node(1,1).v_grt = V_Grt;

%% Calculate the conditions at the remaining points

num_points = length(PTpath(:,1));

for n = 2:num_points
    fprintf('Step: %i of %i\n',n,num_points)
    
        T1 = PTpath(n-1,1);
        P1 = PTpath(n-1,2);
        T2 = PTpath(n,1);
        P2 = PTpath(n,2);

    % write therin.txt with current composition
    fid = fopen('therin.txt', 'w+');
    fprintf(fid, '    000     0000\n0   SI(%.4f)AL(%.4f)FE(%.4f)MG(%.4f)MN(%.4f)CA(%.4f)NA(%.4f)K(%.4f)TI(%.4f)H(%.0f)O(?)  *\n',...
        node(1,n-1).blk_SI,...
        node(1,n-1).blk_AL,...
        node(1,n-1).blk_FE,...
        node(1,n-1).blk_MG,...
        node(1,n-1).blk_MN,...
        node(1,n-1).blk_CA,...
        node(1,n-1).blk_NA,...
        node(1,n-1).blk_K,...
        node(1,n-1).blk_TI,...
        node(1,n-1).blk_H);
    fclose(fid);
    
    fid = fopen('prescribedPathCommands.txt', 'w+');
    fprintf(fid, 'REMOVE  GARNET  100\nTP  %f  %f\nTP  %f  %f  2\n',...
        T1, P1, T2, P2);
    fclose(fid);
    
    %run theriak
    [~,~] = system('prescribedPath.bat'); % Windows or Unix(?) compatible
    
    % Read the new values produced from the search
    [Xalm,Xpy,Xspss,Xgr,mgNumModeled,V_Grt,headers,data] = ...
        prescribedPath_readTable(loopOutputTable,therinName);
    
    % Calculate the Grt Mg# from the measured data
    mgNumMeasured = garnetcomp.data(n,3)./...
        (garnetcomp.data(n,3)+garnetcomp.data(n,2));
   
    % record information in node structure
    node(1,n).T =      data(end,ismember(headers{1,1}, ':Temperature','legacy'));
    node(1,n).P =      data(end,ismember(headers{1,1}, ':Pressure','legacy'));
    node(1,n).blk_AL = data(end,ismember(headers{1,1}, 'blk_AL','legacy'));
    node(1,n).blk_SI = data(end,ismember(headers{1,1}, 'blk_SI','legacy'));
    node(1,n).blk_FE = data(end,ismember(headers{1,1}, 'blk_FE','legacy'));
    node(1,n).blk_MG = data(end,ismember(headers{1,1}, 'blk_MG','legacy'));
    node(1,n).blk_MN = data(end,ismember(headers{1,1}, 'blk_MN','legacy'));
    node(1,n).blk_CA = data(end,ismember(headers{1,1}, 'blk_CA','legacy'));
    node(1,n).blk_NA = data(end,ismember(headers{1,1}, 'blk_NA','legacy'));
    node(1,n).blk_K =  data(end,ismember(headers{1,1}, 'blk_K','legacy'));
    node(1,n).blk_TI = data(end,ismember(headers{1,1}, 'blk_TI','legacy'));
    node(1,n).blk_H =  data(end,ismember(headers{1,1}, 'blk_H','legacy'));
    node(1,n).Xalm =   Xalm;
    node(1,n).Xpy =    Xpy;
    node(1,n).Xspss =  Xspss;
    node(1,n).Xgr =    Xgr;
    node(1,n).mgNumMeasured = mgNumMeasured;
    node(1,n).mgNumModeled = mgNumModeled;
    node(1,n).feNumMeasured = 1 - mgNumMeasured;
    node(1,n).feNumModeled = 1 - mgNumModeled;
    node(1,n).v_grt = V_Grt;
    
end

%% Write file with all compositions formatted for Theriak-Domino

fid = fopen(allCompsForTDName, 'w+');
for i = 1:num_points
    fprintf(fid,'1   SI(%.4f)AL(%.4f)FE(%.4f)MG(%.4f)MN(%.4f)CA(%.4f)NA(%.4f)K(%.4f)TI(%.4f)H(%.0f)O(?)  *   %i\n',...
        node(1,i).blk_SI,...
        node(1,i).blk_AL,...
        node(1,i).blk_FE,...
        node(1,i).blk_MG,...
        node(1,i).blk_MN,...
        node(1,i).blk_CA,...
        node(1,i).blk_NA,...
        node(1,i).blk_K,...
        node(1,i).blk_TI,...
        node(1,i).blk_H,...
        i);
end
fclose(fid);

%% Write file with all node structure information

fid = fopen(nodeOutputName, 'w+');
fprintf(fid,'No.\tT(C)\tP(bars)\tmod_Xalm\tmod_Xprp\tmod_Xsps\tmod_Xgrs\tmod_Mg#\tmod_Fe#\tmod_V-Grt\tobs_Xalm\tobs_Xprp\tobs_Xsps\tobs_Xgrs\tobs_Mg#\tobs_Fe#\tblk_Si\tblk_Al\tblk_Fe\tblk_Mg\tblk_Mn\tblk_Ca\tblk_Na\tblk_K\tblk_Ti\tblk_H\n');
for i = 1:num_points
    fprintf(fid,'%i\t%.2f\t%.2f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
        i,...
        node(1,i).T,...
        node(1,i).P,...
        node(1,i).Xalm,...
        node(1,i).Xpy,...
        node(1,i).Xspss,...
        node(1,i).Xgr,...
        node(1,i).mgNumModeled,...
        node(1,i).feNumModeled,...
        node(1,i).v_grt,...
        garnetcomp.data(i,2),...
        garnetcomp.data(i,3),...
        garnetcomp.data(i,4),...
        garnetcomp.data(i,5),...
        node(1,i).mgNumMeasured,...
        node(1,i).feNumMeasured,...
        node(1,i).blk_SI,...
        node(1,i).blk_AL,...
        node(1,i).blk_FE,...
        node(1,i).blk_MG,...
        node(1,i).blk_MN,...
        node(1,i).blk_CA,...
        node(1,i).blk_NA,...
        node(1,i).blk_K,...
        node(1,i).blk_TI,...
        node(1,i).blk_H);
end
fclose(fid);
%%
if therinExist
    copyfile('therin_initial.txt','therin.txt');
end

%% Ask if plots should be made
makePlots = input('Do you want to plot the results? y/n [y]: ', 's');
if isempty(makePlots)
    makePlots = 'y';
end

%%
if strcmpi(makePlots,'y')
    %% Plot the P-T path
    V_Table = zeros(size(node,2),2);
    for m = 1:size(node,2)
        V_Table(m,1) = node(1,m).T;
        V_Table(m,2) = node(1,m).P;
    end
    figure('name',rockName,'Filename',strcat(rockName,'_PTpath'));
    plot(V_Table(:,1), V_Table(:,2), 'k-o');
    xlabel('Temperature [C]'); ylabel('Pressure [Bar]');
    axis tight;
    
    %% plot modelled v. input composition (assumes equal steps)
    comp = zeros(num_points,9);
    for j = 1:num_points
        comp(j,1) = j;
        comp(j,2) = node(j).Xalm;
        comp(j,3) = node(j).Xpy;
        comp(j,4) = node(j).Xspss;
        comp(j,5) = node(j).Xgr;
        comp(j,6) = node(j).mgNumMeasured;
        comp(j,7) = node(j).mgNumModeled;
        comp(j,8) = node(j).feNumMeasured;
        comp(j,9) = node(j).feNumModeled;
    end
    figure('name',rockName,'Filename',strcat(rockName,'_ModVsObsZoning'));
    plot(comp(:,1),garnetcomp.data(:,2),'or',...
        comp(:,1),garnetcomp.data(:,3),'dg',...
        comp(:,1),garnetcomp.data(:,4),'xb',...
        comp(:,1),garnetcomp.data(:,5),'^c',...
        comp(:,1),comp(:,6),'>m',...
        comp(:,1),comp(:,8),'+k');
    hold on;
    plot(comp(:,1),comp(:,2),'r',...
        comp(:,1),comp(:,3),'g',...
        comp(:,1),comp(:,4),'b',...
        comp(:,1),comp(:,5),'c',...
        comp(:,1),comp(:,7),'m',...
        comp(:,1),comp(:,9),'k');
    axis tight; ylim([0 1]);
    xlabel('Radial Steps'); ylabel('X end-members');
    legend('alm','py','spss','gr','Mg#','Fe#','alm mod','py mod','spss mod',...
        'gr mod','Mg# mod','Fe# mod','Location','best');
end
fprintf('\nFinished.\n')

