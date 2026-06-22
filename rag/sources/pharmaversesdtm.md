---
title: "pharmaversesdtm"
version: "1.4.1"
package_title: "SDTM Test Data for the 'Pharmaverse' Family of Packages"
description: "A set of Study Data Tabulation Model (SDTM) datasets from the Clinical Data Interchange Standards Consortium (CDISC) pilot project used for testing and developing Analysis Data Model (ADaM) datasets inside the pharmaverse family of packages. SDTM dataset specifications are described in the CDISC SDTM implementation guide, accessible by creating a free account on <https://www.cdisc.org/>."
---

# pharmaversesdtm

*SDTM Test Data for the 'Pharmaverse' Family of Packages*

A set of Study Data Tabulation Model (SDTM) datasets from the Clinical Data Interchange Standards Consortium (CDISC) pilot project used for testing and developing Analysis Data Model (ADaM) datasets inside the pharmaverse family of packages. SDTM dataset specifications are described in the CDISC SDTM implementation guide, accessible by creating a free account on <https://www.cdisc.org/>.

## ae

*Adverse Events*

**Description**

An updated SDTM AE dataset that uses the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 35 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier

AESEQ Sequence Number
AESPID Sponsor-Defined Identifier
AETERM Reported Term for the Adverse Event
AELLT Lowest Level Term
AELLTCD Lowest Level Term Code
AEDECOD Dictionary-Derived Term
AEPTCD Preferred Term Code
AEHLT High Level Term
AEHLTCD High Level Term Code
AEHLGT High Level Group Term
AEHLGTCD High Level Group Term Code
AEBODSYS Body System or Organ Class
AEBDSYCD Body System or Organ Class Code
AESOC Primary System Organ Class
AESOCCD Primary System Organ Class Code
AESEV Severity/Intensity
AESER Serious Event
AEACN Action Taken with Study Treatment
AEREL Causality
AEOUT Outcome of Adverse Event
AESCAN Involves Cancer
AESCONG Congenital Anomaly or Birth Defect
AESDISAB Persist or Signif Disability/Incapacity
AESDTH Results in Death
AESHOSP Requires or Prolongs Hospitalization
AESLIFE Is Life Threatening
AESOD Occurred with Overdose
AEDTC Date/Time of Collection
AESTDTC Start Date/Time of Adverse Event
AEENDTC End Date/Time of Adverse Event
AESTDY Study Day of Start of Adverse Event
AEENDY Study Day of End of Adverse Event

**Details**

Adverse Events
An updated SDTM AE dataset that uses the CDISC pilot project

**Author(s)**

Gopi Vegesna

**Source**

Access the source of the Adverse Events dataset.

## ae_ophtha

*Adverse Events for Ophthalmology*

**Description**

An example Adverse Events SDTM dataset with ophthalmology-specific variable AELAT

**Usage**

```r
```

**Format**

A data frame with 37 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
AESEQ Sequence Number
AESPID Sponsor-Defined Identifier
AETERM Reported Term for the Adverse Event
AELLT Lowest Level Term
AELLTCD Lowest Level Term Code
AEDECOD Dictionary-Derived Term
AEPTCD Preferred Term Code
AEHLT High Level Term
AEHLTCD High Level Term Code
AEHLGT High Level Group Term
AEHLGTCD High Level Group Term Code
AEBODSYS Body System or Organ Class
AEBDSYCD Body System or Organ Class Code
AESOC Primary System Organ Class
AESOCCD Primary System Organ Class Code
AESEV Severity/Intensity

AESER Serious Event
AEACN Action Taken with Study Treatment
AEREL Causality
AEOUT Outcome of Adverse Event
AESCAN Involves Cancer
AESCONG Congenital Anomaly or Birth Defect
AESDISAB Persist or Signif Disability/Incapacity
AESDTH Results in Death
AESHOSP Requires or Prolongs Hospitalization
AESLIFE Is Life Threatening
AESOD Occurred with Overdose
AEDTC Date/Time of Collection
AESTDTC Start Date/Time of Adverse Event
AEENDTC End Date/Time of Adverse Event
AESTDY Study Day of Start of Adverse Event
AEENDY Study Day of End of Adverse Event
AELAT Laterality
AELOC Location

**Details**

Adverse Events for Ophthalmology
An example Adverse Events SDTM dataset with ophthalmology-specific variable AELAT

**Source**

Constructed using ae from the pharmaversesdtm package

## ag_neuro

*Procedure Agents Dataset-neuro*

**Description**

A SDTM AG dataset recording details of agents such as a PET tracer used in procedures

**Usage**

```r

```

**Format**

A data frame with 13 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
AGSEQ Sequence Number
AGTRT Reported Agent Name
AGCAT Category for Agent
AGDOSE Dose per Administration
AGDOSEU Dose Units
AGROUTE Route of Administration
AGLNKID Link ID
VISITNUM Visit Number
VISIT Visit Name
AGSTDTC Start Date/Time of Agent

**Details**

Procedure Agents Dataset-neuro
A SDTM AG dataset recording details of agents such as a PET tracer used in procedures

**Source**

Constructed by admiralneuro developers

## be

*Biospecimen Events*

**Description**

A synthetic SDTM BE domain representing specimen collection, aliquoting, and culturing events,
with linkage to MB and MS domains

**Usage**

```r

```

**Format**

A data frame with 13 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
BESEQ Sequence Number
BEREFID Reference ID
BELNKID Link Identifier
BETERM Reported Term for the Biospecimen Event
BECAT Category for Biospecimen Event
BELOC Anatomical Location of Event
VISITNUM Visit Number
BEDTC Date/Time of Specimen Collection
BESTDTC Start Date/Time of Biospecimen Event
BEENDTC End Date/Time of Biospecimen Event

**Details**

Biospecimen Events
A synthetic SDTM BE domain representing specimen collection, aliquoting, and culturing events,
with linkage to MB and MS domains

**Source**

Access the source of the Biospecimen Events dataset.

## ce_vaccine

*Clinical Events for Vaccine*

**Description**

An example SDTM CE dataset for vaccine studies

**Usage**

```r

```

**Format**

A data frame with 29 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
CESEQ Sequence Number
CELNKID Link ID
CELNKGRP Link Group ID
CETERM Reported Term for the Clinical Event
CEDECOD Dictionary-Derived Term
CELAT Laterality of Location of Clinical Event
CELOC Location of Clinical Event
CECAT Category for Clinical Event
CESCAT Subcategory for Clinical Event
CEPRESP Clinical Event Pre-Specified
CEOCCUR Clinical Event Occurrence
CESEV Severity/Intensity
CEREL Causality
CEOUT Outcome of Clinical Event
EPOCH Epoch
CEDTC Date/Time of Event Collection
CESTDTC Start Date/Time of Clinical Event
CEENDTC End Date/Time of Clinical Event
CEDUR Duration of Clinical Event
CETPT Planned Time Point Name
CETPTNUM Planned Time Point Number
CETPTREF Time Point Reference
CERFTDTC Date/Time of Reference Time Point
CEEVINTX Evaluation Interval Text
CESTAT Completion Status
CEREASND Reason Clinical Event Not Collected

**Details**

Clinical Events for Vaccine
An example SDTM CE dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## cm

*Concomitant Medication*

**Description**

