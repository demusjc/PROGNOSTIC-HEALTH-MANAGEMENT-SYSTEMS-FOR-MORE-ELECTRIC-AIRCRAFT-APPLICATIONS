matPath = '..\..\Simulation Results\Cree\MAT Files\*.mat';
cwtPath = '..\..\Simulation Results\Cree\CWT Files';
d = dir(matPath);

for i = 1:length(d)
    load([d(i).folder '\' d(i).name]);
    cwtData = abs(cwt(Data.TD, 100E-6));
    save([cwtPath '\' d(i).name], 'cwtData');
    fprintf('File %s/%s completed\n', num2str(i), num2str(length(d)));
end
