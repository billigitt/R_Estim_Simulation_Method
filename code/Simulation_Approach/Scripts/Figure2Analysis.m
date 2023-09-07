clear; clc; close all
set(0,'DefaultTextInterpreter', 'latex')
set(0,'defaultAxesTickLabelInterpreter','latex');
set(0, 'defaultLegendInterpreter','latex')
set(0, 'defaultaxesfontsize', 18)
set(0, 'defaultlinelinewidth', 1.5)

addpath(genpath('../../Functions'))
%% File Description
%In this file, we perform the analysis that generates Figure 2 in the
%manuscript. This means finding a suitable example simulation to compare
% against aggregate inference, as well as looking at example temporal
% inference.

%% Incidence Generation

FigureGeneration = 'Subplots';

%Set seed
rng(1)

R_0 = 1.5; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/

R_True = [R_0*ones(1, 5) 0.75*ones(1, 5)];

Simulations = load('../Cluster/MatFiles/LargeSyntheticExperimentFinal.mat').aevery;
%Find simulations with max infections less than 800
LogicalSimsLess800 = max((Simulations.I_data_Matrix)') < 800;
VecSimsLess800 = 1:100;
VecSimsLess800 = VecSimsLess800(LogicalSimsLess800);

MeanEveryP = Simulations.MeansOutput;
ErrorEveryP = squeeze(sum(abs((MeanEveryP - R_True))./R_True, 2)/length(R_True));
MeanErrorEveryP = mean(ErrorEveryP, 2);
%%

MeanEveryPSimsLess800 = Simulations.MeansOutput;
MeanEveryPSimsLess800 = MeanEveryPSimsLess800(:, :, LogicalSimsLess800);

ErrorEveryPSimsLess800 = squeeze(sum(abs((MeanEveryPSimsLess800 - R_True))./R_True, 2)/length(R_True));


%%
%Find simulation with the maximum difference between average errors as
%being the smallest- this will be our chosen comparison
[~, ChosenIdx] = min(max(abs(ErrorEveryPSimsLess800 - MeanErrorEveryP)));

%%
ChosenIdx = VecSimsLess800(ChosenIdx);

%%
SI_Mean_SD = GammaGet(2.6/7, 1.3/7);

IncidenceInput = struct('R_True', [R_0*ones(1, 5) 0.75*ones(1, 5)], 'I_1', 1, 'N_true', ...
    7*24*6, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);

I_data = Simulations.I_data_Matrix(ChosenIdx, :);
%%
%Redo inference with this chosen comaparison
NumberofPs = [1 2 3 4 5 6 7];

InferenceInput = struct('RPosteriorLims', [0 20], 'MatchingPairsPerCore', 125, 'PriorR', ...
    [1 5], 'RPosteriorResolution', 1000, 'I_data', I_data, ...
    'SerialParameters', IncidenceInput.SerialParameters, 'SerialTimeDays',...
    IncidenceInput.SerialTimeDays, 'Spaces', IncidenceInput.Spaces, 'R_True', ...
    IncidenceInput.R_True, 'RelativeThreshold', 0, 'RYLims', [0 2], 'CredibleInterval', 90);

InferenceInput.ComparisonsOriginal = 'Off';
InferenceInput.IncidenceAndTrueR = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'Off';
InferenceInput.SimulationComputation = 'On';

w_Sim = cell(length(NumberofPs), 1);
Means = zeros(length(I_data)-1, length(NumberofPs)); %Not sure this matrix has right size... what should dimension 1 be?
Disag = w_Sim;

PlotterStructs = cell(1, 2);

[w_Sim{1}, w_EE, ~, ~, Disag{1}, ~, ~, PlotterStructs{1}] = AnalysisFunction(InferenceInput, 1);

InferenceInput.IncidenceAndTrueR = 'Off';

InferenceInput.IncidenceAndTrueR = 'Off';
InferenceInput.SimulationComputation = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'On';

[w_Sim{7},  ~, Means(:, 7), ~, Disag{7}, ~, ~, PlotterStructs{2}] = AnalysisFunction(InferenceInput, NumberofPs(7));

save('Figure2Analysis.mat', 'PlotterStructs')
