#' National Health and Nutrition Examination Survey 2011-2012
#'
#' A dataset used in the UCLA Statistical Consulting Survey Analysis in R guide
#'  \url{https://stats.idre.ucla.edu/r/seminars/survey-data-analysis-with-r/}
#'
#' @format A data frame with 9756 rows and 16 variables:
#' \describe{
#'   \item{seqn}{Respondent sequence number}
#'   \item{ridageyr}{Age in years at screening}
#'   \item{riagendr}{Gender}
#'   \item{dmdmartl}{Marital status}
#'   \item{dmdeduc2}{Education level - Adults 20+}
#'   \item{sdmvpsu}{Masked variance pseudo-PSU}
#'   \item{sdmvstra}{Masked variance pseudo-stratum}
#'   \item{wtint2yr}{Full sample 2 year interview weight}
#'   \item{female}{Gender}
#'   \item{hsq496}{How many days feel anxious}
#'   \item{hsq571}{SP donated blood in the past 12 months}
#'   \item{hsd010}{General health condition}
#'   \item{pad630}{Minutes moderate-intensity work}
#'   \item{pad675}{Minutes moderate recreational activities}
#'   \item{paq665}{Moderate recreational activities}
#'   \item{pad680}{Minutes sedentary activity}
#' }
#' @source \url{https://wwwn.cdc.gov/nchs/nhanes/Search/DataPage.aspx?Component=Demographics&CycleBeginYear=2011}
"nhanes"

#' Simulated data for ordinal logistic regression example.
#'
#' A dataset used in the UCLA Statistical Consulting Ordinal Logistic Regression Example
#' \url{https://stats.idre.ucla.edu/r/dae/ordinal-logistic-regression/}
#'
#' @format A data frame with 400 rows and 4 variables:
#' \describe{
#'   \item{apply}{Likelihood of applying to graduate school}
#'   \item{pared}{Indicator for whether at least 1 parent has a graduate degree}
#'   \item{public}{Indicator for whether undergraduate institution is public or private}
#'   \item{gpa}{Student's grade point average}
#' }
#' @source \url{https://stats.idre.ucla.edu/stat/data/ologit.dta}
"ologit"
