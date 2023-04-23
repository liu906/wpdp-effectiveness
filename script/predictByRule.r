setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
library(gtools)
require(sqldf)

bugDistribution <- function(root_path,id_colnames,defect_colnames,label_name,defects_name){
  res_colnames <- c(c('project','currentVersion','nextVersion',
                      '#ModuleInCurrentVersion','#ModuleInNextVersion',
                      '#DefectiveInNewModule','#DefectiveInOldModule',
                      '%DefectiveInNewModule','%DefectiveInOldModule'),
                    id_colnames)
  res <- data.frame(matrix(nrow = 0,ncol = length(res_colnames)))
  colnames(res) <- res_colnames
  projects <- list.files(root_path)
  counter <- 1
  for(project in projects){
    cat('project: ',project,'\n')
    cat(counter,'/',length(projects),'\n')
    counter <- counter + 1
    
    versions <- list.files(paste(root_path,'/',project,sep = ''))
    versions <- mixedsort(versions)
    if(length(versions)>=2){
      for(idx_version in 1:(length(versions)-1)){
        current_version <- versions[idx_version]
        current_path <- paste(root_path,'/',project,'/',current_version,sep = '')
        current_data <- read.csv(current_path)
        
        next_version <- versions[idx_version+1]
        next_path <- paste(root_path,'/',project,'/',next_version,sep = '')
        next_data <- read.csv(next_path)
        next_data$id <- next_data[,id_colnames]
          
      
        
        next_data_id <- next_data[,id_colnames[1]]
        current_data_id <- current_data[,id_colnames[1]]
        if(length(id_colnames)>=2){
          for (idx in 2:length(id_colnames)){
            next_data_id <- paste(next_data_id,next_data[,id_colnames[idx]])
            current_data_id <- paste(current_data_id,current_data[,id_colnames[idx]])
          }
        }
        current_data$id <- current_data_id
        next_data$id <- next_data_id
        
        common_id_data <- sqldf('SELECT next_data.* FROM next_data INNER JOIN current_data ON next_data.id = current_data.id')
        new_in_next_data <- sqldf('SELECT * FROM next_data EXCEPT SELECT * FROM common_id_data')
        new_in_next_data <- data.frame(new_in_next_data)
        
        num_DefectiveInNewModule <- sum(new_in_next_data[,label_name])
        num_DefectiveInOldModule <- sum(common_id_data[,label_name])
        per_DefectiveInNewModule <- sum(new_in_next_data[,label_name]) / nrow(new_in_next_data)
        per_DefectiveInOldModule <- sum(common_id_data[,label_name]) / nrow(common_id_data)
       
        res[nrow(res)+1,] <- c(project,current_version,next_version,
                               nrow(current_data),nrow(next_data),
                               num_DefectiveInNewModule,num_DefectiveInOldModule,
                               per_DefectiveInNewModule,per_DefectiveInOldModule,
                               id_colnames)
      }
    }
  }
  write.csv(res,paste(root_path,'_','defectDistribution.csv',sep=''),row.names = FALSE)  
}
root_path <- 'cross-version-instance-overlap/ESEM2016-master/ClassLevel_processed'
id_colnames <- c('Class','Package')
defect_colnames <- c("NumberOfDefects", "Defective")
label_name <- "Defective"
defects_name <- c("NumberOfDefects")
bugDistribution(root_path=root_path,id_colnames=id_colnames,
              label_name = label_name,
              defect_colnames=defect_colnames,defects_name=defects_name)

root_path <- 'ESEM2016-master/MethodLevel_processed'
id_colnames <- c('Class','Package','Method')
defect_colnames <- c("DEFECTIVE")
label_name <- "DEFECTIVE"
defects_name <- "DEFECTIVE"
bugDistribution(root_path=root_path,id_colnames=id_colnames,
              label_name = label_name,
              defect_colnames=defect_colnames,defects_name=defects_name)


root_path <- 'JURECZKO/data_preprocessed_selected'
id_colnames <- c('Project','Class')
defect_colnames <- c("bugs","defective")
label_name <- "defective"
defects_name <- "bugs"
bugDistribution(root_path=root_path,id_colnames=id_colnames,
              label_name = label_name,
              defect_colnames=defect_colnames,defects_name=defects_name)




