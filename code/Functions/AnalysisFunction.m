function [w_Sim, w_EE, Means, EEMeans, Disag, CIs, EECIs, PlotterInputs] = AnalysisFunction(MainInput, N_Sim)

% Function Description

%This function is the main wrapper for inference analysis that is performed
%in many of the script files (see Script Folder). Using a sequence of
%functions in this file (SimulationInferenceSLURM) and others such as
%EpiEstimStandardInference.m (in Functions Folder), we take the input
%parameters in MainInput, as well as the N_Sim (value which is actually the
%P value in the manuscript and named to indicate it is the Number of partitions for the Simulation approach)
% 
% We output a vector of outputs:
%
%w_Sim: The serial interval used for the simulation approach
%w_EE: The serial interval for the Cori et al. approach
%Means: The vector of Mean Rt inference outputs (simulation based approach)
%EEMeans: The vector of Mean Rt inference outputs (Cori et al. approach)
%Disag: Disaggregated incidence used in simulations
%CIs: Credible intervals for simulation based approach
%EECIs: Credible intervals for Cori et al. approach
%PlotterInputs: Struct of values that can be passed into Plotting function

%Unpack Main Input
R_True = MainInput.R_True;

SimulationInputStruct = struct('RPosteriorLims', MainInput.RPosteriorLims, 'RPosteriorResolution', ...
    MainInput.RPosteriorResolution, 'MatchingPairs', MainInput.MatchingPairsPerCore,...
    'I_data', MainInput.I_data, 'PriorPara', ...
    MainInput.PriorR, 'SerialPara', MainInput.SerialParameters, ...
    'SerialTimeDays', MainInput.SerialTimeDays, ...
    'Spaces', MainInput.Spaces, 'N', N_Sim, 'RelativeThreshold', MainInput.RelativeThreshold, ...
    'Computation', MainInput.SimulationComputation, 'CredibleInterval', ...
    MainInput.CredibleInterval);

if isfield(MainInput, 'Workers')
    
    SimulationInputStruct.Workers = MainInput.Workers;
    
end

if isfield(MainInput, 'NoParallelToolBox')
    
    SimulationOutputStruct = SimulationInferenceSLURM(SimulationInputStruct);
    
else
    
    SimulationOutputStruct = SimulationInference_Parallel(SimulationInputStruct);
    
end

EEInferenceInput = struct('I_data', SimulationInputStruct.I_data, 'PriorPara', ...
    SimulationInputStruct.PriorPara, 'SerialPara', SimulationInputStruct.SerialPara, ...
    'SerialTimeDays', SimulationInputStruct.SerialTimeDays, 'Spaces', ...
    SimulationInputStruct.Spaces, 'tau', 1);

EEInferenceOutput = EpiEstimStandardInference(EEInferenceInput);

SimulationOutputStruct.Name = 'Simulation';
EEInferenceOutput.Name = 'EpiEstim';

PlotterInputs = struct('I_data', SimulationInputStruct.I_data, 'SimulationOutputStruct', ...
    SimulationOutputStruct, 'EEInferenceOutput', EEInferenceOutput, 'R_True', R_True, ...
    'SerialParameters', MainInput.SerialParameters, 'w_Sim', SimulationOutputStruct.w, 'w_EE', ...
    EEInferenceOutput.Serial, 'N_Sim', N_Sim, 'RYLims', MainInput.RYLims, 'ComparisonsOriginal', ...
    MainInput.ComparisonsOriginal, 'IncidenceAndTrueR', MainInput.IncidenceAndTrueR, ...
    'ProbabilityDensity', MainInput.ProbabilityDensity, 'ComparisonsNew', MainInput.ComparisonsNew);

w_Sim = SimulationOutputStruct.w;
w_EE = EEInferenceOutput.Serial;
Means = SimulationOutputStruct.Means;
Disag = SimulationOutputStruct.IncidenceDisagreggation;
EEMeans = EEInferenceOutput.Means;
CIs = SimulationOutputStruct.CIs;
EECIs = EEInferenceOutput.CIs;

end

function SimulationOutput = SimulationInferenceSLURM(SimulationInput)

%This function is customised for a computing cluster to peform Rt inference
%when the paraemters are challenging computationally, for example if
%SimulationInput.N (representing the partitioning) is very large.

