function Output = GammaGet(Mean,StDev)

% Takes a gamma input parameterisation of mean and standard deviation and
% outputs the shape and scale parameterisation.

Shape = Mean^2/StDev^2;
Scale = StDev^2/Mean;

Output = [Shape Scale];

end

