function [] = SameDayInfections_ABCAndEEPlotter(PlotterStruct)



SerialLength = PlotterStruct.SerialLength; w = PlotterStruct.Serial;
x = PlotterStruct.x; f_SI = PlotterStruct.f_SI; I = PlotterStruct.I;
Mean = PlotterStruct.Mean; CI = PlotterStruct.CI;
MeanEE = PlotterStruct.MeanEE; CIEE = PlotterStruct.CIsEE;
YLims = PlotterStruct.YLims;

if ~isnan(PlotterStruct.R)
    
    R = PlotterStruct.R;
    
end


%Serial Plot
figure
yyaxis left
g(1) = bar((0:SerialLength-1), w);
ylabel('$w_i$')
hYLabel = get(gca,'YLabel');
set(hYLabel,'rotation',0,'VerticalAlignment','middle')
hYLabel.Position(1) = -3.5;
hold on
yyaxis right
ylabel('Probability density')
g(2) = plot(x, f_SI, 'LineWidth', 2);
xlabel('$i$, Serial duration (days)')


%Main Plot
figure

yyaxis left
bar(I, 'FaceColor',[0.5 .5 .5],'EdgeColor',[0.9 .9 .9]);
ylabel('Incidence')
xlabel('$t$, Time (days)')
hold on

yyaxis right

if ~isnan(PlotterStruct.R)
    
    if length(R) == 1
    
    h(4) = yline(R, 'k');
    
    else
    
        h(4) = plot([nan R], 'k');
        
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
h(2) = fill(daysflipCI, inBetweenCI, 'red', 'EdgeColor', 'none');
set(h(2),'facealpha',.5)
h(5) = plot(MeanEE, 'blue', 'LineWidth', 2);
h(6) = fill(daysflipCIEE, inBetweenCIEE, 'blue', 'EdgeColor', 'none');
set(h(6),'facealpha',.5)
ylabel('$R_t$ inference')

ylim([YLims(1) YLims(2)])

h(7) = yline(1, 'k--');

if ~isnan(PlotterStruct.R)
   
    legend(h([1 2 4 5 6 7]), 'Mean SDS', '90\% CI SDS', 'True R', 'Mean EE', '90\% CI EE', '$R=1$', 'Location', 'best')
    
else
    
    legend(h([1 2 5 6 7]), 'Mean SDS', '90\% CI SDS', 'Mean EE', '90\% CI EE', '$R=1$', 'Location', 'best')
    
end

ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';

end