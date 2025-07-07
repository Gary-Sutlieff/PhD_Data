# Date: 2020-05-05
# Author: Leo Gorman, with subsequent development by Gary Sutlieff

#' Description: This script parses the cvaa files
#' and extracts the pass information for each point.
#' As an example I calculate the revisit pass time for 
#' each point and plot it on a map.

library(magrittr)
library(tibble)
library(tidyr)
library(dplyr)
library(ggplot2)
library(viridis)

#--------------------------------------------
# Specifying File Path
#--------------------------------------------
# This is the path to the file. Please replace this with the path to your file.
file_path <- "./Accesses700.cvaa"

file_path200 <- "./Accesses200.cvaa"
file_path250 <- "./Accesses250.cvaa"
file_path300 <- "./Accesses300.cvaa"
file_path350 <- "./Accesses350.cvaa"
file_path400 <- "./Accesses400.cvaa"
file_path450 <- "./Accesses450.cvaa"
file_path500 <- "./Accesses500.cvaa"
file_path550 <- "./Accesses550.cvaa"
file_path600 <- "./Accesses600.cvaa"
file_path650 <- "./Accesses650.cvaa"
file_path700 <- "./Accesses700.cvaa"

#--------------------------------------------
# Defining Functions
#--------------------------------------------


radians_to_degrees <- function(radians, offset=F){
    if (offset) {
        radians[radians>pi] <- radians[radians>pi] - 2*pi
       
    }

    return(radians * 180 / pi)
}



#' Get Details for Single Point
#'
#' This function extracts the details for a single point.
#' A list of "point numbers" and a list of "new lines" is used.
#' This 
#' 
#' 
#' @param point_number_index The index of the current point to extract details for
#' Note that index refers to "first point" as it appears in the file, not the actual point number.
#' @param full_file The full file to search through.
#' @param all_points The vector of lines where the "point number" appears
#' @param all_newlines The vector of lines where the "new line" appears
#' @return A nested list containing the details for a single point
#' @export
get_details_for_single_point <- function(point_number_index,full_file, all_points, all_newlines){
    current_point <- all_points[point_number_index]

    
    point_number <- gsub("PointNumber\t\t", "",full_file[current_point]) %>% trimws() %>% as.numeric()
    lat <- gsub("Lat\t\t", "",full_file[current_point + 1]) %>% trimws() %>% as.numeric()
    lat <- radians_to_degrees(lat)
    lon <- gsub("Lon\t\t", "",full_file[current_point + 2]) %>% trimws() %>% as.numeric()
    lon <- radians_to_degrees(lon, offset=T)

    alt <- gsub("Alt\t\t", "",full_file[current_point + 3]) %>% trimws() %>% as.numeric()
    num_accesses <- gsub("NumberOfAccesses\t\t", "",full_file[current_point + 4]) %>% trimws() %>% as.numeric()

    end_of_access_points <- min( all_newlines[all_newlines > current_point] )
    time_accesses <- full_file[(current_point + 5):(end_of_access_points-1)]  %>% strsplit(., "  ")

    time_accesses <- sapply(time_accesses, function(x){
        return(
            list(
                'point_number' = point_number,
                'lat' = lat,
                'lon' = lon,
                'alt' = alt,
                'num_accesses' = num_accesses,
                'start_time' = as.numeric(x[2]),
                'end_time' = as.numeric(x[3])
            )
        )
    }) %>% t()
    return(time_accesses)
}

