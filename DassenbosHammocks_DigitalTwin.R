#### Digital Twin application

#08-06-2021
#Group 5
#Main R script for the analysis

#check if packages are installed
if(!"raster" %in% rownames(installed.packages())){install.packages("raster")}
if(!"sp" %in% rownames(installed.packages())){install.packages("sp")}
if(!"colorRamps" %in% rownames(installed.packages())){install.packages("colorRamps")}
if(!"lidR" %in% rownames(installed.packages())){install.packages("lidR")}
if(!"rgl" %in% rownames(installed.packages())){install.packages("rgl")}

### load need packages
library(lidR)
library(raster)
library(colorRamps)
library(sp)
library(rgl)

#set the working directory
setwd("~/WUR master/RGIC_periode6/DigitalTwin") #This should be adjusted to right local folder for reproducibility

## set the name of the file to be loaded
flight1 <-"2021_dassenbos_TLS/Dassenbos2021_smallsliceforsegmentation.las" #Adjust filename for different las files

#read a LASfile into R
las <- readLAS(flight1) ## open the .las file, which will be named "las"

#Set coordinate system according to the metadata
epsg(las) = 28992  ## set RD coordinate system

#check the extent of the las in Rijksdriehoek coordinate system
extent(las)

plot(las) ## a 3D viewer will be opened with the point cloud displayed
rgl.close() ## to close the viewer again. Do so regularly to prevent memory issues. 

#suitability of understory for hammocks
# create clip cirkle at hammock locations with radius of 3.5 (and 4.5 for hammock 4)
hammock1 <- clip_circle(las, 173390.32,443799.279, 3.5)
hammock2 <- clip_circle(las, 173388.47,443802.17, 3.5)
hammock3 <- clip_circle(las, 173387.72,443801.72, 3.5)
hammock4 <- clip_circle(las, 173392.97,443809.99, 4.5)

#plot the different hammocks
plot(hammock1)
plot(hammock2)
plot(hammock3)
plot(hammock4)

#calculate gap fraction at different heights 
gapFraction_hammock1 <- (gap_fraction_profile(hammock1@data$Z))
gapFraction_hammock1$z <- gapFraction_hammock1$z - min(hammock1$Z)
plot(gapFraction_hammock1$z ~ gapFraction_hammock1$gf, type = 'l', xlim=c(0.5,1), ylim=c(0,5), main="Gap Profile Hammock 1", xlab="Gap Fraction", ylab="Height [m]")

gapFraction_hammock2 <- (gap_fraction_profile(hammock2@data$Z))
gapFraction_hammock2$z <- gapFraction_hammock2$z - min(hammock2$Z)
plot(gapFraction_hammock2$z ~ gapFraction_hammock2$gf, type = 'l', xlim=c(0.5,1), ylim=c(0,5), main="Gap Profile Hammock 2", xlab="Gap Fraction", ylab="Height [m]")
 
gapFraction_hammock3 <- (gap_fraction_profile(hammock3@data$Z))
gapFraction_hammock3$z <- gapFraction_hammock3$z - min(hammock3$Z)
plot(gapFraction_hammock3$z ~ gapFraction_hammock3$gf, type = 'l', xlim=c(0.5,1), ylim=c(0,5), main="Gap Profile Hammock 3", xlab="Gap Fraction", ylab="Height [m]")

gapFraction_hammock4 <- (gap_fraction_profile(hammock4@data$Z))
gapFraction_hammock4$z <- gapFraction_hammock4$z - min(hammock4$Z)
plot(gapFraction_hammock4$z ~ gapFraction_hammock4$gf, type = 'l', xlim=c(0.5,1), ylim=c(0,5), main="Gap Profile Hammock 3", xlab="Gap Fraction", ylab="Height [m]")

## Create one plot that shows the gap fraction for the four locations
plot(gapFraction_hammock1$z ~ gapFraction_hammock1$gf, type = 'l', xlim=c(0.5,1), ylim=c(0,5), main="Understory vegetation hammock locations", xlab="Gap Fraction", ylab="Height [m]")
points(gapFraction_hammock2$z ~ gapFraction_hammock2$gf, type = 'l', col=2, lty=2)
points(gapFraction_hammock3$z ~ gapFraction_hammock3$gf, type = 'l', col=3, lty=3)
points(gapFraction_hammock4$z ~ gapFraction_hammock4$gf, type = 'l', col=4, lty=4)
legend(x='topleft', legend=c("Tree 1-4", "Tree 1-3", "Tree 1-2","Tree 3-7"), col=c(1:4), lty=1:4, bty="n")

###################################################################
# PERFORM TREE SEGMENTATION
#segment the trees from the dassenbos pointcloud 
trees <- segment_trees(las, li2012(R=5, speed_up=10, hmin=5)) #R default is 2, speed_up try 5 to speed up the compuations

#plot the trees with ID as color
plot(trees, color="treeID") ## visualise the tree segmentation

#Select max tree ID to count the number of identified trees 
(max(trees@data$treeID, na.rm=TRUE))  ## give the maximum treeID
#14 trees were identified for the test area

#write the segmented trees pointcloud to storage
outname <- "2018_dassenbos_phenology/Digital_Twin_Tile_TreesSegmented.laz"
writeLAS(trees, outname)

#set filenames for the cylinder files
Tree14 <- "Dassenbos_cylinders/tree14.laz"
Tree13 <- "Dassenbos_cylinders/tree13.laz"
Tree12 <- "Dassenbos_cylinders/tree12.laz"
Tree37 <- "Dassenbos_cylinders/tree37.laz"

#write the four point clouds to local folder for further analysis
writeLAS(hammock1, Tree14)
writeLAS(hammock2, Tree13)
writeLAS(hammock3, Tree12)
writeLAS(hammock4, Tree37)
