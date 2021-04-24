#' Graphical check for proportional odds assumption
#'
#' Implements the method described in \url{https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/}
#' for checking if the proportional odds assumption holds for a cumulative logit model.
#'
#' @param object an object
#' @param \dots currently unused
#'
#' @return an object of class 'pomcheck'
#'
#' @importFrom rlang .data
#' @importFrom rlang :=
#'
#' @seealso \code{\link{plot.pomcheck}}
#'
#' @export
#' @examples
#' pomcheck(Species ~ Sepal.Length, iris)
#' pomcheck(Species ~ Sepal.Length + Sepal.Width, iris)
#' pomcheck(object="Species", x="Sepal.Length", iris)
#' pomcheck(object="Species", x=c("Sepal.Length", "Sepal.Width"), iris)
pomcheck <- function(object,...) UseMethod("pomcheck")

#' @param object character string for response
#' @param x vector of character string(s) for explanatory variable(s)
#' @param data data frame containing the variables y and x
#'
#' @describeIn pomcheck default
#' @export
pomcheck.default  <- function(object, x, data,...)
{
  lhs <- object
  rhs <- x
  assertthat::assert_that(is.data.frame(data))
  assertthat::assert_that(is.character(lhs))
  assertthat::assert_that(is.character(rhs))
  assertthat::assert_that(length(lhs)==1)
  # Check lhs is a factor
  assertthat::assert_that(with(data, is.factor(get(lhs))),
                          msg="object must be a factor")
  # Check lhs has at least 3 levels
  assertthat::assert_that(with(data, length(levels(get(lhs))) >= 3),
                          msg="object must have at least three levels")

  # Create empty list to hold results
  result <- vector(mode="list", length=length(rhs))
  class(result) <- append("pomcheck", "list")

  for (idx in seq_along(rhs))
  {
    tmp <- rhs[idx]
    tmpdat <- data
    # Check if rhs variable is numeric
    if (with(data, is.numeric(get(tmp))))
    {
      # split into quantiles
      q <- stats::quantile(with(data, get(tmp)))
      tmpdat <- data %>%
        dplyr::mutate(category=cut(.data[[tmp]],
                            breaks=stats::quantile(.data[[tmp]]),
                            include.lowest = TRUE)) %>%
        dplyr::select(-dplyr::sym(tmp)) %>%
        dplyr::rename(!! tmp := .data$category)
      #tmp <- "category"
    }

    res1 <- tmpdat %>%
      dplyr::mutate(nlhs = as.numeric(.data[[lhs]])) %>%
      dplyr::group_by(.data[[tmp]], .data$nlhs) %>%
      dplyr::summarize(n=dplyr::n(), .groups = "drop_last") %>%
      dplyr::mutate(ntotal = rev(cumsum(rev(.data$n))),
                    p = stats::qlogis(.data$ntotal/sum(.data$n))) %>%
      dplyr::select(c(.data[[tmp]], .data$nlhs, .data$p)) %>%
      tidyr::pivot_wider(names_from = .data$nlhs,
                         names_prefix = paste0(lhs,"_>="),
                         values_from=.data$p)

    # Add to list to return to user
    attr(res1, "variable") <- rhs[idx]
    result[[idx]] = res1
  }

  return(result)
}

#' @param formula formula of the form y ~ x1 + x2 + ...
#' @param data data frame containing the variables
#'
#' @describeIn pomcheck supports formula specification
#' @export
pomcheck.formula <- function(formula, data,...)
{
  #assertthat::assert_that(rlang::is_formula(x))
  t <- all.vars(formula)
  x <- t[1]
  y <- t[-1]
  pomcheck.default(x, y, data)
}
