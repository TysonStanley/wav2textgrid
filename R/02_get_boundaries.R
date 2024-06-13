#' @title Get Boundaries
#'
#' @description Uses Praat to find boundaries of speaking turns.
#'
#' @param folder the folder where the wav_file is located
#' @param min_pitch Minimum pitch (Hz)
#' @param time_step Time step (s)
#' @param threshold silence threshold, default is -45
#' @param min_silent_int Minimum silent interval (s)
#' @param min_sound_int Minimum sounding interval (s)
#'
#' @importFrom speakr praat_run
#' @importFrom glue glue
#' @importFrom readtextgrid read_textgrid
#'
#' @export
get_boundaries <- function(folder, min_pitch, time_step, threshold, min_silent_int, min_sound_int){
  # the parameters for the To TextGrid command:
  #   Minimum pitch (Hz)
  #   Time step (s)
  #   Silence threshold (dB)
  #   Minimum silent interval (s)
  #   Minimum sounding interval (s)

  script <- glue::glue({"
#start praat
form Enter directory and search string
    sentence Directory {folder}
    sentence Word
    boolean anotate_silences 1
endform"})
  script <- glue::glue(script, '\n\n', "Create Strings as file list... file-list 'directory$''word$'*.wav")
  script <- glue::glue(script, '\n\n', "number_of_files = Get number of strings")
  script <- glue::glue(script, '\n\n', "for x from 1 to number_of_files")
  script <- glue::glue(script, '\n', "    select Strings file-list")
  script <- glue::glue(script, '\n', "    current_file$ = Get string... x")
  script <- glue::glue(script, '\n', "    Read from file... 'directory$''current_file$'")
  script <- glue::glue(script, '\n', "    if anotate_silences = 1")
  script <- glue::glue(script, '\n', '        To TextGrid (silences): {min_pitch}, {time_step}, {threshold}, {min_silent_int}, {min_sound_int}, "silence", "sounding"')
  script <- glue::glue(script, '\n', "        Write to text file... 'directory$''current_file$'_silences.TextGrid")
  script <- glue::glue(script, '\n', "    endif")
  script <- glue::glue(script, '\n', "endfor")
  script <- glue::glue(script, '\n\n', "select all")
  script <- glue::glue(script, '\n', "Remove")
  # script <- glue::glue(script, "\n\n", 'writeInfoLine: "Done finding silences :)"')
  script_file <- paste0(folder, "temp.praat")
  writeLines(script, con = script_file)

  speakr::praat_run(script_file, folder, '""', 1)

  # check output
  check_shared_boundaries(script_file)

  # if successful return 1
  return(1)
}



# helper for shared boundaries
check_shared_boundaries <- function(textgrid_file){
  # read in textgrid
  textgrid = readtextgrid::read_textgrid(textgrid_file)

  # check mins and maxs
  xmin1 = textgrid[textgrid$tier_num == 1, ]$xmin
  xmin2 = textgrid[textgrid$tier_num == 2, ]$xmin
  xmax1 = textgrid[textgrid$tier_num == 1, ]$xmax
  xmax2 = textgrid[textgrid$tier_num == 2, ]$xmax

  # remove zeros
  xmin1 = xmin1[xmin1 != 0]
  xmin2 = xmin2[xmin2 != 0]
  xmax1 = xmax1[xmax1 != 0]
  xmax2 = xmax2[xmax2 != 0]

  min_overlap = sum(xmin1 %in% xmin2)/length(xmin1)
  max_overlap = sum(xmax1 %in% xmax2)/length(xmax1)

  if (min_overlap > .3 || max_overlap > .3){
    cli::cli_alert_warning("The Silence/Sounding TextGrid found at least 30% of the boundaries were identical.\nThis can mean there is an issue with the threshold parameter (or others).")
    cli::cli_alert_warning("This suggests there is an issue with the threshold parameter (or others).")
  }
}
