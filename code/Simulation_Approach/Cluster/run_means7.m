function run_means7(Seed, Workers)

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

[MeansOutput, I_data_Matrix, I_disag_1, CIs_1] = MeansLargeScaleComputation_7(Seed, Workers);

% take the power of each element


% save output
save(strcat(save_output,'LatestMeansResults_NoCondition_P7','_Seed_',string(Seed), '.mat'), ...
    'MeansOutput', 'I_data_Matrix', 'I_disag_1', 'CIs_1');
toc
end
