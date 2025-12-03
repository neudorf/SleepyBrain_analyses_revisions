library(lme4)
library(ggplot2)
library(effects)
library(tidyverse)
library(here)

#FC
FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_usc_table.csv')
FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_usc_ggplot.png')
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) , as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df[FC_usc_df$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young (Restricted)','Young (Normal)','Old (Restricted)', 'Old (Normal)'))
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2)
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc)
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc)
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc)

#just getting this for sex variable
sex_df = read.csv(here('data/participants.tsv'),sep='\t')
sex_df$sub = factor(substr(sex_df$participant_id, 5,8))
sex_df$sex = factor(sex_df$Sex, levels=c("Male","Female"))
sex_df = sex_df[,c('sub','sex')]

merged_df = merge(sex_df,FC_usc_df)

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc) ~ age + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) , as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young (Restricted)','Young (Normal)','Old (Restricted)', 'Old (Normal)'))

FC_usc_df_ci = aggregate(usc2~age+sleep,x=FC_usc_df,FUN=sd)
ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_point(data=merged_df, aes(group=cond, y = usc2, shape=sex),  colour='black',alpha=.25) +
  geom_line(data=merged_df, aes(y = usc2, group=sub,linetype=sex),alpha=.5) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + labs(linetype='Sex',shape='Sex') +
  theme_classic() +
  theme(text = element_text(size=20))
ggsave(FC_usc_plot_file)

#FC Degree
FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_FC_degree.csv')
FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_degree_usc_ggplot.png')
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) , as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df[FC_usc_df$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young (Restricted)','Young (Normal)','Old (Restricted)', 'Old (Normal)'))
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2)
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc)
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc)
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc)

merged_df = merge(sex_df,FC_usc_df)

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc) ~ age + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) , as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young (Restricted)','Young (Normal)','Old (Restricted)', 'Old (Normal)'))
FC_usc_df_ci = aggregate(usc2~age+sleep,x=FC_usc_df,FUN=sd)
ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_point(data=merged_df, aes(group=cond, y = usc2, shape=sex),  colour='black',alpha=.25) +
  geom_line(data=merged_df, aes(y = usc2, group=sub,linetype=sex),alpha=.5) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + labs(linetype='Sex',shape='Sex') +
  theme_classic() +
  theme(text = element_text(size=20))
ggsave(FC_usc_plot_file)

#LEiDA FO
# REPLACE following 3 lines for GITHUB
# FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_FO.csv')
# FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_FO_ggplot.png')
# FO_mean_plot_file = here('outputs/PLS/mean_centred_PLS/leida_FO_global_ggplot.png')
FC_usc_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_FO.csv'
FC_usc_plot_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_FO_ggplot.png'
FO_mean_plot_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/leida_FO_global_ggplot.png'
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) , as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df[FC_usc_df$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2)
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc)
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc)
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc)
FC_usc_df$FO_global = as.numeric(FC_usc_df$FO_global)

#just getting this for sex variable
#sex_df = read.csv(here('data/participants.tsv'),sep='\t') #REPLACE FOR GITHUB
sex_df = read.csv('/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/data/participants.tsv',sep='\t') #REMOVE FOR GITHUB
sex_df$sub = factor(substr(sex_df$participant_id, 5,8))
sex_df$sex = factor(sex_df$Sex, levels=c("Male","Female"))
sex_df = sex_df[,c('sub','sex')]

