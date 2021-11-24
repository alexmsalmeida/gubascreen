#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

Build phylogenetic tree from HMMER output and a protein FASTA file

OPTIONS:
   -t      Number of threads [REQUIRED]
   -i      HMMER input file (.tsv) [REQUIRED]
   -p      Protein FASTA file (.faa) [OPTIONAL]
   -m      Tree building tool [iqtree or fasttree]
   -o      Output directory [REQUIRED]
EOF
}

# variables
threads=
hmmer=
fasta=
outdir=
mode=

while getopts “t:i:p:m:o:” OPTION
do
     case ${OPTION} in
         t)
             threads=${OPTARG}
             ;;
         i)
             hmmer=${OPTARG}
             ;;
         p)
             fasta=${OPTARG}
             ;;
         o)
             outdir=${OPTARG}
             ;;
         m)
             mode=${OPTARG}
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

# check arguments
if [[ -z ${threads} ]] || [[ -z ${hmmer} ]] || [[ -z ${fasta} ]] || [[ -z ${outdir} ]] || [[ -z ${mode} ]]
then
     echo "ERROR : Please supply correct arguments"
     usage
     exit 1
fi

timestamp() {
  date +"%H:%M:%S"
}

# make sure output directory exists
if [[ ! -d ${outdir} ]]
then
    mkdir -p ${outdir}
fi

# select best hits per protein per marker
echo "$(timestamp) [ hmmer2tree ] Parsing HMMER results ..."
bestHmmer.py ${hmmer} > ${outdir}/hmmer_besthits.tsv
bestHmmer2faa.py ${outdir}/hmmer_besthits.tsv ${fasta} ${outdir}/markers

# align sequences with muscle
echo "$(timestamp) [ hmmer2tree ] Aligning sequences with MUSCLE ..."
for i in ${outdir}/markers/*.faa
do 
    echo "$(timestamp) [ hmmer2tree ] Processing ${i} ..."
    muscle -in ${i} -out ${i%%.faa}.muscle
done

# prepare alignment files
echo "$(timestamp) [ hmmer2tree ] Parsing output ..."
grep -e ">" ${outdir}/markers/*muscle | cut -f2 -d ":" | cut -f2 -d ">" | sort | uniq > ${outdir}/genome_list.txt
for i in ${outdir}/markers/*muscle; do norm_alignment.py ${i} ${outdir}/genome_list.txt ${i%%.muscle}.aln; done

if [[ ! -d ${outdir}/markers/norm_alignment ]]
then
    mkdir -p ${outdir}/markers/norm_alignment
fi

mv ${outdir}/markers/*.aln ${outdir}/markers/norm_alignment
concat_alns.py -d ${outdir}/markers/norm_alignment -o ${outdir}/concat_alignment.aln

# build tree
echo "$(timestamp) [ hmmer2tree ] Building phylogenetic tree ..."
if [[ ${mode} == "iqtree" ]]
then
    cd ${outdir}
    iqtree -nt ${threads} -s concat_alignment.aln
else
    FastTree ${outdir}/concat_alignment.aln > ${outdir}/fasttree.nwk
fi
echo "$(timestamp) [ hmmer2tree ] Analysis finished successfully"
