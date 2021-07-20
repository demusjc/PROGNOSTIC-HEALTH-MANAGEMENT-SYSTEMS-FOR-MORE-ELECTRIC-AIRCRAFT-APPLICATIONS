%% Data Analysis
% Collects all gathered data from specified folder for analysis via LRM,
% SVM, ANN, and CNN
% Trains using either random indexes from data (optimalTrain = 1) or every
% 10DegC (=0)

clear;
close all; clc;
tStart = tic;
%% INPUTS
device = 'Infineon';

runLRM = 0;
runSVR = 1;
runANN = 0;
runCNN = 0;

optimalTrain = 1;

addNoise = 1;

%% Import Data
outputFolder = 'C:\Users\Justin Demus\Google Drive\College\Research\Thesis\Thesis Images';
dataPath = ['../Simulation Results/' device '/'];
d = dir([dataPath '*.mat']);
for i = 1:length(d)
    if(~contains(d(i).name, 'Error'))
        load([d(i).folder '/' d(i).name]);
    end
end
response = (20:0.1:150)';

%% Generate Training/Validation Sets
% Train using Random Indexes
trainInd = randperm(length(response), round(0.75*1301));
testInd = setdiff(1:length(response), trainInd);
if(~optimalTrain)
    % Train using every X degC
    trainInd = find(mod(response, 10)==0);
    testInd = setdiff(find(mod(response, 5) ==0), trainInd);
end

