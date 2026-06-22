---
title: "pharmaverseadam"
version: "1.3.0"
package_title: "ADaM Test Data for the 'Pharmaverse' Family of Packages"
description: "A set of Analysis Data Model (ADaM) datasets constructed using the Study Data Tabulation Model (SDTM) datasets contained in the 'pharmaversesdtm' package and the template scripts from the 'admiral' family of packages. ADaM dataset specifications are described in the CDISC ADaM implementation guide, accessible by creating a free account on <https://www.cdisc.org/>."
---

# pharmaverseadam

*ADaM Test Data for the 'Pharmaverse' Family of Packages*

A set of Analysis Data Model (ADaM) datasets constructed using the Study Data Tabulation Model (SDTM) datasets contained in the 'pharmaversesdtm' package and the template scripts from the 'admiral' family of packages. ADaM dataset specifications are described in the CDISC ADaM implementation guide, accessible by creating a free account on <https://www.cdisc.org/>.

## adab

*Anti-Drug Antibody Analysis Dataset*

**Description**

Anti-Drug Antibody Analysis Dataset

**Usage**

```r
```

**Format**

A data frame with 72 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
COUNTRY Country
ETHNIC Ethnicity
AGE Age
AGEU Age Units
SEX Sex
RACE Race
SAFFL Safety Population Flag
TRT01P Description of Planned Arm
TRT01A Description of Actual Arm
TRTSDTM Datetime of First Exposure to Treatment
TRTSDT Date of First Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ISSEQ Sequence Number
ISTESTCD Immunogenicity Test/Exam Short Name
ISTEST Immunogenicity Test or Examination Name
ISCAT Category for Immunogenicity Test
ISBDAGNT Binding Agent
ISSTRESC Character Result/Finding in Std Format

ISSTRESN Numeric Results/Findings in Std. Units
ISSTRESU Standard Units
ISSTAT Completion Status
ISREASND Reason Not Done
ISSPEC Specimen Type
DTL Drug Tolerance Level
MRT Minimum Reportable Titer
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EPOCH Epoch
ISDTC Date/Time of Collection
ISDY Study Day of Visit/Collection/Exam
ISTPT Planned Time Point Name
ISTPTNUM Planned Time Point Number
PARAM Parameter
PARAMCD Parameter Code
PARCAT1 Parameter Category 1
AVAL Analysis Value
AVALC Analysis Value (C)
AVALU Analysis Value Unit
BASETYPE Baseline Type
BASE Baseline Value
CHG Change from Baseline
DTYPE Derivation Type
ADTM Analysis Datetime
ADT Analysis Date
ADY Analysis Relative Day
ATMF Analysis Time Imputation Flag
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
APHASE Phase
APHASEN Phase (N)
APERIOD Period
APERIODC Period (C)
FANLDTM First Datetime of Dose for Analyte

FANLDT First Date of Dose for Analyte
FANLTM First Time of Dose for Analyte
FANLTMF First Time of Dose for Analyte ImputeFL
NFRLT Nom. Rel. Time from Analyte First Dose
AFRLT Act. Rel. Time from Analyte First Dose
FRLTU Rel. Time from First Dose Unit
ABLFL Baseline Record Flag
ADABLPFL Baseline ADA Eval. Param-Level Flag
ADPBLPFL Post-Baseline ADA Eval. Param-Level Flag
ADAFL ADA Population Flag

**Details**

Contains a set of 22 unique Parameter Codes and Parameters:
PARAMCD
PARAM
ADADUR1
ADA Duration (Weeks), Anti-XANOMELINE Antibody (1)
ADASTAT1
ADA Status of a patient, Anti-XANOMELINE Antibody (1)
ADASTTV1
ADA Status of a patient by Visit, Anti-XANOMELINE Antibody (1)
BABXANOM
Anti-XANOMELINE Antibody, Titer Units (1)
BFLAG1
Baseline Pos/Neg, Anti-XANOMELINE Antibody (1)
EMERNEG1
Treatment Emergent - Negative, Anti-XANOMELINE Antibody (1)
EMERPOS1
Treatment Emergent - Positive, Anti-XANOMELINE Antibody (1)
ENHANC1
Treatment enhanced ADA, Anti-XANOMELINE Antibody (1)
FPPDTM1
First Post Dose Positive Datetime, Anti-XANOMELINE Antibody (1)
INDUCD1
Treatment induced ADA, Anti-XANOMELINE Antibody (1)
LPPDTM1
Last Post Dose Positive Datetime, Anti-XANOMELINE Antibody (1)
NABSTAT1
Nab Status, Anti-XANOMELINE Neutralizing Antibody (1)
NABXANOM
Anti-XANOMELINE Neutralizing Antibody (1)
NOTRREL1
No treatment related ADA, Anti-XANOMELINE Antibody (1)
PBFLAGV1
Post Baseline Pos/Neg by Visit, Anti-XANOMELINE Antibody (1)
PERSADA1
Persistent ADA, Anti-XANOMELINE Antibody (1)
RESULT1
ADA interpreted per sample result, Anti-XANOMELINE Antibody (1)
RESULT2
Nab interpreted per sample result, Anti-XANOMELINE Neutralizing Antibody (2)
TFLAGV1
Treatment related ADA by Visit, Anti-XANOMELINE Antibody (1)
TIMADA1
Time to onset of ADA (Weeks), Anti-XANOMELINE Antibody (1)
TRANADA1
Transient ADA, Anti-XANOMELINE Antibody (1)
TRUNAFF1
Treatment unaffected, Anti-XANOMELINE Antibody (1)

**Source**

Generated from admiral package (template ad_adab.R).

**References**

None

## adae

*Examples data("adab") adae Adverse Events Analysis*

**Description**

Adverse Events Analysis

**Usage**

```r
```

**Format**

A data frame with 107 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag

REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
AESEQ Sequence Number
AETERM Reported Term for the Adverse Event
AEDECOD Dictionary-Derived Term
AEBODSYS Body System or Organ Class

AEBDSYCD Body System or Organ Class Code
AELLT Lowest Level Term
AELLTCD Lowest Level Term Code
AEPTCD Preferred Term Code
AEHLT High Level Term
AEHLTCD High Level Term Code
AEHLGT High Level Group Term
AEHLGTCD High Level Group Term Code
AESOC Primary System Organ Class
AESOCCD Primary System Organ Class Code
AESTDTC Start Date/Time of Adverse Event
ASTDT Analysis Start Date
ASTDTM Analysis Start Date/Time
ASTDTF Analysis Start Date Imputation Flag
ASTTMF Analysis Start Time Imputation Flag
AEENDTC End Date/Time of Adverse Event
AENDT Analysis End Date
AENDTM Analysis End Date/Time
AENDTF Analysis End Date Imputation Flag
AENTMF Analysis End Time Imputation Flag
ASTDY Analysis Start Relative Day
AESTDY Study Day of Start of Adverse Event
AENDY Analysis End Relative Day
AEENDY Study Day of End of Adverse Event
ADURN Analysis Duration (N)
ADURU Analysis Duration Units
TRTEMFL Treatment Emergent Analysis Flag
AOCCIFL 1st Max Sev./Int. Occurrence Flag
AESER Serious Event
AESDTH Results in Death
AESLIFE Is Life Threatening
AESHOSP Requires or Prolongs Hospitalization
AESDISAB Persist or Signif Disability/Incapacity
AESCONG Congenital Anomaly or Birth Defect
AESEV Severity/Intensity
ASEV Analysis Severity/Intensity
ASEVN Analysis Severity/Intensity (N)

AEREL Causality
AREL Analysis Causality
AEACN Action Taken with Study Treatment
AESPID Sponsor-Defined Identifier
AEOUT Outcome of Adverse Event
AESCAN Involves Cancer
AESOD Occurred with Overdose
AEDTC Date/Time of Collection
LDOSEDTM End Date/Time of Last Dose
DOSEON Treatment Dose
DOSEU Treatment Dose Unit

**Source**

Generated from admiral package (template ad_adae.R).

**References**

None

**Examples**

```r
data("adae")
```

## adapet_neuro

*Amyloid PET Scan Analysis Dataset*

**Description**

Amyloid PET Scan Analysis Dataset

**Usage**

```r
```

**Format**

A data frame with 49 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
ASEQ Analysis Sequence Number
TRT01P Planned Treatment for Period 01

TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code
AVAL Analysis Value
AVALC Analysis Value (C)
AVALU Analysis Value Unit
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
ONTRTFL On Treatment Record Flag
NVSEQ Sequence Number
NVLNKID Link ID
NVTESTCD Short Name of Nervous System Test
NVTEST Name of Nervous System Test
NVCAT Category for Nervous System Test
NVLOC Location Used for the Measurement
NVNAM Vendor Name
NVORRES Result or Finding in Original Units
NVORRESU Original Units
NVSTRESC Character Result/Finding in Std Format
NVSTRESN Numeric Result/Finding in Standard Units
NVSTRESU Standard Units
NVMETHOD Method of Test or Examination
NVLOBXFL Last Observation Before Exposure Flag

