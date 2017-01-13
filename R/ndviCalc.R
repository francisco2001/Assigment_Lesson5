#Function that calculates the NDVI

ndviCalc <- function(x, y) {
  ndvi <- (y - x) / (x + y)
  return(ndvi)

}

