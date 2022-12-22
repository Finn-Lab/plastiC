from Bio import SeqIO
import pandas as pd
import argparse
import os


def filter_fasta(fastainput, seqid):
    """
    Filter FASTA for sequence identifiers created from query_identifiers.
    :param fastainput: FASTA file to select sequences from.
    :param seqid: List of sequence identifiers (generated in query_identifiers).
    :return: Dictionary of selected sequences.
    """
    seq_dict = SeqIO.to_dict(SeqIO.parse(fastainput, "fasta"))
    seqselect_dict = dict(
        (seqid, seq_dict[seqid]) for seqid in seqid if seqid in seq_dict
    )

    return seqselect_dict


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("-i", "--rrnadir", required=True, type=str, help="rRNA directory")
    
    args = ap.parse_args()

    filelist = os.listdir(args.rrnadir)

    for bin in filelist:
        rrnabinpath = args.rrnadir + "/" + bin
        binid = bin[: len(bin) - 13]
        rrnatypes = ["5S", "5.8S", "16S", "23S", "28S"]

        for rrna in rrnatypes:
            seqselect_dict = filter_fasta(rrnabinpath, rrna)

            fastaout = args.rrnadir + "/" + binid + "_" + rrna + ".fasta"

            with open(fastaout, "w") as handle:
                SeqIO.write(seqselect_dict.values(), handle, "fasta")
