docker run --rm -it -v $PWD:/input multifractal/ggplots:v4.1.1 /bin/bash
cd input
R

library(reshape2)
library(gridExtra)
library(grid)
library(dplyr)
library(tidyr)
library(readr)

list_of_files <- list.files(recursive = TRUE,
                            pattern = "\\.kreport$",
                            full.names = TRUE,
                            header = FALSE)

df <- readr::read_csv(list_of_files, id = "file_name")

dat <- list.files(pattern="*.kreport") %>% lapply(read.csv, header=FALSE)

setwd ("/input")
myfiles = list.files(path=".", pattern="*.kreport", full.names=TRUE)
myfiles


a <- c("Percent", "reads", "idk",
       "taxon", "idk2", "organism_name")

for(i in list.files(pattern = "DESeq2_result_*"))
  write.table(read.table(i, col.names = c("Percent", "reads", "idk",
       "taxon", "idk2", "organism_name")), i)