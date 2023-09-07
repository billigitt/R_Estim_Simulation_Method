%clear; clc; close all
set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultTextInterpreter', 'none')
set(0,'defaultAxesTickLabelInterpreter','none');
set(0, 'defaultLegendInterpreter','none')
set(0, 'defaultaxesfontsize', 18)
set(0, 'defaultlinelinewidth', 1.5)

set(0, 'DefaultAxesFontName', 'aakar');
set(0, 'DefaultTextFontName', 'aakar');
set(0, 'defaultUicontrolFontName', 'aakar');
set(0, 'defaultUitableFontName', 'aakar');
set(0, 'defaultUipanelFontName', 'aakar');

addpath(genpath('../../Functions'))

%% File description

%This file generates Figure S2 in the Supplementary Manuscript. By changing
%FigureGeneration to 'Figures', you can also get all the panels outputted
%separately.

%% Load pre-analysed MAT-file

FigureGeneration = 'Subplots';

LoadingStruct = load('FigureS2Analysis.mat');

PlotterStructs = LoadingStruct.PlotterStructs;

NumberofPs = 1:7;

if isequal(FigureGeneration, 'Subplots')
   
    figure
    tiledlayout(2, 2, 'TileSpacing','loose')
    
end

k = 0;

%Here, we plot example inferences temporally for different values of P

for i = [1 3 5]
    
    k = k+1;
    
    if isequal(FigureGeneration, 'Subplots')
    
        nexttile
        
    elseif isequal(FigureGeneration, 'Figures')
    
        figureLoad
        
    end
    
    PlotterComparison(PlotterStructs{i});
    box off
end

%Load inference structure for the hundred different simulations that we
%ran, and plot the final panel to visualise the range of inference errors
OneHundredSimInferences = load('../Cluster/MatFiles/LargeSyntheticExperimentFinal.mat').aevery;
Inferences = OneHundredSimInferences.MeansOutput;
lengthR = length(PlotterStructs{1}.R_True);
MeanBars = 100*mean(squeeze(sum(abs(Inferences - PlotterStructs{1}.R_True)./(lengthR*PlotterStructs{1}.R_True), 2)), 2);

Means = [];

for i = 1:length(PlotterStructs)
   
    Means = [Means; PlotterStructs{i}.SimulationOutputStruct.Means];
    
end

SingleError = sum(abs(Means - PlotterStructs{1}.R_True)./(PlotterStructs{1}.R_True), 2)/lengthR;

SimulationErrors = squeeze(100*sum(abs(OneHundredSimInferences.MeansOutput-PlotterStructs{1}.R_True)./PlotterStructs{1}.R_True, 2)/lengthR);

ErrorDistributions = sort(SimulationErrors, 2);

ErrorHigher = ErrorDistributions(:, 96)' - MeanBars';
ErrorLower = MeanBars' - ErrorDistributions(:, 5)';
%%
if isequal(FigureGeneration, 'Subplots')
    
        nexttile
        
    elseif isequal(FigureGeneration, 'Figures')
    
        figure
        
end
h(1) = bar(NumberofPs, MeanBars');
hold on
h(3) = bar(NumberofPs, 100*SingleError', 'BarWidth', 0.4);
h(2) = errorbar(NumberofPs, MeanBars', ErrorLower, ErrorHigher, "Color", "black");
h(2).LineStyle = 'none';

xlabel('$P$', 'interpreter', 'latex')
ylabel("Average weekly error (%)")

l = legend(h([1 3]), "100 simulations", 'Simulated dataset');

xlim([0.5 7.5])

set(gcf,'Position',[100 100 1000 750])
set(gcf, 'color', 'none') ;
box off
