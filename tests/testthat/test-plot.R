test_that("arguments valid", {
  expect_error(plot.pomcheck(iris), "x must be a pomcheck object")
})

test_that("output correct", {
  expect_message(plot(pomcheck(object=c("Species"),
                          x=c("Sepal.Width", "Petal.Length"),
                          iris)),
                 "Unable to generate plot for Petal.Length")
})
