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

LoadingStruct = load('P5-10-15-20-25-30vsM100Analysis.mat');

totalSims = LoadingStruct.elapsedTime;
%across cols is matchings
%down rows is p value

% totalSimsP1M10 = sum(totalSims{1,1});
% totalSimsP1M20 = sum(totalSims{1,2});
% totalSimsP1M30 = sum(totalSims{1,3});
% totalSimsP1M40 = sum(totalSims{1,4});
% totalSimsP4M10 = sum(totalSims{2,1});
% totalSimsP4M20 = sum(totalSims{2,2});
% totalSimsP4M30 = sum(totalSims{2,3});
% totalSimsP4M40 = sum(totalSims{2,4});
% totalSimsP7M10 = sum(totalSims{3,1});
% totalSimsP7M20 = sum(totalSims{3,2});
% totalSimsP7M30 = sum(totalSims{3,3});
% totalSimsP7M40 = sum(totalSims{3,4});
% totalSimsP10M10 = sum(totalSims{4,1});
% totalSimsP10M20 = sum(totalSims{4,2});
% totalSimsP10M30 = sum(totalSims{4,3});
% totalSimsP10M40 = sum(totalSims{4,4});
% totalSimsP13M10 = sum(totalSims{5,1});
% totalSimsP13M20 = sum(totalSims{5,2});
% totalSimsP13M30 = sum(totalSims{5,3});
% totalSimsP13M40 = sum(totalSims{5,4});
% totalSimsP16M10 = sum(totalSims{6,1});
% totalSimsP16M20 = sum(totalSims{6,2});
% totalSimsP16M30 = sum(totalSims{6,3});
% totalSimsP16M40 = sum(totalSims{6,4});
% totalSimsP19M10 = sum(totalSims{7,1});
% totalSimsP19M20 = sum(totalSims{7,2});
% totalSimsP19M30 = sum(totalSims{7,3});
% totalSimsP19M40 = sum(totalSims{7,4});

totalSimsP5M100 = sum(totalSims(1));
%totalSimsP1M1000 = sum(totalSims{1,2});

totalSimsP10M100 = sum(totalSims(2));
%totalSimsP4M1000 = sum(totalSims{2,2});

totalSimsP15M100 = sum(totalSims(3));
%totalSimsP7M1000 = sum(totalSims{3,2});

totalSimsP20M100 = sum(totalSims(4));
%totalSimsP10M1000 = sum(totalSims{4,2});

%totalSimsP13M100 = sum(totalSims{5,1});
totalSimsP25M100 = sum(totalSims(5));

%totalSimsP16M100 = sum(totalSims{6,1});
totalSimsP30M100 = sum(totalSims(6));

% totalSimsP19M100 = sum(totalSims{7,1});
% totalSimsP19M1000 = sum(totalSims{7,2});


totalSimsMatrix = [totalSimsP5M100 totalSimsP10M100 totalSimsP15M100... 
    totalSimsP20M100 totalSimsP25M100 totalSimsP30M100];

h = bar(5:5:30, totalSimsMatrix);

xlabel('P')
ylabel('Simulation Time (s)')


