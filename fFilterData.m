%% Create Filtered Data Arrays
% Collects all gathered data from specified folder to be processed through
% various filters and saved back to results root folders

function fFilterData(dataPath, filtWindow)

%% Import Data
d = dir([dataPath 'MAT Files\*.mat']);
dNames = {d.name};
for i = 1:length(dNames)
    str = convertStringsToChars(string(dNames(i)));
    dNames(i) = {str2double(str((1:strfind(str, 'C')-1)))};
end
dNames = cell2mat(dNames);
[~, idx] = sort(dNames);
d = d(idx);
load([d(1).folder '/' d(1).name], 'Data');
defaultLength = round(length(Data.FD)*1.005);

%% Preallocate Predictor Arrays
% Moving Average Filter
TIM = Data.TD;
FFT = zeros(length(d), defaultLength);
MAF = zeros(length(d), defaultLength);
%MAG = zeros(length(d), defaultLength);
%LOW = zeros(length(d), defaultLength);
%LOE = zeros(length(d), defaultLength);
%SGF = zeros(length(d), defaultLength);

%% Filter Data
for i=1:length(d)
    file = d(i);
    load([file.folder '/' file.name], 'Data');
    % Standard Time Domain
    TIM(i, 1:length(Data.TD)) = Data.TD;
    
    % Standard FFT
    FFT(i, 1:length(Data.FD)) = Data.FD;
    
    % MAF: Moving Average Filter
    MAF(i, 1:length(Data.FD)) = smoothdata(Data.FD, 'movmean', filtWindow);
    
    % MAG: Moving Average Filter (Gaussian Window)
    %MAG(i, 1:length(Data.FD)) = smoothdata(Data.FD, 'gaussian', filtWindow);
    
    % LOW: Robust Lowess (Locally Weighted Linear Regression)
    %LOW(i, 1:length(Data.FD)) = smoothdata(Data.FD, 'rlowess', filtWindow);
    
    % LOE: Robust Loess (Locally Weighted Quadratic Regression)
    %LOE(i, 1:length(Data.FD)) = smoothdata(Data.FD, 'rloess', filtWindow);
    
    % SGF: Savitzky-Golay Filter
    %SGF(i, 1:length(Data.FD)) = smoothdata(Data.FD, 'sgolay', filtWindow);
end

%% Save Data

lastInd = find(all(FFT==0), 1);
FFT = FFT(:, 1:lastInd-1);
MAF = MAF(:, 1:lastInd-1);
%MAG = MAG(:, 1:lastInd-1);
%LOW = LOW(:, 1:lastInd-1);
%LOE = LOE(:, 1:lastInd-1);
%SGF = SGF(:, 1:lastInd-1);
freq = Data.Freq;
tim = Data.Time;

save([dataPath 'time.mat'], 'tim');
save([dataPath 'freq.mat'], 'freq');
save([dataPath 'TIM.mat'], 'TIM', '-v7.3');
save([dataPath 'FFT.mat'], 'FFT', '-v7.3');
save([dataPath 'MAF.mat'], 'MAF', '-v7.3');
%save([dataPath 'MAG.mat'], 'MAG', '-v7.3');
%save([dataPath 'LOW.mat'], 'LOW', '-v7.3');
%save([dataPath 'LOE.mat'], 'LOE', '-v7.3');
%save([dataPath 'SGF.mat'], 'SGF', '-v7.3');

end