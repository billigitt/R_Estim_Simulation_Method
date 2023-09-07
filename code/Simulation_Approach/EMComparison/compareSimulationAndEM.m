clc
clear all
close all

%% Script Description

%This script compares the EM method with our method, i.e. both methods try to resolve the issue of same time-window infections.
%The EM inference was performed in R and then loaded into this script, enabling comaprison of the two methods on both Wales data-
%sets used in the main manuscript.

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

tiledlayout(2,2, 'TileSpacing','loose')

ColourMat = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

tvals = [1:13];
meanvals = load('meanR_ILI_Wales_2019-20.csv');
lowervals = load('lowerR_ILI_Wales_2019-20.csv');
uppervals = load('upperR_ILI_Wales_2019-20.csv');

LoadingStruct1920 = load('../Cluster/MatFiles/Wales_2019-20_Analysis.mat');
Means1920 = LoadingStruct1920.PlotterStructs{7}.SimulationOutputStruct.Means;
CIs1920 = LoadingStruct1920.PlotterStructs{7}.SimulationOutputStruct.CIs;

LoadingStruct2223 = load('../Cluster/MatFiles/Wales_2022-23_Analysis.mat');
Means2223 = LoadingStruct2223.PlotterStructs{7}.SimulationOutputStruct.Means;
CIs2223= LoadingStruct2223.PlotterStructs{7}.SimulationOutputStruct.CIs;

meanvals = transpose(meanvals);
lowervals = transpose(lowervals);
uppervals = transpose(uppervals);


nexttile

%% Plot A: Simulation Method 19-20

plot(tvals, Means1920, 'color', ColourMat(2, :), 'LineWidth', 2);
hold on;

    % Create a transparent area for confidence intervals
    x = [tvals, fliplr(tvals)]; % x values for the polygon
    y = [CIs1920(1, :), fliplr(CIs1920(2, :))]; % y values for the polygon
    fill(x, y, ColourMat(2, :), 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3, 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);

    % Add legend and labels
    xlabel('Date (day/month)');
    ylabel("Time-dependent"+newline+"reproduction number (  )");
    grid off;

    % Display the plot
    hold off;
xticks([0 tvals])
xlim([-0.5 13.5])
ylim([0.5 2])

box off
nexttile

%% Plot B: EM method 19-20

plot(tvals, meanvals, 'color', ColourMat(1, :), 'LineWidth', 2);
hold on;

    % Create a transparent area for confidence intervals
    x = [tvals, fliplr(tvals)]; % x values for the polygon
    y = [lowervals, fliplr(uppervals)]; % y values for the polygon
    fill(x, y, ColourMat(1, :), 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3, 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);

    % Add legend and labels
    xlabel('Date (day/month)');
    ylabel("Time-dependent"+newline+"reproduction number (  )");
    grid off;

    % Display the plot
    hold off;
xlim([-0.5 13.5])
ylim([0.5 2])
xticks([0 tvals])

box off
    
%% Plot C: 

nexttile

plot(tvals, Means2223, 'color', ColourMat(2, :), 'LineWidth', 2);
hold on;

    % Create a transparent area for confidence intervals
    x = [tvals, fliplr(tvals)]; % x values for the polygon
    y = [CIs2223(1, :), fliplr(CIs2223(2, :))]; % y values for the polygon
    fill(x, y, ColourMat(2, :), 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3, 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);

    % Add legend and labels
    xlabel('Date (day/month)');
    ylabel("Time-dependent"+newline+"reproduction number (  )");
    grid off;

    % Display the plot
    hold off;
xticks([0 tvals])
xlim([-0.5 13.5])
ylim([0.5 1.7])
box off
    
%% Plot D: EM method 22-23 
    
nexttile
tvals = [1:13];
meanvals = load('meanR_ILI_Wales_2022-23.csv');
lowervals = load('lowerR_ILI_Wales_2022-23.csv');
uppervals = load('upperR_ILI_Wales_2022-23.csv');

meanvals = transpose(meanvals);
lowervals = transpose(lowervals);
uppervals = transpose(uppervals);
    
plot(tvals, meanvals, 'color', ColourMat(1, :), 'LineWidth', 2);
hold on;

    % Create a transparent area for confidence intervals
    x = [tvals, fliplr(tvals)]; % x values for the polygon
    y = [lowervals, fliplr(uppervals)]; % y values for the polygon
    fill(x, y, ColourMat(1, :), 'FaceAlpha', 0.5, 'EdgeAlpha', 0.3, 'LineWidth', 0.1, ...
        'edgecolor', [1 1 1]);

    % Add legend and labels
    xlabel('Date (day/month)');
    ylabel("Time-dependent"+newline+"reproduction number (  )");
    grid off;

    % Display the plot
    hold off;
xticks([0 tvals])

 set(gcf,'Position',[100 100 1000 750])
set(gcf, 'color', 'none') ;
xlim([-0.5 13.5])
ylim([0.5 1.7])

box off
