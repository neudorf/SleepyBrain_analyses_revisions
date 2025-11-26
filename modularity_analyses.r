library(lme4)
library(ggplot2)
library(effects)
library(tidyverse)
library(here)

#mod_file = here('outputs/modularity/sleepybrain_modularity.csv') #REPLACE FOR GITHUB
mod_file = ('/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/modularity/sleepybrain_modularity.csv') #REMOVE FOR GITHUB
mod_df = read.csv(mod_file,sep=',')
mod_df$sub = factor(mod_df$sub)
mod_df$age = factor(mod_df$age, levels = c('young','old'))
mod_df$sleep = factor(mod_df$sleep, levels = c('normal','deprived'))
mod_df$Q = as.numeric(mod_df$Q)

lm = lmer(Q ~ sleep*age + (1|sub), mod_df)
summary(lm)

plot(effect("sleep*age",lm))

cols = c('#444444','#2AA198','#D33682')
pdf(here("outputs/modularity/Q.pdf"), height = 6, width = 6) 
par(mar = c(4, 5, 1, 2))
plot(1, frame.plot = F, xlim = c(0, 1), ylim = c(.15,.30), xlab = "", ylab = "Modularity (Q)", xaxt = "n", type = "n")
axis(1, at = c(0.05, 0.95), labels = c("Normal Sleep", "Restricted Sleep"))
lines(x = c(0, 0.9), y = effect("sleep*age", lm)$fit[1:2], pch = 16, col = cols[3], type = "b", lwd = 1.5)
lines(x = c(0.1, 1), y = effect("sleep*age", lm)$fit[3:4], pch = 16, col = cols[2], type = "b", lwd = 1.5)
lines(x = c(0, 0), y = c(effect("sleep*age", lm)$lower[1], effect("sleep*age", lm)$upper[1]), col = cols[3], lwd = 1.5)
lines(x = c(0.9, 0.9), y = c(effect("sleep*age", lm)$lower[2], effect("sleep*age", lm)$upper[2]), col = cols[3], lwd = 1.5)
lines(x = c(0.1, 0.1), y = c(effect("sleep*age", lm)$lower[3], effect("sleep*age", lm)$upper[3]), col = cols[2], lwd = 1.5)
lines(x = c(1, 1), y = c(effect("sleep*age", lm)$lower[4], effect("sleep*age", lm)$upper[4]), col = cols[2], lwd = 1.5)
legend("topleft", lty = 1, lwd = 1.5, pch = 16, col = cols[3:2], legend = c("Young", "Old"), bty = "n")
dev.off()

lm2 = lmer(Q ~ sleep*age + (1|sleep), mod_df)
summary(lm2) # does not converge

lm3 = lmer(Q ~ sleep*age + (1|sub) + (1|sleep), mod_df)
summary(lm3) # does not converge

QC_file = ('/media/WDBlue/mcintosh/data/SleepyBrain/SleepyBrain_ref_image_fix/QC_220/motion.csv')
QC_df = read.csv(QC_file,sep=',')
QC_df$sub = factor(QC_df$subject)
mod_motion_df = merge(mod_df,QC_df,on=c('sub','sleep'))
mod_motion_df$sub = factor(mod_motion_df$sub)
mod_motion_df$age = factor(mod_motion_df$age, levels = c('young','old'))
mod_motion_df$sleep = factor(mod_motion_df$sleep, levels = c('normal','deprived'))
mod_motion_df$Q = as.numeric(mod_motion_df$Q)
mod_motion_df$motion = as.numeric(mod_motion_df$motion)

lm4 = lmer(Q ~ sleep*age + motion + (1|sub), mod_motion_df)
summary(lm4)


plot(effect("sleep*age",lm4))

cols = c('#444444','#2AA198','#D33682')
pdf("/media/WDBlue/mcintosh/projects/SleepyBrain/rsfMRI_sleep_deprivation_FAIR_revisions/SleepyBrain_analyses_revisions/outputs/modularity/Q_motion.pdf", height = 6, width = 6) 
par(mar = c(4, 5, 1, 2))
plot(1, frame.plot = F, xlim = c(0, 1), ylim = c(.15,.30), xlab = "", ylab = "Modularity (Q)", xaxt = "n", type = "n")
axis(1, at = c(0.05, 0.95), labels = c("Normal Sleep", "Restricted Sleep"))
lines(x = c(0, 0.9), y = effect("sleep*age", lm4)$fit[1:2], pch = 16, col = cols[3], type = "b", lwd = 1.5)
lines(x = c(0.1, 1), y = effect("sleep*age", lm4)$fit[3:4], pch = 16, col = cols[2], type = "b", lwd = 1.5)
lines(x = c(0, 0), y = c(effect("sleep*age", lm4)$lower[1], effect("sleep*age", lm4)$upper[1]), col = cols[3], lwd = 1.5)
lines(x = c(0.9, 0.9), y = c(effect("sleep*age", lm4)$lower[2], effect("sleep*age", lm4)$upper[2]), col = cols[3], lwd = 1.5)
lines(x = c(0.1, 0.1), y = c(effect("sleep*age", lm4)$lower[3], effect("sleep*age", lm4)$upper[3]), col = cols[2], lwd = 1.5)
lines(x = c(1, 1), y = c(effect("sleep*age", lm4)$lower[4], effect("sleep*age", lm4)$upper[4]), col = cols[2], lwd = 1.5)
legend("topleft", lty = 1, lwd = 1.5, pch = 16, col = cols[3:2], legend = c("Young", "Old"), bty = "n")
dev.off()
