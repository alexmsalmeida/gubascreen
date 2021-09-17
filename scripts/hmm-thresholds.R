# load libraries
library(ggplot2)
library(rhmmer)

# load data
setwd("~/Documents/ESPOD/Analyses/Project_phages/gubaphage_pangenome/")
hmmer.out = as.data.frame(read_tblout("gpd_hmmer.tsv"))
hmmer.out$query_genome = gsub("_[^_]*$", "", hmmer.out$domain_name)
hmmer.out = aggregate(sequence_score ~ query_genome+query_name, data=hmmer.out, FUN=max)
guba.genomes = scan("gubaphage_genomes.txt", what="")
hmmer.out$description = ifelse(hmmer.out$query_genome %in% guba.genomes, "Gubaphage", "Non-gubaphage")

# define thresholds
scores = data.frame(query_name = unique(hmmer.out$query_name), threshold=0, precision=0, recall=0, f1=0, stringsAsFactors = FALSE)
for (g in 1:nrow(scores)) {
  marker.df = hmmer.out[which(hmmer.out$query_name == scores[g, "query_name"]),]
  score.range = seq(min(marker.df$sequence_score),max(marker.df$sequence_score),(max(marker.df$sequence_score-min(marker.df$sequence_score))/50))
  for (s in score.range) {
    tp = length(which(marker.df$query_name == scores[g, "query_name"] & marker.df$sequence_score > s & marker.df$description == "Gubaphage"))
    fp = length(which(marker.df$query_name == scores[g, "query_name"] & marker.df$sequence_score > s & marker.df$description != "Gubaphage"))
    fn = length(guba.genomes) - length(which(marker.df$query_name == scores[g, "query_name"] & marker.df$sequence_score > s & marker.df$description == "Gubaphage"))
    precision = tp/(tp+fp)
    recall = tp/(tp+fn)
    f1 = 2*((precision*recall)/(precision+recall))
    if (!is.na(f1)) {
      if (f1 > scores[g, "f1"]) {
        scores[g, "f1"] = f1
        scores[g, "precision"] = precision
        scores[g, "recall"] = recall
        scores[g, "threshold"] = s
      }
    }
  }
}
df = merge(hmmer.out, scores, by="query_name")

# plot scores
hist.plot = ggplot(df, aes(x=sequence_score, fill=description)) +
  geom_histogram(alpha=0.8) +
  geom_vline(aes(xintercept = threshold), linetype="dashed") +
  theme_bw() +
  facet_wrap(~ query_name) +
  scale_fill_manual(values=c("steelblue", "tomato"), name="Genome") +
  ylab("Number of genomes") +
  xlab("Alignment score (Bitscore)") +
  theme(strip.background=element_rect(fill=NA, color=NA),
          strip.text=element_text(size=12)) +
  theme(axis.title.x = element_text(size=14)) +
  theme(axis.title.y = element_text(size=14)) +
  theme(axis.text.x = element_text(size=12)) +
  theme(axis.text.y = element_text(size=12))
ggsave(filename="hmmer_thresholds.tiff", height=6, width=14, dpi=300)