merged_df = merge(sex_df,FC_usc_df)

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc,FO_global) ~ age + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) , as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df_ci = aggregate(FO_global~age+sleep,x=FC_usc_df,FUN=sd)
FC_usc_df_ci$cond = paste(as.character(FC_usc_df_ci$age) , as.character(FC_usc_df_ci$sleep))
FC_usc_df_ci[FC_usc_df_ci$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_ci$cond = factor(FC_usc_df_ci$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df_ci$FO_global_ul = FC_usc_df_means$FO_global + 1.96*FC_usc_df_ci$FO_global
FC_usc_df_ci$FO_global_ll = FC_usc_df_means$FO_global - 1.96*FC_usc_df_ci$FO_global
FC_usc_df_ci$FO_global = NULL

FC_usc_df_means = merge(FC_usc_df_means,FC_usc_df_ci, by=c('cond','age','sleep'))

ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_point(data=merged_df, aes(group=cond, y = usc2, shape=sex),  colour='black',alpha=.25) +
  geom_line(data=merged_df, aes(y = usc2, group=sub,linetype=sex),alpha=.5) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + labs(linetype='Sex',shape='Sex') +
  theme_classic() +
  theme(text = element_text(size=20))
ggsave(FC_usc_plot_file)

# Global FO mean plot
ggplot(FC_usc_df_means,aes(x=cond,FO_global)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  geom_errorbar(aes(ymin=FO_global_ll,ymax=FO_global_ul),width=.1) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  ylab('Global Coherence State FO') + xlab('Group (Sleep Condition)') + guides(fill = 'none') +
  theme_classic() +
  theme(text = element_text(size=20), panel.border = element_blank(), panel.grid = element_blank())+
  scale_y_continuous(expand=c(0,0)) # removes gap between 0 and y axis line

ggsave(FO_mean_plot_file)

lm1 = lmer(FO_global ~ sleep*age + (1 |sub),data=FC_usc_df)
summary(lm1)
plot(effect("sleep:age",lm1))

cols = c('#444444','#2AA198','#D33682')
pdf("/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/leida-matlab/FO_global_means.pdf", height = 6, width = 6) 
par(mar = c(4, 5, 1, 2))
plot(1, frame.plot = F, xlim = c(0, 1), ylim = c(0.25,.5), xlab = "Group (Sleep Condition)", ylab = "Global Coherence State FO", xaxt = "n", type = "n")
axis(1, at = c(0.05, 0.95), labels = c("Normal Sleep", "Restricted Sleep"))
lines(x = c(0, 0.9), y = effect("sleep*age", lm1)$fit[1:2], pch = 16, col = cols[3], type = "b", lwd = 1.5)
lines(x = c(0.1, 1), y = effect("sleep*age", lm1)$fit[3:4], pch = 16, col = cols[2], type = "b", lwd = 1.5)
lines(x = c(0, 0), y = c(effect("sleep*age", lm1)$lower[1], effect("sleep*age", lm1)$upper[1]), col = cols[3], lwd = 1.5)
lines(x = c(0.9, 0.9), y = c(effect("sleep*age", lm1)$lower[2], effect("sleep*age", lm1)$upper[2]), col = cols[3], lwd = 1.5)
lines(x = c(0.1, 0.1), y = c(effect("sleep*age", lm1)$lower[3], effect("sleep*age", lm1)$upper[3]), col = cols[2], lwd = 1.5)
lines(x = c(1, 1), y = c(effect("sleep*age", lm1)$lower[4], effect("sleep*age", lm1)$upper[4]), col = cols[2], lwd = 1.5)
legend("topleft", lty = 1, lwd = 1.5, pch = 16, col = cols[3:2], legend = c("Young", "Old"), bty = "n")
dev.off()


#FC Sex
FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_sex_usc_table.csv')
FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_sex_usc_ggplot.png')
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sex = as.factor(FC_usc_df$sex)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) ,as.character(FC_usc_df$sex), as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young female deprived','cond'] = 'Young Female (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young female normal','cond'] = 'Young Female (Normal)'
FC_usc_df[FC_usc_df$cond == 'young male deprived','cond'] = 'Young Male (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young male normal','cond'] = 'Young Male (Normal)'
FC_usc_df[FC_usc_df$cond == 'old female deprived','cond'] = 'Old Female (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old female normal','cond'] = 'Old Female (Normal)'
FC_usc_df[FC_usc_df$cond == 'old male deprived','cond'] = 'Old Male (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old male normal','cond'] = 'Old Male (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young Female (Restricted)','Young Female (Normal)', 'Young Male (Restricted)','Young Male (Normal)','Old Female (Restricted)', 'Old Female (Normal)','Old Male (Restricted)','Old Male (Normal)'))
#flipping these and I have also flipped the BSR figure values for consistency with nonsex versions of the analysis
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2) * -1
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc) * -1
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc) * -1
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc) * -1

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc) ~ age + sex + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) ,as.character(FC_usc_df_means$sex), as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young female deprived','cond'] = 'Young Female (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young female normal','cond'] = 'Young Female (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'young male deprived','cond'] = 'Young Male (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young male normal','cond'] = 'Young Male (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old female deprived','cond'] = 'Old Female (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old female normal','cond'] = 'Old Female (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old male deprived','cond'] = 'Old Male (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old male normal','cond'] = 'Old Male (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young Female (Restricted)','Young Female (Normal)', 'Young Male (Restricted)','Young Male (Normal)','Old Female (Restricted)', 'Old Female (Normal)','Old Male (Restricted)','Old Male (Normal)'))

ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#b32e6e','#b32e6e','#2aa198','#2aa198','#218078','#218078')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + 
  theme_classic() +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 45, vjust = 1,hjust=1,size=12))
ggsave(FC_usc_plot_file)

