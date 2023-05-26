setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
library(effsize)
resample_root <- ('../performance_resample/')
origin_root <- ('../performance/')
res_root <- ('../performance/comparedSmote')
dir.create(res_root,showWarnings = F)
indicators <- c('recall','f1','g1','tp','fp','tn','fn','precision','auc_roc')
posfix <- 'default'
compute_eff <-function(value){
  if(abs(value)<0.1){
    return("negligible")
  }
  else if(abs(value)<0.3){
    return("small")
  }else if(abs(value)<0.5){
    return("medium")
  }else{
    return("large")
  }
}
get_eff_size <- function(x,y,type){
  if(type=='cliff'){
    return(as.character(cliff.delta(x,y)$magnitude) )
  }else if(type=='wilcox'){
    #compute another effect size
    pvalue <- wilcox.test(x,y,paired=T)$p.value
    if(!is.nan(pvalue)){
      z <- qnorm(1 - pvalue/2)
      
    }else{
      z <- qnorm(1 - 1/2)
    }
    if(!is.nan(pvalue)){
      z.smote <- qnorm(1 - pvalue/2)
    }else{
      z <- qnorm(1 - 1/2)
    }
    return(compute_eff(z / sqrt(length(x))))
  }
}


if(F){
  models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')
}else{
  models <- c('autogluon_best_f1','KNN','LR','NB','RF','SVM')
  # models <- c('RF')
}
pvalue_df <- data.frame()
mean_df <- data.frame()
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
      
      #compute cliff's delta effect size
      eff.origin <- cliff.delta(getNumeric(res$original),getNumeric(res$`origial+noDup`))$magnitude
      eff.smote <- cliff.delta(getNumeric(res$smote),getNumeric(res$`smote+noDup`))$magnitude
      
      

      

      
      
      
      eff2.origin <-  get_eff_size(getNumeric(res$original),getNumeric(res$`origial+noDup`),'wilcox') #compute_eff(z / sqrt(length(res$original)))  
      eff2.smote <- get_eff_size(getNumeric(res$smote),getNumeric(res$`smote+noDup`),'wilcox') #compute_eff(z.smote / sqrt(length(res$smote))) 
      
      
      pvalue_df <-  rbind(pvalue_df,data.frame(model,indicator,dataset,pvalue.origin,eff.origin,eff2.origin,pvalue.smote,eff.smote,eff2.smote))
      mean_df <- rbind(mean_df,data.frame(model,indicator,dataset,original=mean(getNumeric(res$original)),
                                          `origial+noDup`=mean(getNumeric(res$`origial+noDup`)),
                                          smote=mean(getNumeric(res$smote)),
                                          `smote+noDup`=mean(getNumeric(res$`smote+noDup`))))
      
      
      dir.create(file.path(res_root,model),showWarnings = F)
      write.csv(res,file = file.path(res_root,model, paste(indicator,'_',dataset,'.csv',sep = '')),row.names = F,quote = F)
    }
  }
}

write.csv(pvalue_df,file = file.path(res_root,'wilcoxon-pvalue-dupVsNonDup.csv'),row.names = F,quote = F)
write.csv(mean_df,file = file.path(res_root,'meanValue-dupVsNonDup.csv'),row.names = F,quote = F)
      

library(dplyr)



summary_mean_alldataset <- function(origin_root){
  summary_files <- list.files(origin_root,pattern = '^summary.*default_.csv')
  
  res_df <- data.frame()
  for(file in summary_files){
    df <- read.csv(file = file.path(origin_root,file))
    df <- cbind(dataset=strsplit(file,'_')[[1]][2],df)
    res_df <- rbind(res_df,df)
  }
  result <- res_df %>%
    group_by(model, diffToPreviousRelease) %>%
    summarise(across(7:ncol(res_df)-2, mean))
  return(as.data.frame(result))
}
summary_pvalue_alldataset <- function(origin_root,resample_root){
  summary_files <- list.files(origin_root,pattern = '^summary.*default_.csv')
  res_df <- data.frame()
  for(file in summary_files){
    df <- read.csv(file = file.path(origin_root,file))
    df <- cbind(dataset=strsplit(file,'_')[[1]][2],df)
    res_df <- rbind(res_df,df)
  }
  summary_files2 <- list.files(resample_root,pattern = '^summary.*default_.csv')
  res_df2 <- data.frame()
  for(file in summary_files){
    df <- read.csv(file = file.path(resample_root,file))
    df <- cbind(dataset=strsplit(file,'_')[[1]][2],df)
    res_df2 <- rbind(res_df2,df)
  }
  
  result <- data.frame()
  for(model in models){
    sub_res_df <- res_df[res_df$model==model,]
    sub_res_df2 <- res_df2[res_df2$model==model,]
    calculate_pvalue <- function(df1,df2){
      df_pvalue <- data.frame()
      
      for (idx in 7:ncol(df1)) {
        pvalue <- wilcox.test(df1[,idx],df2[,idx],paired=T)$p.value
        #cliff <- as.character(cliff.delta(df1[,idx],df2[,idx])$magnitude) 
        eff_size <- get_eff_size(df1[,idx],df2[,idx],'wilcox')
        
        temp <- data.frame(indicator=colnames(df1)[idx],pvalue=pvalue,eff_size=eff_size)
        df_pvalue <- rbind(df_pvalue,temp)
      }
      return(df_pvalue)
    }
    
    sub_result <- calculate_pvalue(df1=sub_res_df[sub_res_df$diffToPreviousRelease=='original',],
                     df2=sub_res_df2[sub_res_df2$diffToPreviousRelease=='original',])
    sub_result_noDup <- calculate_pvalue(df1=sub_res_df[sub_res_df$diffToPreviousRelease=='-dup',],
                                   df2=sub_res_df2[sub_res_df2$diffToPreviousRelease=='-dup',])
    sub_result <- cbind(model=model,
                        indicator=sub_result$indicator, 
                        pvalue_smote_dup=sub_result$pvalue,
                        eff_smote_dup=sub_result$eff_size,
                        pvalue_smote_nodup=sub_result_noDup$pvalue,
                        eff_smote_nodup=sub_result_noDup$eff_size)
    
    result <- rbind(result,sub_result)
  }
  
  return(result)
}
origin_res <- summary_mean_alldataset(origin_root)
resample_res <- summary_mean_alldataset(resample_root)
res <- rbind(cbind(resample=F,origin_res),cbind(resample=T,resample_res))
res <- res[,c('resample','model','diffToPreviousRelease',indicators)]
write.csv(res[order(res$model),],file=file.path(origin_root,'total_mean_allDataset.csv'),row.names = F)


res_pvalue <- summary_pvalue_alldataset(origin_root,resample_root)

res_pvalue <- res_pvalue[res_pvalue$indicator %in% c('recall', 'precision', 'f1', 'g1', 'auc_roc'),]


# 定义顺序
desired_order <- c('recall', 'precision', 'f1', 'g1', 'auc_roc')

# 根据顺序创建索引
order_index <- match(res_pvalue$indicator, desired_order)

# 按照索引重新排序数据框
res_pvalue <- res_pvalue[order(order_index), ]

write.csv(res_pvalue,file=file.path(origin_root,'total_pvalue_allDataset.csv'),row.names = F,quote = F)


