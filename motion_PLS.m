
%% FC with Motion (behav PLS)
project_dir = './';

data_dir = [project_dir 'data/data_processing'];
outputs_dir = [project_dir 'outputs/PLS/motion_PLS'];
orig_outputs_dir = [project_dir 'outputs/PLS/mean_centred_PLS'];


mkdir(outputs_dir);

LEiDA_dir = [project_dir 'leida-matlab-1.0/res_SleepyBrain_TVB_SchaeferTian_220/K5/subject_data'];

young_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_young_subjects_files.csv']);
old_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_old_subjects_files.csv']);

bsr_filename = 'motion_PLS_lv1_bsr_2.0thresh_FC.csv';
usc_fig_filename = 'motion_PLS_lv1_usc_FC.png';
results_filename = 'motion_PLS_FC_result.mat';
usc_table_filename = 'motion_PLS_FC_usc_table.csv';

orig_results_filename = 'mean_centred_PLS_FC_result.mat';

all_subs_FC = [];
for s=1:length(young_subs_files)
    FC = load([data_dir '/' young_subs_files{s}]);
    all_subs_FC = [all_subs_FC; FC'];
end

for s=1:length(old_subs_files)
    FC = load([data_dir '/' old_subs_files{s}]);
    all_subs_FC = [all_subs_FC; FC'];
end

young_motion = str2double(readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'young_subjects_motion.csv']));
old_motion = str2double(readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'old_subjects_motion.csv']));
motion = cat(1,young_motion,old_motion);

%%
datamat_lst = {};
datamat_lst{1} = all_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [84];
num_cond = 1;
option.stacked_behavdata = motion;
option.method = 3;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

motion_FC_result = pls_analysis(datamat_lst, num_subj, num_cond, option);

%%
save(fullfile(outputs_dir,results_filename),'motion_FC_result')

%%
load(fullfile(outputs_dir,results_filename),'motion_FC_result');
load(fullfile(orig_outputs_dir,orig_results_filename),'result');
orig_result = result;

%% Compare motion and original analyses
x = all_subs_FC;
y = motion_FC_result.stacked_behavdata(:,1);

nperm = 1000;
n_con = 1;
lv_orig = 1;
lv_N = 1;

n=size(y,1);
n=n/n_con;
dot_distribution = zeros(1, nperm); 

for i=1:nperm
    yperm=y(randperm(n*n_con),:);
    if n_con>1
        idx_subj=[1:n*n_con];
        idx_subj=reshape(idx_subj,n,n_con);
        rxPy = [];
    
        for j=1:n_con
            tmp_rxPy = corr(x(idx_subj(:,j),:),yperm(idx_subj(:,j),:));
            rxPy=[rxPy,tmp_rxPy];
        end
    
    else
        rxPy=corr(x,yperm);
    end

    locate_nans = find(isnan(rxPy));
    rxPy(locate_nans)= 0;

    [perm_u, ~, ~] = svd(rxPy, 'econ');
     cosine_val = perm_u(:,lv_N)'* orig_result.u(:,lv_orig);
     dot_distribution(i) = cosine_val;
end

%% p-value 
orig_cosine = motion_FC_result.u(:,lv_N)'*orig_result.u(:,lv_orig);
p_value = sum(abs(dot_distribution) >= abs(orig_cosine)) / nperm;

disp(['Original Cosine: ', num2str(orig_cosine)]);
disp(['P-value: ', num2str(p_value)]);