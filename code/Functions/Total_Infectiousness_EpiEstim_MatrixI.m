function Gamma = Total_Infectiousness_EpiEstim_MatrixI(I_data, Generation)

%Same as Total_Infectiousness_EpiEstim.m and Total_Infectiousness.m but allows for matrix input for
%I_data (B*C). This means Gamma outputs a (B by 1 vector). Each ROW in
%I_data is an incidence data-set (B is the number of I_data sets we are looking at) 
%and C is the number of days of incidence looked at. 

%Error

if size(Generation, 1) ~= 1
   
    error('Zak identified an error. The GI need to be in rows.')
    
end

%Function takes incidence data relevant to the Generation Interval, and
%computes the 'Total Infectiousness', Capital Gamma in the literature.

    length_I = size(I_data, 2);
    
    length_G = length(Generation);
    
    length_Gamma = size(I_data, 1);

    %Get Generation Interval and the Incidence to be the same length so we can dot
    %product
    
    if length_I < length_G
       
         Transmitting_Cases = [zeros(length_Gamma,length_G - length_I), I_data];
        
    else
        
        Transmitting_Cases = I_data(:, end-length_G+1:end);
        
    end

    Gamma = Transmitting_Cases*flipud(Generation');
    
end