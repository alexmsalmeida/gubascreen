#!/usr/bin/env python3

import os
from os import path
import sys
from Bio import SeqIO

def markerBest(in_hmmer):
    markers = {}
    with open(in_hmmer) as f:
        for line in f:
            line = line.rstrip()
            cols = line.split("\t")
            if cols[-1] not in markers:
                markers[cols[-1]] = [cols[0]]
            else:
                markers[cols[-1]].append(cols[0])
    return markers

def writeFaa(in_faa, proteins, outname):
    fout = open(outname, "w")
    with open(in_faa) as f:
        for record in SeqIO.parse(f, "fasta"):
            if record.id in proteins:
                record.id = "_".join(record.id.split("_")[:-1])
                record.description = ""
                SeqIO.write(record, fout, "fasta")
    fout.close()
        
if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("usage: script.py bestHmmer.tsv input.faa outdir")
        sys.exit(1)
    else:
        markers = markerBest(sys.argv[1])
        if not os.path.exists(sys.argv[3]):
            os.makedirs(sys.argv[3])
        for marker in markers:
            writeFaa(sys.argv[2], markers[marker], sys.argv[3]+"/"+marker+".faa")
                
