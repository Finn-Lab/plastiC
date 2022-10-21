import pickle

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

completeness_model = pickle.load(open("resources/completeness_prediction.model", "rb"))
completeness_prediction = completeness_model.predict(FILE) # numpy array
completeness_prediction_df = pd.DataFrame(completeness_prediction)

df.to_csv('compl.csv',index=False)
