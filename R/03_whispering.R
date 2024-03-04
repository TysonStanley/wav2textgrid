#' @title Whisper Transcription
#'
#' @description Applies the OpenAI Whisper model to transcribe the conversation
#'
#' @param wav_file the original `wav_file` path
#' @param final_ch1 channel 1 path after the cleaning from `remove_noises()`
#' @param model_type the type of Whisper model to run, default is "base"
#'
#' @import reticulate
#' @importFrom glue glue
#'
#' @export
whispering <- function(wav_file, final_ch1, model_type = "base"){
  reticulate::repl_python(input = glue::glue('
  import whisper

  # channel 1
  model = whisper.load_model("{[model_type]}")
  result1 = model.transcribe("{[final_ch1]}", fp16 = False)
  # full file
  result_full = model.transcribe("{[wav_file]}", fp16 = False)
  ',
  .open = "{[",
  .close = "]}"
  ))

  return(list(py$result_full, py$result1))
}
