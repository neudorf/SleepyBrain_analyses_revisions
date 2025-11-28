#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --time=0-18:00:00            # Time limit (hh:mm:ss)
#SBATCH --ntasks=1                # Number of CPU cores
#SBATCH --mem=20G                 # Memory
#SBATCH --nodes=1                 # Number of nodes

module load matlab/2022b.2

echo "start LEiDA_Start.m"
matlab -nodisplay -r "run('LEiDA_Start.m'); exit;"
echo "done LEiDA_Start.m"
echo "start run_all_after_start.m"
matlab -nodisplay -r "run('run_all_after_start.m'); exit;"
echo "done run_all_after_start.m"