#' Get Pass Info
#' 
#' This function extracts information for all
#' the points in the cvaa file. 
#' It searches through the file for a "point number". 
#' and extracts all the relevant informaiton for that
#' point, using the "get_details_for_single_point" function.
#' 
#' @param file_path The path to the file
#' @return A tibble containing the pass information
#' @export
get_pass_info <- function(file_path){
    
    # Read the first 10 lines
    full_file <- readLines(file_path)

    all_points <- grep("PointNumber", full_file)
    all_newlines <- which(full_file=="")

    point_tibbles <- lapply(1:length(all_points), function(i){
       get_details_for_single_point(i,full_file, all_points, all_newlines) 
    }) 

    point_tibbles <- do.call(rbind, point_tibbles)

    point_tibbles[1:100,]
    point_tibbles <- as_tibble(point_tibbles, validate = NULL, .name_repair = NULL)
    point_tibbles <- point_tibbles %>% mutate_all(as.numeric)
    return(point_tibbles)
 
}

revisit_time_df <- function(pass_info){
    cols <- c('point_number', 'lat', 'lon', 'alt', 'start_time', 'end_time')
    df_1 <- pass_info[-1,cols]

    df_1$second_start_time <- as.numeric(pass_info$end_time)[-nrow(pass_info)]
    df_1$second_point_number <- pass_info[-nrow(pass_info),'point_number']

    df_1 <- df_1 %>% filter(point_number == second_point_number)

    df_1$revisit_time <- as.numeric(df_1$start_time) - as.numeric(df_1$second_start_time)

    df_1$start_time <- NULL
    df_1$end_time <- NULL
    df_1$second_start_time <- NULL

    return(df_1) 
}

#--------------------------------------------
# Extracting Information
#--------------------------------------------

# File path defined at the top
result <- get_pass_info(file_path)

#--------------------------------------------
# Summarising Information
#--------------------------------------------

revisit_time <- revisit_time_df(result)

revisit_time_distribution <- revisit_time %>% 
    group_by(point_number) %>% 
    summarise(
        revisit_time = mean(revisit_time),
        lat=mean(lat),
        lon=mean(lon)
    )

#--------------------------------------------
# Creating Table of Data for All Altitudes
#--------------------------------------------
result200 <- get_pass_info(file_path200)
result250 <- get_pass_info(file_path250)
result300 <- get_pass_info(file_path300)
result350 <- get_pass_info(file_path350)
result400 <- get_pass_info(file_path400)
result450 <- get_pass_info(file_path450)
result500 <- get_pass_info(file_path500)
result550 <- get_pass_info(file_path550)
result600 <- get_pass_info(file_path600)
result650 <- get_pass_info(file_path650)
result700 <- get_pass_info(file_path700)

revisit_time200 <- revisit_time_df(result200)
revisit200_filter_0 <- revisit_time200 %>% filter(lat > -0.5, lat < 0)
revisit200_filter_30 <- revisit_time200 %>% filter(lat > 29.5, lat < 30.5)
revisit200_filter_n30 <- revisit_time200 %>% filter(lat < -29.5, lat > -30.5)
revisit200_filter_60 <- revisit_time200 %>% filter(lat > 59.5, lat < 60)
revisit200_filter_n55 <- revisit_time200 %>% filter(lat > -55, lat < -54.5)
revisit200_filter <- bind_rows(revisit200_filter_0, revisit200_filter_30, revisit200_filter_n30, revisit200_filter_60, revisit200_filter_n55)

revisit_time250 <- revisit_time_df(result250)
revisit250_filter_0 <- revisit_time250 %>% filter(lat > -0.5, lat < 0)
revisit250_filter_30 <- revisit_time250 %>% filter(lat > 29.5, lat < 30.5)
revisit250_filter_n30 <- revisit_time250 %>% filter(lat < -29.5, lat > -30.5)
revisit250_filter_60 <- revisit_time250 %>% filter(lat > 59.5, lat < 60)
revisit250_filter_n55 <- revisit_time250 %>% filter(lat > -55, lat < -54.5)
revisit250_filter <- bind_rows(revisit250_filter_0, revisit250_filter_30, revisit250_filter_n30, revisit250_filter_60, revisit250_filter_n55)

