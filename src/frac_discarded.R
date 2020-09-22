#!/usr/bin/env Rscript

library(data.table)
library(ggplot2)

pop_order <- c(
  "Coromandel" = "Coromandel",
  "Ruakura" = "Ruakura",
  "Taranaki" = "Taranaki",
  "Wellington" = "Wellington",
  "Greymouth" = "Greymouth",
  "Lincoln" = "Lincoln",
  "O" = "Ophir",
  "Mararoa" = "Mararoa Downs",
  "Mossburn" = "Mossburn",
  "Fortrose" = "Fortrose")


used_reads_file <- "/home/tom/Projects/stacks-asw/output/040_stats/reads.csv"

all_files <- list.files("/home/tom/Projects/stacks-asw/output/logs",
                        pattern = "trim_adaptors.*adaptors.txt",
                        full.names = TRUE)
names(all_files) <- gsub(".*?\\.([^\\.]+).*", "\\1", basename(all_files))

# read teh Input Bases field from the log files
input_list <- lapply(all_files, function(x) 
  fread(cmd = paste('grep "^Input:"', x))[
    , data.table(input_bases = as.integer(gsub("[^[:digit:]]+", "", V4)))])

input <- rbindlist(input_list, idcol = "filename")

# combine the total number of bases per individual
input[, c("indiv", "fc", "x", "y", "z") := tstrsplit(filename, "_")]
input_indivs <- input[, .(input_bases = sum(input_bases, na.rm = TRUE)),
                      by = indiv]

# read the kept reads stats
used_reads <- fread(used_reads_file)
used_reads[, used_bases := 80 * reads]

# add para/geo to indivs
input_indivs[gsub("[[:digit:]]+", "", indiv) %in%
               c("I", "L", "R", "Rpoa"),
             indiv_full := paste("para", indiv, sep = "_")]

input_indivs[is.na(indiv_full) & !grepl("GBSNEG", indiv),
             indiv_full := paste("geo", indiv, sep = "_")]

# combine
amount_trimmed <- merge(used_reads, input_indivs, by.x = "individual", by.y = "indiv_full")
amount_trimmed[, frac_discarded := used_bases / input_bases]

# only care about geo samples
geo_only <- amount_trimmed[startsWith(individual, "geo_")]
geo_only[, parsed_pop := gsub("^[[:alpha:]]+_([[:alpha:]]+).*",
                              "\\1",
                              individual)]
geo_only[, pop := plyr::revalue(parsed_pop, pop_order)]
saveRDS(geo_only, "data/frac_discarded.geo.Rds")