REFREG Reference Region
AGTRT Reported Agent Name
AGCAT Category for Agent
VISITNUM Visit Number
VISIT Visit Name
NVDTC Date/Time of Collection
NVDY Study Day of Visit/Collection/Exam

**Details**

Contains a set of 7 unique Parameter Codes and Parameters:
PARAMCD
PARAM
CENTLD
Centiloid value derived from SUVR pipeline
SUVRAFBB
AVID FBB Standard Uptake Ratio Neocortical Composite Whole Cerebellum
SUVRAFBP
AVID FBP Standard Uptake Ratio Neocortical Composite Whole Cerebellum
SUVRBFBB
BERKELEY FBB Standard Uptake Ratio Neocortical Composite Whole Cerebellum
SUVRBFBP
BERKELEY FBP Standard Uptake Ratio Neocortical Composite Whole Cerebellum
VRFBB
FBB Qualitative Visual Classification
VRFBP
FBP Qualitative Visual Classification

**Source**

Generated from admiralneuro package (template ad_adapet.R).

**References**

None

**Examples**

```r
data("adapet_neuro")
```

## adbcva_ophtha

*Best Corrected Visual Acuity Analysis*

**Description**

Best Corrected Visual Acuity Analysis

**Usage**

```r

```

**Format**

A data frame with 71 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
PARAM Parameter
PARAMCD Parameter Code
AVAL Analysis Value
AVALC Analysis Value (C)
AVALU Analysis Value Unit
AVALCAT1 Analysis Value Category 1
AVALCA1N Analysis Value Category 1 (N)
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
CRIT2 Analysis Criterion 2
CRIT2FL Criterion 2 Evaluation Result Flag
CRIT3 Analysis Criterion 3
CRIT3FL Criterion 3 Evaluation Result Flag
CRIT4 Analysis Criterion 4
CRIT4FL Criterion 4 Evaluation Result Flag
CRIT5 Analysis Criterion 5
CRIT5FL Criterion 5 Evaluation Result Flag

CRIT6 Analysis Criterion 6
CRIT6FL Criterion 6 Evaluation Result Flag
CRIT7 Analysis Criterion 7
CRIT7FL Criterion 7 Evaluation Result Flag
CRIT8 Analysis Criterion 8
CRIT8FL Criterion 8 Evaluation Result Flag
DTYPE Derivation Type
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
ONTRTFL On Treatment Record Flag
OESEQ Sequence Number
OECAT Category for Ophthalmic Test or Exam
OESCAT Subcategory for Ophthalmic Test or Exam
OEDTC Date/Time of Collection
VISIT Visit Name
VISITNUM Visit Number
VISITDY Planned Study Day of Visit
OESTRESN Numeric Result/Finding in Standard Units
OESTRESC Character Result/Finding in Std Format
OEORRES Result or Finding in Original Units
OETEST Name of Ophthalmic Test or Exam
OETESTCD Short Name of Ophthalmic Test or Exam
OETSTDTL Ophthalmic Test or Exam Detail
OELAT Laterality
OELOC Location Used for the Measurement
OEDY Study Day of Visit/Collection/Exam
OEMETHOD Method of Test or Examination
OEORRESU Original Units
OESTRESU Standard Units
OESTAT Completion Status
OETPT Planned Time Point Name
OETPTNUM Planned Time Point Number
STUDYEYE Study Eye Location
AFEYE Affected Eye
WORS01FL Worst Post Baseline Obs

**Details**

Contains a set of 4 unique Parameter Codes and Parameters:
PARAMCD
PARAM
FBCVA
Fellow Eye Visual Acuity Score (letters)
FBCVALOG
Fellow Eye Visual Acuity LogMAR Score
SBCVA
Study Eye Visual Acuity Score (letters)
SBCVALOG
Study Eye Visual Acuity LogMAR Score

**Source**

Generated from admiralophtha package (template ad_adbcva.R).

**References**

None

**Examples**

```r
data("adbcva_ophtha")
```

## adce_vaccine

*Clinical Events Analysis for Vaccine*

**Description**

Clinical Events Analysis for Vaccine

**Usage**

```r
```

**Format**

A data frame with 56 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
ASEQ Analysis Sequence Number
AGE Age
AGEU Age Units

SEX Sex
RACE Race
ETHNIC Ethnicity
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
APERSDT Period Start Date
APEREDT Period End Date
APERSTDY Analysis Sub-period Start Relative Day
CESEQ Sequence Number
CETERM Reported Term for the Clinical Event
CEDECOD Dictionary-Derived Term
CECAT Category for the Clinical Event
CESCAT Subcategory for the Clinical Event
CESTDTC Start Date/Time of Clinical Event
ASTDT Analysis Start Date
CEENDTC End Date/Time of Clinical Event
AENDT Analysis End Date
ASTDY Analysis Start Relative Day
AENDY Analysis End Relative Day
ADURN Analysis Duration (N)
ADURU Analysis Duration Units
CEDUR Duration of Clinical Event
APERIOD Period
CEOCCUR Clinical Event Occurrence
CEPRESP Clinical Event Pre-specified
AOCC01FL Event Occurrence Flag
ASEV Analysis Severity/Intensity
ASEVN Analysis Severity/Intensity (N)
AREL Analysis Causality
CELNKID Link ID
CELNKGRP Link Group ID
CELAT Laterality
CELOC Location of Event
CESEV Severity/Intensity
CEREL Causality

CEOUT Outcome of Event
EPOCH Epoch
CEDTC Date/Time of Event Collection
CETPT Planned Time Point Name
CETPTNUM Planned Time Point Number
CETPTREF Time Point Reference
CERFTDTC Date/Time of Reference Time Point
CEEVINTX Evaluation Interval Text
CESTAT Completion Status
CEREASND Reason Clinical Event Not Collected

**Source**

Generated from admiralvaccine package (template ad_adce.R).

**References**

None

**Examples**

```r
data("adce_vaccine")
```

## adcm

*Concomitant Medications Analysis*

**Description**

Concomitant Medications Analysis

**Usage**

```r
```

**Format**

A data frame with 95 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation

RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment

TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Treatment End Datetime Imput Flag
APHASE Phase
APHASEN Description of Phase N
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
CMSEQ Sequence Number
CMDECOD Standardized Medication Name
CMTRT Reported Name of Drug, Med, or Therapy
CMCLAS Medication Class
CMSTDTC Start Date/Time of Medication
ASTDT Analysis Start Date
ASTDTM Analysis Start Date/Time
ASTDTF Analysis Start Date Imputation Flag
ASTTMF Analysis Start Time Imputation Flag
CMENDTC End Date/Time of Medication
AENDT Analysis End Date
AENDTM Analysis End Date/Time
AENDTF Analysis End Date Imputation Flag
AENTMF Analysis End Time Imputation Flag
ASTDY Analysis Start Relative Day
CMSTDY Study Day of Start of Medication
AENDY Analysis End Relative Day
CMENDY Study Day of End of Medication
ADURN Analysis Duration (N)
ADURU Analysis Duration Units
ANL01FL Analysis Flag 01

ONTRTFL On Treatment Record Flag
PREFL Pre-treatment Flag
FUPFL Follow-up Flag
AOCCPFL 1st Occurrence of Preferred Term Flag
CMINDC Indication
CMDOSE Dose per Administration
CMDOSU Dose Units
CMDOSFRQ Dosing Frequency per Interval
CMROUTE Route of Administration
CMSPID Sponsor-Defined Identifier
CMENRTPT End Relative to Reference Time Point
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
CMDTC Date/Time of Collection

**Source**

Generated from admiral package (template ad_adcm.R).

**References**

None

**Examples**

```r
data("adcm")
```

## adcoeq_metabolic

*Questionnaires Analysis for Metabolic*

**Description**

Questionnaires Analysis for Metabolic

**Usage**

```r

```

**Format**

A data frame with 85 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm

ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
AVAL Analysis Value
AVALC Analysis Value (C)
BASE Baseline Value
CHG Change from Baseline
PCHG Percent Change from Baseline
ABLFL Baseline Record Flag
VISIT Visit Name
VISITNUM Visit Number

VISITDY Planned Study Day of Visit
QSBLFL Baseline Flag
QSDTC Date/Time of Finding
QSDY Study Day of Finding
QSCAT Category for Questionnaire
QSTEST Questionnaire Test Name
QSTESTCD Questionnaire Test Short Name
QSORRES Result or Finding in Original Units
QSORRESU Original Units
QSSTRESC Character Result/Finding in Std Format
QSSTRESN Numeric Result/Finding in Standard Units
QSSTRESU Standard Units
QSSEQ Sequence Number

**Details**

