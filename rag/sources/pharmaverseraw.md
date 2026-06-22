---
title: "pharmaverseraw"
version: "0.1.1"
package_title: "Raw Data for 'pharmaversesdtm' Package"
description: "A set of raw datasets used to create SDTM domains in 'pharmaversesdtm' package."
---

# pharmaverseraw

*Raw Data for 'pharmaversesdtm' Package*

A set of raw datasets used to create SDTM domains in 'pharmaversesdtm' package.

## ae_raw

*Adverse Events Raw Dataset*

**Description**

A raw dataset used to create pharmaversesdtm::ae

**Usage**

```r
```

**Format**

A data frame with 32 columns:
STUDY Study Identifier
PATNUM Patient Number
FOLDER Folder
FOLDERL Folder Label
IT.AETERM Reported Term for the Adverse Event
AEOUTCOME Outcome of Adverse Event
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
IT.AESEV Severity/Intensity
IT.AESER Serious Event
IT.AEREL Causality
IT.AEACN Action Taken with Study Treatment
AESCAN Involves Cancer
AESCNO Congenital Anomaly or Birth Defect
AEDIS Persist or Signif Disability/Incapacity

IT.AESDTH Results in Death
IT.AESHOSP Requires or Prolongs Hospitalization
IT.AESLIFE Is Life Threatening
AESOD Occurred with Overdose
AEDTCOL Date/Time of Collection
IT.AESTDAT Start Date/Time of Adverse Event
IT.AEENDAT End Date/Time of Adverse Event

**Details**

Adverse Events
A raw dataset used to create pharmaversesdtm::ae

**Author(s)**

Shiyu Chen

**Source**

Access the source of the adverse events dataset.

## dm_raw

*Demographics Raw Dataset*

**Description**

A raw dataset used to create pharmaversesdtm::dm

**Usage**

```r
```

**Format**

A data frame with 13 columns:
STUDY Study Identifier
PATNUM Patient Number
IT.AGE Age
IT.SEX Sex
IT.ETHNIC Ethnicity
IT.RACE Race
COUNTRY Country
PLANNED_ARM Planned Arm

PLANNED_ARMCD Planned Arm Code
ACTUAL_ARM Actual Arm
ACTUAL_ARMCD Actual Arm Code
COL_DT Date of Collection
IC_DT Date of Informed Consent

**Details**

Demographics
A raw dataset used to create pharmaversesdtm::dm

**Author(s)**

Shiyu Chen

**Source**

Access the source of the demographics dataset.

## ds_raw

*Subject Disposition Raw Dataset*

**Description**

A raw dataset used to create pharmaversesdtm::ds

**Usage**

```r
```

**Format**

A data frame with 13 columns:
STUDY Study Identifier
PATNUM Patient Number
SITENM Site Name
INSTANCE Instance
FORM Form
FORML Form Label
IT.DSTERM Reason for Discontinuation
IT.DSDECOD Discontinuation Code
OTHERSP Other Reason for Discontinuation
DSDTCOL Date of Collection
DSTMCOL Time of Collection
IT.DSSTDAT Start Date of Subject Disposition
DEATHDT Death Date of Subject

**Details**

Subject Disposition
A raw dataset used to create pharmaversesdtm::ds

**Author(s)**

Shiyu Chen

**Source**

Access the source of the subject disposition dataset.

## ec_raw

*Exposure as Collected Raw Dataset*

**Description**

A raw dataset used to create pharmaversesdtm::ex

**Usage**

```r
```

**Format**

A data frame with 14 columns:
STUDY Study Identifier
PATNUM Patient Number
VISITNAME Visit Name
FOLDER Folder
FOLDERL Folder Label
IT.ECREFID Study Treatment Label Identifier
DRUGAD Drug Administered
IT.ECSTDAT Study Treatment Start Date
IT.ECENDAT Study Treatment End Date
IT.ECDSTXT Dose of Study Treatment
IT.ECDOSU Dose Unit of Study Treatment
DOSFM Dose Form of Study Treatment
DOSFRQ Dose Frequency of Study Treatment
IT.ECROUTE Route of Administration

**Details**

Exposure as Collected
A raw dataset used to create pharmaversesdtm::ex

**Author(s)**

Shiyu Chen

**Source**

Access the source of the exposure as collected dataset.

## vs_raw

*Vital Signs Raw Dataset*

**Description**

A raw dataset used to create pharmaversesdtm::vs

**Usage**

```r
```

**Format**

A data frame with 15 columns:
STUDY Study Identifier
PATNUM Patient Number
INSTANCE Folder
FORM Form
FORML Form Label
VTLD Vital Signs Collection Date
IT.HEIGHT_VSORRES Height
IT.WEIGHT Weight
IT.TEMP Temperature
IT.TEMP_LOC Temperature Location
TMPTC Timepoint
SYS_BP Systolic Blood Pressure
DIA_BP Diastolic Blood Pressure
PULSE Pulse
SUBPOS Subject Position

**Details**

Vital Signs
A raw dataset used to create pharmaversesdtm::vs

**Author(s)**

Shiyu Chen & Rammprasad Ganapathy

**Source**

Access the source of the vital signs dataset.
