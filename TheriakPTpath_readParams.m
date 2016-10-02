function [theriakDominoPath,...
    therinName,...
    rockName,...
    userTherinName,...
    therinHeaderLines,...
    datasetName,...
    inputDataFile,...
    T,...
    P,...
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
    saveLoopTable,...
    saveOneLoopTable,...
    makeTheriag,...
    theriagName,...
    savename,...
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
    ] = TheriakPTpath_readParams(name)

% TheriakPTpath_readParams.m
% This function reads the parameters from the TheriakPTpath parameters
% file.  'name' is the file name of the rock parameters file (e.g.,
% 'RockName_params.txt').

fid = fopen(name,'r');
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
theriakDominoPath = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
therinName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
rockName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
userTherinName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
therinHeaderLines = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
datasetName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
inputDataFile = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
T = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
P = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
PTPlotTmin = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
PTPlotTmax = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
PTPlotPmin = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
PTPlotPmax = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
GrtName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
GrtRemovePercent = sscanf(line(1:strfind(line,'%')-1),'%g',1);line = fgetl(fid);
loopStep = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
spss_c = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
line = fgetl(fid);
bulk_Mn_minimum = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
optimsetToleranceFun = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
optimsetToleranceX = sscanf(line(1:strfind(line,'%')-1),'%g',1);
line = fgetl(fid);
optimizationDisplay = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
drawCandidateFig = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
allCompsForTDName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
nodeOutputName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
saveLoopTable = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
saveOneLoopTable = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
makeTheriag = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
theriagName = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
savename = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
use4EndMembers = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useMgNum = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useFeNum = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useAlmPrpGrs = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useAlmPrpSps = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
usePrpGrs = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useSpsGrs = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
useDiff = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
useNormalizedMisfitFun = sscanf(line(1:strfind(line,'%')-1),'%i',1);
line = fgetl(fid);
line = fgetl(fid);
line = fgetl(fid);
loopOutputTable = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
line = fgetl(fid);
theriakOutput = sscanf(line(1:strfind(line,'%')-1),'%s',1);
line = fgetl(fid);
line = fgetl(fid);
PTloopCommandsFile = sscanf(line(1:strfind(line,'%')-1),'%s',1);
fclose(fid);
end