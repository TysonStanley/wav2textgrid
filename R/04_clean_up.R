#' @title Clean Up Whisper Output
#'
#' @description Cleans up the data to get it ready for making
#' the TextGrid file.
#'
#' @param whispered1 channel one whisper data output
#' @param whispered2 channel two whisper data output
#' @param folder the folder where the files are located
#'
#' @import reticulate
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @import data.table
#' @importFrom readtextgrid read_textgrid
#' @importFrom stringr str_trim
#' @importFrom furniture washer
#'
#' @export
clean_up <- function(whispered1, whispered2, folder){
  # grab segments
  chan1 = purrr::map(whispered1, ~.x[["segments"]])
  chan2 = purrr::map(whispered2, ~.x[["segments"]])
  chan1 = purrr::map(chan1, ~purrr::pluck(.x, 1))
  chan2 = purrr::map(chan2, ~purrr::pluck(.x, 1))

  # create tibble channel 1
  channel1 = purrr::map(seq_along(chan1), ~{
    tibble::tibble(
      id = .x,
      #start = chan1[[.x]]$start,
      #end = chan1[[.x]]$end,
      text = chan1[[.x]]$text
    )
  })
  channel1 = do.call("bind_rows", channel1)
  channel1$text = tolower(channel1$text)

  # create tibble channel 2
  channel2 = purrr::map(seq_along(chan2), ~{
    tibble::tibble(
      id = .x,
      #start = chan2[[.x]]$start,
      #end = chan2[[.x]]$end,
      text = chan2[[.x]]$text
    )
  })
  channel2 = do.call("bind_rows", channel2)
  channel2$text = tolower(channel2$text)

  data.table::setDT(channel1)
  data.table::setDT(channel2)

  # grab silences file
  chan1_silences = readtextgrid::read_textgrid(fs::dir_ls(folder, regexp = "ch1.wav_silences"))
  chan2_silences = readtextgrid::read_textgrid(fs::dir_ls(folder, regexp = "ch2.wav_silences"))
  data.table::setDT(chan1_silences)
  data.table::setDT(chan2_silences)
  data.table::setnames(chan1_silences, old = c("xmin", "xmax"), new = c("start", "end"))
  data.table::setnames(chan2_silences, old = c("xmin", "xmax"), new = c("start", "end"))
  chan1_silences = chan1_silences[text == "sounding"]
  chan2_silences = chan2_silences[text == "sounding"]
  chan1_silences[, text := NULL]
  chan2_silences[, text := NULL]
  chan1_silences[, id := .I]
  chan2_silences[, id := .I]

  # join with text
  chan1_joined = merge(channel1, chan1_silences, by = "id")
  chan2_joined = merge(channel2, chan2_silences, by = "id")

  # channels
  chan1_joined[, channel := 1]
  chan2_joined[, channel := 2]

  # add "n" for non-speech
  non1 = chan1_joined[, .(start = end, end = shift(start, type = "lead"))]
  non2 = chan2_joined[, .(start = end, end = shift(start, type = "lead"))]
  non1[, text := "n"]
  non2[, text := "n"]
  non1[, channel := 1]
  non2[, channel := 2]
  begin1 = chan1_joined[, .(end = min(start), start = 0, text = "n", channel = 1)]
  begin2 = chan2_joined[, .(end = min(start), start = 0, text = "n", channel = 2)]

  # combine
  chan1_joined = data.table::rbindlist(list(chan1_joined, non1, begin1), fill = TRUE)
  chan2_joined = data.table::rbindlist(list(chan2_joined, non2, begin2), fill = TRUE)
  chan1_joined = chan1_joined[order(start)]
  chan2_joined = chan2_joined[order(start)]

  # bind
  final = data.table::rbindlist(list(chan1_joined, chan2_joined))
  final[, channel := as.numeric(channel)]
  final[, text := gsub("\\.|\\?", " ", text)]
  final[, text := gsub("\\,", "", text)]
  final[, text := stringr::str_trim(text)]
  final[, end := furniture::washer(end, is.na, value = max(end, na.rm=TRUE))]
  return(final)
}
