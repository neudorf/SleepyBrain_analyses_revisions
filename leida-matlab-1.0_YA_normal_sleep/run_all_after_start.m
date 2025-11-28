%%
%project_dir = [fileparts(pwd) '/']; % change for github?
project_dir = '../';
LEiDA_directory = [project_dir 'leida-matlab-1.0_YA_normal_sleep/'];
run_name = 'SleepyBrain_TVB_SchaeferTian_220';
Parcellation = 'TVBSchaeferTian220';
Conditions_tag = {'normal_sleep'};
n_permutations = 500; % can keep as 500 testing, then increase to 10000
n_bootstraps = 10; % can keep as 10 for testing, then increase to 500
subjects_file = [project_dir 'data/good_subjects.txt']; 
young_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_YA.txt'];
old_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_OA.txt']; 
young_female_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_YA_female.txt']; 
young_male_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_YA_male.txt']; 
old_female_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_OA_female.txt']; 
old_male_subjects_file = [project_dir 'data/data_processing/behav/good_subjects_OA_male.txt']; 

%%
SelectK = 5;
LEiDA_AnalysisK(LEiDA_directory, run_name, SelectK, Parcellation)
%%
LEiDA_AnalysisCentroid(LEiDA_directory, run_name, SelectK, Parcellation)
%%
LEiDA_TransitionsK(LEiDA_directory, run_name, SelectK, n_permutations, n_bootstraps)
%%
LEiDA_StateTime(LEiDA_directory, run_name, SelectK, subjects_file)

%% Saving FO and TM data for PLS analysis
young_subs = readlines(young_subjects_file,"EmptyLineRule","skip");
young_subs_n = size(young_subs);
old_subs = readlines(old_subjects_file,"EmptyLineRule","skip");
old_subs_n = size(old_subs);

