import pandas as pd
import os
import argparse

def summary_table(completeness, contamination, taxonomy, bins):
    '''
    Generates summary dataframe compiling completeness, contamination and taxonomic
    allocation for all plastid bins identified in a sample.
    :param completeness: Path to completeness file (.csv) generated during quality estimation.
    :param contamination: Path to contamination file (.csv) generated during quality estimation.
    :param taxonomy: Path to taxonomy file (.tsv) generated during CAT classification.
    :param bins: Path to directory containing plastid bins.
    :return: pandas dataframe summarizing plastid genome characterisitcs.
    '''
    
    binid = os.listdir(bins)

    if len(binid) == 0:
        binid = "no_plastid"

    completeness = pd.read_csv(completeness, sep = ",")
    contamination = pd.read_csv(contamination, sep = ",")
    taxonomy = pd.read_csv(taxonomy, sep = "\t")

    taxlineage = taxonomy[["# bin","superkingdom", "phylum", "class", "order", "family", "genus"]].set_index("# bin")
    quality = completeness.set_index("id").join(contamination.set_index("id"))

    summary_table = quality.merge(taxlineage, how = 'cross')

    summary_table.insert(loc=0, column='id', value=binid)

    return summary_table

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-comp', '--completeness', required=True, type=str,
                    help='Completeness CSV')
    ap.add_argument('-cont', '--contamination', required=True, type=str,
                    help='Contamination CSV')
    ap.add_argument('-t', '--taxonomy', required=True, type=str, help='Taxonomic classification')
    ap.add_argument('-b', '--bindir', required=True, type=str, help='Bin directory')
    ap.add_argument('-o', '--summaryout', required = True, type=str, help='Summary output file')
    args = ap.parse_args()

    summary = summary_table(args.completeness, args.contamination, args.taxonomy, args.bindir)

    summary.to_csv(args.summaryout, index=False, header=True)