Contains a set of 25 unique Parameter Codes and Parameters:
PARAMCD
PARAM
COEQ01
How hungry have you felt?
COEQ02
How full have you felt?
COEQ03
How strong was your desire to eat sweet foods?
COEQ04
How strong was your desire to eat savoury foods?
COEQ05
How happy have you felt?
COEQ06
How anxious have you felt?
COEQ07
How alert have you felt?
COEQ08
How contented have you felt?
COEQ09
During the last 7 days how often have you had food cravings?
COEQ10
How strong have any food cravings been?
COEQ11
How difficult has it been to resist any food cravings?
COEQ12
How often have you eaten in response to food cravings?
COEQ13
Chocolate or chocolate flavoured foods
COEQ14
Other sweet foods (cakes, pastries, biscuits, etc)
COEQ15
Fruit or fruit juice
COEQ16
Dairy foods (cheese, yoghurts, milk, etc)
COEQ17
Starchy foods (bread, rice, pasta, etc)
COEQ18
Savoury foods (french fries, crisps, burgers, pizza, etc)
COEQ19
Generally, how difficult has it been to control your eating?
COEQ20
Which one food makes it most difficult for you to control eating?
COEQ21
How difficult has it been to resist eating this food during the last 7 days?
COEQCRCO
COEQ - Craving Control
COEQCRSA
COEQ - Craving for Savoury
COEQCRSW
COEQ - Craving for Sweet
COEQPOMO
COEQ - Positive Mood

**Source**

Generated from admiralmetabolic package (template ad_adcoeq.R).

**References**

None

**Examples**

```r
data("adcoeq_metabolic")
```

## adeg

*Electrocardiogram Tests Analysis*

**Description**

Electrocardiogram Tests Analysis

**Usage**

```r
```

**Format**

A data frame with 108 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death

LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)

DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADTM Analysis Datetime
ADY Analysis Relative Day
ATMF Analysis Time Imputation Flag
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
AVAL Analysis Value
AVALC Analysis Value (C)
AVALCAT1 Analysis Value Category 1
AVALCA1N Analysis Value Category 1 (N)
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
CHGCAT1 Change from Baseline Category 1
CHGCAT1N Change from Baseline Category 1 (N)
PCHG Percent Change from Baseline
DTYPE Derivation Type
ANRIND Analysis Reference Range Indicator
BNRIND Baseline Reference Range Indicator
ANRLO Analysis Normal Range Lower Limit
ANRHI Analysis Normal Range Upper Limit
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ONTRTFL On Treatment Record Flag
EGSEQ Sequence Number
EGTESTCD ECG Test or Examination Short Name
EGTEST ECG Test or Examination Name

EGORRES Result or Finding in Original Units
EGORRESU Original Units
EGSTRESC Character Result/Finding in Std Format
EGSTRESN Numeric Result/Finding in Standard Units
EGSTRESU Standard Units
EGSTAT Completion Status
EGLOC Lead Location Used for Measurement
EGBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EGDTC Date/Time of ECG
EGDY Study Day of ECG
EGTPT Planned Time Point Name
EGTPTNUM Planned Time Point Number
EGELTM Planned Elapsed Time from Time Point Ref
EGTPTREF Time Point Reference

**Details**

Contains a set of 8 unique Parameter Codes and Parameters:
PARAMCD
PARAM
EGINTP
ECG Interpretation
HR
Heart Rate (beats/min)
QT
QT Duration (ms)
QTCBR
QTcB - Bazett’s Correction Formula Rederived (ms)
QTCFR
QTcF - Fridericia’s Correction Formula Rederived (ms)
QTLCR
QTlc - Sagie’s Correction Formula Rederived (ms)
RR
RR Duration (ms)
RRR
RR Duration Rederived (ms)

**Source**

Generated from admiral package (template ad_adeg.R).

**References**

None

**Examples**

```r
data("adeg")
```

## adex

*Exposure Analysis*

**Description**

Exposure Analysis

**Usage**

```r
```

**Format**

A data frame with 92 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection

DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
EXTRT Name of Treatment
EXDOSE Dose
EXDOSFRM Dose Form
EXDOSFRQ Dosing Frequency per Interval
EXROUTE Route of Administration
EXADJ Reason for Dose Adjustment

EXSTDTC Start Date/Time of Treatment
EXENDTC End Date/Time of Treatment
EXSTDY Study Day of Start of Treatment
EXENDY Study Day of End of Treatment
EXSEQ Sequence Number
ASTDT Analysis Start Date
AENDT Analysis End Date
EXDURD Duration of Treatment (Days)
EXDOSU Dose Units
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EXPLDOS Planned Dose
ASTDTM Analysis Start Datetime
ASTDTF Analysis Start Date Imputation Flag
ASTTMF Analysis Start Time Imputation Flag
AENDTM Analysis End Datetime
AENDTF Analysis End Date Imputation Flag
AENTMF Analysis End Time Imputation Flag
ASTDY Analysis Start Relative Day
AENDY Analysis End Relative Day
DOSEO Dose O
PDOSEO PDose O
PARAMCD Parameter Code
AVAL Analysis Value
AVALC Analysis Value (C)
PARCAT1 Parameter Category 1
PARAM Parameter
PARAMN Parameter (N)
AVALCAT1 Analysis Value Category 1

**Details**

Contains a set of 19 unique Parameter Codes and Parameters:
PARAMCD
PARAM
ADJ
Dose adjusted during constant dosing interval
ADJAE
Dose adjusted due to AE during constant dosing interval
AVDDSE
Average daily dose administered (mg/mg)

DOSE
Dose administered during constant dosing interval (mg)
DURD
Study drug duration during constant dosing interval (days)
PADJ
Dose adjusted during W2-W24
PADJAE
Dose adjusted in W2-W24 due to AE
PAVDDSE
Average daily dose administered in W2-W24 (mg)
PDOSE
Total dose administered in W2-W2 (mg)4
PDOSINT
W2-24 dose intensity (%)
PDURD
Overall duration in W2-W24 (days)
PLDOSE
Planned dose during constant dosing interval (mg)
PPDOSE
Total planned dose in W2-W24 (mg)
TADJ
Dose adjusted during study
TADJAE
Dose adjusted during study due to AE
TDOSE
Total dose administered (mg)
TDOSINT
Overall dose intensity (%)
TDURD
Overall duration (days)
TPDOSE
Total planned dose (mg)

**Source**

Generated from admiral package (template ad_adex.R).

**References**

None

**Examples**

```r
data("adex")
```

## adface_vaccine

*Findings About Clinical Events Analysis*

**Description**

Findings About Clinical Events Analysis

**Usage**

```r
```

**Format**

A data frame with 61 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study

SITEID Study Site Identifier
AGE Age
AGEU Age Units
SEX Sex
RACE Race
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRT02P Planned Treatment for Period 02
TRT02A Actual Treatment for Period 02
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
APERSDT Period Start Date
APEREDT Period End Date
ADT Analysis Date
ADTM Analysis Datetime
ADY Analysis Relative Day
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
ATPTREF Analysis Timepoint Reference
APERIOD Period
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
PARCAT2 Parameter Category 2
AVAL Analysis Value
AVALC Analysis Value (C)
ANL01FL Analysis Flag 01

ANL02FL Analysis Flag 02
ANL03FL Analysis Flag 03
FATEST Findings About Test Name
FALNKID Link ID
FALNKGRP Link Group ID
FATESTCD Findings About Test Short Name
FAOBJ Object of the Observation
FASTAT Completion Status
FAREASND Reason Not Performed
FAEVAL Evaluator
EPOCH Epoch
FAEVINTX Evaluation Interval Text
EXDOSE Dose
EXTRT Name of Treatment
EXSTDTC Start Date/Time of Treatment
EXENDTC End Date/Time of Treatment
FAORRES Result or Finding in Original Units
VAX01DT Vaccination Date 01
VAX02DT Vaccination Date 02
EVENTFL Event Value Flag
EVENTDFL Day Event Value Flag

**Details**

Contains a set of 30 unique Parameter Codes and Parameters:
PARAMCD
PARAM
DIARE
Redness diameter deltoid muscle left
DIASWEL
Swelling diameter deltoid muscle left
MAXREDN
Redness maximum severity deltoid muscle left
MAXSFAT
Fatigue maximum severity
MAXSHEA
Headache maximum severity
MAXSPIS
Pain at injection site maximum severity deltoid muscle left
MAXSWEL
Swelling maximum severity deltoid muscle left
MAXTEMP
Fever maximum temperature
MDIRE
Redness maximum diameter deltoid muscle left
MDISW
Swelling maximum diameter deltoid muscle left
MSEVNWJP
New or worsened joint pain maximum severity
MSEVNWMP
New or worsened muscle pain maximum severity
OCCHILLS
Chills occurrence indicator
OCCNWJP
New or worsened joint pain occurrence indicator
OCCNWMP
New or worsened muscle pain occurrence indicator

