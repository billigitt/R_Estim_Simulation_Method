clear; clc; close all
set(0,'DefaultTextInterpreter', 'latex')
set(0,'defaultAxesTickLabelInterpreter','latex');
set(0, 'defaultLegendInterpreter','latex')
set(0, 'defaultaxesfontsize', 18)
set(0, 'defaultlinelinewidth', 1.5)
set(0,'DefaultFigureWindowStyle','docked')

addpath(genpath('../../Functions'))

%% File Description

%This file generates the 'Wales_2019-20_Analysis.mat' file that contains
%the small-value partitioning analysis. This is then combined with the
%'Cluster/Wales_2019-20_BigCalcFinal.mat' file to create the Wales
%2019-2020 figures.

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

%We repeat analysis for values of P: 1 through to 7.
NumberofPs = [1 2 3 4 5 6 7];

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

matchings = [2000 5000];

PlotterStructs = cell(1, length(matchings));

for i = 1:length(matchings)
    disp(i)
    tic
    InferenceInput.MatchingPairsPerCore = matchings(i)/4;
    
    [w_Sim{1}, w_EE, ~, ~, Disag{1}, ~, ~, PlotterStructs{i}] = AnalysisFunction(InferenceInput, 7);
    toc
end

%Save file in same directory
save('Wales_2022-23_AnalysisVaryM.mat', 'PlotterStructs')

