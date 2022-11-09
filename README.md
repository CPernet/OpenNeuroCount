# OpenNeuroCount

Simple script to analyze datasets count from OpenNeuro

## The Data

The data are from 2 json files combined_by_ds.json which combines the dowloads per months inside each dataset, and from sizes.json which reports the dataset sizes. This second file is needed to estimate to number of downloads, that is divide the number of bytes downloaded per the dataset size. Indeed, while many datasets are downloaded at once, single files, or part of the data can also be downloaded, so it does not need to be an integer.

## The Analysis

After reading data, a 1st data frame is built simply loading all datasets over the all time period. This is cleaned up removing outliers based on total count (some >10000 access). This inermediate result can be seen in the figure bellow.


From this data frame, all datasets are time re-aligned with 0 = upload time. The data are split into three groups with a group of high nuber of downloads, versus middle ground, vs low. Data are plotted with a 2nd order polynomial (not shown here or in the script, but the RMS of the 2nd order fit was better than 1st or 3rd).
