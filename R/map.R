#' Apply a function to each element of a vector
#'
#' `vec_map()` is like [purrr::map()], but can automatically simplify the output
#' based on vctrs type rules. This does away with the need for variants such
#' as `map_dbl()`, and is more expressive because the output type can be
#' anything, for example, a `Date` vector.
#'
#' @details
#'
#' If `.ptype = NULL`, the common type of the results of the `map()` will
#' attempt to be determined. If a common type can be found, then the result
#' will be simplified to that type. Otherwise, a list is returned.
#'
#' If a common type is found, it is a requirement that every element have
#' size `1`. This enforces the invariant that the size of the input is the
#' same size as the output.
#'
#' You can force an output type by specifying the `.ptype`. For example,
#' specifying `.ptype = double()` is equivalent to `map_dbl()`.
#'
#' Setting `.ptype = list()` is equivalent to `map()`.
#'
#' @inheritParams purrr::map
#'
#' @param .ptype A prototype for the output container. If `NULL`, a common
#' type is determined from the individual results of the `map()`. If no
#' common type can be determined, the output container is a `list()`.
#'
#' @section Invariants:
#'
#' `vec_size(.x) == vec_size(vec_map(.x))`
#'
#' @examples
#'
#' library(vctrs)
#'
#' # Auto simplified to an integer vector
#' vec_map(1:2, ~ .x)
#'
#' # Prevent simplification with `.ptype = list()`
#' vec_map(1:2, ~ .x, .ptype = list())
#'
#' # If a `.ptype` is specified, and casting to that type
#' # is not possible, an error is raised
#' try(vec_map(1:2, ~ .x, .ptype = factor()))
#'
#' # If simplification is possible, all elements must have size 1,
#' # otherwise an error is raised
#' try(vec_map(1:2, ~ if (.x == 1L) 1:2 else 3))
#'
#' # But if you use `.ptype = list()`, this is relaxed
#' # (However, note that the size of the output is still the
#' # same as the size of the input (2), this is the key!)
#' vec_map(1:2, ~ if (.x == 1L) 1:2 else 3, .ptype = list())
#'
#' # The best thing about `vec_map()` is its flexibility with other
#' # non-atomic types, for example, simplifying to a date vector
#' vec_map(1:2, ~ Sys.Date() + .x)
#'
#' # If a common type cannot be determined, a list is returned
#' vec_map(list(1, "x"), ~ .x)
#'
#' # Note that just because a common type isn't found, doesn't mean you
#' # can't still coerce to a certain type. This is the difference between
#' # _coercion_ (automatic type casting) and a _cast_ which is slightly more
#' # flexible because you are specifically requesting the output type.
#' vec_map(list(1, "x"), ~ .x, .ptype = character())
#'
#' # Data frames work too
#' vec_map(1:2, ~ data.frame(x = .x))
#'
#' # You can enforce the structure of the data frame output with a ptype.
#' # This has the same result as before but coerces the integers to characters
#' ptype <- data.frame(x = character(), stringsAsFactors = FALSE)
#' vec_map(1:2, ~ data.frame(x = .x), .ptype = ptype)
#'
#' # Or you can enforce a partial structure with a partial_frame()
#' partial_ptype <- partial_frame(y = numeric())
#' vec_map(1:2, ~ data.frame(x = .x, y = .x + 1), .ptype = partial_ptype)
#'
#' @export
vec_map <- function(.x, .f, ..., .ptype = NULL) {
  out <- map(.x, .f, ...)
  vec_simplify(out, .ptype = .ptype)
}

#' Strictly apply a function to each element of a vector
#'
#' `vec_map_strict()` is `vec_map()`, but without the common type determination.
#' You _must_ supply a `.ptype` for `vec_map_strict()`, and `NULL` is not
#' allowed.
#'
#' @inheritParams purrr::map
#'
#' @param .ptype A prototype for the output container.
#'
#' @export
vec_map_strict <- function(.x, .f, ..., .ptype = list()) {
  vec_assert(.ptype)
  out <- map(.x, .f, ...)
  vec_simplify(out, .ptype = .ptype)
}

vec_simplify <- function(x, .ptype = NULL) {
  .ptype <- tryCatch(
    expr = {
      vec_type_common(!!!x, .ptype = .ptype)
    },
    vctrs_error_incompatible_type = function(e) {
      list()
    }
  )

  if (vec_is(.ptype, ptype = list())) {
    return(x)
  }

  # enforce size of 1 if not a list()
  vec_recycle_common(!!!x, .size = 1L)

  vec_c(!!!x, .ptype = .ptype)
}
