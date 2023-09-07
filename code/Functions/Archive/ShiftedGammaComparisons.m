function [] = ShiftedGammaComparisons(x, mu, sigma)

k1 = mu^2/sigma;
th1 =  sigma/mu;

k2 = (k1 - 1/th1)^2/k1;
th2 = k1*th1^2/(k1*th1 - 1);

y1 = gampdf(x, k1, th1);
y2 = gampdf(x, k2, th2);

figure
plot(x, y1);
hold on
plot(x+1, y2);

end

