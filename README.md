# Project summary

The aim of this project was to develop an image-based analysis method for toxicological effects on esterase acitivty in Daphnia magna after exposure to the esterase inhibitors triphenyl phosphate and netilmicin sulphate. Molecular staining with Calcein-AM combined with fluorescence microscopy was used to quantify adverse effects. After the method was validated, the method was applied to environmental contaminants methoxychlor, lindane, diuron, pentachlorophenol, ethofumesate and TBT-CL. The effects were measured based on light intensity data extracted from fluorescence images. Fast generation of toxicological data is a main goal in this study. Therefore image acquisition was done with an automated multipoint confocal high-content imaging system suitable for experiments in multi-well plates. This R workflow was developed to perform basic statistical analysis and generate figures that compares two toxic endpoints measuered in the same sample. With this code effect concentrations were calculated and dose-response curves were generated for the Calcein signal and immobilisation data of the same samples.

It also contains the code to plot dose-response curves for daphnia immobilisation according to OECD in glass beakers (OECD_TPP.R).The graphs can be found in the supplementary information of the publication (currently under revision)

>Code was used in this paper: (under Review)

It was adapted from the code previously used in this publication: [Automated Image-based Fluorescence Screening of Mitochondrial Membrane Potential in Daphnia magna: An advanced ecotoxicological testing tool](https://doi.org/10.1021/acs.est.4c02897)

## Project structure

The folder `bin` contains the functions and code that is needed to produce the plots.

```sh
CalceinAM_D.magna/
|-- bin/
|   |-- dr_calcein_immobilisation_TPP.R
|   |-- OECD_TPP.R
|-- data/
    |-- CA_immobilisation_TPP.xlsx
    |-- OECD_TPP.xlsx
`-- README.md
```


## code explanation: dose-response modeling
 The results are summarized in a .xslx file containing Calcein intensities and dead/alive evaluation of all  independent experiment as an input file for "dr_calcein_immobilisation_TPP.R" 

The drc package is used to model dose-response relationships for both endpoints (immobilization and fluorescence signal). 
(Reference: Ritz, C.; Baty, F.; Streibig, J. C.; Gerhard, [D. Dose-Response Analysis Using R. PLOS ONE 2015, 10 (12), e0146021.](https://doi.org/10.1371/journal.pone.0146021) )




# raw data
 This folder contains the raw data of all dose-response calculations and plots found in the publication. 
 (only raw data for triphenyl phosphat (TPP) are available at the moment. the raw data for all other tested compounds will be uploaded as soon as the manuscript is accepted)