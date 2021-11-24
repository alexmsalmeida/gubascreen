#!/usr/bin/env python3

import sys
import os
import argparse
import glob
import subprocess
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq

def concat(args):
    seqs = {}
    for concat in glob.glob(os.path.join(args.directory, "*.aln")):
        fasta_in = open(concat, "r")
        for record in SeqIO.parse(fasta_in, "fasta"):
            if record.id not in seqs.keys():
                seqs[record.id] = record.seq
            else:
                seqs[record.id] = seqs[record.id]+record.seq

    new_align = args.output_name
    if not os.path.isfile(new_align):	
        with open(new_align, "w") as fasta_out:
            for element in seqs.keys():
                newRecord = SeqRecord(seqs[element], id=element, description="")
                SeqIO.write(newRecord, fasta_out, "fasta") 

if __name__ == '__main__':
    parser = argparse.ArgumentParser(usage='Concate alignments')
    parser.add_argument('-d', dest='directory', \
                                  help='Directory with protein alignments (.aln files)')
    parser.add_argument('-o', dest='output_name', \
                                  help='Name for the output file')
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)
    else:
        args = parser.parse_args()
        tree_input = concat(args)
