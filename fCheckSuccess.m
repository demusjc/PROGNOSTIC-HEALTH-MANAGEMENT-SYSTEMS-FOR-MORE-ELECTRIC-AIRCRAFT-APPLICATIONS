%% Check Success
% Checks all data files in "BuckSimResults\MAT Files\" to determine how
% many simulations succeeded (NO DEFCONS) or failed

function [errorList] = fCheckSuccess(outputFolder)
%% Initialize
files = dir([outputFolder 'MAT Files\*.mat']);
fail = 0;
success = 0;
errorList = zeros(250, 2);

%% Check Files
for i = 1:length(files)
    file = files(i);
    load([file.folder '\' file.name], 'Data');
    try
        if(Data == 0)
            fail = fail + 1;
            errorList(i, :) = [str2double(file.name(1:end-5)), 1];
        end
    catch
        success = success + 1;
    end
end

%% Output Results and Errors
fprintf('Success Rate: %s\n', num2str(success/(success+fail)));
errorList(errorList(:,2)==0,:) = [];
errorList = errorList(:,1);
errorList = sort(errorList);
end

