# GubaScreen - Detect Gubaphage in viral genomes

This repo contains instructions on how to screen for the presence of Gubaphage lineages in a set of predicted viral sequences (nucleotide FASTA file). For more information about the Gubaphage, see [Camarillo-Guerrero et al. Cell 2021](https://www.sciencedirect.com/science/article/pii/S0092867421000726) for a formal description of this clade.

## Background

The Gubaphage is a recently discovered clade of bacteriophages highly prevalent in the gut microbiome of diverse human populations. Understanding its global distribution is important to uncover its potential role(s) in the gut ecosystem.

To perform a targeted detection of the Gubaphage, I performed a pan-genome analysis of [all known Gubaphage genomes](http://ftp.ebi.ac.uk/pub/databases/metagenomics/genome_sets/gut_phage_database/Gubaphage_genomes.fa) retrieved from [Camarillo-Guerrero et al. Cell 2021](https://www.sciencedirect.com/science/article/pii/S0092867421000726), leading to the identification of a set of <b>6 core genes present in >90% of the genomes</b>. For each core gene, [HMMER](http://hmmer.org/download.html) was used to determine the optimal alignment bitscores (maximum F1 score, calculated with `scripts/hmm-thresholds.R`) that would enable a clear discrimination between Gubaphage and non-Gubaphage sequences. The resulting HMM models alongside their scores can be found in `hmm_models/`.

## Installation

1. Install the following dependencies:

* [Python](https://www.python.org/downloads/) (tested v3.7.3)
* [BioPython](https://biopython.org/wiki/Download)
* [Prodigal](https://github.com/hyattpd/Prodigal/wiki/installation) (tested v2.6.3)
* [HMMER](http://hmmer.org/download.html) (tested v3.1b2)
* [MUSCLE](https://www.drive5.com/muscle/downloads.htm) (tested v3.8.31)
* [IQ-TREE](http://www.iqtree.org/) (tested v1.6.11)
* [FastTree](http://www.microbesonline.org/fasttree/) (tested v2.1.10)

2. Clone the repo.

```
git clone https://github.com/alexmsalmeida/gubascreen.git
```

3. Add the `scripts/` directory to your `$PATH` environmental variable.

## How to run

1. Predict protein sequences from your nucleotide FASTA file (`input.fa`).

```
prodigal -i input.fa -a proteins.faa -p meta 
```

2. Run HMMER to detect the presence of Gubaphage marker genes using pre-defined thresholds.

```
hmmsearch --cpu {threads} --cut_ga --tblout guba_hmmer.tsv --noali hmm_models/guba_core.hmm proteins.faa
```

3. Build phylogenetic tree from HMMER output (`iqtree` can be replaced with `fasttree` for a faster, albeit less accurate analysis).

```
hmmer2tree.sh -t {threads} -i guba_hmmer.tsv -p proteins.faa -m iqtree -o phylo_tree
```

The main output file is a phylogenetic (`phylo_tree/concat_alignment.aln.treefile`) file containing your input sequences and reference Gubaphage genomes.
