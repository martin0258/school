# Perform k-means algorithm on a data matrix.
#
# Args:
#   - x: numeric matrix of data
#   - k: number of clusters
#   - itreration: number of iterations to run
#   - initial_centers: initial centers (randomly choose k points from x if empty)
kmeans <- function (x, k, iteration, initial_centers) {
  # Precondition:
  #  - k must be a positive integer
  #  - k <= number of points
  num_points <- nrow(x)
  if (all.equal(k, as.integer(k)) == FALSE ||
      k <= 0 ||
      k > num_points) {
    stop("k must be an integer that lies between 1 and nrow(x).")
  }
  
  # Decide initial cluster centers
  if (length(initial_centers) > 0) {
    centers <- initial_centers
  } else {
    # Randomly choose k points to be the initial cluster centers
    center_idx <- sample(num_points)[1:k]
    centers <- x[center_idx, ]
  }
  
  cluster_assignments <- rep(0, num_points)
  converge_itr <- NA
  
  for (itr in 1:iteration) {
    # Save cluster assignments for checking stopping criterion
    pre_cluster_assignments <- cluster_assignments

    # Compute distances between each point and cluster centers
    distances <- matrix(ncol=k, nrow=num_points)
    for (center_idx in 1:k) {
      square_distance <- (x - centers[center_idx, ]) ^ 2
      distances[, center_idx] <- sqrt(rowSums(square_distance))
    }
    # Assign each point to the nearest cluster
    for (point_idx in 1:num_points) {
      cluster_assignments[point_idx] <- which.min(distances[point_idx, ])
    }
    # Update cluster centers
    for (center_idx in 1:k) {
      points_belong_to_cluster <- which(cluster_assignments==center_idx)
      if (length(points_belong_to_cluster) > 0) {
        centers[center_idx, ] <- colMeans(x[points_belong_to_cluster, ])
      }
    }
    # Check stopping criterion:
    #  - the cluster each point belongs to is unchanged
    #  - cluster centers are stable
    if (all.equal(pre_cluster_assignments, cluster_assignments)==TRUE) {
      converge_itr <- itr
      cat(sprintf("K-Means converged at iteration %d.\n", itr))
      break
    }
  }
  return(list(cluster=cluster_assignments,
              centers=centers,
              iter=converge_itr))
}

kmeans_test <- function () {
  # Randomly generate 100 points on 2-D plane
  num_points <- 100
  dim <- 2
  x <- matrix(rnorm(num_points * dim), ncol=dim)
  colnames(x) <- c("x", "y")
  
  # k-means algorithm settings
  num_clusters <- 2
  num_itr <- 30

  # Perform k-means algorithm using R built-in implementation
  result1 <- stats::kmeans(x, x[1:num_clusters, ], num_itr)
  # Perform k-means algorithm using our own implementation
  result2 <- kmeans(x, num_clusters, num_itr, x[1:num_clusters, ])
  
  # Plot clustering result
  par(mfrow=c(1, 2)) # 2 figures arrange in 1 row 2 columns
  plot(x, col=result1$cluster, main="K-Means Result (built-in)")
  points(result1$centers, col=1:num_clusters, pch=8, cex=2)
  plot(x, col=result2$cluster, main="K-Means Result (ours)")
  points(result2$centers, col=1:num_clusters, pch=8, cex=2)
}

kmeans_2.1 <- function () {
  # k-means algorithm settings
  num_clusters <- 2
  num_itr <- 30
  
  par(mfrow=c(2, 3)) # 6 figures arrange in 3 row 2 columns
  for (itr in 1:6) {
    # Randomly generate 100 points on 2-D plane
    num_points <- 100
    dim <- 2
    x <- matrix(rnorm(num_points * dim), ncol=dim)
    colnames(x) <- c("x", "y")
  
    result <- kmeans(x, num_clusters, num_itr, x[1:num_clusters, ])
    plot(x, col=result$cluster, main="K-Means Result")
    points(result$centers, col=1:num_clusters, pch=8, cex=2)
  }
}

# Run
kmeans_test()
kmeans_2.1()