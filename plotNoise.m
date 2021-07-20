close all;
d = dir('./Noise files/ANN/*.mat');
hold on;
for i = 1:length(d)
    load([d(i).folder '/' d(i).name]);
    errorHistory(:,1) = mag2db(errorHistory(:,1)/50/1E-6);
    plot(errorHistory(:,1),errorHistory(:,2));
end
hold off;
xlims = xlim;
xlim([min(errorHistory(:,1)) xlims(2)]);
fMUPEL_PLOT('ANN Noise Immunity Results', 'Max Noise Amplitude [dbμA]', ['ΔAbsolute Error [' char(176) 'C]']);
names = {d(1).name; d(2).name; d(3).name; d(4).name};
for i = 1:length(names)
    test = char(names(i));
    names(i) = {string(test(1:strfind(test, '.')-1))};
end
legend(names, 'Location', 'northwest');