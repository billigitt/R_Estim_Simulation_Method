function [] = SameDayInfectionsAndEEPlotter(PlotterStruct)

SerialLength = PlotterStruct.SerialLength; w = PlotterStruct.Serial;
x = PlotterStruct.x; f_SI = PlotterStruct.f_SI; I = PlotterStruct.I;
Mean = PlotterStruct.Mean; CI = PlotterStruct.CI;
It_Mat = PlotterStruct.It_Mat; R_scan = PlotterStruct.R_scan;
MeanEE = PlotterStruct.MeanEE; CIEE = PlotterStruct.CIsEE;
YLims = PlotterStruct.YLims;

if isfield(PlotterStruct, 'R')
    
    R = PlotterStruct.R;
    
end


%Serial Plot
figure
plot((0:SerialLength-1)+0.5, w)
hold on
plot(x, f_SI)

%Main Plot
figure

yyaxis left
bar(I);
ylabel('Incidence')
xlabel('Time')
hold on

yyaxis right

if isfield(PlotterStruct, 'R')
    
    if length(R) == 1
    
    h(4) = yline(R);
    
    else
    
        h(4) = plot(R);
        
    end
    
end

daysflipCI = [1:size(CI, 2), size(CI, 2):-1:1];
inBetweenCI = [CI(2, :), fliplr(CI(1, :))];

RemoveNaNs = find(isnan(inBetweenCI));
daysflipCI(RemoveNaNs) = [];
inBetweenCI(RemoveNaNs) = [];

daysflipCIEE = [1:size(CIEE, 2), size(CIEE, 2):-1:1];
inBetweenCIEE = [CIEE(2, :), fliplr(CIEE(1, :))];

h(1) = plot(Mean, 'red', 'LineWidth', 2);
hold on
h(2) = fill(daysflipCI, inBetweenCI, 'red' , 'LineWidth', 0.1, ...
    'edgecolor', [1 1 1]);
set(h(2),'facealpha',.5)
h(5) = plot(MeanEE, 'blue', 'LineWidth', 2);
h(6) = fill(daysflipCIEE, inBetweenCIEE, 'blue' , 'LineWidth', 0.1, ...
    'edgecolor', [1 1 1]);
set(h(6),'facealpha',.5)
ylabel('R inference')

ylim([YLims(1) YLims(2)])

yline(1)

if isfield(PlotterStruct, 'R')
   
    legend(h([1 2 4 5 6]), 'Mean SDI', '90% CI SDI', 'True R', 'Mean EE', '90% CI EE')
    
else
    
    legend(h([1 2 5 6]), 'Mean SDI', '90% CI SDI', 'Mean EE', '90% CI EE')
    
end

Day1Mat = It_Mat(:, :, 1);
SampleIndex = round(linspace(1, length(R_scan), 10));
Day1MatBar = Day1Mat(SampleIndex, :);
for i = 1:length(SampleIndex)
    
    figure
    histogram(Day1MatBar(i, :))
    hold on
    xline(I(find(isnan(Mean), 1, 'last') + 1), 'red')
    title("R = " + R_scan(SampleIndex(i)))
end

UpperIDay1 = max(max(Day1Mat));
HeatMap = zeros(length(R_scan), UpperIDay1 + 1);

for i = 1:length(R_scan)
   
    HeatMap(i, :) = histcounts(Day1Mat(i, :, 1), 0:UpperIDay1 + 1);
    
end

figure
imagesc([0 UpperIDay1], [R_scan(1) R_scan(end)], HeatMap)
hold on
xline(I(find(isnan(Mean), 1, 'last') + 1))
ylabel('R')
xlabel('Simulated I')
colorbar
title("First day")

end