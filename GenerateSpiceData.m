%% Conduct LTSpice simulation with sweep of temperature values
%  This code simulates a Buck Converter w/ input LISN network for
%  several power device temperatures
%  (See %ATTN comments for adjusting simulation settings)

%% Initialize
clear; clc; close all; fclose('all');
addpath('../MATLAB Code');
tStart = tic;

%% Input Variables
headerPath = 'NetlistHeader\syncBuck_Cree_Base.txt';
outputPath = [pwd '\Generation Output\'];

% Select Temperatures for Simulation
% ATTN: Select temperatures for simulation
temps = 20:0.1:150;

% ATTN: If resuming previous simulation, set start resume temp here; else set to 0
startTemp = 0;

% ATTN: If resuming previous simulation, set max resume temp here; else set
% to 1000
endTemp = 1000;

% ATTN: Enter maximum time [min] allowed for simulation to run before declaring a
% failure (Use SimTimeTest.m to find expected time for one sim)
maxSimTime = 0.58;

% ATTN: Enter Filter window for output data
filterWindow = 85;

%% Runner
% Determine device prefix - necessary for fCreateNetlist to search lines
% for appropriate location for renaming nmos device
if(contains(headerPath, 'Cree'))
    device = 'C3M';
elseif(contains(headerPath, 'Rohm'))
    device = 'SCT';
elseif(contains(headerPath, 'UnitedSiC'))
    device = 'UJC';
elseif(contains(headerPath, 'Infineon'))
    device = 'IKW';
else
    error('Device Prefix could not be determined - Check headerPath variable');
end

format short;
if(startTemp >= temps(1) && endTemp <= temps(end))
    fprintf('Beginning Simulation: Estimated %3.3f hours remaining\n', (maxSimTime*length(temps(find(temps==startTemp):find(temps==endTemp))))/60);
elseif(startTemp >= temps(1))
    fprintf('Beginning Simulation: Estimated %3.3f hours remaining\n', (maxSimTime*length(temps(find(temps==startTemp):end)))/60);
elseif(endTemp <= temps(end))
    fprintf('Beginning Simulation: Estimated %3.3f hours remaining\n', (maxSimTime*length(temps(1:find(temps==endTemp))))/60);
else
    fprintf('Beginning Simulation: Estimated %3.3f hours remaining\n', (maxSimTime*length(temps))/60);
end

for i=1:length(temps)
    if(temps(i) >= startTemp && temps(i) <= endTemp)
        % CALCULATE THE VARIABLES
        Data = fCalculateVariables(temps(i), headerPath, maxSimTime, outputPath, device);
        
        % SAVE DATA TO A .MAT FILE
        fnMatFile = [outputPath 'MAT Files\' num2str(temps(i)) 'C.mat'];
        save(fnMatFile,'Data');
        cwtData = abs(cwt(Data.TD', 100E-6));
        cwtPath = [outputPath 'CWT Files\' num2str(temps(i)) 'C.mat'];
        save(cwtPath, 'cwtData');
    end
end
%% Error Check/Output Failed Temps
errors = fCheckSuccess(outputPath);
fnErrorList = [outputPath 'ErrorList.mat'];
save(fnErrorList, 'errors');

fileID = fopen([outputPath 'Error List.txt'],'w');
fprintf(fileID,'%s\n','Failed Temperatures');
for i = 1:length(errors)
    fprintf(fileID,'%s\n', num2str(errors(i)));
end
fclose(fileID);

%% Organize Files
fOrganizeFiles;

%% Generate Filtered Output Files
fFilterData(outputPath, filterWindow);
fprintf('Program execution finished in %f hours\n', toc(tStart)/3600);