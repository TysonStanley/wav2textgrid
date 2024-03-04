#' @title Dominant Channel
#'
#' @description Finds the dominant channel for part of the conversation to determine which
#' speaker is speaking.
#'
#' @param wav_file the original `wav_file` path
#'
#' @import reticulate
#' @importFrom glue glue
#'
#' @export
dom_channel <- function(wav_file){
  reticulate::repl_python(input = glue::glue('
  import numpy as np
  from scipy.io import wavfile

  # Load the WAV file
  sample_rate, stereo_audio = wavfile.read("{[wav_file]}")

  # Ensure that the stereo audio has two channels
  if stereo_audio.ndim != 2:
      raise ValueError("The input audio is not stereo.")

  # Calculate the number of samples per half-second
  samples_per_half_second = sample_rate // 2  # Half of the sample rate

  # Initialize a list to store the dominant channel at each half-second
  dominant_channel = []

  # Iterate through the audio data, calculating peak amplitude per half-second
  for i in range(0, len(stereo_audio), samples_per_half_second):
      start_idx = i
      end_idx = min(i + samples_per_half_second, len(stereo_audio))
      # Extract half-second of audio data for each channel
      channel1_data = stereo_audio[start_idx:end_idx, 0]
      channel2_data = stereo_audio[start_idx:end_idx, 1]
      # Calculate the peak amplitude for each channel
      peak_amplitude_channel1 = np.max(np.abs(channel1_data))
      peak_amplitude_channel2 = np.max(np.abs(channel2_data))
      # Compare the peak amplitudes to determine the dominant channel
      if peak_amplitude_channel1 > peak_amplitude_channel2:
          dominant_channel.append(1)  # Channel 1 is dominant
      else:
          dominant_channel.append(2)  # Channel 2 is dominant

  print("Finished dominant channels")
  ',
  .open = "{[",
  .close = "]}"
  ))
  return(py$dominant_channel)
}
