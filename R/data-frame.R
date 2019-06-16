#' Apply a function to each element of a vector and combine into a data frame
#'
#' Unlike `map_dfr()`, `vec_map_dfr()` treats vectors as 1 row data frames.
#'
#' @inheritParams purrr::map
#'
#' @examples
#'
#' library(purrr)
#'
#' x <- stats::setNames(1:5, 1:5)
#'
#' map_dfr(x, ~ .x)
#'
#' vec_map_dfr(x, ~ .x)
#'
#' @export
vec_map_dfr <- function(.x, .f, ...) {
  vec_assert(.x)
  out <- map(.x, .f, ...)
  vctrs::vec_rbind(!!!out)
}

#' @rdname vec_map_dfr
#' @export
vec_map_dfc <- function(.x, .f, ...) {
  vec_assert(.x)
  out <- map(.x, .f, ...)
  vctrs::vec_cbind(!!!out)
}
