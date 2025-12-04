#%%
import numpy as np
import pandas as pd
import pickle
import math
import networkx as nx
from pathlib import Path
from bisect import bisect_left
from PyNeudorf import graphs
from brainvistools import visualization
import seaborn as sns
from matplotlib.colors import to_rgb, LinearSegmentedColormap
import scipy.io as sio
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
from statsmodels.formula.api import ols
import nibabel as nib
from scipy.ndimage import measurements
import scipy.stats as stats
import os
from neuromaps import transforms
from nilearn import plotting, datasets

#RSCRIPT = '/usr/bin/Rscript'
RSCRIPT = '/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Core/r/4.3.1/bin/Rscript'

ATLAS = '220'

DATA_PROCESSING_DIR = Path('data/data_processing/')
BEHAV_DIR = DATA_PROCESSING_DIR.joinpath('behav')
BEHAV_FILE = BEHAV_DIR.joinpath('behav_good_subs.csv')

SA_AXIS_FILE = Path('data/atlas/schaefer200x17_SAaxis.csv')

ATLAS_FRIENDLY_NAMES_FILE = DATA_PROCESSING_DIR.joinpath('BrainNet_templates/TVBSchaeferTian220_MNI_node_friendly_names.node')

FC_DIR = DATA_PROCESSING_DIR.joinpath(f'FC/TVBSchaeferTian{ATLAS}')
FC_DEPRIVED_SLEEP_DICT_FILE = FC_DIR.joinpath('FC_deprived_sleep_dict.pkl')
FC_NORMAL_SLEEP_DICT_FILE = FC_DIR.joinpath('FC_normal_sleep_dict.pkl')
FMRI_TIMESERIES_FILTERED_DEPRIVED_SLEEP_DICT_FILE = FC_DIR.joinpath('fmri_timeseries_filtered_zscore_deprived_sleep_dict.pkl')
FMRI_TIMESERIES_FILTERED_NORMAL_SLEEP_DICT_FILE = FC_DIR.joinpath(f'fmri_timeseries_filtered_zscore_normal_sleep_dict.pkl')
FC_DEGREE_DEPRIVED_SLEEP_DICT_FILE = FC_DIR.joinpath('FC_degree_deprived_sleep_dict.pkl')
FC_DEGREE_NORMAL_SLEEP_DICT_FILE = FC_DIR.joinpath('FC_degree_normal_sleep_dict.pkl')

TOTAL_FC_FILE = FC_DIR.joinpath('total_FC.csv')

PLS_BSR_DIR = Path('outputs/PLS/mean_centred_PLS')
PLS_BSR_DIR.mkdir(parents=True,exist_ok=True)
PLS_FC_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC.csv')
PLS_BNV_EDGE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC.edge')
PLS_BNV_NODE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC.node')

PLS_FC_SEX_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_sex.csv')
PLS_SEX_BNV_EDGE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC_sex.edge')
PLS_SEX_BNV_NODE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC_sex.node')

PLS_YOUNG_SLEEP_DIFF_POS_BSR_BNV_EDGE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC_pos_young_sleep_diff.edge')
PLS_YOUNG_SLEEP_DIFF_NEG_BSR_BNV_EDGE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_FC_neg_young_sleep_diff.edge')

PLS_FC_OLD_DEPRIVED_VS_NORMAL_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_lv1_bsr_2.0thresh_FC.csv')
PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_lv1_bsr_FC.edge')
PLS_OLD_DEPRIVED_VS_NORMAL_BNV_NODE_OUTPUT_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_lv1_bsr_FC.node')

PLS_FC_DEGREE_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree.csv')
PLS_FC_DEGREE_BSR_NOTHRESH_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_nothresh_FC_degree.csv')
PLS_FC_DEGREE_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_cortex.png')
PLS_FC_DEGREE_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_subcortex.png')
PLS_FC_DEGREE_NORMAL_SLEEP_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_normal_sleep_age_lv1_bsr_2.0thresh_FC_degree.csv')
PLS_FC_DEGREE_NORMAL_SLEEP_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_normal_sleep_age_lv1_bsr_2.0thresh_FC_degree_cortex.png')
PLS_FC_DEGREE_NORMAL_SLEEP_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_normal_sleep_age_lv1_bsr_2.0thresh_FC_degree_subcortex.png')
PLS_FC_DEGREE_DEPRIVED_SLEEP_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_deprived_sleep_age_lv1_bsr_2.0thresh_FC_degree.csv')
PLS_FC_DEGREE_DEPRIVED_SLEEP_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_deprived_sleep_age_lv1_bsr_2.0thresh_FC_degree_cortex.png')
PLS_FC_DEGREE_DEPRIVED_SLEEP_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_deprived_sleep_age_lv1_bsr_2.0thresh_FC_degree_subcortex.png')
PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_FC_degree.csv')
PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_FC_degree_cortex.png')
PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_FC_degree_subcortex.png')
PLS_FC_DEGREE_YOUNG_SLEEP_DIFF_SIG_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('FC_degree_PLS_sig_means_young_sleep_diff_cortex.png')
PLS_FC_DEGREE_OLD_SLEEP_DIFF_SIG_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('FC_degree_PLS_sig_means_old_sleep_diff_cortex.png')
PLS_FC_DEGREE_YOUNG_SLEEP_DIFF_SIG_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('FC_degree_PLS_sig_means_young_sleep_diff_subcortex.png')
PLS_FC_DEGREE_OLD_SLEEP_DIFF_SIG_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('FC_degree_PLS_sig_means_old_sleep_diff_subcortex.png')
PLS_FC_DEGREE_SEX_BSR_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_sex.csv')
PLS_FC_DEGREE_SEX_BSR_CORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_sex_cortex.png')
PLS_FC_DEGREE_SEX_BSR_SUBCORTEX_FIG_FILE = PLS_BSR_DIR.joinpath('mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_sex_subcortex.png')

SA_AXIS_FIG_FILE = PLS_BSR_DIR.joinpath('SA_axis_schaefer200x17_ggseg.png')

NBS_OUTPUT_DIR = Path('outputs/NBS')
NBS_OUTPUT_DIR.mkdir(parents=True,exist_ok=True)
NBS_BNV_EDGE_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts.edge')
NBS_BNV_NODE_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts.node')
NBS_BNV_EDGE_T2_5_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts_t2_5.edge')
NBS_BNV_NODE_T2_5_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts_t2_5.node')
NBS_BNV_EDGE_T2_9_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts_t2_9.edge')
NBS_BNV_NODE_T2_9_OUTPUT_FILE = NBS_OUTPUT_DIR.joinpath('YA_vs_OA_sleep_diff_NBS_ts_t2_9.node')

LEIDA_RESULTS_DIR = Path(f'leida-matlab-1.0/res_SleepyBrain_TVB_SchaeferTian_{ATLAS}')
LEIDA_CLUSTERS_FILE = LEIDA_RESULTS_DIR.joinpath('LEiDA_Clusters.mat')
LEIDA_OUTPUTS_DIR = Path('outputs/leida-matlab')
LEIDA_OUTPUTS_DIR.mkdir(parents=True,exist_ok=True)

VOXELWISE_DIR = DATA_PROCESSING_DIR.joinpath(f'FC/TVBSchaeferTian{ATLAS}/voxelwise')
GM_SIG_VAR_FILE = VOXELWISE_DIR.joinpath('voxelwise_GM_sig_variability.csv')
GM_IDX_FILE = VOXELWISE_DIR.joinpath('GM_voxelwise_timeseries_filtered_zscore/GM_idx.pkl')
EPI_AFFINE_FILE = VOXELWISE_DIR.joinpath('GM_voxelwise_timeseries_filtered_zscore/epi_affine.pkl')

GM_VOXELWISE_FC_DIR = DATA_PROCESSING_DIR.joinpath('GM_voxelwise_FC')

MDMR_DIR = Path('outputs/MDMR')
MDMR_DIR.mkdir(parents=True,exist_ok=True)

#%%
behav = pd.read_csv(BEHAV_FILE,delimiter=',')

with open(FC_DEPRIVED_SLEEP_DICT_FILE,'rb') as f:
    FC_matrix_deprived_sleep_dict = pickle.load(f)

with open(FC_NORMAL_SLEEP_DICT_FILE,'rb') as f:
    FC_matrix_normal_sleep_dict = pickle.load(f)

with open(FMRI_TIMESERIES_FILTERED_DEPRIVED_SLEEP_DICT_FILE,'rb') as f:
    FC_timeseries_deprived_sleep_dict = pickle.load(f)

with open(FMRI_TIMESERIES_FILTERED_NORMAL_SLEEP_DICT_FILE,'rb') as f:
    FC_timeseries_normal_sleep_dict = pickle.load(f)

#%%
subjects = behav.subject.to_list()
old_subjects = behav.loc[behav.AgeGroup=='Old',['subject']].subject.to_list()
young_subjects = behav.loc[behav.AgeGroup=='Young',['subject']].subject.to_list()

regions_n = FC_matrix_deprived_sleep_dict[subjects[0]].shape[0]

old_FC_deprived_sleep = np.zeros((len(old_subjects),regions_n,regions_n))
old_FC_normal_sleep = np.zeros((len(old_subjects),regions_n,regions_n))
for i,s in enumerate(old_subjects):
    old_FC_deprived_sleep[i,:,:] = FC_matrix_deprived_sleep_dict[s]
    old_FC_normal_sleep[i,:,:] = FC_matrix_normal_sleep_dict[s]

young_FC_deprived_sleep = np.zeros((len(young_subjects),regions_n,regions_n))
young_FC_normal_sleep = np.zeros((len(young_subjects),regions_n,regions_n))
for i,s in enumerate(young_subjects):
    young_FC_deprived_sleep[i,:,:] = FC_matrix_deprived_sleep_dict[s]
    young_FC_normal_sleep[i,:,:] = FC_matrix_normal_sleep_dict[s]

