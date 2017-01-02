function TheriakPTpath(nameOfParamsFile)


% TheriakPTpath.m
% A matlab script to calculate a P-T path, given bulk
% composition and garnet traverse data.
% This file should be placed in the TD 'working' folder, along with
% 'TheriakPTpath_misfit_function.m','TheriakPTpath_readTable.m',
% 'TheriakPTpath_readParams.m', the sample parameters file (e.g.,
% 'RockName_params.txt'), the garnet composition profile (e.g.,
% 'RockNameProfile.txt'), and your dataset.
% DM, March 30 2011 (Modified by Eric D. Kelly)

%% Version
% For version tracking, a version number (date: YYYYMMDD)is now in effect.
% Use letters (a, b, c, ...) for multiple changes in the same day.
% Add initials to distinguish between updates from various users.
TheriakPTpathVersion = 'EDK20160901x';
fprintf('\nTheriakPTpath version: %s\n',TheriakPTpathVersion)


%% Get the parameters

[theriakDominoPath,...
    therinName,...
    runName,...
    userTherinName,...
    therinHeaderLines,...
    datasetName,...
    inputDataFile,...
    node(1,1).T,...
    node(1,1).P,...
    PTPlotTmin,...
    PTPlotTmax,...
    PTPlotPmin,...
    PTPlotPmax,...
    GrtName,...
    GrtRemovePercent,...
    loopStep,...
    spss_c,...
    bulk_Mn_minimum,...
    optimsetToleranceFun,...
    optimsetToleranceX,...
    optimizationDisplay,...
    drawCandidateFig,...
    allCompsForTDName,...
    nodeOutputName,...
    saveEachLoopTable,...
    saveOneLoopTable,...
    makeTheriag,...
    theriagName,...
    saveName,...
    use4EndMembers,...
    useMgNum,...
    useFeNum,...
    useAlmPrpGrs,...
    useAlmPrpSps,...
    usePrpGrs,...
    useSpsGrs,...
    useDiff,...
    useNormalizedMisfitFun,...
    loopOutputTable,...
    theriakOutput,...
    PTloopCommandsFile...
    ] = TheriakPTpath_readParams(nameOfParamsFile);

% Rename some files
allCompsForTDName = strcat(runName,'_',allCompsForTDName);
nodeOutputName = strcat(runName,'_',nodeOutputName);
theriagName = strcat(runName,'_',theriagName);
saveName = strcat(runName,'_',saveName);


%% Make full paths for some files

