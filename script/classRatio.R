setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv('dataset_config.csv')
df_noDup <- read.csv('dataset_config_diffToPreviousRelease.csv')

setwd('../')
getwd()


for (idx in 1:nrow(df)) {
  one_row <- df[idx,]
  test_df <- read.csv(one_row$test_path)
  test_noDup_df <- read.csv(one_row$diff_path)
  test_df$bug
  test_noDup_df
}