#!/bin/bash
#SBATCH --job-name=Peq2and5
#SBATCH --time=1-24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1 
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=4000
#SBATCH --partition=fast 

module load matlab #load MATLAB 2017 (explore options with `module av`)

export NUMBERARG=1

matlab -nodisplay -nodesktop -nosplash -r "run_means2and5(${NUMBERARG}, ${SLURM_CPUS_PER_TASK}); quit"

