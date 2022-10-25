import pickle
import pandas as pd
import os
#import argparse

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

# load the kegg_prepr output .csv
#X, y = load_data("/hps/research/finn/escameron/checkm2/universal_testing_60p/kegg_modules_data.csv")

# load the completeness model
completeness_model = pickle.load(open("resources/completeness_prediction.model", "rb"))

# predict completeness
def completeness_estimate(X):
    completeness_prediction = completeness_model.predict(X) # numpy array
    completeness_prediction_df = pd.DataFrame(completeness_prediction)
    return completeness_prediction_df

#f.to_csv('completeness.csv',index=False)


if __name__ == "__main__":
    X, y = load_data(kegg_prepr_output)
    completeness_prediction_df = completeness_estimate(X)
    df.to_csv('completeness.csv',index=False)
