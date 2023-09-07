function [] = SameDayInfectionsPlotter(PlotterStruct)

SerialLength = PlotterStruct.SerialLength; w = PlotterStruct.Serial;
x = PlotterStruct.x; f_SI = PlotterStruct.f_SI; I = PlotterStruct.I;
Mean = PlotterStruct.Mean; CI = PlotterStruct.CI;
It_Mat = PlotterStruct.It_Mat; R_scan = PlotterStruct.R_scan;

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

h(1) = plot(Mean, 'red', 'LineStyle', '--', 'LineWidth', 2);
h(2) = plot(CI(1, :), 'blue', 'LineStyle', '-', 'LineWidth', 2);
h(3) = plot(CI(2, :), 'blue', 'LineStyle', '-', 'LineWidth', 2);

ylabel('R inference')

ylim([0 5])

if isfield(PlotterStruct, 'R')
   
    legend(h([1 2 4]), 'Mean', '90% CI', 'True R')
    
else
    
    legend(h([1 2]), 'Mean', '90% CI')
    
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