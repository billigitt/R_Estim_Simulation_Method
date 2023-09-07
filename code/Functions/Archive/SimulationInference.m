function SimulationOutput = SimulationInference(SimulationInput)

%Unpacking

RPosteriorLims = [0 20]; 
RPosteriorResolution = 1000; 

MatchingPairs = 100; 
I = [5*ones(1, 30)] ; 
SizePrior = 100;
R_Prior = gamrnd(sqrt(2), sqrt(2), 1, SizePrior); %INPUT
SerialInput = struct('Parameters', [10 0.3], 'SerialTimeDays', 10, ...
    'Spaces', 10, 'SameDayGenerations', 1, 'N', 2); %INPUT
SerialOutput = Serial_Discretiser(SerialInput);

N = SerialInput.N;

w = SerialOutput.w;
w(1) = w(1) + SerialOutput.w_0;

%NEED TO THINK ABOUT I_DISAG. HOW DO WE STORE STUFF ETC SO THAT WE CAN MOVE
%THROUGH TIME...
%I_DISAG NEEDS TO BE MATCHINGPAIRS BY N*LENGTH(I) MATRIX
I_disag = zeros(MatchingPairs, N*length(I));
R_RawPosterior = zeros(MatchingPairs, length(I));
MoreMatchingPairs = MatchingPairs;

BinEdges = linspace(RPosteriorLims(1), RPosteriorLims(2), RPosteriorResolution);
BinCentres = BinEdges + (BinEdges(1) + BinEdges(2))/2; BinCentres(end) = [];

CIs = zeros(2, length(I));
Means = zeros(1, length(I));

for t = 2:length(I)
    
    l = 0;
    
    while MoreMatchingPairs > 0
        
        if t == 2
            
            I_disag_tmp = zeros(MoreMatchingPairs, N);
            
            for j = 1:N-1
                
                %                 I_disag(end - MoreMatchingPairs + 1, j) = I(1)*rand(MoreMatchingPairs, 1);
                
                I_disag_tmp(:, j) = randi([0 I(1)], MoreMatchingPairs, 1);
                
            end
            
            %             I_disag(end - MoreMatchingPairs + 1:end, N) = ...
            %                 I(1) - sum(I_disag(end - MoreMatchingPairs + 1:end, ...
            %                 1:N-1), 2);
            
            I_disag_tmp(:, N) = I(1) - sum(I_disag_tmp, 2);
            
            %CAN GENERALISE THIS FOR MORE POINTS PER DAY, MAYBE USE MULTINOMIAL
            %DISTN. ATM ONLY WORKS FOR N = 2.
            
        else
            
            RandomSamples = randi(MatchingPairs, 1, MoreMatchingPairs);
            
            %             I_disag(end - MoreMatchingPairs + 1 : end, ...
            %                 N*(t-1)+1:t*N) = ...
            %                 I_disag(RandomSamples, N*(t-1) + 1:t*N);
            %
            
            I_disag_tmp = I_disag(RandomSamples, 1:(t-1)*N);
            
        end
        
        RPrior = gamrnd(sqrt(2), sqrt(2), MoreMatchingPairs, 1);
        
        I_new = poissrnd(RPrior.*Total_Infectiousness_EpiEstim_MatrixI(I_disag_tmp, w));
        
%         disp(I_new)
        
        for k = 1:N-1
            
            I_new = [I_new poissrnd(RPrior.*Total_Infectiousness_EpiEstim_MatrixI([I_disag_tmp ...
                I_new], w))];
            
        end
        
        %I_NEW IS NOW A MOREMATCHINGPAIRS BY N MATRIX.
        
        IndexMatch = ((I(t) - sum(I_new, 2)) == 0);
        
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
            
%             disp(MoreMatchingPairs)
            
        end
        
    end
    
    NormalisedPosterior = histcounts(R_RawPosterior(:, t), 'BinEdges', ...
        BinEdges)/MatchingPairs;
    
    CumPosterior = cumsum(NormalisedPosterior);
    
    %Finding confidence intervals
    IdxCILower = (CumPosterior > 0.05);
    CItmp = BinCentres(IdxCILower);
    CIs(1, t) = CItmp(1);
    IdxCIUpper = (CumPosterior > 0.95);
    CItmp = BinCentres(IdxCIUpper);
    CIs(2, t) = CItmp(1);
    
    Means(t) = mean(R_RawPosterior(:, t));
    
    MoreMatchingPairs = 100;
    
end

end