A SDTM CM dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 22 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
CMSEQ Sequence Number
CMSPID Sponsor-Defined Identifier
CMTRT Reported Name of Drug, Med, or Therapy
CMDECOD Standardized Medication Name
CMINDC Indication
CMCLAS Medication Class
CMDOSE Dose per Administration
CMDOSU Dose Units
CMDOSFRQ Dosing Frequency per Interval
CMROUTE Route of Administration
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
CMDTC Date/Time of Collection
CMSTDTC Start Date/Time of Medication
CMENDTC End Date/Time of Medication
CMSTDY Study Day of Start of Medication
CMENDY Study Day of End of Medication
CMENRTPT End Relative to Reference Time Point

**Details**

Concomitant Medication
A SDTM CM dataset from the CDISC pilot project

## dm

*Source Access the source of the Concomitant Medication dataset. dm Demography*

**Description**

A SDTM DM dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 28 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFICDTC Date/Time of Informed Consent
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
SITEID Study Site Identifier
BRTHDTC Date/Time of Birth
AGE Age
AGEU Age Units
SEX Sex
RACE Race
ETHNIC Ethnicity
ARMCD Planned Arm Code
ARM Description of Planned Arm
ACTARMCD Actual Arm Code

ACTARM Description of Actual Arm
COUNTRY Country
DMDTC Date/Time of Collection
DMDY Study Day of Collection
ARMNRS Reason Arm and/or Actual Arm is Null
ACTARMUD Description of Unplanned Actual Arm

**Details**

Demography
A SDTM DM dataset from the CDISC pilot project

**Source**

Access the source of the Demography dataset.

## dm_metabolic

*Demographic Dataset-metabolic*

**Description**

A SDTM DM dataset for metabolic studies

**Usage**

```r
```

**Format**

A data frame with 28 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFICDTC Date/Time of Informed Consent
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag

SITEID Study Site Identifier
BRTHDTC Date/Time of Birth
AGE Age
AGEU Age Units
SEX Sex
RACE Race
ETHNIC Ethnicity
ARMCD Planned Arm Code
ARM Description of Planned Arm
ACTARMCD Actual Arm Code
ACTARM Description of Actual Arm
COUNTRY Country
DMDTC Date/Time of Collection
DMDY Study Day of Collection
ARMNRS Reason Arm and/or Actual Arm is Null
ACTARMUD Description of Unplanned Actual Arm

**Details**

Demographic Dataset-metabolic
A SDTM DM dataset for metabolic studies

**Source**

Constructed by admiralmetabolic developers

## dm_neuro

*Demographic Dataset-neuro*

**Description**

A SDTM DM dataset for Alzheimer’s disease studies

**Usage**

```r

```

**Format**

A data frame with 28 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFICDTC Date/Time of Informed Consent
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
SITEID Study Site Identifier
BRTHDTC Date/Time of Birth
AGE Age
AGEU Age Units
SEX Sex
RACE Race
ETHNIC Ethnicity
ARMCD Planned Arm Code
ARM Description of Planned Arm
ACTARMCD Actual Arm Code
ACTARM Description of Actual Arm
COUNTRY Country
DMDTC Date/Time of Collection
DMDY Study Day of Collection
ARMNRS Reason Arm and/or Actual Arm is Null
ACTARMUD Description of Unplanned Actual Arm

**Details**

Demographic Dataset-neuro
A SDTM DM dataset for Alzheimer’s disease studies

**Source**

Constructed by admiralneuro developers

## dm_peds

*Demographic Dataset-pediatrics*

**Description**

An updated SDTM DM dataset with pediatric patients

**Usage**

```r
```

**Format**

A data frame with 28 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFICDTC Date/Time of Informed Consent
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
SITEID Study Site Identifier
BRTHDTC Date/Time of Birth
AGE Age
AGEU Age Units
SEX Sex
RACE Race
ETHNIC Ethnicity
ARMCD Planned Arm Code
ARM Description of Planned Arm
ACTARMCD Actual Arm Code
ACTARM Description of Actual Arm
COUNTRY Country
DMDTC Date/Time of Collection
DMDY Study Day of Collection
ARMNRS Reason Arm and/or Actual Arm is Null
ACTARMUD Description of Unplanned Actual Arm

**Details**

Demographic Dataset-pediatrics
An updated SDTM DM dataset with pediatric patients

**Source**

Constructed by admiralpeds developers

## dm_vaccine

*Demographics for Vaccine*

**Description**

An example SDTM DM dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 30 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SUBJID Subject Identifier for the Study
RFSTDTC Subject Reference Start Date/Time
RFENDTC Subject Reference End Date/Time
RFXSTDTC Date/Time of First Study Treatment
RFXENDTC Date/Time of Last Study Treatment
RFICDTC Date/Time of Informed Consent
RFPENDTC Date/Time of End of Participation
DTHDTC Date/Time of Death
DTHFL Subject Death Flag
SITEID Study Site Identifier
INVID Investigator Identifier
INVNAM Investigator Name
BRTHDTC Date/Time of Birth
AGE Age
AGEU Age Units

SEX Sex
RACE Race
ETHNIC Ethnicity
ARMCD Planned Arm Code
ARM Description of Planned Arm
ACTARMCD Actual Arm Code
ACTARM Description of Actual Arm
COUNTRY Country
DMDTC Date/Time of Collection
DMDY Study Day of Collection
ARMNRS Reason Arm and/or Actual Arm is Null
ACTARMUD Description of Unplanned Actual Arm

**Details**

Demographics for Vaccine
An example SDTM DM dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## ds

*Disposition*

**Description**

An updated SDTM DS dataset that uses the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 13 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
DSSEQ Sequence Number
DSSPID Sponsor-Defined Identifier
DSTERM Reported Term for the Disposition Event

DSDECOD Standardized Disposition Term
DSCAT Category for Disposition Event
VISITNUM Visit Number
VISIT Visit Name
DSDTC Date/Time of Collection
DSSTDTC Start Date/Time of Disposition Event
DSSTDY Study Day of Start of Disposition Event

**Details**

Disposition
An updated SDTM DS dataset that uses the CDISC pilot project

**Author(s)**

Gopi Vegesna

**Source**

Access the source of the Disposition dataset.

## eg

*Electrocardiogram*

**Description**

An example of standard SDTM EG dataset to be used in deriving ADEG dataset

**Usage**

```r
```

**Format**

A data frame with 23 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
EGSEQ Sequence Number
EGTESTCD ECG Test Short Name
EGTEST ECG Test Name
EGORRES Result or Finding in Original Units
EGORRESU Original Units

EGSTRESC Character Result/Finding in Std Format
EGSTRESN Numeric Result/Finding in Standard Units
EGSTRESU Standard Units
EGSTAT Completion Status
EGLOC Location of Vital Signs Measurement
EGBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EGDTC Date/Time of Measurements
EGDY Study Day of Vital Signs
EGTPT Planned Time Point Number
EGTPTNUM Time Point Number
EGELTM Planned Elapsed Time from Time Point Ref
EGTPTREF Time Point Reference

**Details**

Electrocardiogram
An example of standard SDTM EG dataset to be used in deriving ADEG dataset
Contains a set of 4 unique Test Short Names and Test Names:
EGTESTCD
EGTEST
ECGINT
ECG Interpretation
HR
Heart Rate
QT
QT Duration
RR
RR Duration

**Source**

Generated dataset.

## ex

*Exposure*

**Description**

A SDTM EX dataset from the CDISC pilot project

**Usage**

```r

```

**Format**

A data frame with 17 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
EXSEQ Sequence Number
EXTRT Name of Actual Treatment
EXDOSE Dose per Administration
EXDOSU Dose Units
EXDOSFRM Dose Form
EXDOSFRQ Dosing Frequency per Interval
EXROUTE Route of Administration
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EXSTDTC Start Date/Time of Treatment
EXENDTC End Date/Time of Treatment
EXSTDY Study Day of Start of Treatment
EXENDY Study Day of End of Treatment

