#' @title remove_noises
#'
#' @description Removes some of the extra noise in each channel
#'
#' @param ch1 channel 1 path
#' @param ch2 channel 2 path
#'
#' @import reticulate
#' @importFrom glue glue
#'
#' @export
remove_noises <- function(ch1, ch2){
  reticulate::repl_python(input = glue::glue('
  import llvmlite
  import librosa
  import soundfile as sf
  import numpy as np
  import zlib

  # Load audio files for channel 1 and channel 2
  channel1_audio, sr1 = librosa.load("{[ch1]}", sr=None)
  channel2_audio, sr2 = librosa.load("{[ch2]}", sr=None)

  # Ensure both channels have the same sample rate
  if sr1 != sr2:
      channel1_audio = librosa.resample(channel1_audio, sr1, sr2)

  # Calculate the maximum amplitude of channel 2
  max_amplitude_channel2 = np.max(np.abs(channel2_audio))

  # Set a threshold for attenuation (adjust as needed)
  attenuation_factor = 0.5

  # Remove sounds from channel 1 that are in channel 2
  channel1_audio_cleaned = (channel1_audio) * (np.abs(channel2_audio) / max_amplitude_channel2 <= attenuation_factor)

  # center and standardize
  channel1_audio_cleaned -= np.mean(channel1_audio_cleaned)
  channel1_audio_cleaned = channel1_audio_cleaned.astype(np.float32)
  channel1_audio_cleaned /= np.max(np.abs(channel1_audio_cleaned))

  # Save the cleaned audio to a new file
  sf.write(ch1.replace(".", "_cleaned."), channel1_audio_cleaned, sr2)

  from pydub import AudioSegment

  def remove_noise_and_trim(input_audio_file, output_audio_file, noise_threshold=500, ms=500):
      # Load the input audio file
      audio = AudioSegment.from_file(input_audio_file)
      # Define the duration to trim from both ends (0.5 seconds in milliseconds)
      trim_duration = 500  # milliseconds
      # Trim the first and last half-second
      trimmed_audio = audio[trim_duration:-trim_duration]
      # Convert the AudioSegment object to a NumPy array
      audio_array = np.array(trimmed_audio.get_array_of_samples())
      # Define a threshold for outlier detection (adjust as needed)
      # remove outliers
      top_percentile = 99.99  # The top 1% corresponds to the 99th percentile
      top_percentile_value = np.percentile(audio_array, top_percentile)
      # Detect outliers based on the threshold
      outliers = np.where(np.abs(audio_array) > top_percentile_value)[0]
      # Replace the outlier samples with zeros (or another value)
      audio_array_without_outliers = np.copy(audio_array)
      audio_array_without_outliers[outliers] = 0
      # Convert the modified array back to an AudioSegment object
      modified_audio = AudioSegment(audio_array_without_outliers.tobytes(),
                               frame_rate=audio.frame_rate,
                               sample_width=audio.sample_width,
                               channels=audio.channels)
      # Initialize variables
      silence = AudioSegment.silent(duration=ms)
      # Create an empty audio segment to hold the audio without noise
      audio_without_noise = AudioSegment.empty()
      for i in range(0, len(modified_audio), ms):  # Process in chunks of `ms`
           chunk = modified_audio[i:i + ms]  # Get a `ms` chunk of audio
           chunk_max = chunk.max
           if chunk_max > noise_threshold:
               audio_without_noise += chunk
           else:
               audio_without_noise += silence
      # Export the filtered audio to a new file
      audio_without_noise.export(output_audio_file, format="wav")

  final_ch1 = ch1.replace(".", "_cleaned.")
  silence_threshold = 700
  ms = 500
  remove_noise_and_trim(final_ch1, final_ch1, silence_threshold, ms)
  ',
  .open = "{[",
  .close = "]}"
  ))

  return(c(py$WAV_FILENAME, py$final_ch1))
}
