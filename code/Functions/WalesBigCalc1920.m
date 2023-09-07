function WalesBigCalc1920(Workers, P)

%This function is used in the Run_Wales1920.m file in the Cluster folder
%and allows Rt inference for any integer value of P. The function uses
%AnalysisFunction.m to compute Rt through time. This data is then used to
%plot the 2019-20 Wales data Analysis (see relevant .m files in Script folder)
 
c = parcluster;
%Specify the number of cores for the cluster object

parpool(c,Workers)

%% Incidence Generation


SI_Mean_SD = GammaGet(2.6/7, 1.3/7);

FileName = '../Simulation_Approach/RealWorldData/ILI_Wales_2019-20.csv';
Data = readtable(FileName);
I_data_w = (Data.Incidence)';
%%
% We take incidence-generation outside of the AnalysisFunction because we
% do not need to repeat this multiple times!

InferenceInput = struct('RPosteriorLims', [0 20], 'MatchingPairsPerCore', 84, 'PriorR', ...
    [1 5], 'RPosteriorResolution', 1000, 'I_data', I_data_w, ...
    'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays',...
    10, 'Spaces', 1e2, 'R_True', ...
    [], 'RelativeThreshold', 0, 'RYLims', [0 2], 'CredibleInterval', 95);

InferenceInput.ComparisonsOriginal = 'Off';
InferenceInput.IncidenceAndTrueR = 'On';
InferenceInput.ProbabilityDensity = 'Off';
InferenceInput.ComparisonsNew = 'Off';
InferenceInput.SimulationComputation = 'On';
InferenceInput.Workers = Workers;


[~, ~, ~, ~, ~, ~, ~, PlotterStructs] = AnalysisFunction(InferenceInput, P);

save('Wales_2019-20_BigCalcFinal.mat', 'PlotterStructs')


end
