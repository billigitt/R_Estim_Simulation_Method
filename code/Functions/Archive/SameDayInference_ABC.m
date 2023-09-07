function InferenceStruct = SameDayInference_ABC(InputStruct)

TotalSampleSize = InputStruct.TotalSampleSize;
PriorParameters = InputStruct.PriorParameters;
TotalSimulatedDays = InputStruct.TotalSimulatedDays;
w = InputStruct.Serial; q = InputStruct.SameDayGenerations;
w_0 = InputStruct.w_0; I = InputStruct.I; I_0 = InputStruct.I_0;
RelativeThreshold = InputStruct.RelativeThreshold;
RPosteriorLims = InputStruct.RPosteriorLims; 
RPosteriorResolution = InputStruct.RPosteriorResolution;

%For now, we fix R_scan because we may or may not be given R outside of
%this function
CI = zeros(2, TotalSimulatedDays);
Mean = zeros(1, TotalSimulatedDays);
It_Mat = zeros(TotalSimulatedDays, TotalSampleSize);
%It is possible to also get rid of this for loop if we re-write the
%Total_Infectiousness.m file

R_Prior = gamrnd(PriorParameters(1), PriorParameters(2), 1, TotalSampleSize);

for j = 1:TotalSimulatedDays
    
    %PoissHere
    I_by_gen = zeros(1 + length(q),TotalSampleSize);
    
    I_by_gen(1, :) = poissrnd(R_Prior*Total_Infectiousness(I(1:j+length(I_0)), [0 w]));

    for i = 2:length(q)+1
       %%PoissHere
        I_by_gen(i, :) = poissrnd(I_by_gen(i-1, :).*R_Prior*q(i-1));
        
    end
% %     
    It = sum(I_by_gen, 1);
    It_Mat(j, :) = It;
    %We require the FreqMat (the frequency of the simulations which in some way match the data)
    %to be within roughly 1% of the data, since mathcing exactly becomes
    %statistically unlikley for large R simulations. We also add 0.1 to the
    %data in the denominator in case the incidence is 0 at that point.
    
    IdxMatch = (abs((It - I(j+length(I_0))))/(1+I(j+length(I_0))) <= RelativeThreshold);
    
    R_RawPosterior = R_Prior(IdxMatch);
    BinEdges = linspace(RPosteriorLims(1), RPosteriorLims(2), RPosteriorResolution);
    BinCentres = BinEdges + (BinEdges(1) + BinEdges(2))/2; BinCentres(end) = [];
    NormalisedPosterior = histcounts(R_RawPosterior, 'BinEdges', BinEdges)/length(R_RawPosterior);
    CumPosterior = cumsum(NormalisedPosterior);
    
    %Finding confidence intervals
    IdxCILower = (CumPosterior > 0.05);
    CItmp = BinCentres(IdxCILower);
    CI(1, j) = CItmp(1);
    IdxCIUpper = (CumPosterior > 0.95);
    CItmp = BinCentres(IdxCIUpper);
    CI(2, j) = CItmp(1);
    
    %Finding Mean
    
    Mean(j) = mean(R_RawPosterior);
    
end

Mean = [repmat(nan, 1, length(I_0)) Mean];
CI = [repmat(nan, 2, length(I_0)) CI];

InferenceStruct = struct('Mean', Mean, 'CI', CI, 'It_Mat', It_Mat);

end