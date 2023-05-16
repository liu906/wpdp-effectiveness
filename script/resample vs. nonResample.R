setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
resample_root <- ('../performance_resample/')
origin_root <- ('../performance/')
indicators <- c('recall','f1','g1','tp','fp','tn','fn','precision','auc_roc')
posfix <- 'default'

files_resample <- list.files(resample_root,pattern = paste('^',indicator,'.*',posfix,sep=''))
files <- list.files(origin_root,pattern = paste('^',indicator,'.*',posfix,sep=''))

idx <- 1
model <- 'RF'
for (file in files) {
  df_origin <- read.csv(file.path(origin_root,file))
  sub_df_origin <- df_origin[,grepl(model,df_origin)]
  df_resample <- read.csv(file.path(resample_root,file))
  sub_df_resample <- df_resample[,grepl(model,df_resample)]
  cbind(sub_df_origin,sub_df_resample)
}
