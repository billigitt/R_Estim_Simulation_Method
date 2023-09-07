function I_data_Matrix = I_dataCheck(Seed)

addpath(genpath('../Functions'))

%% Incidence Generation
%RNG = 6,8

rng(Seed)

c = parcluster;
%Specify the number of cores for the cluster object

%Start timing
%End timing

%Delete the parallel object

NumExperiments = 1e2;
NumberofNs = 7;
MeansOutput = zeros(NumberofNs, 10, NumExperiments);
I_data_Matrix = zeros(NumExperiments, 11);

for i = 1:NumExperiments

    I_data = zeros(1, 10);
    
while sum(I_data == 0) > 1
    
    % while sum(I_data == 0) > 1 || max(I_data) > 500 || I_data(end-1) < 10
    
    R_0 = 1.5; %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3084966/
    
    SI_Mean_SD = GammaGet(2.9/7, 1.3/7); %Cauchemez
    
    IncidenceInput = struct('R_True', [R_0*ones(1, 5) 0.75*ones(1, 5)], 'I_1', 1, 'N_true', ...
        24*60, 'SerialParameters', [SI_Mean_SD(1) SI_Mean_SD(2)], 'SerialTimeDays', 2, 'Spaces', 1e2);
    I_data = Incidence_Generator(IncidenceInput);
    
    disp(I_data)
    
end


I_data_Matrix(i, :) = I_data;

end


end
