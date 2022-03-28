setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("summary_performance.r")


get_performance <- function(data_split_config_path,data_set_column_config,dataset,modelName,threshold,mode){
  setwd('/home/lau/PycharmProjects/cross-version/')
  data_split_config = read.csv(data_split_config_path)
  data_column_config = read.csv(data_set_column_config)
  resFolder = data_column_config[data_column_config$datasetName==dataset,'res_folder']
  
  files <- c()
  
  for(i in 1:nrow(data_split_config)){
    train_path = data_split_config[i,'train_path']
    test_path = data_split_config[i,'test_path']
    train_release_name <- strsplit(train_path,'/')[[1]][length(strsplit(train_path,'/')[[1]])]
    test_release_name <- strsplit(test_path,'/')[[1]][length(strsplit(test_path,'/')[[1]])]
    prediction_result_path = paste('./prediction_result/',modelName,'/',resFolder , '/',sep='')
    res_file_name = paste(train_release_name, '_' , test_release_name,sep='')
    
    files <- c(files,paste(prediction_result_path, res_file_name,sep=''))
  }
  res = summaryPerformance_by_files(files = files,threshold = threshold,mode = mode)
  return(res)
  
  
}

data_split_config_paths =c('./script/path_config_jureczko_diffToPreviousRelease.csv',
                           './script/path_config_jureczko.csv')

data_set_column_config ='./script/dataset_column_config.csv'
dataset = 'jureczko'
modelNames = c('LR','KNN1','KNN3','KNN5','KNN10')


# res_default_threshold = summaryPerformance_by_files(files = files,threshold = -1,mode = 'default')
# res_20_SSC = summaryPerformance_by_files(files = files,threshold = 20,mode = 'SSC')
# res_20_SNM = summaryPerformance_by_files(files = files,threshold = 0.2,mode = 'SNM')
for(data_split_config_path in data_split_config_paths){
  for(modelName in modelNames){
    threshold=-1
    mode='default'
    res = get_performance(data_split_config_path,data_set_column_config,dataset,modelName,threshold=-1,mode='default')
    res_path = paste(modelName,threshold,mode,strsplit(data_split_config_path,'/')[[1]][length(strsplit(data_split_config_path,'/')[[1]])],sep = '_')
    write.csv(res,paste('./performance/',res_path,sep=''),row.names = FALSE)
    
    threshold=20
    mode='SSC'
    res = get_performance(data_split_config_path,data_set_column_config,dataset,modelName,threshold=20,mode='SSC')
    res_path = paste(modelName,threshold,mode,strsplit(data_split_config_path,'/')[[1]][length(strsplit(data_split_config_path,'/')[[1]])],sep = '_')
    write.csv(res,paste('./performance/',res_path,sep=''),row.names = FALSE)
    
    threshold=0.2
    mode='SNM'
    res = get_performance(data_split_config_path,data_set_column_config,dataset,modelName,threshold=0.2,mode='SNM')
    res_path = paste(modelName,threshold,mode,strsplit(data_split_config_path,'/')[[1]][length(strsplit(data_split_config_path,'/')[[1]])],sep = '_')
    write.csv(res,paste('./performance/',res_path,sep=''),row.names = FALSE)
  }
}


