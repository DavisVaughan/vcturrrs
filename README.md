
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
#> [1] "2019-06-17" "2019-06-18"

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

## Solving issues

``` r
library(purrr)
```

``` r
# https://github.com/tidyverse/purrr/issues/679
map(NULL, ~ .x)
#> list()

vec_map(NULL, ~ .x)
#> `.x` must be a vector, not NULL
```

``` r
# https://github.com/tidyverse/purrr/issues/633
map_chr(1:2, length)
#> [1] "1" "1"

# I think this one is actually okay because you are explicit about wanting
# a character back? So if the cast is possible, do it.
vec_map(1:2, length, .ptype = character())
#> [1] "1" "1"
```

``` r
# https://github.com/tidyverse/purrr/issues/472
list_of_vecs <- list(
  a = c(x = 1, y = 1, z = 1, w = 1), 
  b = c(x = 2, y = 2, z = 2, w = 2), 
  c = c(x = 3, y = 3, z = 3, w = 3)
)

map_dfr(list_of_vecs, ~.x)
#> # A tibble: 4 x 3
#>       a     b     c
#>   <dbl> <dbl> <dbl>
#> 1     1     2     3
#> 2     1     2     3
#> 3     1     2     3
#> 4     1     2     3

vec_map_dfr(list_of_vecs, ~ .x)
#>   x y z w
#> 1 1 1 1 1
#> 2 2 2 2 2
#> 3 3 3 3 3
```

``` r
# https://github.com/tidyverse/purrr/issues/376
nested <- list(
  col1 = list(
    c("Apple", "Banana"),
    c("Orange")
  ),
  col2 = list(
    c("Baseball", "Soccer"),
    c("Football")
  )
)

map_dfc(nested, map, sprintf, fmt = "I like %s")
#> Error: Argument 2 must be length 2, not 1

vec_map_dfc(nested, map, sprintf, fmt = "I like %s")
#>                          col1                           col2
#> 1 I like Apple, I like Banana I like Baseball, I like Soccer
#> 2               I like Orange                I like Football
```
