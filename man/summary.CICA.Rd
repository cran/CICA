% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.CICA.R
\name{summary.CICA}
\alias{summary.CICA}
\title{Summary method for class CICA}
\usage{
\method{summary}{CICA}(object, ...)
}
\arguments{
\item{object}{Object of the type produced by \code{\link{CICA}}}

\item{...}{Additional arguments}
}
\value{
\code{summary.CICA} returns an overview of the estimated clustering of a \code{\link{CICA}} analysis
\item{PM}{Partitioning matrix}
\item{tab}{tabulation of the clustering}
\item{Loss}{Loss function value of the solution}
}
\description{
Summarize a CICA analysis
}
\examples{
\dontrun{
CICA_data <- Sim_CICA(Nr = 15, Q = 5, R = 4, voxels = 100, timepoints = 10,
E = 0.4, overlap = .25, externalscore = TRUE)

multiple_output = CICA(DataList = CICA_data$X, nComp = 2:6, nClus = 1:5,
userGrid = NULL, RanStarts = 30, RatStarts = NULL, pseudo = c(0.1, 0.2),
pseudoFac = 2, userDef = NULL, scalevalue = 1000, center = TRUE,
maxiter = 100, verbose = TRUE, ctol = .000001)

summary(multiple_output$Q_5_R_4)
}


}