**Details**

Exposure
A SDTM EX dataset from the CDISC pilot project

**Source**

Access the source of the Exposure dataset.

## ex_ophtha

*Exposure for Ophthalmology*

**Description**

An example Exposure SDTM dataset with ophthalmology-specific variables such as EXLOC and
EXLAT

**Usage**

```r

```

**Format**

A data frame with 19 columns:
USUBJID Unique Subject Identifier
STUDYID Study Identifier
DOMAIN Domain Abbreviation
EXSEQ Sequence Number
EXTRT Name of Actual Treatment
EXDOSE Dose per Administration
EXDOSU Dose Units
EXDOSFRM Dose Form
EXDOSFRQ Dose Frequency per Interval
EXROUTE Route of Administration
EXLOC Location of Dose Administration
EXLAT Laterality
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EXSTDTC Start Date/Time of Treatment
EXENDTC End Date/Time of Treatment
EXSTDY Study Day of Start of Treatment
EXENDY Study Day of End of Treatment

**Details**

Exposure for Ophthalmology
An example Exposure SDTM dataset with ophthalmology-specific variables such as EXLOC and
EXLAT

**Source**

Constructed using ex from the pharmaversesdtm package

## ex_vaccine

*Exposures for Vaccine*

**Description**

An example SDTM EX dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 19 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
EXSEQ Sequence Number
EXLNKGRP Link Group ID
EXLNKID Link ID
EXTRT Name of Actual Treatment
EXCAT Category of Treatment
EXDOSE Dose per Administration
EXDOSU Dose Units
EXDOSFRM Dose Form
EXROUTE Route of Administration
EXLOC Location of Dose Administration
EXLAT Laterality
VISITNUM Visit Number
VISIT Visit Name
EPOCH Epoch
EXSTDTC Start Date/Time of Treatment
EXENDTC End Date/Time of Treatment

**Details**

Exposures for Vaccine
An example SDTM EX dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## face_vaccine

*Findings About Clinical Events for Vaccine*

**Description**

An example SDTM FACE for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 30 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
FASEQ Sequence Number
FALNKGRP Link Group ID
FALAT Laterality
FALNKID Link ID
FALOC Location of the Finding About
FATESTCD Findings About Test Short Name
FATEST Findings About Test Name
FAOBJ Object of the Observation
FACAT Category for Findings About
FASCAT Subcategory for Findings About
FAEVAL Evaluator
FAORRES Result or Finding in Original Units
FAORRESU Original Units
EPOCH Epoch
FADTC Date/Time of Collection
FADY Study Day of Collection
FATPT Planned Time Point Name
FATPTNUM Planned Time Point Number
FATPTREF Time Point Reference
FARFTDTC Date/Time of Reference Time Point
FAEVLINT Evaluation Interval
FAEVINTX Evaluation Interval Text

FASTAT Completion Status
FAREASND Reason Not Performed
FASTRESC Character Result/Finding in Std Format
FASTRESN Numeric Result/Finding in Standard Units
FASTRESU Standard Units

**Details**

Findings About Clinical Events for Vaccine
An example SDTM FACE for vaccine studies
Contains a set of 3 unique Test Short Names and Test Names:
FATESTCD
FATEST
DIAMETER
Diameter
OCCUR
Occurrence Indicator
SEV
Severity/Intensity

**Source**

Constructed by admiralvaccine developers

## get_terms

*An example function as expected by the get_terms_fun parameter of admiral::create_query_data()*

**Description**

An example function as expected by the get_terms_fun parameter of admiral::create_query_data()

**Usage**

```r
get_terms(basket_select, version, keep_id, temp_env)
```

**Arguments**

basket_select
A basket_select object defining the terms
version
MedDRA version
keep_id
Should GRPID be included in the output?
temp_env
Temporary environment

## is_ada

*Immunogenicity Specimen Assessments for ADA*

**Description**

A SDTM IS dataset containing relevant antidrug antibody assessment studies

**Usage**

```r
```

**Format**

A data frame with 27 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
ISSEQ Sequence Number
ISTESTCD Immunogenicity Test/Exam Short Name
ISTEST Immunogenicity Test or Examination Name
ISBDAGNT Binding Agent
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
ISBLFL Baseline Flag
ISLLOQ Lower Limit of Quantitation
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
EPOCH Epoch
ISDTC Date/Time of Collection
ISDY Study Day of Visit/Collection/Exam
ISTPT Planned Time Point Name
ISTPTNUM Planned Time Point Number

**Details**

Immunogenicity Specimen Assessments for ADA
A SDTM IS dataset containing relevant antidrug antibody assessment studies
Contains a set of 2 unique Test Short Names and Test Names:
ISTESTCD
ISTEST
ADA_BAB
Binding Antidrug Antibody
ADA_NAB
Neutralizing Binding Antidrug Antibody

**Author(s)**

Kristin Dahnert

**Source**

Generated dataset

## is_vaccine

*Immunogenicity Specimen Assessments for Vaccine*

**Description**

An example SDTM IS for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 24 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
ISSEQ Sequence Number
ISTESTCD Immunogenicity Test/Exam Short Name
ISTEST Immunogenicity Test or Exam Name
ISCAT Category for Immunogenicity Test
ISORRES Result or Finding in Original Units
ISORRESU Original Units
ISSTRESC Character Result/Finding in Std Format
ISSTRESN Numeric Result/Finding in Standard Units

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
ISDY Study Day of Collection
ISULOQ Upper Limit of Quantitation

**Details**

Immunogenicity Specimen Assessments for Vaccine
An example SDTM IS for vaccine studies
Contains a set of 4 unique Test Short Names and Test Names:
ISTESTCD
ISTEST
I0019NT
I0019NT Antibody
J0033VN
J0033VN Antibody
M0019LN
M0019LN Antibody
R0003MA
R0003MA Antibody

**Source**

Constructed by admiralvaccine developers

## lb

*Laboratory Measurements*

**Description**

An updated SDTM LB dataset that uses data from the CDISC pilot project

**Usage**

```r

```

**Format**

A data frame with 23 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

Laboratory Measurements
An updated SDTM LB dataset that uses data from the CDISC pilot project
Contains a set of 47 unique Test Short Names and Test Names:
LBTESTCD
LBTEST
ALB
Albumin
ALP
Alkaline Phosphatase
ALT
Alanine Aminotransferase
ANISO
Anisocytes
AST
Aspartate Aminotransferase
BASO
Basophils

BASOLE
Basophils/Leukocytes
BILI
Bilirubin
BUN
Blood Urea Nitrogen
CA
Calcium
CHOL
Cholesterol
CK
Creatine Kinase
CL
Chloride
COLOR
Color
CREAT
Creatinine
EOS
Eosinophils
EOSLE
Eosinophils/Leukocytes
GGT
Gamma Glutamyl Transferase
GLUC
Glucose
HBA1C
Hemoglobin A1C
HCT
Hematocrit
HGB
Hemoglobin
K
Potassium
KETONES
Ketones
LYM
Lymphocytes
LYMLE
Lymphocytes/Leukocytes
MACROCY
Macrocytes
MCH
Ery. Mean Corpuscular Hemoglobin
MCHC
Ery. Mean Corpuscular HGB Concentration
MCV
Ery. Mean Corpuscular Volume
MICROCY
Microcytes
MONO
Monocytes
MONOLE
Monocytes/Leukocytes
PH
pH
PHOS
Phosphate
PLAT
Platelet
POIKILO
Poikilocytes
POLYCHR
Polychromasia
PROT
Protein
RBC
Erythrocytes
SODIUM
Sodium
SPGRAV
Specific Gravity
TSH
Thyrotropin
URATE
Urate
UROBIL
Urobilinogen
VITB12
Vitamin B12
WBC
Leukocytes

