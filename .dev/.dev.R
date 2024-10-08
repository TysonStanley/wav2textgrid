devtools::document(here::here())
devtools::check(here::here())
devtools::load_all(here::here())

usethis::use_readme_rmd(here::here())
usethis::use_lifecycle_badge("experimental")
usethis::use_cran_badge()
usethis::use_github_actions_badge()
usethis::use_github_action("check-standard")
usethis::use_testthat()
usethis::use_test("01_tests")
usethis::use_package("reticulate")