OCCVOM
Vomiting occurrence indicator
OCDIAR
Diarrhea occurrence indicator
OCFATIG
Fatigue occurrence indicator
OCFEVER
Fever occurrence indicator
OCHEAD
Headache occurrence indicator
OCINS
Swelling occurrence indicator deltoid muscle left
OCISR
Redness occurrence indicator deltoid muscle left
OCPIS
Pain at injection site occurrence indicator deltoid muscle left
SEVFAT
Fatigue severity/intensity
SEVHEAD
Headache severity/intensity
SEVNWJP
New or worsened joint pain severity/intensity
SEVNWMP
New or worsened muscle pain severity/intensity
SEVPIS
Pain at injection site severity/intensity deltoid muscle left
SEVREDN
Redness severity/intensity deltoid muscle left
SEVSWEL
Swelling severity/intensity deltoid muscle left

**Source**

Generated from admiralvaccine package (template ad_adface.R).

**References**

None

**Examples**

```r
data("adface_vaccine")
```

## adis_vaccine

*Immunogenicity Specimen Assessments*

**Description**

Immunogenicity Specimen Assessments

**Usage**

```r
```

**Format**

A data frame with 103 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier

COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
REGION1 Geographic Region 1
BRTHDTC Date/Time of Birth
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
PPROTFL Per-Protocol Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRT02P Planned Treatment for Period 02
TRT02A Actual Treatment for Period 02
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
AP01SDT Period 01 Start Date

AP01EDT Period 01 End Date
AP02SDT Period 02 Start Date
AP02EDT Period 02 End Date
APERSDT Period Start Date
APEREDT Period End Date
RFICDTC Date/Time of Informed Consent
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
ATPTREF Analysis Timepoint Reference
APERIOD Period
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
AVAL Analysis Value
AVALU Analysis Value Unit
BASE Baseline Value
BASECAT1 Baseline Category 1
BASETYPE Baseline Type
CHG Change from Baseline
R2BASE Ratio to Baseline
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
CRIT1FN Criterion 1 Evaluation Result Flag (N)
DTYPE Derivation Type
ABLFL Baseline Record Flag
ISSEQ Sequence Number
ISTESTCD Immunogenicity Test/Exam Short Name
ISTEST Immunogenicity Test or Examination Name
ISCAT Category for Immunogenicity Test
ISORRES Results or Findings in Original Units
ISORRESU Original Units
ISSTRESC Character Result/Finding in Std Format

ISSTRESN Numeric Results/Findings in Std. Units
ISSTRESU Standard Units
ISSTAT Completion Status
ISREASND Reason Not Done
ISNAM Vendor Name
ISSPEC Specimen Type
ISMETHOD Method of Test or Examination
ISBLFL Baseline Flag
ISLLOQ Lower Limit of Quantitation
VISITNUM Visit Number
EPOCH Epoch
ISDTC Date/Time of Collection
ISDY Study Day of Visit/Collection/Exam
ISULOQ Upper Limit of Quantitation
LOD Limit of Detection
DERIVED Derivation Method
CUTOFF02 First Cutoff Value
CUTOFF03 Second Cutoff Value
SERCAT1 Pre-vaccination seropositivity status
SERCAT1N Pre-vaccination sero status (n)
PPSRFL Per-Protocol Record-Level Flag
INVID Investigator Identifier
INVNAM Investigator Name
VAX01DT Vaccination Date 01
VAX02DT Vaccination Date 02

**Details**

Contains a set of 16 unique Parameter Codes and Parameters:
PARAMCD
PARAM
I0019NLF
LOG10 4FOLD (I0019NT Antibody)
I0019NT
I0019NT Antibody
I0019NTF
4FOLD (I0019NT Antibody)
I0019NTL
LOG10 (I0019NT Antibody)
J0033VLF
LOG10 4FOLD (J0033VN Antibody)
J0033VN
J0033VN Antibody
J0033VNF
4FOLD (J0033VN Antibody)
J0033VNL
LOG10 (J0033VN Antibody)
M0019LLF
LOG10 4FOLD (M0019LN Antibody)
M0019LN
M0019LN Antibody

M0019LNF
4FOLD (M0019LN Antibody)
M0019LNL
LOG10 (M0019LN Antibody)
R0003MA
R0003MA Antibody
R0003MAF
4FOLD (R0003MA Antibody)
R0003MAL
LOG10 (R0003MA Antibody)
R0003MLF
LOG10 4FOLD (R0003MA Antibody)

**Source**

Generated from admiralvaccine package (template ad_adis.R).

**References**

None

**Examples**

```r
data("adis_vaccine")
```

## adlb

*Laboratory Analysis*

**Description**

Laboratory Analysis

**Usage**

```r
```

**Format**

A data frame with 115 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation

SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag

EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
AVAL Analysis Value
AVALC Analysis Value (C)
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
R2BASE Ratio to Baseline
R2ANRLO Ratio of Analysis Val compared to ANRLO
R2ANRHI Ratio of Analysis Val compared to ANRHI
SHIFT1 Shift from Baseline to Analysis Value
SHIFT2 Shift from Baseline to Overall Grade
DTYPE Derivation Type
ATOXGR Analysis Toxicity Grade
BTOXGR Baseline Toxicity Grade
ANRIND Analysis Reference Range Indicator
BNRIND Baseline Reference Range Indicator
ANRLO Analysis Normal Range Lower Limit
ANRHI Analysis Normal Range Upper Limit

ATOXGRL Analysis Toxicity Grade Low
ATOXGRH Analysis Toxicity Grade High
BTOXGRL Baseline Toxicity Grade Low
BTOXGRH Baseline Toxicity Grade High
ATOXDSCL Analysis Toxicity Description Low
ATOXDSCH Analysis Toxicity Description High
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ONTRTFL On Treatment Record Flag
LVOTFL Last Value On Treatment Record Flag
LBSEQ Sequence Number
LBTESTCD Lab Test or Examination Short Name
LBTEST Lab Test or Examination Name
LBCAT Category for Lab Test
LBORRES Result or Finding in Original Units
LBORRESU Original Units
LBORNRLO Reference Range Lower Limit in Orig Unit
LBORNRHI Reference Range Upper Limit in Orig Unit
LBSTRESC Character Result/Finding in Std Format
LBSTRESN Numeric Result/Finding in Standard Units
LBSTRESU Standard Units
LBSTNRLO Reference Range Lower Limit-Std Units
LBSTNRHI Reference Range Upper Limit-Std Units
LBNRIND Reference Range Indicator
LBBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
LBDTC Date/Time of Specimen Collection
LBDY Study Day of Specimen Collection

**Details**

Contains a set of 47 unique Parameter Codes and Parameters:
PARAMCD
PARAM
ALB
Albumin (g/L)
ALKPH
Alkaline Phosphatase (U/L)
ALT
Alanine Aminotransferase (U/L)

ANISO
Anisocytes
AST
Aspartate Aminotransferase (U/L)
BASO
Basophils Abs (10^9/L)
BASOLE
Basophils/Leukocytes (FRACTION)
BILI
Bilirubin (umol/L)
BUN
Blood Urea Nitrogen (mmol/L)
CA
Calcium (mmol/L)
CHOLES
Cholesterol (mmol/L)
CK
Creatinine Kinase (U/L)
CL
Chloride (mmol/L)
COLOR
Color
CREAT
Creatinine (umol/L)
EOS
Eosinophils (10^9/L)
EOSLE
Eosinophils/Leukocytes (FRACTION)
GGT
Gamma Glutamyl Transferase (U/L)
GLUC
Glucose (mmol/L)
HBA1C
Hemoglobin A1C (1)
HCT
Hematocrit (1)
HGB
Hemoglobin (mmol/L)
KETON
Ketones
LYMPH
Lymphocytes Abs (10^9/L)
LYMPHLE
Lymphocytes/Leukocytes (FRACTION)
MACROC
Macrocytes
MCH
Ery. Mean Corpuscular Hemoglobin (fmol(Fe))
MCHC
Ery. Mean Corpuscular HGB Concentration (mmol/L)
MCV
Ery. Mean Corpuscular Volume (f/L)
MICROC
Microcytes
MONO
Monocytes (10^9/L)
MONOLE
Monocytes/Leukocytes (FRACTION)
PH
pH
PHOS
Phosphate (mmol/L)
PLAT
Platelet (10^9/L)
POIKIL
Poikilocytes
POLYCH
Polychromasia
POTAS
Potassium (mmol/L)
PROT
Protein (g/L)
RBC
Erythrocytes (TI/L)
SODIUM
Sodium (mmol/L)
SPGRAV
Specific Gravity
TSH
Thyrotropin (mU/L)
URATE
Urate (umol/L)
UROBIL
Urobilinogen
VITB12
Vitamin B12 (pmol/L)
WBC
Leukocytes (10^9/L)

**Source**

Generated from admiral package (template ad_adlb.R).

**References**

None

**Examples**

```r
data("adlb")
```

## adlbhy

*Analysis of Lab Hy’s Law*

**Description**

Analysis of Lab Hy’s Law

**Usage**

```r
```

**Format**

