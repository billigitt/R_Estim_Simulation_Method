function OutputStruct = Serial_Discretiser(Struct)

%Function to discretise the serial interval given a Gamma parameterisation.

Parameters = Struct.Parameters; SerialTimeDays = Struct.SerialTimeDays;
Spaces = Struct.Spaces; SameDayGenerations = Struct.SameDayGenerations;
N = Struct.N;
SerialLength = SerialTimeDays*N; %This includes 0.
%See Cori & Ferguson Appendix Section 11. We have generalised this so that
%we can split time into intervals of length N, i.e. (0, 1/N, 2/N, ...t, t +
%1/N, ...) 
f_U = @(u, kOverN) (N - N^2*(abs(u-kOverN)))/N;

%We must start at  -1 so that the w0 value can be calculated (this is
%included in the original documentation by Cori & Ferguson). The +1s 
%are i) accounting for the fact we start need integral limits for -1 and
%for SerialTimeDays + 1, so we have 3 extra points and ii) to make the 
%numbers nice in the linspace.
x = linspace(-1/N, SerialTimeDays + 1/N, SerialTimeDays*N*Spaces + 2*Spaces + 1);
f_SIAll = gampdf(x, Parameters(1), Parameters(2));
f_SI = f_SIAll;

for i = 2:SameDayGenerations
    
    f_SIAll = [f_SIAll; gampdf(x, Parameters(1)*i, Parameters(2))];
    
end

%We calculate a matrix of SIs, the rows go down in number of generations,
%where as the collumns are the number of days between infections.
W = zeros(SameDayGenerations, SerialLength);

for j = 1:SameDayGenerations
    
    for i = 1:SerialLength
        
        IndexDomain = (i-1)*Spaces + 1:(i+1)*Spaces + 1;
        Domain = x(IndexDomain);
        W(j, i) = trapz(Domain, f_SIAll(j, IndexDomain).*f_U(Domain, ...
            (Domain(1) + Domain(end))/2));
    end
    
end

w_0 = W(:, 1)';
q = [w_0 1]./[1 w_0];
q(end) = [];
w = W(1, :);
%We must remove the first element of the serial as this has already been
%included in the SameDayGeneration, w_0 or q.
w(1) = [];

OutputStruct = struct('w', w, 'w_0', w_0, 'q', q, 'f_SI', f_SI, 'x', x);

end