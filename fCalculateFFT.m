function    [fDATA, FREQ] = fCalculateFFT(tDATA, FS, UNITS)
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  PURPOSE: COMPUTES THE FFT OF TIME DOMAIN DATA.  IT WAS CREATED TO
%  EVALUATE LTSPICE DATA.
%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  - DATE -    VER  - AUTHOR        - ACTION
%  2019-06-29  1.0  - Mark Scott    - Created code for JESTPE
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if nargin < 3
        UNITS = 'dB';
    end
    
    %Ts      = 1/FS;         % Sampling Frequency
    L       = length(tDATA); % Length of Data
    %t       = (0:L-1)*Ts;   % Array of Time
    
    % COMPUTE THE FFT
    fDATA = abs(fft(tDATA)/L);
    % ONLY USE THE FIRST HALF
    fDATA = fDATA(1:floor(L/2+1));
    % CREATE THE FREQUENCY ARRAY
    FREQ = FS*(0:(L/2))/L;
    
    % CONVERTER TO dBuV
    if(strcmpi(UNITS, 'dBµV'))
        fDATA = 20*log10(fDATA./1E-6);
    elseif(strcmpi(UNITS, 'dBmV'))
        fDATA = 20*log10(fDATA./1E-3);
    elseif(strcmpi(UNITS, 'dB'))
        fDATA = mag2db(fDATA);
    end
end