A data frame with 14 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
TRT01A Actual Treatment for Period 01
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
PARAM Parameter
PARAMCD Parameter Code
AVAL Analysis Value
AVALC Analysis Value (C)
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
ANRHI Analysis Normal Range Upper Limit
LBSEQ Sequence Number

**Details**

Contains a set of 4 unique Parameter Codes and Parameters:
PARAMCD
PARAM
ALT
Alanine Aminotransferase (U/L)
AST
Aspartate Aminotransferase (U/L)
BILI
Bilirubin (umol/L)
HYSLAW
ALT/AST >= 3xULN and BILI >= 2xULN

**Source**

Generated from admiral package (template ad_adlbhy.R).

**References**

None

**Examples**

```r
data("adlbhy")
```

## adlb_metabolic

*Laboratory Analysis for Metabolic*

**Description**

Laboratory Analysis for Metabolic

**Usage**

```r
```

**Format**

A data frame with 43 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ADT Analysis Date
ADY Analysis Relative Day

AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
PARCAT2 Parameter Category 2
AVAL Analysis Value
AVALC Analysis Value (C)
ANRLO Analysis Normal Range Lower Limit
ANRHI Analysis Normal Range Upper Limit
LBSEQ Sequence Number
LBTESTCD Lab Test or Examination Short Name
LBTEST Lab Test or Examination Name
LBCAT Category for Lab Test
LBORRES Result or Finding in Original Units
LBORRESU Original Units
LBORNRLO Reference Range Lower Limit in Orig Unit
LBORNRHI Reference Range Upper Limit in Orig Unit
LBSTRESC Character Result/Finding in Std Format
LBSTRESN Numeric Result/Finding in Standard Units
LBSTRESU Standard Units
LBSTNRLO Reference Range Lower Limit-Std Units
LBSTNRHI Reference Range Upper Limit-Std Units
LBNRIND Reference Range Indicator
LBBLFL Baseline Flag
LBFAST Fasting Status
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
LBDTC Date/Time of Specimen Collection
LBDY Study Day of Specimen Collection
BMI Body Mass Index (kg/m2)
WSTCIR Waist Circumference (cm)

**Details**

Contains a set of 11 unique Parameter Codes and Parameters:
PARAMCD
PARAM
ALB
Albumin (g/L)
ALKPH
Alkaline Phosphatase (U/L)
AST
Aspartate Aminotransferase (U/L)
CHOLES
Cholesterol (mmol/L)
FLI
Fatty Liver Index
GGT
Gamma Glutamyl Transferase (U/L)
GLUC
Glucose (mmol/L)
HBA1CHGB
Hemoglobin A1C/Hemoglobin (mmol/mol)
HOMAIR
Homeostasis Model Assessment - Insulin Resistance
INSULIN
Insulin (mIU/L)
TRIG
Triglycerides (mg/dL)

**Source**

Generated from admiralmetabolic package (template ad_adlb.R).

**References**

None

**Examples**

```r
data("adlb_metabolic")
```

## admh

*Medical History Analysis*

**Description**

Medical History Analysis

**Usage**

```r
```

**Format**

A data frame with 114 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier

COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01

TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Treatment End Datetime Imput Flag
APHASE Phase
APHASEN Description of Phase N
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
MHSEQ Sequence Number
MHTERM Reported Term for the Medical History
MHTERMN Medical History Term (N)
MHDECOD Dictionary-Derived Term
MHBODSYS Body System or Organ Class
MHLLT Lowest Level Term
MHHLT High Level Term
MHHLGT High Level Group Term
MHCAT Category for Medical History
MHSTDTC Start Date/Time of Medical History Event
ASTDT Analysis Start Date
MHENDTC End Date/Time of Medical History Event
AENDT Analysis End Date
ASTDY Analysis Start Relative Day
AENDY Analysis End Relative Day
MHOCCUR Medical History Occurrence
MHPRESP Medical History Event Pre-Specified
ANL01FL Analysis Flag 01
AOCCFL 1st Occurrence within Subject Flag

AOCCPFL 1st Occurrence of Preferred Term Flag
AOCCSFL 1st Occurrence of SOC Flag
MHSPID Sponsor-Defined Identifier
MHSEV Severity/Intensity
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
MHDTC Date/Time of History Collection
MHDY Study Day of History Collection
MHSTRTPT Start Relative to Reference Time Point
MHENRTPT End Relative to Reference Time Point
MHSTTPT Start Reference Time Point
MHENTPT End Reference Time Point
MHENRF End Relative to Reference Period
MHSTAT Completion Status
ADT Analysis Date
ADY Analysis Relative Day
SMQ02NAM SMQ 02 Name
SMQ02CD SMQ 02 Code
SMQ02SC SMQ 02 Scope
SMQ02SCN SMQ 02 Scope (N)
SMQ03NAM SMQ 03 Name
SMQ03CD SMQ 03 Code
SMQ03SC SMQ 03 Scope
SMQ03SCN SMQ 03 Scope (N)
SMQ05NAM SMQ 05 Name
SMQ05CD SMQ 05 Code
SMQ05SC SMQ 05 Scope
SMQ05SCN SMQ 05 Scope (N)
CQ01NAM Customized Query 01 Name
CQ04NAM Customized Query 04 Name
CQ04CD Customized Query 04 Code
AHIST Response of Med Hx (past or current)
AOCPFL 1st Occur w/in Trt Prd FL
AOCPSFL 1st Occur of SOC w/in Trt Prd FL
AOCPPFL 1st Occur of PT w/in Trt Prd FL

**Source**

Generated from admiral package (template ad_admh.R).

**References**

None

**Examples**

```r
data("admh")
```

## adnv_neuro

*Nervous System Analysis Dataset*

**Description**

Nervous System Analysis Dataset

**Usage**

```r
```

**Format**

A data frame with 43 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
ASEQ Analysis Sequence Number
AGE Age
SEX Sex
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAMN Parameter (N)
PARAM Parameter
PARAMCD Parameter Code

AVAL Analysis Value
BASE Baseline Value
BASETYPE Baseline Type
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
NVSEQ Sequence Number
NVLNKID Link ID
NVTESTCD Short Name of Nervous System Test
NVTEST Name of Nervous System Test
NVCAT Category for Nervous System Test
NVLOC Location Used for the Measurement
NVNAM Vendor Name
NVORRES Result or Finding in Original Units
NVORRESU Original Units
NVSTRESC Character Result/Finding in Std Format
NVSTRESN Numeric Result/Finding in Standard Units
NVSTRESU Standard Units
NVMETHOD Method of Test or Examination
NVLOBXFL Last Observation Before Exposure Flag
VISITNUM Visit Number
VISIT Visit Name
NVDTC Date/Time of Collection
NVDY Study Day of Visit/Collection/Exam

**Details**

Contains a set of 2 unique Parameter Codes and Parameters:
PARAMCD
PARAM
UPSITPC
Percentile derived from UPSIT total score
UPSITTS
UPSIT Combined Score from 40 Odorant

**Source**

Generated from admiralneuro package (template ad_adnv.R).

**References**

None

## adoe_ophtha

*Examples data("adnv_neuro") adoe_ophtha Exam Analysis for Ophthalmology*

**Description**

Exam Analysis for Ophthalmology

**Usage**

```r
```

**Format**

A data frame with 103 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag

ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit

AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
AVAL Analysis Value
AVALC Analysis Value (C)
AVALU Analysis Value Unit
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
DTYPE Derivation Type
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
ONTRTFL On Treatment Record Flag
OESEQ Sequence Number
OECAT Category for Ophthalmic Test or Exam
OESCAT Subcategory for Ophthalmic Test or Exam
OEDTC Date/Time of Collection
VISIT Visit Name
VISITNUM Visit Number
VISITDY Planned Study Day of Visit
OESTRESN Numeric Result/Finding in Standard Units
OESTRESC Character Result/Finding in Std Format
OEORRES Result or Finding in Original Units
OETEST Name of Ophthalmic Test or Exam
OETESTCD Short Name of Ophthalmic Test or Exam
OETSTDTL Ophthalmic Test or Exam Detail
OELAT Laterality
OELOC Location Used for the Measurement
OEDY Study Day of Visit/Collection/Exam
OEMETHOD Method of Test or Examination
OEORRESU Original Units

OESTRESU Standard Units
OESTAT Completion Status
OETPT Planned Time Point Name
OETPTNUM Planned Time Point Number
STUDYEYE Study Eye Location
AFEYE Affected Eye
WORS01FL Worst Post Baseline Obs

**Details**

Contains a set of 8 unique Parameter Codes and Parameters:
PARAMCD
PARAM
FCSUBTH
Fellow Eye Center Subfield Thickness (um)
FDRSSR
Fellow Eye Diabetic Retinopathy Severity
FIOP
Fellow Eye IOP (mmHg)
FIOPCHG
Fellow Eye IOP Pre to Post Dose Diff (mmHg)
SCSUBTH
Study Eye Center Subfield Thickness (um)
SDRSSR
Study Eye Diabetic Retinopathy Severity
SIOP
Study Eye IOP (mmHg)
SIOPCHG
Study Eye IOP Pre to Post Dose Diff (mmHg)

