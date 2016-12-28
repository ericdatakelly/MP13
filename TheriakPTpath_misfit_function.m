function [misfit] = TheriakPTpath_misfit_function(PT,T1,P1,...
    alm,py,spss,gr,mgNumObs,loopStep,spss_c,useMgNum,useFeNum,...
    useAlmPrpGrs,useDiff,useNormalizedMisfitFun,use4EndMembers,...
    usePrpGrs,useSpsGrs,useAlmPrpSps,useSpsPenalty,GrtName,GrtRemovePercent,...
    therinNamePWD,loopOutputTable,PTloopCommandsFile,figID2,drawCandidateFig)

% TheriakPTpath_misfit_function.m
% misfit function for use with TheriakPTpath.m
% Place this file in the TD 'working' folder, along with
% 'TheriakPTpath.dat', 'TheriakPTpath.m' and the garnet composition file.
% See other notes on file locations in TheriakPTpath.m.
% DM March 30 2011 (modified by Eric Kelly)

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
    if useSpsPenalty
        misfit_alm = (alm-Xalm)/alm;
        misfit_py = (py-Xpy)/py;
        misfit_gr = (gr-Xgr)/gr;
        misfit_spss = spss * (spss-Xspss)/spss; % This effectively removes normalization, but only for Sps
        misfit_mgNum = (mgNumObs-mgNum)/mgNumObs;
        misfit_feNum = 1 - misfit_mgNum;
    else
        misfit_alm = (alm-Xalm)/alm;
        misfit_py = (py-Xpy)/py;
        misfit_gr = (gr-Xgr)/gr;
        misfit_spss = (spss-Xspss)/spss;
        misfit_mgNum = (mgNumObs-mgNum)/mgNumObs;
        misfit_feNum = 1 - misfit_mgNum;
    end
else
    if useSpsPenalty
        misfit_alm = alm-Xalm;
        misfit_py = py-Xpy;
        misfit_gr = gr-Xgr;
        misfit_spss = spss * (spss-Xspss);
        misfit_mgNum = mgNumObs-mgNum;
        misfit_feNum =  1 - misfit_mgNum;
    else
        misfit_alm = alm-Xalm;
        misfit_py = py-Xpy;
        misfit_gr = gr-Xgr;
        misfit_spss = spss-Xspss;
        misfit_mgNum = mgNumObs-mgNum;
        misfit_feNum =  1 - misfit_mgNum;
    end
end

% Choose the misfit function to use
if useDiff
    misfit = sum([abs(misfit_alm) abs(misfit_py) abs(misfit_gr) abs(misfit_spss)]);
elseif useSpsGrs
    misfit = sqrt(misfit_spss^2+misfit_gr^2);
elseif usePrpGrs
    misfit = sqrt(misfit_py^2+misfit_gr^2);
elseif useAlmPrpGrs
    misfit = sqrt(misfit_alm^2+misfit_py^2+misfit_gr^2);
elseif useAlmPrpSps
    misfit = sqrt(misfit_alm^2+misfit_gr^2+misfit_spss^2);
else
    if spss >= spss_c
        if useMgNum
            misfit = sqrt(misfit_mgNum^2+misfit_gr^2+misfit_spss^2);
        elseif useFeNum
            misfit = sqrt(misfit_feNum^2+misfit_gr^2+misfit_spss^2);
        elseif use4EndMembers
            misfit = sqrt(misfit_alm^2+misfit_py^2+misfit_gr^2+misfit_spss^2);
        end
    else
        if useMgNum
            misfit = sqrt(misfit_mgNum^2+misfit_gr^2);
        elseif useFeNum
            misfit = sqrt(misfit_feNum^2+misfit_gr^2);
        elseif use4EndMembers
            misfit = sqrt(misfit_alm^2+misfit_py^2+misfit_gr^2);
        end
    end
end

% Cover the point with black to unhighlight
if drawCandidateFig
    set(0, 'CurrentFigure',figID2);
    plot(T2,P2,'k.','MarkerSize',8);
end

end

