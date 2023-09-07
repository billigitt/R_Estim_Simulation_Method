function SimulationOutput = SimulationInference_Parallel(SimulationInput)

%Function Description:
%This function leverages parallel computing (within MATLAB hence the
%Parallelisation toolbox is required) to perform Rt inference.
%AnalysisFunction.m uses SimulationInference_Parallel if parallelisation
%(within MATLAB) is used. Note that the default number of 'workers' is set
%to 4 and therefore a minimum of 4 cores are required on the users machine
%in order to use this function. Users can see the details in
%AnalysisFunction.m for what fields should be contained in SimulationInput.

%Unpacking

RPosteriorLims = SimulationInput.RPosteriorLims;
RPosteriorResolution = SimulationInput.RPosteriorResolution;
MatchingPairs = SimulationInput.MatchingPairs;
I = SimulationInput.I_data; PriorPara = SimulationInput.PriorPara;
SerialPara = SimulationInput.SerialPara;
SerialTimeDays = SimulationInput.SerialTimeDays;
Spaces = SimulationInput.Spaces;
N = SimulationInput.N; RelativeThreshold = SimulationInput.RelativeThreshold;
Computation = SimulationInput.Computation; CredibleInterval = SimulationInput.CredibleInterval;

if isfield(SimulationInput, 'Workers')
    
    Workers = SimulationInput.Workers;
    
else
    
    Workers = 4;
    
end

SerialInput = struct('Parameters', SerialPara, 'SerialTimeDays', SerialTimeDays, ...
    'Spaces', Spaces, 'SameDayGenerations', 1 , 'N', N); %INPUT
SerialOutput = Serial_Discretiser(SerialInput);

w = SerialOutput.w;
w(1) = w(1) + SerialOutput.w_0;

T = length(I);

%I_DISAG NEEDS TO BE MATCHINGPAIRS BY N*LENGTH(I) MATRIX SO THAT WE CAN
%INPUT INTO FUNCTION AS MATRIX (MORE EFFICIENT)
I_disag_final = zeros(MatchingPairs*Workers, N*T);
R_RawPosterior = zeros(MatchingPairs*Workers, T);
R_RawPosterior_core = zeros(MatchingPairs, 1);
MoreMatchingPairs = MatchingPairs;

BinEdges = linspace(RPosteriorLims(1), RPosteriorLims(2), RPosteriorResolution);
BinCentres = BinEdges + (BinEdges(1) + BinEdges(2))/2; BinCentres(end) = [];

CIs = zeros(2, T);
Means = zeros(1, T);

Waiting = waitbar(0, 'Time left');

I_disag_0core = zeros(MatchingPairs, N);

if isequal(Computation, 'On')
    
    for t = 2:T
        
        waitbar(t/T, Waiting)
        
        I_disag_core = zeros(MatchingPairs, N); %Just for this t
        
        spmd(Workers)
            
            while MoreMatchingPairs > 0
                
                if t == 2
                    
                    I_disag_tmp = mnrnd(I(1), ones(1, N)/N, MoreMatchingPairs);
                    
                else
                    
                    RandomSamples = randi(MatchingPairs, 1, MoreMatchingPairs);
                    
                    I_disag_tmp = I_disag_final(RandomSamples, 1:(t-1)*N);
                    
                end
                
                RPrior = gamrnd(PriorPara(1), PriorPara(2), MoreMatchingPairs, 1);
                
                I_new = bsxfun(@times, ones(1, N), poissrnd(RPrior.*...
                    Total_Infectiousness_EpiEstim_MatrixI(I_disag_tmp, w)));
                
                for k = 1:N-1
                    
                    I_new(:, k+1) = poissrnd(RPrior.*Total_Infectiousness_EpiEstim_MatrixI([I_disag_tmp ...
                        I_new(:, 1:k)], w));
                    
                end
                
                %I_NEW IS NOW A MOREMATCHINGPAIRS BY N MATRIX.
                
                IndexMatch = (abs(I(t) - sum(I_new, 2)) <= RelativeThreshold);
                
                NewMatches = sum(IndexMatch);
                
                if NewMatches > 0
                    
                    if t == 2
                        
                        I_disag_0core(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                            + NewMatches, :) = I_disag_tmp(IndexMatch, :);
                        
                    end
                    
                    I_disag_core(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                        + NewMatches, :) = I_new(IndexMatch, :);
                    
                    R_RawPosterior_core(end - MoreMatchingPairs + 1 : end - MoreMatchingPairs...
                        + NewMatches) = RPrior(IndexMatch);
                    
                    MoreMatchingPairs = MoreMatchingPairs - NewMatches;
                    
                end
                
            end
            
        end
        
        if t == 2
            
            for s = 1:Workers
                
                disp(I_disag_core)
                
                I_disag_final((s-1)*MatchingPairs+1:s*MatchingPairs, 1:N) = I_disag_core{s};
                
            end
            
        end
        
        for s = 1:Workers
            
            I_disag_final(1+(s-1)*MatchingPairs:s*MatchingPairs, (t-1)*N+1:t*N) = I_disag_core{s};
            
            R_RawPosterior((s-1)*MatchingPairs+1:s*MatchingPairs, t) = R_RawPosterior_core{s};
            
        end
        
        HistCounts = histcounts(R_RawPosterior(:, t), 'BinEdges', BinEdges);
        
        NormalisedPosterior = HistCounts/sum(HistCounts);
        
        CumPosterior = cumsum(NormalisedPosterior);
        
        %Finding confidence intervals
        IdxCILower = (CumPosterior > (1-CredibleInterval/100)/2);
        CItmp = BinCentres(IdxCILower);
        CIs(1, t) = CItmp(1);
        IdxCIUpper = (CumPosterior > (1+CredibleInterval/100)/2);
        CItmp = BinCentres(IdxCIUpper);
        CIs(2, t) = CItmp(1);
        
        Means(t) = mean(R_RawPosterior(:, t));
        
        MoreMatchingPairs = MatchingPairs;
        
    end
    
end

SimulationOutput = struct('t', 2:T, 'Means', Means(2:end), 'CIs', CIs(:, 2:end)...
    , 'w', w, 'IncidenceDisagreggation', I_disag_final);
close(Waiting)
end



