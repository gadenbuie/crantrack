library(git2rdata)

cran_snapshot <- cransays::take_snapshot()

snapshot_time <- strftime(cran_snapshot[[1, "snapshot_time"]], "[snapshot] %F %T UTC", tz = "UTC")

repo <- repository()
write_vc(
  as.data.frame(cran_snapshot), 
  file = "cran_snapshot", 
  root = repo, 
  stage = TRUE, 
  strict = FALSE,
  sorting = c("submission_time", "package")
)
commit(message = snapshot_time)
