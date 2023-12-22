source(here::here("R", "config.R"))

load(here("data", "huc6.rda"))

# download nhdplushr spatial object
download_nhdplushr(
  nhd_dir = nhdplus_dir,
  hu_list = str_sub(huc6, 1, 4),
  download_files = TRUE
)

# read in nhdplushr spatial object
nhdplushr <- get_nhdplushr(
  hr_dir = nhdplus_dir,
  layers = "NHDFlowline",
  min_size_sqkm = 5,
  simp = 10,
  proj = crs,
  rename = TRUE
)

nhdplushr <- nhdplushr$NHDFlowline

# simplify nhdplushr spatial object for quicker on-the-fly plotting
nhdplushr <- nhdplushr[!st_is_empty(nhdplushr), ]

nhdplushr <- ms_simplify(nhdplushr, keep = 0.1)

nhdplushr <- st_filter(nhdplushr, huc6)

# write out
use_data(nhdplushr, overwrite = TRUE)


