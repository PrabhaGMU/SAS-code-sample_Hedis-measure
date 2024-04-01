/****connecting to database, assigning a libref using a macro variable, defining a macro variable******/


%INCLUDE ' '; %CONNECT2DB(ASCR); 
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

%INCLUDE 'hidden for privacy'; 
%LOAD_DATA( MEASURE NAME = 'IPU', YEAR = 2020, DECK_TYPE = 'Sample', REGION = 'MAS', LIB = &LIB. ); 

/*Assign record_id to all visits*/ 

data &lib..visit; set &lib..visite; record id . _n_-1; run;

/*Create Score Key*/
proc import datafile = 'C:\IPU\score.txt' 
out = &lib..&lib._Scorekey_TEMP_1 
dbms = dlm replace ;

delimiter = ',';
run; 
PROC SQL; 
CREATE TABLE &lib..&lib._Scorekey_l AS 
SELECT DISTINCT PUT(MemId,16. -L) AS 
Memld, Meas, Payer, Proc, LOS, MM, Age Gender FROM &lib..8(lib.__Scorekey_TEMP_1 
ORDER BY Memld, Meas, Payer; QUIT; 

PROC SQL; 
CREATE TABLE &lib..811ib._Scorekey2 AS SELECT * FROM &lib..8ilib._Scorekey1 
ORDER BY Memld, Meas, Payer; QUIT; 

/*Create My VSD with all value set related to IPU*/

PROC SQL; 
CREATE TABLE &lib..my_vsd AS SELECT * FROM &lib..vsd 
WHERE VALUE SET NAME IN ('INPATIENT STAY', 'NONACUTE INPATIENT STAY', 'MENTAL AND BEHAVIORAL DISORDERS','DELIVERIES INFANT RECORD','MATERNITY DIAGNOSIS','MATERNITY','SURGERY') 
ORDER BY VALUE_SET_NAME, CODE_SYSTEM, CODE; 
QUIT; 

/**Age**/

proc sql; 
create table &lib..memage as select memid, gender, dob from &iib..member_gm; 
quit; 

/*hospice*/

%include 'hidden for privacy'; 
%INCLUDE 'hidden for privacy'; 
%ASCR_DATES(HEDIS_YEAR=&YEAR.);
%HOSPICE( MATCH_DATA = &LIB..hos, 
year= 2020 ,LIB = &lib. 
); 
proc sort data = &lib..hos; 
by memid; 
quit; 

proc sql; 
create table &lib..hos2 as select a.beneficiary_id as memid, a.run date, a.hospice (;)v from &lib..mmdf a 
/*inner join &lib..memage b*/ /*on a.beneficiaryid = b.memid*/ 
where a.hospice , 'Y' and a.run_date between 'Oljan2019'd and '31dec2019'd;
quit; 

proc sort data = &lib..hos2; 
by memid; 
quit; 

/*exclude hosipce*/ 

proc sql; 
CREATE TABLE &lib..allhospice AS SELECT DISTINCT A.MEMID, 'HOSPICE' AS TYP 
FROM &LIB..hos A 
UNION 
SELECT DISTINCT B.MEMID, 'HOSPICE-MMDF' AS TYP 
FROM &lib..hos2 B ; 
QUIT; 

proc sql; create table &lib..ep as select a.* from &lib..memage a 
where a.memid not in (select memid from Saib..allhospice) I 
order by memid; 
quit; 

/***Get Payer****/ 

proc sql; create table &lib..all_lob as select a.*, b.startdate, b.finishdate, b.payer from &lib..ep a inner join &lib..member_en b on a.memid = b.memid; quit; 


/* ---------------------------*/
     Dual enrollment logic
/*----------------------------*/ 
/*Remove members MEDICAID records if they're dually enrolled in COMMERCIAL*/

PROC SQL; 
CREATE TABLE &lib..ce comm_mbr AS SELECT * FROM &lib..all_lob 
WHERE payer IN ('CEP','HM0','POS',PPO'); 
QUIT; 

PROC SQL; 
DELETE FROM &lib..all_lob WHERE payer IN ('MD','MLI','MRB','MCD') AND CATX('#',Memid,startdate,finishdate) IN (SELECT CATX('#',memid,startdate,finishdate) 
FROM &lib..ce_comm_mbr); 
QUIT; 

/*Remove members COMMERCIAL records if they're dually enrolled in MEDICARE*/ 

PROC SQL; 
CREATE TABLE &lib..ce_mcr_mbr AS 
SELECT * FROM &lib—all_lob 
WHERE payer IN ('MCR','MCS','MC','MP','SN1','SN2'); 
QUIT; 

PROC SQL; 
DELETE FROM &lib..all_lob 
WHERE payer IN ('CEP','HM0','P0S','PPO') and CATX('#',memid,startdate,finishdate) IN 
(SELECT CATX( # ,memid,startdate,finishdate) FROM &lib..ce_mcr_mbr); QUIT; 

/*Remove members MEDICAID records if they're dually enrolled in MEDICARE*/ 

PROC SQL; 
DELETE FROM &lib..all_lob 
WHERE payer IN ('MD','MLI','MRB','MCD') AND CATX('#',memid,startdate,finishdate) IN (SELECT CATX('#',memid,startdate,finishdate) FROM &lib..ce_mcr_mbr); 
QUIT; 

/*Step 1-1*/ 
/*Inpatient Stay Visits*/ 

proc sql; 
create table &lib..Step11 as 
SELECT v.*, c.VALUE_SET_NAME AS visit_type 
FROM &lib..visit v 

INNER JOIN &lib..my_vsd c 
ON (v.rev = c.code AND c.code_system = 'UBREV') AND c.VALUE_SET_NAME = 'INPATIENT STAY' 
WHERE hcfapos NOT IN ('81') AND suppdata = 'N' AND claimstatus='1' AND year(v.date_disch) =2019; 
QUIT; 

/*Step 1-2*/ 
/*Noneacute Stay*/ 

proc sql; 
create table &lib..Nacute as SELECT DISTINCT v.*, c.VALUE_SET_NAME AS visit_type2, c.code_system 
FROM &lib..Step11 v INNER JOIN &lib..my_vsd c 
ON ((v.billtype=c.code AND c.code_system='UBTOB') OR 
(v.rev=c.code AND c.code_system = 'UBREV'))AND c.VALUE_SET_NAME='NONACUTE INPATIENT STAY' 
ORDER BY record_id, dateadm, date disch; 
QUIT; 

/*Exclude Nonacute inpatient Stay Visits*/ 

PROC SQL; CREATE TABLE &lib..Step13 AS 
SELECT DISTINCT a.* FROM Kib..Step11 a 
WHERE RECORD_ID NOT IN (SELECT RECORD_ID FROM &lib..Nacute b) 
ORDER BY record id, date adm, date_disch; 
QUIT; 

/*Step 2-1*/ 
/*Exclude Mental & Deliveries Stay*/ 

proc sql; 
create table &lib..Step2 as 
SELECT DISTINCT v.*, c.VALUE_SET_NAME AS visit_type2, c.code_system 
FROM &lib..Step13 v 
INNER JOIN &lib..my_vsd c 
ON (v.diag_i_1 = c.code AND c.code_system = 'ICD1OCM') AND (c.VALUE_SET_NAME = 'DELIVERIES INFANT RECORD' OR c.VALUE_SET_NAME 'MENTAL AND BEHAVIORAL DISORDERS') 
ORDER BY record_id, date_adm, date_disch; 
QUIT; 

/*Step 3*/ 
/*Total Inpatient*/ 

PROC SQL; 
CREATE TABLE &lib..IPUT AS 
SELECT DISTINCT a.* 
FROM &lib..Step13 a 
WHERE RECORD_ID NOT IN (SELECT RECORD_ID FROM &lib..Step2 b) 
ORDER BY record id, date adm, date_disch; 
QUIT; 

/*IPUT with payer*/ 

proc sql; 
create table &lib..FINAL_IPUT as 
select distinct A.memid ,A.DATE_ADM ,A.DATE_DISCH, 'IPUT' AS MEAS
,CASE WHEN B.PAYER IN ('SN1', 'SN2', 'SN3') THEN 'MCR' ELSE B.PAYER END
AS PAYER
,1 AS PROC
,CASE WHEN A.DATE_DISCH=A.DATE_ADM THEN 1 ELSE A.DATE_DISCH-A.DATE_ADM
END AS LOS
,0 AS MM
,B.dob
,B.GENDER
FROM &lib.. IPUT A
LEFT JOIN &lib.. all_lob B
ON A.MEMID=B.MEMID
AND A.DATE_DISCH BETWEEN B.STARTDATE AND B.FINISHDATE
WHERE B.PAYER NOT IN ('MP', 'MC', 'MMO','MOS','MPO','MEP')
AND B.PAYER IS NOT NULL
ORDER BY A.memid;
QUIT;

proc sql;
create table &lib.. FINAL IPUT 1 as
select *,floor(yrdif(dob~ date_disch, "age")) AS Age FROM
&lib.. FINAL_IPUT WHERE PAYER IN ('MRB','MD','MLI')
ORDER BY memid;
QUIT;

/*Use Memid date adm date disch in final_iput join back to vist to get all visits*/

proc sql;
create table &lib.. allvisit as
select a.* ,b.payer,b.Age,b.gender,b.los
from &lib..visit a
inner join &lib.. FINAL_IPUT_l b
on a.memid=b.memid
and a.DATE ADM=B.DATE ADM
AND A.DATE DISCH=B.DATE DISCH;
QUIT;


/*Step 4 Maternity*/

proc sql;
create table &lib..Maternity as
SELECT DISTINCT A.* FROM
(
SELECT DISTINCT v.*, c.VALUE_SET_NAME AS visit_type2, c.code_system
FROM &lib..allvisit v
INNER JOIN &lib..rny_vsd c
ON ((v.billtype = c.code AND c.code_system = 'UBTOB') OR (v.rev -
c.code AND c.code_system = 'UBREV')) AND c.VALUE_SET_NAME ='MATERNITY'
UNION
SELECT DISTINCT v.*, C.VALUE_SET_NAME AS visit_type2, c.code_system
FROM &lib.. allvisit v
INNER JOIN &lib..my_vsd C
ON V.diag_i_1=c.CODE AND c.VALUE_SET_NAME ='MATERNITY DIAGNOSIS'
ORDER BY RECORD ID;
QUIT;

/*Step 5 for Surgery*/
/*Exclude Maternity from Final Inpatient*/

proc sql;
create table &lib .. Nonmaternity as
select a.* from &lib.. FINAL_IPUT_1 a
left join &lib..Maternity b 
on a.memid=b.memid
and a.DATE_ADM=B.DATE_ADM
AND A.DATE_DISCH=B.DATE_DISCH
where b.memid is null;
quit; 

/*Use Memid date_adm date_disch in final_iput join back to vist to get all visits for surgery*/

proc sql;
create table &lib.. allvisitsur as
select a.* ,b.payer,b.age,b.gender,b.los
from &lib.. visit a
inner join &lib.. Nonmaternity b
on a.memid=b.memid
and a.DATE_ADM=B.DATE_ADM
AND A.DATE_DISCH=B.DATE_DISCH;
QUIT;

/*Step 5 Final Surgery*/

proc sql;
create table &lib..Surgery as
SELECT DISTINCT v.*, c.VALUE_SET_NAME AS visit_type2, c.code_system
FROM &lib.. allvisitsur v
INNER JOIN &lib..my_vsd C
ON v.rev = c.code AND c.code_system = 'UBREV' AND c.VALUE_SET_NAME -
'SURGERY'
ORDER BY RECORD ID;
QUIT;


/*Step 6 Exclude maternity and surgery to get medicine*/

proc sql;
create table &lib..Medicine as
select a.* from &lib..Surgery C
left join &lib.Surgery C
on a.memid=c.memid
and a.DATE_ADM=c.DATE_ADM
AND A.DATE_DISCH=C·DATE_DISCH
where c.memid is null;

/*Creat final result table*/

proc sql;
create table &lib.. result as
select Memld
, 'IPUT' AS Meas
,Payer
,1 as Proc
,LOS
,0 as MM 
,Age
,Gender 
from &lib..FINAL_IPUT_1
union
select Memld
,'IPUMAT' AS Meas
,Payer
,1 as Proc
,LOS
,0 as MM
,Age
,Gender
from &lib..Maternity
union
select Memid
, 'IPUS' AS Meas
,Payer
,1 as Proc
,LOS
,0 as MM
,Age
,Gender
from &lib..Surgery
union
select Memid
,'IPUM' AS Meas
,Payer 
,1 as Proc
,LOS
,0 as MM
,Age
,Gender
from &lib..Medicine;
quit;

/*Match with score key*/

PROC SQL;
CREATE TABLE LESS AS
SELECT DISTINCT b.* FROM &lib .. result a FULL OUTER JOIN &lib..&lib.
_Scorekeyl b ON a.memid = b.memid AND A.PAYER=B.PAYER AND A.LOS=B.LOS
AND A.MEAS=B.MEAS WHERE a.memid IS NULL;
QUIT;

/*Match with score key*/

PROC SQL;
CREATE TABLE extra AS
SELECT DISTINCT a.* FROM &lib .. result a FULL OUTER JOIN &lib .. &lib.
_Scorekeyl b ON a.memid = b.memid-and_g.LOS=B.LOS AND A.PAYER=B.PAYER
ANO A.MEAS=B.MEAS WHERE,b.memid IS NULL;
QUIT; 


/*Check with scorekey*/

PROC SQL;
CREATE TABLE &LIB.. IPU answer check AS
SELECT
CASE
WHEN a.Memid=b.Memid THEN 1
ELSE 0
END AS MEMID CHECK,
CASE
WHEN a.Meas=b.Meas THEN 1
ELSE 0
END AS Meas_CHECK,
CASE
WHEN a.Payer=b.Payer THEN 1
ELSE 0
END AS Payer_CHECK,
(a.Proc-b.Proc) AS Proc_Diff,(a.LOS-b.LOS) AS LOS Diff ,(a.MM-b.MM) AS
MM_Diff,(a.Age-b.Age) AS Age_Diff,
CASE
WHEN a.Gender=b.Gender THEN 1
ELSE 0
END AS Gender_CHECK FROM &LIB..&LIB._Scorekeyl a
LEFT JOIN &lib.. result b ON a.Memld=b.Memld AND a.Meas=b.Meas;
QUIT;



/**********END OF ANALYSIS********/



