%% fProcessLTSpiceData
% Accepts LTSpice generated .RAW files for extraction of V_LISN_p data & conversion into MATLAB struct w/
% Time Domain Data and Frequency Domain Data (FD2 & FD3 have unknown
% purpose) - Created by Mark Scott
function STRUCT = fProcessLTSpiceData(RAW_FILE, timeStep, fn)

% Find Vlisn_p Data
for i=1:RAW_FILE.num_variables
    if (strfind(RAW_FILE.variable_name_list{i},'lisn_p'))
        break;
    end
end

STRUCT.TD   = RAW_FILE.variable_mat(i,:);
STRUCT.Time = RAW_FILE.time_vect;

% Resample Data LTSPICE Data
if(nargin > 1)
    Tsample = timeStep;
else
    Tsample = 1e-9;
end
fsample = 1/Tsample;
[STRUCT.TD, STRUCT.Time] = resample(STRUCT.TD, STRUCT.Time, fsample);

% CALCULATE THE FFT
[STRUCT.FD, STRUCT.Freq]      = fCalculateFFT(STRUCT.TD, fsample);
if (length(STRUCT.TD) > 1e3)
    STRUCT.TD(1e6+1:end)=[];
else
    error('Simulation was not long enough to do a proper frequency transform.');
end
%[STRUCT.FD2, STRUCT.Freq2]    = fCalculateFFT(STRUCT.TD, fsample);          % dF= 1 kHz
%[STRUCT.FD3, STRUCT.Freq3]    = fCalculateFFT(STRUCT.TD(1:1e5), fsample);   % dF= 10 kHz

if (nargin > 2)
    % ASSIGN FILENAME
    STRUCT.Fname = fn;
end

end