old_FC_sleep_diff = old_FC_deprived_sleep - old_FC_normal_sleep
young_FC_sleep_diff = young_FC_deprived_sleep - young_FC_normal_sleep

#%% Total FC analysis
old_FC_sum_deprived_sleep = {}
old_FC_sum_normal_sleep = {}
young_FC_sum_deprived_sleep = {}
young_FC_sum_normal_sleep = {}
for i,sub in enumerate(old_subjects):
    old_FC_sum_deprived_sleep[sub] = np.sum(np.triu(old_FC_deprived_sleep[i]))
    old_FC_sum_normal_sleep[sub] = np.sum(np.triu(old_FC_normal_sleep[i]))
for i,sub in enumerate(young_subjects):
    young_FC_sum_deprived_sleep[sub] = np.sum(np.triu(young_FC_deprived_sleep[i]))
    young_FC_sum_normal_sleep[sub] = np.sum(np.triu(young_FC_normal_sleep[i]))

with open(TOTAL_FC_FILE,'w') as f:
    f.write('sub,age,sleep,total_FC\n')
for sub,var in young_FC_sum_deprived_sleep.items():
    with open(TOTAL_FC_FILE,'a') as f:
        f.write(f'{sub},young,deprived,{var:.7f}\n')
for sub,var in young_FC_sum_normal_sleep.items():
    with open(TOTAL_FC_FILE,'a') as f:
        f.write(f'{sub},young,normal,{var:.7f}\n')
for sub,var in old_FC_sum_deprived_sleep.items():
    with open(TOTAL_FC_FILE,'a') as f:
        f.write(f'{sub},old,deprived,{var:.7f}\n')
for sub,var in old_FC_sum_normal_sleep.items():
    with open(TOTAL_FC_FILE,'a') as f:
        f.write(f'{sub},old,normal,{var:.7f}\n')

#%%
def ind_t_2d(group1_mat,group2_mat):
    group1_n = group1_mat.shape[0]
    group2_n = group2_mat.shape[0]
    group1_mean = np.mean(group1_mat,axis=0)
    group2_mean = np.mean(group2_mat,axis=0)
    group1_std = np.std(group1_mat,axis=0)
    group2_std = np.std(group2_mat,axis=0)

    pooled_std = np.sqrt( ( (group1_n - 1) * group1_std**2 + (group2_n - 1) * group2_std**2 ) /
                          ( group1_n + group2_n - 2 )
                        )
    
    ind_t = ( group1_mean - group2_mean ) / \
            ( pooled_std * math.sqrt( 1/group1_n + 1/group2_n ) )
    ind_t[np.isnan(ind_t)] = 0.0

    return ind_t

def bin_pos_neg(mat,thresh):
    mat_pos_bin = np.where(mat>thresh,1,0)
    mat_neg_bin = np.where(mat<-1*thresh,1,0)
    mat_bin = mat_pos_bin + mat_neg_bin

    return mat_bin

def thresh_pos_neg(mat,thresh):
    mat_thresh = np.zeros_like(mat)
    mat_thresh[np.where(mat>thresh)] = np.copy(mat[np.where(mat>thresh)])
    mat_thresh[np.where(mat<-1*thresh)] = np.copy(mat[np.where(mat<-1*thresh)])

    return mat_thresh

def nbs(group1_mat,group2_mat,t_thresh,perms=5000):
    ind_t = ind_t_2d(group1_mat,group2_mat)
    ind_t_bin = bin_pos_neg(ind_t,t_thresh)
    ind_t_thresh = thresh_pos_neg(ind_t,t_thresh)

    ind_t_G = nx.from_numpy_matrix(ind_t_bin)
    subgraphs = list(nx.connected_components(ind_t_G))
    print(subgraphs)
    subgraph_sizes = [len(sg) for sg in subgraphs]
    largest_subgraph_idx = np.argmax(subgraph_sizes)
    print(largest_subgraph_idx)
    largest_subgraph_size = len(subgraphs[largest_subgraph_idx])

    # set connections to nodes not within largest subgraph to 0 to isolate subgraph for returning
    largest_subgraph_nodes = list(subgraphs[largest_subgraph_idx])
    largest_subgraph_not_nodes_idx = [False if n in largest_subgraph_nodes else True for n in range(regions_n)]
    largest_subgraph_ind_t_mat = np.copy(ind_t_thresh)
    largest_subgraph_ind_t_mat[largest_subgraph_not_nodes_idx,:] = 0.0
    largest_subgraph_ind_t_mat[:,largest_subgraph_not_nodes_idx] = 0.0

    group1_n = group1_mat.shape[0]
    group2_n = group2_mat.shape[0]
    group_membership = np.zeros((group1_n+group2_n))
    group_membership[:group1_n] = 1

    group_shuffled = np.copy(group_membership).astype(bool)
    concat_mats = np.concatenate([group1_mat,group2_mat],axis=0)

    largest_shuf_subgraph_sizes = []
    for _ in range(perms):
        np.random.shuffle(group_shuffled)
        #keep shuffling if same group assignment as true data
        while (group_shuffled == group_membership).all():
            np.random.shuffle(group_shuffled)
        group1_shuf = concat_mats[group_shuffled,:,:]
        group2_shuf = concat_mats[~group_shuffled,:,:]

        ind_t_shuf = ind_t_2d(group1_shuf,group2_shuf)
        ind_t_shuf_bin = bin_pos_neg(ind_t_shuf,t_thresh)

        ind_t_shuf_G = nx.from_numpy_matrix(ind_t_shuf_bin)

        subgraphs_shuf = list(nx.connected_components(ind_t_shuf_G))
        subgraph_shuf_sizes = [len(sg) for sg in subgraphs_shuf]
        largest_subgraph_shuf_idx = np.argmax(subgraph_shuf_sizes)
        largest_subgraph_shuf_size = len(list(nx.connected_components(ind_t_shuf_G))[largest_subgraph_shuf_idx])

        largest_shuf_subgraph_sizes.append(largest_subgraph_shuf_size)

    sorted_largest_shuf_subgraph_sizes = np.sort(np.array(largest_shuf_subgraph_sizes))

    # p = proportion of rand values as large or larger than empirical value
    p = (perms - bisect_left(sorted_largest_shuf_subgraph_sizes,largest_subgraph_size)) / perms
    print("p =",p)

    return largest_subgraph_ind_t_mat, p

#%%
def save_BNV_node(output_file,degree_array,friendly_names_file):
    bn_node = pd.read_csv(friendly_names_file,names=['x','y','z','colour','size','label'],sep='\t')
    #mask = ~np.isnan(degree_array)
    #bn_node.loc[mask,'size'] = 2
    bn_node['size'] = degree_array
    bn_node['label'] = bn_node['label'].str.replace('_','-')
    bn_node.to_csv(output_file,sep='\t',header=False, index=False)

def save_BNV_edge(matrix,output_path):
    np.savetxt(output_path, matrix, delimiter='\t', fmt='%f')

#%% NBS t 2.7
t_thresh = 2.7
# t=2.7 corresponds to p=.01 for df=40
#%% I flip the sign of the connections when making figures so that it instead represents old - young for consistency with PLS analyses
component, p = nbs(young_FC_sleep_diff, old_FC_sleep_diff,t_thresh,5000) #sig

#%%
component_bin = bin_pos_neg(component,thresh=t_thresh)
component_degree = np.sum(component_bin,axis=0)
#%%
save_BNV_node(NBS_BNV_NODE_OUTPUT_FILE,component_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(component,NBS_BNV_EDGE_OUTPUT_FILE)

#%%
#saving positive and negative components separately for visualization.
#note also that I will color the BNV figures in reverse to show neg as pos and pos as neg
#in order to effectively switch the sign of the t values. This will produce an NBS comparing
#old - young, in order to be consistant with PLS interaction
component = np.genfromtxt(NBS_BNV_EDGE_OUTPUT_FILE,delimiter='\t')
component_neg = np.zeros_like(component)
component_neg[np.where(component<-1*t_thresh)] = component[np.where(component<-1*t_thresh)]
component_pos = np.zeros_like(component)
component_pos[np.where(component>t_thresh)] = component[np.where(component>t_thresh)]
save_BNV_edge(component_neg,NBS_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_OUTPUT_FILE.stem}_neg{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))
save_BNV_edge(component_pos,NBS_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_OUTPUT_FILE.stem}_pos{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))

component_bin = bin_pos_neg(component,thresh=t_thresh)
component_total_n = np.sum(component_bin) / 2
component_lh_n = np.sum(component_bin[:110,:110]) / 2
component_rh_n = np.sum(component_bin[110:,110:]) / 2
component_xh_n = component_total_n - component_lh_n - component_rh_n
print('NBS connections',component_total_n)
print('NBS LH',component_lh_n,component_lh_n/component_total_n * 100,'%')
print('NBS RH',component_rh_n,component_rh_n/component_total_n * 100,'%')
print('NBS interhemi',component_xh_n,component_xh_n/component_total_n * 100,'%')

component_G = nx.from_numpy_matrix(component_bin)
subgraphs = list(nx.connected_components(component_G))
subgraph_sizes = [len(sg) for sg in subgraphs]
print('component size:',np.max(subgraph_sizes))

print('positive (neg in figure) connections:',np.where(component_pos>t_thresh)[0].shape[0] / 2)
print('negative (pos in figure) connections:',np.where(component_neg<-1*t_thresh)[0].shape[0] / 2)

print('sig node degree thresh',np.mean(component_degree) + 2.5*np.std(component_degree))

#%% NBS t 2.5
t_thresh = 2.5
#%% I flip the sign of the connections when making figures so that it instead represents old - young for consistency with PLS analyses
component, p = nbs(young_FC_sleep_diff, old_FC_sleep_diff,t_thresh,5000) #sig

