#' Title
#'
#' @param df
#' @param f
#'
#' @return
#' @export
#'
#' @importFrom rlang .data
#'
#' @examples
pomcheck <- function(df, f)
{
  t <- all.vars(f)
  lhs <- t[1]
  rhs <- t[-1]
  # Check t[1] is a factor
  assertthat::assert_that(with(dat, is.factor(get(lhs))))
  # Check t[1] has at least 3 levels
  assertthat::assert_that(length(levels(get(lhs))) < 3)


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
        dplyr::mutate(napply = as.numeric(apply)) %>%
        dplyr::group_by(.data[[tmp]], napply) %>%
        dplyr::summarize(n=n(), .groups = "drop_last") %>%
        dplyr::mutate(ntotal = rev(cumsum(rev(n))),
               p = stats::qlogis(ntotal/sum(n))) %>%
        dplyr::select(c(.data[[tmp]], napply, p)) %>%
        tidyr::pivot_wider(names_from = napply,
                    names_prefix = "apply_>=",
                    values_from=p)
    )

    # Get number of columns
    nc <- ncol(res1)
    # Now get differences between columns
    print(
      res2 <- cbind(res1[,1], res1[,3:nc] - res1[,2:(nc-1)])
    )
    res2[,2] <- 0

    print(
      res2 %>%
        tidyr::pivot_longer(-c(.data[[tmp]]), names_to="label") %>%
        ggplot2::ggplot() +
        ggplot2::geom_point(mapping=ggplot2::aes(x=.data$value,
                                                 y=.data[[tmp]],
                               color=.data$label)) +
        ggplot2::labs(y=rhs[idx])
    )
  }
}
