# %%
import numpy as np
import pandas as pd
from pathlib import Path
import pickle
from scipy import signal
from PyNeudorf import graphs
import nibabel as nib
from nibabel.processing import resample_from_to
import os

ATLAS = '220'
TR = 2.5
BEHAV_FILE = Path('../participants.tsv')

GOOD_SUBJECTS_FILE = Path('../SleepyBrain_ref_image_fix/good_subjects.txt')

BEHAV_OUTPUT_DIR = Path('behav')
BEHAV_OUTPUT_DIR.mkdir(parents=True,exist_ok=True)
BEHAV_OUTPUT_FILE = BEHAV_OUTPUT_DIR.joinpath('behav_good_subs.csv')
YA_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_YA.txt')
OA_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_OA.txt')
YA_FEMALE_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_YA_female.txt')
YA_MALE_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_YA_male.txt')
OA_FEMALE_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_OA_female.txt')
OA_MALE_SUBS_FILE = BEHAV_OUTPUT_DIR.joinpath('good_subjects_OA_male.txt')

FC_DATA_DIR = Path('../SleepyBrain_ref_image_fix/connectivity_220')
FC_OUTPUT_DIR = Path(f'FC/TVBSchaeferTian{ATLAS}')
FC_OUTPUT_DIR.mkdir(parents=True,exist_ok=True)
FC_OUTPUT_MATLAB_DIR = FC_OUTPUT_DIR.joinpath('matlab')
FC_OUTPUT_MATLAB_DIR.mkdir(parents=True,exist_ok=True)
FC_DEPRIVED_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('FC_deprived_sleep_dict.pkl')
FC_NORMAL_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('FC_normal_sleep_dict.pkl')
FC_DEGREE_DEPRIVED_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('FC_degree_deprived_sleep_dict.pkl')
FC_DEGREE_NORMAL_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('FC_degree_normal_sleep_dict.pkl')
FMRI_TIMESERIES_DEPRIVED_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('fmri_timeseries_deprived_sleep_dict.pkl')
FMRI_TIMESERIES_NORMAL_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath(f'fmri_timeseries_normal_sleep_dict.pkl')
FMRI_TIMESERIES_FILTERED_DEPRIVED_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath('fmri_timeseries_filtered_zscore_deprived_sleep_dict.pkl')
FMRI_TIMESERIES_FILTERED_NORMAL_SLEEP_DICT_FILE = FC_OUTPUT_DIR.joinpath(f'fmri_timeseries_filtered_zscore_normal_sleep_dict.pkl')
FMRI_TIMESERIES_OUTPUT_MATLAB_DIR = FC_OUTPUT_MATLAB_DIR.joinpath('leida_inputs')
FMRI_TIMESERIES_OUTPUT_MATLAB_DIR.mkdir(parents=True,exist_ok=True)

NIFTI_DATA_DIR = Path('../SleepyBrain_ref_image_fix/rfMRI_niftis')
VOXELWISE_DIR = FC_OUTPUT_DIR.joinpath('voxelwise')
VOXELWISE_DIR.mkdir(parents=True,exist_ok=True)
GM_SIG_VAR_FILE = VOXELWISE_DIR.joinpath('voxelwise_GM_sig_variability.csv')
GM_VOXELWISE_TS_DIR = VOXELWISE_DIR.joinpath('GM_voxelwise_timeseries_filtered_zscore')
GM_VOXELWISE_TS_DIR.mkdir(parents=True,exist_ok=True)
GM_IDX_FILE = GM_VOXELWISE_TS_DIR.joinpath('GM_idx.pkl')
EPI_AFFINE_FILE = GM_VOXELWISE_TS_DIR.joinpath('epi_affine.pkl')

GM_VOXELWISE_FC_DIR = Path('GM_voxelwise_FC')
GM_VOXELWISE_FC_DIR.mkdir(parents=True,exist_ok=True)

ATLAS_DIR = Path(f'../atlas')
ATLAS_FILE = ATLAS_DIR.joinpath(f'TVB_SchaeferTian_fixed_{ATLAS}_2mm.nii.gz')
ATLAS_FILE_4MM = ATLAS_DIR.joinpath(f'TVB_SchaeferTian_fixed_{ATLAS}_4mm.nii.gz')

QC_DATA_DIR = Path('../SleepyBrain_ref_image_fix/QC_220/')

