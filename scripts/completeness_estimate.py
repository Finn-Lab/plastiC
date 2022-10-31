import pickle
import pandas as pd
import os
import argparse
import csv
import numpy as np

def bin_kegg_count_parse(keggcountpath):
    training_kegg_id_file = "resources/quality_estimates/training_kegg_id_list.txt"

    with open(training_kegg_id_file) as f:
        training_kegg_id = f.read().splitlines()

    filelist = os.listdir(keggcountpath)

    keggoutput_list = []

    for file in filelist:
        keggout = pd.read_csv(keggcountpath + "/" + file, sep = " ")
        keggout.columns = ["KEGG"]
        keggout["compholder"] = 47
        keggout["bin_id"] = file[0:-18]
        keggout["count"] = keggout.groupby(["KEGG"])["KEGG"].transform("count")
        keggoutput_list.append(keggout)

    keggoutputs = pd.concat(keggoutput_list)

    keggoutputspread = keggoutputs.pivot_table(index = ["bin_id", "compholder"], columns = "KEGG", values = "count", fill_value = 0)

    keggoutput_id = keggoutputspread.columns.tolist()

    missing_kegg_list = [kegg for kegg in training_kegg_id if kegg not in keggoutput_id]

    for kegg in missing_kegg_list:
        keggoutputspread[kegg] = 0

    keggoutputspread_defrag = keggoutputspread.copy()

    bin_kegg_count = keggoutputspread_defrag.reindex(columns=training_kegg_id).reset_index(level=["compholder"])

    return bin_kegg_count

def load_data(path):
    y = []
    X = []
    with open(path) as fin:
        for row in csv.reader(fin):
            y.append(float(row[0]))
            X.append([float(x) for x in row[1:]])
    y = np.array(y)
    X = np.array(X)
    return X, y

# load the completeness model
completeness_model = pickle.load(open("/hps/research/finn/escameron/plastcovery/resources/quality_estimates/completeness.model", "rb"))

# predict completeness
def completeness_estimate(X):
    completeness_prediction = completeness_model.predict(X) # numpy array
    completeness_prediction_df = pd.DataFrame(completeness_prediction * 100)
    completeness_prediction_df = completeness_prediction_df.round(decimals = 2)
    idnames = [file for file in filenames]
    completeness_prediction_df.insert(loc=0, column='id', value=idnames)
    #completeness_prediction_df["id"] = filenames[0:-18]
    #completeness_prediction_df.reindex(columns=["id", "completeness"])
    return completeness_prediction_df

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    #ap.add_argument('-k', '--keggdataprep', required=True, type=str,
    #                help='KEGG data prep csv')
    ap.add_argument('-kc', '--keggcountdir', required=True, type=str,
                    help='KEGG count directory')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output file')

    args = ap.parse_args()
    filenames = os.listdir(args.keggcountdir)
    keggdataprep = bin_kegg_count_parse(args.keggcountdir)
    #X, y = load_data(keggdataprep)
    X = keggdataprep[1:].to_numpy()
    completeness_prediction_df = completeness_estimate(X)
    #mitocontam_prediction_df = mitocontam_estimate(X)
    #quality_prediction_df = completeness_prediction_df.join(mitocontam_prediction_df)
    #quality_prediction_df.to_csv(args.outfile, header=["id", "completeness", "mitochondrial_contamination"],index=False)
    completeness_prediction_df.to_csv(args.outfile, header=["id", "completeness"],index=False)
