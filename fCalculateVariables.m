%% fCalculateVariables
% Conducts LTSpice Simulation for a given temperature (Celsius) and save output files
% --> Attempts to complete an LTSpice Simulation 3 times before failure is
% reported as determined by simTime (which is found experimentally)

function SimResults  = fCalculateVariables(temp, headerName, simTime, outputFolder, devicePref)
%% INITIALIZE:
system('..\GenerateLTSpiceData\SysCmd Code\closeSims.bat');
%% FILE PATHS:
NETDirectory = [outputFolder 'NET Files\'];
RAWDirectory = [outputFolder 'RAW Files\'];
LOGDirectory = [outputFolder 'LOG Files\'];
NETName = [num2str(temp) 'C'];
fnNETName = [NETDirectory NETName '.NET'];
fnLOGName = [NETDirectory NETName '.LOG'];
fnNetlistHeader = headerName;

fCreateNETLIST(fnNETName, fnNetlistHeader, temp, devicePref);

LTpath = 'C:\"Program Files"\LTC\LTspiceXVII\XVIIx64.exe';
SysCmd = ['START ' LTpath ' -Run -b "' fnNETName '"'];
checkCompleted = 'PID';
%% EXECUTE COMMAND
success = 0;
attempt = 1;
while(success == 0)
    % Indicate Failure after 3rd attempt
    if(attempt>3)
        SimResults = 0;
        fprintf('LTSPICE Simulation FAILED: %sC\n', temp);
        return;
    end
    % Start LTSpice Simulation
    progStart = tic;
    system(SysCmd);
    while(contains(checkCompleted, 'PID') && toc(progStart) < 60*(simTime*(1+(attempt-1)*0.25)))
        [~, checkCompleted] = system('tasklist /FI "IMAGENAME eq XVIIx64.exe" 2>NUL');
    end
    if(contains(checkCompleted, 'PID'))
        %% Report Error Data
        system('..\GenerateLTSpiceData\SysCmd Code\closeSims.bat');
        fprintf('LTSpice DEFCON Error (Attempt %s) - %sC\n', num2str(attempt), num2str(temp));
        attempt = attempt + 1;
    else
        %% READ DATA
        % Move Simulation Result Files
        fprintf('LTSPICE Completed: %sC in %f seconds\n', num2str(temp), toc(progStart));
        fnRAWName = [NETDirectory NETName '.RAW'];
        movefile(fnRAWName, RAWDirectory, 'f');
        fnRAWName = [RAWDirectory NETName '.RAW'];
        delete([NETDirectory NETName '.OP.RAW']);
        movefile(fnLOGName, LOGDirectory, 'f');
        
        %% Process Data
        try
            SimData = fLTspice2Matlab(fnRAWName);
            success = 1;
        catch
            fprintf('LTspice2Matlab error - %sC\n', num2str(temp));
            attempt = attempt + 1;
        end
    end
end
%% Get Sample Rate
fid_r = fopen(fnNetlistHeader);        % Contains header file for netlist.
%    Get First Line
Hline = fgetl(fid_r);
while (~isequal(Hline,-1) || isempty(Hline))
    if(contains(Hline, '.tran'))
        ind = strfind(Hline, ' ');
        if(length(ind) == 4)
            timeStepStr = Hline(ind(end)+1:end);
        else
            timeStepStr = Hline(ind(4)+1:ind(5));
        end
        timeStepStr = replace(timeStepStr, 'm', 'E-3');
        timeStepStr = replace(timeStepStr, 'u', 'E-6');
        timeStepStr = replace(timeStepStr, 'μ', 'E-6');
        timeStepStr = replace(timeStepStr, 'n', 'E-9');
        timeStepStr = replace(timeStepStr, 'p', 'E-12');
        timeStepStr = replace(timeStepStr, 'f', 'E-15');
        maxTimeStep = str2double(timeStepStr);
    end
    Hline = fgetl(fid_r);
end
fclose(fid_r);

SimResults = fProcessLTSpiceData(SimData, maxTimeStep);
end