# %%
# Get participants list
subjects = pd.read_csv(GOOD_SUBJECTS_FILE,header=None,names=['subject']).astype(int)
subjects_list = subjects.subject.to_list()

# %%
# Get subject behaviour data as dataframe
behav = pd.read_csv(BEHAV_FILE, sep="\t")
behav['subject'] = behav.participant_id.str.strip("sub-").astype(int)
behav = behav.drop('participant_id',axis=1)
print('behav shape')
print(behav.shape)

#%% merge with subjects so that only good subjects are kept
behav_good_subs = pd.merge(subjects,behav, on='subject', how='left')
behav_good_subs.to_csv(BEHAV_OUTPUT_FILE,sep=',',index=False)

old_subjects = behav_good_subs.loc[behav_good_subs.AgeGroup=='Old',['subject']].subject.to_list()
np.savetxt(OA_SUBS_FILE,old_subjects,fmt='%4i')
young_subjects = behav_good_subs.loc[behav_good_subs.AgeGroup=='Young',['subject']].subject.to_list()
np.savetxt(YA_SUBS_FILE,young_subjects,fmt='%4i')

old_female_subjects = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Old') & (behav_good_subs.Sex=='Female'),['subject']].subject.to_list()
np.savetxt(OA_FEMALE_SUBS_FILE,old_female_subjects,fmt='%4i')
old_male_subjects = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Old') & (behav_good_subs.Sex=='Male'),['subject']].subject.to_list()
np.savetxt(OA_MALE_SUBS_FILE,old_male_subjects,fmt='%4i')
young_female_subjects = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Young') & (behav_good_subs.Sex=='Female'),['subject']].subject.to_list()
np.savetxt(YA_FEMALE_SUBS_FILE,young_female_subjects,fmt='%4i')
young_male_subjects = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Young') & (behav_good_subs.Sex=='Male'),['subject']].subject.to_list()
np.savetxt(YA_MALE_SUBS_FILE,young_male_subjects,fmt='%4i')

#%% Group by sex & age
old_subjects_female = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Old') & (behav_good_subs.Sex=='Female'),['subject']].subject.to_list()
old_subjects_male = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Old') & (behav_good_subs.Sex=='Male'),['subject']].subject.to_list()
young_subjects_female = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Young') & (behav_good_subs.Sex=='Female'),['subject']].subject.to_list()
young_subjects_male = behav_good_subs.loc[(behav_good_subs.AgeGroup=='Young') & (behav_good_subs.Sex=='Male'),['subject']].subject.to_list()

# %%
# This is for FC of subjects rated as good
# Get FC matrices and fMRI timecourses and make pickles of dictionairies with subject number as key
ROI_remove=[]

FC_timeseries_deprived_sleep_dict = {}
FC_timeseries_normal_sleep_dict = {}
# FC_matrix_deprived_sleep_dict = {}
# FC_matrix_normal_sleep_dict = {}

for sub in subjects_list:
    #Sl_cond is the sleep condition counterbalancing. 1 means sleep deprivation was first (rfMRI_0.ica), while 2 means sleep deprivation was second (rfMRI_1.ica).
    counterbalance = int(behav_good_subs.loc[behav_good_subs.subject==sub,'Sl_cond'].iloc[0])
    deprived_sleep_session = 0 if counterbalance == 1 else 1
    normal_sleep_session = int(not deprived_sleep_session)

    #Not using FC straight from pipeline, calculating from freq filtered ts below
    # FC_matrix = np.genfromtxt(FC_DATA_DIR.joinpath(f'sub-{sub}_TVBSchaeferTian{ATLAS}_tvb_inputs/functional_inputs/rfMRI_{deprived_sleep_session}.ica/rfMRI_{deprived_sleep_session}.ica_functional_connectivity.txt'),delimiter=' ')
    # FC_matrix[np.diag_indices_from(FC_matrix)] = 1.0
    # for ROI in ROI_remove:
    #     FC_matrix = np.delete(FC_matrix, ROI, axis=0)
    #     FC_matrix = np.delete(FC_matrix, ROI, axis=1)
    # FC_matrix_deprived_sleep_dict[sub] = FC_matrix

    # FC_matrix = np.genfromtxt(FC_DATA_DIR.joinpath(f'sub-{sub}_TVBSchaeferTian{ATLAS}_tvb_inputs/functional_inputs/rfMRI_{normal_sleep_session}.ica/rfMRI_{normal_sleep_session}.ica_functional_connectivity.txt'),delimiter=' ')
    # FC_matrix[np.diag_indices_from(FC_matrix)] = 1.0
    # for ROI in ROI_remove:
    #     FC_matrix = np.delete(FC_matrix, ROI, axis=0)
    #     FC_matrix = np.delete(FC_matrix, ROI, axis=1)
    # FC_matrix_normal_sleep_dict[sub] = FC_matrix

    FC_timeseries = np.genfromtxt(FC_DATA_DIR.joinpath(f'sub-{sub}_TVBSchaeferTian{ATLAS}_tvb_inputs/functional_inputs/rfMRI_{deprived_sleep_session}.ica/rfMRI_{deprived_sleep_session}.ica_time_series.txt'),delimiter=' ').T
    for ROI in ROI_remove:
        FC_timeseries = np.delete(FC_timeseries, ROI, axis=0)
    FC_timeseries_deprived_sleep_dict[sub] = FC_timeseries

    FC_timeseries = np.genfromtxt(FC_DATA_DIR.joinpath(f'sub-{sub}_TVBSchaeferTian{ATLAS}_tvb_inputs/functional_inputs/rfMRI_{normal_sleep_session}.ica/rfMRI_{normal_sleep_session}.ica_time_series.txt'),delimiter=' ').T
    for ROI in ROI_remove:
        FC_timeseries = np.delete(FC_timeseries, ROI, axis=0)
    FC_timeseries_normal_sleep_dict[sub] = FC_timeseries

