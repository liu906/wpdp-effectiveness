"""
Naive Bayes (NB) done
Random forests (RF) done
K-nearest neighbor (KNN) done
Support vector machine (SVM) done
Logistic regression (LR) done
auto-gloun
"""
from tqdm import tqdm
from imblearn.over_sampling import SMOTE
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.naive_bayes import GaussianNB
from sklearn.ensemble import RandomForestClassifier
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
# import concurrent.futures
logging.basicConfig(level=logging.DEBUG, filename='./log', format='%(asctime)s:%(levelname)s:%(message)s')

from autogluon.tabular import TabularDataset, TabularPredictor


# create a pipeline object
pipe_LR = make_pipeline(
    StandardScaler(),
    LogisticRegression()
)
pipe_KNN = make_pipeline(
    StandardScaler(),
    KNeighborsClassifier()

)
pipe_NB = make_pipeline(
    StandardScaler(),
    GaussianNB()
)
pipe_RF = make_pipeline(
    StandardScaler(),
    RandomForestClassifier()
)

pipe_SVM = make_pipeline(
    StandardScaler(),
    SVC(probability=True)
)

model_dict = {'LR': pipe_LR,
              'KNN': pipe_KNN,
              'NB': pipe_NB,
              'RF': pipe_RF,
              'SVM': pipe_SVM
              }


def getFeatures(train_data, test_data, feature_type, DROPS):
    if feature_type == 'metric':
        train_data = train_data.drop(DROPS, axis=1)
        test_data = test_data.drop(DROPS, axis=1)
    return train_data, test_data


def normal_prediction(train_data, test_data, model, IDs, LABEL, DROPS, SLOC,flag_resample):


    id_train = train_data[IDs]
    id_test = test_data[IDs]
    train_data, test_data = getFeatures(train_data, test_data, feature_type='metric', DROPS=DROPS)


    y_train = train_data[LABEL].values
    y_test = test_data[LABEL].values
    X_train = train_data.drop(LABEL, axis=1)
    X_test = test_data.drop(LABEL, axis=1)
    sloc = X_test[SLOC].values.ravel()
    if flag_resample:
        sm = SMOTE(random_state=42)
        X_train, y_train = sm.fit_resample(X_train, y_train)
        train_data = X_train
        train_data[LABEL] = y_train


    feature_importance = 0

    if 'autogluon' in model:
        if model == 'autogluon':
            metric = 'accuracy'
            presets = 'default'
        elif model == 'autogluon_best':
            metric = 'accuracy'
            presets = 'best_quality'
        elif model == 'autogluon_best_recall':
            metric = 'recall'
            presets = 'best_quality'
        elif model == 'autogluon_best_f1':
            metric = 'f1'
            presets = 'best_quality'

        train_data = TabularDataset(train_data)

        auto_predictor = TabularPredictor(label=LABEL, eval_metric=metric).fit(train_data, verbosity=2, presets=presets)

        # feature_importance = auto_predictor.feature_importance(train_data)
        test_data = TabularDataset(test_data)
        preds = auto_predictor.predict(test_data)
        proba = auto_predictor.predict_proba(test_data)[1]
        id_test = id_test.assign(sloc=sloc, predictLabel=preds, predictedValue=proba, actualBugLabel=y_test.ravel())

    else:
        pipe = model_dict[model]
        try:
            # 使用fit()函数训练模型
            pipe.fit(X_train, y_train)
        except ValueError as e:
            # 捕获ValueError异常并打印错误信息
            print(f"An error occurred while fitting the model: {e}")
            raise

        y_pred = pipe.predict(X_test)
        y_proba = pipe.predict_proba(X_test)[:, 1]

        id_test = id_test.assign(sloc=sloc, predictLabel=y_pred, predictedValue=y_proba, actualBugLabel=y_test.ravel())

    if False:
        print('accuracy: ', accuracy_score(pipe.predict(X_test), y_test))
        print('recall: ', recall_score(pipe.predict(X_test), y_test))
        print('f1: ', f1_score(pipe.predict(X_test), y_test))
    return id_test, feature_importance


def newIsBuggy(train_data, test_data, IDs):
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

