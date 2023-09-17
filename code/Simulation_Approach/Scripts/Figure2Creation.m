clear; clc; close all
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

%% File Description
%In this file, we generate Figure 2 in the manuscript. Figure2Analysis.mat
%is a pre-requisite to generate this file, and Figure2Analaysis.mat can be
%generated using Figure2Analysis.m. 

ColourMat = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];
%% Incidence Generation

LoadingStruct = load('Figure2Analysis.mat');

FigureGeneration = 'Subplots';
%FigureGeneration = 'Figures';

PlotterStructs = LoadingStruct.PlotterStructs;

NumberofPs = 1:7;

if isequal(FigureGeneration, 'Subplots')
    
    
    figure
    tiledlayout(2, 2, 'TileSpacing','loose')
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

PlotterComparison(PlotterStructs{1});
box off

if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

w_EE = PlotterStructs{1}.w_EE;
w_Sim = PlotterStructs{2}.w_Sim;
BarWidth = 0.1;
h(1) = bar(0:length(w_EE)-1, w_EE, BarWidth, 'FaceColor', ColourMat(1, :));
hold on
for i = 7
    
    h(i) = bar(0:1/7:(2 -1/7), [0 w_Sim], 7*BarWidth, 'FaceColor', ColourMat(2, :));
    
end
xlabel('Serial interval (weeks)')
ylabel('Probability')
legend(h([1 7]), 'Cori ($P=1$)', '$P=7$', 'interpreter', 'latex', 'Location', 'NorthWest')
xlim([-1/7 1+1/7])
box off

if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end
PlotterStructs{1}.IncidenceAndTrueR = 'Off';
PlotterStructs{1}.ComparisonsNew = 'On';

PlotterComparison(PlotterStructs{2});
box off

if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

Means7 = PlotterStructs{2}.SimulationOutputStruct.Means;
R_True = PlotterStructs{2}.R_True;

bar(2:1+length(R_True), 100*(Means7-R_True)./R_True, 'FaceColor', ColourMat(2, :), 'BarWidth', 1)

set(gcf,'Position',[100 100 1200 750])
set(gcf, 'color', 'none') ;
ylabel('Relative Error (%)')
xlabel('Time ($t$ weeks)', 'interpreter', 'latex')


xlim([0.5 11.5])
box off
set(gcf,'Position',[100 100 1000 750])
set(gcf, 'color', 'none') ;
