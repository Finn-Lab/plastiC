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
    ap.add_argument('-b', '--barrnap', required=True, type = str,help = 'FASTA for plastid rRNA from barrnap')
    ap.add_argument('-o', '--outpath', required=True, type=str,
                    help='Output FASTA file path')

    args = ap.parse_args()

    rrnatypes = ['5S', '5.8S', '16S', '23S', '28S']

    for rrna in rrnatypes:
        seqselect_dict = filter_fasta(args.barrnap, rrna)

        with open(args.outpath + rrna, "w") as handle:
            SeqIO.write(seqselect_dict.values(), handle, "fasta")
