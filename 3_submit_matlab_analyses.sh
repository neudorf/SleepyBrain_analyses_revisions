#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --time=0-5:00:00            # Time limit (hh:mm:ss)
#SBATCH --ntasks=1                # Number of CPU cores
#SBATCH --mem=10G                 # Memory
#SBATCH --nodes=1                 # Number of nodes

module load matlab/2022b.2

echo "start mean_centred_pls.m"
matlab -nodisplay -r "run('mean_centred_pls.m'); exit;"
echo "done mean_centred_pls.m"
echo "start modularity.m"
matlab -nodisplay -r "run('modularity.m'); exit;"
echo "done modularity.m"