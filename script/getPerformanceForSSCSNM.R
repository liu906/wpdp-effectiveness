setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("../../MATTER/performance.r")
library(dplyr)
prediction_result_path <- ('../prediction_result/')
# models <- c('autogluon','KNN','LR','NB','RF','SVM')
models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')
indicators <- c('recall','f1','g1','ifap2','roi_tp','acc','tp','fp','tn','fn','precision','auc_roc')


thresholds = c(20,0.2,-1,0.1,10,0.5,5)

for (model in models) {
  datasets <- list.files(file.path(prediction_result_path,model))
  for (dataset in datasets) {
    root_path <- file.path(prediction_result_path,model,dataset)
    
    for (threshold in thresholds) {
      if(threshold==-1){
        mode = 'default'
      }
      else if(threshold<1){
        mode = 'SNM'
      }else{
        mode = 'SSC'
      }
      res <- summaryPerformance2(root_path=root_path,threshold = threshold, mode=mode)
      target <- res$target
      target <- grepl('diffToPreviousRelease',target)
      target <- ifelse(target, "-dup", "original")
      
      files <- list.files(root_path)
      
      split_strings <- sapply(files, strsplit, split="csv_")
      second_elements <- lapply(split_strings, function(x) x[[2]])
      result <- unlist(second_elements)
      res$target <- result
      res <- cbind(res[1], diffToPreviousRelease = target, res[-1])
      
      dir.create(file.path('../performance/',model),showWarnings=F,recursive=T)
      res_file_path <- file.path('../performance/',model,paste(dataset,threshold,mode,'.csv',sep='_'))
      write.csv(res,file = res_file_path,row.names = FALSE)
    }
    
  }
}




#reformat comparison results to draw box line plot in origin lab
for (dataset in datasets) {
  root_path <- file.path(prediction_result_path,model,dataset)
  
  for (threshold in thresholds) {
    if(threshold==-1){
      mode = 'default'
    }
    else if(threshold<1){
      mode = 'SNM'
    }else{
      mode = 'SSC'
    }
    first_flag <- T
    for (model in models) {
    datasets <- list.files(file.path(prediction_result_path,model))
    res_file_path <- file.path('../performance/',model,paste(dataset,threshold,mode,'.csv',sep='_'))
    sub_df <- read.csv(res_file_path)
    sub_df <- cbind(model = model, sub_df)
    if(first_flag){
      first_flag <- F
      df <- sub_df
    }else{
      df <- rbind(df,sub_df)
    }
    }
    df$diffToPreviousRelease <- factor(df$diffToPreviousRelease, ordered = TRUE, levels = c("original", "-dup"))
    df <- df[order(df$diffToPreviousRelease),]
    write.csv(df,file.path('../performance/',paste('summary',dataset,threshold,mode,'.csv',sep='_')),row.names = F,quote = F)
    
    
    for(indicator in indicators){
      
      my_list <- split(df[,indicator], list(df$diffToPreviousRelease,df$model),sep='$')
      new_df <- as.data.frame(my_list,check.names = F)
      
      new_colnames <- sapply(colnames(new_df), function(x) unlist(strsplit(x, "\\$")))
      rownames(new_colnames) <- c('dup','model')
      new_df <- rbind(new_colnames,new_df)
      write.csv(new_df,file.path('../performance/',paste(indicator,dataset,threshold,mode,'.csv',sep='_')),row.names = T,quote = F)
  
    }
    
  
}
}


#reformat comparison results to draw table of performance delta 
first_flag <- T
for (dataset in datasets) {
  
  
  for (threshold in thresholds) {
    if(threshold==-1){
      mode = 'default'
    }
    else if(threshold<1){
      mode = 'SNM'
    }else{
      mode = 'SSC'
    }
    df <- read.csv(file.path('../performance/',paste('summary',dataset,threshold,mode,'.csv',sep='_')))
    df <- cbind(threshold=threshold,df)
    source_files <- unique(df$source)
    for (model in models) {
      for (source_file in source_files) {
        
        sub_df <- df[df$source==source_file & df$model==model,]
        stopifnot(nrow(sub_df)==2)
        
        delta_ratio <- ((sub_df[2,indicators] - sub_df[1,indicators])/sub_df[1,indicators])*100
        delta_ratio[sub_df[2,indicators]==0 & sub_df[1,indicators]==0]=0
        
        one_row <- cbind(dataset=dataset,sub_df[1,c(1,2,4)],delta_ratio) 
        if(first_flag){
          first_flag <- F
          res <- one_row
        }else{
          res[nrow(res)+1,] <- one_row
        }
        
      }
    }
    
    
  }
}
class(res)