#%%
component_bin = bin_pos_neg(component,thresh=t_thresh)
component_degree = np.sum(component_bin,axis=0)
#%%
save_BNV_node(NBS_BNV_NODE_T2_5_OUTPUT_FILE,component_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(component,NBS_BNV_EDGE_T2_5_OUTPUT_FILE)

#%%
#saving positive and negative components separately for visualization.
#note also that I will color the BNV figures in reverse to show neg as pos and pos as neg
#in order to effectively switch the sign of the t values. This will produce an NBS comparing
#old - young, in order to be consistant with PLS interaction
component = np.genfromtxt(NBS_BNV_EDGE_T2_5_OUTPUT_FILE,delimiter='\t')
component_neg = np.zeros_like(component)
component_neg[np.where(component<-1*t_thresh)] = component[np.where(component<-1*t_thresh)]
component_pos = np.zeros_like(component)
component_pos[np.where(component>t_thresh)] = component[np.where(component>t_thresh)]
save_BNV_edge(component_neg,NBS_BNV_EDGE_T2_5_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_T2_5_OUTPUT_FILE.stem}_neg{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))
save_BNV_edge(component_pos,NBS_BNV_EDGE_T2_5_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_T2_5_OUTPUT_FILE.stem}_pos{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))

component_bin = bin_pos_neg(component,thresh=t_thresh)
component_total_n = np.sum(component_bin) / 2
component_lh_n = np.sum(component_bin[:110,:110]) / 2
component_rh_n = np.sum(component_bin[110:,110:]) / 2
component_xh_n = component_total_n - component_lh_n - component_rh_n
print('NBS connections',component_total_n)
print('NBS LH',component_lh_n,component_lh_n/component_total_n * 100,'%')
print('NBS RH',component_rh_n,component_rh_n/component_total_n * 100,'%')
print('NBS interhemi',component_xh_n,component_xh_n/component_total_n * 100,'%')

component_G = nx.from_numpy_matrix(component_bin)
subgraphs = list(nx.connected_components(component_G))
subgraph_sizes = [len(sg) for sg in subgraphs]
print('component size:',np.max(subgraph_sizes))

print('positive (neg in figure) connections:',np.where(component_pos>t_thresh)[0].shape[0] / 2)
print('negative (pos in figure) connections:',np.where(component_neg<-1*t_thresh)[0].shape[0] / 2)

print('sig node degree thresh',np.mean(component_degree) + 2.5*np.std(component_degree))

#%% NBS t 2.9
t_thresh = 2.9
#%% I flip the sign of the connections when making figures so that it instead represents old - young for consistency with PLS analyses
component, p = nbs(young_FC_sleep_diff, old_FC_sleep_diff,t_thresh,5000) #sig

#%%
component_bin = bin_pos_neg(component,thresh=t_thresh)
component_degree = np.sum(component_bin,axis=0)
#%%
save_BNV_node(NBS_BNV_NODE_T2_9_OUTPUT_FILE,component_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(component,NBS_BNV_EDGE_T2_9_OUTPUT_FILE)

#%%
#saving positive and negative components separately for visualization.
#note also that I will color the BNV figures in reverse to show neg as pos and pos as neg
#in order to effectively switch the sign of the t values. This will produce an NBS comparing
#old - young, in order to be consistant with PLS interaction
component = np.genfromtxt(NBS_BNV_EDGE_T2_9_OUTPUT_FILE,delimiter='\t')
component_neg = np.zeros_like(component)
component_neg[np.where(component<-1*t_thresh)] = component[np.where(component<-1*t_thresh)]
component_pos = np.zeros_like(component)
component_pos[np.where(component>t_thresh)] = component[np.where(component>t_thresh)]
save_BNV_edge(component_neg,NBS_BNV_EDGE_T2_9_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_T2_9_OUTPUT_FILE.stem}_neg{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))
save_BNV_edge(component_pos,NBS_BNV_EDGE_T2_9_OUTPUT_FILE.parent.joinpath(f'{NBS_BNV_EDGE_T2_9_OUTPUT_FILE.stem}_pos{NBS_BNV_EDGE_OUTPUT_FILE.suffix}'))

component_bin = bin_pos_neg(component,thresh=t_thresh)
component_total_n = np.sum(component_bin) / 2
component_lh_n = np.sum(component_bin[:110,:110]) / 2
component_rh_n = np.sum(component_bin[110:,110:]) / 2
component_xh_n = component_total_n - component_lh_n - component_rh_n
print('NBS connections',component_total_n)
print('NBS LH',component_lh_n,component_lh_n/component_total_n * 100,'%')
print('NBS RH',component_rh_n,component_rh_n/component_total_n * 100,'%')
print('NBS interhemi',component_xh_n,component_xh_n/component_total_n * 100,'%')

component_G = nx.from_numpy_matrix(component_bin)
subgraphs = list(nx.connected_components(component_G))
subgraph_sizes = [len(sg) for sg in subgraphs]
print('component size:',np.max(subgraph_sizes))

print('positive (neg in figure) connections:',np.where(component_pos>t_thresh)[0].shape[0] / 2)
print('negative (pos in figure) connections:',np.where(component_neg<-1*t_thresh)[0].shape[0] / 2)

print('sig node degree thresh',np.mean(component_degree) + 2.5*np.std(component_degree))

#%% global signal variability
timepoints_n = FC_timeseries_deprived_sleep_dict[subjects[0]].shape[1]

old_FC_timeseries_deprived_sleep = np.zeros((len(old_subjects),regions_n,timepoints_n))
old_FC_timeseries_normal_sleep = np.zeros((len(old_subjects),regions_n,timepoints_n))
for i,s in enumerate(old_subjects):
    old_FC_timeseries_deprived_sleep[i,:,:] = FC_timeseries_deprived_sleep_dict[s]
    old_FC_timeseries_normal_sleep[i,:,:] = FC_timeseries_normal_sleep_dict[s]

young_FC_timeseries_deprived_sleep = np.zeros((len(young_subjects),regions_n,timepoints_n))
young_FC_timeseries_normal_sleep = np.zeros((len(young_subjects),regions_n,timepoints_n))
for i,s in enumerate(young_subjects):
    young_FC_timeseries_deprived_sleep[i,:,:] = FC_timeseries_deprived_sleep_dict[s]
    young_FC_timeseries_normal_sleep[i,:,:] = FC_timeseries_normal_sleep_dict[s]

old_FC_timeseries_deprived_sleep_GM_std = np.std(old_FC_timeseries_deprived_sleep,axis=1)
old_FC_timeseries_normal_sleep_GM_std = np.std(old_FC_timeseries_normal_sleep,axis=1)
young_FC_timeseries_deprived_sleep_GM_std = np.std(young_FC_timeseries_deprived_sleep,axis=1)
young_FC_timeseries_normal_sleep_GM_std = np.std(young_FC_timeseries_normal_sleep,axis=1)

old_FC_timeseries_deprived_sleep_GM_std_mean = np.mean(old_FC_timeseries_deprived_sleep_GM_std,axis=1)
old_FC_timeseries_normal_sleep_GM_std_mean = np.mean(old_FC_timeseries_normal_sleep_GM_std,axis=1)
young_FC_timeseries_deprived_sleep_GM_std_mean = np.mean(young_FC_timeseries_deprived_sleep_GM_std,axis=1)
young_FC_timeseries_normal_sleep_GM_std_mean = np.mean(young_FC_timeseries_normal_sleep_GM_std,axis=1)

old_FC_timeseries_deprived_sleep_GM_std_group_mean = np.mean(old_FC_timeseries_deprived_sleep_GM_std_mean)
old_FC_timeseries_normal_sleep_GM_std_group_mean = np.mean(old_FC_timeseries_normal_sleep_GM_std_mean)
young_FC_timeseries_deprived_sleep_GM_std_group_mean = np.mean(young_FC_timeseries_deprived_sleep_GM_std_mean)
young_FC_timeseries_normal_sleep_GM_std_group_mean = np.mean(young_FC_timeseries_normal_sleep_GM_std_mean)

#%% matlab FC BSR inspection
pls_fig_thresh = 2.7
FC_bsr_flat = np.genfromtxt(PLS_FC_BSR_FILE)
FC_bsr = graphs.flat_to_square_matrix(FC_bsr_flat)
FC_bsr_bin = bin_pos_neg(FC_bsr,pls_fig_thresh)
FC_bsr_degree = np.sum(FC_bsr_bin,axis=0)
print('2.5 SD + mean = ',np.mean(FC_bsr_degree) + 2.5*np.std(FC_bsr_degree))

FC_bsr_thresh_pos = np.zeros_like(FC_bsr)
FC_bsr_thresh_pos[np.where(FC_bsr>pls_fig_thresh)] = FC_bsr[np.where(FC_bsr>pls_fig_thresh)]
print("num positive edges",np.sum(FC_bsr_thresh_pos > 0) / 2)
FC_bsr_thresh_neg = np.zeros_like(FC_bsr)
FC_bsr_thresh_neg[np.where(FC_bsr<-1*pls_fig_thresh)] = FC_bsr[np.where(FC_bsr<-1*pls_fig_thresh)]
print("num negative edges",np.sum(FC_bsr_thresh_neg < 0) / 2)

pls_bnv_node_output_file_thr = PLS_BNV_NODE_OUTPUT_FILE.parent.joinpath(f'{PLS_BNV_NODE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}{PLS_BNV_NODE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_neg = PLS_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_neg{PLS_BNV_EDGE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_pos = PLS_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_pos{PLS_BNV_EDGE_OUTPUT_FILE.suffix}')

