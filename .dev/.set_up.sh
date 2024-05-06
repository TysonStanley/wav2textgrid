# to run in terminal
cd ~/'Box Sync'/'Textgrid validation'

# set up
R
library(reticulate)
library(data.table)
library(tidyverse)
library(wav2textgrid) # remotes::install_github("tysonstanley/wav2textgrid")
library(here)
library(fs)

py_setup("~/Desktop", force = TRUE)
reticulate::use_miniconda("~/Desktop/r-py-automate")

# locate the wav files
p1 = here::here("Data", "Diapix-familiar", "Diapix-familiar-wavs")
p2 = here::here("Data", "Diapix-unfamiliar", "Diapix-unfamiliar-wavs")
p3 = here::here("Data", "RCIT-familiar", "RCIT-familiar-wavs")
p4 = here::here("Data", "RCIT-unfamiliar", "RCIT-familiar-wavs")
df = fs::dir_ls(p1)
du = fs::dir_ls(p2)
rf = fs::dir_ls(p3)
ru = fs::dir_ls(p4)
