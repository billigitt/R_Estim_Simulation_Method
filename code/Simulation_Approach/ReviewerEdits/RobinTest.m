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

%%
% Workers = 4;
% c = parcluster;
% 
% 
% poolObject = parpool(c,Workers);

Loading = 1;

NumExperiments = 1e3;

SI_Mean_SD = GammaGet(2.6/7, 1.3/7); %Cauchemez
    
    IncidenceInput = struct('R_True', ones(1, 10), 'I_1', 5, 'N_true', ...
        7*24*6, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);

if (Loading==0)

rng(1)
%2 gives one estimate outside interval for Nash
 
NumberofNs = 1; 
VectorofNs = 7;
MeansOutput = zeros(NumberofNs, 10, NumExperiments);
I_data_Matrix = zeros(NumExperiments, 11);

kk = 0;

for i = 1:NumExperiments

    I_data = zeros(1, 11);
    
    disp(i)
    
while ((sum(I_data == 0) > 0) )%|| || (max(I_data)>20

    
    kk = kk+1;
    disp(kk)
    
    R_0 = 1; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/
    
    SI_Mean_SD = GammaGet(2.6/7, 1.3/7); %Cauchemez
    
    IncidenceInput = struct('R_True', ones(1, 10), 'I_1', 5, 'N_true', ...
        7*24*6, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);
    I_data = Incidence_Generator_Week1Uniform(IncidenceInput);
    

    
end

I_data_Matrix(i, :) = I_data;

end

writematrix(I_data_Matrix, 'lowIncidenceExperiments.csv');

end

if Loading == 1
    
    I_data_Matrix = load('lowIncidenceExperiments.csv');
    
end
    
%I_data_Matrix(1, :) = [6     7    10     8     8    17    21    14    14    18    25];

%% Incidence Generation

% FigureGeneration = 'Subplots';
% 
% %Set seed
% rng(1)
% 
% R_0 = 1.5; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/
% 
% R_True = [R_0*ones(1, 5) 0.75*ones(1, 5)];
% 
% Simulations = load('../Cluster/MatFiles/LargeSyntheticExperimentFinal.mat').aevery;
% %Find simulations with max infections less than 800
% LogicalSimsLess800 = max((Simulations.I_data_Matrix)') < 800;
% VecSimsLess800 = 1:100;
% VecSimsLess800 = VecSimsLess800(LogicalSimsLess800);
% 
% MeanEveryP = Simulations.MeansOutput;
% ErrorEveryP = squeeze(sum(abs((MeanEveryP - R_True))./R_True, 2)/length(R_True));
% MeanErrorEveryP = mean(ErrorEveryP, 2);
% %%
% 
% MeanEveryPSimsLess800 = Simulations.MeansOutput;
% MeanEveryPSimsLess800 = MeanEveryPSimsLess800(:, :, LogicalSimsLess800);
% 
% ErrorEveryPSimsLess800 = squeeze(sum(abs((MeanEveryPSimsLess800 - R_True))./R_True, 2)/length(R_True));
% 
% 
% %%
% %Find simulation with the maximum difference between average errors as
% %being the smallest- this will be our chosen comparison
% [~, ChosenIdx] = min(max(abs(ErrorEveryPSimsLess800 - MeanErrorEveryP)));
% 
% %%
% ChosenIdx = VecSimsLess800(ChosenIdx);
% 
% %%
% SI_Mean_SD = GammaGet(2.6/7, 1.3/7);
% 
% IncidenceInput = struct('R_True', [R_0*ones(1, 5) 0.75*ones(1, 5)], 'I_1', 1, 'N_true', ...
%     7*24*6, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);
% 
% I_data = Simulations.I_data_Matrix(ChosenIdx, :);
%%
%Redo inference with this chosen comparison

nashMean = table2array(readtable('meanNashEstimateLowInc.csv'));
nashLower = table2array(readtable('lowerNashEstimateLowInc.csv'));
nashUpper = table2array(readtable('upperNashEstimateLowInc.csv'));

nashMean(:, 1) = [];
nashLower(:, 1) = [];
nashUpper(:, 1) = [];

SimulationInference = cell(NumExperiments, 1);

for i = 358:NumExperiments

    disp(i)
    I_data = I_data_Matrix(i, :);
    disp(I_data)
NumberofPs = [1 7];

InferenceInput = struct('RPosteriorLims', [0 20], 'MatchingPairsPerCore', 250, 'PriorR', ...
    [1 5], 'RPosteriorResolution', 1000, 'I_data', I_data, ...
    'SerialParameters', IncidenceInput.SerialParameters, 'SerialTimeDays',...
    IncidenceInput.SerialTimeDays, 'Spaces', IncidenceInput.Spaces, 'R_True', ...
    IncidenceInput.R_True, 'RelativeThreshold', 0, 'RYLims', [0 2], 'CredibleInterval', 95);

InferenceInput.ComparisonsOriginal = 'Off';
InferenceInput.IncidenceAndTrueR = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'Off';
InferenceInput.SimulationComputation = 'On';

w_Sim = cell(length(NumberofPs), 1);
Means = zeros(length(I_data)-1, length(NumberofPs));
Disag = w_Sim;

%[w_Sim{1}, w_EE, ~, ~, Disag{1}, ~, ~, PlotterStructs{1}] = AnalysisFunction(InferenceInput, 1);

InferenceInput.IncidenceAndTrueR = 'Off';

InferenceInput.IncidenceAndTrueR = 'Off';
InferenceInput.SimulationComputation = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'On';

[w_Sim{7},  ~, Means(:, 7), ~, Disag{7}, ~, ~, SimulationInference{i}] = AnalysisFunction(InferenceInput, NumberofPs(2));



%%

% ciNash = [nashLower(i, 1:10)' nashUpper(i, 1:10)'];
% 
% %%
% figure
% 
% tiledlayout(1, 2, 'TileSpacing','loose')
% nexttile
% PlotterStructs{2}.ComparisonsOriginal = 'Off';
% PlotterStructs{2}.IncidenceAndTrueR = 'On';
% PlotterStructs{2}.ProbabilityDensity = 'Off';
% PlotterStructs{2}.ComparisonsNew = 'Off';
% PlotterComparison(PlotterStructs{2});
% box off
% 
% set(gcf, 'color', 'none') ;
% 
% nexttile
% plotLinesWithCredibleIntervals(nashMean(i, 1:10), ciNash, Means(:, 7), (PlotterStructs{2}.SimulationOutputStruct.CIs)',PlotterStructs{2}.R_True)
% xlim([0.5 11.5])
% xticks(1:11)
% yticks(0:0.5:3)
% box off
% 
% %set(gcf, 'color', 'none')
% set(gcf,'Position',[100 100 1100 400])
end
save('SimulationInference.mat', 'SimulationInference')


function plotLinesWithCredibleIntervals(points1, credibleInterval1, points2, credibleInterval2, true)
% PLOTLINESWITHCREDIBLEINTERVALS plots two sequences of points as lines with shaded credible intervals.
%   plotLinesWithCredibleIntervals(points1, credibleInterval1, points2, credibleInterval2, color1, color2) takes:
%   - 'points1' and 'points2': two sequences of points (e.g., x and y coordinates)
%   - 'credibleInterval1' and 'credibleInterval2': two 2-column matrices representing the credible intervals (lower and upper bounds)
%   - 'color1' and 'color2': strings specifying the colors of the lines and shaded regions for each sequence

    ColourMat = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

    % Plot line 1
    p1 = plot(2:length(points1)+1, points1, 'Color', ColourMat(1, :), 'LineWidth', 2);
    hold on;

    % Plot shaded credible interval 1
    f1 = fill([2:length(points1)+1 length(points1)+1:-1:2], [credibleInterval1(:, 1); flipud(credibleInterval1(:, 2))]', ColourMat(1, :), 'FaceAlpha', 0.5, 'edgecolor', [1 1 1]);

    % Plot line 2
    p2 = plot(2:length(points2)+1, points2, 'Color', ColourMat(2, :), 'LineWidth', 2);
    
    p3 = plot(2:length(true)+1, true, 'Color', 'k', 'LineWidth', 2);

    % Plot shaded credible interval 2
    f2 = fill([2:length(points2)+1 1+length(points2):-1:2], [credibleInterval2(:, 1); flipud(credibleInterval2(:, 2))], ColourMat(2, :), 'FaceAlpha', 0.5, 'edgecolor', [1 1 1]);

    % Set axis labels and title (customize as needed)
    xlabel('X-axis');
    ylabel('Y-axis');

    % Customize additional plot settings if necessary
    grid off;
    legend([p1 p2 p3], "Nash ", "$P=7$", "True $R_t$", 'interpreter', 'latex', 'Location', 'best');
    ylabel('$\hat{R}_t$', 'interpreter', 'latex')
    xlabel('Time ($t$ weeks)', 'interpreter', 'latex')
    hold off;
end