import pandas as pd
import os
import numpy as np
import logging
from pathlib import Path

logging.basicConfig(level=logging.DEBUG, filename='./log', format='%(asctime)s:%(levelname)s:%(message)s')

IDs = ["relName"]


def testDiffTrain(train_data, test_data, diff_data):
    if len(IDs) > 1:
        list_IDs_test = test_data[IDs].agg(' '.join, axis=1).values
        list_IDs_train = train_data[IDs].agg(' '.join, axis=1).values
    else:
        list_IDs_test = test_data[IDs[0]].values
        list_IDs_train = train_data[IDs[0]].values


    list_IDs_test = [item.replace('$', '.') for item in list_IDs_test]
    list_IDs_train = [item.replace('$', '.') for item in list_IDs_train]
    temp = set(list_IDs_test).intersection(set(list_IDs_train))
    df_same_modules = diff_data.loc[diff_data['isSame'] == True]
    pd.options.mode.chained_assignment = None
    df_same_modules['old'] = [item.replace('\\', '/') for item in df_same_modules['old']]
    df_same_modules['new'] = [item.replace('\\', '/') for item in df_same_modules['new']]

    list_same_id = df_same_modules['old'].tolist()
    bool_result = [any(substring in b for b in list_same_id) for substring in temp]
    list_same_id_in_dataset = set([x for x, b in zip(temp, bool_result) if b])
    # list_same_id_in_dataset = set(list_same_id).intersection(set(list_IDs_test)).intersection(set(list_IDs_train))


    same_id_index_test = []
    tp, tn, fp, fn = 0, 0, 0, 0
    # tp: buggy in old,buggy in new
    # fp: clean in old,buggy in new. clean module change to buggy in new version, while code is the same
    # tn: clean in old,clean in new
    # fn: buggy in old,clean in new. buggy module change to clean in new version, while code is the same

    for idx, j in enumerate(list_IDs_test):
        for id in list_same_id_in_dataset:
            if id == j:
                same_id_index_test.append(idx)
                train_label = train_data.loc[train_data[IDs[-1]] == j,LABEL].values
                test_label = test_data.loc[idx, LABEL].values
                if (train_label and test_label):
                    tp = tp + 1
                elif train_label == False and test_label == False:
                    tn = tn + 1
                elif train_label == True and test_label == False:
                    fn = fn + 1
                else:
                    fp = fp + 1
    print(tp, fp, tn, fn)

    not_same_index_test = list(set([item for item in range(test_data.shape[0])]) - set(same_id_index_test))
    test_data_without_dup = test_data.iloc[not_same_index_test]
    return test_data_without_dup, len(list_same_id), len(list_same_id_in_dataset), tp, fp, tn, fn


def get_diff_data(config_path, config_path_diffToPreviousRelease, dataset_diff_info):
    '''

    :param config_path: string, path of config csv file of a dataset,
           file contains (training path, test path, module diff information file path) combinations of
           cross-version defect prediction
    :param config_path_diffToPreviousRelease: string, path to save the
           (training path, test data without duplication path) of a dataset
    :param dataset_diff_info: csv file path to save the number of new modules (not show in the previous release)
           in a test file and total number of modules of the test file
    :return: none
    '''

    df_path_config = pd.read_csv(config_path)
    res_list = []
    list_path_config_diffData = []

    for idx, row in df_path_config.iterrows():
        train_path = row['train_path']
        print(train_path)
        test_path = row['test_path']
        diff_path = row['diff_path']
        dataset = row['dataset']
        project = row['project']
        train_data = pd.read_csv(train_path)
        test_data = pd.read_csv(test_path)
        diff_data = pd.read_csv(diff_path)
        if dataset == 'Metrics-Repo-2010':
            global IDs
            IDs = ['className']

        test_data_without_dup, len_list_same_id, len_list_same_id_in_dataset, tp, fp, tn, fn = testDiffTrain(train_data, test_data, diff_data)
        Path("./dataset/data_new/"+dataset+'/'+project).mkdir(parents=True, exist_ok=True)

        test_path_diffToPreviousRelease = './dataset/data_new/' + dataset + '/' + project + '/diffToPreviousRelease_' + test_path.split('/')[-1]
        test_data_without_dup.to_csv(test_path_diffToPreviousRelease, index=False)

        list_path_config_diffData.append([train_path, test_path_diffToPreviousRelease])

        res_list.append(
            [train_path, test_path, test_data.shape[0], len_list_same_id, len_list_same_id_in_dataset, tp, fp, tn, fn])

    res_df = pd.DataFrame(res_list, columns=['train_path', 'test_path', 'nrow_test_data', 'len_same_id_in_source_code',
                                             'len_same_id_in_dataset', 'tp', 'fp', 'tn', 'fn'])
    res_df.to_csv(dataset_diff_info, index=False)
    df_path_config_diffData = pd.DataFrame(list_path_config_diffData, columns=['train_path', 'test_path'])
    df_path_config_diffData.to_csv(config_path_diffToPreviousRelease, index=False)



config_path = './script/dataset_config.csv'
config_path_diffToPreviousRelease = './script/dataset_config_diffToPreviousRelease.csv'
dataset_diff_info = './script/dataset_diff_info.csv'
get_diff_data(config_path, config_path_diffToPreviousRelease, dataset_diff_info)





