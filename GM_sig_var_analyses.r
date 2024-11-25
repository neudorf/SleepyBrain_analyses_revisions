library(lme4)
library(ggplot2)
library(effects)
library(here)

sig_var_file = here('data/data_processing/FC/TVBSchaeferTian220/voxelwise/voxelwise_GM_sig_variability.csv')
sig_var_df = read.csv(sig_var_file,sep=',')
sig_var_df$sub = factor(sig_var_df$sub)
sig_var_df$age = factor(sig_var_df$age, levels = c('young','old'))
sig_var_df$sleep = factor(sig_var_df$sleep, levels = c('normal','deprived'))
sig_var_df$GM_sig_variability = as.numeric(sig_var_df$GM_sig_variability)
sig_var_df$framewise_displacement = as.numeric(sig_var_df$framewise_displacement)

lm = lmer(log(GM_sig_variability) ~ sleep*age + framewise_displacement + (1| sub), sig_var_df)
summary(lm)

plot(effect("sleep*age",lm))

cols = c('#444444','#2AA198','#D33682')
pdf(here("outputs/variability/GM_sig_var.pdf"), height = 6, width = 6) 
par(mar = c(4, 5, 1, 2))
plot(1, frame.plot = F, xlim = c(0, 1), ylim = c(2.8, 3.6), xlab = "", ylab = "GM signal variability (ln(SD))", xaxt = "n", type = "n")
axis(1, at = c(0.05, 0.95), labels = c("Normal Sleep", "Restricted Sleep"))
lines(x = c(0, 0.9), y = effect("sleep*age", lm)$fit[1:2], pch = 16, col = cols[3], type = "b", lwd = 1.5)
lines(x = c(0.1, 1), y = effect("sleep*age", lm)$fit[3:4], pch = 16, col = cols[2], type = "b", lwd = 1.5)
lines(x = c(0, 0), y = c(effect("sleep*age", lm)$lower[1], effect("sleep*age", lm)$upper[1]), col = cols[3], lwd = 1.5)
lines(x = c(0.9, 0.9), y = c(effect("sleep*age", lm)$lower[2], effect("sleep*age", lm)$upper[2]), col = cols[3], lwd = 1.5)
lines(x = c(0.1, 0.1), y = c(effect("sleep*age", lm)$lower[3], effect("sleep*age", lm)$upper[3]), col = cols[2], lwd = 1.5)
lines(x = c(1, 1), y = c(effect("sleep*age", lm)$lower[4], effect("sleep*age", lm)$upper[4]), col = cols[2], lwd = 1.5)
legend("topleft", lty = 1, lwd = 1.5, pch = 16, col = cols[3:2], legend = c("Young", "Old"), bty = "n")
dev.off()

#just getting this for sex variable
sex_df = read.csv(here('data/participants.tsv'),sep='\t')
sex_df$sub = factor(substr(sex_df$participant_id, 5,8))
sex_df$sex = factor(sex_df$Sex)

sex_df = sex_df[,c('sub','sex')]

merged_df = merge(sex_df,sig_var_df)

lm_sex = lmer(log(GM_sig_variability) ~ sleep*age + sex + framewise_displacement + (1| sub), merged_df)
summary(lm_sex)