FC_timeseries_deprived_sleep_min_timepoints = np.min([ts.shape[1] for k,ts in FC_timeseries_deprived_sleep_dict.items()])
FC_timeseries_normal_sleep_min_timepoints = np.min([ts.shape[1] for k,ts in FC_timeseries_normal_sleep_dict.items()])
print(FC_timeseries_deprived_sleep_min_timepoints)
print(FC_timeseries_normal_sleep_min_timepoints)
FC_timeseries_min_timepoints = np.min([FC_timeseries_deprived_sleep_min_timepoints,FC_timeseries_normal_sleep_min_timepoints])
print("min timepoints:",FC_timeseries_min_timepoints)

for sub in subjects_list:
    FC_timeseries_deprived_sleep_dict[sub] = FC_timeseries_deprived_sleep_dict[sub][:,:FC_timeseries_min_timepoints]
    FC_timeseries_normal_sleep_dict[sub] = FC_timeseries_normal_sleep_dict[sub][:,:FC_timeseries_min_timepoints]

with open(FMRI_TIMESERIES_DEPRIVED_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_timeseries_deprived_sleep_dict, f)
with open(FMRI_TIMESERIES_NORMAL_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_timeseries_normal_sleep_dict, f)

#%%
def bandpass_filter_rois(rois_timeseries, samp_interval, cutoff_high, cutoff_low, axis=1):
    samp_freq = 1 / samp_interval
    w = [cutoff_low, cutoff_high]
    sos = signal.butter(5,w,'bandpass',fs=samp_freq, output='sos')
    output = signal.sosfiltfilt(sos, rois_timeseries, axis)
    return output

rsfMRI_filtered_deprived_sleep_dict = {k:bandpass_filter_rois(ts, TR, .1, .01, axis=1) for k,ts in FC_timeseries_deprived_sleep_dict.items()}
rsfMRI_filtered_zscore_deprived_sleep_dict = {k:((ts.T - np.mean(ts,axis=1)) / np.std(ts,axis=1)).T for k,ts in rsfMRI_filtered_deprived_sleep_dict.items()}

rsfMRI_filtered_normal_sleep_dict = {k:bandpass_filter_rois(ts, TR, .1, .01, axis=1) for k,ts in FC_timeseries_normal_sleep_dict.items()}
rsfMRI_filtered_zscore_normal_sleep_dict = {k:((ts.T - np.mean(ts,axis=1)) / np.std(ts,axis=1)).T for k,ts in rsfMRI_filtered_normal_sleep_dict.items()}

with open(FMRI_TIMESERIES_FILTERED_DEPRIVED_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(rsfMRI_filtered_zscore_deprived_sleep_dict, f)

with open(FMRI_TIMESERIES_FILTERED_NORMAL_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(rsfMRI_filtered_zscore_normal_sleep_dict, f)

for sub in young_subjects:
    save_name = f'{sub}_deprived_sleep.txt'
    np.savetxt(FMRI_TIMESERIES_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),rsfMRI_filtered_zscore_deprived_sleep_dict[sub],delimiter='\t')
    save_name = f'{sub}_normal_sleep.txt'
    np.savetxt(FMRI_TIMESERIES_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),rsfMRI_filtered_zscore_normal_sleep_dict[sub],delimiter='\t')

