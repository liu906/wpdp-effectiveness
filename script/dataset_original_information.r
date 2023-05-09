setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
file_path <- "../dataset/original/"
list.files(file_path)

datasets <-  c("ECLIPSE-2007","IND-JLMIV+R-2020","JIRA-RA-2019","MA-SZZ-2020","Metrics-Repo-2010")

table <- data.frame()
table_simple <- data.frame()
# colnames(table) <- c("Dataset","Project","Versions","#Instances","%Defective","#Metrics")
for(dataset in datasets){
  # dataset.name <- folder
  folder <- file.path(file_path,dataset)
  projects <- list.files(folder)
  num_projects <- length(projects)
  num_versions <- length(list.files(folder,pattern = '.*.csv',recursive = TRUE))
  num_instances <- 0
  for(project in projects){
    versions <- ""
    instances.min <- 1000000
    instances.max <- -1
    defectiveRatio.min <- 1
    defectiveRatio.max <- 0
    metricsNum <- -1
    versions.fullname <- list.files(paste(folder,project,sep = '/'))
    for (version.fullname in versions.fullname){
      versions.number <- as.numeric(unlist(regmatches(version.fullname,
                                                      gregexpr("-[[:digit:]]+\\.*[[:digit:]]*",version.fullname)) ))
      versions <- paste(versions,substr(versions.number[1],2,nchar(versions.number[1])),", ",sep = "")
      data <- read.csv(paste(folder,project,version.fullname,sep = '/'))
      num_instances <- num_instances + nrow(data)
      
      instanceNum <- nrow(data)
      defectiveRatio <- nrow(data[data$bug>0,]) / nrow(data)
      # defectiveRatio <- sum(data[,ncol(data)] > 0) / nrow(data)
      if(instanceNum > instances.max){
        instances.max <- instanceNum
      }
      if(instanceNum < instances.min){
        instances.min <- instanceNum
      }
      if(defectiveRatio > defectiveRatio.max){
        defectiveRatio.max <- defectiveRatio
      }
      if(defectiveRatio < defectiveRatio.min){
        defectiveRatio.min <- defectiveRatio
      }
      if (metricsNum == -1){
        metricsNum <- ncol(data) - 1
      }
      else if(ncol(data)-1 != metricsNum){
        cat("dataset error: inconsistant number of metrics\n")
      }
    }
    if(length(versions.fullname)==1){
      table[nrow(table)+1,c("Dataset","Project","Versions","#Instances","%Defective","#Metrics")] = c(dataset,project,"-",instances.min,paste(round(defectiveRatio.min*100),"%",sep = ""),metricsNum)
    }else{
      rangeOfDefective <- paste(round(defectiveRatio.min*100),"%~%",round(defectiveRatio.max*100),sep = "")
      rangeOfInstace <- paste(instances.min,"~",instances.max,sep = "")
      table[nrow(table)+1,c("Dataset","Project","Versions","#Instances","%Defective","#Metrics")] = c(dataset,project,substr(versions,1,nchar(versions)-2),rangeOfInstace,rangeOfDefective,metricsNum)
    }
    
  }
}
table
write.csv2(table,file='./dataset_information.csv',quote = FALSE,row.names = FALSE)

