%INCLUDE ' MARDCFILE010 MGOS HEDIS-TEST DECK CONNECTIONS \CONNECT2DB.SAS'; %CONNECT2DB(ASCR); 
%LET LTA = IPU; 
LIBNAME &LIB. 1C:\IPU'; 
%LET MEASURE NAME 'IPU'; %LET MEASURE'- IPU; 
%LET LIB - IPU; 

%LET TEST YEAR = 2020; 
%LET YEAR = 2019; 
%LET VISIT END DT = '31dec2019'd;
%LET EVENT_BEG_DTM ; 
%LET EVENT_ END DTM; 

%LET DECK_TYPE = 'Sample'; 
%LET REGION = 'MAS'; 

%PUT &MEASURE_NAME.; 
%PUT &DECK_TYPE.; 
%PUT &REGION.; 
%PUT &YEAR.; 
%PUT &DIS BEG DTM.; 
%PUT &DIS_ END _DTM.; 
%PUT &EVENT_BEG_DTM.; 
%PUT &EVENT END DTM.; 

/*Last day of measurement year*/ 
%INCLUDE 'W:\QUALITY HEDIS MEASURES\QUALITY TEST DECK 2020\Infile \LOAD_DATA.SAS'; 
%LOAD_DATA( MEASURE NAME = 'IPU', YEAR = 2020, DECK_TYPE = 'Sample', REGION = 'MAS', LIB = &LIB. ); 

/*Assign record_id to all visits*/ 
data &lib..visit; set &lib..visite; record id . _n_-1; run;

/*Create Score Key*/
proc import datafile = 'C:\IPU\score.txt' 
out = &lib..&lib._Scorekey_TEMP_1 
dbms = dlm replace 


