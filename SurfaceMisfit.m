% Program for calculating and displaying the misfit surface of a domino
% plot.

% Hints:
% Edit misfit function as needed below
% 'Comment out' system call to theriak if table has already been created
% (otherwise you need to wait for the table to be built again)

%% Enter starting values
% Observed garnet composition
XalmObs = 0.6793;
XprpObs = 0.0985;
XspsObs = 0.0182;
XgrsObs = 0.204;

% Range and steps for P-T (less than 500 points)
beginT = 525;
beginP = 8500;
endT = 550;
endP = 8800;
stepT = 10;
stepP = 200;

bulkComp = 'COMP  SI(64.5044)AL(7.8591)FE(4.9499)MG(3.4840)MN(0.0101)CA(0.3200)NA(0.5200)K(2.2100)TI(1.3500)H(100)O(?)  *   50';

theriakDominoPath = 'C:\Eric\TheriakDominoWIN\Programs\';

datasetName = 'tcdb55c2d_AL3trimmed.txt';

%% Run Program

fprintf('\nRunning...\n')

% Make drive file
T_steps = ceil((endT - beginT)/stepT);

fid = fopen('SurfaceMisfitDrive.drive','w+');
for press = beginP:stepP:endP
    fprintf(fid,'REF  %g  %g\n',beginT,press);
    fprintf(fid,'%s\n',bulkComp);
    fprintf(fid,'REMOVE  GARNET  0\n');
    fprintf(fid,'TP  %g  %g  %i\n\n',endT,press,T_steps);
end
fclose(fid);

% Write batch and input files for theriak commands
fid = fopen('SurfaceMisfit.bat','wt');
fprintf(fid,'set THERDOM=%s\n',theriakDominoPath);
fprintf(fid,'set PATH=%%THERDOM%%;%%path%%\ntheriak < SurfaceMisfitInput.dat\n');
fclose(fid);

fid = fopen('SurfaceMisfitInput.dat','wt');
fprintf(fid,'%s\nSurfaceMisfitDrive.drive\nInfo.txt\n',datasetName);
fclose(fid);

% Call theriak
[~,~] = system('SurfaceMisfit.bat');

% Read table
[T,P,Xalm,Xpy,Xspss,Xgr] = ...
    SurfaceMisfit_readTable('ThkTab.txt');

% Calculate misfit values
almMisfit = ((XalmObs - Xalm)/XalmObs).^2;
prpMisfit = ((XprpObs - Xpy)/XprpObs).^2;
spsMisfit = ((XspsObs - Xspss)/XspsObs).^2;
grsMisfit = ((XgrsObs - Xgr)/XgrsObs).^2;

misfit = (almMisfit + prpMisfit + spsMisfit + grsMisfit).^0.5;
%misfit = (almMisfit + prpMisfit + grsMisfit).^0.5;

% Plot the values
figure
tri = delaunay(T,P);
trisurf(tri,T,P,misfit)
xlabel('T (C)')
ylabel('P (bars)')
zlabel('Misfit')
hold off

fprintf('\nFinished.\n')
