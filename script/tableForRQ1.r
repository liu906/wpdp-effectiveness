setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(dplyr)
df <- read.csv('dataset_diff_info.csv')
df$pos_ratio <- df$positive / df$len_same_id_in_dataset
df$neg_ratio <- df$negative / df$len_same_id_in_dataset



res <- df %>%
  group_by(df[,1]) %>%  # 按照第一列进行分组
  summarize(across(.cols = 4:length(df), .fns = mean, na.rm = TRUE))

total_res <- df %>%
  summarize(across(.cols = 4:length(df), .fns = mean, na.rm = TRUE))


df <- read.csv('dataset_classRatio.csv')

res2 <- df %>%
  group_by(df[,2]) %>%  # 按照第一列进行分组
  summarize(across(.cols = 7:length(df), .fns = mean, na.rm = TRUE))
total_res2 <- df %>%
  summarize(across(.cols = 7:length(df), .fns = mean, na.rm = TRUE))




colnames(res2)[1] <- 'dataset'
colnames(res)[1] <- 'dataset'
total_res2 <- cbind(dataset='Total', total_res2)
total_res <- cbind(dataset='Total', total_res)


res2[nrow(res2)+1,] <- total_res2
res[nrow(res)+1,] <- total_res

result <- left_join(res, res2, by = "dataset")
result$ratio <- result$ratio*100
result$pos_ratio <- result$pos_ratio*100
result$neg_ratio <- result$neg_ratio*100

write.csv(result, file = "data_duplicate_statistic.csv", row.names = FALSE)
