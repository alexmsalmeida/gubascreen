# GubaScreen - Detect Gubaphage in viral genomes

This repo contains instructions on how to screen for the presence of Gubaphage lineages in a set of predicted viral sequences (nucleotide FASTA file). For more information about the Gubaphage, see [Camarillo-Guerrero et al. Cell 2021](https://www.sciencedirect.com/science/article/pii/S0092867421000726) for a formal description of this clade.

## Background

The Gubaphage is a recently discovered clade of bacteriophages highly prevalent in the gut microbiome of diverse human populations. Understanding its global distribution is important to uncover its potential role(s) in the gut ecosystem.

To perform a targeted detection of the Gubaphage, I performed a pan-genome analysis of [all known Gubaphage genomes](http://ftp.ebi.ac.uk/pub/databases/metagenomics/genome_sets/gut_phage_database/Gubaphage_genomes.fa) retrieved from [Camarillo-Guerrero et al. Cell 2021](https://www.sciencedirect.com/science/article/pii/S0092867421000726), leading to the identification of a set of 6 core genes present in >90% of the genomes. For each core gene, HMMER was used to determine the optimal alignment bitscores (maximum F1 score) that would enable a clear separation between Gubaphage and non-Gubaphage sequences. The resulting HMM models alongside their scores can be found in `hmm_models/`.

## Installation

1. Install the following dependencies:

* [Python](https://www.python.org/downloads/) (tested v3.7.3)
* [BioPython](https://biopython.org/wiki/Download)
* [Prodigal](https://github.com/hyattpd/Prodigal/wiki/installation)
* [HMMER](http://hmmer.org/download.html)
* [IQ-TREE](http://www.iqtree.org/)
* [FastTree](http://www.microbesonline.org/fasttree/)

2. Clone the repo.

```
git clone .....
```

3. Add the scripts/ directory to your $PATH environmental variable.

## How to run

1. Predict protein sequences from your nucleotide FASTA file.

```
prodigal -p meta 
```

2. Run HMMER to detect the presence of Gubaphage marker genes

```
hmmsearch ...
```

3. Build phylogenetic tree from HMMER output

```
hmmer2tree.sh ...
```