**Author(s)**

Annie Yang

**Source**

Access the source of the Laboratory Measurements dataset.

## lb_metabolic

*Laboratory Measurements Dataset-metabolic*

**Description**

A SDTM LB dataset containing relevant laboratory measurements for metabolic studies

**Usage**

```r
```

**Format**

A data frame with 24 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

**Details**

Laboratory Measurements Dataset-metabolic
A SDTM LB dataset containing relevant laboratory measurements for metabolic studies
Contains a set of 9 unique Test Short Names and Test Names:
LBTESTCD
LBTEST
ALB
Albumin
ALP
Alkaline Phosphatase
AST
Aspartate Aminotransferase
CHOL
Cholesterol
GGT
Gamma Glutamyl Transferase
GLUC
Glucose
HBA1CHGB
Hemoglobin A1C/Hemoglobin
INSULIN
Insulin
TRIG
Triglycerides

**Source**

Constructed by admiralmetabolic developers

## lb_neuro

*Laboratory Test Dataset-neuro*

**Description**

A SDTM LB domain dataset containing laboratory test results for Alzheimer’s Disease studies

**Usage**

```r
```

**Format**

A data frame with 23 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

Laboratory Test Dataset-neuro
A SDTM LB domain dataset containing laboratory test results for Alzheimer’s Disease studies
Contains a set of 4 unique Test Short Names and Test Names:
LBTESTCD
LBTEST
AMYLB42
Lumipulse G Beta-Amyloid 1-42-N Plasma
ASYNASAA
Alpha Synuclein Seed Amplification Assay (CSF)
PTAB42R
Lumipulse G pTau 217/Beta-Amyloid 1-42 Plasma Ratio
PTAU217
Lumipulse G pTau 217 Plasma

**Source**

Constructed by admiralneuro developers

## lb_onco_pcwg3

*Laboratory Measurements (PSA) for Oncology*

**Description**

A SDTM LB dataset for prostate cancer studies intended for examples of ADaM dataset creation

**Usage**

```r

```

**Format**

A data frame with 18 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
LBSEQ Sequence Number
LBTESTCD Lab Test or Examination Short Name
LBTEST Lab Test or Examination Name
LBCAT Category for Lab Test
LBORRES Result or Finding in Original Units
LBORRESU Original Units
LBSTRESC Character Result/Finding in Std Format
LBSTRESN Numeric Result/Finding in Standard Units
LBSTRESU Standard Units
LBBLFL Baseline Flag
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
LBDTC Date/Time of Specimen Collection
LBDY Study Day of Specimen Collection

**Details**

Laboratory Measurements (PSA) for Oncology
A SDTM LB dataset for prostate cancer studies intended for examples of ADaM dataset creation
Contains a set of 1 unique Test Short Name and Test Name:
LBTESTCD
LBTEST
PSA
Prostate Specific Antigen

**Author(s)**

Tomoyuki Namai

**Source**

Generated dataset

## mb

*Microbiology Specimen*

**Description**

A synthetic SDTM MB domain representing microbiology findings and linkage to MS domain (ms)

**Usage**

```r
```

**Format**

A data frame with 21 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
MBSEQ Sequence Number
MBGRPID Group ID
MBREFID Reference ID
MBLNKGRP Link Group ID
MBTESTCD Microbiology Test or Finding Short Name
MBTEST Microbiology Test or Finding Name
MBTSTDTL Measurement, Test or Examination Detail
MBORRES Result or Finding in Original Units
MBORRESU Original Units
MBRSLSCL Result Scale
MBSTRESC Result or Finding in Standard Format
MBSTRESN Numeric Result/Finding in Standard Units
MBSTRESU Standard Units
MBSPEC Specimen Material Type
MBLOC Specimen Collection Location
MBMETHOD Method of Test or Examination
VISITNUM Visit Number
MBDTC Date/Time of Collection

**Details**

Microbiology Specimen
A synthetic SDTM MB domain representing microbiology findings and linkage to MS domain (ms)
Contains a set of 6 unique Test Short Names and Test Names:
MBTESTCD
MBTEST
GMNCOC
Gram Negative Cocci
GNROD
Gram Negative Rods
GPRCOC
Gram Positive Cocci
MCCOLCNT
Colony Count
MCORGIDN
Microbial Organism Identification
MTBCMPLX
Mycobacterium tuberculosis complex

**Source**

Access the source of the Microbiology Specimen dataset.

## mh

*Medical History*

**Description**

An updated SDTM MH dataset that uses data from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 28 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
MHSEQ Sequence Number
MHSPID Sponsor-Defined Identifier
MHTERM Reported Term for the Medical History
MHLLT Lowest Level Term
MHDECOD Dictionary-Derived Term
MHHLT High Level Term
MHHLGT High Level Group Term
MHCAT Category for Medical History

MHBODSYS Body System or Organ Class
MHSEV Severity/Intensity
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
MHDTC Date/Time of History Collection
MHSTDTC Start Date/Time of Medical History Event
MHDY Study Day of History Collection
MHENDTC End Date/Time of Medical History Event
MHPRESP Medical History Event Pre-Specified
MHOCCUR Medical History Occurrence
MHSTRTPT Start Relative to Reference Time Point
MHENRTPT End Relative to Reference Time Point
MHSTTPT Start Reference Time Point
MHENTPT End Reference Time Point
MHENRF End Relative to Reference Period
MHSTAT Completion Status

**Details**

Medical History
An updated SDTM MH dataset that uses data from the CDISC pilot project

**Author(s)**

Annie Yang

**Source**

Access the source of the Medical History dataset.

## ms

*Microbiology Susceptibility*

**Description**

A synthetic SDTM MS domain with susceptibility results and linkage to MB domain (mb)

**Usage**

```r

```

**Format**

A data frame with 23 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
MSSEQ Sequence Number
MSREFID Reference ID
NHOID Non-host Organism ID
MSGRPID Group ID
MSLNKID Link ID
MSTESTCD Short Name of Assessment
MSTEST Name of Assessment
MSAGENT Agent Name
MSCONC Agent Concentration
MSCONCU Agent Concentration Units
MSORRES Result or Finding in Original Units
MSORRESU Original Units
MSSTRESC Result or Finding in Standard Format
MSSTRESN Numeric Result/Finding in Standard Units
MSSTRESU Standard Units
MSSPEC Specimen Material Type
MSLOC Location Used for the Measurement
MSMETHOD Method of Test or Examination
VISITNUM Visit Number
MSDTC Date/Time of Collection

**Details**

Microbiology Susceptibility
A synthetic SDTM MS domain with susceptibility results and linkage to MB domain (mb)
Contains a set of 3 unique Test Short Names and Test Names:
MSTESTCD
MSTEST
DIAZOINH
Diameter of the Zone of Inhibition
MIC
Minimum Inhibitory Concentration
MICROSUS
Microbial Susceptibility

**Source**

Access the source of the Microbiology Susceptibility dataset.

## nv_neuro

*Neurological Assessment Dataset-neuro*

**Description**

A SDTM NV dataset containing neurological assessments or test results

