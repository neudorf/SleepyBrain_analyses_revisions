#!/bin/bash
#SBATCH --account=rrg-rmcintos
#SBATCH --time=0-4:00:00            # Time limit (hh:mm:ss)
#SBATCH --ntasks=1                # Number of CPU cores
#SBATCH --mem=4G                 # Memory
#SBATCH --nodes=1                 # Number of nodes

module load StdEnv/2020 r/4.3.1 gcc/9.3.0 gdal/3.5.1 udunits/2.2.28
export R_LIBS=~/.local/R/$EBVERSIONR/

echo "start GM_sig_var_analyses.r"
Rscript GM_sig_var_analyses.r
echo "done GM_sig_var_analyses.r"

echo "start modularity_analyses.r"
Rscript modularity_analyses.r
echo "done modularity_analyses.r"

echo "start PLS_usc_figures.r"
Rscript PLS_usc_figures.r
echo "done PLS_usc_figures.r"