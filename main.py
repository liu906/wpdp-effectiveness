from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.pipeline import make_pipeline
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score, recall_score, f1_score
from pathlib import Path
import argparse
import pandas as pd
import os
import numpy as np
import logging
from pathlib import Path

logging.basicConfig(level=logging.DEBUG, filename='./log', format='%(asctime)s:%(levelname)s:%(message)s')

# create a pipeline object
pipe_LR = make_pipeline(
    StandardScaler(),
    LogisticRegression()
)
pipe_KNN1 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=1)
)
pipe_KNN1ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=1)
)
pipe_KNN2 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=2)
)
pipe_KNN2ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=2)
)
pipe_KNN3 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=3)
)
pipe_KNN3ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=3)
)
pipe_KNN4 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=4)
)
pipe_KNN4ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=4)
)
pipe_KNN5 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=5)
)
pipe_KNN5ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=5)
)
pipe_KNN10 = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=10)
)
pipe_KNN10ns = make_pipeline(
    KNeighborsClassifier(n_neighbors=10)
)

pipe_SVC_diffTrainData = make_pipeline(
    StandardScaler(),
    SVC
)
pipe_KNN1_diffTrainData = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=1)
)
pipe_KNN3_diffTrainData = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=3)
)
pipe_KNN5_diffTrainData = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=5)
)
pipe_KNN10_diffTrainData = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier(n_neighbors=10)
)

LABEL = ["defective"]
DROPS = ["Project", "Class", "bugs"]
SLOC = ["loc"]
IDs = ["Class"]


model_dict = {'LR': pipe_LR,
              'KNN1': pipe_KNN1, 'KNN1ns': pipe_KNN1ns,
              'KNN2': pipe_KNN2, 'KNN2ns': pipe_KNN2ns,
              'KNN3': pipe_KNN3, 'KNN3ns': pipe_KNN3ns,
              'KNN4': pipe_KNN4, 'KNN4ns': pipe_KNN4ns,
              'KNN5': pipe_KNN5, 'KNN5ns': pipe_KNN5ns,
              'KNN10': pipe_KNN10, 'KNN10ns': pipe_KNN10ns,
              'SVC_diff': pipe_SVC_diffTrainData,
              'KNN1_diff': pipe_KNN1_diffTrainData,
              'KNN3_diff': pipe_KNN3_diffTrainData,
              'KNN5_diff': pipe_KNN5_diffTrainData,
              'KNN10_diff': pipe_KNN10_diffTrainData,
              }



def getFeatures(train_data,test_data,feature_type):
    if feature_type=='metric':
        train_data = train_data.drop(DROPS, axis=1)
        test_data = test_data.drop(DROPS, axis=1)
    return train_data, test_data


def normal_prediction(train_data, test_data, model):
    # if model.endswith('diff'):
    #     test_data = testDiffTrain(train_data, test_data)

    id_train = train_data[IDs]
    id_test = test_data[IDs]
    train_data, test_data = getFeatures(train_data, test_data, feature_type='metric')
    y_train = train_data[LABEL].values
    y_test = test_data[LABEL].values
    X_train = train_data.drop(LABEL, axis=1)
    X_test = test_data.drop(LABEL, axis=1)

    pipe = model_dict[model]
    pipe.fit(X_train, y_train)
    y_pred = pipe.predict(X_test)
    y_proba = pipe.predict_proba(X_test)[:, 1]
    sloc = X_test[SLOC].values.ravel()

    id_test.loc[:, 'sloc'] = sloc
    id_test.loc[:, 'predictLabel'] = y_pred
    id_test.loc[:, 'predictedValue'] = y_proba
    id_test.loc[:, 'actualBugLabel'] = y_test.ravel()

    print('accuracy: ', accuracy_score(pipe.predict(X_test), y_test))
    print('recall: ', recall_score(pipe.predict(X_test), y_test))
    print('f1: ', f1_score(pipe.predict(X_test), y_test))
    return id_test

def newIsBuggy(train_data,test_data):
    list_IDs_train = train_data[IDs].agg(' '.join, axis=1).values
    list_IDs_test = test_data[IDs].agg(' '.join, axis=1).values
    set_IDs_train = set(list_IDs_train)
    set_IDs_test = set(list_IDs_test)
    temp = list(set_IDs_test - set_IDs_train)
    arr_new_instance_idx = []
    y_pred = [0 for _ in list_IDs_test]

    for element in temp:
        idx = list_IDs_test.index(element)
        arr_new_instance_idx.append(idx)
        y_pred[idx] = 1

    return temp


