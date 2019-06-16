
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vcturrrs

<!-- badges: start -->

<!-- badges: end -->

An exploration of vctrs + purrr.

## Example

``` r
library(vcturrrs)
library(vctrs)

# Auto simplified to an integer vector
vec_map(1:2, ~ .x)
#> [1] 1 2

# Prevent simplification with `.ptype = list()`
vec_map(1:2, ~ .x, .ptype = list())
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2

# If a `.ptype` is specified, and casting to that type
# is not possible, an error is raised
try(vec_map(1:2, ~ .x, .ptype = factor()))
#> Error : Can't cast <integer> to <factor<>>

# If simplification is possible, all elements must have size 1,
# otherwise an error is raised
try(vec_map(1:2, ~ if (.x == 1L) 1:2 else 3))
#> Error : Incompatible lengths: 2, 1

# But if you use `.ptype = list()`, this is relaxed
# (However, note that the size of the output is still the
# same as the size of the input (2), this is the key!)
vec_map(1:2, ~ if (.x == 1L) 1:2 else 3, .ptype = list())
#> [[1]]
#> [1] 1 2
#> 
#> [[2]]
#> [1] 3

# The best thing about `vec_map()` is its flexibility with other
# non-atomic types, for example, simplifying to a date vector
vec_map(1:2, ~ Sys.Date() + .x)
#> [1] "2019-06-16" "2019-06-17"

# If a common type cannot be determined, a list is returned
vec_map(list(1, "x"), ~ .x)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] "x"

# Note that just because a common type isn't found, doesn't mean you
# can't still coerce to a certain type. This is the difference between
# _coercion_ (automatic type casting) and a _cast_ which is slightly more
# flexible because you are specifically requesting the output type.
vec_map(list(1, "x"), ~ .x, .ptype = character())
#> [1] "1" "x"

# Data frames work too
vec_map(1:2, ~ data.frame(x = .x))
#>   x
#> 1 1
#> 2 2

# You can enforce the structure of the data frame output with a ptype.
# This has the same result as before but coerces the integers to characters
ptype <- data.frame(x = character(), stringsAsFactors = FALSE)
vec_map(1:2, ~ data.frame(x = .x), .ptype = ptype)
#>   x
#> 1 1
#> 2 2

# Or you can enforce a partial structure with a partial_frame()
partial_ptype <- partial_frame(y = numeric())
vec_map(1:2, ~ data.frame(x = .x, y = .x + 1), .ptype = partial_ptype)
#>   x y
#> 1 1 2
#> 2 2 3
```

There is a strict version of `vec_map()` that does not allow for any
“guessing” of the ptype using vctrs rules.

``` r
# By default, it works like map()
vec_map_strict(1:2, ~ .x)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] 2

# You have to specify the ptype to get simplification
vec_map_strict(1:2, ~ .x, .ptype = integer())
#> [1] 1 2
```
