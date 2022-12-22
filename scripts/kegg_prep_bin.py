import pandas as pd
import os
import argparse
import json


def bin_kegg_count_parse(keggcountpath, keggorder):
    """
    Generates dataframe of KEGG counts for each plastid bin.
    :param keggcountpath: Path to directory containing KEGG lists as generated
    with keggcounter.sh
    :param keggorder: Path to KEGG order text file generated in preparation
    of training data.
    :return: pandas dataframe containing counts of KEGG (rows = sample, columns = KEGGs)
    """

    training_kegg_id_file = keggorder

    with open(training_kegg_id_file) as f:
        training_kegg_id = f.read().splitlines()

    filelist = os.listdir(keggcountpath)

    keggoutput_list = []

    for file in filelist:
        if os.path.getsize(keggcountpath + "/" + file) == 0:
            keggout = pd.DataFrame(training_kegg_id)
            keggout.columns = ["KEGG"]
            keggout["compholder"] = 47
            keggout["bin_id"] = file
            keggout["count"] = 0
            keggoutput_list.append(keggout)
        else:
            keggout = pd.read_csv(keggcountpath + "/" + file, sep=" ", header=None)
            keggout.columns = ["KEGG"]
            keggout["compholder"] = 47
            keggout["bin_id"] = file
            keggout["count"] = keggout.groupby(["KEGG"])["KEGG"].transform("count")
            keggoutput_list.append(keggout)

    keggoutputs = pd.concat(keggoutput_list)

    keggoutputspread = keggoutputs.pivot_table(
        index=["bin_id", "compholder"], columns="KEGG", values="count", fill_value=0
    )

    keggoutput_id = keggoutputspread.columns.tolist()

    missing_kegg_list = [kegg for kegg in training_kegg_id if kegg not in keggoutput_id]

    newcolnames = keggoutput_id + missing_kegg_list

    keggoutputspread_new = keggoutputspread.reindex(columns=newcolnames).fillna(0)

    bin_kegg_count = keggoutputspread_new.reindex(columns=training_kegg_id).reset_index(
        level=["compholder"]
    )

    return bin_kegg_count


with open("resources/quality_estimates/kegg_modules.json") as filein:
    modules_contents = json.load(filein)


def module_coverage(keggprep):
    """
    Generates dataframe of KEGG module completeness.
    Calculate KEGG module compelteness based on KEGG count data and module
    composition.
    :param keggprep: KEGG preparation dataframe generated from bin_kegg_count_parse
    :return: pandas dataframe of KEGG module compelteness (rows = sample, columns = modules)
    """
    boolkegg = (
        keggprep.reset_index("bin_id")
        .set_index(["bin_id", "compholder"])
        .astype(bool)
        .astype(int)
    )

    modules = list(modules_contents.keys())
    kegg_module_values = list(modules_contents.values())
    kegg_module_values_flat = [
        item for sublist in kegg_module_values for item in sublist
    ]

    missing_kegg_cols = list(set(kegg_module_values_flat).difference(boolkegg.columns))
    newcolnames = list(boolkegg.columns) + missing_kegg_cols
    module_prep = boolkegg.reindex(columns=newcolnames).fillna(0)

    module_df = pd.DataFrame(columns=modules)

    for module, members in modules_contents.items():  # keggs is your dictionary
        module_df[module] = module_prep[members].sum(axis=1) / len(members)

    module_df = module_df.reset_index("compholder")
    return module_df


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-kc", "--keggcounts", required=True, type=str, help="KEGG Count directory"
    )
    ap.add_argument("-o", "--outfile", required=True, type=str, help="Output file")
    ap.add_argument("-l", "--keggorderlist", required=True, type=str, help="KEGG Order")

    args = ap.parse_args()

    bin_kegg_count = bin_kegg_count_parse(args.keggcounts, args.keggorderlist)
    bin_kegg_module = module_coverage(bin_kegg_count)
    bin_kegg_module.to_csv(args.outfile, index=False, header=False)
