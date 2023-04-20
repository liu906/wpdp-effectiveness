setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd('../')
root <- 'udb'

datasets <- list.files(root)

first_flag <- T
for (dataset in datasets) {
  projects <- list.files(file.path(root,dataset))
  for (project in projects) {
    releases <- list.files(file.path(root,dataset,project))
    releases <- sort(releases)
    for (idx in 1:(length(releases)-1)) {
      pre <- releases[idx]
      nex <- releases[idx+1]
      
      pre_path <- file.path(root,dataset,project,pre)
      nex_path <- file.path(root,dataset,project,nex)
      
      temp <- data.frame(dataset=dataset,project=project,old_udb_path=pre_path,new_udb_path=nex_path,old_release_name=tools::file_path_sans_ext(pre), new_release_name=tools::file_path_sans_ext(nex),module_type='class')
      if(first_flag){
        res <- temp
        first_flag <- F
      }else{
        res <- rbind(res,temp)
      }
    }
    
  }
}

# write.csv(res,file='script/udb_diff.csv',quote = F)

res$command <- apply(res, 1, function(row) {
  paste('python','pureCompare.py',paste(row[3:length(row)], collapse = " "),sep=' ')
})


write.csv(paste(res$command,res$dataset),file='script/compareByUdb.bat',quote = F,row.names = F)
write.csv(paste(res$command,res$dataset),file='script/compareByUdb_file.bat',quote = F,row.names = F)


root <- 'dataset/original/'

datasets <- list.files(root)

first_flag <- T
for (dataset in datasets) {
  if(dataset=='Metrics-Repo-2010'){
    module_type='class'
  }else{
    module_type='file'
  }
  projects <- list.files(file.path(root,dataset))
  for (project in projects) {
    releases <- list.files(file.path(root,dataset,project))
    releases <- sort(releases)
    for (idx in 1:(length(releases)-1)) {
      pre <- releases[idx]
      nex <- releases[idx+1]
      
      pre_path <- file.path(root,dataset,project,pre)
      nex_path <- file.path(root,dataset,project,nex)
      pre_name <- tools::file_path_sans_ext(pre)
      nex_name <- tools::file_path_sans_ext(nex)
      diff_name <- paste(pre_name,nex_name,module_type,sep = '_')
      diff_name <- paste(diff_name,'.csv',sep = '')
      
      temp <- data.frame(dataset=dataset,project=project,train_path=pre_path,test_path=nex_path,diff_path=file.path('dataset/diff',dataset,diff_name))
      if(first_flag){
        res <- temp
        first_flag <- F
      }else{
        res <- rbind(res,temp)
      }
    }
    
  }
}

write.csv(res,file='script/dataset_config.csv',quote = F,row.names = F)


