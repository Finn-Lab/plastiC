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

# predict completeness
def completeness_estimate(X):
    completeness_prediction = completeness_model.predict(X) # numpy array
    completeness_prediction_df = pd.DataFrame(completeness_prediction)
    return completeness_prediction_df

#df.to_csv('completeness.csv',index=False)


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-k', '--keggdataprep', required=True, type=str,
                    help='KEGG Count directory')
    ap.add_argument('-o', '--outfile', required=True, type=str,
                    help='Output file')

    args = ap.parse_args()
    X, y = load_data(args.keggdataprep)
    completeness_prediction_df = completeness_estimate(X)
    df.to_csv(args.outfile, header=False,index=False)