**Usage**

```r
```

**Format**

A data frame with 21 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
NVSEQ Sequence Number
NVLNKID Link ID
NVTESTCD Short Name of Nervous System Test
NVTEST Name of Nervous System Test
NVCAT Category for Nervous System Test
NVLOC Location Used for the Measurement
NVMETHOD Method of Test or Examination
NVNAM Vendor Name
NVORRES Result or Finding in Original Units
NVORRESU Original Units
NVSTRESC Character Result/Finding in Std Format
NVSTRESN Numeric Result/Finding in Standard Units
NVSTRESU Standard Units
VISITNUM Visit Number
VISIT Visit Name
NVDTC Date/Time of Collection
NVDY Study Day of Collection
NVLOBXFL Last Observation Before Exposure Flag

**Details**

Neurological Assessment Dataset-neuro
A SDTM NV dataset containing neurological assessments or test results
Contains a set of 3 unique Test Short Names and Test Names:
NVTESTCD
NVTEST
SUVR
Standardized Uptake Value Ratio
UPSIT
University of Pennsylvania Smell Identification Test
VR
Qualitative Visual Classification

**Source**

Constructed by admiralneuro developers

## oe_ophtha

*Ophthalmic Examinations for Ophthalmology*

**Description**

A SDTM OE dataset simulated by Ophthalmology team

**Usage**

```r
```

**Format**

A data frame with 25 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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
OETEST Name of Ophthalmic Test or Examination

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

**Details**

Ophthalmic Examinations for Ophthalmology
A SDTM OE dataset simulated by Ophthalmology team
Contains a set of 4 unique Test Short Names and Test Names:
OETESTCD
OETEST
CSUBTH
Center Subfield Thickness
DRSSR
Diabetic Retinopathy Sev Recode Value
IOP
Intraocular Pressure
VACSCORE
Visual Acuity Score

**Author(s)**

Gordon Miller

**Source**

Generated dataset.

## pc

*Pharmacokinetic Concentrations*

**Description**

A SDTM PC dataset simulated by Antonio Rodriguez Contesti

**Usage**

```r

```

**Format**

A data frame with 21 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
PCSEQ Sequence Number
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

**Details**

Pharmacokinetic Concentrations
A SDTM PC dataset simulated by Antonio Rodriguez Contesti
Contains a set of 1 unique Test Short Name and Test Name:
PCTESTCD
PCTEST
XAN
XANOMELINE

**Author(s)**

Antonio Rodriguez Contesti

**Source**

Access the source of the Pharmacokinetic Concentrations dataset.

## pp

*Pharmacokinetic Parameters*

**Description**

A SDTM PP dataset simulated by Antonio Rodriguez Contesti

**Usage**

```r
```

**Format**

A data frame with 14 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
PPSEQ Sequence Number
PPTESTCD Parameter Short Name
PPTEST Parameter Name
PPCAT Parameter Category
PPORRES Result or Finding in Original Units
PPORRESU Original Units
PPSTRESC Character Result/Finding in Std Format
PPSTRESN Numeric Result/Finding in Standard Units
PPSTRESU Standard Units
PPSPEC Specimen Material Type
PPRFDTC Date/Time of Reference Point

**Details**

Pharmacokinetic Parameters
A SDTM PP dataset simulated by Antonio Rodriguez Contesti
Contains a set of 10 unique Test Short Names and Test Names:
PPTESTCD
PPTEST
AUCALL
AUC All
AUCLST
AUC to Last Nonzero Conc
CLST
Last Nonzero Conc
CMAX
Max Conc
LAMZ
Lambda z

LAMZHL
Half-Life Lambda z
LAMZNPT
Number of Points for Lambda z
RCAMINT
Ae
RENALCL
CLR
TMAX
Time of CMAX

**Author(s)**

Antonio Rodriguez Contesti

**Source**

Access the source of the Pharmacokinetic Parameters dataset.

## qs_metabolic

*Questionnaire Dataset-metabolic*

**Description**

A SDTM QS dataset containing COEQ data (Control of Eating Questionnaire) for metabolic stud-
ies. Note that University of Leeds are the copyright holders of the Control of Eating Questionnaire
(CoEQ) and the test data included within pharmaversesdtm as well as the ADCOEQ code are for
not-for-profit use only within admiralmetabolic and pharmaverse-related examples/documentation.
Any persons or companies wanting to use the CoEQ should request a license to do so from the
following link.

**Usage**

```r
```

**Format**

A data frame with 18 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
DOMAIN Domain Abbreviation
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

Questionnaire Dataset-metabolic
A SDTM QS dataset containing COEQ data (Control of Eating Questionnaire) for metabolic stud-
ies. Note that University of Leeds are the copyright holders of the Control of Eating Questionnaire
(CoEQ) and the test data included within pharmaversesdtm as well as the ADCOEQ code are for
not-for-profit use only within admiralmetabolic and pharmaverse-related examples/documentation.
Any persons or companies wanting to use the CoEQ should request a license to do so from the
following link.
Contains a set of 21 unique Test Short Names and Test Names:
QSTESTCD
QSTEST
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

**Source**

Constructed by admiralmetabolic developers

## qs_ophtha

*Questionnaire for Ophthalmology*

**Description**

An example Questionnaires SDTM dataset with ophthalmology-specific questionnaire of NEI VFQ-

**Usage**

```r
```

**Format**

A data frame with 20 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

Questionnaire for Ophthalmology
An example Questionnaires SDTM dataset with ophthalmology-specific questionnaire of NEI VFQ-
Contains a set of 29 unique Test Short Names and Test Names:
QSTESTCD
QSTEST
VFQ101
Your Overall Health Is
VFQ102
Eyesight Using Both Eyes Is
VFQ103
How Often You Worry About Eyesight
VFQ104
How Often Pain in and Around Eyes
VFQ105
Difficulty Reading Newspapers
VFQ106
Difficulty Doing Work/Hobbies
VFQ107
Difficulty Finding on Crowded Shelf
VFQ108
Difficulty Reading Street Signs
VFQ109
Difficulty Going Down Step at Night
VFQ110
Difficulty Noticing Objects to Side
VFQ111
Difficulty Seeing How People React
VFQ112
Difficulty Picking Out Own Clothes
VFQ113
Difficulty Visiting With People
VFQ114
Difficulty Going Out to See Movies
VFQ115
Are You Currently Driving
VFQ115C
Difficulty Driving During Daytime
VFQ116
Difficulty Driving at Night
VFQ116A
Driving in Difficult Conditions
VFQ119
Eye Pain Keep You From Doing What You Like
VFQ120
I Stay Home Most of the Time
VFQ121
I Feel Frustrated a Lot of the Time
VFQ124
I Need a Lot of Help From Others
VFQ125
Worry I’ll Do Embarrassing Things
VFQ1A03
Difficulty Reading Small Print
VFQ1A04
Difficulty Figure Out Bill Accuracy
VFQ1A05
Difficulty Shaving or Styling Hair
VFQ1A06
Difficulty Recognizing People
VFQ1A07
Difficulty Taking Part in Sports
VFQ1A08
Difficulty Seeing Programs on TV

**Source**

Constructed using qs from the pharmaversesdtm package

## rs_onco

*Disease Response for Oncology*

**Description**

A SDTM RS dataset simulated by Gopi Vegesna

**Usage**

```r
```

**Format**

