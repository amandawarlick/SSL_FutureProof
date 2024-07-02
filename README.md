## *Optimizing mark-resight survey design for demographic estimation: A retrospective analyses using the endangered Steller sea lion* 

#### Amanda J. Warlick, Brian S. Fadely, Peter Mahoney, Sharon R. Melin, Tom Gelatt, Kim Raum-Suryan, Sarah J. Converse

##### Please contact Amanda Warlick at amanda.warlick@noaa.gov for questions about the code or data.

##### Secondary contact: Sarah Converse (sconver@usgs.gov)

DOI: TBD.

________________________________________________________________________________

## Abstract

Effective monitoring is fundamental to estimating wildlife population parameters with a level of precision that is adequate to inform management decisions. However, trade-offs exist between survey effort, costs, and the resulting data quality. As such, evaluating the expected performance of monitoring designs prior to implementation can help identify designs that require the least investment for a desired level of performance. In this study, we present a simulation framework for examining the precision of age-specific survival estimates and the probability of detecting a change in survival within the context of mark-resight monitoring programs. We consider 90 survey designs that vary across a range of attributes, including marked cohort size, marking frequency, resight probability, and study duration. We implement this framework in the context of designing an effective monitoring program for Steller sea lions (*Eumetopias jubatus*), which is complicated by heterogeneity in rookery accessibility, rookery population sizes, and abundance trends across the species’ range. Our results highlight a variety of survey designs that reliably meet pre-defined precision targets, with precision being most sensitive to marked cohort size, marking frequency, and study duration, and less sensitive to resight probability. We found that historical mark-resight survey effort for Steller sea lions has been sufficient to reliably achieve precision targets for younger age classes only for rookeries where abundance trends are stable or increasing. However, at rookeries where abundance trends are declining, the probability of achieving survival estimates with target levels of precision is low (<25%) due to smaller marked cohort sizes, lower marking frequency at remote sites, and fewer years of available data. We also demonstrate the evaluation of model performance relative to costs to identify the most cost-efficient survey designs. Though our results indicate that the precision of survival estimates for subpopulations of conservation concern can be improved by longer-term monitoring, the constraints of monitoring these small populations may limit the ability of biologists to detect changes in population dynamics on management-relevant time horizons. This modeling framework can be applied in a variety of contexts to assist natural resource managers in developing monitoring programs that efficiently meet specific monitoring objectives. 

### Table of Contents 

#### [Scripts](./scripts)

- SSL_FutureProof_sim.Rmd includes simulation and estimation functions, code to run simulations and model fitting in nimble, and code to generate model performance metrics. 

Code to generate figures is available upon request but generally not extensively included here. 
 
#### [Data](./Data) 

This was primarily a simulation-based study. Contact the first author for code and data that were used to produce empirical estimates that guided data generation for the simulations. 

#### [Results](./results)

Results files can be obtained by contacting the first author.

### Required Packages and Versions Used 

Hmisc_4.5-0       
ggstance_0.3.5   
reshape2_1.4.4    
truncnorm_1.0-8   
DescTools_0.99.43 c
cowplot_1.1.1     
demogR_0.6.0     
gtools_3.9.2
knitr_1.31        
stringr_1.4.0    
purrr_0.3.4       
ggplot2_3.3.6     
tidyverse_1.3.1   
dplyr_1.0.5      
readr_2.0.1       
here_1.0.1        
tidyr_1.1.3       
lubridate_1.7.10 
latex2exp_0.9.5

### Details of Article 

Warlick, AJ, Fadely, BS, Mahoney, P, Melin, SR, Gelatt, T, Raum-Suryan, K, Converse, SJ. Date. Optimizing mark-resight survey design for demographic estimation: A retrospective analyses using the endangered Steller sea lion. Journal TBD

### How to Use this Repository 

The SSL_FutureProof_sim.Rmd file includes code chunks that outline functions used to designate initial values and known latent state information, nimble functions used to fit the model, model text, transition matrices and descriptions of the model parameters and simulation scenarios, and code used to run the model in parallel using nimble. Simulations were saved in batches due to computing resources.

Contact the first author for (1) data processing and mark-resight model code used to produce empirical estimates (that guided data generation for the simulation); and (2) code used to generate figures and summary statistics found in the manuscript.




