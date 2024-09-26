#' @title Whisper Transcription
#'
#' @description Applies the OpenAI Whisper model to transcribe the conversation
#'
#' @param ch1 channel 1 file
#' @param ch2 channel 2 file
#' @param folder folder of the files
#' @param model_type the type of Whisper model to run, default is "base"
#' @param prompt Can prompt the model with words, names, spellings you want it to use.
#'
#' @importFrom readtextgrid read_textgrid
#' @importFrom glue glue
#' @import data.table
#' @import tuneR
#' @importFrom seewave cutw
#' @importFrom fs path
#' @import reticulate
#' @importFrom cli cli_progress_bar
#' @importFrom cli cli_progress_update
#'
#' @export
whispering <- function(ch1, ch2, folder, model_type = "base", prompt){
  # grab silence/sounding timings
  chan1_silences = readtextgrid::read_textgrid(fs::dir_ls(folder, regexp = "ch1.wav_silences"))
  chan2_silences = readtextgrid::read_textgrid(fs::dir_ls(folder, regexp = "ch2.wav_silences"))
  data.table::setDT(chan1_silences)
  data.table::setDT(chan2_silences)
  timings1 = chan1_silences[text == "sounding", .(annotation_num, start = xmin, end = xmax)]
  timings2 = chan2_silences[text == "sounding", .(annotation_num, start = xmin, end = xmax)]

  # import channels
  ch1_audio = tuneR::readWave(ch1)
  ch2_audio = tuneR::readWave(ch2)
  sample_freq1 = ch1_audio@samp.rate
  sample_freq2 = ch2_audio@samp.rate

  # create segmented audio
  ch1_files = vector("list", length = nrow(timings1))
  for (i in 1:nrow(timings1)){
    rows = timings1[i]
    start = if (rows$start-0.2 < 0) 0 else rows$start-0.2
    end = if (rows$end+0.2 > max(rows$end)) rows$end else rows$end+0.2
    audio_seg1 = seewave::cutw(ch1_audio, f = sample_freq1, from = start, to = end, output = "Wave")
    tuneR::writeWave(audio_seg1, filename = fs::path(folder, paste0("ch1_segment_", i, ".wav")))
    ch1_files[[i]] = fs::path(folder, paste0("ch1_segment_", i, ".wav"))
  }
  ch2_files = vector("list", length = nrow(timings2))
  for (i in 1:nrow(timings2)){
    rows = timings2[i]
    start = if (rows$start-0.2 < 0) 0 else rows$start-0.2
    end = if (rows$end+0.2 > max(rows$end)) rows$end else rows$end+0.2
    audio_seg2 = seewave::cutw(ch2_audio, f = sample_freq2, from = start, to = end, output = "Wave")
    tuneR::writeWave(audio_seg2, filename = fs::path(folder, paste0("ch2_segment_", i, ".wav")))
    ch2_files[[i]] = fs::path(folder, paste0("ch2_segment_", i, ".wav"))
  }

  # set up model
  whisper = reticulate::import("whisper")
  message("imported whisper")
  model = whisper$load_model(model_type)

  # channel 1
  result1 = vector("list", length = length(ch1_files))
  message1 = paste0("Transcribing Channel 1 | n = ", length(ch1_files), " |")
  cli::cli_progress_bar(message1, total = length(ch1_files))
  for (i in seq_along(ch1_files)){
    result1[[i]] = model$transcribe(ch1_files[[i]], fp16 = FALSE, initial_prompt = prompt)
    cli::cli_progress_update(set = i)
  }

  # channel 2
  result2 = vector("list", length = length(ch2_files))
  message2 = paste0("Transcribing Channel 2 | n = ", length(ch2_files), " |")
  cli::cli_progress_bar(message2, total = length(ch2_files))
  for (i in seq_along(ch2_files)){
    result2[[i]] = model$transcribe(ch2_files[[i]], fp16 = FALSE, initial_prompt = prompt)
    cli::cli_progress_update(set = i)
  }

  return(list(result1, result2))
}