res <- lapply(res, function(x) {
  x[is.infinite(x)] <- NaN
  return(x)
})
res <- as.data.frame(res)

# 求delta的平均值和中位数
delta_result <- res %>% 
  group_by(dataset,model,threshold) %>% 
  summarise(across(indicators, 
                   mean, 
                   na.rm = TRUE))
write.csv(delta_result, file = file.path('../performance/','delta_result_mean.csv'), row.names = FALSE)

delta_result <- res %>% 
  group_by(dataset,model,threshold) %>% 
  summarise(across(indicators, 
                   median, 
                   na.rm = TRUE))
write.csv(delta_result, file = file.path('../performance/','delta_result_median.csv'), row.names = FALSE)





# skESD test rank multiple models 
library(ScottKnottESD)
first_flag <- T
for (dataset in datasets) {
  
  
  for (threshold in thresholds) {
    if(threshold==-1){
      mode = 'default'
    }
    else if(threshold<1){
      mode = 'SNM'
    }else{
      mode = 'SSC'
    }
    total_df <- read.csv(file.path('../performance/',paste('summary',dataset,threshold,mode,'.csv',sep='_')))
    total_df <- cbind(threshold=threshold,total_df)
    diffToPre <- unique(total_df$diffToPreviousRelease)
    
    for (d in diffToPre) {
      df <- total_df[total_df$diffToPreviousRelease==d,]
               
     for (indicator in indicators) {
       
       if(grepl('ifa',indicator)){
         df_list <- split(df[,indicator],df$model) 
       }else{
         df_list <- split(-df[,indicator],df$model) 
       }
       
       sub_df <- data.frame(df_list)
       sk <- sk_esd(sub_df, version='np')
       temp <- t(data.frame(sk$groups))
       temp <- data.frame(cbind(dataset=dataset,diffToPreviousRelease=d,threshold=threshold,mode=mode,indicator=indicator,temp))
       
       if(first_flag){
         first_flag <- FALSE
         res <- temp
       }else{
         as.data.frame(temp[,colnames(res)])
         res <- rbind(res, temp[,colnames(res)])
       }
       
     }
    }
    
  }
}

one_level_res <- res[order(res$mode,res$indicator),]
res_path <- '../performance/one_level_skESD_result.csv'
write.csv(res,res_path,row.names = F,quote = F)

first_flag <- T
for (threshold in thresholds) {
  for (indicator in unique(one_level_res$indicator)) {
    
    for (d in unique(one_level_res$diffToPreviousRelease)) {
      sub_df <- one_level_res[one_level_res$threshold==threshold & one_level_res$indicator==indicator & one_level_res$diffToPreviousRelease==d,models]  
      two_level_result <- sk_esd(data.frame(lapply(sub_df,as.integer)), version='np')$group
      two_level_result <- cbind(threshold=threshold, indicator=indicator, diffToPreviousRelease=d,t(data.frame(two_level_result)))
      if(first_flag){
        first_flag <- F
        total_two_level <- data.frame(two_level_result)
      }else{
        total_two_level[nrow(total_two_level)+1,colnames(data.frame(two_level_result))] <-  data.frame(two_level_result)
      }
    }
  }
}

class(total_two_level)
total_two_level <- total_two_level[order(total_two_level$threshold,total_two_level$indicator),]
total_two_level <- cbind(total_two_level[,1:3],data.frame(lapply(total_two_level[,models],as.integer)))

res_path <- '../performance/two_level_skESD_result.csv'
write.csv(total_two_level,res_path,row.names = F,quote = F)


