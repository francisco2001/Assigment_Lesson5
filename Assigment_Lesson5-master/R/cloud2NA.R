# NDVI Calculation function. Using the Overlay method 

cloud2NA <- function(x, y){
  x[y != 0] <- NA
  return(x)
}