**Source**

Generated from admiralophtha package (template ad_adoe.R).

**References**

None

**Examples**

```r
data("adoe_ophtha")
```

## adpc

*Pharmacokinetic Concentrations*

**Description**

Pharmacokinetic Concentrations

**Usage**

```r

```

**Format**

A data frame with 128 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Under 30 Group
DTHA30FL Over 30 Group
DTHDOM Domain for Date of Death Collection
DTHB30FL Over 30 plus 30 days Group
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code

ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
DOSEP Planned Treatment Dose
DOSEA Actual Treatment Dose
DOSEU Treatment Dose Units
ADT Analysis Date
ATM Analysis Time
ADTM Analysis Datetime
ADY Analysis Relative Day
ATMF Analysis Time Imputation Flag
ASTDT Analysis Start Date
ASTTM Analysis Start Time
ASTDTM Analysis Start Datetime
AENDT Analysis End Date
AENTM Analysis End Time
AENDTM Analysis End Datetime
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint

ATPTN Analysis Timepoint (N)
ATPTREF Analysis Timepoint Reference
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
AVAL Analysis Value
AVALU Analysis Value Unit
AVALCAT1 Analysis Value Category 1
BASE Baseline Value
BASETYPE Baseline Type
CHG Change from Baseline
DTYPE Derivation Type
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
SRCDOM Source Data
SRCVAR Source Variable
SRCSEQ Source Sequence Number
NFRLT Nom. Rel. Time from Analyte First Dose
PCTESTCD Pharmacokinetic Test Short Name
PCTEST Pharmacokinetic Test Name
PCORRES Result or Finding in Original Units
PCORRESU Original Units
PCSTRESC Character Result/Finding in Std Format
PCSTRESN Numeric Result/Finding in Standard Units
PCSTRESU Standard Units
PCNAM Vendor Name
PCSPEC Specimen Material Type
PCLLOQ Lower Limit of Quantitation
VISIT Visit Name
VISITNUM Visit Number
VISITDY Planned Study Day of Visit
PCDTC Date/Time of Specimen Collection
PCDY Actual Study Day of Specimen Collection
PCTPT Planned Time Point Name
PCTPTNUM Planned Time Point Number

FANLDTM First Datetime of Dose for Analyte
AFRLT Act. Rel. Time from Analyte First Dose
ARRLT Actual Rel. Time from Ref. Dose
PCRFTDTM Reference Datetime of Dose for Analyte
FANLDT First Date of Dose for Analyte
FANLTM First Time of Dose for Analyte
PCRFTDT Reference Date of Dose for Analyte
PCRFTTM Reference Time of Dose for Analyte
NRRLT Nominal Rel. Time from Ref. Dose
FRLTU Rel. Time from First Dose Unit
RRLTU Rel. Time from Ref. Dose Unit
ALLOQ Analysis Lower Limit of Quantitation
MRRLT Modified Rel. Time from Ref. Dose
HTBL Numeric Result/Finding in Standard Units
HTBLU Standard Units
WTBL Numeric Result/Finding in Standard Units
WTBLU Standard Units
BMIBL Baseline Body Mass Index (kg/m2)
BMIBLU BMI at Baseline (Unit)

**Details**

Contains a set of 2 unique Parameter Codes and Parameters:
PARAMCD
PARAM
DOSE
Xanomeline Patch Dose
XAN
Pharmacokinetic concentration of Xanomeline

**Source**

Generated from admiral package (template ad_adpc.R).

**References**

None

**Examples**

```r
data("adpc")
```

## adpp

*Pharmacokinetic Parameters*

**Description**

Pharmacokinetic Parameters

**Usage**

```r
```

**Format**

A data frame with 79 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age

AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAMCD Parameter Code
AVAL Numeric Result/Finding in Standard Units

AVALCAT1 Analysis Value Category 1
AVALCA1N Analysis Value Category 1 (N)
SRCDOM Domain Abbreviation
SRCVAR Source Variable
SRCSEQ Sequence Number
PPTESTCD Parameter Short Name
PPTEST Parameter Name
PPCAT Parameter Category
PPORRES Result or Finding in Original Units
PPORRESU Original Units
PPSTRESU Standard Units
PPSPEC Specimen Material Type
PPRFDTC Date/Time of Reference Point
VISIT Visit Name
VISITNUM Visit Number
PARCAT1 Parameter Category
AVALU Standard Units

**Source**

Generated from admiral package (template ad_adpp.R).

**References**

None

**Examples**

```r
data("adpp")
```

## adppk

*Population Pharmacokinetic*

**Description**

Population Pharmacokinetic

**Usage**

```r

```

**Format**

A data frame with 61 columns:
PROJID Project Identifier
PROJIDN Project Identifier (N)
STUDYID Study Identifier
STUDYIDN Study Identifier (N)
USUBJID Unique Subject Identifier
USUBJIDN Unique Subject Identifier (N)
SUBJID Subject Identifier for the Study
SUBJIDN Subject Identifier for the Study (N)
SITEID Study Site Identifier
SITEIDN Study Site Identifier (N)
RECSEQ Record Sequence
AFRLT Act. Rel. Time from Analyte First Dose
APRLT Actual Rel Time from Previous Dose
NFRLT Nom. Rel. Time from Analyte First Dose
NPRLT Nominal Rel Time from Previous Dose
EVID Event ID
CMT Compartment
DV Dependent Variable Result
PARAMCD Parameter Code
PARAM Parameter
PARAMN Parameter (N)
ASEQ Analysis Sequence Number
AVAL Analysis Value
AVALU Analysis Value Unit
MDV Missing Dependent Variable Result
ALLOQ Analysis Lower Limit of Quantitation
BLQFL Below Lower Limit of Quant Flag
BLQFN Below Lower Limit of Quant Flag (N)
AMT Actual Amount of Dose Received (unit)
DOSEA Actual Treatment Dose
II Dosing Interval (unit)
SS Steady State
FORM Drug Formulation
FORMN Drug Formulation (N)
ROUTE Route of Administration

ROUTEN Route of Administration (N)
COHORT Cohort Subject Enrolled Into
COHORTC Description of Planned Arm
UDTC Date/Time
WTBL Numeric Result/Finding in Standard Units
HTBL Numeric Result/Finding in Standard Units
BMIBL Baseline Body Mass Index (kg/m2)
BSABL Numeric Result/Finding in Standard Units
AGE Age
SEX Sex
SEXN Sex (N)
RACE Race
RACEN Race (N)
ETHNIC Ethnicity
ETHNICN Ethnicity (N)
COUNTRY Country
COUNTRYL Country Name
COUNTRYN Country (N)
CREATBL Numeric Result/Finding in Standard Units
CRCLBL Baseline Creatinine Clearance
EGFRBL Age
TBILBL Numeric Result/Finding in Standard Units
ASTBL Numeric Result/Finding in Standard Units
ALTBL Numeric Result/Finding in Standard Units
DOSEP Planned Treatment Dose
DVL Log DV

**Details**

Contains a set of 2 unique Parameter Codes and Parameters:
PARAMCD
PARAM
DOSE
Xanomeline Patch Dose
XAN
Pharmacokinetic concentration of Xanomeline

**Source**

Generated from admiral package (template ad_adppk.R).

**References**

None

## adrs_onco

*Examples data("adppk") adrs_onco Tumor Response Analysis*

**Description**

Tumor Response Analysis

**Usage**

```r
```

**Format**

A data frame with 79 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag

ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADTF Analysis Date Imputation Flag
AVISIT Analysis Visit
PARAM Parameter

PARAMCD Parameter Code
PARCAT1 Parameter Category 1
PARCAT2 Parameter Category 2
PARCAT3 Parameter Category 3
AVAL Analysis Value
AVALC Analysis Value (C)
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
VISITNUM Visit Number
VISIT Visit Name
RSTESTCD Assessment Short Name
RSTEST Assessment Name
RSORRES Result or Finding in Original Units
RSSTRESC Character Result/Finding in Std Format
RSEVAL Evaluator
RSEVALID Evaluator Identifier
RSACPTFL Accepted Record Flag
RSDTC Date/Time of Assessment
RSSEQ Sequence Number
DTHDTF Date of Death Imputation Flag

**Details**

Contains a set of 13 unique Parameter Codes and Parameters:
PARAMCD
PARAM
BCP
Best Overall Response of CR/PR by Investigator (confirmation not required)
BOR
Best Overall Response by Investigator (confirmation not required)
CB
Clinical Benefit by Investigator (confirmation for response not required)
CBCP
Best Confirmed Overall Response of CR/PR by Investigator
CBOR
Best Confirmed Overall Response by Investigator
CCB
Confirmed Clinical Benefit by Investigator
CRSP
Confirmed Response by Investigator
DEATH
Death
LSTA
Last Disease Assessment by Investigator
MDIS
Measurable Disease at Baseline by Investigator
OVR
Overall Response by Investigator
PD
Disease Progression by Investigator
RSP
Response by Investigator (confirmation not required)