for sub in old_subjects:
    save_name = f'{sub}_deprived_sleep.txt'
    np.savetxt(FMRI_TIMESERIES_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),rsfMRI_filtered_zscore_deprived_sleep_dict[sub],delimiter='\t')
    save_name = f'{sub}_normal_sleep.txt'
    np.savetxt(FMRI_TIMESERIES_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),rsfMRI_filtered_zscore_normal_sleep_dict[sub],delimiter='\t')

#%%Frequency power spectrum
from matplotlib import pyplot as plt
def power_spectrum(ts, sample_interval):
    ps = np.abs(np.fft.rfft(ts))**2
    freqs = np.fft.rfftfreq(ts.size, sample_interval)
    idx = np.argsort(freqs)

    plt.plot(freqs[idx], ps[idx])

power_spectrum(rsfMRI_filtered_deprived_sleep_dict[subjects_list[0]][0] - np.mean(rsfMRI_filtered_deprived_sleep_dict[subjects_list[0]][0]), TR)

#%%
FC_matrix_deprived_sleep_dict = {}
FC_matrix_normal_sleep_dict = {}
for sub in subjects_list:
    FC_timeseries_deprived_sleep = rsfMRI_filtered_zscore_deprived_sleep_dict[sub]
    FC_timeseries_normal_sleep = rsfMRI_filtered_zscore_normal_sleep_dict[sub]

    FC_matrix_r_deprived_sleep = np.corrcoef(FC_timeseries_deprived_sleep)
    FC_matrix_r_to_z_deprived_sleep = np.arctanh(FC_matrix_r_deprived_sleep)
    FC_matrix_r_to_z_deprived_sleep[np.isinf(FC_matrix_r_to_z_deprived_sleep)] = 0.0
    FC_matrix_deprived_sleep_dict[sub] = FC_matrix_r_to_z_deprived_sleep

    FC_matrix_r_normal_sleep = np.corrcoef(FC_timeseries_normal_sleep)
    FC_matrix_r_to_z_normal_sleep = np.arctanh(FC_matrix_r_normal_sleep)
    FC_matrix_r_to_z_normal_sleep[np.isinf(FC_matrix_r_to_z_normal_sleep)] = 0.0
    FC_matrix_normal_sleep_dict[sub] = FC_matrix_r_to_z_normal_sleep

#%%
with open(FC_DEPRIVED_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_matrix_deprived_sleep_dict, f)

with open(FC_NORMAL_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_matrix_normal_sleep_dict, f)

#%%
def create_file_list_pls(subs,filename,filename_cond1_tail,filename_cond2_tail):
    with open(FC_OUTPUT_MATLAB_DIR.joinpath(filename),'w') as f:
        f.write('')
    for sub in subs:
        filename_cond1 = f'{sub}{filename_cond1_tail}'
        with open(FC_OUTPUT_MATLAB_DIR.joinpath(filename),'a') as f:
            f.write(f'{FC_OUTPUT_MATLAB_DIR.joinpath(filename_cond1)}\n')
    for sub in subs:
        filename_cond2 = f'{sub}{filename_cond2_tail}'
        with open(FC_OUTPUT_MATLAB_DIR.joinpath(filename),'a') as f:
            f.write(f'{FC_OUTPUT_MATLAB_DIR.joinpath(filename_cond2)}')
            if sub != subs[-1]:
                f.write('\n')

#%% making flattened adj matrices for PLS analyses in matlab
for sub in young_subjects:
    save_name = f'{sub}_FC_deprived_sleep_YA.csv'
    adj_mat = np.copy(FC_matrix_deprived_sleep_dict[sub])
    flat_adj_mat = graphs.matrix_to_flat_triu(adj_mat)
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),flat_adj_mat,delimiter='\t')
    save_name = f'{sub}_FC_normal_sleep_YA.csv'
    adj_mat = np.copy(FC_matrix_normal_sleep_dict[sub])
    flat_adj_mat = graphs.matrix_to_flat_triu(adj_mat)
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),flat_adj_mat,delimiter='\t')

