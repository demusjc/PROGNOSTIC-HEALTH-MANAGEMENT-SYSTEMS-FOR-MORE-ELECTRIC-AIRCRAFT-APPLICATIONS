%% fCalculateVariables
% Conducts LTSpice Simulation for a given temperature (Celsius) and save output files
% --> Attempts to complete an LTSpice Simulation 3 times before failure is
% reported as determined by simTime (which is found experimentally)
%% INITIALIZE:
function SimResults  = fCalculateVariables(temp, headerName, simTime, outputFolder, devicePref)
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
    SysCmd = ['START ' LTpath ' -Run -b "' fnNETName '"'];
    system(SysCmd);
    pause(60*(simTime*(1+(attempt-1)*0.25)));
    [~, checkCompleted] = system('tasklist /FI "IMAGENAME eq XVIIx64.exe" 2>NUL');
    if(contains(checkCompleted, 'PID'))
        %% Report Error Data
        system('..\GenerateLTSpiceData\SysCmd Code\closeSims.bat');
        fprintf('LTSpice DEFCON Error (Attempt %s) - %sC\n', num2str(attempt), num2str(temp));
        attempt = attempt + 1;
    else
        %% READ DATA
        % Move Simulation Result Files
        fprintf('LTSPICE Completed: %sC\n', num2str(temp));
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

SimResults = fProcessLTSpiceData(SimData);
end
