pomcheck <- function(df, f)
{
  t <- all.vars(f)
  lhs <- t[1]
  rhs <- t[-1]
  # Check t[1] is a factor
  if (!with(dat, is.factor(get(lhs))))
  {
    #raise error
  }
  # Check t[1] has at least 3 levels
  if (length(levels(get(lhs))) < 3)
  {
    #raise error
  }

  for (idx in seq_along(rhs))
  {
    tmp <- rhs[idx]
    tmpdat <- dat
    # Check if rhs variable is numeric
    if (with(dat, is.numeric(get(tmp))))
    {
      # split into quantiles
      q <- quantile(with(dat, get(tmp)))
      tmpdat <- dat %>%
        mutate(category=cut(.data[[tmp]],
                            breaks=quantile(.data[[tmp]]),
                            include.lowest = TRUE))
      tmp <- "category"
    }

    print(
      res1 <- tmpdat %>%
        mutate(napply = as.numeric(apply)) %>%
        group_by(.data[[tmp]], napply) %>%
        summarize(n=n(), .groups = "drop_last") %>%
        mutate(ntotal = rev(cumsum(rev(n))),
               p = qlogis(ntotal/sum(n))) %>%
        select(c(.data[[tmp]], napply, p)) %>%
        pivot_wider(names_from = napply,
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
        pivot_longer(-c(.data[[tmp]]), names_to="label") %>%
        ggplot() +
        geom_point(mapping=aes(x=value, y=.data[[tmp]],
                               color=label)) +
        labs(y=rhs[idx])
    )
  }
}
