function InferenceStruct = SameDayInference(InputStruct)

SampleSize = InputStruct.SampleSize;
PriorParameters = InputStruct.PriorParameters;
TotalSimulatedDays = InputStruct.TotalSimulatedDays;
w = InputStruct.Serial; q = InputStruct.SameDayGenerations;
w_0 = InputStruct.w_0; I = InputStruct.I; I_0 = InputStruct.I_0; 
R_scan_length = InputStruct.R_scan_length;

%For now, we fix R_scan because we may or may not be given R outside of
%this function
R_scan = linspace(0.5, 5, R_scan_length)';
Prior = gampdf(R_scan, PriorParameters(1), PriorParameters(2))';

PosteriorMat = zeros(TotalSimulatedDays, length(R_scan));
CI = zeros(2, TotalSimulatedDays);
Mean = zeros(1, TotalSimulatedDays);
It_Mat = zeros(length(R_scan), SampleSize, TotalSimulatedDays);
%It is possible to also get rid of this for loop if we re-write the
%Total_Infectiousness.m file

for j = 1:TotalSimulatedDays
    
    %PoissHere
    It = poissrnd(repmat(R_scan*Total_Infectiousness(I(1:j+length(I_0)), [0 w]), 1, SampleSize));

%     It = poissrnd(sum([1 w_0].*(R_scan.^(0:length(w_0))), 2).*It);
    
    It_3DMatrix = zeros(length(R_scan), SampleSize, length(q)+1);
    It_3DMatrix(:, :, 1) = It;

    for i = 1:length(q)
       %%PoissHere
        It_3DMatrix(:, :, i+1) = poissrnd(R_scan.*It_3DMatrix(:, :, i)*q(i));
        
    end
% %     
    It = sum(It_3DMatrix,3);
    %We require the FreqMat (the frequency of the simulations which in some way match the data)
    %to be within roughly 1% of the data, since mathcing exactly becomes
    %statistically unlikley for large R simulations. We also add 1 to the
    %data in the denominator in case the incidence is 0 at that point.
    
    It_Mat(:, :, j) = It;
    
    FreqLikeliMat = sum(abs((It - I(j+length(I_0))))/(1+I(j+length(I_0))) <= 0.1, 2)';
    FreqPosteriorMat = FreqLikeliMat.*Prior;
    PosteriorMat(j, :) = FreqPosteriorMat/sum(FreqPosteriorMat);
    CumPosteriorMat = cumsum(PosteriorMat(j, :));
    
    %Finding confidence intervals
    LowerLogical = (CumPosteriorMat > 0.05);
    UpperLogical = (CumPosteriorMat > 0.95);
    
    LowerR = R_scan(LowerLogical);
    CI(1, j) = LowerR(1);
    
    UpperR = R_scan(UpperLogical);
    CI(2, j) = UpperR(1);
    
    %Finding Mean
    
    Mean(j) = sum(PosteriorMat(j, :).*R_scan')/sum(PosteriorMat(j, :));
    
end

Mean = [repmat(nan, 1, length(I_0)) Mean];
CI = [repmat(nan, 2, length(I_0)) CI];

InferenceStruct = struct('Mean', Mean, 'CI', CI, 'It_Mat', It_Mat, 'R_scan', R_scan);

end