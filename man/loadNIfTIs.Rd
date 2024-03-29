% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/loadNiftis.R
\name{loadNIfTIs}
\alias{loadNIfTIs}
\title{Load Nifti files from directory}
\usage{
loadNIfTIs(dir, toMatrix = TRUE)
}
\arguments{
\item{dir}{Input directory containing nifti files}

\item{toMatrix}{logical if TRUE nifti's are converted to matrices}
}
\value{
list object containing Voxel by Time course matrices
}
\description{
Load Nifti files from directory
}
\examples{
\dontrun{
nifs <- loadNIfTIs('<FolderPath>', toMatrix = T)
outnif <- CICA(DataList = nifs, RanStarts = 2, nComp = 10, nClus = 2)
}

}
