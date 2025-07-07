library(tidyverse)
library(tibble)
library(fs)
library(ggplot2)
library(dplyr)
library(ggpubr)
library(ggbreak)


# Read in data with Agents present
data_file_path1 <- path_real("./1/GB_B100_1_Y-90000.asc")
stopifnot(file_exists(data_file_path1))
values1 <- scan(data_file_path1, what=double(), skip=4)
values1

data_file_path2 <- path_real("./15/GB_B100_15_Y-90000.asc")
stopifnot(file_exists(data_file_path2))
values2 <- scan(data_file_path2, what=double(), skip=4)
values2

data_file_path3 <- path_real("./30/GB_B100_30_Y-90000.asc")
stopifnot(file_exists(data_file_path3))
values3 <- scan(data_file_path3, what=double(), skip=4)
values3

data_file_path4 <- path_real("./45/GB_B100_45_Y-90000.asc")
stopifnot(file_exists(data_file_path4))
values4 <- scan(data_file_path4, what=double(), skip=4)
values4

data_file_path5 <- path_real("./60/GB_B100_60_Y-90000.asc")
stopifnot(file_exists(data_file_path5))
values5 <- scan(data_file_path5, what=double(), skip=4)
values5


# Generate Wavenumber Column for Tibble
wavenumbers <- seq(645, 1500, 0.25)
wavenumbers
stopifnot(length(values1) == length(wavenumbers))

# Create Tibble of data
imported_data <- tibble("Wavenumber"=seq(645, 1500, 0.25),
                        "Radiance_1"=scan(data_file_path1, what=double(), skip=4),
                        "Radiance_2"=scan(data_file_path2, what=double(), skip=4),
                        "Radiance_3"=scan(data_file_path3, what=double(), skip=4),
                        "Radiance_4"=scan(data_file_path4, what=double(), skip=4),
                        "Radiance_5"=scan(data_file_path5, what=double(), skip=4))
imported_data

# Read in data without Agent
data_file_path_N <- path_real("./NO_AGENT_Y-90000.asc")
stopifnot(file_exists(data_file_path_N))

values_N <- scan(data_file_path_N, what=double(), skip=4)
values_N

# Create Tibble of data
imported_data2 <- tibble("Wavenumber"=seq(645, 1500, 0.25),
                         "Radiance_N"=scan(data_file_path_N, what=double(), skip=4))
imported_data2

#Unify Tibbles
imported_data["RadianceNoAgent"] <- imported_data2$Radiance_N

# Subtract each agent data set from the set with no agent
imported_data["One"] <- imported_data$RadianceNoAgent - imported_data$Radiance_1
imported_data["Fifteen"] <- imported_data$RadianceNoAgent - imported_data$Radiance_2
imported_data["Thirty"] <- imported_data$RadianceNoAgent - imported_data$Radiance_3
imported_data["FourtyFive"] <- imported_data$RadianceNoAgent - imported_data$Radiance_4
imported_data["Sixty"] <- imported_data$RadianceNoAgent - imported_data$Radiance_5

# Create amplified Difference column to better show differences if necessary
#a = 1
#imported_data["DiffAmp"] <- imported_data$Difference * a

# Add a column for wavelength rather than wavenumber
imported_data["Wavelength"] <- 10000/(imported_data$Wavenumber)
#Add a column for wavelength in nanometers specifically
imported_data["Wavelength/nm"] <- 1000*(imported_data$Wavelength)
#export csv of wavenumber and radiance data for LVF model if necessary
write.csv(imported_data, file="LVF_Data.csv")

#Import IASI Noise Data - Data is digitised from a graph and needs unit conversion, see below
IASI_Noise <- read.table("IASI_Noise.txt", header=FALSE, sep=",")
#Add Column for unit conversion - Multiply by 100,000, then multiply by 1E-4, so multiply by 10
IASI_Noise["Noise"] <- 10*IASI_Noise$V2
IASI_Noise2 <- as.tibble(IASI_Noise)

# Plot Difference against IASI Noise
plot(imported_data$Wavenumber, imported_data$One, type="l", xlim=c(645, 1500), ylim=c(0, 30), main="Difference Between the Two Radiance Datasets", xlab="Wavenumber / cm-1", ylab="Radiance Difference / nW/(cm2 sr cm-1)")
#plot(IASI_Noise$V1, IASI_Noise$V3, type="l", col="blue",  xlim=c(645, 1500), ylim=c(0, 30), xlab = "", ylab="")
lines(as.numeric(IASI_Noise$V1), as.numeric(IASI_Noise$Noise), type="l", col="blue")

