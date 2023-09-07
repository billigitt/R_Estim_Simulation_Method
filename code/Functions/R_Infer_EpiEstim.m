function [Mean, Variance, Upper, Lower, Shape, Scale] = R_Infer_EpiEstim(I_02t, W, Par, tau)
%Inference is instantaneous R_t so we use (a subset of) I_0 to I_t. Allow 
%for time-varying GI/SI so w is a vector but the input may be extracting a
%row from a matrix (the GI at that time). Par is the [a b] values from the
%prior distribution. Again, there is potential to update this on each loop,
%outside of this function (we permit the updated a and b paramters to be 
%ouputs of the function). Tau is the time-window over which the likelihood
%is taken. i is the step in the algorithm.

Shape = sum(I_02t(end-tau+1:end)) + Par(1);
Scale = 0;
for k = 1:tau

    Scale = Scale + Total_Infectiousness_EpiEstim(I_02t(1:end-tau+k), W);

end
Scale = Scale + (1/Par(2));
Scale = 1/Scale;
Mean = Shape*Scale;
Variance = Shape*Scale^2;
Upper = gaminv(0.95, Shape, Scale);
Lower = gaminv(0.05, Shape, Scale);

end

