import pandas as pd
import os

def summary_table(completeness, contamination, taxonomy, bins):
    binid = os.listdir(bins)
    completeness = pd.read_csv(completeness, sep = ",")
    contamination = pd.read_csv(contamination, sep = ",")
    taxonomy = pd.read_csv(taxonomy, sep = "\t")

    taxlineage = taxonomy[["# bin","superkingdom", "phylum", "class", "order", "family", "genus"]].set_index("# bin")
    quality = comp.set_index("id").join(cont.set_index("id"))

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

    summary.to_csv(args.summary, index=False, header=True)