def testDiffTrain(train_data, test_data, diff_data):
    if len(IDs) > 1:
        list_IDs_test = test_data[IDs].agg(' '.join, axis=1).values
        list_IDs_train = train_data[IDs].agg(' '.join, axis=1).values
    else:
        list_IDs_test = test_data[IDs[0]].values
        list_IDs_train = train_data[IDs[0]].values


    list_IDs_test = [item.replace('$', '.') for item in list_IDs_test]
    list_IDs_train = [item.replace('$', '.') for item in list_IDs_train]

    df_same_modules = diff_data.loc[diff_data['isSame'] == True]
    list_same_id = df_same_modules['old'].tolist()
    list_same_id_in_dataset = set(list_same_id).intersection(set(list_IDs_test)).intersection(set(list_IDs_train))


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
        test_path = row['test_path']
        diff_path = row['diff_path']
        train_data = pd.read_csv(train_path)
        test_data = pd.read_csv(test_path)
        diff_data = pd.read_csv(diff_path)
        test_data_without_dup,len_list_same_id, len_list_same_id_in_dataset, tp, fp, tn, fn = testDiffTrain(train_data, test_data, diff_data)
        Path("./data_new").mkdir(parents=True, exist_ok=True)

        test_path_diffToPreviousRelease = './data_new/'+'diffToPreviousRelease_'+test_path.split('/')[-1]
        test_data_without_dup.to_csv(test_path_diffToPreviousRelease, index=False)

        list_path_config_diffData.append([train_path, test_path_diffToPreviousRelease])

        res_list.append(
            [train_path, test_path, test_data.shape[0], len_list_same_id, len_list_same_id_in_dataset, tp, fp, tn, fn])

    res_df = pd.DataFrame(res_list, columns=['train_path', 'test_path', 'nrow_test_data', 'len_same_id_in_source_code',
                                             'len_same_id_in_dataset', 'tp', 'fp', 'tn', 'fn'])
    res_df.to_csv(dataset_diff_info, index=False)
    df_path_config_diffData = pd.DataFrame(list_path_config_diffData, columns=['train_path', 'test_path'])
    df_path_config_diffData.to_csv(config_path_diffToPreviousRelease, index=False)


def test():
    config_path = './script/path_config_jureczko.csv'
    config_path_diffToPreviousRelease = './script/path_config_jureczko_diffToPreviousRelease.csv'
    dataset_diff_info = './result/jureczko_diff_info.csv'
    get_diff_data(config_path, config_path_diffToPreviousRelease, dataset_diff_info)


def run_model_by_config_path(data_split_config_path,data_set_column_config,dataset,modelName):
    df_config = pd.read_csv(data_split_config_path)
    df_column_config = pd.read_csv(data_set_column_config, index_col=0)

    LABEL = df_column_config.loc[dataset, 'label']
    DROPS = df_column_config.loc[dataset, 'drops']
    SLOC = df_column_config.loc[dataset, 'sloc']
    IDs = df_column_config.loc[dataset, 'ids']

    resFolder = df_column_config.loc[dataset, 'res_folder']
    for idx, row in df_config.iterrows():
        train_path = row['train_path']
        test_path = row['test_path']
        train_data = pd.read_csv(train_path)
        test_data = pd.read_csv(test_path)

        if(sum(train_data[LABEL].values)==0):
            print('cannot train the prediction model because no buggy instance in training file')

        prediction_result_df = normal_prediction(train_data, test_data, modelName)
        '../prediction_result/KNN10/ELFF_Method_result/'
        prediction_result_path = './prediction_result/'+modelName+'/'+resFolder + '/'
        res_file_name = train_path.split('/')[-1] + '_' + test_path.split('/')[-1]
        prediction_result_df.to_csv(prediction_result_path + res_file_name, index=False)

def run():
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko_diffToPreviousRelease.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='LR')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko_diffToPreviousRelease.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN10')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko_diffToPreviousRelease.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN5')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko_diffToPreviousRelease.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN1')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko_diffToPreviousRelease.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN3')

    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko.csv',
                         data_set_column_config='./script/dataset_column_config.csv',
                         dataset='jureczko',
                         modelName='LR')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN1')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN3')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN5')
    run_model_by_config_path(data_split_config_path='./script/path_config_jureczko.csv',
                             data_set_column_config='./script/dataset_column_config.csv',
                             dataset='jureczko',
                             modelName='KNN10')

if __name__ == '__main__':
    # test()
    run()


    # parser = argparse.ArgumentParser(
    #     description="use this file to train and test defect prediction model")
    #
    # parser.add_argument("train_file_path")
    # parser.add_argument("test_file_path")
    # parser.add_argument("--result-path", default="prediction_results")
    # parser.add_argument("--label")
    # parser.add_argument("--drops")
    # parser.add_argument("--sloc")
    # parser.add_argument("--ids")
    # parser.add_argument("--model")
    #
    # args = parser.parse_args()
    # model = args.model
    # LABEL = [args.label]
    # DROPS = args.drops.split()
    # SLOC = [args.sloc]
    # IDs = args.ids.split()
    #
    # print("Loading data...")
    # train_data = pd.read_csv(args.train_file_path)
    # test_data = pd.read_csv(args.test_file_path)
    #
    # if not os.path.exists(args.result_path):
    #     Path(args.result_path).mkdir(parents=True, exist_ok=True)
    #
    #
    #
    # if(sum(train_data[LABEL].values)==0):
    #     print('cannot train the prediction model because no buggy instance in training file')
    # else:
    #     df = normal_prediction(train_data, test_data, model)
    #     result_path = os.path.join(args.result_path, args.train_file_path.split('/')[-1] + '_' +
    #                                args.test_file_path.split('/')[-1] + '.csv')
    #     df.to_csv(result_path, index=False)
