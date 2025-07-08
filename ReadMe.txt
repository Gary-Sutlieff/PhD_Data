ReadMe

This respository contains all of the processing scripts and a few of the model configuration files used in the various modelling efforts conducted for my PhD. At the bottom of this ReadMe file is a list of each of the included files and what the purpose of each one is. This list is categorised by which modelling effort or PhD Chapter the file was used for.

Regrettably, the data from my PhD is not available in this repository, since there is about 15 GB of data. However, it has been made available on the University of Bristol's data repository. To gain access, please contact the data steward for my PhD's folders on the university's repository, Professor Lucy Berthoud, by emailing Lucy.Berthoud@bristol.ac.uk

Thank you for reading!

- Gary

List of all of the files in this Repository:

Literature Review Chapter:
1. Satellite Data Survey.xlsx - A spreadsheet describing the revisit time and spatial resolution achieved by different kinds of satellite instruments, along with graphs depicting the relationship for each instrument type.

Dispersion Modelling:
1. atm_profile_from_grid_conc_exp_final.Rmd - A R Markdown notebook for taking the atmospheric concentration data output by the Urban Dispersion Model and turning it into vertical profiles of atmospheric concentration that are compatible with the Reference Forward Model, a radiative transfer model.
2. atm_profiles_plotter.Rmd - A R markdown notebook designed to plot each of the produced atmospheric concentration profiles for a given dispersion scenario against one another for comparison.