def predict_by_row(row, df_column_config,modelName,flag_resample,prediction_result_path):
    dataset = row['dataset']
    project = row['project']
    train_path = row['train_path']
    test_path = row['test_path']
    prediction_result_path = os.path.join(prediction_result_path, modelName, dataset)
    if not os.path.exists(prediction_result_path):
        Path(prediction_result_path).mkdir(parents=True, exist_ok=True)

    res_file_name = train_path.split('/')[-1] + '_' + test_path.split('/')[-1]
    if os.path.exists(os.path.join(prediction_result_path, res_file_name)):
        print('skip')
        return 'skip'
    train_data = pd.read_csv(train_path)
    test_data = pd.read_csv(test_path)

    LABEL = df_column_config.loc[dataset, 'label']
    DROPS = df_column_config.loc[dataset, 'drops']
    DROPS = str.split(DROPS, ' ')
    SLOC = df_column_config.loc[dataset, 'sloc']
    IDs = df_column_config.loc[dataset, 'ids']
    IDs = str.split(IDs, ' ')
    print(train_path, ' ', test_path)

    if (sum(train_data[LABEL].values) == 0):
        print("cannot train the prediction model because no buggy instance in training file'")

    else:
        try:
            prediction_result_df, feature_importance = normal_prediction(train_data, test_data, modelName, IDs, LABEL, DROPS, SLOC,flag_resample)
            prediction_result_df.to_csv(os.path.join(prediction_result_path, res_file_name), index=False)
            # if modelName == 'autogluon' or modelName == 'autogluon_best' or modelName=='autogluon_best_recall'or modelName=='autogluon_best_f1':
            #     feature_importance['train_path'] = train_path
            #     feature_importance['test_path'] = test_path
            #     feature_importance.to_csv('feature_importance.csv', index=True, mode='a')
        except ValueError as e:
            # handle the exception raised from bar()
            print(f"An error occurred predicting: {e}")



def run_model_by_config_path(data_split_config_path, data_set_column_config, modelName,flag_resample,prediction_result_path):
    df_config = pd.read_csv(data_split_config_path)
    df_column_config = pd.read_csv(data_set_column_config, index_col=0)

    for idx, row in df_config.iterrows():
       predict_by_row(row, df_column_config, modelName, flag_resample, prediction_result_path)



def run(flag_resample):
    if not flag_resample:
        prediction_result_path = 'prediction_result'
    else:
        prediction_result_path = 'prediction_result_resample'

    # modelNames = ['LR', 'KNN', 'NB', 'RF', 'SVM']
    modelNames = ['autogluon_best_f1']

    for modelName in modelNames:
        run_model_by_config_path(data_split_config_path='./script/dataset_config.csv',
                                 data_set_column_config='./script/dataset_column_config.csv',
                                 modelName=modelName,
                                 flag_resample=flag_resample,
                                 prediction_result_path=prediction_result_path)
        run_model_by_config_path(data_split_config_path='./script/dataset_config_diffToPreviousRelease.csv',
                                 data_set_column_config='./script/dataset_column_config.csv',
                                 modelName=modelName,
                                 flag_resample=flag_resample,
                                 prediction_result_path=prediction_result_path)


flag_run_all = True
if __name__ == '__main__':
    if flag_run_all:
        run(flag_resample=True)
    else:
        parser = argparse.ArgumentParser(
            description="use this file to train and test defect prediction model")

        parser.add_argument("train_file_path")
        parser.add_argument("test_file_path")
        parser.add_argument("--result-path", default="prediction_results")
        parser.add_argument("--label")
        parser.add_argument("--drops")
        parser.add_argument("--sloc")
        parser.add_argument("--ids")
        parser.add_argument("--model")

        args = parser.parse_args()
        model = args.model
        LABEL = [args.label]
        DROPS = args.drops.split()
        SLOC = [args.sloc]
        IDs = args.ids.split()

        print("Loading data...")
        train_data = pd.read_csv(args.train_file_path)
        test_data = pd.read_csv(args.test_file_path)

        if not os.path.exists(args.result_path):
            Path(args.result_path).mkdir(parents=True, exist_ok=True)

        if (sum(train_data[LABEL].values) == 0):
            print('cannot train the prediction model because no buggy instance in training file')
        else:
            df = normal_prediction(train_data, test_data, model, IDs, LABEL)
            result_path = os.path.join(args.result_path, args.train_file_path.split('/')[-1] + '_' +
                                       args.test_file_path.split('/')[-1] + '.csv')
            df.to_csv(result_path, index=False)
