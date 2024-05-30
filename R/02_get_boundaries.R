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
  return(1)
}
