from Bio import SeqIO
import pandas as pd
import argparse
import os


def query_identifiers(hmmout):
    """
    Identify sequence IDs corresponding to marker hits.
    :param hmmout: HMM Domain table.
    :return: List of sequence identifiers.
    """

    hmmout = pd.read_csv(args.hmm, comment="#", sep="\s+", header=None, index_col=None)
    hmmout.columns = [
        "target_name",
        "accession",
        "tlen",
        "query_name",
        "accession",
        "qlen",
        "eval_fullseq",
        "score_fullseq",
        "bias_fullseq",
        "#",
        "of",
        "c-eval",
        "i-eval",
        "score_dom",
        "bias_dom",
        "hmm_coord_from",
        "hmm_coord_to",
        "ali_coord_from",
        "ali_coord_to",
        "env_coord_from",
        "env_coord_to",
        "acc",
        "description",
    ]
    hmmout_filtered = hmmout[hmmout["eval_fullseq"] <= 1.0e-5]
    queryinterest = hmmout_filtered["query_name"].tolist()

    return queryinterest


def filter_fasta(fastainput, seqid):
    """
    Filter FASTA for sequence identifiers created from query_identifiers.
    :param fastainput: FASTA file to select sequences from.
    :param seqid: List of sequence identifiers (generated in query_identifiers).
    :return: Dictionary of selected sequences.
    """
    seq_dict = SeqIO.to_dict(SeqIO.parse(fastainput, "fasta"))
    seqselect_dict = dict(
        (seqid, seq_dict[seqid]) for seqid in queryinterest if seqid in seq_dict
    )

    return seqselect_dict


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-t", "--hmmdomtbl", required=True, type=str, help="HMM domain table"
    )
    ap.add_argument("-b", "--bin", required=True, type=str, help="FASTA for plastidbin")
    ap.add_argument(
        "-o",
        "--outfile",
        required=True,
        type=str,
        help="Output FASTA file path and name",
    )

    args = ap.parse_args()

    seqidlist = query_identifiers(args.hmmdomtbl)
    seqselect_dict = filter_fasta(args.bin, seqidlist)

    with open(args.outfile, "w") as handle:
        SeqIO.write(seqselect_dict.values(), handle, "fasta")
