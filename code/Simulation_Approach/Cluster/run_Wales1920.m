function run_Wales1920(Workers)

addpath(genpath('../'))
addpath(genpath('../../Functions'))


% this is our main function, which runs the code
% the output for time taken to run (eg tic toc) will be stored in the slurm
% output folder
tic

% location to save sequence (change matjqj with your user name)
% make sure you have created a folder called "test" (eg use mkdir test)
%save_output = '/storage/rawsys/test/';
save_output = '';
%save_output = '';
% get the first N fibonacci numbers

WalesBigCalc1920(Workers, 168);

toc
end
