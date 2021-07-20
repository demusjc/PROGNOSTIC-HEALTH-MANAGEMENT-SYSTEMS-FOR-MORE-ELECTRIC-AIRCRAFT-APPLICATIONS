close all;
dRAW = dir([pwd '\*.raw']);
dMAT = dir([pwd '\*.mat']);

for i = 1:length(dRAW)
    SimData = fLTspice2Matlab(dRAW(i).name);
    SimResults = fProcessLTSpiceData(SimData, 1E-9);
    ind = strfind(dRAW(i).name, '.raw');
    save([dRAW(i).name(1:strfind(dRAW(i).name, '.raw')-1) '.mat']);
end

hold on;
for i = 1:length(dMAT)
    load([dMAT(i).folder '\' dMAT(i).name]);
    plot(SimResults.Freq, smoothdata(SimResults.FD, 'movmean', 85));
    %plot(SimResults.Freq, SimResults.FD);
    dMAT = dir([pwd '\*.mat']);
end
hold off;
set(gca, 'XScale', 'log');
xlim([SimResults.Freq(1) SimResults.Freq(end)]);
xticklabels({'10 kHz', '100 kHz', '1 MHz', '10 MHz', '100 MHz'});
legend(['20' char(176) 'C'], ['30' char(176) 'C'], ['40' char(176) 'C'], ['50' char(176) 'C'], ['60' char(176) 'C']);
fMUPEL_PLOT('CM Equiv. Circuit Conducted Emissions (Filtered)', 'Frequency [Hz]', 'Noise Magnitude [dBV]');