young_subs_names = [];
% for s=1:young_subs_n
%     young_subs_names = [young_subs_names; strcat(young_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
for s=1:young_subs_n
    young_subs_names = [young_subs_names; strcat(young_subs(s), '_', Conditions_tag(2),'.txt' )];
end

% old_subs_names = [];
% for s=1:old_subs_n
%     old_subs_names = [old_subs_names; strcat(old_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
% for s=1:old_subs_n
%     old_subs_names = [old_subs_names; strcat(old_subs(s), '_', Conditions_tag(2),'.txt' )];
% end

load([LEiDA_directory 'res_' run_name '/LEiDA_EigenVectors.mat'],'Data_info','idx_data');
load([LEiDA_directory 'res_' run_name '/LEiDA_Stats_FracOccup.mat'],'P');
load([LEiDA_directory 'res_' run_name '/K' num2str(SelectK) '/LEiDA_Stats_TransitionMatrix.mat'],'TMnorm');

FO_files_YA = {};
TM_files_YA = {};
for subj_idx = 1:young_subs_n
    subj = young_subs_names(subj_idx);
    for i = 1:length(idx_data)
        s = idx_data(i);
        if contains(Data_info(s).name,subj)
            FO = P(s,SelectK-1,1:SelectK);
            FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
            writematrix(FO, FO_filename)  
            FO_files_YA{subj_idx} = FO_filename;
    
            TM = TMnorm(s,:,:);
            TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
            writematrix(TM, TM_filename)
            TM_files_YA{subj_idx} = TM_filename;
        end
    end
end

FO_YA_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_YA_files.txt');
TM_YA_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_YA_files.txt');
for subj_idx = 1:young_subs_n
    if subj_idx == 1
        writelines(FO_files_YA{subj_idx},FO_YA_PLS_filenames_file);
        writelines(TM_files_YA{subj_idx},TM_YA_PLS_filenames_file);
    else
        writelines(FO_files_YA{subj_idx},FO_YA_PLS_filenames_file,WriteMode='append');
        writelines(TM_files_YA{subj_idx},TM_YA_PLS_filenames_file,WriteMode='append');
    end
end

% FO_files_OA = {};
% TM_files_OA = {};
% for subj_idx = 1:old_subs_n
%     subj = old_subs_names(subj_idx);
%     for i = 1:length(idx_data)
%         s = idx_data(i);
%         if contains(Data_info(s).name,subj)
%             FO = P(s,SelectK-1,1:SelectK);
%             FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
%             writematrix(FO, FO_filename)  
%             FO_files_OA{subj_idx} = FO_filename;
%     
%             TM = TMnorm(s,:,:);
%             TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
%             writematrix(TM, TM_filename)
%             TM_files_OA{subj_idx} = TM_filename;
%         end
%     end
% end

% FO_OA_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_OA_files.txt');
% TM_OA_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_OA_files.txt');
% for subj_idx = 1:old_subs_n
%     if subj_idx == 1
%         writelines(FO_files_OA{subj_idx},FO_OA_PLS_filenames_file);
%         writelines(TM_files_OA{subj_idx},TM_OA_PLS_filenames_file);
%     else
%         writelines(FO_files_OA{subj_idx},FO_OA_PLS_filenames_file,WriteMode='append');
%         writelines(TM_files_OA{subj_idx},TM_OA_PLS_filenames_file,WriteMode='append');
%     end
% end

%% Saving FO and TM data for PLS analysis Sex
% young_female_subs = readlines(young_female_subjects_file,"EmptyLineRule","skip");
% young_female_subs_n = size(young_female_subs);
% young_male_subs = readlines(young_male_subjects_file,"EmptyLineRule","skip");
% young_male_subs_n = size(young_male_subs);
% old_female_subs = readlines(old_female_subjects_file,"EmptyLineRule","skip");
% old_female_subs_n = size(old_female_subs);
% old_male_subs = readlines(old_male_subjects_file,"EmptyLineRule","skip");
% old_male_subs_n = size(old_male_subs);
% 
% young_female_subs_names = [];
% for s=1:young_female_subs_n
%     young_female_subs_names = [young_female_subs_names; strcat(young_female_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
% for s=1:young_female_subs_n
%     young_female_subs_names = [young_female_subs_names; strcat(young_female_subs(s), '_', Conditions_tag(2),'.txt' )];
% end
% 
% young_male_subs_names = [];
% for s=1:young_male_subs_n
%     young_male_subs_names = [young_male_subs_names; strcat(young_male_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
% for s=1:young_male_subs_n
%     young_male_subs_names = [young_male_subs_names; strcat(young_male_subs(s), '_', Conditions_tag(2),'.txt' )];
% end
% 
% old_female_subs_names = [];
% for s=1:old_female_subs_n
%     old_female_subs_names = [old_female_subs_names; strcat(old_female_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
% for s=1:old_female_subs_n
%     old_female_subs_names = [old_female_subs_names; strcat(old_female_subs(s), '_', Conditions_tag(2),'.txt' )];
% end
% 
% old_male_subs_names = [];
% for s=1:old_male_subs_n
%     old_male_subs_names = [old_male_subs_names; strcat(old_male_subs(s), '_', Conditions_tag(1),'.txt' )];
% end
% for s=1:old_male_subs_n
%     old_male_subs_names = [old_male_subs_names; strcat(old_male_subs(s), '_', Conditions_tag(2),'.txt' )];
% end
% 
% load([LEiDA_directory 'res_' run_name '/LEiDA_EigenVectors.mat'],'Data_info','idx_data');
% load([LEiDA_directory 'res_' run_name '/LEiDA_Stats_FracOccup.mat'],'P');
% load([LEiDA_directory 'res_' run_name '/K' num2str(SelectK) '/LEiDA_Stats_TransitionMatrix.mat'],'TMnorm');
% 
% FO_files_YA_female = {};
% TM_files_YA_female = {};
% for subj_idx = 1:young_female_subs_n*2
%     subj = young_female_subs_names(subj_idx);
%     for i = 1:length(idx_data)
%         s = idx_data(i);
%         if contains(Data_info(s).name,subj)
%             FO = P(s,SelectK-1,1:SelectK);
%             FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
%             FO_files_YA_female{subj_idx} = FO_filename;
% 
%             TM = TMnorm(s,:,:);
%             TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
%             TM_files_YA_female{subj_idx} = TM_filename;
%         end
%     end
% end
% 
% FO_YA_female_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_YA_female_files.txt');
% TM_YA_female_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_YA_female_files.txt');
% for subj_idx = 1:young_female_subs_n*2
%     if subj_idx == 1
%         writelines(FO_files_YA_female{subj_idx},FO_YA_female_PLS_filenames_file);
%         writelines(TM_files_YA_female{subj_idx},TM_YA_female_PLS_filenames_file);
%     else
%         writelines(FO_files_YA_female{subj_idx},FO_YA_female_PLS_filenames_file,WriteMode='append');
%         writelines(TM_files_YA_female{subj_idx},TM_YA_female_PLS_filenames_file,WriteMode='append');
%     end
% end
% 
% FO_files_YA_male = {};
% TM_files_YA_male = {};
% for subj_idx = 1:young_male_subs_n*2
%     subj = young_male_subs_names(subj_idx);
%     for i = 1:length(idx_data)
%         s = idx_data(i);
%         if contains(Data_info(s).name,subj)
%             FO = P(s,SelectK-1,1:SelectK);
%             FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
%             FO_files_YA_male{subj_idx} = FO_filename;
% 
%             TM = TMnorm(s,:,:);
%             TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
%             TM_files_YA_male{subj_idx} = TM_filename;
%         end
%     end
% end
% 
% FO_YA_male_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_YA_male_files.txt');
% TM_YA_male_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_YA_male_files.txt');
% for subj_idx = 1:young_male_subs_n*2
%     if subj_idx == 1
%         writelines(FO_files_YA_male{subj_idx},FO_YA_male_PLS_filenames_file);
%         writelines(TM_files_YA_male{subj_idx},TM_YA_male_PLS_filenames_file);
%     else
%         writelines(FO_files_YA_male{subj_idx},FO_YA_male_PLS_filenames_file,WriteMode='append');
%         writelines(TM_files_YA_male{subj_idx},TM_YA_male_PLS_filenames_file,WriteMode='append');
%     end
% end
% 
% 
% FO_files_OA_female = {};
% TM_files_OA_female = {};
% for subj_idx = 1:young_female_subs_n*2
%     subj = young_female_subs_names(subj_idx);
%     for i = 1:length(idx_data)
%         s = idx_data(i);
%         if contains(Data_info(s).name,subj)
%             FO = P(s,SelectK-1,1:SelectK);
%             FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
%             FO_files_OA_female{subj_idx} = FO_filename;
% 
%             TM = TMnorm(s,:,:);
%             TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
%             TM_files_OA_female{subj_idx} = TM_filename;
%         end
%     end
% end
% 
% FO_OA_female_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_OA_female_files.txt');
% TM_OA_female_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_OA_female_files.txt');
% for subj_idx = 1:young_female_subs_n*2
%     if subj_idx == 1
%         writelines(FO_files_OA_female{subj_idx},FO_OA_female_PLS_filenames_file);
%         writelines(TM_files_OA_female{subj_idx},TM_OA_female_PLS_filenames_file);
%     else
%         writelines(FO_files_OA_female{subj_idx},FO_OA_female_PLS_filenames_file,WriteMode='append');
%         writelines(TM_files_OA_female{subj_idx},TM_OA_female_PLS_filenames_file,WriteMode='append');
%     end
% end
% 
% FO_files_OA_male = {};
% TM_files_OA_male = {};
% for subj_idx = 1:young_male_subs_n*2
%     subj = young_male_subs_names(subj_idx);
%     for i = 1:length(idx_data)
%         s = idx_data(i);
%         if contains(Data_info(s).name,subj)
%             FO = P(s,SelectK-1,1:SelectK);
%             FO_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_', subj{1}(1:end-4), '.csv');
%             FO_files_OA_male{subj_idx} = FO_filename;
% 
%             TM = TMnorm(s,:,:);
%             TM_filename = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_', subj{1}(1:end-4), '.csv');
%             TM_files_OA_male{subj_idx} = TM_filename;
%         end
%     end
% end
% 
% FO_OA_male_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_FO_OA_male_files.txt');
% TM_OA_male_PLS_filenames_file = strcat(LEiDA_directory, 'res_', run_name, '/K', num2str(SelectK), '/subject_data/', 'K', num2str(SelectK), '_TM_OA_male_files.txt');
% for subj_idx = 1:young_male_subs_n*2
%     if subj_idx == 1
%         writelines(FO_files_OA_male{subj_idx},FO_OA_male_PLS_filenames_file);
%         writelines(TM_files_OA_male{subj_idx},TM_OA_male_PLS_filenames_file);
%     else
%         writelines(FO_files_OA_male{subj_idx},FO_OA_male_PLS_filenames_file,WriteMode='append');
%         writelines(TM_files_OA_male{subj_idx},TM_OA_male_PLS_filenames_file,WriteMode='append');
%     end
% end