% Be sure program path ends with a backslash
if length(theriakDominoPath) > max(strfind(theriakDominoPath,'\'))
    theriakDominoProgram = strcat(theriakDominoPath,'\','theriak.exe');
else
    theriakDominoProgram = strcat(theriakDominoPath,'theriak.exe');
end

loopOutputTablePWD = strcat(pwd,'\',loopOutputTable);
theriakOutputPWD = strcat(pwd,'\',theriakOutput);
savenamePWD = strcat(pwd,'\',saveName);
allCompsForTDNamePWD = strcat(pwd,'\',allCompsForTDName);
nodeOutputNamePWD = strcat(pwd,'\',nodeOutputName);
theriagNamePWD = strcat(pwd,'\',theriagName);
therinNamePWD = strcat(pwd,'\',therinName);
userTherinNamePWD = strcat(pwd,'\',userTherinName);
inputDataFilePWD = strcat(pwd,'\',inputDataFile);
datasetNamePWD = strcat(pwd,'\',datasetName);

%% Check the status of some files

if exist(theriakDominoProgram, 'file') == 2
else
    errMess1 = 'Cannot find theriak.exe.';
    errMess2 = 'Check that the path to the Programs folder is correct.';
    errMess3 = 'Aborting...';
    error('\n%s\n%s\n%s\n',errMess1,errMess2,errMess3)
end

if exist(userTherinNamePWD, 'file') == 2
    fid = fopen(userTherinNamePWD,'r');
    headerline = fgetl(fid);
    fclose(fid);
    if strcmp(headerline(1,1),'!') == 0
        errMess1 = 'Bulk composition not found.  Check format of ';
        errMess2 = 'Aborting...';
        error('\n%s%s.\n%s\n',errMess1,userTherinName,errMess2)
    end
else
    errMess1 = 'Bulk composition file ';
    errMess2 = ' seems to be missing.';
    errMess3 = 'Aborting...';
    error('\n%s%s%s\n%s\n',errMess1,userTherinName,errMess2,errMess3)
end

if exist(inputDataFilePWD, 'file') == 2
else
    errMess1 = 'Garnet zoning file ';
    errMess2 = ' seems to be missing.';
    errMess3 = 'Aborting...';
    error('\n%s%s%s\n%s\n',errMess1,inputDataFile,errMess2,errMess3)
end

if exist(datasetNamePWD, 'file') == 2
else
    errMess1 = 'Dataset file ';
    errMess2 = ' seems to be missing.';
    errMess3 = 'Aborting...';
    error('\n%s%s%s\n%s\n',errMess1,datasetName,errMess2,errMess3)
end

%% Reminders for the user
fprintf('\nInitial T P:          %g %g\n',node(1,1).T,node(1,1).P)

if useSpsGrs
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Xsps and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    else
        fprintf('\nUsing Xsps and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    end
elseif usePrpGrs
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Xprp and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    else
        fprintf('\nUsing Xprp and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    end
elseif useAlmPrpGrs
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Xalm, Xprp, and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    else
        fprintf('\nUsing Xalm, Xprp, and Xgrs to constrain P-T.')
        fprintf('\nXsps cutoff is ignored with this misfit function.')
    end
elseif useMgNum
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Mg#, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Mg# and Xgrs will be used.',spss_c)
    else
        fprintf('\nUsing Mg#, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Mg# and Xgrs will be used.',spss_c)
    end
elseif useFeNum
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Fe#, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Fe# and Xgrs will be used.',spss_c)
    else
        fprintf('\nUsing Fe#, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Fe# and Xgrs will be used.',spss_c)
    end
elseif use4EndMembers
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Xalm, Xprp, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    else
        fprintf('\nUsing Xalm, Xprp, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    end
elseif useAlmPrpSps
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized Xalm, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    else
        fprintf('\nUsing Xalm, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    end
elseif useDiff
    if useNormalizedMisfitFun
        fprintf('\nUsing normalized differences in Xalm, Xprp, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    else
        fprintf('\nUsing differences in Xalm, Xprp, Xgrs, and Xsps to constrain P-T.')
        fprintf('\nIf Xsps falls below %g, Xalm, Xgrs, and Xprp will be used.',spss_c)
    end
else
    errMess1 = 'Unknown misfit function.';
    errMess2 = 'Be sure a function is chosen in the params file.';
    error('\n%s\n%s\n',errMess1,errMess2)
end

if bulk_Mn_minimum > 0
    fprintf('\n\nMinimum bulk Mn option is on.')
    fprintf('\nMn will not be allowed to drop below %g.',bulk_Mn_minimum)
end

fprintf('\n\nSome files will be deleted or overwritten.  Save them now!')
fprintf('\n\nPress any key to start or CTRL-C to stop.\n')
pause

fprintf('\nRunning...\n')

%% Remove old files and write new ones

% Remove old files to prevent partial overwrites
if exist((loopOutputTablePWD), 'file') == 2
    delete(loopOutputTablePWD);
end

if exist((theriakOutputPWD), 'file') == 2
    delete(theriakOutputPWD);
end

if exist(savenamePWD, 'file') == 2
    delete(savenamePWD);
end

if exist(allCompsForTDNamePWD, 'file') == 2
    delete(allCompsForTDNamePWD);
end

if exist(nodeOutputNamePWD, 'file') == 2
    delete(nodeOutputNamePWD);
end

% save initial therin file
if exist(therinNamePWD, 'file') == 2
    copyfile(therinNamePWD,'therin_initial.txt');
    therinExist = 1;
else
    therinExist = 0;
end

% Write therin file from the user file
copyfile(userTherinNamePWD,therinNamePWD);

% Write batch and input files for theriak commands
fid = fopen('TheriakPTpath.bat','wt');
fprintf(fid,'set THERDOM=%s\n',theriakDominoPath);
fprintf(fid,'set PATH=%%THERDOM%%;%%path%%\ntheriak < TheriakPTpathInput.dat\n');
fclose(fid);

fid = fopen('TheriakPTpathInput.dat','wt');
fprintf(fid,'%s\n%s\nInfo.txt\n',datasetName,PTloopCommandsFile);
fclose(fid);


%% Read rock conditions

% get initial composition from therin file
fid = fopen(therinNamePWD,'r');
icomp = textscan(fid,'%s',1,'delimiter','\n', 'headerlines', therinHeaderLines);
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

% Get the garnet zoning data and determine the number of steps in the profile
garnetcomp = importdata(inputDataFilePWD);
num_points = size(garnetcomp.data,1);


%% Create figures to monitor the run

% Draw a figure to track the P-T path progress during the run
figID1 = figure('name',runName,'Filename',strcat(runName,'_PTpath'));
figID1_position = get(gcf,'Position');
plot(node(1,1).T,node(1,1).P,'ro');
xlim([PTPlotTmin PTPlotTmax]);
ylim([PTPlotPmin PTPlotPmax]);
xlabel('Temperature [C]');
ylabel('Pressure [Bar]');
hold on

% Draw a figure to show the candidate P-T points during the search
if drawCandidateFig
    figID2 = figure('name','Misfit Candidates','Position',...
        [figID1_position(1)+15 figID1_position(2)-15 figID1_position(3) figID1_position(4)]);
else
    figID2 = [];
end


%% Begin search
tstart = tic;
startTime = now;

for n = 1: num_points
    loopstart = tic;

    % get the starting temperature and pressure
    T1 = node(1,n).T;
    P1 = node(1,n).P;
    
    % Add accepted points to candidate figure
    if drawCandidateFig
        clf(figID2)
        set(0, 'CurrentFigure',figID2);
        hold on
        for i = 1:n  % There's a better way to plot these from a structure...
            plot(node(1,i).T,node(1,i).P,'ko');
        end
        plot(node(1,1).T,node(1,1).P,'ro');
        xlabel('Temperature [C]');
        ylabel('Pressure [Bar]');
    end
    
    % write therin.txt with new composition
    fid = fopen(therinNamePWD, 'wt');
    fprintf(fid, '    000     0000\n0   SI(%#.9g)AL(%#.9g)FE(%#.9g)MG(%#.9g)',...
        node(1,n).blk_SI,...
        node(1,n).blk_AL,...
        node(1,n).blk_FE,...
        node(1,n).blk_MG);
    fprintf(fid,'MN(%#.9g)CA(%#.9g)NA(%#.9g)K(%#.9g)TI(%#.9g)H(%#.9g)O(?)  *\n',...
        node(1,n).blk_MN,...
        node(1,n).blk_CA,...
        node(1,n).blk_NA,...
        node(1,n).blk_K,...
        node(1,n).blk_TI,...
        node(1,n).blk_H);
    fclose(fid);
    
    % select garnet composition from traverse
    alm = garnetcomp.data(n,2);
    py = garnetcomp.data(n,3);
    spss = garnetcomp.data(n,4);
    gr = garnetcomp.data(n,5);
    mgNumObs = garnetcomp.data(n,3)./...
        (garnetcomp.data(n,3)+garnetcomp.data(n,2));
    
    % choose input P-T for optimisation function (same as initial value).
    % Note that 'PT' will be adjusted by fminsearch during the
    % optimization, so we only need a starting point here.
    PT = [node(1,n).T,node(1,n).P];
    
    
    % Run optimisation to find best P,T fit for given garnet composition
    
    % Define the function
    functionOfPT = @(PT) TheriakPTpath_misfit_function(PT,T1,P1,...
        alm,py,spss,gr,mgNumObs,loopStep,spss_c,useMgNum,useFeNum,...
        useAlmPrpGrs,useDiff,useNormalizedMisfitFun,use4EndMembers,...
        usePrpGrs,useSpsGrs,useAlmPrpSps,GrtName,GrtRemovePercent,...
        therinNamePWD,loopOutputTable,PTloopCommandsFile,figID2,drawCandidateFig);
    
    % Define the function options
    functionOptions = optimset('Display',optimizationDisplay,...
        'TolFun',optimsetToleranceFun,'TolX',optimsetToleranceX);
    
    % Run the search routine
    fminsearch(functionOfPT,PT,functionOptions);
    
    % Read the new values produced from the search
    [Xalm,Xpy,Xspss,Xgr,mgNum,V_SolidsCC,V_GrtCC,headers,data] = ...
        TheriakPTpath_readTable(loopOutputTable,therinNamePWD);
    
    % Calculate garnet mode
    % The current state of the system (last fractionation step between
    % previous PT and new PT, each row of the loop table) is an
    % independent calculation of phase equilibria in which only the
    % outer volume of Grt is in equilibrium with the matrix.
    % During the current Grt zoning step (n), Grt is fractionated between 
    % the last PT point and the next PT point.  Thus the Grt volume 
    % fractionated during the current step must be summed with all Grt
    % volume fractionated during previous steps.
    if n == 1
        V_GrtAllCC = 0;
        V_GrtCurrentStepCC = sum(V_GrtCC); % Get all Grt fractionated in first step (cm^3)
    else
        V_GrtCurrentStepCC = sum(V_GrtCC(2:end)); % Avoid redundant value calculated at previous PT (cm^3)
    end
    V_GrtAllCC = V_GrtAllCC + V_GrtCurrentStepCC;
    % Mode = 100 * (all Grt fractionated along path) 
    %            / (all solids, avoiding redundant Grt within V_solidsCC)
    V_GrtCumulMode = 100 * V_GrtAllCC...
        / ((V_SolidsCC - V_GrtCC(end)) + V_GrtAllCC);
    
    % record information in node structure
    node(1,n+1).T =      data(end,ismember(headers{1,1}, ':Temperature','legacy'));
    node(1,n+1).P =      data(end,ismember(headers{1,1}, ':Pressure','legacy'));
    node(1,n+1).blk_AL = data(end,ismember(headers{1,1}, 'blk_AL','legacy'));
    node(1,n+1).blk_SI = data(end,ismember(headers{1,1}, 'blk_SI','legacy'));
    node(1,n+1).blk_FE = data(end,ismember(headers{1,1}, 'blk_FE','legacy'));
    node(1,n+1).blk_MG = data(end,ismember(headers{1,1}, 'blk_MG','legacy'));
    node(1,n+1).blk_MN = data(end,ismember(headers{1,1}, 'blk_MN','legacy'));
    node(1,n+1).blk_CA = data(end,ismember(headers{1,1}, 'blk_CA','legacy'));
    node(1,n+1).blk_NA = data(end,ismember(headers{1,1}, 'blk_NA','legacy'));
    node(1,n+1).blk_K =  data(end,ismember(headers{1,1}, 'blk_K','legacy'));
    node(1,n+1).blk_TI = data(end,ismember(headers{1,1}, 'blk_TI','legacy'));
    node(1,n+1).blk_H =  data(end,ismember(headers{1,1}, 'blk_H','legacy'));
    node(1,n+1).Xalm =   Xalm;
    node(1,n+1).Xpy =    Xpy;
    node(1,n+1).Xspss =  Xspss;
    node(1,n+1).Xgr =    Xgr;
    node(1,n+1).mgNumObs =       mgNumObs;
    node(1,n+1).mgNum =          mgNum;
    node(1,n+1).feNumObs =       1 - mgNumObs;
    node(1,n+1).feNum =          1 - mgNum;
    node(1,n+1).v_solCC =        V_SolidsCC;
    node(1,n+1).v_grtOuterCC =   V_GrtCC(end);
    node(1,n+1).v_grtCC =        V_GrtCurrentStepCC; % Edit node name elsewhere also
    node(1,n+1).v_grtAllCC =     V_GrtAllCC;
    node(1,n+1).v_grtCumulMode = V_GrtCumulMode;
    
    % Ensure that the bulk composition does not lose Mn (user option)
    if node(1,n+1).blk_MN < bulk_Mn_minimum
        node(1,n+1).blk_MN = bulk_Mn_minimum;
    end

    % Save a copy of the loop table for the successful PT point
    if saveEachLoopTable
        ext_index = strfind(loopOutputTable,'.');
        ext_str = sscanf(loopOutputTable(ext_index:end),'%s');
        loopFrac_name = strcat(runName,'_LoopFrac',num2str(n),ext_str);
        copyfile(loopOutputTable,loopFrac_name);
    end
    
    % Record PT points along each loop for making full theriak loop table
    if saveOneLoopTable
        if n == 1
            loopTP = [
                data(1:end,ismember(headers{1,1}, ':Temperature','legacy')) ...
                data(1:end,ismember(headers{1,1}, ':Pressure','legacy'))];
        else
            loopTP = [loopTP;
                data(2:end,ismember(headers{1,1}, ':Temperature','legacy')) ...
                data(2:end,ismember(headers{1,1}, ':Pressure','legacy'))];
        end
    end
    
    % Print out information about the run
    loopTimeMinutes = toc(loopstart)/60;
    total_time = toc(tstart)/60;
    total_timeDate = (total_time * 60 / n) * num_points;
    fprintf('\nRun name:  %s\n',runName)
    fprintf('New P-T is %#.3f bars, %#.3f degrees C\n', node(1,n+1).P, node(1,n+1).T)
    fprintf('Loop number %d out of %d completed\n',n, num_points)
    fprintf('Observed Xsps = %g. Cutoff is %g\n',garnetcomp.data(n,4),spss_c)
    fprintf('Time elapsed during loop number %d: %.2f minutes\n',n,loopTimeMinutes)
    fprintf('Cumulative running time: %.2f minutes (%.3g hours)\n',total_time,total_time/60)
    fprintf('Projected end of run (improves with more steps): %s\n',...
        datestr(addtodate(startTime,round(total_timeDate),'second')))
    
    % Add point to P-T path progress figure
    set(0, 'CurrentFigure',figID1);
    plot(node(1,n+1).T,node(1,n+1).P,'ko');
    
    % Add last point to candidate figure
    if drawCandidateFig
        if n == num_points
            set(0, 'CurrentFigure',figID2);
            plot(node(1,n+1).T,node(1,n+1).P,'ko');
        end
    end
end

% Save the workspace
warning('off');
save(saveName);
warning('on');

set(0, 'CurrentFigure',figID1)
hold off
fprintf('\nP-T path search for "%s" finished at %s\n',runName,datestr(now))

%% Run theriak to generate one big loop table along the whole PT path
if saveOneLoopTable
    fprintf('\nRunning theriak loop for whole PT path...\n')
    
    % write the loop fractionation file
    fid = fopen(PTloopCommandsFile, 'wt');
    fprintf(fid, 'REMOVE  %s  %#.5f\n',GrtName, GrtRemovePercent);
    for n = 1:length(loopTP(:,1))
        fprintf(fid, 'TP  %#.8f  %#.8f\n', loopTP(n,1), loopTP(n,2));
    end
    fclose(fid);
    
    % Write therin file from the user file
    copyfile(userTherinNamePWD,therinNamePWD);

    % call theriak and monitor the output file modification time to allow 
    % the program to continue only after the file has been written
    [output1] = dir(loopOutputTable);
    [~,~] = system('TheriakPTpath.bat');
    [output2] = dir(loopOutputTable);
    while output1.datenum == output2.datenum
        pause(1)
        [output2] = dir(loopOutputTable);
    end
    
    % Copy and rename the new tab file
    copyfile(loopOutputTablePWD,strcat(runName,'_',loopOutputTable))
    fprintf('...loop table saved as %s.\n',strcat(runName,'_',loopOutputTable))
    
%     % Get the free energy values of garnet for printing in the output table
    % Also keep a copy of the output file
    copyfile(theriakOutputPWD,strcat(runName,'_',theriakOutput))
%     fprintf('\nGetting garnet free energy values from %s...\n',theriakOutput)
%     nodeT = zeros(num_points,1);
%     nodeP = zeros(num_points,1);
%     for n = 1:num_points
%         nodeT(n) = node(1,n+1).T;
%         nodeP(n) = node(1,n+1).P;
%     end
%     G_grt = TheriakPTpath_readOut(...
%         theriakOutput,GrtName,nodeT,nodeP);
%     for n = 1:num_points
%         [node(1,n+1).G_grt] = G_grt(n);
%     end
    fprintf('...Finished\n')
end

%% Write file with all compositions formatted for Theriak-Domino

fid = fopen(allCompsForTDNamePWD, 'wt');
fprintf(fid,'TheriakPTpath version: %s\n',TheriakPTpathVersion);
for n = 1:num_points
    fprintf(fid,'1   SI(%#.9g)AL(%#.9g)FE(%#.9g)MG(%#.9g)MN(%#.9g)CA(%#.9g)',...
        node(1,n+1).blk_SI,...
        node(1,n+1).blk_AL,...
        node(1,n+1).blk_FE,...
        node(1,n+1).blk_MG,...
        node(1,n+1).blk_MN,...
        node(1,n+1).blk_CA);
    fprintf(fid,'NA(%#.9g)K(%#.9g)TI(%#.9g)H(%#.9g)O(?)  *   %i\n',...
        node(1,n+1).blk_NA,...
        node(1,n+1).blk_K,...
        node(1,n+1).blk_TI,...
        node(1,n+1).blk_H,...
        n);
end
fclose(fid);

%% Write file with all node structure information

fid = fopen(nodeOutputNamePWD, 'wt');
% Write the header lines
fprintf(fid,'TheriakPTpath version: %s\n',TheriakPTpathVersion);
fprintf(fid,'No.,T(C),P(bars)');
fprintf(fid,',Xalm,Xprp,Xsps,Xgrs,Mg#,Fe#');
fprintf(fid,',obs_Xalm,obs_Xprp,obs_Xsps,obs_Xgrs,obs_Mg#,obs_Fe#');
% fprintf(fid,',GrtVolCC,GrtCumulMode,GrtG(J)');
fprintf(fid,',GrtVolCC,GrtCumulMode');
fprintf(fid,',blk_Si,blk_Al,blk_Fe,blk_Mg');
fprintf(fid,',blk_Mn,blk_Ca,blk_Na,blk_K,blk_Ti,blk_H\n');
for n = 1:num_points
    % Step number and P-T
    fprintf(fid,'%i,%#.8f,%#.8f',...
        n,...
        node(1,n+1).T,...
        node(1,n+1).P);
    % Modeled Grt comps
    fprintf(fid,',%#.8g,%#.8g,%#.8g,%#.8g,%#.8g,%#.8g',...
        node(1,n+1).Xalm,...
        node(1,n+1).Xpy,...
        node(1,n+1).Xspss,...
        node(1,n+1).Xgr,...
        node(1,n+1).mgNum,...
        node(1,n+1).feNum);
    % Observed Grt comps
    fprintf(fid,',%#.8g,%#.8g,%#.8g,%#.8g,%#.8g,%#.8g',...
        garnetcomp.data(n,2),...
        garnetcomp.data(n,3),...
        garnetcomp.data(n,4),...
        garnetcomp.data(n,5),...
        node(1,n+1).mgNumObs,...
        node(1,n+1).feNumObs);
    % Volumes
    %fprintf(fid,',%#.10g,%#.10g,%#.8g',...
    fprintf(fid,',%#.10g,%#.10g',...
        node(1,n+1).v_grtCC,...    % Edit node name elsewhere also
        node(1,n+1).v_grtCumulMode);%,...
%         node(1,n+1).G_grt);
    % Bulk composition
    fprintf(fid,',%#.9g,%#.9g,%#.9g,%#.9g,%#.9g,%#.9g,%#.9g,%#.9g,%#.9g,%#.9g\n',...
        node(1,n+1).blk_SI,...
        node(1,n+1).blk_AL,...
        node(1,n+1).blk_FE,...
        node(1,n+1).blk_MG,...
        node(1,n+1).blk_MN,...
        node(1,n+1).blk_CA,...
        node(1,n+1).blk_NA,...
        node(1,n+1).blk_K,...
        node(1,n+1).blk_TI,...
        node(1,n+1).blk_H);
end
fclose(fid);
%%
if therinExist
    copyfile('therin_initial.txt',therinNamePWD);
end

%% Create input file for Theriag
if makeTheriag
    tstep = 0.00001;
    fid = fopen(theriagNamePWD, 'wt');
    for n = 1:size(node,2)
        fprintf(fid, '%#.8f           %#.8f          %#.8f\n', node(n).T, node(n).P, tstep*(n-1));
    end
    fclose(fid);
end

%% Ask if plots should be made
makePlots = input('\nDo you want to plot the results? y/n [y]: ', 's');
if isempty(makePlots)
    makePlots = 'y';
end
if strcmpi(makePlots,'y')
    %% Plot the P-T path
    V_Table = zeros(size(node,2),2);
    for m = 1:size(node,2)
        V_Table(m,1) = node(1,m).T;
        V_Table(m,2) = node(1,m).P;
    end
    figure('name',runName,'Filename',strcat(runName,'_PTpath'));
    plot(V_Table(:,1), V_Table(:,2), 'k-o');
    xlabel('Temperature [C]'); ylabel('Pressure [Bar]');
    axis tight;
    
    %% plot modelled v. input composition (assumes equal steps)
    comp = zeros(num_points,9);
    for j = 1:num_points
        comp(j,1) = j;
        comp(j,2) = node(j+1).Xalm;
        comp(j,3) = node(j+1).Xpy;
        comp(j,4) = node(j+1).Xspss;
        comp(j,5) = node(j+1).Xgr;
        comp(j,6) = node(j+1).mgNumObs;
        comp(j,7) = node(j+1).mgNum;
        comp(j,8) = node(j+1).feNumObs;
        comp(j,9) = node(j+1).feNum;
    end
    figure('name',runName,'Filename',strcat(runName,'_ModVsObsZoning'));
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
    
    %% Plot the delta T and P with each step
    dtable = zeros(num_points,3);
    for n = 1: num_points
        dtable(n,1) = n;
        dtable(n,2) = node(n+1).T-node(n).T;
        dtable(n,3) = node(n+1).P-node(n).P;
    end
    figure('name',runName,'Filename',...
        strcat(runName,'_deltaPT')); subplot(2,1,1);
    plot(dtable(:,1),dtable(:,2), 'b*');
    axis tight;
    xlabel('Steps'); ylabel('delta T [C]');
    subplot(2,1,2);
    plot(dtable(:,1),dtable(:,3), 'b*');
    axis tight;
    xlabel('Steps'); ylabel('delta P [Bar]');
    
    %% Plot the difference between observed and modelled compositions
    diff = zeros(num_points,5);
    for n = 1: num_points
        diff(n,1) = n;
        diff(n,2) = (node(1,n+1).Xalm-garnetcomp.data(n,2))*100;
        diff(n,3) = (node(1,n+1).Xpy-garnetcomp.data(n,3))*100;
        diff(n,4) = (node(1,n+1).Xspss-garnetcomp.data(n,4))*100;
        diff(n,5) = (node(1,n+1).Xgr-garnetcomp.data(n,5))*100;
    end
    figure('name',runName,'Filename',...
        strcat(runName,'_ModVsObsDelta'));
    subplot(4,1,1);
    plot(diff(:,1), diff(:,2), 'b*'); 
    axis tight;
    xlabel('Steps'); ylabel('alm orig');
    subplot(4,1,2);
    plot(diff(:,1), diff(:,3), 'b*');
    axis tight;
    xlabel('Steps'); ylabel('py orig');
    subplot(4,1,3);
    plot(diff(:,1), diff(:,4), 'b*');
    axis tight;
    xlabel('Steps'); ylabel('spss orig');
    subplot(4,1,4);
    plot(diff(:,1), diff(:,5), 'b*');
    axis tight;
    xlabel('Steps'); ylabel('gr orig');
    
    %% Plot changes in chemistry
    bulk = zeros(size(node,2),7);
    for n = 1:size(node,2)
        bulk(n,1) = n;
        bulk(n,2) = node(1,n).blk_AL/node(1,1).blk_AL;
        bulk(n,3) = node(1,n).blk_FE/node(1,1).blk_FE;
        bulk(n,4) = node(1,n).blk_MG/node(1,1).blk_MG;
        bulk(n,5) = node(1,n).blk_MN/node(1,1).blk_MN;
        bulk(n,6) = node(1,n).blk_CA/node(1,1).blk_CA;
        bulk(n,7) = node(1,n).blk_MG/(node(1,n).blk_MG+node(1,n).blk_FE);
    end
    figure('name',runName,'Filename',strcat(runName,'_ModBC'));
    plot(bulk(:,1),bulk(:,2),'yo-', bulk(:,1),bulk(:,3),'bo-',...
        bulk(:,1),bulk(:,4),'go-', bulk(:,1), bulk(:,5),'ro-',...
        bulk(:,1),bulk(:,6),'mo-', bulk(:,1), bulk(:,7), 'k-o');
    axis tight;
    xlabel('Steps'); ylabel('Bulk rock / original bulk rock (n)');
    legend('Al','Fe','Mg','Mn','Ca', 'M/M+F','Location','best');
    title('Bulk Rock Composition');
    
end

% Save the workspace again to get the new figures
warning('off');
save(saveName);
warning('on');

end