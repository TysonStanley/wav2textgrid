#' @title Split Channels
#'
#' @description Splits the wav file into the two channels
#'
#' @param wav_file The path to the wav file
#' @param noise_reduction whether the praat noise reduction script should be run before getting boundaries, default = FALSE
#' @param threshold noise level for removal
#' @param plot should the tuneR::plot() be made for each channel? Default is FALSE. Only applicable when noise_reduction = FALSE.
#'
#' @import tuneR
#' @import data.table
#' @importFrom stringr str_replace
#'
#' @export
split_channels <- function(wav_file, noise_reduction = FALSE, threshold = 200, plot = FALSE){
  # read in wave file
  wav <- tuneR::readWave(wav_file)
  wav <- tuneR::normalize(wav, unit = "16")
  # check if it has two channels
  if (tuneR::nchannel(wav) != 2) stop ("wave file needs to have 2 channels")

  # file names
  ch1 <- stringr::str_replace(wav_file, "\\.wav$", "_ch1.wav")
  ch2 <- stringr::str_replace(wav_file, "\\.wav$", "_ch2.wav")

  # split into left and right
  left <- tuneR::channel(wav, which = "left")
  right <- tuneR::channel(wav, which = "right")

  # save channeled wav files
  tuneR::writeWave(left, ch1)
  tuneR::writeWave(right, ch2)

  if (plot) tuneR::plot(left); tuneR::plot(right)


  # noise reduction
  if (noise_reduction){
    noise_reduce(fs::path_dir(ch1), ch1)
    noise_reduce(fs::path_dir(ch2), ch2)

  }

  # check that files exist
  if (! fs::file_exists(ch1) | ! fs::file_exists(ch2)) stop("error creating channels")

  # return names
  return(c(ch1, ch2))
}



# create and run script for noise_reduction
noise_reduce <- function(folder, channel){
  script <- glue::glue({"
# Made by Lotte Eijk - 17-11-22
# Reduce noise using the standard Praat settings and save denoised file to specified folder

form Reduce noise
    sentence inputDir {folder}
    positive Channel: 2
    sentence outputDir {folder}
    sentence inputFile {channel}
endform"})
  script <- glue::glue(script, '\n\n', "Create Strings as file list... file-list 'inputFile$'")
  script <- glue::glue(script, '\n\n', "numberOfFiles = Get number of strings")
  script <- glue::glue(script, '\n\n', "for ifile to numberOfFiles")
  script <- glue::glue(script, '\n', "    select Strings list")
  script <- glue::glue(script, '\n', "    fileName$ = Get string... ifile")
  script <- glue::glue(script, '\n', "    Read from file... 'inputDir$'/'fileName$'")
  script <- glue::glue(script, '\n', '    Reduce noise: 0, 0, 0.025, 80, 10000, 40, -20, "spectral-subtraction"')
  script <- glue::glue(script, '\n', "    lengthFN = length (fileName$)")
  script <- glue::glue(script, '\n', "    newfilename$ = fileName$")
  script <- glue::glue(script, '\n', "    Write to WAV file... 'outputDir$'/'newfilename$'")
  script <- glue::glue(script, '\n', "endfor")
  script <- glue::glue(script, '\n\n', "select all")
  script <- glue::glue(script, '\n', "Remove")
  script_file <- paste0(folder, "temp_noise.praat")
  writeLines(script, con = script_file)

  speakr::praat_run(script_file, folder, '""', 1)
}

# script <- glue::glue(script, '\n\n', "printline 'directory$'")
# script <- glue::glue(script, '\n', "printline 'word$'")
# script <- glue::glue(script, '\n', "printline 'number_of_files'")
