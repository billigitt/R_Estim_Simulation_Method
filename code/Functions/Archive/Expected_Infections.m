function ExpectedInfections = Expected_Infections(InputStruct)

%Unpack
R_t = InputStruct.R; I_data = InputStruct.I; 
Generation = InputStruct.w; w_0 = InputStruct.w_0;

if size(I_data, 1) + size(Generation, 1) + size(w_0, 1) ~= 3
   
    error('Zak identified an error. The data and GI need to be in rows.')
    
end

%Function takes incidence data relevant to the Generation Interval, and
%computes the 'Total Infectiousness', Capital Gamma in the literature.

    length_I = length(I_data);
    
    length_G = length(Generation);

    %Get Generation Interval and the Incidence to be the same length so we can dot
    %product
    
    if length_I < length_G
       
         Transmitting_Cases = [zeros(1,length_G - length_I), I_data];
%         
%         Transmitting_Cases = I_data;
% 
%         Generation(length_I+1:end) = [];
%         
%         Generation = Generation/(sum(Generation));
        
    else
        
        Transmitting_Cases = I_data(end-length_G+1:end);
        
    end

    It_0 = R_t*dot(Transmitting_Cases, fliplr(Generation)); %We now have to flip the Serial
     SameDayGens = length(w_0);
%     R_Power = R_t.^(0:SameDayGens);
%     
%     ExpectedInfections = sum(It_0*R_Power.*[1 w_0]);
    I_sameday = It_0*ones(1, SameDayGens);
    q = [w_0 1]./[1 w_0];
    q(end) = [];
    
    
    for i = 2:SameDayGens
       
        I_sameday(i) = R_t*I_sameday(i-1)*q(i-1);
        
    end

    ExpectedInfections = sum(I_sameday);
    
end