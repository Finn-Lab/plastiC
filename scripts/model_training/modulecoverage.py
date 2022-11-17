import pandas as pd
import numpy as np
import argparse

def module_coverage(keggprep):
    '''
    Generate pandas dataframe of KEGG module completeness.
    :param keggprep: KEGG count pandas dataframe.
    :return: pandas dataframe of KEGG module completeness.
    '''
    boolkegg = keggprep.reset_index("bin_id").set_index(["bin_id", "completeness"]).astype(bool).astype(int)

    modules = list(modules_contents.keys())
    kegg_module_values = list(modules_contents.values())
    kegg_module_values_flat = [item for sublist in kegg_module_values for item in sublist]

    missing_kegg_cols = list(set(kegg_module_values_flat).difference(boolkegg.columns))
    newcolnames = list(boolkegg.columns) + missing_kegg_cols
    module_prep = boolkegg.reindex(columns = newcolnames).fillna(0)

    module_df = pd.DataFrame(columns = modules)

    for module, members  in modules_contents.items(): # keggs is your dictionary
        module_df[module] = module_prep[members].sum(axis=1)/len(members)

    module_df = module_df.reset_index("completeness")
    return module_df

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument('-k', '--keggdataprep', required=True, type=str,
                    help='KEGG data prep csv')
    ap.add_argument('-o', '--outfilepath', required=True, type=str,
                    help='Output file path for csv')

    args = ap.parse_args()
    keggmodulecov = module_coverage(args.keggdataprep)
    keggmodulecov.to_csv(args.outfilepath + "kegg_modules_data.csv", index=False, header=False)
