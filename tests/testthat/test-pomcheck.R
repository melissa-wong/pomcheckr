test_that("arguments valid", {
  expect_error(pomcheck(c("Species", "Sepal.Length"), "Sepal.Width", iris),
               "not equal to 1")
  expect_error(pomcheck("Sepal.Width", "Sepal.Width", iris),
               "object must be a factor")
  expect_error(pomcheck(supp ~ len, ToothGrowth),
               "object must have at least three levels")
})

test_that("result correct", {
  p <- pomcheck(object=c("Species"),
                x=c("Sepal.Width", "Sepal.Length"),
                iris)
  # Expected result
  expect_s3_class(p, "pomcheck")
  expect_snapshot_value(p, style="serialize")
})