#%%
save_BNV_node(pls_bnv_node_output_file_thr,FC_bsr_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(FC_bsr_thresh_pos,pls_bnv_edge_output_file_thr_pos)
save_BNV_edge(FC_bsr_thresh_neg,pls_bnv_edge_output_file_thr_neg)

#%% hemispheric connection counts
bsr_total_n = np.sum(FC_bsr_bin) / 2
bsr_lh_n = np.sum(FC_bsr_bin[:110,:110]) / 2
bsr_rh_n = np.sum(FC_bsr_bin[110:,110:]) / 2
bsr_xh_n = bsr_total_n - bsr_lh_n - bsr_rh_n
print('PLS connections',bsr_total_n)
print('PLS LH',bsr_lh_n,bsr_lh_n/bsr_total_n * 100,'%')
print('PLS RH',bsr_rh_n,bsr_rh_n/bsr_total_n * 100,'%')
print('PLS interhemi',bsr_xh_n,bsr_xh_n/bsr_total_n * 100,'%')

#%% mean sleep difference effects for connections identified by PLS sig BSRs
#   this will aid interpretting PLS interaction
FC_bsr_sig_pos_idx = np.where(FC_bsr_thresh_pos > 0)
FC_bsr_sig_neg_idx = np.where(FC_bsr_thresh_neg < 0)

old_FC_sleep_diff_mean = np.mean(old_FC_sleep_diff,axis=0)
old_FC_sleep_diff_bsr_sig_pos = np.zeros_like(old_FC_sleep_diff_mean)
old_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] = old_FC_sleep_diff_mean[FC_bsr_sig_pos_idx]
old_FC_sleep_diff_bsr_sig_neg = np.zeros_like(old_FC_sleep_diff_mean)
old_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] = old_FC_sleep_diff_mean[FC_bsr_sig_neg_idx]

young_FC_sleep_diff_mean = np.mean(young_FC_sleep_diff,axis=0)
young_FC_sleep_diff_bsr_sig_pos = np.zeros_like(young_FC_sleep_diff_mean)
young_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] = young_FC_sleep_diff_mean[FC_bsr_sig_pos_idx]
young_FC_sleep_diff_bsr_sig_neg = np.zeros_like(young_FC_sleep_diff_mean)
young_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] = young_FC_sleep_diff_mean[FC_bsr_sig_neg_idx]

print('old FC sleep diff from sig pos bsr that are negative:',np.where(old_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] < 0)[0].shape[0] / 2)
print('old FC sleep diff from sig pos bsr that are positive:',np.where(old_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] > 0)[0].shape[0] / 2)
print('old FC sleep diff from sig neg bsr that are negative:',np.where(old_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] < 0)[0].shape[0] / 2)
print('old FC sleep diff from sig neg bsr that are positive:',np.where(old_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] > 0)[0].shape[0] / 2)

print('young FC sleep diff from sig pos bsr that are negative:',np.where(young_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] < 0)[0].shape[0] / 2)
print('young FC sleep diff from sig pos bsr that are positive:',np.where(young_FC_sleep_diff_bsr_sig_pos[FC_bsr_sig_pos_idx] > 0)[0].shape[0] / 2)
print('young FC sleep diff from sig neg bsr that are negative:',np.where(young_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] < 0)[0].shape[0] / 2)
print('young FC sleep diff from sig neg bsr that are positive:',np.where(young_FC_sleep_diff_bsr_sig_neg[FC_bsr_sig_neg_idx] > 0)[0].shape[0] / 2)

#isolating for YA the sleep diff in FC where the PLS bsr was sig positive and the raw sleep diff for YA is also positive (like the OA, but less strongly)
young_FC_sleep_diff_pos_sig_bsr_young_pos = young_FC_sleep_diff_bsr_sig_pos[np.where(young_FC_sleep_diff_bsr_sig_pos > 0)]
#isolating for OA the sleep diff in FC where the PLS bsr was sig positive and the raw sleep diff for YA is also positive (should be more strongly pos than for YA)
old_FC_sleep_diff_pos_sig_bsr_young_pos = old_FC_sleep_diff_bsr_sig_pos[np.where(young_FC_sleep_diff_bsr_sig_pos > 0)]
print("YA sleep diff from sig pos bsr that are positive but less so than OA:",np.where((old_FC_sleep_diff_pos_sig_bsr_young_pos - young_FC_sleep_diff_pos_sig_bsr_young_pos) > 0)[0].shape[0] / 2)

#isolating for YA the sleep diff in FC where the PLS bsr was sig negative and the raw sleep diff for YA is also negative (like the OA, but less strongly)
young_FC_sleep_diff_neg_sig_bsr_young_neg = young_FC_sleep_diff_bsr_sig_neg[np.where(young_FC_sleep_diff_bsr_sig_neg < 0)]
#isolating for OA the sleep diff in FC where the PLS bsr was sig negative and the raw sleep diff for YA is also negative (should be more strongly neg than for YA)
old_FC_sleep_diff_neg_sig_bsr_young_neg = old_FC_sleep_diff_bsr_sig_neg[np.where(young_FC_sleep_diff_bsr_sig_neg < 0)]
print("YA sleep diff from sig neg bsr that are negative but less so than OA:",np.where((old_FC_sleep_diff_neg_sig_bsr_young_neg - young_FC_sleep_diff_neg_sig_bsr_young_neg) < 0)[0].shape[0] / 2)

young_FC_sleep_diff_bsr_sig_pos_for_fig = np.zeros_like(young_FC_sleep_diff_bsr_sig_pos)
young_FC_sleep_diff_bsr_sig_pos_for_fig[np.where(young_FC_sleep_diff_bsr_sig_pos > 0)] = 2 # 2 for positive diff
young_FC_sleep_diff_bsr_sig_pos_for_fig[np.where(young_FC_sleep_diff_bsr_sig_pos < 0)] = 1 # 1 for negative diff

young_FC_sleep_diff_bsr_sig_neg_for_fig = np.zeros_like(young_FC_sleep_diff_bsr_sig_neg)
young_FC_sleep_diff_bsr_sig_neg_for_fig[np.where(young_FC_sleep_diff_bsr_sig_neg > 0)] = 2 # 2 for positive diff
young_FC_sleep_diff_bsr_sig_neg_for_fig[np.where(young_FC_sleep_diff_bsr_sig_neg < 0)] = 1 # 1 for negative diff

save_BNV_edge(young_FC_sleep_diff_bsr_sig_pos_for_fig,PLS_YOUNG_SLEEP_DIFF_POS_BSR_BNV_EDGE_OUTPUT_FILE)
save_BNV_edge(young_FC_sleep_diff_bsr_sig_neg_for_fig,PLS_YOUNG_SLEEP_DIFF_NEG_BSR_BNV_EDGE_OUTPUT_FILE)

#%% matlab FC sex BSR inspection
pls_fig_thresh = 2.7
FC_sex_bsr_flat = np.genfromtxt(PLS_FC_SEX_BSR_FILE)
FC_sex_bsr = graphs.flat_to_square_matrix(FC_sex_bsr_flat)
FC_sex_bsr_bin = bin_pos_neg(FC_sex_bsr,pls_fig_thresh)
FC_sex_bsr_degree = np.sum(FC_sex_bsr_bin,axis=0)
print('2.5 SD + mean = ',np.mean(FC_sex_bsr_degree) + 2.5*np.std(FC_sex_bsr_degree))

FC_sex_bsr_thresh_pos = np.zeros_like(FC_sex_bsr)
FC_sex_bsr_thresh_pos[np.where(FC_sex_bsr>pls_fig_thresh)] = FC_sex_bsr[np.where(FC_sex_bsr>pls_fig_thresh)]
print("num positive edges",np.sum(FC_sex_bsr_thresh_pos > 0) / 2)
FC_sex_bsr_thresh_neg = np.zeros_like(FC_sex_bsr)
FC_sex_bsr_thresh_neg[np.where(FC_sex_bsr<-1*pls_fig_thresh)] = FC_sex_bsr[np.where(FC_sex_bsr<-1*pls_fig_thresh)]
print("num negative edges",np.sum(FC_sex_bsr_thresh_neg < 0) / 2)

pls_bnv_node_output_file_thr = PLS_SEX_BNV_NODE_OUTPUT_FILE.parent.joinpath(f'{PLS_SEX_BNV_NODE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}{PLS_SEX_BNV_NODE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_neg = PLS_SEX_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_SEX_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_neg{PLS_SEX_BNV_EDGE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_pos = PLS_SEX_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_SEX_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_pos{PLS_SEX_BNV_EDGE_OUTPUT_FILE.suffix}')

