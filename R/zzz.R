.onLoad <- function(libname = find.package("furniture"),
                    pkgname = "furniture") {
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c(".", "1", "2", "channel", "dist", "dom", "end.x", "i.end", "i.id", "i.text", "id", "min_dist", "start", "start.x", "text"))
  }
  invisible()
}
