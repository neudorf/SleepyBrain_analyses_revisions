library(lme4)
library(ggplot2)
library(effects)
library(tidyverse)
library(here)

mod_file = here('outputs/modularity/sleepybrain_modularity.csv')
mod_df = read.csv(mod_file,sep=',')
mod_df$sub = factor(mod_df$sub)
mod_df$age = factor(mod_df$age, levels = c('young','old'))
mod_df$sleep = factor(mod_df$sleep, levels = c('normal','deprived'))
mod_df$Q = as.numeric(mod_df$modularity)

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

attention_df = read.csv(here('data/participants.tsv'),sep='\t')
attention_df$sub = factor(substr(attention_df$participant_id, 5,8))
attention_df$BADD_Attention = as.numeric(attention_df$BADD_Attention)
attention_df$sex = factor(attention_df$Sex, levels = c('Female','Male'))

mod_sex_df = merge(attention_df,mod_df)

lm2 = lmer(Q ~ sleep*age + sex + (1|sub), mod_sex_df)
summary(lm2)

attention_df = attention_df[,c('sub','BADD_Attention')]

attention_df = merge(attention_df,mod_df)
attention_df = na.omit(attention_df)

lm3 = lmer(Q ~ sleep*age + BADD_Attention + (1|sub), attention_df)
summary(lm3)