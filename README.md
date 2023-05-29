# Unveiling the impact of duplicate modules across versions on the evaluation of within-project defect prediction models 

## Steps to remove duplicate modules in the source release (compared to its target release)  
1. generate udb files for this the source release and the target release from their source code through scitools Undertand  

2. run `python pureCompare.py` to store diff information between source and target releases  

3. run `python detectDuplication.py` to store new target release without duplicate modules  