**Source**

Generated from admiralonco package (template ad_adrs.R).

**References**

None

**Examples**

```r
data("adrs_onco")
```

## adsl

*Subject Level Analysis*

**Description**

Subject Level Analysis

**Usage**

```r
```

**Format**

A data frame with 55 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag

DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
BRTHDTC Date/Time of Birth

**Source**

Generated from admiral package (template ad_adsl.R).

**References**

None

**Examples**

```r
data("adsl")
```

## adsl_vaccine

*Subject Level Analysis for Vaccine*

**Description**

Subject Level Analysis for Vaccine

**Usage**

```r
```

**Format**

A data frame with 46 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country/Region
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
REGION1 Geographic Region 1
BRTHDTC Date/Time of Birth
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age

AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
PPROTFL Per-Protocol Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRT02P Planned Treatment for Period 02
TRT02A Actual Treatment for Period 02
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
AP01SDT Period 01 Start Date
AP01EDT Period 01 End Date
AP02SDT Period 02 Start Date
AP02EDT Period 02 End Date
RFICDTC Date/Time of Informed Consent
INVID Investigator Identifier
INVNAM Investigator Name
VAX01DT Vaccination Date 01
VAX02DT Vaccination Date 02

**Source**

Generated from admiralvaccine package (template ad_adsl.R).

**References**

None

**Examples**

```r
data("adsl_vaccine")
```

## adtpet_neuro

*Tau PET Scan Analysis Dataset*

**Description**

Tau PET Scan Analysis Dataset

**Usage**

```r
```

**Format**

A data frame with 46 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
ASEQ Analysis Sequence Number
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTEDT Date of Last Exposure to Treatment
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code
AVAL Analysis Value
AVALC Analysis Value (C)
BASE Baseline Value
BASEC Baseline Value (C)
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
ONTRTFL On Treatment Record Flag

NVSEQ Sequence Number
NVLNKID Link ID
NVTESTCD Short Name of Nervous System Test
NVTEST Name of Nervous System Test
NVCAT Category for Nervous System Test
NVLOC Location Used for the Measurement
NVNAM Vendor Name
NVORRES Result or Finding in Original Units
NVORRESU Original Units
NVSTRESC Character Result/Finding in Std Format
NVSTRESN Numeric Result/Finding in Standard Units
NVSTRESU Standard Units
NVMETHOD Method of Test or Examination
NVLOBXFL Last Observation Before Exposure Flag
REFREG Reference Region
AGTRT Reported Agent Name
AGCAT Category for Agent
VISITNUM Visit Number
VISIT Visit Name
NVDTC Date/Time of Collection
NVDY Study Day of Visit/Collection/Exam

**Details**

Contains a set of 2 unique Parameter Codes and Parameters:
PARAMCD
PARAM
SUVRAFTP
AVID FTP Standard Uptake Ratio Neocortical Composite Inferior Cerebellar Gray Matter
SUVRBFTP
BERKELEY FTP Standard Uptake Ratio Neocortical Composite Inferior Cerebellar Gray Matter

**Source**

Generated from admiralneuro package (template ad_adtpet.R).

**References**

None

**Examples**

```r
data("adtpet_neuro")
```

## adtr_onco

*Tumor Results Analysis for Oncology*

**Description**

Tumor Results Analysis for Oncology

**Usage**

```r
```

**Format**

A data frame with 99 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection

DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
PDFL Pharmacodynamic Analysis Set Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
ADTF Analysis Date Imputation Flag
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter

PARAMCD Parameter Code
PARCAT1 Parameter Category 1
PARCAT2 Parameter Category 2
PARCAT3 Parameter Category 3
AVAL Analysis Value
BASE Baseline Value
CHG Change from Baseline
PCHG Percent Change from Baseline
NADIR NADIR
CHGNAD Change from NADIR
PCHGNAD Percent Change from NADIR
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ANL02FL Analysis Flag 02
ANL03FL Analysis Flag 03
ANL04FL Analysis Flag 04
TRSEQ Sequence Number
TRGRPID Group ID
TRLNKID Link ID
TRTESTCD Tumor/Lesion Assessment Short Name
TRTEST Tumor/Lesion Assessment Test Name
TRORRES Result or Finding in Original Units
TRORRESU Original Units
TRSTRESC Character Result/Finding in Std Format
TRSTRESN Numeric Result/Finding in Standard Units
TRSTRESU Standard Units
TREVAL Evaluator
TREVALID Evaluator Identifier
TRACPTFL Accepted Record Flag
VISITNUM Visit Number
VISIT Visit Name
TRDTC Date/Time of Tumor/Lesion Measurement
TULOC Location of the Tumor/Lesion
TULOCGR1 Tumor Site Group 1
LSEXP Lesion IDs Expected
LSASS Lesion IDs Assessed
DTHDTF Date of Death Imputation Flag

**Details**

Contains a set of 11 unique Parameter Codes and Parameters:
PARAMCD
PARAM
LDIAM1
Target Lesion 1 Analysis Diameter
LDIAM2
Target Lesion 2 Analysis Diameter
LDIAM3
Target Lesion 3 Analysis Diameter
LDIAM4
Target Lesion 4 Analysis Diameter
LDIAM5
Target Lesion 5 Analysis Diameter
NLDIAM1
Target Lesion 1 Analysis Perpendicular
NLDIAM2
Target Lesion 2 Analysis Perpendicular
NLDIAM3
Target Lesion 3 Analysis Perpendicular
NLDIAM4
Target Lesion 4 Analysis Perpendicular
NLDIAM5
Target Lesion 5 Analysis Perpendicular
SDIAM
Target Lesions Sum of Diameters by Investigator

**Source**

Generated from admiralonco package (template ad_adtr.R).

**References**

None

**Examples**

```r
data("adtr_onco")
```

## adtte_onco

*Time to Event Analysis for Oncology*

**Description**

Time to Event Analysis for Oncology

**Usage**

```r
```

**Format**

A data frame with 20 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
ASEQ Analysis Sequence Number
AGE Age

SEX Sex
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
ADT Analysis Date
PARAM Parameter
PARAMCD Parameter Code
AVAL Analysis Value
STARTDT Time-to-Event Origin Date for Subject
CNSR Censor
EVNTDESC Event or Censoring Description
CNSDTDSC Censor Date Description
SRCDOM Source Data
SRCVAR Source Variable
SRCSEQ Source Sequence Number

**Details**

Contains a set of 3 unique Parameter Codes and Parameters:
PARAMCD
PARAM
OS
Overall Survival
PFS
Progression Free Survival
RSD
Duration of Response

**Source**

Generated from admiralonco package (template ad_adtte.R).

**References**

None

**Examples**

```r
data("adtte_onco")

```

## advfq_ophtha

*Visual Function Questionnaire Analysis*

**Description**

Visual Function Questionnaire Analysis

**Usage**

```r
```

**Format**

A data frame with 89 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection

DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
PARAM Parameter
PARAMCD Parameter Code

PARCAT1 Parameter Category 1
PARCAT2 Parameter Category 2
AVAL Analysis Value
AVALC Analysis Value (C)
BASE Baseline Value
CHG Change from Baseline
PCHG Percent Change from Baseline
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ONTRTFL On Treatment Record Flag
QSSEQ Sequence Number
QSTESTCD Question Short Name
QSTEST Question Name
QSCAT Category of Question
QSSCAT Subcategory for Question
QSORRES Finding in Original Units
QSORRESU Original Units
QSSTRESC Character Result/Finding in Std Format
QSSTRESN Numeric Finding in Standard Units
QSSTRESU Standard Units
QSBLFL Baseline Flag
QSDRVFL Derived Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
QSDTC Date/Time of Finding
QSDY Study Day of Finding

**Details**

Contains a set of 11 unique Parameter Codes and Parameters:
PARAMCD
PARAM
QBCSCORE
Composite Score
QR01
Recoded Item - 01
QR02
Recoded Item - 02
QR03
Recoded Item - 03
QR04
Recoded Item - 04
QSG01
General Score 01
QSG02
General Score 02

VFQ1
Overall Health
VFQ2
Eyesight in Both Eyes
VFQ3
Worry About Eyesight
VFQ4
Pain in and Around Eyes

**Source**

Generated from admiralophtha package (template ad_advfq.R).

**References**

None

**Examples**

```r
data("advfq_ophtha")
```

## advs

*Vital Signs Analysis*

**Description**

Vital Signs Analysis

**Usage**

```r
```

**Format**

A data frame with 105 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date

FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRTP Planned Treatment
TRTA Actual Treatment
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status

EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
AVAL Analysis Value
AVALCAT1 Analysis Value Category 1
AVALCA1N Analysis Value Category 1 (N)
BASE Baseline Value
BASETYPE Baseline Type
CHG Change from Baseline
PCHG Percent Change from Baseline
DTYPE Derivation Type
ANRIND Analysis Reference Range Indicator
BNRIND Baseline Reference Range Indicator
ANRLO Analysis Normal Range Lower Limit
ANRHI Analysis Normal Range Upper Limit
A1LO Analysis Range 1 Lower Limit
A1HI Analysis Range 1 Upper Limit
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ONTRTFL On Treatment Record Flag
VSSEQ Sequence Number
VSTESTCD Vital Signs Test Short Name

VSTEST Vital Signs Test Name
VSPOS Vital Signs Position of Subject
VSORRES Result or Finding in Original Units
VSORRESU Original Units
VSSTRESC Character Result/Finding in Std Format
VSSTRESN Numeric Result/Finding in Standard Units
VSSTRESU Standard Units
VSSTAT Completion Status
VSLOC Location of Vital Signs Measurement
VSBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
VSDTC Date/Time of Measurements
VSDY Study Day of Vital Signs
VSTPT Planned Time Point Name
VSTPTNUM Planned Time Point Number
VSELTM Planned Elapsed Time from Time Point Ref
VSTPTREF Time Point Reference

**Details**

Contains a set of 9 unique Parameter Codes and Parameters:
PARAMCD
PARAM
BMI
Body Mass Index(kg/m^2)
BSA
Body Surface Area(m^2)
DIABP
Diastolic Blood Pressure (mmHg)
HEIGHT
Height (cm)
MAP
Mean Arterial Pressure (mmHg)
PULSE
Pulse Rate (beats/min)
SYSBP
Systolic Blood Pressure (mmHg)
TEMP
Temperature (C)
WEIGHT
Weight (kg)

**Source**

Generated from admiral package (template ad_advs.R).

**References**

None

**Examples**

```r
data("advs")
```

## advs_metabolic

*Vital Signs Analysis for Metabolic*

**Description**

Vital Signs Analysis for Metabolic

**Usage**

```r
```

**Format**

A data frame with 101 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier
COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
SCRFDT Screen Failure Date
FRVDT Final Retrieval Visit Date
DTHDTC Date/Time of Death
DTHADY Relative Day of Death
DTHFL Subject Death Flag
LDDTHELD Elapsed Days from Last Dose to Death
LDDTHGR1 Last Dose to Death - Days Elapsed Grp 1
DTH30FL Death Within 30 Days of Last Trt Flag
DTHA30FL Death After 30 Days from Last Trt Flag
DTHDOM Domain for Date of Death Collection
DTHB30FL Death Within 30 Days of First Trt Flag
ASEQ Analysis Sequence Number
REGION1 Geographic Region 1
DMDTC Date/Time of Collection

DMDY Study Day of Collection
AGE Age
AGEU Age Units
AGEGR1 Pooled Age Group 1
SEX Sex
RACE Race
RACEGR1 Pooled Race Group 1
ETHNIC Ethnicity
SAFFL Safety Population Flag
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
EOSSTT End of Study Status
EOSDT End of Study Date
RFICDTC Date/Time of Informed Consent
RANDDT Date of Randomization
LSTALVDT Date Last Known Alive
TRTDURD Total Treatment Duration (Days)
DTHDT Date of Death
DTHDTF Date of Death Imputation Flag
DTHCAUS Cause of Death
DTHCGR1 Cause of Death Reason 1
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)
ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)

PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
PARCAT1 Parameter Category 1
PARCAT1N Parameter Category 1 (N)
AVAL Analysis Value
AVALCAT1 Analysis Value Category 1
AVALCA1N Analysis Value Category 1 (N)
BASE Baseline Value
BASECAT1 Baseline Category 1
BASECA1N Baseline Category 1 (N)
CHG Change from Baseline
PCHG Percent Change from Baseline
CRIT1 Analysis Criterion 1
CRIT1FL Criterion 1 Evaluation Result Flag
CRIT2 Analysis Criterion 2
CRIT2FL Criterion 2 Evaluation Result Flag
ABLFL Baseline Record Flag
VSSEQ Sequence Number
VSTESTCD Vital Signs Test Short Name
VSTEST Vital Signs Test Name
VSPOS Vital Signs Position of Subject
VSORRES Result or Finding in Original Units
VSORRESU Original Units
VSSTRESC Character Result/Finding in Std Format
VSSTRESN Numeric Result/Finding in Standard Units
VSSTRESU Standard Units
VSSTAT Completion Status
VSLOC Location of Vital Signs Measurement
VSBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
VSDTC Date/Time of Measurements
VSDY Study Day of Vital Signs
VSTPT Planned Time Point Name
VSTPTNUM Planned Time Point Number
VSELTM Planned Elapsed Time from Time Point Ref
VSTPTREF Time Point Reference

**Details**

Contains a set of 10 unique Parameter Codes and Parameters:
PARAMCD
PARAM
BMI
Body Mass Index (kg/m2)
DIABP
Diastolic Blood Pressure (mmHg)
HEIGHT
Height (cm)
HIPCIR
Hip Circumference (cm)
PULSE
Pulse Rate (beats/min)
SYSBP
Systolic Blood Pressure (mmHg)
TEMP
Temperature (C)
WAISTHIP
Waist to Hip Ratio
WEIGHT
Weight (kg)
WSTCIR
Waist Circumference (cm)

**Source**

Generated from admiralmetabolic package (template ad_advs.R).

**References**

None

**Examples**

```r
data("advs_metabolic")
```

## advs_peds

*Vital Signs Analysis for Pediatrics*

**Description**

Vital Signs Analysis for Pediatrics

**Usage**

```r
```

**Format**

A data frame with 80 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
SITEID Study Site Identifier

COUNTRY Country
DOMAIN Domain Abbreviation
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
ASEQ Analysis Sequence Number
BRTHDTC Date/Time of Birth (Character)
BRTHDT Date/Time of Birth
DMDTC Date/Time of Collection
DMDY Study Day of Collection
AGE Age
AGEU Age Units
SEX Sex
RACE Race
ETHNIC Ethnicity
ARM Description of Planned Arm
ARMCD Planned Arm Code
ACTARM Description of Actual Arm
ACTARMCD Actual Arm Code
TRT01P Planned Treatment for Period 01
TRT01A Actual Treatment for Period 01
TRTSDT Date of First Exposure to Treatment
TRTSDTM Datetime of First Exposure to Treatment
TRTSTMF Time of First Exposure Imput. Flag
TRTEDT Date of Last Exposure to Treatment
TRTEDTM Datetime of Last Exposure to Treatment
TRTETMF Time of Last Exposure Imput. Flag
RFICDTC Date/Time of Informed Consent
TRTDURD Total Treatment Duration (Days)
ADT Analysis Date
ADY Analysis Relative Day
AVISIT Analysis Visit
AVISITN Analysis Visit (N)

ATPT Analysis Timepoint
ATPTN Analysis Timepoint (N)
PARAM Parameter
PARAMCD Parameter Code
PARAMN Parameter (N)
AVAL Analysis Value
BASE Baseline Value
CHG Change from Baseline
PCHG Percent Change from Baseline
ABLFL Baseline Record Flag
ANL01FL Analysis Flag 01
ONTRTFL On Treatment Record Flag
EPOCH Epoch
VSEVAL Evaluator
VSSEQ Sequence Number
VSTESTCD Vital Signs Test Short Name
VSTEST Vital Signs Test Name
VSPOS Vital Signs Position of Subject
VSORRES Result or Finding in Original Units
VSORRESU Original Units
VSSTRESC Character Result/Finding in Std Format
VSSTRESN Numeric Result/Finding in Standard Units
VSSTRESU Standard Units
VSSTAT Completion Status
VSLOC Location of Vital Signs Measurement
VSBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
VSDTC Date/Time of Measurements
VSDY Study Day of Vital Signs
VSTPT Planned Time Point Name
VSTPTNUM Planned Time Point Number
VSELTM Planned Elapsed Time from Time Point Ref
VSTPTREF Time Point Reference
AAGECUR Current Analysis Age (Days)
AAGECURU Current Analysis Age Units
HGTTMP Temporary Height at Timepoint
HGTTMPU Temporary Height at Timepoint Units

**Details**

Contains a set of 14 unique Parameter Codes and Parameters:
PARAMCD
PARAM
BMI
Body Mass Index(kg/m^2)
BMIPCTL
BMI-for-age percentile
BMISDS
BMI-for-age z-score
HDCIRC
Head Circumference (cm)
HDCPCTL
Head Circumference-for-age percentile
HDCSDS
Head Circumference-for-age z-score
HEIGHT
Height (cm)
HGTPCTL
Height-for-age percentile
HGTSDS
Height-for-age z-score
WEIGHT
Weight (kg)
WGTAPCTL
Weight-for-age percentile
WGTASDS
Weight-for-age z-score
WGTHPCTL
Weight-for-length/height Percentile
WGTHSDS
Weight-for-length/height Z-Score

**Source**

Generated from admiralpeds package (template ad_advs.R).

**References**

None

**Examples**

```r
data("advs_peds")
```
