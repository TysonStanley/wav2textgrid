#' @title Automate TextGrid
#'
#' @description Takes all of the steps and puts them together to produce a textgrid from a
#' wav file.
#'
#' @param wav_file The path to the wav file
#' @param min_pitch Minimum pitch (Hz)
#' @param time_step Time step (s)
#' @param threshold silence threshold, default is -45
#' @param min_silent_int Minimum silent interval (s)
#' @param min_sound_int Minimum sounding interval (s)
#'
#' @importFrom fs path_split
#' @importFrom fs dir_ls
#' @importFrom fs path_dir
#' @importFrom fs file_move
#' @importFrom fs dir_create
#' @importFrom fs dir_delete
#'
#' @export
auto_textgrid <- function(wav_file, min_pitch = 100, time_step = 0.0, threshold = -45, min_silent_int = 0.5, min_sound_int = 0.1){
  # Step 1
  message("Step 1 of 5...")
  step1 = split_channels(wav_file, threshold = 200, plot = TRUE)

  # move files to tmp folder
  fs::dir_create(file.path(fs::path_dir(wav_file), "tmp"))
  file1 = fs::path_file(step1[1])
  file2 = fs::path_file(step1[2])
  fs::file_move(step1[1], file.path(fs::path_dir(step1[1]), "tmp"))
  fs::file_move(step1[2], file.path(fs::path_dir(step1[2]), "tmp"))

  # new locations
  step1[1] = file.path(fs::path_dir(step1[1]), "tmp", file1)
  step1[2] = file.path(fs::path_dir(step1[2]), "tmp", file2)
  folder = fs::path_dir(step1[2])

  # Step 2
  message("Step 2 of 5...")
  folder2 <- if (stringr::str_detect(osVersion, "Window|window")) paste0(folder, "\\") else paste0(folder, "/")
  step2 = get_boundaries(folder2, min_pitch, time_step, threshold, min_silent_int, min_sound_int)

  # Step 3
  message("Step 3 of 5...")
  whispered = whispering(step1[1], step1[2], folder = folder)

  # Step 4
  message("\nStep 4 of 5...")
  cleaned = clean_up(whispered[[1]], whispered[[2]], folder = folder)

  # Step 5
  message("Step 5 of 5...")
  make_textgrid(cleaned, wav_file)

  ## Delete intermediate files
  fs::dir_delete(folder)
}
