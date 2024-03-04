#' @title split_channels
#'
#' @description Splits the wav file into the two channels
#'
#' @param wav_file The path to the wav file
#'
#' @import reticulate
#' @importFrom glue glue
#'
#' @export
split_channels <- function(wav_file){
  reticulate::repl_python(input = glue::glue('
  import wave
  import numpy as np

  def save_wav_channel(fn, wav, channel):
      # Read data
      nch   = wav.getnchannels()
      depth = wav.getsampwidth()
      wav.setpos(0)
      sdata = wav.readframes(wav.getnframes())

      # Extract channel data (24-bit data not supported)
      typ = { 1: np.uint8, 2: np.uint16, 4: np.uint32 }.get(depth)
      if not typ:
        raise ValueError("sample width {} not supported".format(depth))
      if channel >= nch:
        raise ValueError("cannot extract channel {} out of {}".format(channel+1, nch))
      print ("Extracting channel {} out of {} channels, {}-bit depth".format(channel+1, nch, depth*8))
      data = np.frombuffer(sdata, dtype=typ)
      ch_data = data[channel::nch]

      # Save channel to a separate file
      outwav = wave.open(fn, "w")
      outwav.setparams(wav.getparams())
      outwav.setnchannels(1)
      outwav.writeframes(ch_data.tobytes())
      outwav.close()

  WAV_FILENAME = "{[wav_file]}"
  ch1 = WAV_FILENAME.replace(".", "_ch1.")
  ch2 = WAV_FILENAME.replace(".", "_ch2.")
  wav = wave.open(WAV_FILENAME)
  save_wav_channel(ch1, wav, 0)
  save_wav_channel(ch2, wav, 1)
  ',
  .open = "{[",
  .close = "]}"
  ))

  return(c(py$ch1, py$ch2))
}
