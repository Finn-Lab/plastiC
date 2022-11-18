from Bio import SeqIO
import pandas as pd
import argparse

def filter_fasta(fastainput, seqid):
    '''
    Filter FASTA for sequence identifiers created from query_identifiers.
    :param fastainput: FASTA file to select sequences from.
    :param seqid: List of sequence identifiers (generated in query_identifiers).
    :return: Dictionary of selected sequences.
    '''
    seq_dict = SeqIO.to_dict(SeqIO.parse(fastainput, "fasta"))
    seqselect_dict = dict((seqid, seq_dict[seqid]) for seqid in queryinterest if seqid in seq_dict)

    return seqselect_dict

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-t', '--hmmdomtbl', required=True, type=str,
                    help='HMM domain table')
    ap.add_argument('-b', '--bin', required=True, type = str,help = 'FASTA for plastidbin')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output FASTA file path and name')

    args = ap.parse_args()

    seqidlist = query_identifiers(args.hmmdomtbl)
    seqselect_dict = filter_fasta(args.bin, seqidlist)

    with open(args.outfile, "w") as handle:
        SeqIO.write(seqselect_dict.values(), handle, "fasta") 