for sub in old_subjects:
    save_name = f'{sub}_FC_deprived_sleep_OA.csv'
    adj_mat = np.copy(FC_matrix_deprived_sleep_dict[sub])
    flat_adj_mat = graphs.matrix_to_flat_triu(adj_mat)
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),flat_adj_mat,delimiter='\t')
    save_name = f'{sub}_FC_normal_sleep_OA.csv'
    adj_mat = np.copy(FC_matrix_normal_sleep_dict[sub])
    flat_adj_mat = graphs.matrix_to_flat_triu(adj_mat)
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),flat_adj_mat,delimiter='\t')

#%%
# save file with flattened adj matrices in order needed by matlab for mean-centred PLS (2 group 2 condition)
create_file_list_pls(young_subjects,'FC_young_subjects_files.csv','_FC_deprived_sleep_YA.csv','_FC_normal_sleep_YA.csv')
create_file_list_pls(old_subjects,'FC_old_subjects_files.csv','_FC_deprived_sleep_OA.csv','_FC_normal_sleep_OA.csv')
create_file_list_pls(young_subjects_female,'FC_young_female_subjects_files.csv','_FC_deprived_sleep_YA.csv','_FC_normal_sleep_YA.csv')
create_file_list_pls(young_subjects_male,'FC_young_male_subjects_files.csv','_FC_deprived_sleep_YA.csv','_FC_normal_sleep_YA.csv')
create_file_list_pls(old_subjects_female,'FC_old_female_subjects_files.csv','_FC_deprived_sleep_OA.csv','_FC_normal_sleep_OA.csv')
create_file_list_pls(old_subjects_male,'FC_old_male_subjects_files.csv','_FC_deprived_sleep_OA.csv','_FC_normal_sleep_OA.csv')  

#%% Graph theory nodal measures
# Degree
FC_degree_deprived_sleep_dict = {k:np.sum(v,axis=0) for k,v in FC_matrix_deprived_sleep_dict.items()}
FC_degree_normal_sleep_dict = {k:np.sum(v,axis=0) for k,v in FC_matrix_normal_sleep_dict.items()}

with open(FC_DEGREE_DEPRIVED_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_degree_deprived_sleep_dict, f)

with open(FC_DEGREE_NORMAL_SLEEP_DICT_FILE,'wb') as f:
    pickle.dump(FC_degree_normal_sleep_dict, f)

for sub in young_subjects:
    save_name = f'{sub}_FC_degree_deprived_sleep_YA.csv'
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),FC_degree_deprived_sleep_dict[sub],delimiter='\t')
    save_name = f'{sub}_FC_degree_normal_sleep_YA.csv'
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),FC_degree_normal_sleep_dict[sub],delimiter='\t')

for sub in old_subjects:
    save_name = f'{sub}_FC_degree_deprived_sleep_OA.csv'
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),FC_degree_deprived_sleep_dict[sub],delimiter='\t')
    save_name = f'{sub}_FC_degree_normal_sleep_OA.csv'
    np.savetxt(FC_OUTPUT_MATLAB_DIR.joinpath(f'{save_name}'),FC_degree_normal_sleep_dict[sub],delimiter='\t')

#%%
# save file with order needed by matlab for mean-centred PLS (2 group 2 condition)
create_file_list_pls(young_subjects,'FC_degree_young_subjects_files.csv','_FC_degree_deprived_sleep_YA.csv','_FC_degree_normal_sleep_YA.csv')
create_file_list_pls(old_subjects,'FC_degree_old_subjects_files.csv','_FC_degree_deprived_sleep_OA.csv','_FC_degree_normal_sleep_OA.csv')
create_file_list_pls(young_subjects_female,'FC_degree_young_female_subjects_files.csv','_FC_degree_deprived_sleep_YA.csv','_FC_degree_normal_sleep_YA.csv')
create_file_list_pls(young_subjects_male,'FC_degree_young_male_subjects_files.csv','_FC_degree_deprived_sleep_YA.csv','_FC_degree_normal_sleep_YA.csv')
create_file_list_pls(old_subjects_female,'FC_degree_old_female_subjects_files.csv','_FC_degree_deprived_sleep_OA.csv','_FC_degree_normal_sleep_OA.csv')
create_file_list_pls(old_subjects_male,'FC_degree_old_male_subjects_files.csv','_FC_degree_deprived_sleep_OA.csv','_FC_degree_normal_sleep_OA.csv')

#%% voxelwise timeseries from preprocessed/cleaned niftis
    #nibabel import of niftis. Need to add MNI standardized version for MDMR, but local space good for global signal variability
    #will need affine for MNI space from SchaeferTian atlas to save MDMR figure, but no affine needed for subject space
