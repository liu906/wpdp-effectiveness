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

file.remove(file.path('LR','IND-JLMIV+R-2020',difference))
