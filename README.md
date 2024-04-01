# SAS-code-sample_Hedis-measure

Inpatient Utilization—General Hospital/Acute Care (IPU)

Description
This measure summarizes utilization of acute inpatient care and services in the following categories:
              • Maternity.
              • Surgery.
              • Medicine.
              • Total inpatient (the sum of Maternity, Surgery and Medicine).
              
Calculations
Note: Members in hospice are excluded from this measure. Refer to General Guideline 17: Members in Hospice.
      Product lines Report the following tables for each applicable product line:
            • Table IPU-1a Total Medicaid.
            • Table IPU-1b Medicaid/Medicare Dual-Eligibles.
            • Table IPU-1c Medicaid—Disabled.
            • Table IPU-1d Medicaid—Other Low Income.
            • Table IPU-2 Commercial—by Product or Combined HMO/POS.
            • Table IPU-3 Medicare.

Member months
For each product line and table, report all member months for the measurement year. IDSS automatically produces member years data for the commercial and Medicare
product lines. 
Refer to Specific Instructions for Utilization Tables for more information. 
Maternity rates are reported per 1,000 male and per 1,000 female total member months for members 10–64 years in order to capture deliveries as a percentage of the total inpatient discharges.
Days Count all days associated with the identified discharges. Report days for total inpatient,
maternity, surgery and medicine.
ALOS Refer to Specific Instructions for Utilization Tables for the formula. Calculate average length of stay for total inpatient, maternity, surgery and medicine.

Draft Document for HEDIS Public Comment—Obsolete After March 11, 2019 ©2019 National Committee for Quality Assurance 5
Use the following steps to identify and categorize inpatient discharges.
Step 1 
Identify all acute inpatient discharges on or between January 1 and December 31 of the
measurement year. To identify acute inpatient discharges:
1. Identify all acute and nonacute inpatient stays (Inpatient Stay Value Set).
2. Exclude nonacute inpatient stays (Nonacute Inpatient Stay Value Set).
3. Identify the discharge date for the stay.
   
Step 2 
Exclude discharges with a principal diagnosis of mental health or chemical dependency
(Mental and Behavioral Disorders Value Set).
Exclude newborn care rendered from birth to discharge home from delivery (only include care
rendered during subsequent rehospitalizations after the delivery discharge). Identify newborn
care by a principal diagnosis of live-born infant (Deliveries Infant Record Value Set).
Organizations must develop methods to differentiate between the mother’s claim and the
newborn’s claim, if needed.

Step 3 
Report total inpatient, using all discharges identified after completing steps 1 and 2.

Step 4 
Report maternity. A delivery is not required for inclusion in the Maternity category; any
maternity-related stay is included. Include birthing center deliveries and count them as one
day of stay.
Starting with all discharges identified in step 3, identify maternity using either of the following:
• A maternity-related principal diagnosis (Maternity Diagnosis Value Set).
• A maternity-related stay (Maternity Value Set).

Step 5 
Report surgery. From discharges remaining after removing maternity (identified in step 4) from
total inpatient (identified in step 3), identify surgery (Surgery Value Set).

Step 6 
Report medicine. Categorize as medicine the discharges remaining after removing maternity
(identified in step 4) and surgery (identified in step 5) from total inpatient (identified in step 3).
Draft Document for HEDIS Public Comment—Obsolete
