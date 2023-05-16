setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
resample_root <- ('../performance_resample/')
origin_root <- ('../performance/')

indicators <- c('recall','f1','g1','tp','fp','tn','fn','precision','auc_roc')
posfix <- 'default'

if(F){
  models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')
}else{
  # models <- c('autogluon_best_f1','KNN','LR','NB','RF','SVM')
  models <- c('RF')
}
for (model in models) {
  
}
for (indicator in indicators) {
  files_resample <- list.files(resample_root,pattern = paste('^',indicator,'.*',posfix,sep=''))
  files <- list.files(origin_root,pattern = paste('^',indicator,'.*',posfix,sep=''))
  for (file in files) {
    df_origin <- read.csv(file.path(origin_root,file))
    sub_df_origin <- df_origin[,grepl(model,df_origin)]
    df_resample <- read.csv(file.path(resample_root,file))
    sub_df_resample <- df_resample[,grepl(model,df_resample)]
    res <- cbind(sub_df_origin,sub_df_resample)
    colnames(res) <- c('original','origial+noDup','smote','smote+noDup')
    write.csv(res,file = file.path(origin_root, paste('comparedToSmote_',model,'_',file,sep = '')),row.names = F,quote = F)
  }
}