A data frame with 19 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
RSSEQ Sequence Number
RSLNKGRP Link Group
RSTESTCD Response Assessment Short Name
RSTEST Response Assessment Name
RSCAT Category for Response Assessment
RSORRES Response Assessment Original Result
RSSTRESC Response Assessment Result in Std Format
RSSTAT Completion Status
RSREASND Reason Response Assessment Not Performed
RSEVAL Evaluator
RSEVALID Evaluator Identifier
RSACPTFL Accepted Record Flag
VISITNUM Visit Number
VISIT Visit Name
RSDTC Date/Time of Response Assessment
RSDY Study Day of Response Assessment

**Details**

Disease Response for Oncology
A SDTM RS dataset simulated by Gopi Vegesna
Contains a set of 4 unique Test Short Names and Test Names:
RSTESTCD
RSTEST
NEWLPROG
New Lesion Progression
NTRGRESP
Non-target Response
OVRLRESP
Overall Response
TRGRESP
Target Response

**Author(s)**

Gopi Vegesna

**Source**

Access the source of the Disease Response for Oncology dataset.

## rs_onco_ca125

*Disease Response (GCIG)*

**Description**

A SDTM RS dataset using GCIG criteria. The dataset contains just a few patients. It is intended for
vignettes and examples of ADaM dataset creation.

**Usage**

```r
```

**Format**

A data frame with 13 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
RSSEQ Sequence Number
RSTESTCD Assessment Short Name
RSTEST Assessment Name
RSCAT Category for Assessment
RSORRES Result or Finding in Original Units
RSSTRESC Character Result/Finding in Std Format
RSEVAL Evaluator
VISITNUM Visit Number
VISIT Visit Name
RSDTC Date/Time of Assessment

**Details**

Disease Response (GCIG)
A SDTM RS dataset using GCIG criteria. The dataset contains just a few patients. It is intended for
vignettes and examples of ADaM dataset creation.
Contains a set of 1 unique Test Short Name and Test Name:
RSTESTCD
RSTEST
OVRLRESP
Overall Response

**Author(s)**

Vinh Nguyen

## rs_onco_imwg

*Source Generated dataset (rs_supprs_onco_ca125.R) rs_onco_imwg Disease Response (IMWG)*

**Description**

A SDTM RS dataset using IMWG criteria intended for examples of ADaM dataset creation

**Usage**

```r
```

**Format**

A data frame with 17 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
RSSEQ Sequence Number
RSLNKGRP Link Group ID
RSTESTCD Assessment Short Name
RSTEST Assessment Name
RSCAT Category for Assessment
RSORRES Result or Finding in Original Units
RSSTRESC Character Result/Finding in Std Format
RSSTAT Completion Status
RSREASND Reason Not Done
RSEVAL Evaluator
VISITNUM Visit Number
VISIT Visit Name
RSDTC Date/Time of Assessment
RSDY Study Day of Assessment

**Details**

Disease Response (IMWG)
A SDTM RS dataset using IMWG criteria intended for examples of ADaM dataset creation
Contains a set of 1 unique Test Short Name and Test Name:
RSTESTCD
RSTEST
OVRLRESP
Overall Response

**Author(s)**

Vinh Nguyen

**Source**

Derived from tr_onco_recist

## rs_onco_irecist

*Disease Response (iRECIST) for Oncology*

**Description**

A SDTM RS dataset using iRECIST intended for examples of ADaM dataset creation

**Usage**

```r
```

**Format**

A data frame with 19 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
RSSEQ Sequence Number
RSLNKGRP Link Group ID
RSTESTCD Assessment Short Name
RSTEST Assessment Name
RSCAT Category for Assessment
RSORRES Result or Finding in Original Units
RSSTRESC Character Result/Finding in Std Format
RSSTAT Completion Status
RSREASND Reason Not Done

RSEVAL Evaluator
RSEVALID Evaluator Identifier
RSACPTFL Accepted Record Flag
VISITNUM Visit Number
VISIT Visit Name
RSDTC Date/Time of Assessment
RSDY Study Day of Assessment

**Details**

Disease Response (iRECIST) for Oncology
A SDTM RS dataset using iRECIST intended for examples of ADaM dataset creation
Contains a set of 6 unique Test Short Names and Test Names:
RSTESTCD
RSTEST
IRECLIND
Last iRECIST Assessment Indicator
NEWLIND
New Lesion Indicator
NEWLPROG
New Lesion Progression
NTRGRESP
Non-target Response
OVRLRESP
Overall Response
TRGRESP
Target Response

**Author(s)**

Rohan Thampi

**Source**

Generated dataset.

## rs_onco_pcwg3

*Disease Response (PCWG3) for Oncology*

**Description**

A SDTM RS dataset for oncology studies using PCWG3 criteria intended for examples of ADaM
dataset creation

**Usage**

```r

```

**Format**

A data frame with 14 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
RSSEQ Sequence Number
RSTESTCD Response Assessment Short Name
RSTEST Response Assessment Name
RSCAT Category for Response Assessment
RSORRES Response Assessment Original Result
RSSTRESC Response Assessment Result in Std Format
RSEVAL Evaluator
VISITNUM Visit Number
VISIT Visit Name
RSDTC Date/Time of Response Assessment
RSDY Study Day of Response Assessment

**Details**

Disease Response (PCWG3) for Oncology
A SDTM RS dataset for oncology studies using PCWG3 criteria intended for examples of ADaM
dataset creation
Contains a set of 3 unique Test Short Names and Test Names:
RSTESTCD
RSTEST
BONERESP
Bone Response
OVRLRESP
Overall Response
SFTSRESP
Soft Tissue Response

**Author(s)**

Tomoyuki Namai

**Source**

Generated dataset

## rs_onco_recist

*Disease Response (RECIST 1.1) for Oncology*

**Description**

A SDTM RS dataset using RECIST 1.1 intended for examples of ADaM dataset creation

**Usage**

```r
```

**Format**

A data frame with 14 columns:
DOMAIN Domain Abbreviation
STUDYID Study Identifier
USUBJID Unique Subject Identifier
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

**Details**

Disease Response (RECIST 1.1) for Oncology
A SDTM RS dataset using RECIST 1.1 intended for examples of ADaM dataset creation
Contains a set of 1 unique Test Short Name and Test Name:
RSTESTCD
RSTEST
OVRLRESP
Overall Response

**Author(s)**

Stefan Bundfuss

**Source**

Generated dataset.

## sc_ophtha

*Subject Characteristic for Ophthalmology*

**Description**

A SDTM SC dataset simulated by Ophthalmology team

**Usage**

```r
```

**Format**

A data frame with 12 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
SCSEQ Sequence Number
SCTESTCD Subject Characteristic Short Name
SCTEST Subject Characteristic
SCCAT Category for Subject Characteristic
SCORRES Result or Finding in Original Units
SCSTRESC Character Result/Finding in Std Format
EPOCH Epoch
SCDTC Date/Time of Collection
SCDY Study Day of Examination

**Details**

Subject Characteristic for Ophthalmology
A SDTM SC dataset simulated by Ophthalmology team
Contains a set of 1 unique Test Short Name and Test Name:
SCTESTCD
SCTEST
FOCID
Focus of Study-Specific Interest

**Author(s)**

Gordon Miller

**Source**

Generated dataset.

## sdg_db

*SDG*

**Description**

An example SDG dataset

**Usage**

```r
```

**Format**

A data frame with 5 columns:
termchar Reported Term
sdg_name Name
sdg_id Name ID
termvar Variable
version Version

**Details**

SDG
An example SDG dataset

**Source**

Access the source of the SDG dataset.

## smq_db

*Standardized MedDRA Queries*

**Description**

