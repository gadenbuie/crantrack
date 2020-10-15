library(tidyverse)
# remotes::install_github("gadenbuie/git2rdata@git-show")
library(git2rdata)

list_data_changes(".") %>% as_tibble()

cran_changes <- 
  list_data_changes(".", "cran_snapshot") %>% 
  {set_names(.$sha, .$message)} %>% 
  map_dfr(function(ref) read_vc("cran_snapshot", root_at_ref(ref = ref))) %>% 
  as_tibble()

# From {cransays} ----
standard_folders <- c(
  "pretest", "inspect", "recheck", "pending", "publish", "newbies", "waiting"
)

cran_incoming <- 
  cran_changes %>% 
  arrange(subfolder, howlongago) %>% 
  filter(subfolder != "archive") %>% 
  mutate(
    folder = ifelse(subfolder %in% standard_folders, subfolder, "human"),
    subfolder = ifelse(subfolder %in% standard_folders, NA, subfolder)
  )


cran_incoming %>% 
  mutate(hour = lubridate::floor_date(snapshot_time, "hour")) %>% 
  group_by(hour, folder) %>% 
  count() %>% 
  ggplot() +
  aes(hour, n, fill = folder) +
  geom_col()
