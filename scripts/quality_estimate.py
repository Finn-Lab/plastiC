import pickle
import pandas as pd
import os
import argparse
import csv
import numpy as np

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
mitocontam_model = pickle.load(open("/hps/research/finn/escameron/plastcovery/resources/quality_estimates/mitochloromodel1_defgbr.model", "rb"))

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

def mitocontam_estimate(X):
    mitocontam_prediction = mitocontam_model.predict(X)
    mitocontam_prediction_df = pd.DataFrame(mitocontam_prediction * 100)
    cmitocontam_prediction_df = mitocontam_prediction_df.round(decimals = 2)
    idnames = [file for file in filenames]
    mitocontam_prediction_df.insert(loc=0, column='id', value=idnames)
    return mitocontam_prediction_df

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-k', '--keggdataprep', required=True, type=str,
                    help='KEGG data prep csv')
    ap.add_argument('-kc', '--keggcountdir', required=True, type=str,
                    help='KEGG count directory')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output file')

    args = ap.parse_args()
    filenames = os.listdir(args.keggcountdir)
    X, y = load_data(args.keggdataprep)
    completeness_prediction_df = completeness_estimate(X)
    mitocontam_prediction_df = mitocontam_estimate(X)
    quality_prediction_df = completeness_prediction_df.join(mitocontam_prediction_df)
    quality_prediction_df.to_csv(args.outfile, header=["id", "completeness", "mitochondrial_contamination"],index=False)
