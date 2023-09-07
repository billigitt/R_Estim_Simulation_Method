#!/bin/bash
#SBATCH --job-name=Wales2223
#SBATCH --time=1-16:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=12
#SBATCH --mem-per-cpu=4000
#SBATCH --partition=fast 


module load matlab #load MATLAB 2017 (explore options with `module av`)


matlab -nodisplay -nodesktop -nosplash -r "run_Wales2223(${SLURM_CPUS_PER_TASK}); quit"