#FC Sex
FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_degree_sex_usc_table.csv')
FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_FC_degree_sex_usc_ggplot.png')
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sex = as.factor(FC_usc_df$sex)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) ,as.character(FC_usc_df$sex), as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young female deprived','cond'] = 'Young Female (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young female normal','cond'] = 'Young Female (Normal)'
FC_usc_df[FC_usc_df$cond == 'young male deprived','cond'] = 'Young Male (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young male normal','cond'] = 'Young Male (Normal)'
FC_usc_df[FC_usc_df$cond == 'old female deprived','cond'] = 'Old Female (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old female normal','cond'] = 'Old Female (Normal)'
FC_usc_df[FC_usc_df$cond == 'old male deprived','cond'] = 'Old Male (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old male normal','cond'] = 'Old Male (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young Female (Restricted)','Young Female (Normal)', 'Young Male (Restricted)','Young Male (Normal)','Old Female (Restricted)', 'Old Female (Normal)','Old Male (Restricted)','Old Male (Normal)'))
#flipping these and I have also flipped the BSR figure values for consistency with nonsex versions of the analysis
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2) * -1
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc) * -1
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc) * -1
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc) * -1

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc) ~ age + sex + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) ,as.character(FC_usc_df_means$sex), as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young female deprived','cond'] = 'Young Female (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young female normal','cond'] = 'Young Female (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'young male deprived','cond'] = 'Young Male (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young male normal','cond'] = 'Young Male (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old female deprived','cond'] = 'Old Female (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old female normal','cond'] = 'Old Female (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old male deprived','cond'] = 'Old Male (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old male normal','cond'] = 'Old Male (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young Female (Restricted)','Young Female (Normal)', 'Young Male (Restricted)','Young Male (Normal)','Old Female (Restricted)', 'Old Female (Normal)','Old Male (Restricted)','Old Male (Normal)'))

ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#b32e6e','#b32e6e','#2aa198','#2aa198','#218078','#218078')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + 
  theme_classic() +
  theme(text = element_text(size=20), axis.text.x = element_text(angle = 45, vjust = 1,hjust=1,size=12))
ggsave(FC_usc_plot_file)

