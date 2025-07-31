# Analysis code for: "Opposite effects of acute sleep restriction on the dynamic and static functional connectivity network of young and old adult brains"

This page includes the analysis code for our manuscript entitled: "Young and old adult brains experience opposite effects of acute sleep restriction on the functional connectivity network" (preprint [here](https://doi.org/10.1101/2025.07.25.666859)). The analyses in this manuscript can be reproduced using the code included here. To do so, begin by (1) setting up your environment by following the instructions under "Environment installation instructions" (you can set up an environment either locally or on a high-performance computing cluster). Then, (2) run the code in the order specified under the "Order to run code" section.

## Environment installation instructions:
Note: for each section follow the instructions in *either* the `Local Bash` or the `HPC (Alliance Canada) Bash` subsection.

### Python:
#### Local Bash
```bash
git clone https://github.com/McIntosh-Lab/SleepyBrain_analyses.git
cd SleepyBrain_analyses
conda create -n neudorf_venv -c conda-forge python=3.10 numpy scipy nibabel nilearn matplotlib pillow pandas seaborn tqdm statsmodels plotnine networkx
conda activate neudorf_venv
pip install nctpy matlabengine=9.13.11 #matlab 2022b.2
cd python_packages
git clone https://github.com/netneurolab/neuromaps
cd neuromaps
pip install .
cd ../brainvistools
pip install .
cd ../PyNeudorf
pip install .
cd ../..
```

#### HPC (Alliance Canada) Bash
```bash
cd ~/scratch
git clone https://github.com/McIntosh-Lab/SleepyBrain_analyses.git
cd SleepyBrain_analyses/python_packages
git clone https://github.com/netneurolab/neuromaps
cd ..
module load StdEnv/2020 matlab/2022b.2 python/3.10
python3.10 -m venv neudorf_venv
source neudorf_venv/bin/activate
#edit line below by finding matlabroot using `which matlab`, and substitute `matlab` executable with `glnxa64`
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cvmfs/restricted.computecanada.ca/easybuild/software/2020/x86-64-v3/Core/matlab/2022b.2/bin/glnxa64
pip install -r requirements_hpc.txt
```

### R:
#### Local Bash
```bash
Rscript install_packages.r
```

#### HPC (Alliance Canada) Bash
```bash
module load StdEnv/2020 r/4.3.1 gcc/9.3.0 gdal/3.5.1 udunits/2.2.28
mkdir -p ~/.local/R/$EBVERSIONR
export R_LIBS=~/.local/R/$EBVERSIONR/
Rscript install_packages.r
```

### Matlab:
#### Local Bash
Follow instructions here and add `plscmd` folder to startup.m: https://github.com/McIntosh-Lab/PLS

#### HPC (Alliance Canada) Bash
```bash
git clone https://github.com/McIntosh-Lab/PLS
cp -r PLS/plscmd ~/matlab
echo "addpath(genpath('~/matlab/plscmd'))" >> ~/matlab/startup.m
```

## Usage

### Order to run code:
#### Local Bash
1. `data/data_processing/import_SleepyBrain_data.py`
2. LEiDA toolbox in `leida-matlab-1.0/`. You can change `n_permutations` and `n_bootstraps` to a higher number after testing.
3. `mean_centred_pls.m`
4. `modularity.m`
5. `rsfMRI_sleep_deprivation_analyses.py`
6. `GM_sig_var_analyses.r`, `modularity_analyses.r`, and `PLS_usc_figures.r` in no particular order.

#### HPC (Alliance Canada) Bash
Use sbatch submission scripts provided:
 1. Copy data (0_copy_data.sh):
     1. `sbatch 0_copy_data.sh`
 2. Submit preprocessing (1_submit_preprocessing.sh):
     1. `sbatch 1_submit_preprocessing.sh`
 3. Submit LEiDA (2_submit_leida.sh):
     1. `cd leida-matlab-1.0`
     2. `sbatch 2_submit_leida.sh`
     3. `cd ..`.
 4. Submit MATLAB analyses (3_submit_matlab_analyses.sh):
     1. `sbatch 3_submit_matlab_analyses.sh`
 5. Submit Python analyses (4_submit_python_analyses.sh):
     1. Change `RSCRIPT='/usr/bin/Rscript'` at top of `rsfMRI_sleep_deprivation_analyses.py` to `RSCRIPT='/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Core/r/4.3.1/bin/Rscript'`
     2. `sbatch 4_submit_python_analyses.sh`
 6. Submit R analyses (5_submit_r_analyses.sh):
     1. `sbatch 5_submit_r_analyses.sh`
 7. Submit null testing matlab script (6_submit_FC_null_array.sh; optional for FAIR review):
     1. `sbatch 6_submit_FC_null_array.sh`
