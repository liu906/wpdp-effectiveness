calculateIndicator <- function(detail_result,threshold){
  # threshold -1: default classification threshold
  # threshold 0-1: number of module alignment
  # threshold 1-100: SLOC alignment
  
  detail_result <- detail_result[order(detail_result$actualBugLabel, decreasing = FALSE),]  
  detail_result <- detail_result[order(detail_result$sloc, decreasing = TRUE),]  
  detail_result <- detail_result[order(detail_result$predictedValue, decreasing = TRUE),]
  detail_result <- detail_result[order(detail_result$predictLabel, decreasing = TRUE),]
  detail_result$actualBugLabel <- (detail_result$actualBugLabel >= 1)
  # 0.2 means 0.2 of total module
  # 20 means 20% of total SLOC
  
  cumsum_sloc <- cumsum(detail_result$sloc)
  cumsum_tp <- cumsum(detail_result$actualBugLabel)

  
  
  if(threshold==-1){
    cutoff <- sum(detail_result$predictLabel == 1)
  }else{
    if(threshold<=1&&threshold>0){
      cutoff <- as.integer(nrow(detail_result) * threshold)
    }else{
      if(threshold==100){
        topsum <- cumsum_sloc[length(cumsum_sloc)]
        cutoff <- length(cumsum_sloc)
      }else{
        topsum <- cumsum_sloc[length(cumsum_sloc)] * 0.01 * threshold  
        flag <- which(cumsum_sloc > topsum)
        cutoff <- flag[1] - 1  
      }
      
      
    }
    detail_result[1:cutoff,"predictLabel"] <- 1
    if(cutoff < nrow(detail_result)){
      detail_result[(cutoff+1):nrow(detail_result),"predictLabel"] <- 0  
    }
    
  } 
  
  idx <- which(cumsum_sloc>0)[1]
  cumsum_sloc_sub <- cumsum_sloc[idx:cutoff]
  cumsum_tp_sub <- cumsum_tp[idx:cutoff]
  
  mdd <- sum((cumsum_tp_sub / (cumsum_sloc_sub / 1000) ) )/ length(cumsum_tp_sub)  
  if(is.na(mdd)){
    mdd <- 0
  }
    
  
  tp <- sum(detail_result$predictLabel * (detail_result$actualBugLabel>=1))
  tn <- sum((detail_result$predictLabel + detail_result$actualBugLabel) == 0)
  fp <- sum((detail_result$predictLabel == 1) * (detail_result$actualBugLabel == 0))
  fn <- sum((detail_result$predictLabel == 0) * (detail_result$actualBugLabel >= 1))
  
  if((tp + tn + fp + fn) != nrow(detail_result)){
    cat('confusion matrix calculation error!!!!!\n')
    return(0)
  }
  tp <- as.numeric(tp)
  tn <- as.numeric(tn)
  fp <- as.numeric(fp)
  fn <- as.numeric(fn)
  
  if((tp+fn)!=0){
    recall <- tp / (tp + fn)  
  }else{
    recall <- 0
  }
  if((tp+fp)!=0){
    precision <- tp / (tp + fp)  
  }else{
    precision <- 0
  }
   
  
  pii <- cutoff / nrow(detail_result)
  if(cutoff==0){
    pci <- 0
  }else{
    pci <- cumsum_sloc[cutoff]/cumsum_sloc[nrow(detail_result)]
  }
  
  pf <- fp / (fp + tn)
  if(recall==0 || precision==0){
    f1 <- 0
  }else{
    f1 <- 2 * precision * recall / (precision + recall)  
  }
  if((recall + 1 - pf)==0){
    g1 <- 0
  }else{
    g1 <-  (2 * recall * (1-pf)) / (recall + 1 - pf)
  }
  if(((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn)) == 0){
    mcc <- 0
  }else{
    mcc <- (tp * tn - fp * fn) / sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
  }
  
  ifa <- which(detail_result$actualBugLabel>=1)[1] - 1
  if(sum(detail_result$actualBugLabel)==0){
    ifa_pii <- ifa_pci <- ifap <- ifap2 <- 1
    ifa <- nrow(detail_result)
  }else if(ifa==0){
    ifa_pii <- ifa_pci <- ifap <- ifap2 <- 0
  }else{
    ifa_pii <- ifa / nrow(detail_result)
    ifa_pci <- (sum(detail_result$sloc[1:ifa]) / sum(detail_result$sloc))
    
    ifap <- (ifa / nrow(detail_result)) * (sum(detail_result$sloc[1:ifa]) / sum(detail_result$sloc))
    ifap2 <- (ifa / nrow(detail_result)) * 0.5 + 0.5 * (sum(detail_result$sloc[1:ifa]) / sum(detail_result$sloc))
  } 
  ifap3 <- sqrt(ifap)
  return(c(tp,fp,tn,fn,f1,g1,pf,pci,pii,recall,mcc,ifa,ifap,mdd,ifap2,ifa_pii,ifa_pci,ifap3))
}


