
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
# wav2textgrid relies on the python (the OpenAI whisper model)
reticulate::use_miniconda("path/r-miniconda-arm64")
# if the following python packages are not installed, use:
# packages = c("ffmpeg-python", "numpy", "scipy", "setuptools-rust", "pydub", "llvmlite", "librosa", "numba",
#              "Cmake", "wheel", "setuptools-rust", "pytorch", "torchvision")
# reticulate::conda_install(envname = "~/Desktop/Automation/r-py-automate", packages = packages)
# reticulate::py_install("openai-whisper", pip = TRUE, pip_options = "-U")
# reticulate::py_install("light-the-torch", pip = TRUE, pip_options = "-U")

library(wav2textgrid)
wav_file = "data/example.wav"
auto_textgrid(wav_file)
```

    #> Step 1 of 5...
    #> Step 2 of 5...
    #> Step 3 of 5...
    #> Started channel 1 transcription...
    #>  67 of 67 segments complete for channel 1
    #> Started channel 2 transcription...
    #>  68 of 68 segments complete for channel 2
    #> Step 4 of 5...
    #> Step 5 of 5...
    #> Written to path/example_output.TextGrid

The output is a textgrid that can be loaded directly into Praat or can
be read into R via `readtextgrid` package. For the wav file in the
`inst/extdata` folder, running the code above gives us the following
TextGrid (as shown by reading it in using `readtextgrid`).

    #> # A tibble: 272 × 6
    #>    tier_num tier_xmin tier_xmax  xmin  xmax text                                
    #>       <dbl>     <dbl>     <dbl> <dbl> <dbl> <chr>                               
    #>  1        1         0      281.  0     1.54 n                                   
    #>  2        1         0      281.  1.54  4.53 i am participant one on channel one 
    #>  3        1         0      281.  4.53  8.44 n                                   
    #>  4        1         0      281.  8.44 11.9  okay you want to start in the top l…
    #>  5        1         0      281. 11.9  15.5  n                                   
    #>  6        1         0      281. 15.5  15.7  thank you                           
    #>  7        1         0      281. 15.7  17.9  n                                   
    #>  8        1         0      281. 17.9  19.4  mine says peggy's so                
    #>  9        1         0      281. 19.4  22.4  n                                   
    #> 10        1         0      281. 22.4  22.7  yeah                                
    #> # ℹ 262 more rows
