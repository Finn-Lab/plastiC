from Bio import SeqIO
import pandas as pd
import pandas
import argparse
import os


def query_identifiers(hmmdomtbl):
    """
    Identify sequence IDs corresponding to marker hits.
    :param hmmout: HMM Domain table.
    :return: List of sequence identifiers.
    """
    try:
        hmmout = pd.read_csv(
            hmmdomtbl, comment="#", sep="\s+", header=None, index_col=None
        )
        print(hmmout)
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
    except pandas.errors.EmptyDataError:
        pass


def filter_fasta(fastainput, seqid):
    """
    Filter FASTA for sequence identifiers created from query_identifiers.
    :param fastainput: FASTA file to select sequences from.
    :param seqid: List of sequence identifiers (generated in query_identifiers).
    :return: Dictionary of selected sequences.
    """
    try:
        seq_dict = SeqIO.to_dict(SeqIO.parse(fastainput, "fasta"))
        seqselect_dict = dict(
            (seqid, seq_dict[seqid]) for seqid in seqid if seqid in seq_dict
        )

        return seqselect_dict
    except TypeError:
        pass


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-i", "--hmminputdir", required=True, type=str, help="HMMscan directory"
    )
    ap.add_argument("-b", "--bindir", required=True, type=str, help="Bin directory")
    ap.add_argument(
        "-o", "--outpath", required=True, type=str, help="Output FASTA file path"
    )

    args = ap.parse_args()

    filelist = os.listdir(args.hmminputdir)

    hmmdomtbl = [item for item in filelist if ".out" not in item]

    for bin in hmmdomtbl:
        hmmdomtblpath = args.hmminputdir + "/" + bin

        binid = bin[: len(bin) - 11]

        binfasta = args.bindir + "/" + binid + ".fa"

        seqidlist = query_identifiers(hmmdomtblpath)
        seqselect_dict = filter_fasta(binfasta, seqidlist)

        fastaout = args.outpath + "/" + binid + ".fasta"

        try:
            with open(fastaout, "w") as handle:
                SeqIO.write(seqselect_dict.values(), handle, "fasta")
        except AttributeError:
            pass
