% %% res param 1 (default)
% project_dir = './';
% 
% mod_dir = [project_dir 'outputs/modularity/'];
% 
% % Attach the required function to the parallel pool
% pool = gcp;
% addAttachedFiles(pool, {'null_model_und_sign.m'});
% 
% % Load subjects and matrices
% load(fullfile(mod_dir,'FC_community.mat'), 'FC_community');
% load(fullfile(mod_dir,'ALL_SUBS.mat'), 'ALL_SUBS');
% 
% num_nulls = 1000;
% num_subjects = 84;
% num_rois = 220;
% 
% % Determine which subject to process for this MATLAB instance
% subject_index = str2double(getenv('SLURM_ARRAY_TASK_ID'));
% 
% A_flat = ALL_SUBS{subject_index};
% A_square = zeros(num_rois);
% count = 0;
% for i = 1:num_rois
%     for j = 1:num_rois
%         if j > i
%             count = count + 1;
%             A_square(i,j) = A_flat(count);
%         end 
%     end
% end
% 
% A = A_square + A_square.';
% %Set Diagonal to 0
% n=size(A,1);
% A(1:num_rois+1:num_rois*num_rois)=0;
% matrix = A;
% 
% null_distribution = zeros(1,num_nulls);
% pval = [];
% null_matrices = {};
% 
% parfor i = 1:num_nulls
%     null_mat = null_model_und_sign(matrix);
%     [null_M,null_Q] = community_louvain(null_mat,1,'','negative_asym');
%     null_distribution(i)= null_Q;
%     null_matrices{i}=null_mat;
% end
% 
% Q = FC_community(subject_index);
% pval = (sum(abs(null_distribution) >= abs(Q)) /num_nulls);
% 
% save(fullfile(mod_dir,sprintf('FC_Q_sub%d',subject_index)), 'pval');
% save(fullfile(mod_dir,sprintf('FC_Q_null_distribution_sub%d', subject_index)), 'null_distribution');
% save(fullfile(mod_dir,sprintf('FC_Q_null_matrices_sub%d', subject_index)), 'null_matrices');
%% res param 0.75
project_dir = './';

mod_dir = [project_dir 'outputs/modularity/'];

% Attach the required function to the parallel pool
pool = gcp;
addAttachedFiles(pool, {'null_model_und_sign.m'});

% Load subjects and matrices
load(fullfile(mod_dir,'sleepybrain_modularity_res_0_75.mat'), 'FC_community');
load(fullfile(mod_dir,'sleepybrain_FC_res_0_75.mat'), 'ALL_SUBS');

num_nulls = 1000;
num_subjects = 84;
num_rois = 220;

% Determine which subject to process for this MATLAB instance
subject_index = str2double(getenv('SLURM_ARRAY_TASK_ID'));

A_flat = ALL_SUBS{subject_index};
A_square = zeros(num_rois);
count = 0;
for i = 1:num_rois
    for j = 1:num_rois
        if j > i
            count = count + 1;
            A_square(i,j) = A_flat(count);
        end 
    end
end

A = A_square + A_square.';
%Set Diagonal to 0
n=size(A,1);
A(1:num_rois+1:num_rois*num_rois)=0;
matrix = A;

null_distribution = zeros(1,num_nulls);
pval = [];
null_matrices = {};

parfor i = 1:num_nulls
    null_mat = null_model_und_sign(matrix);
    [null_M,null_Q] = community_louvain(null_mat,0.75,'','negative_asym');
    null_distribution(i)= null_Q;
    null_matrices{i}=null_mat;
end

Q = FC_community(subject_index);
pval = (sum(abs(null_distribution) >= abs(Q)) /num_nulls);

save(fullfile(mod_dir,sprintf('FC_Q_res_0_75_sub%d',subject_index)), 'pval');
save(fullfile(mod_dir,sprintf('FC_Q_res_0_75_null_distribution_sub%d', subject_index)), 'null_distribution');
save(fullfile(mod_dir,sprintf('FC_Q_res_0_75_null_matrices_sub%d', subject_index)), 'null_matrices');

%% res param 1.25
project_dir = './';

mod_dir = [project_dir 'outputs/modularity/'];

% Attach the required function to the parallel pool
pool = gcp;
addAttachedFiles(pool, {'null_model_und_sign.m'});

% Load subjects and matrices
load(fullfile(mod_dir,'sleepybrain_modularity_res_1_25.mat'), 'FC_community');
load(fullfile(mod_dir,'sleepybrain_FC_res_1_25.mat'), 'ALL_SUBS');

num_nulls = 1000;
num_subjects = 84;
num_rois = 220;

% Determine which subject to process for this MATLAB instance
subject_index = str2double(getenv('SLURM_ARRAY_TASK_ID'));

A_flat = ALL_SUBS{subject_index};
A_square = zeros(num_rois);
count = 0;
for i = 1:num_rois
    for j = 1:num_rois
        if j > i
            count = count + 1;
            A_square(i,j) = A_flat(count);
        end 
    end
end

A = A_square + A_square.';
%Set Diagonal to 0
n=size(A,1);
A(1:num_rois+1:num_rois*num_rois)=0;
matrix = A;

null_distribution = zeros(1,num_nulls);
pval = [];
null_matrices = {};

parfor i = 1:num_nulls
    null_mat = null_model_und_sign(matrix);
    [null_M,null_Q] = community_louvain(null_mat,1.25,'','negative_asym');
    null_distribution(i)= null_Q;
    null_matrices{i}=null_mat;
end

Q = FC_community(subject_index);
pval = (sum(abs(null_distribution) >= abs(Q)) /num_nulls);

save(fullfile(mod_dir,sprintf('FC_Q_res_1_25_sub%d',subject_index)), 'pval');
save(fullfile(mod_dir,sprintf('FC_Q_res_1_25_null_distribution_sub%d', subject_index)), 'null_distribution');
save(fullfile(mod_dir,sprintf('FC_Q_res_1_25_null_matrices_sub%d', subject_index)), 'null_matrices');