#' @title Automate TextGrid
#'
#' @description Takes all of the steps and puts them together to produce a textgrid from a
#' wav file.
#'
#' @param wav_file The path to the wav file
#'
#' @importFrom fs path_split
#' @importFrom fs dir_ls
#'
#' @export
auto_textgrid <- function(wav_file){

  ## Step 1. Split `wav` file into channels
  splits <- split_channels(wav_file)

  ## Step 2. Remove other channel noises from first channel
  cleaned_ch1 <- remove_noises(splits[1], splits[2])

  ## Step 3. Use Whisper to transcribe the first channel and the full wav file
  results <- whispering(cleaned_ch1[1], cleaned_ch1[2])

  ## Step 4. Determine which channel is dominant at each half second
  doms <- dom_channel(wav_file)

  ## Step 5. Mark all first channel turns using the channel's transcription
  final_tab <- clean_up(results[[1]], results[[2]], doms)

  ## Step 6. Write the transcription and the turns to a TextGrid file
  make_textgrid(final_tab, wav_file)

  ## Delete intermediate files
  path_to_clean <- fs::path_split(wav_file)[[1]]
  path_to_clean <- path_to_clean[-length(path_to_clean)]
  int_files <- fs::dir_ls(path = path_to_clean, regexp = "_ch1|_ch2")
  fs::file_delete(int_files)
}
