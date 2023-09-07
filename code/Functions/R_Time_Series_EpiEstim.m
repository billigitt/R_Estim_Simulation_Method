function OutputStruct = R_Time_Series_EpiEstim(InputStruct)


%Un-packing
Par = InputStruct.PriorPar;
W = InputStruct.W;
I = InputStruct.I;
tau = InputStruct.tau;

%Generates the entire sequence of CIs and mean R estimates for a serial
%interval matrix (each row is a different time) and the entire data stream
%of incident cases, I. This means that the output can be immeadiatley
%plotted.

%Diagram of I time-series:

% 1-2--...---------------------------------------t (Indices)
% 1-2--...--(tau)---------------(t-tau+1)--------t (Time)

%---start-----------------------start (Starts are at 2 and (t-tau+1) so
%there are t-tau values in the I time-series)


%This (as shown in the diagram) implies that the length of the sequence of
%CIs and Means is (t-tau), Epi-Estim doesnt use the first one for some
%reason.

t = length(I);
disp(t)
% StartPt = StartingPtFinder(t, W, 0.75, tau);

Means = zeros(1, t);
CIs = zeros(2, t);
Shape = zeros(t, 1);
Scale = zeros(t, 1);
Variance = zeros(t, 1);

for i = tau + 1 : t
    
    [Means(i), Variance(i), CIs(1, i), CIs(2, i), Shape(i), Scale(i)] = R_Infer_EpiEstim(I(1 : i), W, Par, tau);
    
end

Means(1:tau) = [];
Variance(1:tau) = [];
CIs(:, 1:tau) = [];
Shape(1:tau) = [];
Scale(1:tau) = [];

OutputStruct = struct('Means', Means, 'Variance', Variance, 'CIs', CIs, ...
    'Shape', Shape, 'Scale', Scale);

end