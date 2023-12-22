source(here::here("R", "config.R"))

# pull huc4 spatial object
huc6 <- get_huc(id = huc6, t_srs = crs, type = "huc06")

# drop empty columns
huc6 <- select(huc6, where(~any(!is.na(.))))

# write out
use_data(huc6, overwrite = TRUE)