regions_n = FC_degree_deprived_sleep_dict[subjects_list[0]].shape[0]
def global_signal_variability(sub,session):
    print(sub,session)
    rfMRI_nifti_deprived_sleep_img = nib.load(NIFTI_DATA_DIR.joinpath(f'sub-{sub}/rfMRI_{session}.ica/filtered_func_data_clean.nii.gz'))
    rfMRI_nifti_deprived_sleep_data = rfMRI_nifti_deprived_sleep_img.get_fdata()[:,:,:,:FC_timeseries_min_timepoints]
    parcellation_nifti_deprived_sleep_img = nib.load(NIFTI_DATA_DIR.joinpath(f'sub-{sub}/rfMRI_{session}.ica/parcellation_TVBSchaeferTian220.nii.gz'))
    parcellation_nifti_deprived_sleep_data = parcellation_nifti_deprived_sleep_img.get_fdata()
    GM_idx = (parcellation_nifti_deprived_sleep_data > 0.5) & (parcellation_nifti_deprived_sleep_data <= (regions_n + 0.5))
    rfMRI_nifti_deprived_sleep_GM_data = rfMRI_nifti_deprived_sleep_data[GM_idx,:]

    #find voxels to keep that do not have all zeros in timeseries
    rfMRI_nifti_deprived_sleep_GM_nonzero_voxels_idx = np.sum(rfMRI_nifti_deprived_sleep_GM_data,axis=-1) > 0
    rfMRI_nifti_deprived_sleep_GM_nonzero_data = rfMRI_nifti_deprived_sleep_GM_data[rfMRI_nifti_deprived_sleep_GM_nonzero_voxels_idx,:]

    rfMRI_nifti_deprived_sleep_GM_filtered_data = bandpass_filter_rois(rfMRI_nifti_deprived_sleep_GM_nonzero_data, TR, .1, .01, axis=1)
    rfMRI_nifti_deprived_sleep_GM_voxelwise_variability = np.std(rfMRI_nifti_deprived_sleep_GM_filtered_data,axis=0)
    rfMRI_nifti_deprived_sleep_GM_global_variability = np.mean(rfMRI_nifti_deprived_sleep_GM_voxelwise_variability)

    return rfMRI_nifti_deprived_sleep_GM_global_variability

rfMRI_global_signal_variability_deprived_sleep_YA_dict = {}
rfMRI_global_signal_variability_normal_sleep_YA_dict = {}
for sub in young_subjects:
    counterbalance = int(behav_good_subs.loc[behav_good_subs.subject==sub,'Sl_cond'].iloc[0])
    deprived_sleep_session = 0 if counterbalance == 1 else 1
    normal_sleep_session = int(not deprived_sleep_session)

    rfMRI_global_signal_variability_deprived_sleep_YA_dict[sub] = global_signal_variability(sub,deprived_sleep_session)
    rfMRI_global_signal_variability_normal_sleep_YA_dict[sub] = global_signal_variability(sub,normal_sleep_session)

rfMRI_global_signal_variability_deprived_sleep_OA_dict = {}
rfMRI_global_signal_variability_normal_sleep_OA_dict = {}
for sub in old_subjects:
    counterbalance = int(behav_good_subs.loc[behav_good_subs.subject==sub,'Sl_cond'].iloc[0])
    deprived_sleep_session = 0 if counterbalance == 1 else 1
    normal_sleep_session = int(not deprived_sleep_session)

    rfMRI_global_signal_variability_deprived_sleep_OA_dict[sub] = global_signal_variability(sub,deprived_sleep_session)
    rfMRI_global_signal_variability_normal_sleep_OA_dict[sub] = global_signal_variability(sub,normal_sleep_session)

#%% get motion parameters for LMM regression in R
FD_deprived_sleep_dict = {}
FD_normal_sleep_dict = {}
for sub in subjects_list:
    counterbalance = int(behav_good_subs.loc[behav_good_subs.subject==sub,'Sl_cond'].iloc[0])
    deprived_sleep_session = 0 if counterbalance == 1 else 1
    normal_sleep_session = int(not deprived_sleep_session)

    idp_df = pd.read_csv(QC_DATA_DIR.joinpath(f'sub-{sub}/IDP_files_TVBSchaeferTian220/tvb_new_IDPs.tsv'),delimiter='\t')
    FD_deprived_sleep_dict[sub] = float(idp_df.loc[idp_df.short == f'MCFLIRT_abs_disp_mean_rfMRI_{deprived_sleep_session}.ica',['value']].iloc[0][0])
    print(sub,'deprived',FD_deprived_sleep_dict[sub])
    FD_normal_sleep_dict[sub] = float(idp_df.loc[idp_df.short == f'MCFLIRT_abs_disp_mean_rfMRI_{normal_sleep_session}.ica',['value']].iloc[0][0])
    print(sub,'normal',FD_normal_sleep_dict[sub])

