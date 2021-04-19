#' Graphical check for proportional odds assumption
#'
#' Generates the plots described in \url{https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/}
#' for checking if the proportional odds assumption holds for a cumulative logit model.
#'
#' @param object an object
#' @param \dots additional arguments
#'
#' @return None
#'
#' @importFrom rlang .data
#'
#' @export
#' @examples
#' pomcheck(Species ~ Sepal.Length, iris)
#' pomcheck(object="Species", x="Sepal.Length", iris)
#' pomcheck(object="Species", x=c("Sepal.Length", "Sepal.Width"), iris)
pomcheck <- function(object,...) UseMethod("pomcheck")

#' @param object character string for response
#' @param x vector of character string(s) for explanatory variable(s)
#' @param dat data frame containing the variables y and x
#'
#' @describeIn pomcheck default
#' @export
pomcheck.default  <- function(object, x, dat,...)
{
  lhs <- object
  rhs <- x
  assertthat::assert_that(is.data.frame(dat))
  assertthat::assert_that(is.character(lhs))
  assertthat::assert_that(is.character(rhs))
  assertthat::assert_that(length(lhs)==1)
  # assertthat::assert_that(rlang::is_formula(f))
  # t <- all.vars(f)
  # lhs <- t[1]
  # rhs <- t[-1]
  # Check lhs is a factor
  assertthat::assert_that(with(dat, is.factor(get(lhs))))
  # Check lhs has at least 3 levels
  assertthat::assert_that(with(dat, length(levels(get(lhs))) >= 3))

  for (idx in seq_along(rhs))
  {
    tmp <- rhs[idx]
    tmpdat <- dat
    # Check if rhs variable is numeric
    if (with(dat, is.numeric(get(tmp))))
    {
      # split into quantiles
      q <- stats::quantile(with(dat, get(tmp)))
      tmpdat <- dat %>%
        dplyr::mutate(category=cut(.data[[tmp]],
                            breaks=stats::quantile(.data[[tmp]]),
                            include.lowest = TRUE))
      tmp <- "category"
    }

    print(
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
    )

    # Get number of columns
    nc <- ncol(res1)

    # Check that at least two columns are finite
    if(any(rowSums(sapply(res1[,2:nc], is.finite)) >= 2))
    {
      # Now get differences between columns
      res2 <- cbind(res1[,1], res1[,3:nc] - res1[,2:(nc-1)])

      print(
        res2 %>%
          tidyr::pivot_longer(-c(.data[[tmp]]), names_to="label") %>%
          dplyr::filter(is.finite(.data$value)) %>%
          ggplot2::ggplot() +
          ggplot2::geom_point(mapping=ggplot2::aes(x=.data$value,
                                                   y=.data[[tmp]],
                                                   color=.data$label)) +
          ggplot2::labs(y=rhs[idx]) +
          ggplot2::xlim(NA, 0)
      )
    }
    else
    {
      message("Unable to generate plots. Counts must be > 0 in at least 3 categories in order to calculate proportional odds.")
    }
  }
}

#' @param formula A formula of the form y ~ x1 + x2 + ...
#' @param dat data frame containing the variables in the formula
#'
#' @describeIn pomcheck Graphical check given formula specification
#' @export
pomcheck.formula <- function(formula, dat,...)
{
  #assertthat::assert_that(rlang::is_formula(x))
  t <- all.vars(formula)
  x <- t[1]
  y <- t[-1]
  pomcheck.default(x, y, dat)
}
