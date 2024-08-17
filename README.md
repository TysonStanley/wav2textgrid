
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
analysis in R or Praat. To use the package, you’ll need `R`, `Praat`,
and `python` installed.

## Installation

You can install the development version of wav2textgrid from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("TysonStanley/wav2textgrid")
```

## Example

### Python Environment Set Up

``` r
library(wav2textgrid)
py_setup(path)
# this runs the following
# wav2textgrid relies on the python (the OpenAI whisper model)
# reticulate::use_miniconda("path/r-miniconda-arm64")
# if the following python packages are not installed, use:
# packages = c("ffmpeg-python", "numpy", "scipy", "setuptools-rust", "pydub", "llvmlite", "librosa", "numba",
#              "Cmake", "wheel", "setuptools-rust", "pytorch", "torchvision")
# reticulate::conda_install(envname = "~/Desktop/Automation/r-py-automate", packages = packages)
# reticulate::py_install("openai-whisper", pip = TRUE, pip_options = "-U")
# reticulate::py_install("light-the-torch", pip = TRUE, pip_options = "-U")
```

### Run `auto_textgrid()`

``` r
wav_file = "path/example.wav"
auto_textgrid(wav_file)
```

    #> → Default prompt:
    #> 'I was like, was like, I'm like, um, ah, huh, and so, so um, uh, and um, mm-hmm, like um, so like, like it's, it's like, i mean, yeah, uh-huh, hmm, right, ok so, uh so, so uh, yeah so, you know, it's uh, uh and, and uh'
    #> ✔ Step 1 of 5 [2.6s]
    #> ✔ Step 2 of 5 [1.8s]
    #> ✔ Step 3 of 5 [5m 11.3s]                                                
    #> ✔ Step 4 of 5 [262ms]
    #> ✔ Step 5 of 5 [68ms]
    #> ℹ Written to path/example_output.TextGrid

The output is a textgrid that can be loaded directly into Praat or can
be read into R via `readtextgrid` package. For the wav file in the
example above (found on GitHub in the `inst` folder), running the code
above gives us the following TextGrid (as shown by reading it in using
`readtextgrid`).

    #> # A tibble: 270 × 6
    #>    tier_num tier_xmin tier_xmax  xmin  xmax text                                
    #>       <dbl>     <dbl>     <dbl> <dbl> <dbl> <chr>                               
    #>  1        1         0      281.  0     1.48 n                                   
    #>  2        1         0      281.  1.48  5.15 i'm participant one on channel one  
    #>  3        1         0      281.  5.15  5.80 n                                   
    #>  4        1         0      281.  5.80 23.5  ok um you want to start in the top …
    #>  5        1         0      281. 23.5  24.3  n                                   
    #>  6        1         0      281. 24.3  38.0  and then i have another towel that'…
    #>  7        1         0      281. 38.0  38.9  n                                   
    #>  8        1         0      281. 38.9  41.3  i don't think anything fell out of …
    #>  9        1         0      281. 41.3  41.8  n                                   
    #> 10        1         0      281. 41.8  43.1  green ok                            
    #> # ℹ 260 more rows

Importantly, we can control a number of features of the transcription to
make it more accurate. In this case, we used a noise reduction program
and set the threshold of silences to -30 dB. We also use the larger
“small” model from Whisper.

``` r
auto_textgrid(wav_file, noise_reduction = TRUE, threshold = -30, model_type = "small")
```
