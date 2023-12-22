pacman::p_load(
  dplyr,
  DT,
  ggplot2,
  here,
  leaflet,
  nhdplusTools,
  readr,
  readxl,
  tibble,
  tidyr,
  rmapshaper,
  rsconnect,
  sf,
  shiny,
  snakecase,
  stringr
)

crs <- st_crs(4326)

nhdplus_dir <- here("data-raw", "nhdplus_dir")

if(!dir.exists(nhdplus_dir)) {
  dir.create(nhdplus_dir)
}

nhdplusTools_data_dir(dir = nhdplus_dir)

huc6 <- 180102
