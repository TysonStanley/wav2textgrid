
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wav2textgrid

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/wav2textgrid)](https://CRAN.R-project.org/package=wav2textgrid)
[![R-CMD-check](https://github.com/TysonStanley/wav2textgrid/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/TysonStanley/wav2textgrid/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of wav2textgrid is to take a two channel `wav` file of a
conversation and turn it into a transcribed textgrid ready for further
analysis in R or Praat.

## Installation

You can install the development version of wav2textgrid from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("TysonStanley/wav2textgrid")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(wav2textgrid)
wav_file = "conversaton1.wav"
auto_textgrid(wav_file)
```

The output is a textgrid that can be loaded directly into Praat or can
be read into R via `readtextgrid` package.