summaryPerformance <- function(root_path,threshold,mode){
  cols <- c('community','source','target','tp','fp','tn','fn','f1','g1','pf','pci','pii','recall','mcc','ifa','ifap','mdd','ifap2','ifa_pii','ifa_pci','ifap3')
  
  files <- list.files(paste(root_path,'./detail_result/',sep=''))
  total_res <- data.frame(matrix(nrow = 0,ncol = length(cols)))
  colnames(total_res) <- cols
  
  for(file in files){
    cat(file,'\n')
    data <- read.csv(file=paste(root_path,'./detail_result/',file,sep = ''))
    perfs <- calculateIndicator(data,threshold = threshold)
    community <- strsplit(file,split = '-')[[1]][1]
    source <- strsplit(file,split = '_')[[1]][1]
    target <- strsplit(file,split = '_')[[1]][2]
    total_res[nrow(total_res)+1,] <- c(community,source,target,perfs)
  }
  if(mode=='SSC'){
    total_res$roi = as.numeric(total_res$recall)/ as.numeric(total_res$pii)  
    total_res[is.nan(total_res$roi),'roi'] <- 0
   
    
  }else if(mode=='SNM'){
    total_res$roi = as.numeric(total_res$recall)/ as.numeric(total_res$pci)  
    total_res[is.nan(total_res$roi),'roi'] <- 0
    
  }
  total_res$roi2 = as.numeric(total_res$recall)/ (0.5*as.numeric(total_res$pii) + 0.5*as.numeric(total_res$pci))
  total_res[is.nan(total_res$roi2),'roi2'] <- 0
  total_res$roi3 = as.numeric(total_res$recall)/ sqrt(as.numeric(total_res$pii) * as.numeric(total_res$pci))
  total_res[is.nan(total_res$roi3),'roi3'] <- 0
  
  write.csv(total_res,paste(root_path,'./total_result_',as.character(threshold),'.csv',sep = ''),row.names = FALSE)
  return(total_res)
}

summaryPerformance2 <- function(root_path,threshold,mode){
  cols <- c('community','source','target','tp','fp','tn','fn','f1','g1','pf','pci','pii','recall','mcc','ifa','ifap','mdd','ifap2','ifa_pii','ifa_pci','ifap3')
  
  files <- list.files(paste(root_path,sep=''))
  total_res <- data.frame(matrix(nrow = 0,ncol = length(cols)))
  colnames(total_res) <- cols
  
  for(file in files){
    cat(file,'\n')
    data <- read.csv(file=paste(root_path,file,sep = ''),stringsAsFactors=FALSE)
  
    
    data[data$predictLabel=='False','predictLabel'] = 0
    data[data$predictLabel=='True','predictLabel'] = 1
    data[data$actualBugLabel=='False','actualBugLabel'] = 0
    data[data$actualBugLabel=='True','actualBugLabel'] = 1
    
    data$predictedValue <- as.numeric(data$predictedValue)
    data$predictLabel <- as.numeric(data$predictLabel)
    data$actualBugLabel <- as.numeric(data$actualBugLabel)
    
    perfs <- calculateIndicator(data,threshold = threshold)
    community <- strsplit(file,split = '-')[[1]][1]
    source <- strsplit(file,split = '_')[[1]][1]
    target <- strsplit(file,split = '_')[[1]][2]
    total_res[nrow(total_res)+1,] <- c(community,source,target,perfs)
  }
  if(mode=='SSC'){
    total_res$roi = as.numeric(total_res$recall)/ as.numeric(total_res$pii)  
    total_res[is.nan(total_res$roi),'roi'] <- 0
    
  }else if(mode=='SNM'){
    total_res$roi = as.numeric(total_res$recall)/ as.numeric(total_res$pci)  
    total_res[is.nan(total_res$roi),'roi'] <- 0
    
  }
  total_res$roi2 = as.numeric(total_res$recall)/ (0.5*as.numeric(total_res$pii) + 0.5*as.numeric(total_res$pci))
  total_res[is.nan(total_res$roi2),'roi2'] <- 0
  total_res$roi3 = as.numeric(total_res$recall)/ sqrt(as.numeric(total_res$pii) * as.numeric(total_res$pci))
  total_res[is.nan(total_res$roi3),'roi3'] <- 0
  
  return(total_res)
}