revisit_time300 <- revisit_time_df(result300)
revisit300_filter_0 <- revisit_time300 %>% filter(lat > -0.5, lat < 0)
revisit300_filter_30 <- revisit_time300 %>% filter(lat > 29.5, lat < 30.5)
revisit300_filter_n30 <- revisit_time300 %>% filter(lat < -29.5, lat > -30.5)
revisit300_filter_60 <- revisit_time300 %>% filter(lat > 59.5, lat < 60)
revisit300_filter_n55 <- revisit_time300 %>% filter(lat > -55, lat < -54.5)
revisit300_filter <- bind_rows(revisit300_filter_0, revisit300_filter_30, revisit300_filter_n30, revisit300_filter_60, revisit300_filter_n55)

revisit_time350 <- revisit_time_df(result350)
revisit350_filter_0 <- revisit_time350 %>% filter(lat > -0.5, lat < 0)
revisit350_filter_30 <- revisit_time350 %>% filter(lat > 29.5, lat < 30.5)
revisit350_filter_n30 <- revisit_time350 %>% filter(lat < -29.5, lat > -30.5)
revisit350_filter_60 <- revisit_time350 %>% filter(lat > 59.5, lat < 60)
revisit350_filter_n55 <- revisit_time350 %>% filter(lat > -55, lat < -54.5)
revisit350_filter <- bind_rows(revisit350_filter_0, revisit350_filter_30, revisit350_filter_n30, revisit350_filter_60, revisit350_filter_n55)

revisit_time400 <- revisit_time_df(result400)
revisit400_filter_0 <- revisit_time400 %>% filter(lat > -0.5, lat < 0)
revisit400_filter_30 <- revisit_time400 %>% filter(lat > 29.5, lat < 30.5)
revisit400_filter_n30 <- revisit_time400 %>% filter(lat < -29.5, lat > -30.5)
revisit400_filter_60 <- revisit_time400 %>% filter(lat > 59.5, lat < 60)
revisit400_filter_n55 <- revisit_time400 %>% filter(lat > -55, lat < -54.5)
revisit400_filter <- bind_rows(revisit400_filter_0, revisit400_filter_30, revisit400_filter_n30, revisit400_filter_60, revisit400_filter_n55)

revisit_time450 <- revisit_time_df(result450)
revisit450_filter_0 <- revisit_time450 %>% filter(lat > -0.5, lat < 0)
revisit450_filter_30 <- revisit_time450 %>% filter(lat > 29.5, lat < 30.5)
revisit450_filter_n30 <- revisit_time450 %>% filter(lat < -29.5, lat > -30.5)
revisit450_filter_60 <- revisit_time450 %>% filter(lat > 59.5, lat < 60)
revisit450_filter_n55 <- revisit_time450 %>% filter(lat > -55, lat < -54.5)
revisit450_filter <- bind_rows(revisit450_filter_0, revisit450_filter_30, revisit450_filter_n30, revisit450_filter_60, revisit450_filter_n55)

revisit_time500 <- revisit_time_df(result500)
revisit500_filter_0 <- revisit_time500 %>% filter(lat > -0.5, lat < 0)
revisit500_filter_30 <- revisit_time500 %>% filter(lat > 29.5, lat < 30.5)
revisit500_filter_n30 <- revisit_time500 %>% filter(lat < -29.5, lat > -30.5)
revisit500_filter_60 <- revisit_time500 %>% filter(lat > 59.5, lat < 60)
revisit500_filter_n55 <- revisit_time500 %>% filter(lat > -55, lat < -54.5)
revisit500_filter <- bind_rows(revisit500_filter_0, revisit500_filter_30, revisit500_filter_n30, revisit500_filter_60, revisit500_filter_n55)

