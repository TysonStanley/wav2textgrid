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

  whisper = reticulate::import('whisper')
  model = whisper$load_model("base")
  result1 = model$transcribe(final_ch1, fp16 = FALSE)
  result_full = model$transcribe(wav_file, fp16 = FALSE)

  return(list(result_full, result1))
}
