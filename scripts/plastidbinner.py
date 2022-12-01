import os
import pandas as pd
import argparse
from Bio import SeqIO
import shutil

def plastid_seq_id(tiaraplastid):
    '''
    Creates list of contigs classified as plastid.
    :param tiaraplastid: Plastid fasta generated in tiara
    :return: List object containing plastid contig identifiers
    '''
    plastidseqlist = []
    plastidseq = list(SeqIO.parse(tiaraplastid, "fasta"))

    for record in plastidseq:
        plastidseqlist.append(record.id)

    return plastidseqlist

def plastid_bin_stats(binpath, plastidseqlist):
    '''
    Generates dataframe summarizing plastid content of bins.
    :param binpath: Path to directory containing bin files.
    :param plastidseqs: Plastid contig identifier list
    :return: pandas dataframe containing plastid content information for bins.
    '''
    filelist = os.listdir(binpath)
    binfasta_all = [item for item in filelist if ".fai" not in item]
    binfasta = binfasta_all[:len(binfasta_all) - 2]
    print(binfasta)

    bindict = {}

    for file in binfasta:
        binid = file.rstrip(".fa")
        binseq = list(SeqIO.parse(binpath + file, "fasta"))

        total_nt = 0
        bin_contigs = []

        plastid_nt = 0

        for record in binseq:
            total_nt += len(record.seq)
            bin_contigs.append(record.id)

            if record.id in plastidseqlist:
                plastid_nt += len(record.seq)

        bincontigcount = len(bin_contigs)
        
        plastid_bin_contigs = set(bin_contigs) & set(plastidseqlist)
        plastidcontigcount = len(plastid_bin_contigs)

        if bincontigcount == 0:
            percent_plastid_count = 0 
        else:
            percent_plastid_count = round((plastidcontigcount / bincontigcount) * 100, 2)

        if total_nt == 0:
            percent_plastid_nt = 0
        else:
            percent_plastid_nt = round((plastid_nt / total_nt) * 100, 2)

        bindict[binid] = {"total_contig_count":bincontigcount, "bin_size_nt":total_nt, "plastid_contig_count":plastidcontigcount, "plastid_size_nt":plastid_nt, "plastid_count_percent":percent_plastid_count, "plastid_nt_percent":percent_plastid_nt}

    print(bindict)
    binstats = pd.DataFrame.from_dict(bindict, orient = "index")
    binstats.insert(loc=0, column='bin_id', value=binfasta)

    return binstats


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-b', '--binpath', required=True, type = str,help = 'Path to directory containing bins')
    ap.add_argument('-p', '--plastids', required=True, type=str,
                    help='Plastid fasta (produced from Tiara)')
    ap.add_argument('-o', '--outdir', required=True, type = str, help = "Path to output directory")
    ap.add_argument('-d', '--plastidbindir', required = True, type = str, help = "Path to directory with plastid bins")
    ap.add_argument('-s', '--binsize', required=False, type = int, help = "Threshold of plastid bin content", default = 90)
    args = ap.parse_args()

    plastidseqlist = plastid_seq_id(args.plastids)

    plastidbin_dataframe = plastid_bin_stats(args.binpath, plastidseqlist)
    plastidbin_dataframe.to_csv(args.outdir + "/plastid_bin_stats.csv", index=True, header=True)

    filteredplastids = list(plastidbin_dataframe[plastidbin_dataframe["plastid_nt_percent"] >= args.binsize]["bin_id"])

    for bin in filteredplastids:
        shutil.copy(args.binpath + bin, args.plastidbindir)
