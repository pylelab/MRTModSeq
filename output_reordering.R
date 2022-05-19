#!/usr/bin/env Rscript

args=commandArgs(TRUE)
if (length(args)<1){
  cat("adenosin_predictions.arff cytidine_predictions.arff guanosine_predictions.arff uridine_predictions.arff profile.txt\n")
  cat("\nInput:\n")
  cat("    adenosine_predictions.arff          - WEKA format feature file with classifications for A\n")
  cat("    cytidine_predictions.arff          - WEKA format feature file with classifications for A\n")
  cat("    guanosine_predictions.arff         - WEKA format feature file with classifications for A\n")
  cat("    uridine_predictions.arff           - WEKA format feature file with classifications for A\n")
  cat("    profile.txt                        - profile file from ShapeMapper --counted output\n")
  cat("\nOutput:\n")
  cat("    5_8_sample_predictions.csv  - final ordered prediction file in CSV format\n")
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
wc_cutoff_G <- which(Gs$Mn_rate > 0.05 && tmpg$Untreated_rate > 0.0015)
pred_As <- cbind(cumdf_adenine_nuc, As %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_adenine_nuc)
pred_As$cumdf_nuc[wc_cutoff_A] <- "m1A"
pred_Cs <- cbind(cumdf_cytosines_nuc, Cs %>%
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_cytosines_nuc)
pred_Gs <- cbind(cumdf_guanine_nuc, Gs %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_guanine_nuc)
pred_Gs$cumdf_nuc[wc_cutoff_G] <- "m7G"
pred_Us <- cbind(cumdf_uracils_nuc, Us %>% 
                   select(starts_with("predict"))) %>% rename(cumdf_nuc = cumdf_uracils_nuc)
pred_Us$cumdf_nuc[wc_cutoff_U] <- "m3U or m1acp3Y"



unordered <- rbind(pred_As, pred_Cs, pred_Gs, pred_Us)
newpred <- unordered[order(unordered$cumdf_nuc),]
write.csv(newpred, file = "5_8_sample_predictions.csv", row.names = FALSE)
