setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("../../MATTER/performance.r")

prediction_result_path <- ('../prediction_result/')
models <- c('autogluon','KNN','LR','NB','RF','SVM')
for (model in models) {
  datasets <- list.files(file.path(prediction_result_path,model))
  for (dataset in datasets) {
    root_path <- file.path(prediction_result_path,model,dataset)
    thresholds = c(20,0.2)
    for (threshold in thresholds) {
      if(threshold<1){
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





for (dataset in datasets) {
  root_path <- file.path(prediction_result_path,model,dataset)
  thresholds = c(20,0.2)
  for (threshold in thresholds) {
    if(threshold<1){
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
    indicators <- c('recall','f1','g1','ifap2','roi_tp','acc')
    
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









