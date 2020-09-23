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


fs_files <- list.files("/home/tom/Projects/stacks-asw/flagstats",
                       pattern = ".tsv",
                       full.names = TRUE)

names(fs_files) <- sub(".tsv", "", basename(fs_files))

fs_list <- lapply(fs_files, function(x)
  fread(x, na.strings = "N/A")[, .(
    qc_pass = as.numeric(gsub("[^[:digit:]|\\.]+", "", V1)),
    qc_fail = V2,
    category = V3)])

flagstats <- rbindlist(fs_list, idcol = "indiv")

flagstats[, parsed_pop := gsub("^[[:alpha:]]+_([[:alpha:]]+).*",
                               "\\1",
                               indiv)]
flagstats[, pop := plyr::revalue(parsed_pop, pop_order)]
flagstats[, pop2 := factor(pop, levels = rev(pop_order))]

saveRDS(flagstats, "data/flagstats.Rds")
