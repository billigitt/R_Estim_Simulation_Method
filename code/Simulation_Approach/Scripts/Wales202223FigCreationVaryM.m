clear; clc;
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

addpath(genpath('../../Functions'))%% File Description
%This file generates both figures used in the manuscript for the ILI
%real-world data from the Wales 2019-20 data-set. By changing
%FigureGeneration to 'Figures', you can also get all the panels outputted
%separately.

%% File Description
%This file generates both figures used in the manuscript for the ILI
%real-world data from the Wales 2019-20 data-set. By changing
%FigureGeneration to 'Figures', you can also get all the panels outputted
%separately.

ColourMat = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
%% Load data

FigureGeneration = 'Subplots';
%FigureGeneration = 'Figures'

LoadingStruct = load('Wales_2022-23_AnalysisVaryM.mat');
PlotterStructs = LoadingStruct.PlotterStructs;

ActualAnalysis = load('../Cluster/MatFiles/Wales_2022-23_Analysis.mat');

figure

if isequal(FigureGeneration, 'Subplots')
    
    tiledlayout(1,2, 'TileSpacing','loose')
    
end

k = 0;

CIs = ActualAnalysis.PlotterStructs{7}.SimulationOutputStruct.CIs;
Means = ActualAnalysis.PlotterStructs{7}.SimulationOutputStruct.Means;
    
daysflipCI = [1:size(CIs, 2), size(CIs, 2):-1:1];
inBetweenCI = [CIs(2, :), fliplr(CIs(1, :))];
    
if isequal(FigureGeneration, 'Subplots')
        
        nexttile
        
elseif isequal(FigureGeneration, 'Figures')
    
     figure
        
end
hold on
h(1) = plot(2:length(Means)+1, Means, 'color', ColourMat(2, :), 'LineWidth', 2);
h(2) = fill(1+daysflipCI, inBetweenCI, ColourMat(2,:) , 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);
set(h(2),'facealpha',.5)

xticks(1:14)
xlim([0.5 14.5])
ylim([0.4 1.8])

for i = [2]
    
    k = k+1;
    
    CIs = PlotterStructs{i}.SimulationOutputStruct.CIs;
    Means = PlotterStructs{i}.SimulationOutputStruct.Means;
    
    daysflipCI = [1:size(CIs, 2), size(CIs, 2):-1:1];
    inBetweenCI = [CIs(2, :), fliplr(CIs(1, :))];
    
    if isequal(FigureGeneration, 'Subplots')
        
        nexttile
        
    elseif isequal(FigureGeneration, 'Figures')
    
        figure
        
    end
    hold on
    h(1) = plot(2:length(Means)+1, Means, 'color', ColourMat(2, :), 'LineWidth', 2);
    h(2) = fill(1+daysflipCI, inBetweenCI, ColourMat(2, :) , 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);
    set(h(2),'facealpha',.5)


    %     set(gcf, 'color', 'none') ;
end

xlim([0.5 14.5])
ylim([0.4 1.8])
xticks(1:14)

box off

set(gcf,'Position',[100 100 1100 400])
set(gcf, 'color', 'none')

% 
% if isequal(FigureGeneration, 'Subplots')
%     
%     nexttile
%     
% elseif isequal(FigureGeneration, 'Figures')
%     
%     figure
%     
% end
% 
% LoadingStructExtra = load('Wales_2019-20_AnalysisVaryM100-2000-5000.mat');
% PlotterStructsExtra = LoadingStructExtra.PlotterStructs;
% 
% R_5000 = PlotterStructsExtra{3}.SimulationOutputStruct.Means;
% 
% MeansAll = [PlotterStructs{1}.SimulationOutputStruct.Means;...
%     PlotterStructs{2}.SimulationOutputStruct.Means;...
%     PlotterStructs{3}.SimulationOutputStruct.Means;...
%     PlotterStructsExtra{2}.SimulationOutputStruct.Means];
% 
% bar(sym(100*sum(abs(MeansAll - R_5000)./R_5000, 2)'/length(R_5000)), 'BarWidth', 0.4, 'FaceColor', ColourMat(2, :))
% xlabel('$M$', 'interpreter', 'latex')
% ylabel("Average weekly error (%)")
% 
% xticks([1 2 3 4]); % Set the desired tick positions
% xticklabels({'8', '40', '100', '2000'}); % Set the labels for the ticks
% 
% 
% box off
% 
% set(gcf,'Position',[100 100 1000 750])
% set(gcf, 'color', 'none') ;
