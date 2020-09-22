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



vcf_file <- "data/populations.geo.pruned.vcf"
full_vcf <- fread(cmd = paste("grep -v '^##'", vcf_file))

# manually parse depth from the vcf
sample_cols <- names(full_vcf)[10: length(names(full_vcf))]

GetDP <- function(x) {
  as.integer(unlist(strsplit(x, ":"))[[2]])
}

dp_table <- full_vcf[, lapply(.SD, GetDP),
         .SDcols = sample_cols,
         by = .(`#CHROM`, POS)]

dp_long <- melt(dp_table,
                id.vars = c("#CHROM", "POS"),
                variable.name = "indiv",
                value.name = "DP",
                variable.factor = FALSE)


# only care about geo samples
geo_only <- dp_long[startsWith(as.character(indiv), "geo")]
geo_only[, parsed_pop := gsub("^[[:alpha:]]+_([[:alpha:]]+).*",
                              "\\1",
                              indiv)]

mean_dp <- geo_only[, .(mean_dp = mean(DP, na.rm = TRUE)),
                    by = .(indiv, parsed_pop)]
mean_dp[, pop := plyr::revalue(parsed_pop, pop_order)]
mean_dp[, pop2 := factor(pop, levels = rev(pop_order))]

saveRDS(mean_dp, "data/mean_dp.Rds")
