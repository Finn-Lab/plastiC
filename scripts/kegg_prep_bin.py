
import pandas as pd
import os
import argparse

def bin_kegg_count_parse(keggcountpath, keggorder):
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
            keggout = pd.read_csv(keggcountpath + "/" + file, sep = " ", header = None)
            keggout.columns = ["KEGG"]
            keggout["compholder"] = 47
            keggout["bin_id"] = file
            keggout["count"] = keggout.groupby(["KEGG"])["KEGG"].transform("count")
            keggoutput_list.append(keggout)

    keggoutputs = pd.concat(keggoutput_list)

    keggoutputspread = keggoutputs.pivot_table(index = ["bin_id", "compholder"], columns = "KEGG", values = "count", fill_value = 0)

    keggoutput_id = keggoutputspread.columns.tolist()

    missing_kegg_list = [kegg for kegg in training_kegg_id if kegg not in keggoutput_id]

    newcolnames = keggoutput_id + missing_kegg_list
    keggoutputspread_new = keggoutputspread.reindex(columns=newcolnames).fillna(0)
    #for kegg in missing_kegg_list:
     #   keggoutputspread[kegg] = 0

    #keggoutputspread_defrag = keggoutputspread.copy()

    bin_kegg_count = keggoutputspread_new.reindex(columns=training_kegg_id).reset_index(level=["compholder"])

    return bin_kegg_count

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-kc', '--keggcounts', required=True, type=str,
                    help='KEGG Count directory')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output file')
    ap.add_argument('-l', '--keggorderlist', required=True, type=str, help='KEGG Order')

    args = ap.parse_args()

    bin_kegg_count = bin_kegg_count_parse(args.keggcounts, args.keggorderlist)

    bin_kegg_count.to_csv(args.outfile, index=False, header=False)
