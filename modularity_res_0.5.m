%% Prep
project_dir = './';
subject_files_dir = [project_dir 'data/data_processing/FC/TVBSchaeferTian220/matlab/'];
outputs_dir = [project_dir 'outputs/modularity/'];
mkdir(outputs_dir);
mod_table_filename = 'sleepybrain_modularity_res_0.5.csv';
FC_mat_filename = 'sleepybrain_FC_res_0.5.mat';
mod_mat_filename = 'sleepybrain_modularity_res_0.5.mat';

%% GET DATA
% YOUNG ADULTS
young_subs_files = readlines([subject_files_dir 'FC_young_subjects_files.csv']);

% Preallocate a cell array for loading data
ALL_YA = cell(length(young_subs_files), 1);  % Adjust the size if needed
% Loop through each row
for s = 1:length(young_subs_files)
    % Construct the filename
    filename = strcat(project_dir, 'data/data_processing/', young_subs_files(s));
    % Display filename
    disp(['Loading file: ' filename]);
    % Load the data
    ALL_YA{s} = load(filename);
end

% OLD ADULTS
old_subs_files = readlines([subject_files_dir 'FC_old_subjects_files.csv']);
% Preallocate a cell array for loading data
ALL_OA = cell(length(old_subs_files), 1);  % Adjust the size if needed
% Loop through each row of the cell array
for s = 1:length(old_subs_files)
    % Construct the filename
    filename = strcat(project_dir, 'data/data_processing/', old_subs_files(s));
    % Display the filename
    disp(['Loading file: ' filename]);
    % Load the data
    ALL_OA{s} = load(filename);
end

ALL_SUBS = [ALL_YA; ALL_OA];
save(fullfile(outputs_dir, FC_mat_filename),'ALL_SUBS');

%% FC Community
FC_community=[];
FC_M=[];
gamma = 0.5; % resolution parameter
n=220;
for s=1:length(young_subs_files) + length(old_subs_files)
    A_flat = ALL_SUBS{s};
    A_square = zeros(n);
    count = 0;
    for i = 1:n
        for j = 1:n
            if j > i
                count = count + 1;
                A_square(i,j) = A_flat(count);
            end
        end
    end
    
    A = A_square + A_square.';
    %Set Diagonal to 0
    n=size(A,1);
    A(1:n+1:n*n)=0;
    
    %Calculate
    [M, Q] = community_louvain(A,gamma,'','negative_asym');
    
     %Append Q metric     
     FC_community =[FC_community; Q];
    
    %Append partition
     FC_M=[FC_M; M'];
end
save(fullfile(outputs_dir, mod_mat_filename),'FC_community');

%% SAVE
young_subs_files_size = size(young_subs_files);
young_subs_n = cast(young_subs_files_size(1) / 2,'uint8');
young_subs = zeros(young_subs_n,1);
for s=1:young_subs_n
    filename = strsplit(young_subs_files(s),'/');
    filename_end = filename(end);
    young_subs_str = extractBetween(filename_end,1,4);
    young_subs(s) = str2num(young_subs_str);
end
old_subs_files_size = size(old_subs_files);
old_subs_n = cast(old_subs_files_size(1) / 2,'uint8');
old_subs = zeros(old_subs_n,1);
for s=1:old_subs_n
    filename = strsplit(old_subs_files(s),'/');
    filename_end = filename(end);
    old_subs_str = extractBetween(filename_end,1,4);
    old_subs(s) = str2num(old_subs_str);
end

mod_table = table(FC_community);
mod_table.modularity = mod_table.FC_community;
mod_table = removevars(mod_table,'FC_community');
mod_table.sub = cat(1,young_subs,young_subs,old_subs,old_subs);

age = strings(young_subs_n*2 + old_subs_n*2,1);
sleep = strings(young_subs_n*2 + old_subs_n*2,1);
for i=1:young_subs_n
    age(i) = 'young';
    sleep(i) = 'deprived';
end
for i=young_subs_n+1:young_subs_n*2
    age(i) = 'young';
    sleep(i) = 'normal';
end
for i=young_subs_n*2+1:young_subs_n*2+old_subs_n
    age(i) = 'old';
    sleep(i) = 'deprived';
end
for i=young_subs_n*2+old_subs_n+1:young_subs_n*2+old_subs_n*2
    age(i) = 'old';
    sleep(i) = 'normal';
end

mod_table.age = age;
mod_table.sleep = sleep;

writetable(mod_table,fullfile(outputs_dir, mod_table_filename));