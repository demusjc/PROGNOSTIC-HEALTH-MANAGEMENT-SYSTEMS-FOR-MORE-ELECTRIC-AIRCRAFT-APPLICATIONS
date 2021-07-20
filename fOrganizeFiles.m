%% Organize Files
% Sorts through LTSpice generated results to move files to their correct
% locations

function fOrganizeFiles
%% Initialize
files = dir('..\BuckSimResults\NET Files\');
rawDir = '..\BuckSimResults\RAW Files\';
logDir = '..\BuckSimResults\LOG Files\';

%% Check Files
for i = 1:length(files)
    file = files(i);
    if(contains(file.name, '.op.raw'))
        delete([file.folder '\' file.name]);
    elseif(contains(file.name, '.raw'))
        movefile([file.folder '\' file.name], rawDir, 'f');
    elseif(contains(file.name, '.log'))
        movefile([file.folder '\' file.name], logDir);
    end
end
end