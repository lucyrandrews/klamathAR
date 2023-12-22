source(here::here("R", "config.R"))

# read in barrier ranks spreadsheet
barrier_ranks <- read_excel(here("data-raw", "20231116_ca_barriers_ranks_klamath.xlsx"))

barrier_ranks <- rowid_to_column(
  barrier_ranks,
  "rank"
)

# add a group index to deal with duplicates
barrier_ranks <- barrier_ranks %>%
  group_by(SARPID) %>%
  arrange(Source) %>%
  mutate(SARPID_count = row_number())

# read in barriers spatial object
barriers <- read_sf(here("data-raw", "klamath_shp"))

barriers <- st_transform(barriers, crs = crs)

# add a group index to deal with duplicates
barriers <- barriers %>%
  group_by(SARPID) %>%
  arrange(Source) %>%
  mutate(SARPID_count = row_number())

# add a rank field
barriers <- left_join(
  barriers,
  select(barrier_ranks, rank, SARPID, SARPID_count),
  by = c("SARPID", "SARPID_count"))

# write out
use_data(barriers, overwrite = TRUE)