with open(GM_SIG_VAR_FILE,'w') as f:
    f.write('sub,age,sleep,GM_sig_variability,framewise_displacement\n')
for sub,var in rfMRI_global_signal_variability_deprived_sleep_YA_dict.items():
    with open(GM_SIG_VAR_FILE,'a') as f:
        f.write(f'{sub},young,deprived,{var:.7f},{FD_deprived_sleep_dict[sub]:.7f}\n')
for sub,var in rfMRI_global_signal_variability_normal_sleep_YA_dict.items():
    with open(GM_SIG_VAR_FILE,'a') as f:
        f.write(f'{sub},young,normal,{var:.7f},{FD_normal_sleep_dict[sub]:.7f}\n')
for sub,var in rfMRI_global_signal_variability_deprived_sleep_OA_dict.items():
    with open(GM_SIG_VAR_FILE,'a') as f:
        f.write(f'{sub},old,deprived,{var:.7f},{FD_deprived_sleep_dict[sub]:.7f}\n')
for sub,var in rfMRI_global_signal_variability_normal_sleep_OA_dict.items():
    with open(GM_SIG_VAR_FILE,'a') as f:
        f.write(f'{sub},old,normal,{var:.7f},{FD_normal_sleep_dict[sub]:.7f}\n')

#%% voxelwise timeseries from nifti in standard space for MDMR
#convert atlas to 4mm
os.system(f'flirt -in {ATLAS_FILE} -ref {ATLAS_FILE} -interp nearestneighbour -applyisoxfm 4.0 -nosearch -out {ATLAS_FILE_4MM}')
regions_n = FC_degree_deprived_sleep_dict[subjects_list[0]].shape[0]
def import_voxelwise_rfMRI_std(sub,session):
    atlas_nifti_img = nib.load(ATLAS_FILE_4MM)
    #convert rfMRI nifti to 4mm
    rfMRI_nifti_file = NIFTI_DATA_DIR.joinpath(f'sub-{sub}/rfMRI_{session}.ica/filtered_func_data_clean_std.nii.gz')
    rfMRI_nifti_file_4mm = NIFTI_DATA_DIR.joinpath(f'sub-{sub}/rfMRI_{session}.ica/filtered_func_data_clean_std_4mm.nii.gz')
    if not rfMRI_nifti_file_4mm.is_file():
        os.system(f'flirt -in {rfMRI_nifti_file} -ref {rfMRI_nifti_file} -applyisoxfm 4.0 -nosearch -out {rfMRI_nifti_file_4mm}')
    rfMRI_nifti_img = nib.load(rfMRI_nifti_file_4mm)
    rfMRI_nifti_data = rfMRI_nifti_img.get_fdata()[:,:,:,:FC_timeseries_min_timepoints]

    #adjust atlas data to be consistent with affine data for rfMRI/epi (for SleepyBrain data this will flip in LR direction but this is flexible to other data)
    atlas2epi_img = resample_from_to(atlas_nifti_img, (rfMRI_nifti_img.shape[:3], rfMRI_nifti_img.affine))
    atlas_nifti_data = atlas2epi_img.get_fdata()
    affine = atlas2epi_img.affine

    #GM indices from atlas data
    GM_idx = (atlas_nifti_data > 0.5) & (atlas_nifti_data <= (regions_n + 0.5))
    #extract GM voxels timeseries from rfMRI/epi data (timeseries is 2nd dimension)
    voxelwise_timeseries = rfMRI_nifti_data[GM_idx,:]

    return voxelwise_timeseries, GM_idx, affine

#These dictionaries are obvious memory hogs. Could save to disk and load each sub instead of holding them in dict.
#voxelwise_ts_deprived_sleep_dict = {}
voxelwise_timeseries_filtered_zscore_deprived_sleep_dict = {}
zero_voxels_idx_deprived_sleep_dict = {}
#voxelwise_ts_normal_sleep_dict = {}
voxelwise_timeseries_filtered_zscore_normal_sleep_dict = {}
zero_voxels_idx_normal_sleep_dict = {}

