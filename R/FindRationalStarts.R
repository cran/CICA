#'@description
#'Two step clustering for finding rational start partitions
#'
#'
#' @param DataList a list of matrices
#' @param RatStarts type of rational start. 'all' computes all types of hclust methods
#' @param nComp number of ICA components to extract
#' @param nClus number of clusters
#' @param scalevalue scale each matrix to have an equal sum of squares
#' @param center mean center matrices
#' @param pseudo percentage value for perturbating rational starts to obtain pseudo rational starts
#' @param pseudoFac how many pseudo starts per rational start
#' @param verbose print output to console
#'
#' @return dataframe with (pseudo-) rational and dist object based on the pairwise modified RV values
#'
#'
#' @examples
#' \dontrun{
#' CICA_data <- Sim_CICA(Nr = 15, Q = 5, R = 4, voxels = 100, timepoints = 10,
#' E = 0.4, overlap = .25, externalscore = TRUE)
#' rats <- FindRationalStarts(DataList = CICA_data$X, nComp = 5, nClus = 4,verbose = TRUE, pseudo = .2)
#' plot(rats, type = 1, method = 'ward.D2')
#' plot(rats, type = 2, method = 'ward.D2')
#' plot(rats, type = 2, method = 'ward.D2', mdsdim = 3)
#' }
#'
#'
#' @export
#' @references Durieux, J., & Wilderjans, T. F. (2019). Partitioning subjects based on high-dimensional fMRI data: comparison of several clustering methods and studying the influence of ICA data reduction in big data. Behaviormetrika, 46(2), 271-311.
#'
FindRationalStarts <- function(DataList, RatStarts = 'all', nComp, nClus, scalevalue = NULL,
                               center = TRUE, verbose = TRUE, pseudo = NULL, pseudoFac=NULL){


  METHODS <- c("ward.D", "single", "complete", "average", "mcquitty",
               "median", "centroid", "ward.D2", 'all')
  i.meth <- pmatch(RatStarts, METHODS)
  if(any(is.na(i.meth))){
    stop('Invalid RatStart argument')
  }


  ICAs <- CICA(DataList = DataList, RanStarts = 1, nComp = nComp,
               nClus = length(DataList), scalevalue = scalevalue, center = center, verbose = F)
  d <- computeRVmat(DataList = ICAs$Sr, dist = TRUE, verbose = verbose)

  if(any(i.meth == 9)){
    hcl0 <- hclust(d = d, method = 'ward.D')
    hcl1 <- hclust(d = d, method = 'ward.D2')
    hcl2 <- hclust(d = d, method = 'complete')
    hcl3 <- hclust(d = d, method = 'single')
    hcl4 <- hclust(d = d, method = 'average')
    hcl5 <- hclust(d = d, method = 'mcquitty')
    hcl6 <- hclust(d = d, method = 'median')
    hcl7 <- hclust(d = d, method = 'centroid')

    p_ward <- cutree(hcl0, k = nClus)
    p_ward2 <- cutree(hcl1, k = nClus)
    p_comp <- cutree(hcl2, k = nClus)
    p_single <- cutree(hcl3, k = nClus)
    p_average <- cutree(hcl4, k = nClus)
    p_mcquitty <- cutree(hcl5, k = nClus)
    p_median <- cutree(hcl6, k = nClus)
    p_centroid <- cutree(hcl7, k = nClus)

    ps <- data.frame(p_ward, p_ward2, p_comp, p_single, p_average, p_mcquitty,
                     p_median, p_centroid)
  }else{
    ps <- matrix(data = NA, nrow = length(DataList), ncol = length(i.meth))
    for(i in 1:length(i.meth)){
      hcl <- hclust(d = d, method = METHODS[i.meth[i]])
      ps[,i] <- cutree(hcl, k = nClus)

    }
    ps <- data.frame(ps)
    colnames(ps) <- METHODS[i.meth]
  }


  if(!is.null(pseudo)){

    if(all(pseudo >= 0 & pseudo <=1) == FALSE){
      stop('pseudo should be a value between 0 and 1')
    }

    if(pseudoFac < 1){
      stop('pseudoFac should be an integer larger or equal than 1')
    }


    #### add loop here to go over pseudo if it is a vector, see issue #4 github
    Ppseudo_i <- list()
    for(i in 1:pseudoFac){
      Ppseudo_j <- list()
      for(j in 1:length(pseudo)){
        perbs <- matrix(data = NA, nrow = nrow(ps), ncol = ncol(ps))
        for(k in 1:ncol(ps)){
          perbs[,k] <- perturbation(ps[ ,k], percentage = pseudo[j])
        }
        colnames(perbs) <- paste(names(ps),'Pseudo',
                                 rep(pseudo[j], times = ncol(ps)), 'Fac',i, sep = '')
        Ppseudo_j[[j]] <- data.frame(perbs)
      }
      Ppseudo_i[[i]] <- data.frame(Ppseudo_j)

    }
    Ppseudo <- data.frame(Ppseudo_i)
    ps <- cbind(ps, Ppseudo)
  }

  # check if no empty clusters are present
  temp <- ps
  for(i in 1:ncol(temp)){
    temp[,i] <- SearchEmptyClusters(nClus, newcluster = ps[, i])
  }
  ps <- temp


  out <- list()
  out$rationalstarts <- ps
  out$RVdist <- d

  class(out) <- 'rstarts'

  return(out)

}
