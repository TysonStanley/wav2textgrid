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
  browser()
  # grab segments
  chan1 = purrr::map(whispered1, ~.x[["segments"]])
  chan2 = purrr::map(whispered2, ~.x[["segments"]])
  lengths1 = purrr::map_dbl(chan1, ~length(.x))
  lengths2 = purrr::map_dbl(chan2, ~length(.x))

  # extract text
  chan1_text = purrr::map2(lengths1, seq_along(chan1), ~{
    if (.x == 0){
      "NA"
    } else if (.x > 0){
      paste(chan1[[.y]][[1]]$text, collapse = " ")
    }
  })
  chan2_text = purrr::map2(lengths2, seq_along(chan2), ~{
    if (.x == 0){
      "NA"
    } else if (.x > 0){
      paste(chan2[[.y]][[1]]$text, collapse = " ")
    }
  })

  chan1_text = tolower(chan1_text)
  chan1_text = stringr::str_squish(stringr::str_remove_all(chan1_text, "\\.|\\,"))
  chan1_text = stringr::str_replace_all(chan1_text, "^thank you$", "[bc]")
  chan1_text = data.table::data.table(text = chan1_text)
  chan2_text = tolower(chan2_text)
  chan2_text = stringr::str_squish(stringr::str_remove_all(chan2_text, "\\.|\\,"))
  chan2_text = stringr::str_replace_all(chan2_text, "^thank you$", "[bc]")
  chan2_text = data.table::data.table(text = chan2_text)

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

  # join with text
  chan1_joined = cbind(chan1_silences, chan1_text)
  chan2_joined = cbind(chan2_silences, chan2_text)

  # channels
  chan1_joined[, channel := 1]
  chan2_joined[, channel := 2]

  # add "n" for non-speech
  non1 = chan1_joined[, .(start = end, end = data.table::shift(start, type = "lead"))]
  non2 = chan2_joined[, .(start = end, end = data.table::shift(start, type = "lead"))]
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