RPosteriorLims = SimulationInput.RPosteriorLims;
RPosteriorResolution = SimulationInput.RPosteriorResolution;
MatchingPairs = SimulationInput.MatchingPairs;
I = SimulationInput.I_data; PriorPara = SimulationInput.PriorPara;
SerialPara = SimulationInput.SerialPara;
SerialTimeDays = SimulationInput.SerialTimeDays;
Spaces = SimulationInput.Spaces;
N = SimulationInput.N; RelativeThreshold = SimulationInput.RelativeThreshold;
Computation = SimulationInput.Computation; CredibleInterval = SimulationInput.CredibleInterval;

SerialInput = struct('Parameters', SerialPara, 'SerialTimeDays', SerialTimeDays, ...
    'Spaces', Spaces, 'SameDayGenerations', 1 , 'N', N); %INPUT
SerialOutput = Serial_Discretiser(SerialInput);

w = SerialOutput.w;
w(1) = w(1) + SerialOutput.w_0;

T = length(I);

%I_DISAG NEEDS TO BE MATCHINGPAIRS BY N*LENGTH(I) MATRIX SO THAT WE CAN
%INPUT INTO FUNCTION AS MATRIX (MORE EFFICIENT)
I_disag = zeros(MatchingPairs, N*T);
R_RawPosterior = zeros(MatchingPairs, T);
MoreMatchingPairs = MatchingPairs;

BinEdges = linspace(RPosteriorLims(1), RPosteriorLims(2), RPosteriorResolution);
BinCentres = BinEdges + (BinEdges(1) + BinEdges(2))/2; BinCentres(end) = [];

CIs = zeros(2, T);
Means = zeros(1, T);

Waiting = waitbar(0, 'Time left');

Computation = 'On';

if isequal(Computation, 'On')
    
    for t = 2:T
        
        waitbar(t/T, Waiting)
        
        while MoreMatchingPairs > 0
            
            if t == 2
                
                I_disag_tmp = mnrnd(I(1), ones(1, N)/N, MoreMatchingPairs);
                
            else
                
                RandomSamples = randi(MatchingPairs, 1, MoreMatchingPairs);
                
                I_disag_tmp = I_disag(RandomSamples, 1:(t-1)*N);
                
            end
            
            RPrior = gamrnd(PriorPara(1), PriorPara(2), MoreMatchingPairs, 1);
            
            I_new = bsxfun(@times, ones(1, N), poissrnd(RPrior.*...
                Total_Infectiousness_EpiEstim_MatrixI(I_disag_tmp, w)));
            
            for k = 1:N-1
                
                I_new(:, k+1) = poissrnd(RPrior.*Total_Infectiousness_EpiEstim_MatrixI([I_disag_tmp ...
                    I_new(:, 1:k)], w));
                
            end
            
            %I_NEW is now a MOREMATCHINGPAIRS by N size matrix.
            
            IndexMatch = (abs((I(t) - sum(I_new, 2))) <= RelativeThreshold);
            
            NewMatches = sum(IndexMatch);
            
            if NewMatches > 0
                
                if t == 2
                    
                    I_disag(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                        + NewMatches, 1:N) = I_disag_tmp(IndexMatch, :);
                    
                end
                
                I_disag(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                    + NewMatches, N*(t-1) + 1:t*N) = I_new(IndexMatch, :);
                
                R_RawPosterior(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                    + NewMatches, t) = RPrior(IndexMatch);
                
                MoreMatchingPairs = MoreMatchingPairs - NewMatches;
                
            end
            
        end
        
        NormalisedPosterior = histcounts(R_RawPosterior(:, t), 'BinEdges', ...
            BinEdges)/MatchingPairs;
        
        CumPosterior = cumsum(NormalisedPosterior);
        
        %Finding confidence intervals
        IdxCILower = (CumPosterior > (1-CredibleInterval/100)/2);
        
        CItmp = BinCentres(IdxCILower);
        CIs(1, t) = CItmp(1);
        
        IdxCIUpper = (CumPosterior < (1+CredibleInterval/100)/2);
        
        CItmp = BinCentres(IdxCIUpper);
        CIs(2, t) = CItmp(end);
        
        Means(t) = mean(R_RawPosterior(:, t));
        
        MoreMatchingPairs = MatchingPairs;
        
    end
    
    SimulationOutput = struct('t', 2:T, 'Means', Means(2:end), 'CIs', CIs(:, 2:end)...
        , 'w', w, 'IncidenceDisagreggation', I_disag);
    
end


end
