setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("../../MATTER/performance.r")
library(dplyr)

reformat <- function(res,indicator){
  res <- res %>% group_by(source)
  
  res <- res %>% mutate(Difference = last({{indicator}}) - first({{indicator}}))
  
  a <- res %>% filter(diffToPreviousRelease == 'original') %>%
    select(source,Difference,{{indicator}})
  b <- res %>% filter(diffToPreviousRelease == '-dup') %>%
    select({{indicator}})
  a <- as.data.frame(a)
  b <- as.data.frame(b)[,2]
  df <- cbind(a,noDup=b)
  return(df[order(df$Difference),])
}


# models <- c('autogluon','KNN','LR','NB','RF','SVM')
indicators <- c('recall','f1','g1','ifap2','roi_tp','acc','tp','fp','tn','fn','precision','auc_roc')


if(T){
  performance_root <- '../performance/'
  prediction_result_path <- ('../prediction_result/')
}else{
  performance_root <- '../performance_resample'
  prediction_result_path <- ('../prediction_result_resample/')
}
dir.create(performance_root,showWarnings = F)

if(F){
  models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')
}else{
  models <- c('autogluon_best_f1','KNN','LR','NB','RF','SVM')
}

if(F){
  thresholds = c(20,0.2,-1,0.1,10,0.5,5)
}else{
  thresholds = c(-1)
}


