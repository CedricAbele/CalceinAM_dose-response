# Project summary

The aim of this project was to develop an image-based analysis method for toxicological effects on esterase acitivty in Daphnia magna after exposure the esterase inhibitors triphenyl phosphate and netilmicin sulphate. Molecular staining with Calcein-AM combined with fluorescence microscopy was used to quantify adverse effects. After the method was validated, the method was applied to environmental contaminants methoxychlor, lindane, diuron, pentachlorophenol, ethofumesate and TBT-CL. The effects were measured based on light intensity data extracted from fluorescence images. Fast generation of toxicological data is a main goal in this study. Therefore image acquisition was done with an automated multipoint confocal high-content imaging system suitable for experiments in multi-well plates. This R workflow was developed to perform basic statistical analysis and generate figures that compares two toxic endpoints measuered in the same sample.

It also contains the code to plot dose-response curves for daphnia immobilisation which can be found in the supplementary information of the publication (currently under revision)

>Code was used in this paper: (under Review)

It was adapted from the code previously used in this publication: [Automated Image-based Fluorescence Screening of Mitochondrial Membrane Potential in Daphnia magna: An advanced ecotoxicological testing tool](https://doi.org/10.1021/acs.est.4c02897)

## Project structure

The folder `bin` contains the functions and code that is needed to produce the plots.

```sh
project/
|-- bin/
|   |-- dose_response.R
|   |-- dr_immobilisation_24h_48h.R
|-- data/
`-- README.md
```


## code explanation: dose-response modeling
 The results are summarized in a .xslx file containing Calcein intensities and dead/alive evaluation of all  independent experiments.

The drc package is used to model dose-response relationships for both endpoints (immobilization and fluorescence signal). 
(Reference: Ritz, C.; Baty, F.; Streibig, J. C.; Gerhard, [D. Dose-Response Analysis Using R. PLOS ONE 2015, 10 (12), e0146021.](https://doi.org/10.1371/journal.pone.0146021) )




# raw data
 This folder contains the raw data of all dose-response calculations and plots found in the publication. 
 (files will be uploaded as soon as the manuscript is accepted)