An example SMQ dataset

**Usage**

```r

```

**Format**

A data frame with 6 columns:
termchar Reported Term
scope Scope
smq_name Name
smq_id Name ID
version Version
termvar Variable

**Details**

Standardized MedDRA Queries
An example SMQ dataset

**Source**

Generated dataset.

## suppae

*Supplemental Adverse Events*

**Description**

A SDTM SUPPAE dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 10 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin
QEVAL Evaluator

**Details**

Supplemental Adverse Events
A SDTM SUPPAE dataset from the CDISC pilot project

**Source**

Access the source of the Supplemental Adverse Events dataset.

## suppce_vaccine

*Supplemental Qualifiers for Clinical Events for Vaccine*

**Description**

An example SDTM SUPPCE for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
RDOMAIN Related Domain Abbreviation
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QVAL Data Value
QLABEL Qualifier Variable Label
QORIG Origin

**Details**

Supplemental Qualifiers for Clinical Events for Vaccine
An example SDTM SUPPCE for vaccine studies

**Source**

Constructed by admiralvaccine developers

## suppdm

*Supplemental Demography*

**Description**

A SDTM SUPPDM dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 10 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin
QEVAL Evaluator

**Details**

Supplemental Demography
A SDTM SUPPDM dataset from the CDISC pilot project

**Source**

Generated dataset.

## suppdm_vaccine

*Supplemental Qualifiers for Demographics for Vaccine*

**Description**

An example SDTM SUPPDM dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
RDOMAIN Related Domain Abbreviation
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QVAL Data Value
QLABEL Qualifier Variable Label
QORIG Origin

**Details**

Supplemental Qualifiers for Demographics for Vaccine
An example SDTM SUPPDM dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## suppds

*Supplemental Disposition*

**Description**

A SDTM SUPPDS dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin

**Details**

Supplemental Disposition
A SDTM SUPPDS dataset from the CDISC pilot project

**Source**

Access the source of the Supplemental Disposition dataset.

## suppex_vaccine

*Supplemental Qualifiers for Exposures for Vaccine*

**Description**

An example SDTM SUPPEX dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
RDOMAIN Related Domain Abbreviation
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QVAL Data Value
QLABEL Qualifier Variable Label
QORIG Origin

**Details**

Supplemental Qualifiers for Exposures for Vaccine
An example SDTM SUPPEX dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## suppface_vaccine

*Supplemental Qualifiers for Findings About for Clinical Events for Vaccine*

**Description**

An example SDTM SUPPFACE dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
USUBJID Unique Subject Identifier
RDOMAIN Related Domain Abbreviation
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QVAL Data Value
QLABEL Qualifier Variable Label
QORIG Origin

**Details**

Supplemental Qualifiers for Findings About for Clinical Events for Vaccine
An example SDTM SUPPFACE dataset for vaccine studies

**Source**

Constructed by admiralvaccine developers

## suppis_vaccine

*Supplemental Qualifiers for Immunogenicity Specimen Assessments for Vaccine*

**Description**

An example SDTM SUPPIS dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 10 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin
QEVAL Evaluator

**Details**

Supplemental Qualifiers for Immunogenicity Specimen Assessments for Vaccine
An example SDTM SUPPIS dataset for vaccine studies

**Source**

Constructed by admiralpeds developers

## suppnv_neuro

*Supplemental for Neurological Assessment Dataset-neuro*

**Description**

A SDTM SUPPNV dataset containing additional information about neurological assessments or
test results

**Usage**

```r
```

**Format**

A data frame with 10 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin
QEVAL Evaluator

**Details**

Supplemental for Neurological Assessment Dataset-neuro
A SDTM SUPPNV dataset containing additional information about neurological assessments or
test results

**Source**

Constructed by admiralneuro developers

## supprs_onco_ca125

*Supplemental Qualifiers for RS_ONCO_CA125*

**Description**

A SDTM supplemental RS dataset using GCIG criteria. It is intended to be used together with
rs_onco_ca125.

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin

**Details**

Supplemental Qualifiers for RS_ONCO_CA125
A SDTM supplemental RS dataset using GCIG criteria. It is intended to be used together with
rs_onco_ca125.

**Author(s)**

Vinh Nguyen

**Source**

Generated dataset (rs_supprs_onco_ca125.R)

## supprs_onco_imwg

*Supplemental Qualifiers for RS_ONCO_IMWG*

**Description**

A SDTM supplemental RS dataset using IMWG criteria intended to be used with rs_onco_imwg

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin

**Details**

Supplemental Qualifiers for RS_ONCO_IMWG
A SDTM supplemental RS dataset using IMWG criteria intended to be used with rs_onco_imwg

**Author(s)**

Vinh Nguyen

**Source**

Access the source of the Supplemental Qualifiers for RS_ONCO_IMWG dataset.

## supptr_onco

*Supplemental Tumor Results for Oncology*

**Description**

A SDTM SUPPTR dataset simulated by Gopi Vegesna

**Usage**

```r
```

**Format**

A data frame with 9 columns:
STUDYID Study Identifier
RDOMAIN Related Domain Abbreviation
USUBJID Unique Subject Identifier
IDVAR Identifying Variable
IDVARVAL Identifying Variable Value
QNAM Qualifier Variable Name
QLABEL Qualifier Variable Label
QVAL Data Value
QORIG Origin

**Details**

Supplemental Tumor Results for Oncology
A SDTM SUPPTR dataset simulated by Gopi Vegesna

**Author(s)**

Gopi Vegesna

**Source**

Access the source of the Supplemental Tumor Results for Oncology dataset.

## sv

*Subject Visits*

**Description**

A SDTM SV dataset from the CDISC pilot project with corrected duplicate observation

**Usage**

```r
```

**Format**

A data frame with 8 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
VISITNUM Visit Number
VISIT Visit Name
VISITDY Planned Study Day of Visit
SVSTDTC Start Date/Time of Visit
SVENDTC End Date/Time of Visit

**Details**

Subject Visits
A SDTM SV dataset from the CDISC pilot project with corrected duplicate observation

**Source**

Constructed by admiralvaccine developers

## tr_onco

*Tumor Results for Oncology*

**Description**

A SDTM TR dataset simulated by Gopi Vegesna

**Usage**

```r
```

**Format**

A data frame with 24 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
TRSEQ Sequence Number
TRGRPID Group ID
TRLNKGRP Link Group
TRLNKID Link ID
TRTESTCD Tumor Assessment Short Name
TRTEST Tumor Assessment Test Name
TRORRES Result or Finding in Original Units
TRORRESU Original Units
TRSTRESC Character Result/Finding in Std Format
TRSTRESN Numeric Result/Finding in Standard Units
TRSTRESU Standard Units
TRSTAT Completion Status
TRREASND Reason Tumor Measurement Not Performed
TRMETHOD Method used to Identify the Tumor
TREVAL Evaluator
TREVALID Evaluator Identifier
TRACPTFL Accepted Record Flag
VISITNUM Visit Number
VISIT Visit Name
TRDTC Date/Time of Tumor Measurement
TRDY Study Day of Tumor Measurement

**Details**

Tumor Results for Oncology
A SDTM TR dataset simulated by Gopi Vegesna
Contains a set of 5 unique Test Short Names and Test Names:
TRTESTCD
TRTEST
DIAMETER
Diameter
LDIAM
Longest Diameter
LPERP
Longest Perpendicular
SUMDIAM
Sum of Diameter
TUMSTATE
Tumor State

**Author(s)**

Gopi Vegesna

**Source**

