#' @title Clean Up Results
#'
#' @description Cleans up the data produced by Whisper and the dominant channel analysis.
#'
#' @param result_full The Whisper results for the full conversation
#' @param result1 The Whisper results for the channel 1 of the conversation
#' @param doms The results of the dominant channel analysis
#'
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom tibble tibble
#' @importFrom fuzzyjoin interval_join
#' @importFrom dplyr full_join
#' @importFrom dplyr select
#' @importFrom dplyr case_when
#' @importFrom dplyr arrange
#' @importFrom stringr str_trim
#' @importFrom tidyr pivot_wider
#' @importFrom tidyr pivot_longer
#' @importFrom stringdist stringdist
#' @import data.table
#'
#' @export
clean_up <- function(result_full, result1, doms){
  segs_full = result_full[["segments"]]
  segs_ch1 = result1[["segments"]]

  segfull_tbl = purrr::map(seq_along(segs_full), ~{
    tibble::tibble(
      id = segs_full[[.x]]$id,
      start = segs_full[[.x]]$start,
      end = segs_full[[.x]]$end,
      text = segs_full[[.x]]$text
    )
  })
  segfull_tbl = do.call("bind_rows", segfull_tbl)
  segfull_tbl$text = tolower(segfull_tbl$text)

  seg1_tbl = purrr::map(seq_along(segs_ch1), ~{
    tibble::tibble(
      id = segs_ch1[[.x]]$id,
      start = segs_ch1[[.x]]$start,
      end = segs_ch1[[.x]]$end,
      text = segs_ch1[[.x]]$text
    )
  })
  seg1_tbl = do.call("bind_rows", seg1_tbl)
  seg1_tbl$text = tolower(seg1_tbl$text)

  data.table::setDT(segfull_tbl)
  data.table::setDT(seg1_tbl)

  dom_channel = tibble::tibble(
    dom = doms
  )
  dom_channel$sec = (1:nrow(dom_channel))/2
  dom_channel$start = dom_channel$sec
  dom_channel$end = dom_channel$sec+.5

  interval_data = fuzzyjoin::interval_join(segfull_tbl, dom_channel, by = c("start", "end"))
  data.table::setDT(interval_data)
  interval_data = interval_data[, .(dom = mean(dom)), by = .(id, text, start.x, end.x)]
  interval_data = interval_data[, .(id, dom)]

  seg_tbl = seg1_tbl[segfull_tbl, on = "start", roll='nearest']
  seg_tbl[, dist := stringdist::stringdist(text, i.text)]
  seg_tbl[, min_dist := min(dist), by = id]
  seg_tbl[, channel := fifelse(dist == min_dist, 1, 2)]
  final = dplyr::select(seg_tbl, id = i.id, start, end = i.end, text = i.text, channel)

  # when the dominant channel is uncertain, use the channel based on the stringdist
  final2 = dplyr::full_join(final, interval_data, by = "id")
  final2$dom = dplyr::case_when(final2$dom > 1.65 ~ 2, final2$dom  < 1.35 ~ 1, .default = final2$channel)

  # add 'n' to non speaking turns for each channel
  final3 = tidyr::pivot_wider(final2, names_from = dom, values_from = text)
  data.table::setDT(final3)
  final3[, `1` := ifelse(is.na(`1`), "n", `1`)]
  final3[, `2` := ifelse(is.na(`2`), "n", `2`)]
  final3[, channel := NULL]
  final3 = tidyr::pivot_longer(final3, cols = `1`:`2`, names_to = "channel", values_to = "text")
  final3$channel = as.numeric(final3$channel)
  final3$text = stringr::str_trim(final3$text)
  final3 = dplyr::arrange(final3, id)
  return(final3)
}
