# Author: Arias, Francisco ; Araza, Arnan
# 13 January 2017
# Pre-processing chain to assess change in NDVI over time

#Cleaning the workspace

rm(list= ls())

# Importing lybraries 
library(sp)
library(raster)
library(rgdal)


download.file("https://www.dropbox.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz?dl=0", "data/landsat5.tar.gz")
download.file("https://www.dropbox.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz?dl=0", "data/landsat8.tar.gz")

# unziping files
untar('data/landsat5.tar.gz', exdir = "data/")
untar('data/landsat8.tar.gz', exdir = "data/")

# creating stacks for Landsat data
list_ls <- list.files('data/', pattern = '*.tif', full.names = TRUE)
list_ls
lands5 <- stack(list_ls[10:24])
lands8 <- stack(list_ls[1:9])

# Reproject Landsat 5 using the parameters of landsat 8. To make sure that both has same projecions 
projectRaster(lands5,lands8)

# Here we are ensuring that both datasets have the same extent
lands5_ext <- crop(lands5, lands8)
lands8_ext <- crop(lands8, lands5)

# to extract cloud mask rasterLayer from Landsat5 and Landsat 8 
fmask5 <- lands5_ext[[1]]
fmask8 <- lands8_ext[[1]]

# Remove cloud mask (fmask) layer from the Landsat stack
lands5_NoCloud <- dropLayer(lands5_ext, 1)
lands8_NoCloud <- dropLayer(lands8_ext, 1)

## Replace 'clear land' with 'NA'
fmask5[clmask5 == 0] <- NA
fmask8[clmask8 == 0] <- NA

source("R/cloud2NA.R") # Source de function saved in R folder of the project

## Apply the function on the two raster objects using overlay

lands5_CloudFree <- overlay(x = lands5_NoCloud, y = fmask5, fun = cloud2NA)
lands8_CloudFree <- overlay(x = lands8_NoCloud, y = fmask8, fun = cloud2NA)

names (lands5_CloudFree) = names (lands5_NoCloud) # To recover the original names 
names (lands8_CloudFree) = names (lands8_NoCloud) # To recover the original names


# NDVI calculations
source("R/ndviCalc.R")

ndvilands5 <- overlay(x= lands5_CloudFree[[6]], y=lands5_CloudFree[[5]], fun=ndviCalc)
plot(ndvilands5)
ndvilands8 <- overlay(x=lands8_CloudFree[[7]], y=lands8_CloudFree[[6]], fun=ndviCalc)
plot(ndvilands8)

# NDVI change over 30 years
NDVI_dif <- ndvilands8 - ndvilands5
plot(NDVI_dif)
# Convert the image to a KML format. To use it on Google Earth
NDVI_dif_to_KML <- projectRaster(NDVI_dif, crs='+proj=longlat')
KML(x=NDVI_dif_to_KML, filename='NDVI_dif.kml')










