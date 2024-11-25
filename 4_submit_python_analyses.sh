#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --time=0-90:00:00            # Time limit (hh:mm:ss)
#SBATCH --ntasks=1                # Number of CPU cores
#SBATCH --mem=40G                 # Memory
#SBATCH --nodes=1                 # Number of nodes

module load StdEnv/2020 r/4.3.1 matlab/2022b.2
source neudorf_venv/bin/activate
export R_LIBS=~/.local/R/$EBVERSIONR/
echo "Starting"
python -u rsfMRI_sleep_deprivation_analyses.py
echo "done"