%% Linear Regression Model
if(runLRM)
    warningId = 'stats:LinearModel:RankDefDesignMat';
    warning('off', warningId);
    % Original FFT Data
    lrmFFTMdl = fitlm(FFT(trainInd, :), response(trainInd));
    lrmFFTPred = predict(lrmFFTMdl, FFT(testInd,:));
    lrmFFTComp = [response(testInd) lrmFFTPred response(testInd)-lrmFFTPred];
    meanData = mean(abs(lrmFFTComp(:,3)));
    maxData = max(abs(lrmFFTComp(:,3)));
    if(addNoise)
        benchMean = meanData;
        maxAmp = (db2mag(110)*1E-6*50);
        minAmp = (db2mag(49)*1E-6*50);
        amplitude = logspace(log(minAmp)/log(10), log(maxAmp)/log(10), 200);
        errorHistory = zeros(200,2);
        noiseStart = tic;
        for i = 1:length(amplitude)
            amp = amplitude(i);
            noisyFFT = addNoise2Data(TIM, FFT, amp);
            noiseMdl = fitlm(noisyFFT(trainInd, :), response(trainInd));
            noisePred = predict(noiseMdl, noisyFFT(testInd,:));
            noiseComp = [response(testInd), noisePred, response(testInd)-noisePred];
            benchMean = mean(abs(noiseComp(:,3)));
            errorHistory(i,:) = [amp benchMean];
        end
        ind = find(errorHistory(:,1)==0);
        if(~isempty(ind))
            errorHistory = errorHistory(1:find(errorHistory(:,1)==0,1)-1,:);
        end
        toc(noiseStart);
        beep;
        plot(errorHistory(:,1), errorHistory(:,2));
        save([device '.mat'],'errorHistory');
    end
    % Plot FFT Results
    FFTLRM = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 4);
    scatter(response(testInd), lrmFFTPred, '.b', 'LineWidth', 0.5);
    hold off;
    fMUPEL_PLOT('LRM Prediction Results (FFT)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'LRMFFT';
        else
            filename = 'LRMFFTBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    
    fprintf('Original FFT LRM avg Error: %f\n', meanData);
    fprintf('Original FFT LRM max Error: %f\n', maxData);
    lrmYLim = ylim;
    
    % MAF Data
    lrmMAFMdl = fitlm(MAF(trainInd, :), response(trainInd));
    lrmMAFPred = predict(lrmMAFMdl, MAF(testInd,:));
    lrmMAFComp = [response(testInd) lrmMAFPred response(testInd)-lrmMAFPred];
    % Plot MAF Results
    MAFLRM = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 2);
    scatter(response(testInd), lrmMAFPred, '.b', 'LineWidth', 0.5);
    ylim(lrmYLim);
    hold off;
    fMUPEL_PLOT('LRM Prediction Results (MAF)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'LRMMAF';
        else
            filename = 'LRMMAFBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    fprintf('MAF LRM avg Error: %f\n', mean(abs(lrmMAFComp(:,3))));
    fprintf('MAF LRM max Error: %f\n', max(abs(lrmMAFComp(:,3))));
    
    warning('on', 'all');
end

%% Support Vector Machine Regression Model
if(runSVR)
    % Original FFT Data
    svrFFTMdl = fitrsvm(FFT(trainInd, :), response(trainInd), 'Standardize', 'on');
    svrFFTPred = predict(svrFFTMdl, FFT(testInd,:));
    svrFFTComp = [response(testInd) svrFFTPred response(testInd)-svrFFTPred];
    % Find mean/max of results
    meanData = mean(abs(svrFFTComp(:,3)));
    maxData = max(abs(svrFFTComp(:,3)));
    if(addNoise)
        benchMean = meanData;
        maxAmp = (db2mag(110)*1E-6*50);
        minAmp = (db2mag(49)*1E-6*50);
        amplitude = logspace(log(minAmp)/log(10), log(maxAmp)/log(10), 200);
        errorHistory = zeros(200,2);
        noiseStart = tic;
        for i = 1:length(amplitude)
            amp = amplitude(i);
            noisyFFT = addNoise2Data(TIM, FFT, amp);
            noiseMdl = fitrsvm(noisyFFT(trainInd, :), response(trainInd), 'Standardize', 'on');
            noisePred = predict(noiseMdl, noisyFFT(testInd,:));
            noiseComp = [response(testInd), noisePred, response(testInd)-noisePred];
            benchMean = mean(abs(noiseComp(:,3)));
            errorHistory(i,:) = [amp benchMean];
        end
        ind = find(errorHistory(:,1)==0);
        if(~isempty(ind))
            errorHistory = errorHistory(1:find(errorHistory(:,1)==0,1)-1,:);
        end
        toc(noiseStart);
        beep;
        plot(errorHistory(:,1), errorHistory(:,2));
        save([device '.mat'],'errorHistory');
    end
    % Plot FFT Results
    FFTSVR = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 4);
    scatter(response(testInd), svrFFTPred, '.b', 'LineWidth', 0.5);
    hold off;
    fMUPEL_PLOT('SVR Prediction Results (FFT)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'SVRFFT';
        else
            filename = 'SVRFFTBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    
    fprintf('Original FFT SVR avg Error: %f\n', mean(abs(svrFFTComp(:,3))));
    fprintf('Original FFT SVR max Error: %f\n', max(abs(svrFFTComp(:,3))));
    svrYLim = ylim;
    
    % MAF Data
    svrMAFMdl = fitrsvm(MAF(trainInd, :), response(trainInd), 'Standardize', 'on');
    svrMAFPred = predict(svrMAFMdl, MAF(testInd,:));
    svrMAFComp = [response(testInd) svrMAFPred response(testInd)-svrMAFPred];
    % Plot MAF Results
    MAFSVR = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 2);
    scatter(response(testInd), svrMAFPred, '.b', 'LineWidth', 0.5);
    ylim(svrYLim);
    hold off;
    fMUPEL_PLOT('SVR Prediction Results (MAF)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'SVRMAF';
        else
            filename = 'SVRMAFBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    
    fprintf('MAF SVR avg Error: %f\n', mean(abs(svrMAFComp(:,3))));
    fprintf('MAF SVR max Error: %f\n', max(abs(svrMAFComp(:,3))));
end

%% Artificial Neural Network
if(runANN)
    annFFTMdl = fitrnet(FFT(trainInd,:), response(trainInd), 'Standardize', true);
    annFFTPred = predict(annFFTMdl, FFT(testInd,:));
    annFFTComp = [response(testInd) annFFTPred response(testInd)-annFFTPred];
    
    meanData = mean(abs(annFFTComp(:,3)));
    maxData = max(abs(annFFTComp(:,3)));
    if(addNoise)
        benchMean = meanData;
        maxAmp = (db2mag(110)*1E-6*50);
        minAmp = (db2mag(49)*1E-6*50);
        amplitude = logspace(log(minAmp)/log(10), log(maxAmp)/log(10), 50);
        errorHistory = zeros(50,2);
        noiseStart = tic;
        for i = 1:length(amplitude)
            amp = amplitude(i);
            noisyFFT = addNoise2Data(TIM, FFT, amp);
            noiseMdl = fitrnet(noisyFFT(trainInd,:), response(trainInd), 'Standardize', true);
            noisePred = predict(noiseMdl, noisyFFT(testInd,:));
            noiseComp = [response(testInd), noisePred, response(testInd)-noisePred];
            benchMean = mean(abs(noiseComp(:,3)));
            errorHistory(i,:) = [amp benchMean];
        end
        ind = find(errorHistory(:,1)==0);
        if(~isempty(ind))
            errorHistory = errorHistory(1:find(errorHistory(:,1)==0,1)-1,:);
        end
        toc(noiseStart);
        beep;
        plot(errorHistory(:,1), errorHistory(:,2));
        save([device '.mat'],'errorHistory');
    end
    % Plot FFT Results
    FFTANN = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 4);
    scatter(response(testInd), annFFTPred, '.b', 'LineWidth', 0.5);
    hold off;
    fMUPEL_PLOT('ANN Prediction Results (FFT)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'ANNFFT';
        else
            filename = 'ANNFFTBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    
    fprintf('Original FFT ANN avg Error: %f\n', mean(abs(annFFTComp(:,3))));
    fprintf('Original FFT ANN max Error: %f\n', max(abs(annFFTComp(:,3))));
    annYLim = ylim;
    
    % MAF Data
    annMAFMdl = fitrnet(MAF(trainInd,:), response(trainInd), 'Standardize', true);
    annMAFPred = predict(annMAFMdl, MAF(testInd,:));
    annMAFComp = [response(testInd) annMAFPred response(testInd)-annMAFPred];
    % Plot MAF Results
    MAFANN = figure;
    hold on;
    plot(response(testInd), response(testInd), 'r', 'LineWidth', 2);
    scatter(response(testInd), annMAFPred, '.b', 'LineWidth', 0.5);
    ylim(annYLim);
    hold off;
    fMUPEL_PLOT('ANN Prediction Results (MAF)', ['Tested Temperature [' char(176) 'C]'], ['Predicted Result [' char(176) 'C]']);
    if(contains(device, 'Cree'))
        if(optimalTrain)
            filename = 'ANNMAF';
        else
            filename = 'ANNMAFBAD';
        end
        f = gcf;
        saveas(f,[outputFolder '\' filename], 'tiff');
        savefig(f,[outputFolder '\' filename]);
    end
    
    fprintf('MAF ANN avg Error: %f\n', mean(abs(annMAFComp(:,3))));
    fprintf('MAF ANN max Error: %f\n', max(abs(annMAFComp(:,3))));
end

%% Convolutional Neural Network
if(runCNN)
    % Import CWT Files
    dataPath = [dataPath 'CWT Files/'];
    d = dir([dataPath '*.mat']);
    load([d(1).folder '/' d(1).name]);
    CWTData = zeros(size(cwtData, 1), size(cwtData, 2)+5, 1, length(d));
    minSize = size(cwtData,2);
    cwtStart = tic;
    for i = 1:length(d)
        minSize = min(minSize, size(CWTData,2));
        load([d(i).folder '/' d(i).name]);
        CWTData(:,1:size(cwtData,2),:,i) = cwtData;
    end
    CWTData = CWTData(:,1:minSize,:,:);
    toc(cwtStart);
    
    % Design Network
    layers = [
        imageInputLayer([size(CWTData,1),size(CWTData,2),1])
        fullyConnectedLayer(10)
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer(2,'Stride',2, 'Padding', 'Same')
        batchNormalizationLayer
        reluLayer
        fullyConnectedLayer(1)
        regressionLayer];
    options = trainingOptions('sgdm', ...
        'MaxEpochs',30, ...
        'Plots','training-progress', ...
        'ExecutionEnvironment', 'auto', ...
        'ValidationData',{CWTData(:,:, :,testInd), response(testInd)},...
        'Verbose',false);
    imageSize = [size(CWTData,1) size(CWTData,2) 1];
    augimds = augmentedImageDatastore(imageSize, CWTData(:,:,:,trainInd), response(trainInd));
    net = trainNetwork(augimds, layers, options);
end

toc(tStart);

%% Helper Functions
function noiseData = addNoise2Data(cleanTD, cleanFFT, noiseAmplitude)
noiseData = zeros(size(cleanFFT,1), size(cleanFFT,2));
for i=1:size(cleanTD,1)
    [temp, ~] = fCalculateFFT(cleanTD(i,:) + noiseAmplitude*rand(1,size(cleanTD,2)), 1/8E-9);
    noiseData(i,:) = smoothdata(temp, 'movmean', 85);
end
end