.onLoad <- function(libname = find.package("wav2textgrid"),
                    pkgname = "wav2textgrid") {
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c("osVersion", "end", "xmin", "folder", "xmax", "annotation_num", ".", "1", "2", "channel", "dist", "dom", "end.x", "i.end", "i.id", "i.text", "id", "min_dist", "start", "start.x", "text"))
  }
  invisible()
}
