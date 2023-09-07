function OverallOutputStruct = CompareEEandSDI_ABCFunc(InputStruct)
tic
%% Experiment Description
%In this file (and subsequent files), we want to:
%A) Generate incidence from a pseudo-continuous 'real' SI, and a 'true' R.
%B) Generate inference SIs. One for the standard EpiEstim and one for our
%novel method.
%C) Compute Rt inference and see how this compares to the true R.

% !!! indicates places we have experimented with and need to be changed
SI_scale = InputStruct.SI_Para(1); SI_shape = InputStruct.SI_Para(2);
SI_TimeDays = InputStruct.SI_TimeDays; SameDayGens = InputStruct.SameDayGens;
Experiment = InputStruct.Experiment; I = InputStruct.I; 
TotalSampleSize = InputStruct.TotalSampleSize; Prior_Paras = InputStruct.Prior_Paras;
TotalSimDays = InputStruct.TotalSimDays; EEtau = InputStruct.EEtau; 
RPlotYLims = InputStruct.RPlotYLims; RelativeThreshold = InputStruct.RelativeThreshold;
RPosteriorResolution = InputStruct.RPosteriorResolution; RPosteriorLims = InputStruct.RPosteriorLims;
%% Serial Data
%Serial Interval and Same-Day Serial: sum(w) + w_0(1) = 1, since w_0(1) =
%probability of atleast one generation in one day.
rng(1)

SerialStruct = struct('Parameters', [SI_scale SI_shape], 'SerialTimeDays', SI_TimeDays, ...
    'SameDayGenerations', SameDayGens, 'Spaces', 10, 'N', 1);

OutputStruct = Serial_Discretiser(SerialStruct);

w = OutputStruct.w; w_0 = OutputStruct.w_0; q = OutputStruct.q;
%In this file, we consider the naive discretisation: w_1 = w_1 + w_0 (and
%set w_0 to 0). 
w_EpiEstim = w; w_EpiEstim(1) = w_0(1) + w_EpiEstim(1); w_EpiEstim = [0 w_EpiEstim];
f_SI = OutputStruct.f_SI; x = OutputStruct.x;
%% Incidence Data or Generation.
% Experiment = 'Data';
% Experiment = 'Synthetic';

if isequal(Experiment, 'Synthetic')
    
    R_True = InputStruct.R_True;
    HourlySerialStruct = struct('Parameters', SerialStruct.Parameters, ...
        'SerialTimeDays', SerialStruct.SerialTimeDays, ...
    'SameDayGenerations', SerialStruct.SameDayGenerations, 'Spaces', 10, 'N', 1);
    
    HourlySerialOutputStruct = Serial_Discretiser(HourlySerialStruct);

    RHourly = reshape(repmat(R_True, HourlySerialStruct.N, 1), 1, length(R_True)*HourlySerialStruct.N);
    I_0 = 10*(rand(1, HourlySerialStruct.N) > 0.25);
    I = I_0;
    
    InfectionsStruct = struct('R', RHourly(1), 'I', I, 'w', HourlySerialOutputStruct.w, 'w_0', HourlySerialOutputStruct.w_0);
    
    %Generate Synethetic Data
    for i = 1:TotalSimDays*HourlySerialStruct.N
        InfectionsStruct.R = RHourly(i);
        %Round here because i) Infections are people so integers and we use
        %a poisson calculation for inference...
        I_new = round(Expected_Infections(InfectionsStruct));
        InfectionsStruct.I = [InfectionsStruct.I I_new];
        
        
    end
    
    %Aggregation of hourly incidence back into days
    InfectionsStruct.I = reshape(InfectionsStruct.I, HourlySerialStruct.N, TotalSimDays + 1);
    InfectionsStruct.I = sum(InfectionsStruct.I, 1);
    
    I_0 = sum(I_0);
   
elseif isequal(Experiment, 'Data')
    
    InfectionsStruct = struct('I', I);
%     I_0 = ones(1, length(w))*InfectionsStruct.I(1);
    
    InfectionsStruct.I = [InfectionsStruct.I];
    
    TotalSimDays = length(I) - 1;
    
    R_True =nan;
end

%% Inference SameDay

InferenceInput = struct('TotalSampleSize', TotalSampleSize, 'PriorParameters', Prior_Paras, ...
    'TotalSimulatedDays', TotalSimDays, 'Serial', w, 'SameDayGenerations',...
    q, 'I', InfectionsStruct.I, 'I_0', InfectionsStruct.I(1), 'w_0', w_0, 'RelativeThreshold', RelativeThreshold, ...
    'RPosteriorLims', RPosteriorLims, 'RPosteriorResolution', ...
    RPosteriorResolution);

InferenceOutput = SameDayInference_ABC(InferenceInput);
%% Inference EpiEstim

% EEInferenceInput = struct('I', InfectionsStruct.I, 'W', w_EpiEstim, 'PriorPar', ...
%     InferenceInput.PriorParameters, 'tau', 1);

%Remember that we need to put a zero infront of inference. This is done
%within the function for SDI Inference but for EE we put it oustide the
%function
EEInferenceInput = struct('I', InfectionsStruct.I, 'W', [w_EpiEstim], 'PriorPar', ...
    InferenceInput.PriorParameters, 'tau', EEtau);

EEInferenceOutput = R_Time_Series_EpiEstim(EEInferenceInput);

%% Plotting

PlotterStruct = struct('SerialLength', length(w) + 1, ...
    'Serial', [w_0(1) w], 'x', x, 'f_SI', f_SI, 'I', InfectionsStruct.I, 'Mean', ...
    InferenceOutput.Mean, 'CI', InferenceOutput.CI, 'R', R_True, 'It_Mat', ...
    InferenceOutput.It_Mat, 'MeanEE',...
    EEInferenceOutput.Means, 'CIsEE', (EEInferenceOutput.CIs)', ...
    'YLims', RPlotYLims);

OverallOutputStruct = InferenceOutput;
OverallOutputStruct.Idata = InfectionsStruct.I;
OverallOutputStruct.w_0 = w_0;
OverallOutputStruct.q = q;


SameDayInfections_ABCAndEEPlotter(PlotterStruct);
toc


end