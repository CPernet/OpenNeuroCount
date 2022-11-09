# OpenNeuroCount

Simple script to analyze datasets count from OpenNeuro

## The Data

The data are from 2 json files combined_by_ds.json which combines the dowloads per months inside each dataset, and from sizes.json which reports the dataset sizes. This second file is needed to estimate to number of downloads, that is divide the number of bytes downloaded per the dataset size. Indeed, while many datasets are downloaded at once, single files, or part of the data can also be downloaded, so it does not need to be an integer.

## The Analysis

After reading data, a 1st data frame is built simply loading all datasets over time. This is cleaned up removing outliers based on total count (some >10000 access). This inermediate result can be seen in the figure bellow.

![download over time](https://github.com/CPernet/OpenNeuroCount/blob/main/fig/OpenNeuroTime.jpg)


From this data frame, all datasets are time re-aligned with 0 = upload time. The data are split into three groups with a group of high nuber of downloads, versus middle ground, vs low. Data are plotted with a 2nd order polynomial (not shown here or in the script, but the RMS of the 2nd order fit was better than 1st or 3rd).

![download from upload](https://github.com/CPernet/OpenNeuroCount/blob/main/fig/OpenNeuroCounts.jpg)

The average download count shows two peaks, one after the data deposit and another 10 to 15 months later, supposedly matching the time between submitting the data and the publication of research results using those data (figure 1). On OpenNeuro, the top ~6% of datasets accounts for more than 16% of the total downloads (top 25th percentile), and the download count does not seem to slow down with time. Conversely, as we expected, the download count goes down over time (more so after 1.5 years, or 6 months post-publication), for all other datasets. 
