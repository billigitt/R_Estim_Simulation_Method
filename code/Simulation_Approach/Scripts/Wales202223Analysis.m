clear; clc; close all
set(0,'DefaultTextInterpreter', 'latex')
set(0,'defaultAxesTickLabelInterpreter','latex');
set(0, 'defaultLegendInterpreter','latex')
set(0, 'defaultaxesfontsize', 18)
set(0, 'defaultlinelinewidth', 1.5)
set(0,'DefaultFigureWindowStyle','docked')

addpath(genpath('../../Functions'))

%% Incidence Generation

FigureGeneration = 'Subplots';
%FigureGeneration = 'Figures';

%Set seed so that inference (which has stochastic since uses ABC) is
%identical each time
rng(36)

R_0 = 1.5; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/

SI_Mean_SD = GammaGet(2.6/7, 1.3/7);

%Read in incidence data
FileName = '../RealWorldData/ILI_Wales_2022-23.csv';
Data = readtable(FileName);
I_data_w = (Data.Incidence)';
%%

%We repeat analysis for values of P: 1 through to 7.
NumberofPs = 1:7;

InferenceInput = struct('RPosteriorLims', [0 20], 'MatchingPairsPerCore', 250, 'PriorR', ...
    [1 5], 'RPosteriorResolution', 1000, 'I_data', I_data_w, ...
    'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays',...
    10, 'Spaces', 1e2, 'R_True', ...
    [], 'RelativeThreshold', 0, 'RYLims', [0 2], 'CredibleInterval', 95);

%Settings for inference and plots
InferenceInput.ComparisonsOriginal = 'Off';
InferenceInput.IncidenceAndTrueR = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'Off';
InferenceInput.SimulationComputation = 'On';


w_Sim = cell(NumberofPs(end), 1);
Means = zeros(length(I_data_w)-1, NumberofPs(end)); %Not sure this matrix has right size... what should dimension 1 be?
Disag = w_Sim;
CIs = zeros(2, length(I_data_w)-1, NumberofPs(end));

PlotterStructs = cell(1, NumberofPs(end));

for i = NumberofPs
    
    [w_Sim{1}, w_EE, ~, ~, Disag{1}, ~, ~, PlotterStructs{i}] = AnalysisFunction(InferenceInput, i);
    xlim([0.5 11.5])
    
end

save('Wales_2022-23_AnalysisExtra.mat', 'PlotterStructs')

