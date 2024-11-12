%% FC
%%%%%%%%%%%% EDIT PATH BELOW TO PROJECT DIRECTORY (GITHUB ROOT) %%%%%%%%%%%%
project_dir = '/PATH/TO/DIR/'; %edit
%%%%%%%%%%%% EDIT PATH ABOVE TO PROJECT DIRECTORY (GITHUB ROOT) %%%%%%%%%%%%

data_dir = [project_dir 'data/data_processing'];
outputs_dir = [project_dir 'outputs/PLS/mean_centred_PLS'];

mkdir(outputs_dir);

LEiDA_dir = [project_dir 'leida-matlab-1.0/res_SleepyBrain_TVB_SchaeferTian_220/K5/subject_data]';

young_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_young_subjects_files.csv']);
old_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_old_subjects_files.csv']);

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_FC.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_FC.png';
results_filename = 'mean_centred_PLS_FC_result.mat';
usc_table_filename = 'mean_centred_PLS_FC_usc_table.csv';

young_subs_FC = [];
for s=1:length(young_subs_files)
    FC = load([data_dir '/' young_subs_files{s}]);
    young_subs_FC = [young_subs_FC; FC'];
end

old_subs_FC = [];
for s=1:length(old_subs_files)
    FC = load([data_dir '/' old_subs_files{s}]);
    old_subs_FC = [old_subs_FC; FC'];
end

%%
datamat_lst = {};
datamat_lst{1} = young_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = old_subs_FC;

num_subj = [23 19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

%%
save(fullfile(outputs_dir,results_filename),'result')

%%
load(fullfile(outputs_dir,results_filename),'result');
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
%ylim([-1,1]);

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA (Deprived)'; 'YA (Normal)'; 'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% usc table for fig in R
lv=1;
load(fullfile(outputs_dir,results_filename),'result');

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

old_deprived_usc_ci = 2 * std(result.boot_result.distrib(3,1,:));
old_normal_usc_ci = 2 * std(result.boot_result.distrib(4,1,:));

usc2 = result.boot_result.usc2;
usc_table = table(usc2(:,lv));
usc_table.usc2 = usc_table.Var1;
usc_table = removevars(usc_table,'Var1');
usc_table.sub = cat(1,young_subs,young_subs,old_subs,old_subs);
age = strings(young_subs_n*2 + old_subs_n*2,1);
sleep = strings(young_subs_n*2 + old_subs_n*2,1);
orig_usc = zeros(young_subs_n*2 + old_subs_n*2,1);
ulusc = zeros(young_subs_n*2 + old_subs_n*2,1);
llusc = zeros(young_subs_n*2 + old_subs_n*2,1);
for i=1:young_subs_n
    age(i) = 'young';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(1,lv);
    ulusc(i) = result.boot_result.ulusc(1,lv);
    llusc(i) = result.boot_result.llusc(1,lv);
end
for i=young_subs_n+1:young_subs_n*2
    age(i) = 'young';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(2,lv);
    ulusc(i) = result.boot_result.ulusc(2,lv);
    llusc(i) = result.boot_result.llusc(2,lv);
end
for i=young_subs_n*2+1:young_subs_n*2+old_subs_n
    age(i) = 'old';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(3,lv);
    ulusc(i) = result.boot_result.orig_usc(3,lv) + old_deprived_usc_ci;
    llusc(i) = result.boot_result.orig_usc(3,lv) - old_deprived_usc_ci;
end
for i=young_subs_n*2+old_subs_n+1:young_subs_n*2+old_subs_n*2
    age(i) = 'old';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(4,lv);
    ulusc(i) = result.boot_result.orig_usc(4,lv) + old_normal_usc_ci;
    llusc(i) = result.boot_result.orig_usc(4,lv) - old_normal_usc_ci;
end
usc_table.age = age;
usc_table.sleep = sleep;
usc_table.orig_usc = orig_usc;
usc_table.ulusc = ulusc;
usc_table.llusc = llusc;

writetable(usc_table,fullfile(outputs_dir, usc_table_filename));

%% Young deprived vs normal sleep
bsr_filename = 'mean_centred_PLS_young_deprived_vs_normal_lv1_bsr_2.0thresh_FC.csv';
usc_fig_filename = 'mean_centred_PLS_young_deprived_vs_normal_lv1_usc_FC.png';
results_filename = 'mean_centred_PLS_young_deprived_vs_normal_FC_result.mat';

datamat_lst = {};
datamat_lst{1} = young_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [23];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result') % not siga

%% Old deprived vs normal sleep
bsr_filename = 'mean_centred_PLS_old_deprived_vs_normal_lv1_bsr_2.0thresh_FC.csv';
usc_fig_filename = 'mean_centred_PLS_old_deprived_vs_normal_lv1_usc_FC.png';
results_filename = 'mean_centred_PLS_old_deprived_vs_normal_FC_result.mat';

%%
datamat_lst = {};
datamat_lst{1} = old_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result') % not siga

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

%% 
load(fullfile(outputs_dir,results_filename),'result')

lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Group (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% FC sex
young_female_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_young_female_subjects_files.csv']);
young_male_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_young_male_subjects_files.csv']);
old_female_subs_files = readlines([data_dir '/FC//TVBSchaeferTian220/matlab/' 'FC_old_female_subjects_files.csv']);
old_male_subs_files = readlines([data_dir '/FC//TVBSchaeferTian220/matlab/' 'FC_old_male_subjects_files.csv']);

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_FC_sex.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_FC_sex.png';
results_filename = 'mean_centred_PLS_FC_sex_result.mat';
usc_sex_table_filename = 'mean_centred_PLS_FC_sex_usc_table.csv';

young_female_subs_FC = [];
for s=1:length(young_female_subs_files)
    FC = load([data_dir '/' young_female_subs_files{s}]);
    young_female_subs_FC = [young_female_subs_FC; FC'];
end

young_male_subs_FC = [];
for s=1:length(young_male_subs_files)
    FC = load([data_dir '/' young_male_subs_files{s}]);
    young_male_subs_FC = [young_male_subs_FC; FC'];
end

old_female_subs_FC = [];
for s=1:length(old_female_subs_files)
    FC = load([data_dir '/' old_female_subs_files{s}]);
    old_female_subs_FC = [old_female_subs_FC; FC'];
end

old_male_subs_FC = [];
for s=1:length(old_male_subs_files)
    FC = load([data_dir '/' old_male_subs_files{s}]);
    old_male_subs_FC = [old_male_subs_FC; FC'];
end

%%
datamat_lst{1} = young_female_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = young_male_subs_FC;
datamat_lst{3} = old_female_subs_FC;
datamat_lst{4} = old_male_subs_FC;

num_subj = [11 12 9 10];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.9 0.3 0.5;0.4 0.7 0.9;0.5 0.8 1.0];
data = result.boot_result.orig_usc(:,lv) * -1; %flipping sign and will flip bsr sign for consistency with other figures
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
bar(x(5:6), data(5:6),'FaceColor',barColors(3,:));
bar(x(7:8), data(7:8),'FaceColor',barColors(4,:));
%ylim([-1,1]);

lower=-1* (result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv));
upper=-1* (result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv));
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA Female (Deprived)'; 'YA Female (Normal)';'YA Male (Deprived)'; 'YA Male (Normal)'; 'OA Female (Deprived)'; 'OA Female (Normal)'; 'OA Male (Deprived)'; 'OA Male (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% usc table for fig in R
lv=1;
load(fullfile(outputs_dir,results_filename),'result');

young_female_subs_files_size = size(young_female_subs_files);
young_female_subs_n = cast(young_female_subs_files_size(1) / 2,'uint8');
young_female_subs = zeros(young_female_subs_n,1);
for s=1:young_female_subs_n
    filename = strsplit(young_female_subs_files(s),'/');
    filename_end = filename(end);
    young_female_subs_str = extractBetween(filename_end,1,4);
    young_female_subs(s) = str2num(young_female_subs_str);
end
young_male_subs_files_size = size(young_male_subs_files);
young_male_subs_n = cast(young_male_subs_files_size(1) / 2,'uint8');
young_male_subs = zeros(young_male_subs_n,1);
for s=1:young_male_subs_n
    filename = strsplit(young_male_subs_files(s),'/');
    filename_end = filename(end);
    young_male_subs_str = extractBetween(filename_end,1,4);
    young_male_subs(s) = str2num(young_male_subs_str);
end

old_female_subs_files_size = size(old_female_subs_files);
old_female_subs_n = cast(old_female_subs_files_size(1) / 2,'uint8');
old_female_subs = zeros(old_female_subs_n,1);
for s=1:old_female_subs_n
    filename = strsplit(old_female_subs_files(s),'/');
    filename_end = filename(end);
    old_female_subs_str = extractBetween(filename_end,1,4);
    old_female_subs(s) = str2num(old_female_subs_str);
end
old_male_subs_files_size = size(old_male_subs_files);
old_male_subs_n = cast(old_male_subs_files_size(1) / 2,'uint8');
old_male_subs = zeros(old_male_subs_n,1);
for s=1:old_male_subs_n
    filename = strsplit(old_male_subs_files(s),'/');
    filename_end = filename(end);
    old_male_subs_str = extractBetween(filename_end,1,4);
    old_male_subs(s) = str2num(old_male_subs_str);
end

usc2 = result.boot_result.usc2;
usc_table = table(usc2(:,lv));
usc_table.usc2 = usc_table.Var1;
usc_table = removevars(usc_table,'Var1');
usc_table.sub = cat(1,young_female_subs,young_female_subs,young_male_subs,young_male_subs,old_female_subs,old_female_subs,old_male_subs,old_male_subs);
total_scans = young_female_subs_n*2 + young_male_subs_n*2 + old_female_subs_n*2 + old_male_subs_n*2;
age = strings(total_scans,1);
sex = strings(total_scans,1);
sleep = strings(total_scans,1);
orig_usc = zeros(total_scans,1);
ulusc = zeros(total_scans,1);
llusc = zeros(total_scans,1);
count = 0;
for i=1:young_female_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'female';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(1,lv);
    ulusc(count) = result.boot_result.ulusc(1,lv);
    llusc(count) = result.boot_result.llusc(1,lv);
end
for i=1:young_female_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'female';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(2,lv);
    ulusc(count) = result.boot_result.ulusc(2,lv);
    llusc(count) = result.boot_result.llusc(2,lv);
end
for i=1:young_male_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'male';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(3,lv);
    ulusc(count) = result.boot_result.ulusc(3,lv);
    llusc(count) = result.boot_result.llusc(3,lv);
end
for i=1:young_male_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'male';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(4,lv);
    ulusc(count) = result.boot_result.ulusc(4,lv);
    llusc(count) = result.boot_result.llusc(4,lv);
end

for i=1:old_female_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'female';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(5,lv);
    ulusc(count) = result.boot_result.ulusc(5,lv);
    llusc(count) = result.boot_result.llusc(5,lv);
end
for i=1:old_female_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'female';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(6,lv);
    ulusc(count) = result.boot_result.ulusc(6,lv);
    llusc(count) = result.boot_result.llusc(6,lv);
end
for i=1:old_male_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'male';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(7,lv);
    ulusc(count) = result.boot_result.ulusc(7,lv);
    llusc(count) = result.boot_result.llusc(7,lv);
end
for i=1:old_male_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'male';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(8,lv);
    ulusc(count) = result.boot_result.ulusc(8,lv);
    llusc(count) = result.boot_result.llusc(8,lv);
end

usc_table.age = age;
usc_table.sex = sex;
usc_table.sleep = sleep;
usc_table.orig_usc = orig_usc;
usc_table.ulusc = ulusc;
usc_table.llusc = llusc;

writetable(usc_table,fullfile(outputs_dir, usc_sex_table_filename));

%% Degree
young_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_degree_young_subjects_files.csv']);
old_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_degree_old_subjects_files.csv']);

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_FC_degree.png';
usc_table_filename = 'mean_centred_PLS_lv1_usc_table_FC_degree.csv';
results_filename = 'mean_centred_PLS_FC_degree_result.mat';

young_subs_FC = [];
for s=1:length(young_subs_files)
    FC = load([data_dir '/' young_subs_files{s}]);
    young_subs_FC = [young_subs_FC; FC'];
end

old_subs_FC = [];
for s=1:length(old_subs_files)
    FC = load([data_dir '/' old_subs_files{s}]);
    old_subs_FC = [old_subs_FC; FC'];
end

%%
datamat_lst{1} = young_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = old_subs_FC;

num_subj = [23 19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
load(fullfile(outputs_dir,results_filename),'result');
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);
bsr_nothresh_filename = 'mean_centred_PLS_lv1_bsr_nothresh_FC_degree.csv';
csvwrite(fullfile(outputs_dir, bsr_nothresh_filename),bsr);


%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
%ylim([-1,1]);

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA (Deprived)'; 'YA (Normal)'; 'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% usc table for fig in R
lv=1;
load(fullfile(outputs_dir,results_filename),'result');

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

usc2 = result.boot_result.usc2;
usc_table = table(usc2(:,lv));
usc_table.usc2 = usc_table.Var1;
usc_table = removevars(usc_table,'Var1');
usc_table.sub = cat(1,young_subs,young_subs,old_subs,old_subs);
age = strings(young_subs_n*2 + old_subs_n*2,1);
sleep = strings(young_subs_n*2 + old_subs_n*2,1);
orig_usc = zeros(young_subs_n*2 + old_subs_n*2,1);
ulusc = zeros(young_subs_n*2 + old_subs_n*2,1);
llusc = zeros(young_subs_n*2 + old_subs_n*2,1);
for i=1:young_subs_n
    age(i) = 'young';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(1,lv);
    ulusc(i) = result.boot_result.ulusc(1,lv);
    llusc(i) = result.boot_result.llusc(1,lv);
end
for i=young_subs_n+1:young_subs_n*2
    age(i) = 'young';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(2,lv);
    ulusc(i) = result.boot_result.ulusc(2,lv);
    llusc(i) = result.boot_result.llusc(2,lv);
end
for i=young_subs_n*2+1:young_subs_n*2+old_subs_n
    age(i) = 'old';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(3,lv);
    ulusc(i) = result.boot_result.ulusc(3,lv);
    llusc(i) = result.boot_result.llusc(3,lv);
end
for i=young_subs_n*2+old_subs_n+1:young_subs_n*2+old_subs_n*2
    age(i) = 'old';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(4,lv);
    ulusc(i) = result.boot_result.ulusc(4,lv);
    llusc(i) = result.boot_result.llusc(4,lv);
end
usc_table.age = age;
usc_table.sleep = sleep;
usc_table.orig_usc = orig_usc;
usc_table.ulusc = ulusc;
usc_table.llusc = llusc;

writetable(usc_table,fullfile(outputs_dir, usc_table_filename));

%% Young deprived vs. normal sleep
bsr_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_FC_degree.csv';
usc_fig_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_lv1_usc_FC_degree.png';
results_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_FC_degree_result.mat';

datamat_lst = {};
datamat_lst{1} = young_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [23];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%% Old deprived vs. normal sleep
bsr_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_FC_degree.csv';
usc_fig_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_usc_FC_degree.png';
results_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_FC_degree_result.mat';

%%
datamat_lst = {};
datamat_lst{1} = old_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%% 
load(fullfile(outputs_dir,results_filename),'result')

lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Group (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% Degree sex
young_female_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_degree_young_female_subjects_files.csv']);
young_male_subs_files = readlines([data_dir '/FC/TVBSchaeferTian220/matlab/' 'FC_degree_young_male_subjects_files.csv']);
old_female_subs_files = readlines([data_dir '/FC//TVBSchaeferTian220/matlab/' 'FC_degree_old_female_subjects_files.csv']);
old_male_subs_files = readlines([data_dir '/FC//TVBSchaeferTian220/matlab/' 'FC_degree_old_male_subjects_files.csv']);

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_FC_degree_sex.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_FC_degree_sex.png';
usc_sex_table_filename = 'mean_centred_PLS_FC_degree_sex_usc_table.csv';
results_filename = 'mean_centred_PLS_FC_degree_sex_result.mat';

young_female_subs_FC = [];
for s=1:length(young_female_subs_files)
    FC = load([data_dir '/' young_female_subs_files{s}]);
    young_female_subs_FC = [young_female_subs_FC; FC'];
end

young_male_subs_FC = [];
for s=1:length(young_male_subs_files)
    FC = load([data_dir '/' young_male_subs_files{s}]);
    young_male_subs_FC = [young_male_subs_FC; FC'];
end

old_female_subs_FC = [];
for s=1:length(old_female_subs_files)
    FC = load([data_dir '/' old_female_subs_files{s}]);
    old_female_subs_FC = [old_female_subs_FC; FC'];
end

old_male_subs_FC = [];
for s=1:length(old_male_subs_files)
    FC = load([data_dir '/' old_male_subs_files{s}]);
    old_male_subs_FC = [old_male_subs_FC; FC'];
end

%%
datamat_lst{1} = young_female_subs_FC; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = young_male_subs_FC;
datamat_lst{3} = old_female_subs_FC;
datamat_lst{4} = old_male_subs_FC;

num_subj = [11 12 9 10];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);
bsr_nothresh_filename = 'mean_centred_PLS_lv1_bsr_nothresh_FC_degree_sex.csv';
csvwrite(fullfile(outputs_dir, bsr_nothresh_filename),bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.9 0.3 0.5;0.4 0.7 0.9;0.5 0.8 1.0];
data = result.boot_result.orig_usc(:,lv) * -1; %flipping sign and will flip bsr sign for consistency with other figures
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
bar(x(5:6), data(5:6),'FaceColor',barColors(3,:));
bar(x(7:8), data(7:8),'FaceColor',barColors(4,:));
%ylim([-1,1]);

lower=-1* (result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv));
upper=-1* (result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv));
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA Female (Deprived)'; 'YA Female (Normal)';'YA Male (Deprived)'; 'YA Male (Normal)'; 'OA Female (Deprived)'; 'OA Female (Normal)'; 'OA Male (Deprived)'; 'OA Male (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% usc table for fig in R
lv=1;
load(fullfile(outputs_dir,results_filename),'result');

young_female_subs_files_size = size(young_female_subs_files);
young_female_subs_n = cast(young_female_subs_files_size(1) / 2,'uint8');
young_female_subs = zeros(young_female_subs_n,1);
for s=1:young_female_subs_n
    filename = strsplit(young_female_subs_files(s),'/');
    filename_end = filename(end);
    young_female_subs_str = extractBetween(filename_end,1,4);
    young_female_subs(s) = str2num(young_female_subs_str);
end
young_male_subs_files_size = size(young_male_subs_files);
young_male_subs_n = cast(young_male_subs_files_size(1) / 2,'uint8');
young_male_subs = zeros(young_male_subs_n,1);
for s=1:young_male_subs_n
    filename = strsplit(young_male_subs_files(s),'/');
    filename_end = filename(end);
    young_male_subs_str = extractBetween(filename_end,1,4);
    young_male_subs(s) = str2num(young_male_subs_str);
end

old_female_subs_files_size = size(old_female_subs_files);
old_female_subs_n = cast(old_female_subs_files_size(1) / 2,'uint8');
old_female_subs = zeros(old_female_subs_n,1);
for s=1:old_female_subs_n
    filename = strsplit(old_female_subs_files(s),'/');
    filename_end = filename(end);
    old_female_subs_str = extractBetween(filename_end,1,4);
    old_female_subs(s) = str2num(old_female_subs_str);
end
old_male_subs_files_size = size(old_male_subs_files);
old_male_subs_n = cast(old_male_subs_files_size(1) / 2,'uint8');
old_male_subs = zeros(old_male_subs_n,1);
for s=1:old_male_subs_n
    filename = strsplit(old_male_subs_files(s),'/');
    filename_end = filename(end);
    old_male_subs_str = extractBetween(filename_end,1,4);
    old_male_subs(s) = str2num(old_male_subs_str);
end

usc2 = result.boot_result.usc2;
usc_table = table(usc2(:,lv));
usc_table.usc2 = usc_table.Var1;
usc_table = removevars(usc_table,'Var1');
usc_table.sub = cat(1,young_female_subs,young_female_subs,young_male_subs,young_male_subs,old_female_subs,old_female_subs,old_male_subs,old_male_subs);
total_scans = young_female_subs_n*2 + young_male_subs_n*2 + old_female_subs_n*2 + old_male_subs_n*2;
age = strings(total_scans,1);
sex = strings(total_scans,1);
sleep = strings(total_scans,1);
orig_usc = zeros(total_scans,1);
ulusc = zeros(total_scans,1);
llusc = zeros(total_scans,1);
count = 0;
for i=1:young_female_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'female';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(1,lv);
    ulusc(count) = result.boot_result.ulusc(1,lv);
    llusc(count) = result.boot_result.llusc(1,lv);
end
for i=1:young_female_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'female';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(2,lv);
    ulusc(count) = result.boot_result.ulusc(2,lv);
    llusc(count) = result.boot_result.llusc(2,lv);
end
for i=1:young_male_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'male';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(3,lv);
    ulusc(count) = result.boot_result.ulusc(3,lv);
    llusc(count) = result.boot_result.llusc(3,lv);
end
for i=1:young_male_subs_n
    count = count + 1;
    age(count) = 'young';
    sex(count) = 'male';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(4,lv);
    ulusc(count) = result.boot_result.ulusc(4,lv);
    llusc(count) = result.boot_result.llusc(4,lv);
end

for i=1:old_female_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'female';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(5,lv);
    ulusc(count) = result.boot_result.ulusc(5,lv);
    llusc(count) = result.boot_result.llusc(5,lv);
end
for i=1:old_female_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'female';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(6,lv);
    ulusc(count) = result.boot_result.ulusc(6,lv);
    llusc(count) = result.boot_result.llusc(6,lv);
end
for i=1:old_male_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'male';
    sleep(count) = 'deprived';
    orig_usc(count) = result.boot_result.orig_usc(7,lv);
    ulusc(count) = result.boot_result.ulusc(7,lv);
    llusc(count) = result.boot_result.llusc(7,lv);
end
for i=1:old_male_subs_n
    count = count + 1;
    age(count) = 'old';
    sex(count) = 'male';
    sleep(count) = 'normal';
    orig_usc(count) = result.boot_result.orig_usc(8,lv);
    ulusc(count) = result.boot_result.ulusc(8,lv);
    llusc(count) = result.boot_result.llusc(8,lv);
end

usc_table.age = age;
usc_table.sex = sex;
usc_table.sleep = sleep;
usc_table.orig_usc = orig_usc;
usc_table.ulusc = ulusc;
usc_table.llusc = llusc;

writetable(usc_table,fullfile(outputs_dir, usc_sex_table_filename));

%% LEiDA FO
young_subs_files = readlines([LEiDA_dir '/K5_FO_YA_files.txt'],"EmptyLineRule","skip");
old_subs_files = readlines([LEiDA_dir '/K5_FO_OA_files.txt'],"EmptyLineRule","skip");

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_leida_FO.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_leida_FO.png';
usc_table_filename = 'mean_centred_PLS_lv1_usc_table_leida_FO.csv';
results_filename = 'mean_centred_PLS_leida_FO_result.mat';

young_subs_FO = [];
for s=1:length(young_subs_files)
    FO = load([young_subs_files{s}]);
    young_subs_FO = [young_subs_FO; FO];
end

old_subs_FO = [];
for s=1:length(old_subs_files)
    FO = load([old_subs_files{s}]);
    old_subs_FO = [old_subs_FO; FO];
end

%%
datamat_lst{1} = young_subs_FO; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = old_subs_FO;

num_subj = [23 19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
%sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

%sig_bsr = zeros(size(bsr));
%sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
%ylim([-1,1]);

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA (Deprived)'; 'YA (Normal)'; 'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% usc table for fig in R
lv=1;
load(fullfile(outputs_dir,results_filename),'result');

young_subs_files_size = size(young_subs_files);
young_subs_n = cast(young_subs_files_size(1) / 2,'uint8');
young_subs = zeros(young_subs_n,1);
for s=1:young_subs_n
    filename = strsplit(young_subs_files(s),'/');
    filename_end = filename(end);
    young_subs_str = extractBetween(filename_end,7,10);
    young_subs(s) = str2num(young_subs_str);
end
old_subs_files_size = size(old_subs_files);
old_subs_n = cast(old_subs_files_size(1) / 2,'uint8');
old_subs = zeros(old_subs_n,1);
for s=1:old_subs_n
    filename = strsplit(old_subs_files(s),'/');
    filename_end = filename(end);
    old_subs_str = extractBetween(filename_end,7,10);
    old_subs(s) = str2num(old_subs_str);
end

usc2 = result.boot_result.usc2;
usc_table = table(usc2(:,lv));
usc_table.usc2 = usc_table.Var1;
usc_table = removevars(usc_table,'Var1');
usc_table.sub = cat(1,young_subs,young_subs,old_subs,old_subs);
age = strings(young_subs_n*2 + old_subs_n*2,1);
sleep = strings(young_subs_n*2 + old_subs_n*2,1);
orig_usc = zeros(young_subs_n*2 + old_subs_n*2,1);
ulusc = zeros(young_subs_n*2 + old_subs_n*2,1);
llusc = zeros(young_subs_n*2 + old_subs_n*2,1);
FO_global = zeros(young_subs_n*2 + old_subs_n*2,1);
for i=1:young_subs_n
    age(i) = 'young';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(1,lv);
    ulusc(i) = result.boot_result.ulusc(1,lv);
    llusc(i) = result.boot_result.llusc(1,lv);
    FO_global(i) = young_subs_FO(i,1);
end
for i=young_subs_n+1:young_subs_n*2
    age(i) = 'young';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(2,lv);
    ulusc(i) = result.boot_result.ulusc(2,lv);
    llusc(i) = result.boot_result.llusc(2,lv);
    FO_global(i) = young_subs_FO(i,1);
end
for i=young_subs_n*2+1:young_subs_n*2+old_subs_n
    age(i) = 'old';
    sleep(i) = 'deprived';
    orig_usc(i) = result.boot_result.orig_usc(3,lv);
    ulusc(i) = result.boot_result.ulusc(3,lv);
    llusc(i) = result.boot_result.llusc(3,lv);
    j = i - young_subs_n*2
    FO_global(i) = old_subs_FO(j,1);
end
for i=young_subs_n*2+old_subs_n+1:young_subs_n*2+old_subs_n*2
    age(i) = 'old';
    sleep(i) = 'normal';
    orig_usc(i) = result.boot_result.orig_usc(4,lv);
    ulusc(i) = result.boot_result.ulusc(4,lv);
    llusc(i) = result.boot_result.llusc(4,lv);
    j = i - young_subs_n*2;
    FO_global(i) = old_subs_FO(j,1);
end
usc_table.age = age;
usc_table.sleep = sleep;
usc_table.orig_usc = orig_usc;
usc_table.ulusc = ulusc;
usc_table.llusc = llusc;
usc_table.FO_global = FO_global;

writetable(usc_table,fullfile(outputs_dir, usc_table_filename));

%% mean figure global coherence state
mean_fig_name = 'leida_global_coherence_state_FO_group_cond_means.png';

young_subs_deprived_FO_mean = mean(young_subs_FO(1:23,:));
young_subs_normal_FO_mean = mean(young_subs_FO(24:46,:));
old_subs_deprived_FO_mean = mean(old_subs_FO(1:19,:));
old_subs_normal_FO_mean = mean(old_subs_FO(20:38,:));

fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.4 0.7 0.9];
data = [young_subs_deprived_FO_mean(1),young_subs_normal_FO_mean(1),old_subs_deprived_FO_mean(1),old_subs_normal_FO_mean(1)];
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
%ylim([-1,1]);

%lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
%upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
%er = errorbar(x,data,lower,upper);

%er.Color = [0 0 0];
%er.LineStyle = 'none';
%er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Global Coherence FO','FontWeight','bold','FontSize',axisLabelFontSize);
title('Global Coherence FO', 'FontSize',titleFontSize);

xticklabels = {'YA (Deprived)'; 'YA (Normal)'; 'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:numel(data), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, mean_fig_name), '-dpng', '-r600');

hold off

%% Young Deprived vs. Normal Sleep
bsr_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_leida_FO.csv';
usc_fig_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_lv1_usc_leida_FO.png';
results_filename = 'mean_centred_PLS_young_deprived_vs_normal_sleep_leida_FO_result.mat';

datamat_lst = {};
datamat_lst{1} = young_subs_FO; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [23];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option); % not sig p = .242

save(fullfile(outputs_dir,results_filename),'result')

%% OLD Deprived vs. Normal Sleep
bsr_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_bsr_2.0thresh_leida_FO.csv';
usc_fig_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_lv1_usc_leida_FO.png';
results_filename = 'mean_centred_PLS_old_deprived_vs_normal_sleep_leida_FO_result.mat';

%%
datamat_lst = {};
datamat_lst{1} = old_subs_FO; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
%sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

%sig_bsr = zeros(size(bsr));
%sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),bsr);

%% 
load(fullfile(outputs_dir,results_filename),'result')

lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Group (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% FO sex
young_female_subs_files = readlines([LEiDA_dir '/K5_FO_YA_female_files.txt'],"EmptyLineRule","skip");
young_male_subs_files = readlines([LEiDA_dir '/K5_FO_YA_male_files.txt'],"EmptyLineRule","skip");
old_female_subs_files = readlines([LEiDA_dir '/K5_FO_OA_female_files.txt'],"EmptyLineRule","skip");
old_male_subs_files = readlines([LEiDA_dir '/K5_FO_OA_male_files.txt'],"EmptyLineRule","skip");

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_leida_FO_sex.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_leida_FO_sex.png';
results_filename = 'mean_centred_PLS_leida_FO_sex_result.mat';

young_female_subs_FO = [];
for s=1:length(young_female_subs_files)
    FO = load([young_female_subs_files{s}]);
    young_female_subs_FO = [young_female_subs_FO; FO];
end

young_male_subs_FO = [];
for s=1:length(young_male_subs_files)
    FO = load([young_male_subs_files{s}]);
    young_male_subs_FO = [young_male_subs_FO; FO];
end

old_female_subs_FO = [];
for s=1:length(old_female_subs_files)
    FO = load([old_female_subs_files{s}]);
    old_female_subs_FO = [old_female_subs_FO; FO];
end

old_male_subs_FO = [];
for s=1:length(old_male_subs_files)
    FO = load([old_male_subs_files{s}]);
    old_male_subs_FO = [old_male_subs_FO; FO];
end

%%
datamat_lst{1} = young_female_subs_FO; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = young_male_subs_FO;
datamat_lst{3} = old_female_subs_FO;
datamat_lst{4} = old_male_subs_FO;

num_subj = [11 12 9 10];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.9 0.3 0.5;0.4 0.7 0.9;0.5 0.8 1.0];
data = result.boot_result.orig_usc(:,lv) * -1; %flipping sign and will flip bsr sign for consistency with other figures
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
bar(x(5:6), data(5:6),'FaceColor',barColors(3,:));
bar(x(7:8), data(7:8),'FaceColor',barColors(4,:));
%ylim([-1,1]);

lower=-1* (result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv));
upper=-1* (result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv));
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA Female (Deprived)'; 'YA Female (Normal)';'YA Male (Deprived)'; 'YA Male (Normal)'; 'OA Female (Deprived)'; 'OA Female (Normal)'; 'OA Male (Deprived)'; 'OA Male (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%% LEiDA TM
young_subs_files = readlines([LEiDA_dir '/K5_TM_YA_files.txt'],"EmptyLineRule","skip");
old_subs_files = readlines([LEiDA_dir '/K5_TM_OA_files.txt'],"EmptyLineRule","skip");

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_leida_TM.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_leida_TM.png';
results_filename = 'mean_centred_PLS_leida_TM_result.mat';

young_subs_TM = [];
for s=1:length(young_subs_files)
    TM = load([young_subs_files{s}]);
    young_subs_TM = [young_subs_TM; TM];
end

old_subs_TM = [];
for s=1:length(old_subs_files)
    TM = load([old_subs_files{s}]);
    old_subs_TM = [old_subs_TM; TM];
end

%%
datamat_lst{1} = young_subs_TM; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = old_subs_TM;

num_subj = [23 19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
%sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

%sig_bsr = zeros(size(bsr));
%sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.4 0.7 0.9];
data = result.boot_result.orig_usc(:,lv);
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
%ylim([-1,1]);

lower=result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv);
upper=result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv);
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA (Deprived)'; 'YA (Normal)'; 'OA (Deprived)'; 'OA (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off

%%
bsr_filename = 'mean_centred_PLS_old_deprived_vs_normal_lv1_bsr_2.0thresh_leida_TM.csv';
usc_fig_filename = 'mean_centred_PLS_old_deprived_vs_normal_lv1_usc_leida_TM.png';
results_filename = 'mean_centred_PLS_old_deprived_vs_normal_leida_TM_result.mat';

datamat_lst = {};
datamat_lst{1} = old_subs_TM; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)

num_subj = [19];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);
save(fullfile(outputs_dir,results_filename),'result')

%% TM sex
young_female_subs_files = readlines([LEiDA_dir '/K5_TM_YA_female_files.txt'],"EmptyLineRule","skip");
young_male_subs_files = readlines([LEiDA_dir '/K5_TM_YA_male_files.txt'],"EmptyLineRule","skip");
old_female_subs_files = readlines([LEiDA_dir '/K5_TM_OA_female_files.txt'],"EmptyLineRule","skip");
old_male_subs_files = readlines([LEiDA_dir '/K5_TM_OA_male_files.txt'],"EmptyLineRule","skip");

bsr_filename = 'mean_centred_PLS_lv1_bsr_2.0thresh_leida_TM_sex.csv';
usc_fig_filename = 'mean_centred_PLS_lv1_usc_leida_TM_sex.png';
results_filename = 'mean_centred_PLS_leida_TM_sex_result.mat';

young_female_subs_TM = [];
for s=1:length(young_female_subs_files)
    TM = load([young_female_subs_files{s}]);
    young_female_subs_TM = [young_female_subs_TM; TM];
end

young_male_subs_TM = [];
for s=1:length(young_male_subs_files)
    TM = load([young_male_subs_files{s}]);
    young_male_subs_TM = [young_male_subs_TM; TM];
end

old_female_subs_TM = [];
for s=1:length(old_female_subs_files)
    TM = load([old_female_subs_files{s}]);
    old_female_subs_TM = [old_female_subs_TM; TM];
end

old_male_subs_TM = [];
for s=1:length(old_male_subs_files)
    TM = load([old_male_subs_files{s}]);
    old_male_subs_TM = [old_male_subs_TM; TM];
end

%%
datamat_lst{1} = young_female_subs_TM; %this should have deprived and normal sleep conditions concatenated (all subs deprived then all subs normal)
datamat_lst{2} = young_male_subs_TM;
datamat_lst{3} = old_female_subs_TM;
datamat_lst{4} = old_male_subs_TM;

num_subj = [11 12 9 10];
num_cond = 2;
option.method = 1;
option.num_boot = 1000;
option.num_perm = 1000;
option.meancentering_type = 0;

result = pls_analysis(datamat_lst, num_subj, num_cond, option);

save(fullfile(outputs_dir,results_filename),'result')

%%
lv=1;
thresh=2;
bsr = result.boot_result.compare_u(:,lv);
sig_bsr_idx = bsr > thresh | bsr < (-1*thresh);

sig_bsr = zeros(size(bsr));
sig_bsr(sig_bsr_idx) = bsr(sig_bsr_idx);

csvwrite(fullfile(outputs_dir, bsr_filename),sig_bsr);

%%
fig = figure('Units','inches','Position',[0,0,10,10]);
barColors = [0.8 0.2 0.4;0.9 0.3 0.5;0.4 0.7 0.9;0.5 0.8 1.0];
data = result.boot_result.orig_usc(:,lv) * -1; %flipping sign and will flip bsr sign for consistency with other figures
x = 1:numel(data);
bar(x(1:2), data(1:2),'FaceColor',barColors(1,:));
hold on;
bar(x(3:4),data(3:4),'FaceColor',barColors(2,:));
bar(x(5:6), data(5:6),'FaceColor',barColors(3,:));
bar(x(7:8), data(7:8),'FaceColor',barColors(4,:));
%ylim([-1,1]);

lower=-1* (result.boot_result.orig_usc(:,lv) - result.boot_result.llusc(:,lv));
upper=-1* (result.boot_result.ulusc(:,lv) - result.boot_result.orig_usc(:,lv));
er = errorbar(x,data,lower,upper);

er.Color = [0 0 0];
er.LineStyle = 'none';
er.LineWidth = 0.2;

axisLabelFontSize = 12;
titleFontSize = 7;
xlabel('Groups (Conditions)','FontWeight','bold','FontSize',axisLabelFontSize);
ylabel('Brain Score','FontWeight','bold','FontSize',axisLabelFontSize);
title(['LV=' num2str(lv) ', p=' num2str(result.perm_result.sprob(lv))], 'FontSize',titleFontSize);

xticklabels = {'YA Female (Deprived)'; 'YA Female (Normal)';'YA Male (Deprived)'; 'YA Male (Normal)'; 'OA Female (Deprived)'; 'OA Female (Normal)'; 'OA Male (Deprived)'; 'OA Male (Normal)'};
set(gca, 'XTick', 1:size(result.v(:,lv),1), 'XTickLabel', xticklabels, 'FontSize', axisLabelFontSize, 'LineWidth', 0.3);

print(fullfile(outputs_dir, usc_fig_filename), '-dpng', '-r600');

hold off