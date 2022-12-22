# import libraries
import pandas as pd
import os
import argparse
import csv
import numpy as np

# subsample the kegg counts for each sample to create simulated plastid genomes


def simulator(keggoutput_spread, minsize=0, maxsize=1.05, stepwise=0.05):
    """
    Subsamples plastid genomes to varying levels of completeness ranging from
    0% to 100% in increments of 5 (Default)
    :params keggoutput_spread: KEGG count pandas dataframe.
    :params minsize: Minimum genome subsampling size (Default: 0)
    :params maxsize: Maximum genome subsampling size (Default: 1.05 [e.g. complete])
    :params stepwise: Incremement step size (Default = 0.05)
    :return: pandas dataframe consisting
    """
    percents = np.arange(minsize, maxsize, stepwise).round(2).tolist()
    subsample_list = []

    for value in percents:
        elements_to_sample = math.ceil(value * len(keggoutput_spread.columns))
        subsample = (
            keggoutput_spread.transpose().sample(n=elements_to_sample).transpose()
        )
        subsample.insert(loc=0, column="completeness", value=value)
        subsample_list.append(subsample)

    simulated = pd.concat(subsample_list).fillna(0)

    bin_kegg_count = keggoutputspread.reindex(columns=training_kegg_id)

    return simulated


def kegg_model_order(simulated_data, filepath):
    """
    Generate order of KEGG in simulated training dataset for use in preparation
    of data for testing.
    :param simulated_data: Simulated data frame (generated from simulator function)
    :param filepath: Path to write text file with KEGG order to (Path only)
    """
    model_kegg_id = simulated_data.columns.tolist()

    with open(filepath + "id_list.txt", "w") as kegglistfile:

        for kegg in contam_kegg_id:
            kegglistfile.write("%s\n" % kegg)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-k", "--keggdataprep", required=True, type=str, help="KEGG data prep csv"
    )
    ap.add_argument(
        "-o",
        "--outfilepath",
        required=True,
        type=str,
        help="Output file path for csv and id text list (including prefix)",
    )

    args = ap.parse_args()
    simulated_data = simulator(args.keggdataprep)
    kegg_model_order(simulated_data, args.outfilepath)
    simulated_data.to_csv(args.outfilepath + "kegg_data.csv", index=False, header=False)