Generated dataset.

## tr_onco_recist

*Tumor Results (RECIST 1.1) for Oncology*

**Description**

A SDTM TR dataset using RECIST 1.1 intended for examples of ADaM dataset creation

**Usage**

```r
```

**Format**

A data frame with 19 columns:
DOMAIN Domain Abbreviation
STUDYID Study Identifier
USUBJID Unique Subject Identifier
TRGRPID Group ID
TRLNKID Link ID
TRTESTCD Tumor/Lesion Assessment Short Name
TRTEST Tumor/Lesion Assessment Test Name
TRORRES Result or Finding in Original Units
TRORRESU Original Units

TRSTRESC Character Result/Finding in Std Format
TRSTRESN Numeric Result/Finding in Standard Units
TRSTRESU Standard Units
VISITNUM Visit Number
VISIT Visit Name
TREVAL Evaluator
TREVALID Evaluator Identifier
TRACPTFL Accepted Record Flag
TRDTC Date/Time of Tumor/Lesion Measurement
TRSEQ Sequence Number

**Details**

Tumor Results (RECIST 1.1) for Oncology
A SDTM TR dataset using RECIST 1.1 intended for examples of ADaM dataset creation
Contains a set of 3 unique Test Short Names and Test Names:
TRTESTCD
TRTEST
LDIAM
Longest Diameter
LPERP
Longest Perpendicular
TUMSTATE
Tumor State

**Author(s)**

Stefan Bundfuss

**Source**

Generated dataset.

## ts

*Trial Design*

**Description**

A SDTM TS dataset from the CDISC pilot project

**Usage**

```r

```

**Format**

A data frame with 6 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
TSSEQ Sequence Number
TSPARMCD Trial Summary Parameter Short Name
TSPARM Trial Summary Parameter
TSVAL Parameter Value

**Details**

Trial Design
A SDTM TS dataset from the CDISC pilot project

**Source**

Access the source of the Trial Design dataset.

## tu_onco

*Tumor Identification for Oncology*

**Description**

A SDTM TU dataset simulated by Gopi Vegesna

**Usage**

```r
```

**Format**

A data frame with 18 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
TUSEQ Sequence Number
TULNKID Link ID
TUTESTCD Tumor Identification Short Name
TUTEST Tumor Identification Test Name
TUORRES Tumor Identification Result
TUSTRESC Tumor Identification Result Std. Format

TULOC Location of the Tumor
TUMETHOD Method of Identification
TUEVAL Evaluator
TUEVALID Evaluator Identifier
TUACPTFL Accepted Record Flag
VISITNUM Visit Number
VISIT Visit Name
TUDTC Date/Time of Tumor Identification
TUDY Study Day of Tumor Identification

**Details**

Tumor Identification for Oncology
A SDTM TU dataset simulated by Gopi Vegesna
Contains a set of 1 unique Test Short Name and Test Name:
TUTESTCD
TUTEST
TUMIDENT
Tumor Identification

**Author(s)**

Gopi Vegesna

**Source**

Generated dataset.

## tu_onco_recist

*Tumor Identification (RECIST 1.1) for Oncology*

**Description**

A SDTM TU dataset using RECIST 1.1 intended for examples of ADaM dataset creation

**Usage**

```r

```

**Format**

A data frame with 16 columns:
DOMAIN Domain Abbreviation
STUDYID Study Identifier
USUBJID Unique Subject Identifier
VISIT Visit Name
VISITNUM Visit Number
TULOC Location of the Tumor/Lesion
TUTESTCD Tumor/Lesion ID Short Name
TUTEST Tumor/Lesion ID Test Name
TUORRES Tumor/Lesion ID Result
TUSTRESC Tumor/Lesion ID Result Std. Format
TUMETHOD Method of Identification
TULNKID Link ID
TUEVAL Evaluator
TUEVALID Evaluator Identifier
TUACPTFL Accepted Record Flag
TUSEQ Sequence Number

**Details**

Tumor Identification (RECIST 1.1) for Oncology
A SDTM TU dataset using RECIST 1.1 intended for examples of ADaM dataset creation
Contains a set of 1 unique Test Short Name and Test Name:
TUTESTCD
TUTEST
TUMIDENT
Tumor Identification

**Author(s)**

Stefan Bundfuss

**Source**

Generated dataset.

## vs

*Vital Signs*

**Description**

A SDTM VS dataset from the CDISC pilot project

**Usage**

```r
```

**Format**

A data frame with 24 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

Vital Signs
A SDTM VS dataset from the CDISC pilot project
Contains a set of 6 unique Test Short Names and Test Names:
VSTESTCD
VSTEST
DIABP
Diastolic Blood Pressure
HEIGHT
Height
PULSE
Pulse Rate
SYSBP
Systolic Blood Pressure
TEMP
Temperature
WEIGHT
Weight

**Source**

Generated dataset.

## vs_metabolic

*Vital signs Dataset-metabolic*

**Description**

A SDTM VS dataset for metabolic studies

**Usage**

```r
```

**Format**

A data frame with 24 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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

Vital signs Dataset-metabolic
A SDTM VS dataset for metabolic studies
Contains a set of 9 unique Test Short Names and Test Names:
VSTESTCD
VSTEST
BMI
Body Mass Index
DIABP
Diastolic Blood Pressure
HEIGHT
Height
HIPCIR
Hip Circumference
PULSE
Pulse Rate
SYSBP
Systolic Blood Pressure
TEMP
Temperature
WEIGHT
Weight
WSTCIR
Waist Circumference

**Source**

Constructed by admiralmetabolic developers

## vs_peds

*Vital signs Dataset-pediatrics*

**Description**

An updated SDTM VS dataset with anthropometric measurements for pediatric patients

**Usage**

```r
```

**Format**

A data frame with 26 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
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
VSEVAL Evaluator
EPOCH Epoch

**Details**

Vital signs Dataset-pediatrics
An updated SDTM VS dataset with anthropometric measurements for pediatric patients
Contains a set of 4 unique Test Short Names and Test Names:
VSTESTCD
VSTEST
BMI
BMI
HDCIRC
Head Circumference
HEIGHT
Height
WEIGHT
Weight

**Source**

Constructed by admiralpeds developers

## vs_vaccine

*Vital Signs for Vaccine*

**Description**

An example SDTM VS dataset for vaccine studies

**Usage**

```r
```

**Format**

A data frame with 23 columns:
STUDYID Study Identifier
DOMAIN Domain Abbreviation
USUBJID Unique Subject Identifier
VSSEQ Sequence Number
VSLNKID Link ID
VSLNKGRP Link Group ID
VSTESTCD Vital Signs Test Short Name
VSTEST Vital Signs Test Name
VSCAT Category for Vital Signs
VSSCAT Subcategory for Vital Signs
VSORRES Result or Finding in Original Units
VSORRESU Original Units
VSSTRESC Character Result/Finding in Std Format

VSSTRESN Numeric Result/Finding in Standard Units
VSSTRESU Standard Units
VSEVAL Evaluator
VSLOC Location of Vital Signs Measurement
EPOCH Epoch
VSDTC Date/Time of Measurements
VSDY Study Day of Vital Signs
VSTPT Planned Time Point Name
VSTPTNUM Planned Time Point Number
VSTPTREF Time Point Reference

**Details**

Vital Signs for Vaccine
An example SDTM VS dataset for vaccine studies
Contains a set of 1 unique Test Short Name and Test Name:
VSTESTCD
VSTEST
TEMP
Temperature

**Source**

Constructed by admiralvaccine developers
