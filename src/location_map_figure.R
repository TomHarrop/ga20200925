#!/usr/bin/env Rscript

library(data.table)
library(ggmap)

bbox <- c(165,-47,180,-35)

# wgs84_loc <- fread("data/manual_locations_with_wgs84.csv")
wgs84_loc <- fread("data/manual_locations_with_wgs84.csv")[location != "Reefton"]
wgs84_loc[, loc_code := paste0(location, " (", code, ")")]
setorder(wgs84_loc, -lat)
wgs84_loc[, loc_code := factor(loc_code, levels = rev(loc_code))]
wgs84_loc[, code_loc := paste0(code, " (", location, ")")]
wgs84_loc[, paste(code_loc, collapse = ", ")]

# prepare a plot
if(!file.exists("data/nz_map.Rds")) {
    nz <- get_googlemap(center = "Wellington NZ",
                        zoom = 5,
                        scale = 2,
                        maptype = "terrain",
                        style = "element:labels|visibility:off")
    saveRDS(nz, "data/nz_map.Rds")
} else {
    nz <- readRDS("data/nz_map.Rds")
}

if(!file.exists("data/nz_map_sm.Rds")) {
    nz_sm <- get_stamenmap(bbox,
                           maptype = "terrain-background",
                           zoom = 9)
    get_stamen_tile_download_fail_log()
    retry_stamen_map_download()
    saveRDS(nz_sm, "data/nz_map_sm.Rds")
} else {
    nz_sm <- readRDS("data/nz_map_sm.Rds")
}


# plot
lon_bump <- 0.20
# lat_bump <- 0.025
lat_bump <- 0

gp <- ggmap(nz_sm) +
    theme_minimal(base_size = 8) +
    theme(legend.key.size = unit(0.5, "lines")) +
    scale_x_continuous(expand = c(0, 0),
                       limits = c(165, 180)) +
    scale_y_continuous(expand = c(0, 0),
                       limits = c(-47, -35)) +
    xlab("Longitude") + ylab("Latitude") +
    geom_point(mapping = aes(x = lon,
                             y = lat,
                             fill = loc_code),
               colour = "black",
               shape = 21,
               size = 2,
               data = wgs84_loc) +
    geom_text(mapping = aes(x = lon + lon_bump,
                            y = lat - lat_bump,
                            label = toupper(location)),
              colour = "black",
              size = 2.5,
              hjust = "left",
              vjust = 0.5,
              data = wgs84_loc) +
    # fontface = "bold") +
    geom_text(mapping = aes(x = lon - lon_bump,
                            y = lat - lat_bump,
                            label = n),
              colour = "black",
              size = 2.5,
              hjust = "right",
              vjust = 0.5,
              data = wgs84_loc) +
    # fontface = "bold") +
    scale_fill_viridis_d(guide = FALSE)

saveRDS(gp, "fig/location_map.Rds")