Radiative Transfer Modelling:
1. rfm_rad.drv - A driver table for the Reference Forward Model (RFM), a radiative transfer model. This one configures the RFM to produce measurements of the top of atmosphere radiance observed by the satellite. Please note that it needs to be renamed to "rfm.drv" to function, and that various options will need to be reconfigured to match specific model scenarios.
2. rfm_bbt.drv - A driver table for the Reference Forward Model (RFM), a radiative transfer model. This one configures the RFM to produce measurements of the top of atmosphere brightness temperature observed by the satellite. Please note that it needs to be renamed to "rfm.drv" to function, and that various options will need to be reconfigured to match specific model scenarios.
3. rfm_jac.drv - A driver table for the Reference Forward Model (RFM), a radiative transfer model. This one configures the RFM to produce measurements of the top of the "Jacobian Difference Spectra" observed by the satellite. These values are equal to the change in the observed top of atmosphere radiance for each sampling wavelength caused by a 1% perturbation in the chemical agent's atmospheric concentration at each of several specified tangent altitudes. The Jacobian Difference Spectra can then be further processed into the Jacobians or Weighting Functions themselves. Please note that it needs to be renamed to "rfm.drv" to function, and that various options will need to be reconfigured to match specific model scenarios.
4. IASI_Noise.txt - A text file detailing the radiometric noise curve of the IASI instrument for plotting purposes.
5. rfm0.tan - A file specifying tangent heights for the calculations of the Jacobian Difference Spectra. For use with rfm_jac.drv, as described above.
6. rfm1.tan - A file specifying tangent heights for the calculations of the Jacobian Difference Spectra. For use with rfm_jac.drv, as described above.
7. atm_height_grid_structure.Rmd - A R markdown notebook used to compare the atmospheric structure considered in the RFM configuration for this research with that which was considered in previous research.
8. RFM_PROCESSOR_FINAL.R - A R script for processing the radiance data output by the RFM (when using rfm_rad.drv as described above) into plots depicting the difference (due to absorption by a chemical agent) that would be observed by the IASI instrument for each of the modelled dispersion scenarios.
9. RFM_PROCESSOR_FINAL_gb600_BBT.R - A similar R script to the above, but for reading the brightness temperature data output by the RFM (when using the rfm_bbt.drv as described above), and for a specific scenario to compare the results of this research to those of previous research.
10. sensitivity_final_gb.Rmd - A R markdown notebook that processes the jacobian difference spectra output by the RFM (when using rfm_jac.drv, as described above) into the weighting functions (or Jacobians proper) for the IASI instrument, and produces plots of these weighting functions for each of the modelled sarin dispersion scenarios.
11. sensitivity_final_sm.Rmf - As above, but with sulphur mustard as the released chemical agent, rather than sarin.
12. RFM_PROCESSOR_FINAL_LVF.R - A similar R script to "RFM_PROCESSOR_FINAL.R" but this calculates the observed top of atmosphere radiance without applying the lineshape or spectral response function of any instrument. This script can be used to plot the difference in the observed raw top of atmosphere radiance, but it also outputs this data for further processing, done separately in the LVF Filter-Detector Model (which can be found on the university's data repository, not here) and Filtered_Radiance.Rmd, to calculate the difference observed by the LVF spectrometer.
13. sensitivity_final_gb_noILS.Rmd - A R markdown notebook that processes the jacobian difference spectra output by the RFM (when using rfm_jac.drv, as described above) into the weighting functions (or Jacobians proper) without considering any instrument lineshape, and produces plots of these weighting functions for each of the modelled sarin dispersion scenarios. It also outputs the data for further processing, done separately in the LVF Filter-Detector Model (which can be found on the university's data repository, not here) and Filtered_JAC_v2.Rmd, to calculate the weighting functions for the LVF spectrometer.
14. sensitivity_final_sm_noILS.Rmd - As above, but for the scenarios with sulphur mustard as the released chemical agent, rather than sarin.
15. LVF_Output_Final.Rmd - A R markdown notebook that processes the post-filter flux and SNR outputs from the LVF Filter-Detector Model and produces plots of that data.
16. Filtered_Radiance.Rmd - A R markdown notebook that processes the post-filter flux output from the LVF Filter-Detector Model and back-calculates the post-filter radiance, essentially applying the LVF spectrometer's response function to the radiance measurements output by the RFM.
17. Filtered_JAC_v2.Rmd - A R markdown notebook that processes the post-filter flux difference spectrum output from the LVF Filter-Detector Model (when the Jacobian difference spectrum is fed through it instead of the top-of-atmosphere radiance) and back-calculates the post-filter jacobian difference spectrum, essentially applying the LVF spectrometer's response function to the jacobian difference spectra measurements output by the RFM.


Orbital Modelling:
1. WorldMapCovClip.shp - A shapefile for input into Systems Tool Kit (STK) to define the area for which the coverage of the satellite instruments should be assessed. This particular file covers all of the world's land surfaces between +60 and -60 degrees latitude.
2. Sample_Grid.csv - A csv file containing the coordinates of all 9375 points on the sampling grid for which coverage was assessed in STK.
3. WorldLand_Cov_SHP_Cropped.tif - The above shapefile as a .tif image.
4. orbit_data_boxplots_ext_final.Rmd - A R markdown notebook that produces boxplots depicting the average values of the minimum, quartile, median, mean, and maximum revisit times for the satellite across all sample points in the grid, for a satellite at 10 different altitudes.
5. orbit_data_boxplots_ext_final_days.Rmd - An identical R markdown notebook to the previous entry, but this one outputs the revisit times in units of days rather than seconds.
6. parse_cvaa_v2_final.R - A R script that reads the .cvaa files output by STK to extract all of the access time data and calculate the times between each revisit for each sample point on the grid for each scenario.
7. Means_Comp.Rmd - A R markdown notebook that compares the mean revisit times achieved by a satellite at different altitudes across every sample point in each of several different latitude regions.
8. Means_Comp_Days.Rmd - As above, but with the output in units of days rather than seconds.
9. raw_data_boxplots_Lat[X].Rmd - Several R markdown notebooks that each produce a boxplot depicting the average values of the minimum, quartile, median, mean, and maximum revisit times for the satellite across all sample points in a given latitude region, for a satellite at 10 different altitudes. Replace [X] with 0, 30, N30, 60, or N55 depending on which latitude region is being considered.
10. raw_data_boxplots_Lat[X]_days.Rmd - As above, but with the outputs in units of days rather than seconds.
11. OffNadirCalcSheet.xlsx - A spreadsheet used to calculate the maximum allowable off-nadir observation angle for the satellite's instruments at different altitudes.
12. RevisitCalcSheet_Capped_Elevation.xlsx - A spreadsheet used to manually calculate estimates of the revisit time for the satellite's instruments at different altitudes from first principles.
13. CalculatedOrbitData.Rmd - A R Markdown notebook that reads the outputs of RevisitCalcSheet_Capped_Elevation.xlsx and produces plots comparing the revisit times for each altitude.
14. CalculatedOrbitData.csv - A csv file storing the outputs of RevisitCalcSheet_Capped_Elevation.xlsx that are read by CalculatedOrbitData.Rmd

