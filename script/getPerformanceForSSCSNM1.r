setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()
source("summary_performance.r")


res <- summaryPerformance2(root_path='../prediction_result/LR/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/LR_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/LR/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/LR_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/LR/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/LR_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/LR/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/LR_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/LR/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/LR_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/LR/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/LR_JURECZKO_result_1.csv',row.names = FALSE)

############################ KNN n_neighbor=1 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN1/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN1/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN1/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1_JURECZKO_result_1.csv',row.names = FALSE)

############################KNN n_neighbor=1 no scale formalization##############

res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1ns_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1ns_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1ns_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1ns_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN1ns_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN1ns/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN1ns_JURECZKO_result_1.csv',row.names = FALSE)
############################ KNN n_neighbor=2 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN2/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN2_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN2/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN2_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN2/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN2_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN2/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN2_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN2/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN2_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN2/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN2_JURECZKO_result_1.csv',row.names = FALSE)

############################ KNN n_neighbor=3 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN3/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN3_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN3/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN3_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN3/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN3_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN3/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN3_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN3/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN3_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN3/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN3_JURECZKO_result_1.csv',row.names = FALSE)

############################ KNN n_neighbor=4 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN4/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN4_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN4/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN4_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN4/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN4_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN4/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN4_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN4/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN4_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN4/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN4_JURECZKO_result_1.csv',row.names = FALSE)

############################ KNN n_neighbor=5 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN5/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN5_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN5/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN5_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN5/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN5_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN5/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN5_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN5/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN5_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN5/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN5_JURECZKO_result_1.csv',row.names = FALSE)

############################ KNN n_neighbor=10 ##################################

res <- summaryPerformance2(root_path='../prediction_result/KNN10/ELFF_class_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN10_ELFF_class_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN10/ELFF_class_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN10_ELFF_class_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN10/ELFF_Method_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN10_ELFF_Method_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN10/ELFF_Method_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN10_ELFF_Method_result_1.csv',row.names = FALSE)


res <- summaryPerformance2(root_path='../prediction_result/KNN10/JURECZKO_result/',threshold = 0.01, mode='SNM')
write.csv(res,file='../performance/KNN10_JURECZKO_result_0.01.csv',row.names = FALSE)
res <- summaryPerformance2(root_path='../prediction_result/KNN10/JURECZKO_result/',threshold = 1, mode='SSC')
write.csv(res,file='../performance/KNN10_JURECZKO_result_1.csv',row.names = FALSE)

