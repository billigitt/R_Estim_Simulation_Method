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

x300 = load('SimulationInference1-300.mat').SimulationInference;
x331 = load('SimulationInference301-331.mat').SimulationInference;
x357 = load('SimulationInference332-357.mat').SimulationInference;
x1000 = load('SimulationInference358-1000.mat').SimulationInference;

    ColourMat = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.1250];

ciLow = zeros(1000,10);
ciUp = zeros(1000,10);


for i=1:300
   
    ciLow(i, :) = x300{i}.SimulationOutputStruct.CIs(1, :);
    ciUp(i, :) = x300{i}.SimulationOutputStruct.CIs(2, :);
    
end

for i=301:331
   
    ciLow(i, :) = x331{i}.SimulationOutputStruct.CIs(1, :);
    ciUp(i, :) = x331{i}.SimulationOutputStruct.CIs(2, :);
    
end

for i=332:357
   
    ciLow(i, :) = x357{i}.SimulationOutputStruct.CIs(1, :);
    ciUp(i, :) = x357{i}.SimulationOutputStruct.CIs(2, :);
    
end

for i=358:1000
   
    ciLow(i, :) = x1000{i}.SimulationOutputStruct.CIs(1, :);
    ciUp(i, :) = x1000{i}.SimulationOutputStruct.CIs(2, :);
    
end

matrixLogOG = (ciLow< 1) & (ciUp>1);

save('SimulationInferenceCIs1-1000.mat', 'ciLow', 'ciUp')

crOG = 100*sum(sum(matrixLogOG))/(1000*10);

nashLower = table2array(readtable('lowerNashEstimateLowInc.csv'));
nashUpper = table2array(readtable('upperNashEstimateLowInc.csv'));

matrixLogNash = (nashLower< 1) & (nashUpper>1);

crNash = 100*sum(sum(matrixLogNash))/(1000*10);
%%
OGcounts = histcounts(sum(matrixLogOG, 2), -0.5:1:10.5)/10;
Nashcounts = histcounts(sum(matrixLogNash, 2), -0.5:1:10.5)/10;

figure
g(2) = bar(0:10, Nashcounts, 'FaceColor', ColourMat(1, :), 'BarWidth', 1);
hold on
g(1) = bar(0:10, OGcounts, 'FaceColor', ColourMat(2, :), 'BarWidth', 0.5);



set(gcf,'Position',[100 100 1200 750])
ylabel('Percentage of simulations (%)')
xlabel('Credible interval coverage (%)', 'interpreter', 'latex')


xlim([-0.5 10.5])
xticklabels(["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"])
yticks([0:10:60])
box off
set(gcf,'Position',[100 100 450 350])


legend(g([2 1]), 'Nash \textit{et al.}', '$P=7$', 'interpreter', 'latex', 'Location', 'NorthWest')
set(gcf, 'color', 'none') ;