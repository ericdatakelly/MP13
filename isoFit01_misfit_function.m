function [differenceInGrtChem] = isoFit01_misfit_function(PT,T1,P1,...
    alm_obs,prp_obs,sps_obs,grs_obs,mgNumObs,loopStep,spss_c,useMgNum,useFeNum,...
    useAlmPrpGrs,useDiff,useNormalizedMisfitFun,use4EndMembers,...
    usePrpGrs,useSpsGrs,useAlmPrpSps,GrtName,GrtRemovePercent,...
    therinNamePWD,loopOutputTable,PTloopCommandsFile,figID2,drawCandidateFig)

% isoFit_misfit_function.m
% misfit function for use with isoFit.m
% Place this file in the TD 'working' folder, along with
% 'TheriakPTpath.dat', 'TheriakPTpath.m' and the garnet composition file.
% See other notes on file locations in TheriakPTpath.m.
% DM March 30 2011 (modified by Eric Kelly)


%% Edit the headers <---------------------


%% Find a new PT point

% Assign ending P and T for loop.  The PT value will be incremented by
% fminsearch
T2 = PT(1);
P2 = PT(2);

% Add point to the candidate figure 
if drawCandidateFig
    set(0, 'CurrentFigure',figID2);
    plot(T2,P2,'r.','MarkerSize',8); % Highlight the point momentarily (overdrawn below)
end

% calculate the number of steps (scale is 30 bars, 1 degree)
loop_length = sqrt((T2-T1)^2+((P2-P1)/30)^2);
numberOfSteps = ceil(loop_length/loopStep);

% write theriak loop file.  This will be used with theriak to determine the
% system variables after fractionation of garnet along a path from the 
% starting PT to the ending PT.  The variables at the end of the loop will
% be evaluated to see if the misfit criterion has been reached.
fid = fopen(PTloopCommandsFile, 'wt');
fprintf(fid, 'REMOVE  %s  %#.5f\nTP  %#.5f  %#.5f\nTP  %#.5f  %#.5f  %u\n',...
    GrtName, GrtRemovePercent, T1, P1, T2, P2, numberOfSteps);
fclose(fid);

%run theriak
[~,~] = system('TheriakPTpath.bat'); % Windows or Unix(?) compatible
% [~,~] = dos('TheriakPTpath.bat'); % Windows version
% !/Users/gravius/Documents/Metamorphic/TheriakDominoMAC/Programs/theriak < in_ther >/dev/null % Unix

% Read the loop table
[Xalm,Xpy,Xspss,Xgr,mgNum,~,~] = ...
    TheriakPTpath_readTable(loopOutputTable,therinNamePWD);

%% Calculate misfit value at the new PT

% Calculate the misfit value for each endmember
if useNormalizedMisfitFun
    misfit_alm = (alm_obs-Xalm)/alm_obs;
    misfit_prp = (prp_obs-Xpy)/prp_obs;
    misfit_grs = (grs_obs-Xgr)/grs_obs;
    misfit_sps = (sps_obs-Xspss)/sps_obs;
    misfit_mgNum = (mgNumObs-mgNum)/mgNumObs;
    misfit_feNum = 1 - misfit_mgNum;
else
    misfit_alm = alm_obs-Xalm;
    misfit_prp = prp_obs-Xpy;
    misfit_grs = grs_obs-Xgr;
    misfit_sps = sps_obs-Xspss;
    misfit_mgNum = mgNumObs-mgNum;
    misfit_feNum =  1 - misfit_mgNum;
end

differenceInGrtChem = [misfit_alm misfit_prp misfit_grs misfit_sps];


% the alternative misfit functions will need to be rewritten after this
% initial testing...





% Choose the misfit function to use
if useDiff
    misfit = sum([abs(misfit_alm) abs(misfit_prp) abs(misfit_grs) abs(misfit_sps)]);
elseif useSpsGrs
    misfit = sqrt(misfit_sps^2+misfit_grs^2);
elseif usePrpGrs
    misfit = sqrt(misfit_prp^2+misfit_grs^2);
elseif useAlmPrpGrs
    misfit = sqrt(misfit_alm^2+misfit_prp^2+misfit_grs^2);
elseif useAlmPrpSps
    misfit = sqrt(misfit_alm^2+misfit_grs^2+misfit_sps^2);
else
    if sps_obs >= spss_c
        if useMgNum
            misfit = sqrt(misfit_mgNum^2+misfit_grs^2+misfit_sps^2);
        elseif useFeNum
            misfit = sqrt(misfit_feNum^2+misfit_grs^2+misfit_sps^2);
        elseif use4EndMembers
            misfit = sqrt(misfit_alm^2+misfit_prp^2+misfit_grs^2+misfit_sps^2);
        end
    else
        if useMgNum
            misfit = sqrt(misfit_mgNum^2+misfit_grs^2);
        elseif useFeNum
            misfit = sqrt(misfit_feNum^2+misfit_grs^2);
        elseif use4EndMembers
            misfit = sqrt(misfit_alm^2+misfit_prp^2+misfit_grs^2);
        end
    end
end

% Cover the point with black to unhighlight
if drawCandidateFig
    set(0, 'CurrentFigure',figID2);
    plot(T2,P2,'k.','MarkerSize',8);
end

end

