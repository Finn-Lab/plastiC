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

# predict completeness
def quality_estimate(X, bincount):
    binid = os.listdir(bins)
    if len(binid) == 0:
        quality_prediction_df = pd.DataFrame([0], columns=['quality'])
        quality_prediction_df.insert(loc=0, column='id', value="no_plastid")
    else:
        quality_prediction = quality_model.predict(X) # numpy array
        quality_prediction_df = pd.DataFrame(quality_prediction * 100)
        quality_prediction_df = quality_prediction_df.round(decimals = 2)
        idnames = [file for file in filenames]
        quality_prediction_df.insert(loc=0, column='id', value=idnames)
        #completeness_prediction_df["id"] = filenames[0:-18]
        #completeness_prediction_df.reindex(columns=["id", "completeness"])
    return completeness_prediction_df


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-b', '--bindir', required=True, type=str, help='Bin directory (check to see if plastid bins exist)')
    ap.add_argument('-k', '--keggdataprep', required=True, type=str,
                    help='KEGG data prep csv')
    ap.add_argument('-kc', '--keggcountdir', required=True, type=str,
                    help='KEGG count directory')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output file')
    ap.add_argument('-m', '--model', required=True, type=str, help='Model')
    ap.add_argument('-t', '--type', required=True, type=str, help = 'Type of estimate')
    args = ap.parse_args()

    completeness_model = pickle.load(open(args.model, "rb"))

    filenames = os.listdir(args.keggcountdir)
    X, y = load_data(args.keggdataprep)
    quality_prediction_df = quality_estimate(X, args.bindir)
    colnames = ["id"]
    colnames.append(args.type)
    print(colnames)
    quality_prediction_df.to_csv(args.outfile, header=colnames,index=False)