for (model in models) {
  datasets <- list.files(file.path(prediction_result_path,model))
  for (dataset in datasets) {
    root_path <- file.path(prediction_result_path,model,dataset)
    
    for (threshold in thresholds) {
      if(threshold==-1){
        mode = 'default'
        
      }else if(threshold<1){
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
      dir.create(file.path(performance_root,model),showWarnings=F,recursive=T)
      res_file_path <- file.path(performance_root,model,paste(dataset,threshold,mode,'.csv',sep='_'))
      write.csv(res,file = res_file_path,row.names = FALSE)
      
      #simple output for line plot      
      r <- reformat(res,recall)
      linePlot_file_path <- file.path(performance_root,model,paste('linePlot',dataset,threshold,mode,'recall','.csv',sep='_'))
      write.csv(r,file = linePlot_file_path,row.names = FALSE)
      r <- reformat(res,precision)
      linePlot_file_path <- file.path(performance_root,model,paste('linePlot',dataset,threshold,mode,'precision','.csv',sep='_'))
      write.csv(r,file = linePlot_file_path,row.names = FALSE)
      r <- reformat(res,f1)
      linePlot_file_path <- file.path(performance_root,model,paste('linePlot',dataset,threshold,mode,'f1','.csv',sep='_'))
      write.csv(r,file = linePlot_file_path,row.names = FALSE)
      r <- reformat(res,g1)
      linePlot_file_path <- file.path(performance_root,model,paste('linePlot',dataset,threshold,mode,'g1','.csv',sep='_'))
      write.csv(r,file = linePlot_file_path,row.names = FALSE)
      r <- reformat(res,auc_roc)
      linePlot_file_path <- file.path(performance_root,model,paste('linePlot',dataset,threshold,mode,'auc_roc','.csv',sep='_'))
      write.csv(r,file = linePlot_file_path,row.names = FALSE)
    
    }
    
  }
}





#reformat comparison results to draw box line plot in origin lab
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
    first_flag <- T
    for (model in models) {
    datasets <- list.files(file.path(prediction_result_path,model))
    res_file_path <- file.path(performance_root,model,paste(dataset,threshold,mode,'.csv',sep='_'))
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
    write.csv(df,file.path(performance_root,paste('summary',dataset,threshold,mode,'.csv',sep='_')),row.names = F,quote = F)
    
    
    for(indicator in indicators){
      
      my_list <- split(df[,indicator], list(df$diffToPreviousRelease,df$model),sep='$')
      new_df <- as.data.frame(my_list,check.names = F)
      
      new_colnames <- sapply(colnames(new_df), function(x) unlist(strsplit(x, "\\$")))
      rownames(new_colnames) <- c('dup','model')
      new_df <- rbind(new_colnames,new_df)
      new_df['model',new_df['model',]=='autogluon_best_f1'] = 'Auto'
      write.csv(new_df,file.path(performance_root,paste(indicator,dataset,threshold,mode,'.csv',sep='_')),row.names = T,quote = F)
  
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
    df <- read.csv(file.path(performance_root,paste('summary',dataset,threshold,mode,'.csv',sep='_')))
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
write.csv(delta_result, file = file.path(performance_root,'delta_result_mean.csv'), row.names = FALSE)

delta_result <- res %>% 
  group_by(dataset,model,threshold) %>% 
  summarise(across(indicators, 
                   median, 
                   na.rm = TRUE))
write.csv(delta_result, file = file.path(performance_root,'delta_result_median.csv'), row.names = FALSE)





# skESD test rank multiple models 
library(ScottKnottESD)
first_flag <- T
datasets <- list.files(file.path(prediction_result_path,models[1]))
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
    total_df <- read.csv(file.path(performance_root,paste('summary',dataset,threshold,mode,'.csv',sep='_')))
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
res_path <- file.path(performance_root,'one_level_skESD_result.csv')  
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

res_path <- file.path(performance_root,'two_level_skESD_result.csv')
write.csv(total_two_level,res_path,row.names = F,quote = F)



one_level_res
total_two_level



#compute Kendall's tau-b and Spearman's rank correlation coefficient to compare two rankings
# 按照 col1 和 col2 进行拆分
one_level_list <- split(one_level_res, list(one_level_res$dataset, one_level_res$threshold,one_level_res$indicator),sep='/')

two_level_list <- split(total_two_level, list(total_two_level$threshold, total_two_level$indicator),sep='/')

compute_k <- function(df) {
  # 在这里进行对子数据框的操作
  # 计算 Kendall's tau-b
  
  k <- cor(as.numeric(df[1,models]),as.numeric(df[2,models]), method = "kendall")
  if(is.na(k)){
    cat(as.numeric(df[1,models]),'\n')
    cat(as.numeric(df[2,models]),'\n')
    
  }
  return(k)
}
compute_s <- function(df) {
  # 在这里进行对子数据框的操作
  # 计算 Spearman's rho
  s <- cor(as.numeric(df[1,models]),as.numeric(df[2,models]), method = "spearman")
  
  return(s)
}
compute_p <- function(df) {
  # 在这里进行对子数据框的操作
  # 计算 Pearson correlation 
  s <- cor(as.numeric(df[1,models]),as.numeric(df[2,models]), method = "pearson")
  
  return(s)
}
compute_wilcox <- function(df) {
  # 在这里进行对子数据框的操作
  # 计算 Pearson correlation 
  
  w <- wilcox.test(as.numeric(df[1,models]),as.numeric(df[2,models]), paired = TRUE)$p.value
  if(is.na(w) || is.nan(w)){
    cat(as.numeric(df[1,models]),'\n')
    cat(as.numeric(df[2,models]),'\n')
  }
  return(w)
}


# 使用 lapply() 函数将每个子数据框传递给函数进行操作，并将结果存储在一个列表中
one_results_k <- lapply(one_level_list, compute_k)
two_results_k <- lapply(two_level_list, compute_k)
one_results_s <- lapply(one_level_list, compute_s)
two_results_s <- lapply(two_level_list, compute_s)
one_results_p <- lapply(one_level_list, compute_p)
two_results_p <- lapply(two_level_list, compute_p)
one_results_wilcox <- lapply(one_level_list, compute_wilcox)
two_results_wilcox <- lapply(two_level_list, compute_wilcox)

transform_list <- function(df_list){
  my_matrix <- do.call(cbind, strsplit(names(df_list),'/'))
  my_df <- as.data.frame(t(as.data.frame(my_matrix)))
  my_array <- as.numeric(unlist(df_list)) 
  my_df$cor <-  my_array
  colnames(my_df) <- c('dataset','threshold','indicator')
  return(my_df)
}
write.csv(transform_list(one_results_k),file.path(performance_root,'one_level_skESD_Kendall.csv'),row.names = F,quote = F)
write.csv(transform_list(one_results_s),file.path(performance_root,'one_level_skESD_Spearman.csv'),row.names = F,quote = F)
write.csv(transform_list(one_results_p),file.path(performance_root,'one_level_skESD_Pearson.csv'),row.names = F,quote = F)
write.csv(transform_list(two_results_k),file.path(performance_root,'two_level_skESD_Kendall.csv'),row.names = F,quote = F)
write.csv(transform_list(two_results_s),file.path(performance_root,'two_level_skESD_Spearman.csv'),row.names = F,quote = F)
write.csv(transform_list(two_results_p),file.path(performance_root,'two_level_skESD_Pearson.csv'),row.names = F,quote = F)



# 把所有数据集的rank拼接在一起把样本变大，计算wilcox

one_level_list2 <- split(one_level_res, list(one_level_res$threshold,one_level_res$indicator),sep='/')
compute_wilcox_allDataset <- function(df) {
  # 在这里进行对子数据框的操作
  # 计算 Kendall's tau-b
  split_res <- split(df,list(df$diffToPreviousRelease))
  df_origin <- split_res$original
  df_noDup <- split_res$`-dup`
  
  
  w <- wilcox.test(as.numeric(t(unlist(df_origin[,models]))),as.numeric(t(unlist(df_noDup[,models]))), paired = T)$p.value
  return(w)
}
one_results_wilcox_allDataset <- lapply(one_level_list2, compute_wilcox_allDataset)
res <- transform_list(one_results_wilcox_allDataset)
colnames(res) <- c('threshold','indicator','p-value')
write.csv(res,file.path(performance_root,'one_level_skESD_wilcox_allDataset.csv'),row.names = F,quote = F)


