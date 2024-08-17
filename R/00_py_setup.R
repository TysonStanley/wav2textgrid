#' @title Python Set Up
#'
#' @description The function sets up a miniconda environment at `path_to_env`
#'
#' @param path The path to the miniconda environment
#' @param install Whether to install conda at the specified path (default = TRUE)
#'
#' @import reticulate
#' @importFrom cli cli_process_start
#' @importFrom cli cli_process_done
#'
#' @export
py_setup <- function(path, install = TRUE){
  cli::cli_process_start(msg = "Begin python environment set up")
  if (install) {
    reticulate::conda_create(envname = path, python_version = "3.11")
  }

  reticulate::use_condaenv(path, required = TRUE)
  packages = c("ffmpeg-python", "numpy", "scipy", "setuptools-rust", "pydub", "llvmlite", "librosa", "numba",
               "Cmake", "wheel", "setuptools-rust", "pytorch", "torchvision")
  reticulate::conda_install(envname = path, packages = packages)
  reticulate::py_install("openai-whisper", pip = TRUE, pip_options = "-U")
  reticulate::py_install("light-the-torch", pip = TRUE, pip_options = "-U")
  cli::cli_process_done(msg_done = "Completed python environment set up")
}
