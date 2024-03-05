#' @title Python Set Up
#'
#' @description The function sets up a miniconda environment at `path_to_env`
#'
#' @param path_to_env The path to the miniconda environment
#' @param force Whether to force an a new install of minoconda
#'
#' @import reticulate
#'
#' @export
py_setup <- function(path_to_env, force = FALSE){
  # Set Up Python
  path = file.path(path_to_env, "r-py-automate")
  reticulate::install_miniconda(path, force = force)
  reticulate::use_miniconda(path)
  reticulate::conda_install(envname = path, packages = "nomkl")
  packages = c("ffmpeg-python", "numpy", "scipy", "setuptools-rust", "pydub", "llvmlite", "librosa", "numba",
               "Cmake", "wheel", "setuptools-rust", "pytorch", "torchvision")
  reticulate::conda_install(envname = path, packages = packages)
  reticulate::py_install("openai-whisper", pip = TRUE, pip_options = "-U")
  #reticulate::py_install("pyannote.audio", pip = TRUE, pip_options = "-U")
  #reticulate::py_install("light-the-torch", pip = TRUE, pip_options = "-U")
}
