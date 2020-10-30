library(tidyverse)
# remotes::install_github("gadenbuie/git2rdata@git-show")
library(git2rdata)

list_data_changes(".", ref = "main") %>% as_tibble()

cran_changes <- 
  list_data_changes(".", ref = "main") %>% 
  filter(str_detect(message, "snapshot")) %>% 
  {set_names(.$sha, .$message)} %>% 
  map_dfr(function(ref) read_vc("cran_snapshot", root_at_ref(ref = ref))) %>% 
  as_tibble()

# From {cransays} ----
standard_folders <- c(
  "pretest", "newbies", "inspect", "recheck", "waiting", "pending", "publish"
)

cran_incoming <- 
  cran_changes %>% 
  arrange(subfolder, howlongago) %>% 
  filter(subfolder != "archive") %>% 
  filter(snapshot_time >= lubridate::ymd("2020-10-16")) %>% 
  mutate(
    folder = ifelse(subfolder %in% standard_folders, subfolder, "human"),
    subfolder = ifelse(subfolder %in% standard_folders, NA, subfolder)
  )


cran_incoming %>% 
  mutate(
    hour = lubridate::floor_date(snapshot_time, "hour"),
    folder = factor(folder, levels = rev(c(standard_folders, "human")))
  ) %>% 
  group_by(hour, folder) %>% 
  count() %>% 
  ggplot() +
  aes(hour, n, fill = folder) +
  geom_col(width = 60^2) +
  labs(
    fill = "Status", x = NULL, y = "Incoming Packages",
    title = "CRAN Incoming Packages by Status"
  ) +
  scale_fill_viridis_d(direction = -1, option = "A", end = 0.8, begin = 0.1) +
  scale_x_datetime(expand = expansion()) +
  theme_minimal(18) +
  theme(
    panel.grid.minor.y = element_blank()
  )

cran_incoming %>%
  filter(folder == "newbies") %>%
  count(snapshot_time) %>%
  ggplot() +
  aes(snapshot_time, n) +
  geom_area(fill = "gray90", color = "gray60") +
  theme_minimal()