# Options for adding bands of interest
#abline(v=c(12.626, 13.089), col="springgreen", lty=2, lwd=2)
#abline(v=c(11.628, 12.048), col="brown", lty=2, lwd=2)
#abline(v=c(10.526, 11.236), col="grey55", lty=2, lwd=2)
#abline(v=c(9.709, 10), col="magenta", lty=2, lwd=2)
#abline(v=c(9.524, 9.606), col="yellow", lty=2, lwd=2)
#abline(v=c(8.403, 9.174), col="darkorchid4", lty=2, lwd=2)


#p1 <- ggplot() +
#  xlim(645, 1500) +
#  scale_y_cut(breaks = 0.003, which = 1, scales = c(0.5, 1)) +
#  geom_line(data = imported_data, aes(x = Wavenumber, y = Difference1), color = "skyblue2") +
#  geom_line(data = imported_data, aes(x = Wavenumber, y = Difference2), color = "springgreen") +
#  geom_line(data = imported_data, aes(x = Wavenumber, y = Difference3), color = "darkorchid4") +
#  geom_line(data = imported_data, aes(x = Wavenumber, y = Difference4), color = "magenta") +
#  geom_line(data = imported_data, aes(x = Wavenumber, y = Difference5), color = "orange") +
#  geom_line(data = IASI_Noise, aes(x = V1, y = V3), color="black") +
#  labs(title = "30 kg sarin release, bulk ground areas", x = "Wavenumber / cm-1", y = "Radiance Difference / nW/(cm2 st cm-1)") +
#  theme(text = element_text(size = 18, colour = "black"),
#        plot.title = element_text(size = 22, colour = "black", hjust = 0.5),
#        axis.title.x = element_text(size = 20, colour ="black"),
#        axis.text = element_text(size = 18, colour = "black"))
#p1


p1a <- ggplot() +
  xlim(645, 1500) +
  scale_y_cut(breaks = 0.015, which = 1, scales = c(0.5, 1)) +
  geom_line(data = imported_data, aes(x = Wavenumber, y = One, colour ="1 Min")) +
  geom_line(data = imported_data, aes(x = Wavenumber, y = Fifteen, colour ="15 Mins")) +
  geom_line(data = imported_data, aes(x = Wavenumber, y = Thirty, colour ="30 Mins")) +
  geom_line(data = imported_data, aes(x = Wavenumber, y = FourtyFive, colour ="45 Mins")) +
  geom_line(data = imported_data, aes(x = Wavenumber, y = Sixty, colour ="60 Mins")) +
  geom_line(data = IASI_Noise, aes(x = V1, y = Noise, colour = "Noise")) +
  scale_color_manual(name = "Sample Time", breaks = c("1 Min", "15 Mins", "30 Mins", "45 Mins", "60 Mins", "Noise"), values = c("1 Min" = "skyblue2", "15 Mins" = "springgreen", "30 Mins" = "darkorchid4", "45 Mins" = "magenta", "60 Mins" = "orange", "Noise" = "black")) +
  labs(title = "100 kg sarin release, bulk ground areas", x = "Wavenumber / cm-1", y = "Radiance Difference / nW/(cm2 sr cm-1)") +
  theme(text = element_text(size = 20, colour = "black"),
        plot.title = element_text(size = 24, colour = "black", hjust = 0.5),
        axis.title.x = element_text(size = 22, colour ="black"),
        axis.text = element_text(size = 20, colour = "black"))
p1a

# Plot the two data sets together
#par(mar = c(5, 4, 4, 4) + 0.3)
#plot(imported_data$Wavenumber, imported_data$Radiance_1, type="l", xlim=c(645, 1500), ylim=c(0, 12000), col="red", lwd=1, xlab="Wavenumber / cm-1", ylab="Radiance / nW/(cm2 st cm-1)", main = "Radiance Return Results")
#par(new=TRUE)
#plot(imported_data$Wavenumber, imported_data$RadianceNoAgent, type="l", xlim=c(645, 1500), ylim=c(0, 12000), col="skyblue2", lwd=1, axes=FALSE, xlab="", ylab="")

#Plot the two data sets and the amplified difference on the same graph to show differences
#par(mar = c(5, 4, 4, 4) + 0.3)
#plot(imported_data$Wavenumber, imported_data$Radiance_1, type="l", xlim=c(645, 1500), ylim=c(0, 12000), col="red", lwd=1, xlab="Wavenumber / cm-1", ylab="Radiance / nW/(cm2 st cm-1)", main = "Radiance Return Results with Differences")
#par(new=TRUE)
#plot(imported_data$Wavenumber, imported_data$RadianceNoAgent, type="l", xlim=c(645, 1500), ylim=c(0, 12000), col="skyblue2", lwd=1, axes=FALSE, xlab="", ylab="")
#par(new=TRUE)
#plot(imported_data$Wavenumber, imported_data$Difference1, type="l", xlim=c(645, 1500), ylim=c(0, 1200), lwd=1, axes=FALSE, xlab="", ylab="")
#axis(side = 4)
#mtext("Radiance Difference", side = 4, line = 3)