for sub in subjects_list:
    print(sub)
    #Sl_cond is the sleep condition counterbalancing. 1 means sleep deprivation was first (rfMRI_0.ica), while 2 means sleep deprivation was second (rfMRI_1.ica).
    counterbalance = int(behav_good_subs.loc[behav_good_subs.subject==sub,'Sl_cond'].iloc[0])
    deprived_sleep_session = 0 if counterbalance == 1 else 1
    normal_sleep_session = int(not deprived_sleep_session)

    voxelwise_ts_deprived_sleep, GM_idx, epi_affine = import_voxelwise_rfMRI_std(sub,deprived_sleep_session)
    #find voxels with zero activation throughout timeseries
    zero_voxels_idx_deprived_sleep_dict[sub] = np.sum(voxelwise_ts_deprived_sleep,axis=1) == 0
    print(np.sum(zero_voxels_idx_deprived_sleep_dict[sub]))

    voxelwise_ts_normal_sleep, GM_idx, epi_affine = import_voxelwise_rfMRI_std(sub,normal_sleep_session)
    #find voxels with zero activation throughout timeseries
    zero_voxels_idx_normal_sleep_dict[sub] = np.sum(voxelwise_ts_normal_sleep,axis=1) == 0
    print(np.sum(zero_voxels_idx_normal_sleep_dict[sub]))

    voxelwise_timeseries_filtered_deprived_sleep = bandpass_filter_rois(voxelwise_ts_deprived_sleep, TR, .1, .01, axis=1)
    voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub] = ((voxelwise_timeseries_filtered_deprived_sleep.T - np.mean(voxelwise_timeseries_filtered_deprived_sleep,axis=1)) / np.std(voxelwise_timeseries_filtered_deprived_sleep,axis=1)).T
    voxelwise_timeseries_filtered_normal_sleep = bandpass_filter_rois(voxelwise_ts_normal_sleep, TR, .1, .01, axis=1)
    voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub] = ((voxelwise_timeseries_filtered_normal_sleep.T - np.mean(voxelwise_timeseries_filtered_normal_sleep,axis=1)) / np.std(voxelwise_timeseries_filtered_normal_sleep,axis=1)).T

#find consensus across all subjects for nonzero indices (set voxels to 0/False if any subject has zeroes for all timepoints)
nonzero_voxels_idx_consensus =  np.logical_and( np.sum([v for k,v in zero_voxels_idx_deprived_sleep_dict.items()],axis=0) == 0,
                                                np.sum([v for k,v in zero_voxels_idx_normal_sleep_dict.items()],axis=0) == 0    )

for sub in subjects_list:
    #apply nonzero GM indices masking to voxelwise subject data
    voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub] = voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub][nonzero_voxels_idx_consensus]
    voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub] = voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub][nonzero_voxels_idx_consensus]

    np.save(GM_VOXELWISE_TS_DIR.joinpath(f'GM_voxelwise_4mm_ts_filtered_zscore_deprived_sleep_sub-{sub}.npy'),voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub])
    np.save(GM_VOXELWISE_TS_DIR.joinpath(f'GM_voxelwise_4mm_ts_filtered_zscore_normal_sleep_sub-{sub}.npy'),voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub])

    voxelwise_FC_deprived_sleep = np.corrcoef(voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub])
    voxelwise_FC_normal_sleep = np.corrcoef(voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub])
    np.save(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_deprived_sleep_sub-{sub}.npy'),voxelwise_FC_deprived_sleep)
    np.save(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_normal_sleep_sub-{sub}.npy'),voxelwise_FC_normal_sleep)

    print(sub,'masking')
    print(voxelwise_timeseries_filtered_zscore_deprived_sleep_dict[sub].shape)
    print(voxelwise_timeseries_filtered_zscore_normal_sleep_dict[sub].shape)

#set GM index data to False for zero connections and True for nonzero connections
GM_idx[np.where(GM_idx)] = nonzero_voxels_idx_consensus
print(np.sum(GM_idx))

with open(GM_IDX_FILE,'wb') as f:
    pickle.dump(GM_idx, f)
with open(EPI_AFFINE_FILE,'wb') as f:
    pickle.dump(epi_affine, f)