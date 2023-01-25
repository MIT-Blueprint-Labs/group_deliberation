How individual preferences are aggregated in groups: An experimental study
Attila Ambrus, Ben Greiner, Parag A. Pathak

Readme file for replication of results

Prepared by Carol Gao, completed 

********************************  Replication Instructions ********************************

- To run the code from beginning to end, including cleaning data files, setting up the analysis
file, and producing the tables and graphs, follow the instructions below:

	1. Open gift_exchange_clean.do and lottery_clean.do. Replace the SAS library path (line 6) with the appropriate one for 
		your machine. Run this file. This will run the code that cleans the raw data 
		files. The code outputs the clean file unobserved_dataset.csv, which is the 
		data file used for analysis. 
	2. Open master_exhibits.do. Update the clean_data and output paths (lines 10 and 11) to 
		those of your machine. Ensure both switches in the file for are turned on (i.e.,
		values equal 1). These are set to 1 by default. Run this file. This will run the 
		do files figures.do and tables.do, which produce figures 1-5 and tables 2-5.

	Note: The estimates in the published version of column 5 of Table 4 are different from 
		what is produced by the replication package. 