#%%
save_BNV_node(pls_bnv_node_output_file_thr,FC_sex_bsr_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(FC_sex_bsr_thresh_pos,pls_bnv_edge_output_file_thr_pos)
save_BNV_edge(FC_sex_bsr_thresh_neg,pls_bnv_edge_output_file_thr_neg)

#%% hemispheric connection counts
bsr_total_n = np.sum(FC_sex_bsr_bin) / 2
bsr_lh_n = np.sum(FC_sex_bsr_bin[:110,:110]) / 2
bsr_rh_n = np.sum(FC_sex_bsr_bin[110:,110:]) / 2
bsr_xh_n = bsr_total_n - bsr_lh_n - bsr_rh_n
print('PLS connections',bsr_total_n)
print('PLS LH',bsr_lh_n,bsr_lh_n/bsr_total_n * 100,'%')
print('PLS RH',bsr_rh_n,bsr_rh_n/bsr_total_n * 100,'%')
print('PLS interhemi',bsr_xh_n,bsr_xh_n/bsr_total_n * 100,'%')

#%% matlab FC BSR inspection (OA sleep comparison)
pls_fig_thresh = 2.7
FC_bsr_flat = np.genfromtxt(PLS_FC_OLD_DEPRIVED_VS_NORMAL_BSR_FILE)
FC_bsr = graphs.flat_to_square_matrix(FC_bsr_flat)
FC_bsr_bin = bin_pos_neg(FC_bsr,pls_fig_thresh)
FC_bsr_degree = np.sum(FC_bsr_bin,axis=0)
print('2.5 SD + mean = ',np.mean(FC_bsr_degree) + 2.5*np.std(FC_bsr_degree))

FC_bsr_thresh_pos = np.zeros_like(FC_bsr)
FC_bsr_thresh_pos[np.where(FC_bsr>pls_fig_thresh)] = FC_bsr[np.where(FC_bsr>pls_fig_thresh)]
print("num positive edges",np.sum(FC_bsr_thresh_pos > 0) / 2)
FC_bsr_thresh_neg = np.zeros_like(FC_bsr)
FC_bsr_thresh_neg[np.where(FC_bsr<-1*pls_fig_thresh)] = FC_bsr[np.where(FC_bsr<-1*pls_fig_thresh)]
print("num negative edges",np.sum(FC_bsr_thresh_neg < 0) / 2)

pls_bnv_node_output_file_thr = PLS_OLD_DEPRIVED_VS_NORMAL_BNV_NODE_OUTPUT_FILE.parent.joinpath(f'{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_NODE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_NODE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_neg = PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_neg{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.suffix}')
pls_bnv_edge_output_file_thr_pos = PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.parent.joinpath(f'{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.stem}_thr{pls_fig_thresh}_pos{PLS_OLD_DEPRIVED_VS_NORMAL_BNV_EDGE_OUTPUT_FILE.suffix}')

#%%
save_BNV_node(pls_bnv_node_output_file_thr,FC_bsr_degree,ATLAS_FRIENDLY_NAMES_FILE)
save_BNV_edge(FC_bsr_thresh_pos,pls_bnv_edge_output_file_thr_pos)
save_BNV_edge(FC_bsr_thresh_neg,pls_bnv_edge_output_file_thr_neg)

#%%
bsr_total_n = np.sum(FC_bsr_bin) / 2
bsr_lh_n = np.sum(FC_bsr_bin[:110,:110]) / 2
bsr_rh_n = np.sum(FC_bsr_bin[110:,110:]) / 2
bsr_xh_n = bsr_total_n - bsr_lh_n - bsr_rh_n
print('PLS connections',bsr_total_n)
print('PLS LH',bsr_lh_n,bsr_lh_n/bsr_total_n * 100,'%')
print('PLS RH',bsr_rh_n,bsr_rh_n/bsr_total_n * 100,'%')
print('PLS interhemi',bsr_xh_n,bsr_xh_n/bsr_total_n * 100,'%')

#%% matlab FC degree BSR inspection
FC_degree_bsr = np.genfromtxt(PLS_FC_DEGREE_BSR_FILE)
visualization.vis_cortex(FC_degree_bsr,PLS_FC_DEGREE_BSR_CORTEX_FIG_FILE,2.0,atlas_name='ST220',rscript=RSCRIPT)
visualization.vis_subcortical(FC_degree_bsr,PLS_FC_DEGREE_BSR_SUBCORTEX_FIG_FILE,2.0,atlas_name='ST220')

#%%
FC_degree_bsr_nothresh = np.genfromtxt(PLS_FC_DEGREE_BSR_NOTHRESH_FILE)
sa_axis_data = np.genfromtxt(SA_AXIS_FILE,delimiter=',',skip_header=1,usecols=[1])
sa_axis_data -= int(np.mean(sa_axis_data))
sa_axis_data_padded = np.zeros_like(FC_degree_bsr_nothresh)
sa_axis_data_padded[:100] = sa_axis_data[:100]
sa_axis_data_padded[110:210] = sa_axis_data[100:]
visualization.vis_cortex(sa_axis_data_padded,SA_AXIS_FIG_FILE,0.0,atlas_name='ST220',rscript=RSCRIPT)

#%%
FC_degree_bsr_cortex = np.zeros_like(sa_axis_data)
FC_degree_bsr_cortex[:100] = FC_degree_bsr_nothresh[:100]
FC_degree_bsr_cortex[100:] = FC_degree_bsr_nothresh[110:210]
print(stats.pearsonr(FC_degree_bsr_cortex,sa_axis_data))

#%%
with open(FC_DEGREE_DEPRIVED_SLEEP_DICT_FILE,'rb') as f:
    FC_degree_deprived_sleep_dict = pickle.load(f)
with open(FC_DEGREE_NORMAL_SLEEP_DICT_FILE,'rb') as f:
    FC_degree_normal_sleep_dict = pickle.load(f)

old_FC_degree_deprived_sleep = np.zeros((len(old_subjects),regions_n))
old_FC_degree_normal_sleep = np.zeros((len(old_subjects),regions_n))
young_FC_degree_deprived_sleep = np.zeros((len(young_subjects),regions_n))
young_FC_degree_normal_sleep = np.zeros((len(young_subjects),regions_n))
for i,s in enumerate(old_subjects):
    old_FC_degree_deprived_sleep[i,:] = FC_degree_deprived_sleep_dict[s]
    old_FC_degree_normal_sleep[i,:] = FC_degree_normal_sleep_dict[s]
for i,s in enumerate(young_subjects):
    young_FC_degree_deprived_sleep[i,:] = FC_degree_deprived_sleep_dict[s]
    young_FC_degree_normal_sleep[i,:] = FC_degree_normal_sleep_dict[s]

old_FC_degree_deprived_mean = np.mean(old_FC_degree_deprived_sleep)
old_FC_degree_normal_mean = np.mean(old_FC_degree_normal_sleep)
young_FC_degree_deprived_mean = np.mean(young_FC_degree_deprived_sleep)
young_FC_degree_normal_mean = np.mean(young_FC_degree_normal_sleep)

old_FC_degree_deprived_std = np.std(old_FC_degree_deprived_sleep)
old_FC_degree_normal_std = np.std(old_FC_degree_normal_sleep)
young_FC_degree_deprived_std = np.std(young_FC_degree_deprived_sleep)
young_FC_degree_normal_std = np.std(young_FC_degree_normal_sleep)

#%%
FC_degree_bsr_sig_idx = np.where(FC_degree_bsr < -2.0)
young_FC_degree_sleep_diff = young_FC_degree_deprived_sleep - young_FC_degree_normal_sleep
old_FC_degree_sleep_diff = old_FC_degree_deprived_sleep - old_FC_degree_normal_sleep
young_FC_degree_sleep_diff_mean = np.mean(young_FC_degree_sleep_diff,axis=0)
old_FC_degree_sleep_diff_mean = np.mean(old_FC_degree_sleep_diff,axis=0)
young_FC_degree_sleep_diff_mean_sig = np.zeros_like(young_FC_degree_sleep_diff_mean)
young_FC_degree_sleep_diff_mean_sig[FC_degree_bsr_sig_idx] = young_FC_degree_sleep_diff_mean[FC_degree_bsr_sig_idx]
old_FC_degree_sleep_diff_mean_sig = np.zeros_like(old_FC_degree_sleep_diff_mean)
old_FC_degree_sleep_diff_mean_sig[FC_degree_bsr_sig_idx] = old_FC_degree_sleep_diff_mean[FC_degree_bsr_sig_idx]
visualization.vis_cortex(young_FC_degree_sleep_diff_mean_sig,PLS_FC_DEGREE_YOUNG_SLEEP_DIFF_SIG_BSR_CORTEX_FIG_FILE,0.001,atlas_name='ST220',rscript=RSCRIPT)
visualization.vis_subcortical(young_FC_degree_sleep_diff_mean_sig,PLS_FC_DEGREE_YOUNG_SLEEP_DIFF_SIG_BSR_SUBCORTEX_FIG_FILE,0.001,atlas_name='ST220')
visualization.vis_cortex(old_FC_degree_sleep_diff_mean_sig,PLS_FC_DEGREE_OLD_SLEEP_DIFF_SIG_BSR_CORTEX_FIG_FILE,0.001,atlas_name='ST220',rscript=RSCRIPT)
visualization.vis_subcortical(old_FC_degree_sleep_diff_mean_sig,PLS_FC_DEGREE_OLD_SLEEP_DIFF_SIG_BSR_SUBCORTEX_FIG_FILE,0.001,atlas_name='ST220')

print(np.where(young_FC_degree_sleep_diff_mean_sig < 0))

#%% FC degree PLS old deprived vs normal sleep
FC_degree_deprived_sleep_bsr = np.genfromtxt(PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_FILE)
visualization.vis_cortex(FC_degree_deprived_sleep_bsr,PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_CORTEX_FIG_FILE,2.0,atlas_name='ST220',rscript=RSCRIPT)
visualization.vis_subcortical(FC_degree_deprived_sleep_bsr,PLS_FC_DEGREE_OLD_DEPRIVED_VS_NORMAL_SLEEP_BSR_SUBCORTEX_FIG_FILE,2.0,atlas_name='ST220')

#%% matlab FC degree BSR inspection sex
FC_degree_bsr = np.genfromtxt(PLS_FC_DEGREE_SEX_BSR_FILE) * -1 #flipping sign to be consistent with other analyses (Brain Score plot flipped in matlab)
visualization.vis_cortex(FC_degree_bsr,PLS_FC_DEGREE_SEX_BSR_CORTEX_FIG_FILE,2.0,atlas_name='ST220',rscript=RSCRIPT)
visualization.vis_subcortical(FC_degree_bsr,PLS_FC_DEGREE_SEX_BSR_SUBCORTEX_FIG_FILE,2.0,atlas_name='ST220')

#%% LEiDA Analysis
K = 5

GLO_colour_hex = "409832"
DMN_colour_hex = "d9717d"
ATN_colour_hex = "a251ac"
FPN_colour_hex = "efb943"
SM_colour_hex = "789ac0"

K5_colours_hex = [  GLO_colour_hex,
                    DMN_colour_hex,
                    FPN_colour_hex,
                    SM_colour_hex,
                    ATN_colour_hex
                    ]

K5_colours_rgb = [to_rgb('#' + colour) for colour in K5_colours_hex]

#%% Saves state activation maps as figure
clusters_mat = sio.loadmat(LEIDA_CLUSTERS_FILE, simplify_cells=True)
LEiDA_centroids_dir = LEIDA_OUTPUTS_DIR.joinpath(f'K{K}')
LEiDA_centroids_dir.mkdir(exist_ok=True)
k_idx = K - 2
cluster_centroid_roi_values = clusters_mat['Kmeans_results'][k_idx]['C']
cluster_centroid_roi_values[0] *= -1
cluster_centroid_roi_values_pos_bin = np.where(cluster_centroid_roi_values>0, 1.0, 0.0)
for state in range(K):
    np.savetxt(LEiDA_centroids_dir.joinpath(f'{state+1}_of_{K}_cluster_centroid_roi_values.csv'),
                cluster_centroid_roi_values[state],delimiter=',')

    visualization.vis_cortex(cluster_centroid_roi_values_pos_bin[state],
                                    LEiDA_centroids_dir.joinpath(f'{state+1}_of_{K}_cluster_centroid_roi_values_pos_bin_cortex.png'),
                                    thresh=0.0,
                                    pos_colour=K5_colours_hex[state],
                                    bg_colour='transparent',
                                    atlas_name='ST220',
                                    rscript=RSCRIPT
                                    )
    visualization.vis_subcortical(cluster_centroid_roi_values_pos_bin[state],
                                    LEiDA_centroids_dir.joinpath(f'{state+1}_of_{K}_cluster_centroid_roi_values_pos_bin_subcortex.png'),
                                    thresh=0.001,
                                    pos_colours=[(0,0,0),K5_colours_rgb[state]],
                                    save_cmap=True,
                                    atlas_name='ST220')
    
#%% global signal variability
#%%
GM_sig_var_df = pd.read_csv(GM_SIG_VAR_FILE)
GM_sig_var_df['log_var'] = np.log(GM_sig_var_df['GM_sig_variability'])

#%%
model = ols('GM_sig_variability ~ C(age) + C(sleep) + C(age):C(sleep)', data=GM_sig_var_df).fit()
sm.stats.anova_lm(model,typ=2)

#%%
model = ols('log_var ~ C(age) + C(sleep) + C(age):C(sleep)', data=GM_sig_var_df).fit()
sm.stats.anova_lm(model,typ=2)

#%%
sns.barplot(x='age',y='log_var',data=GM_sig_var_df,hue='sleep')
plt.ylim([2.8,3.6])

#%%need to try also controlling for IDP MCFLIRT_rel_disp_mean_rfMRI_0.ica and MCFLIRT_rel_disp_mean_rfMRI_1.ica
#and try with lme4 mixed-effects in R
#%%MDMR
with open(GM_IDX_FILE,'rb') as f:
    GM_idx = pickle.load(f)
with open(EPI_AFFINE_FILE,'rb') as f:
    epi_affine = pickle.load(f)

perms = 15000
cluster_perms = 500
pthresh = .05

#%% load voxelwise connectivity in memory map mode (each is 2.4GB)
young_old_subjects_deprived_sleep_voxelwise_FC_dict = {}
young_old_subjects_normal_sleep_voxelwise_FC_dict = {}

subjects_young_old = young_subjects + old_subjects

for sub in subjects_young_old:
    young_old_subjects_deprived_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_deprived_sleep_sub-{sub}.npy'),mmap_mode='r')
    young_old_subjects_normal_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_normal_sleep_sub-{sub}.npy'),mmap_mode='r')

#%% intersubject distance matrix function
def distance_matrix(m1,m2):
    voxels_n = m1.shape[0]
    m1 = np.copy(m1[~np.eye(voxels_n,dtype=bool)].reshape(voxels_n,-1).T)
    m2 = np.copy(m2[~np.eye(voxels_n,dtype=bool)].reshape(voxels_n,-1).T)
    # n = voxels_n - 1 because the diagonal elements were removed (looking at connections to each other voxel)
    n = voxels_n - 1

    m1num = np.subtract(m1,np.mean(m1,axis=0))
    m1den = np.std(m1,axis=0)
    m2num = np.subtract(m2,np.mean(m2,axis=0))
    m2den = np.std(m2,axis=0)
    r = np.sum(np.multiply(np.divide(m1num,m1den), np.divide(m2num,m2den)),axis=0) / n

    dist = np.sqrt(2 - 2 * r)
    return dist

#%% MDMR functions
def check_rank(X):
    k    = X.shape[1]
    rank = np.linalg.matrix_rank(X)
    if rank < k:
        raise Exception("matrix is rank deficient (rank %i vs cols %i)" % (rank, k))

def hat(X):
    Q1, _ = np.linalg.qr(X)
    return Q1.dot(Q1.T)

def gower(D):
    n = D.shape[0]
    A = -0.5 * (D ** 2)
    I = np.eye(n, n)
    uno = np.ones((n, 1))
    C = I - (1.0 / n) * uno.dot(uno.T)
    G = C.dot(A).dot(C)
    return G

def gen_h2(x, cols, indexperm):
    H = gen_h(x, cols, indexperm)
    other_cols = [i for i in range(x.shape[1]) if i not in cols]
    Xj = x[:,other_cols]
    H2 = H - hat(Xj)
    return H2

def permute_design(x, cols, indexperm):
    Xj = x.copy()
    Xj[:, cols] = Xj[indexperm][:, cols]
    return Xj

def gen_h(x, cols, indexperm):
    x = permute_design(x, cols, indexperm)
    H = hat(x)
    return H

def gen_h2_perms(x, cols, perms):
    nperms, nobs = perms.shape
    H2perms = np.zeros((nobs**2, nperms))
    for i in range(nperms):
        H2 = gen_h2(x, cols, perms[i,:])
        H2perms[:,i] = H2.flatten()

    return H2perms

def gen_ih_perms(x, cols, perms):
    nperms, nobs = perms.shape
    I = np.eye(nobs, nobs)

    IHperms = np.zeros((nobs ** 2, nperms))
    for i in range(nperms):
        IH = I - gen_h(x, cols, perms[i, :])
        IHperms[:, i] = IH.flatten()

    return IHperms

def calc_ssq_fast(Hs, Gs, transpose=True):
    if transpose:
        ssq = Hs.T.dot(Gs)
    else:
        ssq = Hs.dot(Gs)
    return ssq

def ftest_fast(Hs, IHs, Gs, df_among, df_resid, **ssq_kwrds):
    SS_among = calc_ssq_fast(Hs, Gs, **ssq_kwrds)
    SS_resid = calc_ssq_fast(IHs, Gs, **ssq_kwrds)
    F = (SS_among / df_among) / (SS_resid / df_resid)
    return F

def mdmr(D, X, columns, permutations):

    check_rank(X)

    subjects = X.shape[0]
    if subjects != D.shape[1]:
        raise Exception("# of subjects incompatible between X and D")

    voxels = D.shape[0]
    Gs = np.zeros((subjects ** 2, voxels))
    for di in range(voxels):
        Gs[:, di] = gower(D[di]).flatten()

    X1 = np.hstack((np.ones((subjects, 1)), X))
    columns = columns.copy() + 1

    regressors = X1.shape[1]

    permutation_indexes = np.zeros((permutations + 1, subjects), dtype=int)
    permutation_indexes[0, :] = range(subjects)
    for i in range(1, permutations + 1):
        permutation_indexes[i,:] = np.random.permutation(subjects)

    H2perms = gen_h2_perms(X1, columns, permutation_indexes)
    IHperms = gen_ih_perms(X1, columns, permutation_indexes)

    df_among = len(columns)
    df_resid = subjects - regressors

    F_perms = ftest_fast(H2perms, IHperms, Gs, df_among, df_resid)

    p_vals = (F_perms[1:, :] >= F_perms[0, :]) \
                .sum(axis=0) \
                .astype('float')
    p_vals /= permutations

    return F_perms[0, :], p_vals

#%%
def mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name):
    cols = np.array([1])
    cols = np.array(cols, dtype=np.int32)
    reg = np.array(group_contrast,dtype=np.float64)
    X = np.array([range(reg.shape[0]),group_contrast],dtype=np.float64).T
    print(X.shape)
    print(X)

    F_perms, p_vals = mdmr(sub_dist_mat,X,cols,perms)

    np.save(MDMR_DIR.joinpath(f'intersubject_voxelwise_{analysis_name}_dist_F_perms.npy'),F_perms)
    np.save(MDMR_DIR.joinpath(f'intersubject_voxelwise_{analysis_name}_dist_p_vals.npy'),p_vals)

    max_clusters = np.zeros((cluster_perms))
    print("cwas cluster permutations")
    for c in range(cluster_perms):
        print(c)
        regX = np.copy(group_contrast)
        np.random.shuffle(regX)
        Xp = np.array([range(regX.shape[0]),list(regX)],dtype=np.float64).T
        F_temp, p_vals_temp = mdmr(sub_dist_mat,Xp,cols,perms)
        p_vals_temp[np.where(p_vals_temp==0)] = 1/perms

        p_vals_temp_data = np.zeros_like(np.array(GM_idx,dtype=np.float64))
        p_vals_temp_data[np.where(GM_idx)] = p_vals_temp

        p_vals_temp_data[np.where(p_vals_temp_data >= pthresh)] = 0
        p_vals_temp_data_bin = np.array(p_vals_temp_data)
        p_vals_temp_data_bin[np.where(p_vals_temp_data_bin > 0)] = 1
        clusters,nClusters = measurements.label(p_vals_temp_data)
        area = measurements.sum(p_vals_temp_data_bin,clusters,index = np.arange(nClusters)+1)
        max_clusters[c] = area.max()
    max_clusters = np.sort(max_clusters)

    #this condition didn't appear, but is added in case no permuted cases are lower than empirical p. Prevents sig p voxels == 0 being removed.
    p_vals[np.where(p_vals==0)] = 1/perms
    p_vals_data = np.zeros_like(np.array(GM_idx,dtype=np.float64))
    p_vals_data[np.where(GM_idx)] = p_vals
    #p_vals_img = nib.Nifti1Image(p_vals_data, epi_affine)

    #threshold output image using cluster_thresh now
    p_vals_data[p_vals_data >= pthresh] = 0
    p_vals_data_bin = np.array(p_vals_data)
    p_vals_data_bin[np.where(p_vals_data_bin > 0)] = 1
    clusters,nClusters = measurements.label(p_vals_data)
    area = measurements.sum(p_vals_data_bin,clusters,index = np.arange(nClusters)+1)
    sig_clusters = np.zeros_like(clusters)
    for i in range(area.size):
        p = (cluster_perms - bisect_left(max_clusters,area[i])) / cluster_perms
        sig_clusters[np.where(clusters == i + 1)] = 1 if p < pthresh else 0

    #mask pvalues by significant clusters
    sig_p_vals_data = np.multiply(sig_clusters,p_vals_data)

    # mni_4mm_pvals_img = nb.Nifti1Image(mni_4mm_pvals, mni_4mm_img.affine)
    sig_p_vals_img = nib.Nifti1Image(sig_p_vals_data, epi_affine)
    nib.save(sig_p_vals_img, MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p.nii.gz'))

#%% deprived - normal sleep young vs old intersubject distance matrix calculation
if False: # put back for github
    voxels_n = young_old_subjects_deprived_sleep_voxelwise_FC_dict[subjects_young_old[0]].shape[0]
    sub_dist_mat = np.zeros((voxels_n,len(subjects_young_old),len(subjects_young_old)))
    for i, s1 in enumerate(subjects_young_old):
        s1_diff_sleep_FC = young_old_subjects_deprived_sleep_voxelwise_FC_dict[s1] - young_old_subjects_normal_sleep_voxelwise_FC_dict[s1]
        for j, s2 in enumerate(subjects_young_old):
            if j > i:
                print('s1',i,s1,'s2',j,s2)
                s2_diff_sleep_FC = young_old_subjects_deprived_sleep_voxelwise_FC_dict[s2] - young_old_subjects_normal_sleep_voxelwise_FC_dict[s2]
                
                sub_dist_mat[:,i,j] = distance_matrix(s1_diff_sleep_FC,s2_diff_sleep_FC)
                sub_dist_mat[:,j,i] = sub_dist_mat[:,i,j]

    np.save(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_diff_sleep_dist_matrix.npy'),sub_dist_mat)

#%% put back for github
if False:
    sub_dist_mat = np.load(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_diff_sleep_dist_matrix.npy'))
    group_contrast = [1.0 if sub in young_subjects else -1.0 for sub in subjects_young_old]
    analysis_name = 'diff_sleep'

    mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name)

#%% deprived vs normal sleep old
# put back for github
if False:
    old_subjects_deprived_sleep_voxelwise_FC_list = []
    old_subjects_normal_sleep_voxelwise_FC_list = []
    for sub in old_subjects:
        old_subjects_deprived_sleep_voxelwise_FC_list.append(young_old_subjects_deprived_sleep_voxelwise_FC_dict[sub])
        old_subjects_normal_sleep_voxelwise_FC_list.append(young_old_subjects_normal_sleep_voxelwise_FC_dict[sub])
    old_subjects_deprived_normal_sleep_voxelwise_FC_list = old_subjects_deprived_sleep_voxelwise_FC_list + old_subjects_normal_sleep_voxelwise_FC_list

    voxels_n = young_old_subjects_normal_sleep_voxelwise_FC_dict[subjects_young_old[0]].shape[0]
    matrices_n = len(old_subjects_deprived_normal_sleep_voxelwise_FC_list)
    sub_dist_mat = np.zeros((voxels_n,matrices_n,matrices_n))
    for i, mat1 in enumerate(old_subjects_deprived_normal_sleep_voxelwise_FC_list):
        for j, mat2 in enumerate(old_subjects_deprived_normal_sleep_voxelwise_FC_list):
            if j > i:
                print('mat1',i,'mat2',j)
                sub_dist_mat[:,i,j] = distance_matrix(mat1,mat2)
                sub_dist_mat[:,j,i] = sub_dist_mat[:,i,j]

    np.save(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_old_dist_matrix.npy'),sub_dist_mat)

#%% put back for github
if False:
    sub_dist_mat = np.load(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_old_dist_matrix.npy'))
    group_contrast = [1.0 if i < len(old_subjects) else -1.0 for i in range(2*len(old_subjects))]
    analysis_name = 'old_deprived_vs_normal_sleep'

    mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name)

#%% deprived vs normal sleep young
# put back for github
if False:
    young_subjects_deprived_sleep_voxelwise_FC_list = []
    young_subjects_normal_sleep_voxelwise_FC_list = []
    for sub in young_subjects:
        young_subjects_deprived_sleep_voxelwise_FC_list.append(young_old_subjects_deprived_sleep_voxelwise_FC_dict[sub])
        young_subjects_normal_sleep_voxelwise_FC_list.append(young_old_subjects_normal_sleep_voxelwise_FC_dict[sub])
    young_subjects_deprived_normal_sleep_voxelwise_FC_list = young_subjects_deprived_sleep_voxelwise_FC_list + young_subjects_normal_sleep_voxelwise_FC_list

    voxels_n = young_old_subjects_normal_sleep_voxelwise_FC_dict[subjects_young_old[0]].shape[0]
    matrices_n = len(young_subjects_deprived_normal_sleep_voxelwise_FC_list)
    sub_dist_mat = np.zeros((voxels_n,matrices_n,matrices_n))
    for i, mat1 in enumerate(young_subjects_deprived_normal_sleep_voxelwise_FC_list):
        for j, mat2 in enumerate(young_subjects_deprived_normal_sleep_voxelwise_FC_list):
            if j > i:
                print('mat1',i,'mat2',j)
                sub_dist_mat[:,i,j] = distance_matrix(mat1,mat2)
                sub_dist_mat[:,j,i] = sub_dist_mat[:,i,j]

    np.save(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_young_dist_matrix.npy'),sub_dist_mat)

#%% put back for github
if False:
    sub_dist_mat = np.load(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_young_dist_matrix.npy'))
    group_contrast = [1.0 if i < len(young_subjects) else -1.0 for i in range(2*len(young_subjects))]
    analysis_name = 'young_deprived_vs_normal_sleep'

    mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name)

#%% put back for github
if False:
    analysis_name = 'young_deprived_vs_normal_sleep'
    mdmr_nifti_file = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p.nii.gz')
    mdmr_nifti_file_2mm = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm.nii.gz')
    os.system(f'flirt -in {mdmr_nifti_file} -ref {mdmr_nifti_file} -applyisoxfm 2.0 -nosearch -interp nearestneighbour -out {mdmr_nifti_file_2mm}')

    mdmr_img = nib.load(mdmr_nifti_file_2mm)
    # mdmr_affine = mdmr_img.affine
    # mdmr_data = mdmr_img.get_fdata()
    # mdmr_05_min_p = np.zeros_like(mdmr_data)
    # mdmr_05_min_p[np.where(mdmr_data > 0)] = 0.05 - mdmr_data[np.where(mdmr_data > 0)]
    # mdmr_05_min_p_img = nib.Nifti1Image(mdmr_05_min_p,mdmr_affine)
    mdmr_img_2_fsaverage_surf = transforms.mni152_to_fsaverage(mdmr_img,fsavg_density='10k',method='nearest')
    mdmr_gifti_file_fsaverage_LH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH.gii.gz')
    mdmr_gifti_file_fsaverage_RH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH.gii.gz')
    nib.save(mdmr_img_2_fsaverage_surf[0],mdmr_gifti_file_fsaverage_LH)
    nib.save(mdmr_img_2_fsaverage_surf[1],mdmr_gifti_file_fsaverage_RH)

#%%
def custom_nonzero_mean(vertices):
    """ignoring adjacent 0 values as these would decrease the pvalue to an artificially
    low level
    """
    sum = 0.0
    n = 0.0
    for v in vertices:
        if v > 0.0:
            sum += v
            n += 1.0
    mean = 0.0 if n==0.0 else sum / n
    
    return mean
# put back for github
if False:
    fsaverage = datasets.fetch_surf_fsaverage(mesh='fsaverage5')

    cmap_colours = [(.886,.761,.133),(.847,.631,.031),(.922,.0,.02)][::-1]
    cmap = LinearSegmentedColormap.from_list('greyscale', cmap_colours,N=100)
    fig = plt.figure(figsize=(30, 30))
    plotting.plot_surf_stat_map(fsaverage['pial_left'],
                                mdmr_gifti_file_fsaverage_LH,
                                bg_map=fsaverage['sulc_left'],
                                view='medial',
                                bg_on_data=True,
                                cmap=cmap,
                                threshold=.0000001,
                                hemi='left',
                                output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_medial.png'),
                                figure=fig,
                                vmax=.05,
                                symmetric_cbar=False,
                                avg_method=custom_nonzero_mean,
                                darkness = 1.2,
                                )

#%% put back for github
if False:
    fig = plt.figure(figsize=(30, 30))
    plotting.plot_surf_stat_map(fsaverage['pial_left'],
                                mdmr_gifti_file_fsaverage_LH,
                                bg_map=fsaverage['sulc_left'],
                                view='lateral',
                                bg_on_data=True,
                                cmap=cmap,
                                threshold=.0000001,
                                hemi='left',
                                output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_lateral.png'),
                                figure=fig,
                                vmax=.05,
                                symmetric_cbar=False,
                                avg_method=custom_nonzero_mean,
                                darkness = 1.2,
                                )

#%% put back for github
if False:
    fig = plt.figure(figsize=(30, 30))
    plotting.plot_surf_stat_map(fsaverage['pial_right'],
                                mdmr_gifti_file_fsaverage_RH,bg_map=fsaverage['sulc_right'],
                                view='medial',
                                bg_on_data=True,
                                cmap=cmap,
                                threshold=0.0000001,
                                hemi='right',
                                output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_medial.png'),
                                figure=fig,
                                vmax=.05,
                                symmetric_cbar=False,
                                avg_method=custom_nonzero_mean,
                                darkness = 1.2,
                                )

#%% put back for github
if False:
    fig = plt.figure(figsize=(30, 30))
    plotting.plot_surf_stat_map(fsaverage['pial_right'],
                                mdmr_gifti_file_fsaverage_RH,
                                bg_map=fsaverage['sulc_right'],
                                view='lateral',
                                bg_on_data=True,
                                cmap=cmap,
                                threshold=0.0000001,
                                hemi='right',
                                output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_lateral.png'),
                                figure=fig,
                                vmax=.05,
                                symmetric_cbar=False,
                                avg_method=custom_nonzero_mean,
                                darkness = 1.2,
                                )

#%%MDMR 750 cluster perms
with open(GM_IDX_FILE,'rb') as f:
    GM_idx = pickle.load(f)
with open(EPI_AFFINE_FILE,'rb') as f:
    epi_affine = pickle.load(f)

perms = 15000
cluster_perms = 750
pthresh = .05

#%% load voxelwise connectivity in memory map mode (each is 2.4GB)
young_old_subjects_deprived_sleep_voxelwise_FC_dict = {}
young_old_subjects_normal_sleep_voxelwise_FC_dict = {}

subjects_young_old = young_subjects + old_subjects

for sub in subjects_young_old:
    young_old_subjects_deprived_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_deprived_sleep_sub-{sub}.npy'),mmap_mode='r')
    young_old_subjects_normal_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_normal_sleep_sub-{sub}.npy'),mmap_mode='r')

#%%
sub_dist_mat = np.load(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_young_dist_matrix.npy'))
group_contrast = [1.0 if i < len(young_subjects) else -1.0 for i in range(2*len(young_subjects))]
analysis_name = 'young_deprived_vs_normal_sleep_perms_750'

mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name)

#%%
analysis_name = 'young_deprived_vs_normal_sleep_perms_750'
mdmr_nifti_file = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p.nii.gz')
mdmr_nifti_file_2mm = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm.nii.gz')
os.system(f'flirt -in {mdmr_nifti_file} -ref {mdmr_nifti_file} -applyisoxfm 2.0 -nosearch -interp nearestneighbour -out {mdmr_nifti_file_2mm}')

mdmr_img = nib.load(mdmr_nifti_file_2mm)
# mdmr_affine = mdmr_img.affine
# mdmr_data = mdmr_img.get_fdata()
# mdmr_05_min_p = np.zeros_like(mdmr_data)
# mdmr_05_min_p[np.where(mdmr_data > 0)] = 0.05 - mdmr_data[np.where(mdmr_data > 0)]
# mdmr_05_min_p_img = nib.Nifti1Image(mdmr_05_min_p,mdmr_affine)
mdmr_img_2_fsaverage_surf = transforms.mni152_to_fsaverage(mdmr_img,fsavg_density='10k',method='nearest')
mdmr_gifti_file_fsaverage_LH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH.gii.gz')
mdmr_gifti_file_fsaverage_RH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH.gii.gz')
nib.save(mdmr_img_2_fsaverage_surf[0],mdmr_gifti_file_fsaverage_LH)
nib.save(mdmr_img_2_fsaverage_surf[1],mdmr_gifti_file_fsaverage_RH)

#%%
def custom_nonzero_mean(vertices):
    """ignoring adjacent 0 values as these would decrease the pvalue to an artificially
    low level
    """
    sum = 0.0
    n = 0.0
    for v in vertices:
        if v > 0.0:
            sum += v
            n += 1.0
    mean = 0.0 if n==0.0 else sum / n
    
    return mean
    

fsaverage = datasets.fetch_surf_fsaverage(mesh='fsaverage5')

cmap_colours = [(.886,.761,.133),(.847,.631,.031),(.922,.0,.02)][::-1]
cmap = LinearSegmentedColormap.from_list('greyscale', cmap_colours,N=100)
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_left'],
                            mdmr_gifti_file_fsaverage_LH,
                            bg_map=fsaverage['sulc_left'],
                            view='medial',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=.0000001,
                            hemi='left',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_medial.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_left'],
                            mdmr_gifti_file_fsaverage_LH,
                            bg_map=fsaverage['sulc_left'],
                            view='lateral',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=.0000001,
                            hemi='left',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_lateral.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_right'],
                            mdmr_gifti_file_fsaverage_RH,bg_map=fsaverage['sulc_right'],
                            view='medial',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=0.0000001,
                            hemi='right',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_medial.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_right'],
                            mdmr_gifti_file_fsaverage_RH,
                            bg_map=fsaverage['sulc_right'],
                            view='lateral',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=0.0000001,
                            hemi='right',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_lateral.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%MDMR 1000 cluster perms
with open(GM_IDX_FILE,'rb') as f:
    GM_idx = pickle.load(f)
with open(EPI_AFFINE_FILE,'rb') as f:
    epi_affine = pickle.load(f)

perms = 15000
cluster_perms = 1000
pthresh = .05

#%% load voxelwise connectivity in memory map mode (each is 2.4GB)
young_old_subjects_deprived_sleep_voxelwise_FC_dict = {}
young_old_subjects_normal_sleep_voxelwise_FC_dict = {}

subjects_young_old = young_subjects + old_subjects

for sub in subjects_young_old:
    young_old_subjects_deprived_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_deprived_sleep_sub-{sub}.npy'),mmap_mode='r')
    young_old_subjects_normal_sleep_voxelwise_FC_dict[sub] = np.load(GM_VOXELWISE_FC_DIR.joinpath(f'GM_voxelwise_4mm_FC_normal_sleep_sub-{sub}.npy'),mmap_mode='r')

#%%
sub_dist_mat = np.load(GM_VOXELWISE_FC_DIR.joinpath('intersubject_voxelwise_FC_deprived_vs_normal_sleep_young_dist_matrix.npy'))
group_contrast = [1.0 if i < len(young_subjects) else -1.0 for i in range(2*len(young_subjects))]
analysis_name = 'young_deprived_vs_normal_sleep_perms_1000'

mdmr_cluster_thresh(sub_dist_mat,group_contrast,analysis_name)

#%%
analysis_name = 'young_deprived_vs_normal_sleep_perms_1000'
mdmr_nifti_file = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p.nii.gz')
mdmr_nifti_file_2mm = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm.nii.gz')
os.system(f'flirt -in {mdmr_nifti_file} -ref {mdmr_nifti_file} -applyisoxfm 2.0 -nosearch -interp nearestneighbour -out {mdmr_nifti_file_2mm}')

mdmr_img = nib.load(mdmr_nifti_file_2mm)
# mdmr_affine = mdmr_img.affine
# mdmr_data = mdmr_img.get_fdata()
# mdmr_05_min_p = np.zeros_like(mdmr_data)
# mdmr_05_min_p[np.where(mdmr_data > 0)] = 0.05 - mdmr_data[np.where(mdmr_data > 0)]
# mdmr_05_min_p_img = nib.Nifti1Image(mdmr_05_min_p,mdmr_affine)
mdmr_img_2_fsaverage_surf = transforms.mni152_to_fsaverage(mdmr_img,fsavg_density='10k',method='nearest')
mdmr_gifti_file_fsaverage_LH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH.gii.gz')
mdmr_gifti_file_fsaverage_RH = MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH.gii.gz')
nib.save(mdmr_img_2_fsaverage_surf[0],mdmr_gifti_file_fsaverage_LH)
nib.save(mdmr_img_2_fsaverage_surf[1],mdmr_gifti_file_fsaverage_RH)

#%%
def custom_nonzero_mean(vertices):
    """ignoring adjacent 0 values as these would decrease the pvalue to an artificially
    low level
    """
    sum = 0.0
    n = 0.0
    for v in vertices:
        if v > 0.0:
            sum += v
            n += 1.0
    mean = 0.0 if n==0.0 else sum / n
    
    return mean
    

fsaverage = datasets.fetch_surf_fsaverage(mesh='fsaverage5')

cmap_colours = [(.886,.761,.133),(.847,.631,.031),(.922,.0,.02)][::-1]
cmap = LinearSegmentedColormap.from_list('greyscale', cmap_colours,N=100)
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_left'],
                            mdmr_gifti_file_fsaverage_LH,
                            bg_map=fsaverage['sulc_left'],
                            view='medial',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=.0000001,
                            hemi='left',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_medial.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_left'],
                            mdmr_gifti_file_fsaverage_LH,
                            bg_map=fsaverage['sulc_left'],
                            view='lateral',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=.0000001,
                            hemi='left',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_LH_lateral.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_right'],
                            mdmr_gifti_file_fsaverage_RH,bg_map=fsaverage['sulc_right'],
                            view='medial',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=0.0000001,
                            hemi='right',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_medial.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )

#%%
fig = plt.figure(figsize=(30, 30))
plotting.plot_surf_stat_map(fsaverage['pial_right'],
                            mdmr_gifti_file_fsaverage_RH,
                            bg_map=fsaverage['sulc_right'],
                            view='lateral',
                            bg_on_data=True,
                            cmap=cmap,
                            threshold=0.0000001,
                            hemi='right',
                            output_file=MDMR_DIR.joinpath(f'cluster_thresholded_voxelwise_{analysis_name}_mdmr_p_2mm_RH_lateral.png'),
                            figure=fig,
                            vmax=.05,
                            symmetric_cbar=False,
                            avg_method=custom_nonzero_mean,
                            darkness = 1.2,
                            )