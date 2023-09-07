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

LoadingStruct = load('../Cluster/MatFiles/Wales_2019-20_Analysis.mat');
PlotterStructs = LoadingStruct.PlotterStructs;

NumberofPs = 1:7;
MeansAll = zeros(7, 13);
MeansEE = PlotterStructs{1}.EEInferenceOutput.Means;
for i = NumberofPs
    
    PlotterStructs{i}.IncidenceAndTrueR = 'On';
    PlotterStructs{i}.ComparisonsNew = 'Off';
    
    MeansAll(i, :) = PlotterStructs{i}.SimulationOutputStruct.Means;
    
end

if isequal(FigureGeneration, 'Subplots')
   
    figure
    tiledlayout(1,3, 'TileSpacing','loose')
    
end



if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

PlotterStructs{1}.IncidenceAndTrueR = 'On';
PlotterComparison(PlotterStructs{1});
set(gcf, 'color', 'none') ;
box off

set(gcf,'Position',[100 100 1200 750])
set(gcf, 'color', 'none') ;

if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end
PlotterStructs{7}.IncidenceAndTrueR = 'Off';
PlotterStructs{7}.ComparisonsNew = 'On';

PlotterComparison(PlotterStructs{7});
box off

if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

OverkillMeans = load('../Cluster/MatFiles/Wales_2019-20_BigCalcFinal.mat');

Means5 = PlotterStructs{7}.SimulationOutputStruct.Means;
R_True = OverkillMeans.PlotterStructs.SimulationOutputStruct.Means;

bar(2:1+length(R_True), 100*(Means5-R_True)./R_True, 'FaceColor', ColourMat(2, :), 'BarWidth', 1)
% 
set(gcf,'Position',[100 100 1200 400])
set(gcf, 'color', 'none') ;
ylabel('Relative Error (%)')
xlabel('Time ($t$ weeks)', 'interpreter', 'latex')

box off

set(gcf,'Position',[100 100 1200 400])
set(gcf, 'color', 'none') ;
xlim([0.5 1.5+length(R_True)])

figure

if isequal(FigureGeneration, 'Subplots')
    
    tiledlayout(2,2, 'TileSpacing','loose')
    
end

k = 0;

for i = [1 3 5]
    
    k = k+1;
    
    if isequal(FigureGeneration, 'Subplots')
        
        nexttile
        
    elseif isequal(FigureGeneration, 'Figures')
    
        figure
        
    end
    
    PlotterStructs{i}.IncidenceAndTrueR = 'Off';
    PlotterStructs{i}.ComparisonsNew = 'On';
    
    PlotterComparison(PlotterStructs{i});
    set(gcf, 'color', 'none') ;
end


if isequal(FigureGeneration, 'Subplots')
    
    nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    figure
    
end

bar(sym(100*sum(abs(MeansAll - R_True)./R_True, 2)'/length(R_True)), 'BarWidth', 0.4, 'FaceColor', ColourMat(2, :))
xlabel('$P$', 'interpreter', 'latex')
ylabel("Average weekly error (%)")
xlim([0.5 7.5])

ylim([0 30])
box off

set(gcf,'Position',[100 100 1000 750])
set(gcf, 'color', 'none') ;
