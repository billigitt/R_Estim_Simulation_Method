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
%%
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
    
    h = nexttile
    
elseif isequal(FigureGeneration, 'Figures')
    
    h = figure
    
end

Means7 = PlotterStructs{2}.SimulationOutputStruct.Means;
R_True = PlotterStructs{2}.R_True;
MeansEE = PlotterStructs{2}.EEInferenceOutput.Means;

g(1) = bar(2:1+length(R_True), 100*(MeansEE-R_True)./R_True, 'FaceColor', ColourMat(1, :), 'BarWidth', 1);
hold on
g(2) = bar(2:1+length(R_True), 100*(Means7-R_True)./R_True, 'FaceColor', ColourMat(2, :), 'BarWidth', 0.5);


set(gcf,'Position',[100 100 1200 750])
set(gcf, 'color', 'none') ;
ylabel('Relative Error (%)')
xlabel('Time ($t$ weeks)', 'interpreter', 'latex')


xlim([0.5 11.5])
box off
set(gcf,'Position',[100 100 1000 750])
set(gcf, 'color', 'none') ;

legend(g([1 2]), 'Cori', '$P=7$', 'interpreter', 'latex', 'Location', 'NorthEast')

% yscale_symlog(h)


function yscale_symlog(h)
% yscale_symlog applies symmetric logarithmic scale to Y axis of current axis (negative
% logarithmic scale on the bottom, positive logarithmic scale on the top)
%
% yscale_symlog(AX) applies to axes AX instead of current axes.
if nargin<1
    h = gca;
end
% get all objects from current axis
O = findobj(h);
Otype = get(O, 'type');
O(strcmp(Otype, 'axes') | strcmp(Otype, 'legend')) = [];  % exclude axes and legend types
% get Y values from all objects
Y = get(O,'YData');
if ~iscell(Y)
    Y = {Y};
end
% single vector of values
Yall = cellfun(@(x) x(:)', Y, 'uniformoutput',0);
Yall = [Yall{:}];
yl = ylim(h); %
% if all positive values, then we can simply use built-in log scale option
if yl(1)>=0
    set(h, 'yscale','log')
    return;
end
min_negval = max(Yall(Yall<0)); % maximum value from all negative values
min_negval = floor(log10(-min_negval)-.1); % get negative log value and round up
min_posval = min(Yall(Yall>0)); % minimum value from all positive values
min_posval = floor(log10(min_posval)-.1); % get log value and round up
% transform Y values for each object
for u=1:length(O)
    this_y = Y{u};
    this_y(this_y>0) = posvalpos(this_y(this_y>0),min_posval); % for positive values
    this_y(this_y<0) =negvalpos(this_y(this_y<0),min_negval); % for negative values
    set(O(u), 'YData',this_y);
end
set(h, 'YTickLabelMode','auto');
% set new limits for yaxis
new_yl(1) = negvalpos(yl(1),min_negval);
if new_yl(1)>-1 % make sure at least one neg tick with integer value (in log10 space)
    new_yl(1) = -1;
end
if yl(2)>0
    new_yl(2) = posvalpos(yl(2),min_posval);
    if new_yl(2)<1 % make sure at least one tick with integer value (in log10 space)
        new_yl(2) = 1;
    end
elseif yl(2)<0
    new_yl(2) = negvalpos(yl(2),min_negval);
else
    new_yl(2) = 0;
end
ylim(h, new_yl);
% set tick labels
tick = get(h,'YTick');
ticklabel = cell(1,length(tick));
excl_tick = mod(tick,1)~=0; % exclude ticks that do not fall on integer value in log10 space
tick(excl_tick) = [];
% add intermediate ticks in log scale
if  mean(excl_tick)>.3
    add_intermediate = log10(2:9); % add intermediate ticks for all  integers
elseif mean(excl_tick)>0
    add_intermediate = log10(2:6); % add intermediate ticks for integers 2 to 6
else
    add_intermediate = []; % do not add intermediate ticks
end
for u = length(tick)-1:-1:find(tick==0) % ticks in positive log scale
    tick = [tick(1:u) tick(u)+add_intermediate tick(u+1:end)];
end
for u = find(tick==0)-1:-1:1 % ticks in negaive log scale
    tick = [tick(1:u) tick(u)+1-fliplr(add_intermediate) tick(u+1:end)];
end
for u=1:length(tick)
    if mod(tick(u),1)% for non-integer, keep tick without label
        ticklabel{u} = '';
    else
        if tick(u)<0 % negative values
            switch -tick(u)+min_negval
                case 0
                    ticklabel{u} = '-1';
                case 1
                    ticklabel{u} = '-10';
                case -1
                    ticklabel{u} = '-0.1';
                otherwise
                    ticklabel{u} = ['-100'];
            end
        elseif tick(u)>0
            switch tick(u)+min_posval
                case 0
                    ticklabel{u} = '1';
                case 1
                    ticklabel{u} = '10';
                case -1
                    ticklabel{u} = '0.1';
                otherwise
                    ticklabel{u} = ['100'];
            end
        else
            ticklabel{u} = '0';
        end
    end
end
set(h, 'ytick',tick,'yticklabel',ticklabel);
end
% position for positive values
function V = posvalpos(Z, ref)
V = log10(Z) - ref';
end
% position for negative values
function V = negvalpos(Z, ref)
V = - log10(-Z) + ref';
end