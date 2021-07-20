%% Measure execution time of one simulation
% Approximates the amount of time necessary to complete all
% GenerateSpiceData simulations

%% RUNNER

tic;
system('START /WAIT C:\"Program Files"\LTC\LTspiceXVII\XVIIx64.exe -Run -b "C:\Users\Justin Demus\Google Drive\College\Research\Justin Demus\Simulations\GenerateLTSpiceData\NetlistHeader\syncBuck_UnitedSiC_Base.NET"');
toc;