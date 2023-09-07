function [MeansOutput, I_data_Matrix, I_disag_1, I_disag_2, CIs_1, CIs_2] = MeansLargeScaleComputation_1And6(Seed, Workers)


%Pairing with the AnalysisFunction.m Incidence_Generator.m function, we
%input parameters and the function returns Mean output inference for Rt and
% a matrix containing the incidence generated. Specifically, this for when
% we have P=1 and 6 as our partitioning parameter.

rng(Seed+1)

c = parcluster;

poolObject = parpool(c,Workers);

NumExperiments = 100; 
NumberofNs = 2; 
VectorofNs = [1 6];
MeansOutput = zeros(NumberofNs, 10, NumExperiments);
I_data_Matrix = zeros(NumExperiments, 11);

for i = 1:NumExperiments

    I_data = zeros(1, 10);
    
while sum(I_data == 0) > 1
    
    R_0 = 1.5; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/
    
    SI_Mean_SD = GammaGet(2.6/7, 1.3/7); %Cauchemez
    
    IncidenceInput = struct('R_True', [R_0*ones(1, 5) 0.75*ones(1, 5)], 'I_1', 1, 'N_true', ...
        7*24*6, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);
    I_data = Incidence_Generator(IncidenceInput);
    
    disp(I_data)
    
end



I_data_Matrix(i, :) = I_data;

end

InferenceInput = struct('MatchingPairsPerCore', 1000);
    
    

I_disag_1 = zeros(InferenceInput.MatchingPairsPerCore, VectorofNs(1)*length(I_data), NumExperiments);
I_disag_2 = zeros(InferenceInput.MatchingPairsPerCore, VectorofNs(2)*length(I_data), NumExperiments);
CIs_1 = zeros(2, length(I_data)-1, NumExperiments);
CIs_2 = zeros(2, length(I_data)-1, NumExperiments);
    
tic
parfor i = 1:NumExperiments    
    
   InferenceInput = struct('RPosteriorLims', [0 20], 'MatchingPairsPerCore', 1000, 'PriorR', ...
        [1 5], 'RPosteriorResolution', 1000, 'I_data', I_data_Matrix(i, :), ...
        'SerialParameters', IncidenceInput.SerialParameters, 'SerialTimeDays',...
        IncidenceInput.SerialTimeDays, 'Spaces', IncidenceInput.Spaces, 'R_True', ...
        IncidenceInput.R_True, 'RelativeThreshold', 0, 'RYLims', [0 2],...
        'CredibleInterval', 90);
    InferenceInput.ComparisonsOriginal = 'Off';
    InferenceInput.IncidenceAndTrueR = 'Off';
    InferenceInput.ProbabilityDensity = 'Off';
    InferenceInput.ComparisonsNew = 'Off';
    InferenceInput.SimulationComputation = 'On';
    InferenceInput.NoParallelToolBox = 1;
    
    Means = zeros(length(I_data_Matrix(i,:))-1, length(VectorofNs)); %Not sure this matrix has right size... what should dimension 1 be?
        
        [~,  ~, Means(:, 1), ~, I_disag_1(:, :, i), CIs_1(:, :, i), ~, ~] = AnalysisFunction(InferenceInput, VectorofNs(1));
        [~,  ~, Means(:, 2), ~, I_disag_2(:, :, i), CIs_2(:, :, i), ~, ~] = AnalysisFunction(InferenceInput, VectorofNs(2));
        
    
    
    %%
    lengthR = length(IncidenceInput.R_True);
    
    MeansOutput(:, :, i) = Means(end-lengthR+1:end, :)';
    
    
end

toc

delete(poolObject);

end
