
REM Important: before performing the integration, change "full_path" by the path containing data and relation tables

REM *********************************************
REM *********** PART 1: integrations ************
REM ******** scan > peptide > protein ***********
REM *********************************************

REM ********** CALIBRATION OF WEIGHTS (as in the WSPP model)

REM Calculation of calibration constant k of the set of scans belonging to the NM-peptides
REM k transforms uncalibrated weights into true weights (inverses of variances)
REM -a sets the indicated prefix into the output file
REM -o names the output file as "NM_scan_Calibrated.txt" 

klibrate.exe -d"full_path/scan_XsVs_NM.txt" -r"full_path/s2pNM_Rels.txt" -k1 -v0 -aNM_scan -o"full_path/NM_scan_Calibrated.txt"

REM Calibration of weights of the set of scans belonging to the PTM-peptides
REM -f avoids k and variance recalculation (uses variance seed as final variance)
REM the variance and calibration constant k from the set of scans corresponding to the non modified (NM) peptides are used to calibrate the scans from the PTM-containing peptides (PTM)

klibrate.exe -d"full_path/scan_XsVs_PTM.txt" -r"full_path/s2pPTM_Rels.txt" -f -K"full_path/NM_scan_infoFile.txt" -V"full_path/NM_scan_infoFile.txt" -aPTM_scan -o"full_path/PTM_scan_Calibrated.txt"

REM prepares a joined scan data file from NM and PTM peptides
copy "full_path/NM_scan_Calibrated.txt"+"full_path/PTM_scan_Calibrated.txt" "full_path/ALL_scan.txt"

REM prepares a joined scan to peptide relations file from NM and PTM peptides
copy "full_path/s2pNM_Rels.txt"+"full_path/s2pPTM_Rels.txt" "full_path/s2pALL_Rels.txt"

REM ********** SCAN TO PEPTIDE INTEGRATION

REM --tags"NonMod" selects the group of scans from the NM peptides as the null-hypothesis to calculate the scan variance. 
REM The tag is included in the third column of the scan-to-peptide relations file.
REM A file named "s2pNM_OutStats.xls" is created. It contains Zsp for scans from NM and PTM-peptides, and FDRsp for scans only from NM peptides.
REM Also a file named "NM_peptide.xls" is created. It contains Xp and Vp values from NM-peptides to perform the following peptide-to-protein integration.

sanxot.exe -d"full_path/ALL_scan.txt" -r"full_path/s2pALL_Rels.txt" -a"s2pNM" -o"NM_peptide.xls" --tags"NonMod"

REM -f avoids variance recalculation (uses variance seed as final variance)
REM -V"s2pNM_infoFile.txt" forces the previously obtained null-hypothesis scan variance as seed to integrate the scans from the PTM-peptides.
REM --tags"PTM" selects the group of scans from the PTM-peptides to perform the integration. 
REM A file named "s2pPTM_OutStats.xls" is created. It contains Zsp for scans from NM and PTM-peptides, and FDRsp for scans only from PTM peptides.
REM Also a file named "PTM_peptide.xls" is created. It contains Xp and Vp values from PTM-peptides to perform the following peptide-to-protein integration.

sanxot.exe -d"full_path/ALL_scan.txt" -r"full_path/s2pALL_Rels.txt" -f -V"full_path/s2pNM_infoFile.txt" -a"s2pPTM" -o"PTM_peptide.xls" --tags"PTM"

REM ********** PEPTIDE TO PROTEIN INTEGRATION

REM prepares a joined NM- and PTM-peptide data file 

copy "full_path/NM_peptide.xls"+"full_path/PTM_peptide.xls" "full_path/peptide_ALL.xls"

REM --tags"NonMod" selects the NM peptides as the null-hypothesis to calculate the peptide variance and the protein mean. 
REM The tag is included in the third column of the peptide-to-protein relations file.
REM A file named "protein.xls" is created. It contains protein Xq and Vq values to perform the following protein-to-category integration.
REM An additional file is created "p2q_OutStats.xls" containing the Zpq for NM and PTM-peptides, and the FDRpq for NM peptides only.

sanxot.exe -d"full_path/peptide_ALL.xls" -r"full_path/p2qRels_ALL.xls" -a"p2q" --tags="NonMod" -o"protein.xls"
	
REM *********************************************
REM ****** PART 2: SYSTEMS BIOLOGY TRIANGLE *****
REM *********************************************

REM ********* PROTEIN TO CATEGORY INTEGRATION

REM initial protein>category integration
REM The output file "q2c_OutStats.xls" contains Zqc and FDRqc.

sanxot.exe -d"full_path/protein.xls" -r"full_path/q2cRels.txt" -a"q2c_inouts"

REM The output file "removingOutliers_q2c_tagged.xls" file is created by tagging as "out" the protein outliers withinh each category at 1% FDRqc in the q2cRels.txt file.

sanxotsieve.exe -d"full_path/protein.xls" -r"full_path/q2cRels.txt" -f0.01 -V"full_path/q2c_inouts_infoFile.txt" -a"removingOutliers_q2c" --tags="!out"

REM reintegrate protein>category without outliers

sanxot.exe -d"full_path/protein.xls" -r"full_path/removingOutliers_q2c_tagged.xls" -a"q2c_NoOuts" -o"category.xls" --tags="!out" -f -V"full_path/q2c_inOuts_infoFile.txt"
	
REM ********* CATEGORY TO ALL INTEGRATION

REM -C forces integration to all, obviating the use of a (category-to-all) relations table.
REM The output file "c2A_OutStats.xls" contains Zca and FDRca. 

sanxot.exe -d"full_path/category.xls" -C -v0 -f -a"c2A"

REM ********* PROTEIN TO ALL INTEGRATION

REM The output file "q2A_OutStats.xls" contains Zqa and FDRqa

sanxot.exe -d"full_path/protein.xls" -C -V"full_path/q2c_inouts_infoFile.txt" -f -a"q2A"

echo on