setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd('../prediction_result/')
models <- c('autogluon/','KNN/','LR/','NB/','RF/','SVM/')
for (model in models) {
  files <- list.files(model,pattern = '*.csv',recursive = T)
  cat(model,length(files),'\n')
}
for (model in list.files('LR')) {
  files <- list.files(file.path('LR',model),pattern = '*.csv',recursive = T)
  cat(model,length(files),'\n')
}

files <- list.files(file.path('LR','IND-JLMIV+R-2020'),pattern = '*.csv',recursive = T)
files2 <- list.files(file.path('KNN','IND-JLMIV+R-2020'),pattern = '*.csv',recursive = T)
length(files)
length(files2)
intersect(files, files2)
difference <- setdiff(files, files2)
train_file <- c()
for (idx in 1:length(strsplit(difference,'_'))) {
  train_file <- append(train_file, strsplit(difference,'_')[[idx]][1])
}

file_to_delete <- unique(train_file)
getwd()
write.csv(file_to_delete,'trainSet_need_to_be_removed.csv')

file.remove(file.path('LR','IND-JLMIV+R-2020',difference))

origin_files <- list.files(file.path('../dataset/original/IND-JLMIV+R-2020/'),recursive = T)
for(file in file_to_delete){
  df <- read.csv(file.path('../dataset/original/IND-JLMIV+R-2020/',origin_files[grep(file,origin_files)]))
  cat(nrow(df),sum(df$bug==1), '\n')
}
#所以LR的训练集可以没有阳性样本，但是其他的方法都要求训练集必须要有阳性样本。因此我们的数据集过滤条件就是过滤掉所有的不含阳性样本的训练集。
