make_table <- function(prefix,pattern,postfix,datasets){
  files <- list.files(path='./performance',pattern=pattern)  
  median_table <- data.frame(matrix(nrow = length(datasets),ncol = length(files) / length(datasets)))
  median_table <- data.frame()
  mean_table <- data.frame(matrix(nrow = length(datasets),ncol = length(files) / length(datasets)))
  mean_table <- data.frame()
  indicators <- c('recall','f1','pf','mcc')
  for(indicator in indicators){
    for(file in files){
      data <- read.csv(file=paste('./performance/',file,sep=''))
      if(length(strsplit(file,'_')[[1]])==5){
        median_table[paste(strsplit(file,'_')[[1]][2],
                           strsplit(file,'_')[[1]][3],sep='_'),strsplit(file,'_')[[1]][1]] <- median(data[,indicator])
        mean_table[paste(strsplit(file,'_')[[1]][2],
                         strsplit(file,'_')[[1]][3],sep='_'),strsplit(file,'_')[[1]][1]] <- mean(data[,indicator])
      }else if(length(strsplit(file,'_')[[1]])==4){
        median_table[strsplit(file,'_')[[1]][2], strsplit(file,'_')[[1]][1]] <- median(data[,indicator])
        mean_table[strsplit(file,'_')[[1]][2], strsplit(file,'_')[[1]][1]] <- mean(data[,indicator])
      }
    }
    write.csv(median_table,paste(prefix,indicator,'_median',postfix,'.csv',sep=""),row.names = TRUE)
    write.csv(mean_table,paste(prefix,indicator,'_mean',postfix,'.csv',sep=""),row.names = TRUE)
  }
}

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

datasets <- c('ELFF_class','ELFF_Method','JURECZKO')
make_table(pattern = 'KNN[0-9]_.*_result_0.2.csv',prefix = 'statistic/KNN_',postfix = '0.2',datasets=datasets)
make_table(pattern = 'KNN[0-9]_.*_result_20.csv',prefix = 'statistic/KNN_',postfix = '20',datasets=datasets)

make_table(pattern = 'KNN[0-9]_.*_result_0.05.csv',prefix = 'statistic/KNN_',postfix = '0.05',datasets=datasets)
make_table(pattern = 'KNN[0-9]_.*_result_5.csv',prefix = 'statistic/KNN_',postfix = '5',datasets=datasets)

make_table(pattern = 'KNN[0-9]_.*_result_0.1.csv',prefix = 'statistic/KNN_',postfix = '0.1',datasets=datasets)
make_table(pattern = 'KNN[0-9]_.*_result_10.csv',prefix = 'statistic/KNN_',postfix = '10',datasets=datasets)


make_table(pattern = 'KNN[0-9]_.*_result_0.01.csv',prefix = 'statistic/KNN_',postfix = '0.01',datasets=datasets)
make_table(pattern = 'KNN[0-9]_.*_result_1.csv',prefix = 'statistic/KNN_',postfix = '1',datasets=datasets)

