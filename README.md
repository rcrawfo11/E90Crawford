# E90RicardoRekha
### Rekha Crawford and Ricardo Gonzalez 
### E90 2021 

## Summary: 
This repository contains the files used to complete Ricardo Gonzalez and Rekha Crawford's E90 final capstone project 2021. This capstone used data from the BNCI 2020 Horizon's data set in order to create and offline P300 speller implementation. EEG data from 
## Relavant Files 
**Data Folder:** Holds participant and intermediate processed data

**PreprocessingEpochPaper.m:** Splices Data into epochs and does feature extraction, saves relavant data into "paper.mat" in the Data folder. Needs to be run before Classifier.m

**ClassifierPaper.m:** Runs LDA and creates confusion matricies. Cross-Validates and randomly samples to generate balanced data set. 
