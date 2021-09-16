#!/usr/bin/env python3

import os
import sys

def bestHit(in_hmmer):
    with open(sys.argv[1]) as f:
        hits = {}
        markers = {}
        for line in f:
            if line[0] != "#":
                cols = line.rstrip().split()
                query = cols[0]
                marker = cols[2]
                bitscore = float(cols[5])
                if query not in hits:
                    hits[query] = [marker, bitscore]
                elif bitscore > hits[query][-1]:
                    hits[query] = [marker, bitscore]
        return hits

def bestMarker(hits):
    markers_best = {}
    markers_contigs = {}
    for protein in hits:
        marker = hits[protein][0]
        bitscore = hits[protein][-1]
        contig = "_".join(protein.split("_")[:-1])
        if marker not in markers_best: # store first instance
            markers_best[marker] = [(protein, bitscore)]
            markers_contigs[marker] = [contig]
        else:
            if contig in markers_contigs[marker]: # if contig has already been included
                for n,marker_res in enumerate(markers_best[marker]):
                    contig_old = "_".join(marker_res[0].split("_")[:-1])
                    bitscore_old = marker_res[-1]
                    if contig_old == contig and bitscore > bitscore_old:
                        markers_best[marker][n] = (protein, bitscore)
            else:
                markers_best[marker].append((protein, bitscore))
                markers_contigs[marker].append(contig)
    return markers_best

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("usage: script.pyt in_hmmer.tsv")
        sys.exit(1)
    else:
       hits = bestHit(sys.argv[1])
       markers = bestMarker(hits)
       for m in markers:
           for hit in markers[m]:
               print("%s\t%s" % (hit[0], m.split(".faa")[0]))
