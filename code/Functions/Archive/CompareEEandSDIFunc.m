function [] = CompareEEandSDIFunc(InputStruct)
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
SDISampleSize = InputStruct.SDISampleSize; Prior_Paras = InputStruct.Prior_Paras;
TotalSimDays = InputStruct.TotalSimDays; EEtau = InputStruct.EEtau; 
RPlotYLims = InputStruct.RPlotYLims;
R_scan_length = InputStruct.R_scan_length;
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
w_EpiEstim = w; w_EpiEstim(2) = w_EpiEstim(2) + w_EpiEstim(1); w_EpiEstim(1) = 0;

f_SI = OutputStruct.f_SI; x = OutputStruct.x;
%% Incidence Data or Generation.
% Experiment = 'Data';
% Experiment = 'Synthetic';

if isequal(Experiment, 'Synthetic')
    
    HourlySerialStruct = struct('Parameters', SerialStruct.Parameters, ...
        'SerialTimeDays', SerialStruct.SerialTimeDays, ...
    'SameDayGenerations', SerialStruct.SameDayGenerations, 'Spaces', 10, 'N', 24);
    
    HourlySerialOutputStruct = Serial_Discretiser(HourlySerialStruct);

    TotalSimulatedDays = 50;
    R = 2;
    I_0 = (rand(1, HourlySerialStruct.N) > 0.5);
    I = I_0;
    
    InfectionsStruct = struct('R', R, 'I', I, 'w', HourlySerialOutputStruct.w, 'w_0', HourlySerialOutputStruct.w_0);
    
    %Generate Synethetic Data
    for i = 1:TotalSimulatedDays*HourlySerialStruct.N
        %Round here because i) Infections are people so integers and we use
        %a poisson calculation for inference...
        I_new = round(Expected_Infections(InfectionsStruct));
        InfectionsStruct.I = [InfectionsStruct.I I_new];
        
    end
    
    %Aggregation of hourly incidence back into days
    InfectionsStruct.I = reshape(InfectionsStruct.I, HourlySerialStruct.N, TotalSimulatedDays + 1);
    InfectionsStruct.I = sum(InfectionsStruct.I);
    
    I_0 = sum(I_0);
   
elseif isequal(Experiment, 'Data')
    
    R = 0;
    
    InfectionsStruct = struct('I', I);
    I_0 = ones(1, length(w))*InfectionsStruct.I(1);
    InfectionsStruct.I = [I_0 InfectionsStruct.I];
    
end

%% Inference SameDay

InferenceInput = struct('SampleSize', SDISampleSize, 'PriorParameters', Prior_Paras, ...
    'TotalSimulatedDays', TotalSimDays, 'Serial', w, 'SameDayGenerations',...
    q, 'I', InfectionsStruct.I, 'I_0', I_0, 'w_0', w_0, 'R_scan_length', R_scan_length);

InferenceOutput = SameDayInference(InferenceInput);
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
    InferenceOutput.Mean, 'CI', InferenceOutput.CI, 'R', R, 'It_Mat', ...
    InferenceOutput.It_Mat, 'R_scan', InferenceOutput.R_scan, 'MeanEE',...
    EEInferenceOutput.Means, 'CIsEE', (EEInferenceOutput.CIs)', ...
    'YLims', RPlotYLims);

SameDayInfectionsAndEEPlotter(PlotterStruct);
toc


end