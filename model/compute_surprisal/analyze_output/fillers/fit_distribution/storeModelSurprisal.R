library(stringr)
library(ggplot2)
library(dplyr)
library(tidyr)
library(lme4)
library(dplyr)



# Read all model predictions
model = read.csv("~/sda/RRLCS_LOGS/reinforce-logs-both-short/calibration-full-logs-tsv/collect12_NormJudg_Short_Cond_W_GPT2_ByTrial_VN3_Fillers.py.tsv", sep="\t")

# Column indicating the position of each word in the setence
model = model %>% mutate(wordInItem = as.numeric(as.character(Region))+1)

# Create item IDs corresponding to those in the human data
model = model %>% mutate(item = paste("Filler", Sentence, sep="_"))

# Average over repeat runs of the importance sampler. `SurprisalReweighted' is the estimate of Resource-Rational Lossy-Context Surprisal computed by the importance sampler.
model = model %>% group_by(item, wordInItem, Region, Word, Script, ID, predictability_weight, deletion_rate)
model = model %>% summarise(SurprisalReweighted=mean(as.numeric(as.character(SurprisalReweighted)), na.rm=TRUE))
# variables appearing here:
#  item: the ID of the filler sentence
#  wordInItem, Region: position of word in sentence
#  Word: the word
#  Script: script used for training the model. Here, only those containing "_TPS" are used, the others reflect earlier versions of the model (see next line).
#  ID: ID of the model run
#  predictability_weight: only take those with value 1
#  deletion_rate: what fraction of the last N=20 words is forgotton on average. Only 0.05 is of interest here (for now, look at almost perfect memory)
#model = model %>% filter(grepl("_TPS", Script), predictability_weight==1) # commenting this out (November 2023)
model = model %>% filter(deletion_rate==0.05, predictability_weight==1)
# Now, average across all model runs
model = model %>% group_by(Word, wordInItem, item) %>% summarise(SurprisalReweighted=mean(SurprisalReweighted, na.rm=TRUE))

write.table(model, file="cached_data/model_surprisal.tsv", sep="\t")
