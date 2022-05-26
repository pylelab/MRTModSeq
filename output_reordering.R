#!/usr/bin/env Rscript

args=commandArgs(TRUE)
if (length(args)<1){
  cat("adenosin_predictions.arff cytidine_predictions.arff guanosine_predictions.arff uridine_predictions.arff profile.txt\n")
  cat("\nInput:\n")
  cat("    adenosin_predictions.arff          - WEKA format feature file with classifications for A\n")
  cat("    cytidine_predictions.arff          - WEKA format feature file with classifications for A\n")
  cat("    guanosine_predictions.arff         - WEKA format feature file with classifications for A\n")
  cat("    uridine_predictions.arff           - WEKA format feature file with classifications for A\n")
  cat("    profile.txt                        - profile file from ShapeMapper --counted output\n")
  cat("\nOutput:\n")
  cat("    ordered_predictions.csv  - final ordered prediction file in CSV format\n")
  quit()
}

library(dplyr, warn.conflicts = FALSE)
library(foreign)

As <- read.arff(args[1])
Cs <- read.arff(args[2])
Gs <- read.arff(args[3])
Us <- read.arff(args[4])
profile <- read.table(args[5], header = TRUE)

cumdf_adenine_nuc <- (profile %>% filter(Sequence == "A"))$Nucleotide
cumdf_cytosines_nuc <- (profile %>% filter(Sequence == "C"))$Nucleotide
cumdf_guanine_nuc <- (profile %>% filter(Sequence == "G"))$Nucleotide
cumdf_uracils_nuc <- (profile %>% filter(Sequence == "U"))$Nucleotide

#adenines:total Mn2+ mutation rate above 0.5 were classified as a “m1A”
wc_cutoff_A <- which(As$Mn_rate > 0.5)

#uridines:total Mn2+ mutation rate above 0.5 were classified as a “m3U or m1acp3Y”
wc_cutoff_U <- which(Us$Mn_rate > 0.5)

#guanosines: total Mn2+ mutation rate above 0.05 and total Mg2+ mutation rate above 0.0015 were classified as “m7G”
#wc_cutoff_G <- Gs %>% filter(Mn_rate > 0.05) %>% (Untreated_rate > 0.00)
wc_cutoff_G <- which((Gs$Mn_rate > 0.5) & (Gs$Untreated_rate > 0.5))

pred_As <- cbind(rep("A", length(cumdf_adenine_nuc)), cumdf_adenine_nuc, As %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_adenine_nuc) %>% 
  rename(seq = 'rep("A", length(cumdf_adenine_nuc))')
pred_As$`predicted Modifications` <- as.character(pred_As$`predicted Modifications`)
pred_As$`predicted Modifications`[wc_cutoff_A] <- "m1A"

pred_Cs <- cbind(rep("C", length(cumdf_cytosines_nuc)), cumdf_cytosines_nuc, Cs %>%
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_cytosines_nuc) %>% 
  rename(seq = 'rep("C", length(cumdf_cytosines_nuc))')
pred_Cs$`predicted Modifications` <- as.character(pred_Cs$`predicted Modifications`)

pred_Gs <- cbind(rep("G", length(cumdf_guanine_nuc)), cumdf_guanine_nuc, Gs %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_guanine_nuc) %>% 
  rename(seq = 'rep("G", length(cumdf_guanine_nuc))')
pred_Gs$`predicted Modifications` <- as.character(pred_Gs$`predicted Modifications`)
pred_Gs$`predicted Modifications`[wc_cutoff_G] <- "m7G"

pred_Us <- cbind(rep("U", length(cumdf_uracils_nuc)), cumdf_uracils_nuc, Us %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_uracils_nuc) %>% 
  rename(seq = 'rep("U", length(cumdf_uracils_nuc))')
pred_Us$`predicted Modifications` <- as.character(pred_Us$`predicted Modifications`)
pred_Us$`predicted Modifications`[wc_cutoff_U] <- "m3U or m1acp3Y"


unordered <- rbind(pred_As, pred_Cs, pred_Gs, pred_Us)
newpred <- unordered[order(as.numeric(unordered$cumdf_nuc)),]

newpred <- newpred %>% rename(Nucleotide = 'seq') %>% rename(Position = 'cumdf_nuc') %>% rename('Prediction Margin' = 'prediction margin') %>%
  rename ('Predicted Modifications' = 'predicted Modifications')

write.csv(newpred, file = "ordered_predictions.csv", row.names = FALSE)
