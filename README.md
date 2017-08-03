#Instructions to execute GIA workflows under Windows 7.-

(1) Unzip all the files from the .zip package
(2) Run the prompt cmd and change default directory to the folder containing the .exe files (\SanXoT_package) 
"(3) Open the Example_Workflow.bat file with a text editor and replace ""full_path"" by the path of the directory containing the data tables (i.e. those in \Example)."
"(4) To run the demo integration, drag the .bat file to cmd promt and execute"

"The GIA workflows are constructed using three executables: klibrate.exe, sanxot.exe and sanxotsieve.exe. "

"Workflows are assembled in .bat files, that are executed automatically under Windows command prompt. "

"Example_Workflow.bat is an example .bat file to integrate a table of quantifications performed at the scan level to the peptide and protein levels, and to perform the Systems Biology Triangle (a Scheme of the workflow is also included). The files needed to execute the demo (in the \Example folder) are:"

"scan_XsVs_NM.txt and scan_XsVs_PTM.txt are the original files containing the quantifications at the scan level. These are tab-delimited files containing three columns: the first contains unique alphanumeric identifiers of each element, the second the quantification Xi and the third the weights Vi."

s2pNM_Rels.txt and s2pPTM_Rels.txt are the relation tables assigning peptide identifiers (first column) to scan identifiers (second column) and to modifications identifiers (third column)

p2qRels_ALL..txt is the relation table assigning protein identifiers (First column) to peptide identifiers (second column) and to modifications identifiers (third column)

q2cRels.txt is the relation table assigning category identifiers to protein identifiers (protein classification into categories)

All these txt files contain a header that is only used for orientative purposes.

"-klibrate.exe is an executable file used to calibrate the original weights, transforming them into calibrated weights (in units of the inverse of local variances). This program must be executed as a first step in the workflow."

"-sanxot.exe is the main executable file containing the GIA algorithm. It calculates iteratively the variance of the integration, and once convergence is reached, integrates the data from the lower to the higher level (such as from peptide data to protein "
 
sanxotsieve.exe is an executable file used to tagg outliers in the relation table after a sanxot integration. The FDR threshold can be set by the user.

"More detailed technical information about each executable, input and output files and parameters can be obtained by running them using -h."
