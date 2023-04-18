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

write.csv(res,file='script/dataset_config.csv',quote = F)

res$command <- apply(res, 1, function(row) {
  paste('python','pureCompare.py',paste(row[3:length(row)], collapse = " "),sep=' ')
})


write.csv(paste(res$command,res$dataset),file='script/compareByUdb.sh',quote = F,row.names = F)