#LEiDA DT
# REPLACE THESE 3 LINES FOR GITHUB
# FC_usc_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_DT.csv')
# FC_usc_plot_file = here('outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_DT_ggplot.png')
# FO_mean_plot_file = here('outputs/PLS/mean_centred_PLS/leida_DT_global_ggplot.png')
# REMOVE NEXT 3 LINES FOR GITHUB
FC_usc_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_DT.csv'
FC_usc_plot_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/mean_centred_PLS_lv1_usc_table_leida_DT_ggplot.png'
DT_mean_plot_file = '/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/PLS/mean_centred_PLS/leida_DT_global_ggplot.png'
FC_usc_df = read.csv(FC_usc_file,sep=',')
FC_usc_df$sub = as.factor(FC_usc_df$sub)
FC_usc_df$age = as.factor(FC_usc_df$age)
FC_usc_df$sleep = as.factor(FC_usc_df$sleep)
FC_usc_df$cond = paste(as.character(FC_usc_df$age) , as.character(FC_usc_df$sleep))
FC_usc_df[FC_usc_df$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df[FC_usc_df$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df[FC_usc_df$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df[FC_usc_df$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df$cond = factor(FC_usc_df$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df$usc2 = as.numeric(FC_usc_df$usc2)
FC_usc_df$orig_usc = as.numeric(FC_usc_df$orig_usc)
FC_usc_df$ulusc = as.numeric(FC_usc_df$ulusc)
FC_usc_df$llusc = as.numeric(FC_usc_df$llusc)
FC_usc_df$DT_global = as.numeric(FC_usc_df$DT_global)

#just getting this for sex variable
#sex_df = read.csv(here('data/participants.tsv'),sep='\t') #REPLACE FOR GITHUB
sex_df = read.csv('/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/data/participants.tsv',sep='\t') #REMOVE FOR GITHUB
sex_df$sub = factor(substr(sex_df$participant_id, 5,8))
sex_df$sex = factor(sex_df$Sex, levels=c("Male","Female"))
sex_df = sex_df[,c('sub','sex')]

merged_df = merge(sex_df,FC_usc_df)

# All values same, from matlab. Using mean function but equivalent to just grabbing 1 value.
FC_usc_df_means = aggregate(cbind(orig_usc,llusc,ulusc,DT_global) ~ age + sleep,x=FC_usc_df,FUN='mean')
FC_usc_df_means$cond = paste(as.character(FC_usc_df_means$age) , as.character(FC_usc_df_means$sleep))
FC_usc_df_means[FC_usc_df_means$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_means[FC_usc_df_means$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_means[FC_usc_df_means$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_means$cond = factor(FC_usc_df_means$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df_ci = aggregate(DT_global~age+sleep,x=FC_usc_df,FUN=sd)
FC_usc_df_ci$cond = paste(as.character(FC_usc_df_ci$age) , as.character(FC_usc_df_ci$sleep))
FC_usc_df_ci[FC_usc_df_ci$cond == 'young deprived','cond'] = 'Young (Restricted)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'young normal','cond'] = 'Young (Normal)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'old deprived','cond'] = 'Old (Restricted)'
FC_usc_df_ci[FC_usc_df_ci$cond == 'old normal','cond'] = 'Old (Normal)'
FC_usc_df_ci$cond = factor(FC_usc_df_ci$cond, levels=c('Young (Normal)','Young (Restricted)','Old (Normal)', 'Old (Restricted)'))
FC_usc_df_ci$DT_global_ul = FC_usc_df_means$DT_global + 1.96*FC_usc_df_ci$DT_global
FC_usc_df_ci$DT_global_ll = FC_usc_df_means$DT_global - 1.96*FC_usc_df_ci$DT_global
FC_usc_df_ci$DT_global = NULL

FC_usc_df_means = merge(FC_usc_df_means,FC_usc_df_ci, by=c('cond','age','sleep'))

ggplot(FC_usc_df_means,aes(x=cond,orig_usc)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  geom_errorbar(aes(ymin=llusc,ymax=ulusc),width=.1) +
  geom_point(data=merged_df, aes(group=cond, y = usc2, shape=sex),  colour='black',alpha=.25) +
  geom_line(data=merged_df, aes(y = usc2, group=sub,linetype=sex),alpha=.5) +
  geom_hline(yintercept=0,colour='#444444') +
  ylab('Brain Score') + xlab('Group (Sleep Condition)') + guides(fill = 'none') + labs(linetype='Sex',shape='Sex') +
  theme_classic() +
  theme(text = element_text(size=20))
ggsave(FC_usc_plot_file)

# Global FO mean plot
ggplot(FC_usc_df_means,aes(x=cond,DT_global)) + 
  geom_col(aes(fill=cond), linetype = 'solid', colour = 'black', linewidth = 0.25) +
  geom_errorbar(aes(ymin=DT_global_ll,ymax=DT_global_ul),width=.1) +
  scale_fill_manual(values=c('#d33682','#d33682','#2aa198','#2aa198')) +
  ylab('Global Coherence State FO') + xlab('Group (Sleep Condition)') + guides(fill = 'none') +
  theme_classic() +
  theme(text = element_text(size=20), panel.border = element_blank(), panel.grid = element_blank())+
  scale_y_continuous(expand=c(0,0)) # removes gap between 0 and y axis line

ggsave(DT_mean_plot_file)

lm2 = lmer(DT_global ~ sleep*age + (1 |sub),data=FC_usc_df)
summary(lm2)
plot(effect("sleep:age",lm2))

cols = c('#444444','#2AA198','#D33682')
pdf("/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/leida-matlab/DT_global_means.pdf", height = 6, width = 6) 
par(mar = c(4, 5, 1, 2))
plot(1, frame.plot = F, xlim = c(0, 1), ylim = c(8,13), xlab = "Group (Sleep Condition)", ylab = "Global Coherence State DT", xaxt = "n", type = "n")
axis(1, at = c(0.05, 0.95), labels = c("Normal Sleep", "Restricted Sleep"))
lines(x = c(0, 0.9), y = effect("sleep*age", lm2)$fit[1:2], pch = 16, col = cols[3], type = "b", lwd = 1.5)
lines(x = c(0.1, 1), y = effect("sleep*age", lm2)$fit[3:4], pch = 16, col = cols[2], type = "b", lwd = 1.5)
lines(x = c(0, 0), y = c(effect("sleep*age", lm2)$lower[1], effect("sleep*age", lm2)$upper[1]), col = cols[3], lwd = 1.5)
lines(x = c(0.9, 0.9), y = c(effect("sleep*age", lm2)$lower[2], effect("sleep*age", lm2)$upper[2]), col = cols[3], lwd = 1.5)
lines(x = c(0.1, 0.1), y = c(effect("sleep*age", lm2)$lower[3], effect("sleep*age", lm2)$upper[3]), col = cols[2], lwd = 1.5)
lines(x = c(1, 1), y = c(effect("sleep*age", lm2)$lower[4], effect("sleep*age", lm2)$upper[4]), col = cols[2], lwd = 1.5)
legend("topleft", lty = 1, lwd = 1.5, pch = 16, col = cols[3:2], legend = c("Young", "Old"), bty = "n")
dev.off()