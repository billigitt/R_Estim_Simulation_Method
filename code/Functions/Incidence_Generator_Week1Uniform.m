function I_data = Incidence_Generator_Week1Uniform(MainInput)

%Function Description
%This function takes a struct input with multiple fields, namely: 
%R_True: This is the assumed Rt values that the user inputs.
%N_true: The 'true' partitioning over which the incidence is generated.
%This is a subjective. Typically, the larger the more accurate the
%incidence generation.
%I_1: The assumed first value for the incidence
%SerialParameters: A 2 by 1 vector containing the shape and scale
%parameterisation for a Gamma distribution which describes the serial
%interval.
%SerialTimeDays: The length of time over which the serial interval is
%defined. Typically, it is best to make this value large so that the serial
%probabilities are guaranteed to sum to 1. Although the user should check
%with the Serial Parameterisation first.
%Spaces: The discretisation over which the integration is performed. The
%higher this number, the more accurate the serial interval, and therefore
%the incidence generated


% The output of the function is a random vector of incidence but one that
% aligns with the inputs provided. The length of the vector will be
% length(MainInput.R_True) + 1.

%Un-packing
R_True = MainInput.R_True;
T = length(R_True);
N_true = MainInput.N_true;

TrueI_hourly = zeros(1, (T + 1)*N_true);
% TrueI_hourly(1) = MainInput.I_1; %Assumed first value of incidence
%We don't infer R over this first value since there is no incidence before
%it

SerialInputStruct = struct('Parameters', MainInput.SerialParameters, 'SerialTimeDays', MainInput.SerialTimeDays, ...
    'Spaces', MainInput.Spaces, 'SameDayGenerations', 1, 'N', N_true);
SerialOutputStruct = Serial_Discretiser(SerialInputStruct);

w_Truehourly = SerialOutputStruct.w;
w_Truehourly(1) = w_Truehourly(1) + SerialOutputStruct.w_0;

R_Truehourly = reshape(repmat(R_True, N_true, 1), 1, []);

% for i = 2:N_true
%    
%     %Poisson random incidence generation with R number assumed as 1
%     TrueI_hourly(i) = MainInput.I_1;
%     
% end

randomIndices = randperm(N_true, MainInput.I_1);

TrueI_hourly(randomIndices) = 1;

for i = 1+N_true:(T+1)*N_true
    
    %Poisson random incidence generation using the true hourly R values
    TrueI_hourly(i) =  poissrnd(R_Truehourly(i-N_true)*...
        Total_Infectiousness(TrueI_hourly(1:i-1), w_Truehourly));
    
end

%Reshape I_data
I_data = sum(reshape(TrueI_hourly, N_true, T+1), 1);

end

