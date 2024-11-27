#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --time=0-3:00:00            # Time limit (hh:mm:ss)
#SBATCH --ntasks=1                # Number of CPU cores
#SBATCH --mem=4G                 # Memory
#SBATCH --nodes=1                 # Number of nodes

echo starting
cd data
cp ~/projects/def-rmcintos/jneudorf/SleepyBrain_DMP/pipeline_outputs/pipeline_outputs_FIXed/connectivity_220.tar.gz .
cp ~/projects/def-rmcintos/jneudorf/SleepyBrain_DMP/pipeline_outputs/pipeline_outputs_FIXed/QC_220.tar.gz .
cp ~/projects/def-rmcintos/jneudorf/SleepyBrain_DMP/pipeline_outputs/pipeline_outputs_FIXed/rfMRI_niftis.tar.gz .
tar -xf connectivity_220.tar.gz
tar -xf QC_220.tar.gz
tar -xf rfMRI_niftis.tar.gz
echo done