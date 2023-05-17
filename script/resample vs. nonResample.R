setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
library(effsize)
resample_root <- ('../performance_resample/')
origin_root <- ('../performance/')
res_root <- ('../performance/comparedSmote')
dir.create(res_root,showWarnings = F)
indicators <- c('recall','f1','g1','tp','fp','tn','fn','precision','auc_roc')
posfix <- 'default'

if(F){
  models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')
}else{
  models <- c('autogluon_best_f1','KNN','LR','NB','RF','SVM')
  # models <- c('RF')
}
pvalue_df <- data.frame()
for (model in models) {
  for (indicator in indicators) {
    files_resample <- list.files(resample_root,pattern = paste('^',indicator,'.*',posfix,sep=''))
    files <- list.files(origin_root,pattern = paste('^',indicator,'.*',posfix,sep=''))
    for (file in files) {
      df_origin <- read.csv(file.path(origin_root,file))
      sub_df_origin <- df_origin[,grepl(model,colnames(df_origin))]
      df_resample <- read.csv(file.path(resample_root,file))
      sub_df_resample <- df_resample[,grepl(model,colnames(df_resample))]
      res <- cbind(sub_df_origin,sub_df_resample)
      colnames(res) <- c('original','origial+noDup','smote','smote+noDup')
      res[1,] <- rep(indicator,4)
      dataset <- strsplit(strsplit(file,indicator)[[1]][2],'_')[[1]][2]
      row_dataset <- rep(dataset,4)
      res <- rbind(row_dataset,res)
      getNumeric <- function(one_column){
        return(as.numeric(one_column[4:length(one_column)]))
      }
      pvalue.origin <- wilcox.test(getNumeric(res$original),getNumeric(res$`origial+noDup`) ,paired = T)$p.value
      pvalue.smote <- wilcox.test(getNumeric(res$smote),getNumeric(res$`smote+noDup`) ,paired = T)$p.value
      eff.origin <- cliff.delta(getNumeric(res$original),getNumeric(res$`origial+noDup`))$magnitude
      eff.smote <- cliff.delta(getNumeric(res$smote),getNumeric(res$`smote+noDup`))$magnitude
      pvalue_df <-  rbind(pvalue_df,data.frame(model,indicator,dataset,pvalue.origin,eff.origin,pvalue.smote,eff.smote))
      
      dir.create(file.path(res_root,model),showWarnings = F)
      write.csv(res,file = file.path(res_root,model, paste(indicator,'_',dataset,'.csv',sep = '')),row.names = F,quote = F)
    }
  }
}

write.csv(pvalue_df,file = file.path(res_root,'wilcoxon-pvalue-dupVsNonDup.csv'),row.names = F,quote = F)
          