import numpy as np
from sklearn import datasets, ensemble
from sklearn.inspection import permutation_importance
from sklearn.metrics import mean_squared_error
from sklearn.ensemble import RandomForestRegressor
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import AdaBoostRegressor
from sklearn import svm, datasets
from sklearn.model_selection import GridSearchCV
import csv
import argparse


def load_data(path):
    """
    Load KEGG data from KEGG data preparation for use in regression training.
    :param path: Path to directory containing KEGG data preparation csv.
    :return: numpy array
    """
    y = []
    X = []
    with open(path) as fin:
        for row in csv.reader(fin):
            y.append(float(row[0]))
            X.append([float(x) for x in row[1:]])
    y = np.array(y)
    X = np.array(X)
    return X, y


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "-k", "--keggdataprep", required=True, type=str, help="KEGG data prep csv"
    )
    ap.add_argument(
        "-o", "--outfile", required=True, type=str, help="Output file (model)"
    )
    gbreg = ensemble.GradientBoostingRegressor()
    gbreg.fit(X_train, y_train)
    pickle.dump(gbreg, open(args.outfile, "wb"))
