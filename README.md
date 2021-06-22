# E90Crawford
### Rekha Crawford 
### E90 2021 

## Summary: 
This repository contains the files used to complete Ricardo Gonzalez and Rekha Crawford's E90 final capstone project 2021. This capstone used data from the BNCI 2020 Horizon's data set in order to create and offline P300 speller implementation. Specifically data from Riccio et al. 2013 was used. This data consisted of EEG signals from 8 participants during their time using a P300 speller for the purpose of spelling pre-selected words. Our final data proccessing pipeline followed the steps used in this study. Final classification accuracy on test data for our classifier was comparable to the original study (average accuracy of 89.86% for all participants). 

Our original pre-processing pipeline (found at Old/ProcessingForClassifier) was based off a P300 classifier tutorial by Goncharenko, cited below. No files currently in use follow this pipeline. 


## Folders 
**Data Folder:** Holds participant and intermediate processed data

**Old:** Has files currently not in use (past processing pipelines, visualizations, etc) 

**Figures:** Has saved data visualizations for participants at different times


## Relavant Files

**PreprocessingEpochPaper.m:** Splices Data into epochs and does feature extraction, saves relavant data into "paper.mat" in the Data folder. Needs to be run before Classifier.m

**ClassifierPaper.m:** Runs LDA and creates confusion matricies. Cross-Validates and randomly samples to generate balanced data set. 


## Citations 

Goncharenko, V. (2020, January 22). Simple P300 classifier on open data. Medium.com. Retrieved April 1, 2021 from https://medium.com/impulse-neiry/simple-p300-classifier-on-open-data-27e906f68b83

Riccio, A., Simione, L., Schettini, F., Pizzimenti, A., Inghilleri, M., Bernardinelli, M.O., Mattia, D., Cincotti, F. (2013). Attention and P300-based BCI performance in people with amyotrophic lateral sclerosis. Frontiers in Human Neuroscience, 7, 732. doi:10.3389/fnhum.2013.00732

## Acknoledgements 
This project was done in collaboration with Ricardo Gonzalez, another Swarthmore Engineering Major. However the files in this Github here were all created by Rekha Crawford. 
