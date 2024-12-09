# Analysis code for: "Opposite effects of acute sleep restriction on the dynamic and static functional connectivity network of young and old adult brains"

Working manuscript [here](https://1sfu-my.sharepoint.com/:w:/g/personal/jneudorf_sfu_ca/EXsLHFDGinBDk5A3kxfFUdUBxr3d3K1FVV7HrVlWiet5nQ?e=AvHv8S)

## Environment installation instructions:
Note: for each section follow the instructions in *either* the `Local Bash` or the `HPC (Alliance Canada) Bash` subsection.

### Python:
#### Local Bash
```bash
git clone https://github.com/McIntosh-Lab/SleepyBrain_analyses.git
cd SleepyBrain_analyses
conda create -n neudorf_venv -c conda-forge python=3.10 numpy scipy nibabel nilearn matplotlib pillow pandas seaborn tqdm statsmodels plotnine networkx
conda activate neudorf_venv
pip install nctpy
python -m pip install matlabengine=9.13.11 #matlab 2022b.2
cd python_libraries
git clone https://github.com/netneurolab/neuromaps
cd neuromaps
python -m pip install .
cd ../brainvistools
python -m pip install .
cd ../PyNeudorf
python -m pip install .
cd ../..
```

#### HPC (Alliance Canada) Bash
```bash
cd ~/scratch
git clone https://github.com/McIntosh-Lab/SleepyBrain_analyses.git
cd SleepyBrain_analyses/python_libraries
git clone https://github.com/netneurolab/neuromaps
cd ..
module load StdEnv/2020 matlab/2022b.2 python/3.10
python3.10 -m venv neudorf_venv
source neudorf_venv/bin/activate
pip install numpy scipy nibabel nilearn matplotlib==3.6.2 pillow pandas seaborn==0.12.1 tqdm statsmodels plotnine==0.12.3 certifi nctpy networkx
#edit line below by finding matlabroot using `which matlab`, and substitute `matlab` executable with `glnxa64`
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/cvmfs/restricted.computecanada.ca/easybuild/software/2020/x86-64-v3/Core/matlab/2022b.2/bin/glnxa64
#set matlabengine version number to match matlab version 2022b.2
python -m pip install matlabengine==9.13.11
cd python_libraries/neuromaps
python -m pip install .
cd ../brainvistools
python -m pip install .
cd ../PyNeudorf
python -m pip install .
cd ../..
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

### For code review:
#### Reviewer 1
Fig. 7 A: `outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_degree_usc_ggplot.png`

Fig. 7 B: `outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_cortex.png` and `outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_subcortex.png`

Fig. 7 C: `outputs/PLS/mean_centred_PLS/SA_axis_schaefer200x17_ggseg.png`

#### Reviewer 2
Fig. 11 A: `outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_FO_ggplot.png`

Fig. 11 B: based on values in `outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_bsr_2.0thresh_leida_FO.csv`

Fig. 11 C: `leida_FO_global_ggplot.png`

#### Reviewer 3
Figure 12: `outputs/modularity/Q.pdf`

Table 1: results from `summary(lm)` in `modularity_analyses.r`

### Order to run code:
#### Local Bash
1. `data/data_processing/import_SleepyBrain_data.py`
2. LEiDA toolbox in `leida-matlab-1.0/`. Info is in the corresponding README.md as well, but edit path at the top of `LEiDA_Start.m` and `run_all_after_start.m`. Then run `LEiDA_Start.m` followed by `run_all_after_start.m`. You can change `n_permutations` and `n_bootstraps` to a higher number after testing.
3. `mean_centred_pls.m` edit paths marked `% edit` first
4. `modularity.m` edit path marked `% edit` first
5. `rsfMRI_sleep_deprivation_analyses.py` (change `RSCRIPT='/usr/bin/Rscript'` at top of `rsfMRI_sleep_deprivation_analyses.py` to `RSCRIPT='/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Core/r/4.3.1/bin/Rscript'`)
6. `GM_sig_var_analyses.r`, `modularity_analyses.r`, and `PLS_usc_figures.r` in no particular order.

#### HPC (Alliance Canada) Bash
Use sbatch submission scripts provided:
 - `0_copy_data.sh`
 - `1_submit_preprocessing.sh`
 - `leida-matlab-1.0/2_submit_leida.sh` (refer to step 2. above and edit paths)
 - `3_submit_matlab_analyses.sh` (refer to steps 3 & 4 above and edit paths)
 - `4_submit_python_analyses.sh` (change `RSCRIPT='/usr/bin/Rscript'` at top of `rsfMRI_sleep_deprivation_analyses.py` to `RSCRIPT='/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Core/r/4.3.1/bin/Rscript'`)
 - `5_submit_r_analyses.sh`
 - `6_submit_FC_null_array.sh` (optional for FAIR review) first edit path at top of FC_null_array.m