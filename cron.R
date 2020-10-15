#! /usr/bin/env Rscript

cli::cli_process_start("Taking snapshot of CRAN incoming")
source("snapshot.R")
cli::cli_process_done()

cli::cli_process_start("Pushing changes")
git2r::push(credentials = git2r::cred_token())
cli::cli_process_done()

