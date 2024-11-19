#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --job-name=FCnull
#SBATCH --cpus-per-task=8
#SBATCH --ntasks=1  # Each job in the array will have 1 task
#SBATCH --mem-per-cpu=8G
#SBATCH --time=0-1:00:00       # Adjust based on estimated runtime
#SBATCH --array=1-84           # Number of tasks in the array, one for each subject

# Load MATLAB module (adjust as per your cluster's MATLAB setup)
module load matlab

# Define MATLAB script
MATLAB_SCRIPT="FC_null_array.m"

# Determine which subject to process for this job array task
subject_index=$((SLURM_ARRAY_TASK_ID))

# Run MATLAB script for the selected subject index
matlab -nodisplay -nosplash -r "run('${MATLAB_SCRIPT}'); exit;"
