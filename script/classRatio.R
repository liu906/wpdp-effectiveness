
#########compute class ratio before and after deleting duplicate instances
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv('dataset_config.csv')
df_noDup <- read.csv('dataset_config_diffToPreviousRelease.csv')
colnames(df_noDup)[colnames(df_noDup)=="test_path"]="test_path_noDup"
merged_df <- merge(df, df_noDup, by = c("train_path","dataset","project"))
colnames(merged_df)
setwd('../')
getwd()

for (idx in 1:nrow(merged_df)) {
  one_row <- merged_df[idx,]
  test_df <- read.csv(one_row$test_path)
  test_noDup_df <- read.csv(one_row$test_path_noDup)
  
  ratio <- table(test_df$bug)["0"]/table(test_df$bug)["1"]
  num_neg <- table(test_df$bug)["0"]
  num_pos <- table(test_df$bug)["1"]
  
  ratio_noDup <- table(test_noDup_df$bug)["0"]/table(test_noDup_df$bug)["1"]
  num_neg_noDup <- table(test_noDup_df$bug)["0"]
  num_pos_noDup <- table(test_noDup_df$bug)["1"]
  
  merged_df[idx,'class_ratio'] <- ratio
  merged_df[idx,'class_ratio_noDup'] <- ratio_noDup
  merged_df[idx,'num_neg'] <- num_neg
  merged_df[idx,'num_pos'] <- num_pos
  merged_df[idx,'num_neg_noDup'] <- num_neg_noDup
  merged_df[idx,'num_pos_noDup'] <- num_pos_noDup
}
write.csv(merged_df,'./script/dataset_classRatio.csv',row.names = F)
# conclusion is class is more balanced after deleting duplicate instances, 
# because most of the duplicate instances are labeled as clean, which is easy to understand,
# since clean instances are more possible to be kept unchanged in the next release than buggy instances 



#########compute effort required under default threshold
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

prediction_result_path <- ('../prediction_result/')
# models <- c('autogluon','KNN','LR','NB','RF','SVM')
models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','KNN','LR','NB','RF','SVM')
first_flag <- T
for (model in models) {
  datasets <- list.files(file.path(prediction_result_path,model))
  for (dataset in datasets) {
    root_path <- file.path(prediction_result_path,model,dataset)
    files <- list.files(root_path)
    for (file in files) {
      mode <- grepl('diffToPreviousRelease',file)
      mode <- ifelse(mode, "noDup", "original")
      df <- read.csv(file.path(root_path,file))
      if( is.na(table(df$predictLabel)["1"])){
        context_switch_effort <- 0
      }else{
        context_switch_effort <- (table(df$predictLabel)["1"]/nrow(df))*100
      }
      
      sloc_effort <- (sum(df[df$predictLabel==1,'sloc'])/sum(df[,'sloc']))*100
      temp <- data.frame(model=model,dataset=dataset,mode=mode,file=file,context_switch_effort=context_switch_effort,sloc_effort=sloc_effort)
      if(first_flag){
        first_flag <- F
        total_res <- temp
      }else{
        total_res <- rbind(total_res,temp)
      }
    }
  }
}
total_res[total_res$model=='autogluon_best','model'] <- 'AG(A)'
total_res[total_res$model=='autogluon_best_f1','model'] <- 'AG(F)'
total_res[total_res$model=='autogluon_best_recall','model'] <- 'AG(R)'
write.csv(total_res,'defualtEffort.csv',row.names = F,quote = F)


##################################################################
#######analyze instance by instance between dup and noDup#########
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()


prediction_result_path <- ('../prediction_result/')
# models <- c('autogluon','KNN','LR','NB','RF','SVM')
models <- c('autogluon_best_f1','autogluon_best_recall','autogluon_best','autogluon','KNN','LR','NB','RF','SVM')

first_flag <- T
for (model in models) {
  datasets <- list.files(file.path(prediction_result_path,model))
  for (dataset in datasets) {
    root_path <- file.path(prediction_result_path,model,dataset)
    files <- list.files(root_path)
    files_noDup <- files[grepl('diffToPreviousRelease',files)]
    files_noDup <- sort(files_noDup)
    files_Dup <- files[!grepl('diffToPreviousRelease',files)]
    files_Dup <- sort(files_Dup)
    stopifnot(length(files_noDup)==length(files_Dup))
    for (idx in 1:length(files_noDup)) {
      file_noDup <- files_noDup[idx]
      file_Dup <- files_Dup[idx]
      df_noDup <- read.csv(file.path(root_path,file_noDup))
      df_Dup <- read.csv(file.path(root_path,file_Dup))
      
      keep <- df_Dup[,1] %in% df_noDup[,1]
      df_Dup <- cbind(df_Dup,keep)
      table(df_Dup[df_Dup$predictLabel==1,'keep'])
      table(df_Dup[df_Dup$predictLabel==0,'keep'])
      tp <- table(df_Dup[df_Dup$predictLabel==1 & df_Dup$actualBugLabel==1,'keep'])["FALSE"]
      fp <- table(df_Dup[df_Dup$predictLabel==1 & df_Dup$actualBugLabel==0,'keep'])["FALSE"]
      fn <- table(df_Dup[df_Dup$predictLabel==0 & df_Dup$actualBugLabel==1,'keep'])["FALSE"]
      tn <- table(df_Dup[df_Dup$predictLabel==0 & df_Dup$actualBugLabel==0,'keep'])["FALSE"]
      correct_value <- function(x){
        if(is.na(x)){
          x <- 0
        }
        return(x)
      }
      arr <- lapply(c(tp,fp,tn,fn), correct_value)
      
      
      temp <- data.frame(model=model,dataset=dataset,file=file_Dup,
                         tp=arr[[1]],
                         fp=arr[[2]],
                         tn=arr[[3]],
                         fn=arr[[4]])
      if(first_flag){
        first_flag <- F
        res <- temp
      }else{
        res[nrow(res)+1,] <- temp
      }
    }
  }
}

write.csv(res,'deletedInstancesAnalyze.csv',row.names = F,quote = F)

