#' @title Split Channels
#'
#' @description Splits the wav file into the two channels
#'
#' @param wav_file The path to the wav file
#' @param threshold noise level for removal
#' @param plot should the tuneR::plot() be made for each channel? Default is FALSE.
#'
#' @import tuneR
#' @import data.table
#' @importFrom stringr str_replace
#'
#' @export
split_channels <- function(wav_file, threshold = 200, plot = FALSE){
  # read in wave file
  wav <- tuneR::readWave(wav_file)
  wav <- tuneR::normalize(wav, unit = "16")
  # check if it has two channels
  if (tuneR::nchannel(wav) != 2) stop ("wave file needs to have 2 channels")

  # split into left and right
  left <- tuneR::channel(wav, which = "left")
  right <- tuneR::channel(wav, which = "right")

  # running mean
  left_roll <- data.table::frollmean(abs(left@left), n = 10000)
  right_roll <- data.table::frollmean(abs(right@left), n = 10000)
  left_roll[1:10000] <- abs(mean(left@left[1:10000]))
  right_roll[1:10000] <- abs(mean(right@left[1:10000]))

  # remove noises
  left@left <- ifelse(left_roll < threshold, 0, left@left)
  right@left <- ifelse(right_roll < threshold, 0, right@left)
  # left <- volume(left, gain = ifelse(left@left < threshold, 0, 1))
  # left <- volume(left, gain = ifelse(left@left < threshold, 0, 1))

  if (plot) tuneR::plot(left); tuneR::plot(right)

  # save channeled wav files
  ch1 <- stringr::str_replace(wav_file, "\\.wav$", "_ch1.wav")
  ch2 <- stringr::str_replace(wav_file, "\\.wav$", "_ch2.wav")
  tuneR::writeWave(left, ch1)
  tuneR::writeWave(right, ch2)

  # return names
  return(c(ch1, ch2))
}
