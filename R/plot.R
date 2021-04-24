#' Graphical check for proportional odds assumption
#'
#'Generates the plots described in \url{https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/}
#' for checking if the proportional odds assumption holds for a cumulative logit model.
#'
#' @param x a pomcheck object
#' @param legend.position the position of legends ("none", "left", "right", "bottom", "top", or two-element numeric vector)
#' @param \dots currently unused
#'
#' @return None
#' @export
#'
#' @seealso \code{\link{pomcheck}}
#'
#' @examples
#' plot(pomcheck(Species ~ Sepal.Width, iris))
plot.pomcheck <- function(x, legend.position = "none", ...)
{
  assertthat::assert_that(inherits(x, "pomcheck"),
                          msg = "x must be a pomcheck object")
  for (idx in seq_along(x))
  {
    res1 <- x[[idx]]
    # Get explanatory variable
    tmp <- attr(res1, "variable")
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
          ggplot2::labs(y=tmp) +
          ggplot2::scale_colour_discrete(labels = function(x) stringr::str_wrap(x, width = 10,
                                                                                 whitespace_only=FALSE)) +
          ggplot2::scale_y_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
          ggplot2::xlim(NA, 0) +
          ggplot2::theme(legend.position = legend.position)
      )
    }
    else
    {
      message(paste0("Unable to generate plot for ", tmp,
                     ". Counts must be > 0 in at least 3 categories in
                     order to calculate proportional odds."))
    }
  }
}