revisit_time550 <- revisit_time_df(result550)
revisit550_filter_0 <- revisit_time550 %>% filter(lat > -0.5, lat < 0)
revisit550_filter_30 <- revisit_time550 %>% filter(lat > 29.5, lat < 30.5)
revisit550_filter_n30 <- revisit_time550 %>% filter(lat < -29.5, lat > -30.5)
revisit550_filter_60 <- revisit_time550 %>% filter(lat > 59.5, lat < 60)
revisit550_filter_n55 <- revisit_time550 %>% filter(lat > -55, lat < -54.5)
revisit550_filter <- bind_rows(revisit550_filter_0, revisit550_filter_30, revisit550_filter_n30, revisit550_filter_60, revisit550_filter_n55)

revisit_time600 <- revisit_time_df(result600)
revisit600_filter_0 <- revisit_time600 %>% filter(lat > -0.5, lat < 0)
revisit600_filter_30 <- revisit_time600 %>% filter(lat > 29.5, lat < 30.5)
revisit600_filter_n30 <- revisit_time600 %>% filter(lat < -29.5, lat > -30.5)
revisit600_filter_60 <- revisit_time600 %>% filter(lat > 59.5, lat < 60)
revisit600_filter_n55 <- revisit_time600 %>% filter(lat > -55, lat < -54.5)
revisit600_filter <- bind_rows(revisit600_filter_0, revisit600_filter_30, revisit600_filter_n30, revisit600_filter_60, revisit600_filter_n55)

revisit_time650 <- revisit_time_df(result650)
revisit650_filter_0 <- revisit_time650 %>% filter(lat > -0.5, lat < 0)
revisit650_filter_30 <- revisit_time650 %>% filter(lat > 29.5, lat < 30.5)
revisit650_filter_n30 <- revisit_time650 %>% filter(lat < -29.5, lat > -30.5)
revisit650_filter_60 <- revisit_time650 %>% filter(lat > 59.5, lat < 60)
revisit650_filter_n55 <- revisit_time650 %>% filter(lat > -55, lat < -54.5)
revisit650_filter <- bind_rows(revisit650_filter_0, revisit650_filter_30, revisit650_filter_n30, revisit650_filter_60, revisit650_filter_n55)

revisit_time700 <- revisit_time_df(result700)
revisit700_filter_0 <- revisit_time700 %>% filter(lat > -0.5, lat < 0)
revisit700_filter_30 <- revisit_time700 %>% filter(lat > 29.5, lat < 30.5)
revisit700_filter_n30 <- revisit_time700 %>% filter(lat < -29.5, lat > -30.5)
revisit700_filter_60 <- revisit_time700 %>% filter(lat > 59.5, lat < 60)
revisit700_filter_n55 <- revisit_time700 %>% filter(lat > -55, lat < -54.5)
revisit700_filter <- bind_rows(revisit700_filter_0, revisit700_filter_30, revisit700_filter_n30, revisit700_filter_60, revisit700_filter_n55)


#--------------------------------------------
# Plotting
#--------------------------------------------


#plot <- ggplot() + 
#  geom_point(
#    data = revisit_time_distribution, 
#    aes(x = lon, y = lat, color = revisit_time), size = 1,
#    stroke=NA) +
#  scale_color_gradient(high = "red", low = "royalblue1", limits = c(20000, 5e+05),
#                       name = "Revisit Time (Seconds)") + xlab("Longitude (Degrees)") + ylab("Latitude (Degrees)") +ggtitle("Revisit Time for Each Sample Point at 700 km - Fixed Scale")

#ggsave("results/revisit_time_700.png", plot)

#plot2 <- ggplot() + 
#  geom_point(
#    data = revisit_time_distribution, 
#    aes(x = lon, y = lat, color = revisit_time), size = 1,
#    stroke=NA) +
#  scale_color_viridis(name = "Revisit Time (Seconds)") + xlab("Longitude (Degrees)") + ylab("Latitude (Degrees)") + ggtitle("Revisit Time for Each Sample Point at 700 km - Separate Scale")

#ggsave("results/revisit_time_700_alt.png", plot2)
