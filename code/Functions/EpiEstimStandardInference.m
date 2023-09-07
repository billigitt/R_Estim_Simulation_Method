function EEInferenceOutput = EpiEstimStandardInference(SimulationInput)

%This function performs the standard Cori et al. method for Rt inference,
%wrapping the outputs into a struct, EEInferenceOutput.

I = SimulationInput.I_data; PriorPara = SimulationInput.PriorPara;
SerialPara = SimulationInput.SerialPara;
SerialTimeDays = SimulationInput.SerialTimeDays;
Spaces = SimulationInput.Spaces;
tau = SimulationInput.tau;

SerialInput = struct('Parameters', SerialPara, 'SerialTimeDays', SerialTimeDays, ...
    'Spaces', Spaces, 'SameDayGenerations', 1 , ...
    'N', 1); 
SerialOutput = Serial_Discretiser(SerialInput);

w = SerialOutput.w;
w(1) = w(1) + SerialOutput.w_0;

w = [0 w];

EEInferenceInput = struct('I', I, 'W', w, 'PriorPar', PriorPara, 'tau', tau);

EEInferenceOutput = R_Time_Series_EpiEstim(EEInferenceInput);
EEInferenceOutput.Serial = w;
end