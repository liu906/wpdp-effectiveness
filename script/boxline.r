# library
# install.packages('ggplot2',dependencies = TRUE)
library(ggplot2)
getwd()
setwd('~/PycharmProjects/cross-version/')


build_df <- function(threshold,models){
  df_performance_path_and_model <- data.frame(matrix(ncol = 0,nrow = 0)) 
  if(threshold==-1){
    mode = 'default'
  }else if(threshold <= 1){
    mode = 'SNM'
  }else{
    mode = 'SSC'
  }
  
  for (model in models){
    df_performance_path_and_model[nrow(df_performance_path_and_model)+1,'performance_full_path'] <- paste('./performance/',model,'_',threshold,'_',mode,'_path_config_jureczko.csv',sep = '')
    df_performance_path_and_model[nrow(df_performance_path_and_model),'performance_rm_dup_path'] <- paste('./performance/',model,'_',threshold,'_',mode,'_path_config_jureczko_diffToPreviousRelease.csv',sep = '')
    df_performance_path_and_model[nrow(df_performance_path_and_model),'model_name'] <- model
  }
  return(df_performance_path_and_model)
}

summary_data <- function(df_performance_path_and_model){
  total_df <- data.frame()
  for(i in 1:nrow(df_performance_path_and_model)){
    performance_full_path <- df_performance_path_and_model[i,'performance_full_path']
    performance_rm_dup_path <- df_performance_path_and_model[i,'performance_rm_dup_path']
    model_name <- df_performance_path_and_model[i,'model_name']
    performance_full <- read.csv(performance_full_path)
    performance_rm_dup <- read.csv(performance_rm_dup_path)
    performance_full$variety <- 'full'
    performance_rm_dup$variety <- 'rm_dup'
    performance_full$model <- model_name
    performance_rm_dup$model <- model_name
    
    if (nrow(total_df) == 0){
      total_df <- rbind(performance_full,performance_rm_dup)
    }else{
      total_df <- rbind(total_df,performance_full)
      total_df <- rbind(total_df,performance_rm_dup)
    }
  }
  return(total_df)
}
getwd()
models <- c('KNN1','KNN3','KNN5','KNN10','LR')
thresholds <- c(0.2,20,-1)

for (threshold in thresholds){
  df_performance_path_and_model <- build_df(models = models,threshold = threshold)
  total_df <- summary_data(df_performance_path_and_model)
  total_df$precision <- total_df$tp / (total_df$tp + total_df$fp)
  total_df$model<-factor(total_df$model, levels=models)
  
  if (threshold != -1){
    indicator <- 'roi'
    graph <- ggplot(total_df, aes(x=model, y=roi, fill=variety)) + 
      geom_boxplot()
    ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
  }
  
  indicator <- 'recall'
  graph <- ggplot(total_df, aes(x=model, y=recall, fill=variety)) + 
    geom_boxplot()
  ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
  
  indicator <- 'pf'
  graph <- ggplot(total_df, aes(x=model, y=pf, fill=variety)) + 
    geom_boxplot()
  ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
  
  indicator <- 'f1'
  graph <- ggplot(total_df, aes(x=model, y=f1, fill=variety)) + 
    geom_boxplot()
  ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
  
  indicator <- 'mcc'
  graph <- ggplot(total_df, aes(x=model, y=mcc, fill=variety)) + 
    geom_boxplot()
  ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
  
  indicator <- 'g1'
  graph <- ggplot(total_df, aes(x=model, y=g1, fill=variety)) + 
    geom_boxplot()
  ggsave(paste('jureczko_',indicator,'_',threshold,'.png',sep = ''), graph, path = "~/PycharmProjects/cross-version/statistic/image/",width=100, height=100, unit="mm")
}
