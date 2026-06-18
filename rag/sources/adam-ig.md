---
title: "ADaM-IG"
version: "1.3"
package_title: "CDISC ADaM Implementation Guide v1.3"
description: "Analysis Data Model Implementation Guide v1.3 — standard ADaM variables, ADSL and Basic Data Structure (BDS) variable specifications, naming fragments, flag and timing conventions for analysis datasets."
---

# ADaM-IG

*CDISC Analysis Data Model Implementation Guide, version 1.3.* Reference extract: standard variable conventions, ADSL and BDS variable specifications, and naming fragments.

# ADaM-IG Variable Conventions


## 3.1.1 General Variable Conventions

1. To ensure compliance with SAS Version 5 transport file format and Oracle constraints, all ADaM variable names must be no more than 8 characters in length, start with a letter (not underscore), and be composed only of letters (A-Z), underscore ( _ ), and numerals (0-9). All ADaM variable labels must be no more than 40 characters in length. All ADaM character variables must be no more than 200 characters in length.

2. The lower-case letters "w", "xx", "y", and "zz" that appear in a variable name or label in this document must be replaced in the actual variable name or label using the following conventions:

b. The letters "xx" in a variable name (e.g., TRTxxP, APxxSDT) refer to a specific period where "xx" is replaced with a zero-padded 2-digit integer [01–99]. The use of "xx" within a variable name is restricted to the concept of a period, and "xx" is not considered an index.

c. The lower-case letter "y" in a variable name (e.g., SITEGRy) refers to a grouping or other categorization scheme, an analysis criterion, or an analysis range, and is replaced with an integer [1–99, not zero-padded]. Truncation of the original variable name may be necessary in rare situations when a 2-digit index is needed and causes the length of the variable name to exceed 8 characters. In these situations, it is recommended that the same truncation be used for both the character and numeric versions of the variables in a variable pair.

d. The lower-case letters "zz" in a variable name (e.g., ANLzzFL) are an index for the zzth variable where "zz" is replaced with a zero-padded 2-digit integer [01-99]. Note that the "zz" convention represents a simple counter, while the "xx" convention represents a specific period.

e. If an indexed variable is included in a dataset, there is no requirement that the preceding variable(s) in the sequence be included. For example, a dataset might include ANL02FL but not ANL01FL.

3. Any variable in an ADaM dataset whose name is the same as an SDTM variable must be a copy of the SDTM variable, and its label, meaning, and values must not be modified. ADaM adheres to a principle of harmonization known as "same name, same meaning, same values." However, to optimize file size, it is permissible that the length of the variables differ (e.g., trailing blanks may be removed). In many cases it makes sense to copy over a variable from an SDTM dataset. For example, the SDTM variable --SEQ may be useful for traceability. However, in other cases, it is also perfectly acceptable, and might be much better, to create an ADaM variable with a meaningful variable name and clear and unambiguous metadata. An SDTM variable may be somewhat meaningless when removed from its SDTM context. For example, the meaning of the SDTM variable DSDECOD may depend on other SDTM variables such as DSCAT and DSSCAT, and ultimately on how the data were collected and mapped to SDTM in a particular study; thus it may be better to create a clearly defined ADaM variable. In any case, whenever values are modified in any way, it is mandatory to do so in an ADaM variable, and it is prohibited to do so in a variable whose name is that of an SDTM variable.

4. When an ADaM standard variable name has been defined for a specific concept, the ADaM standard variable name must be used, even if the content of an ADaM variable is a direct copy of the content of an SDTM variable. For example, in the creation of an ADaM dataset based on an SDTM LB dataset, even if AVAL is just a copy of LBSTRESN, the dataset must contain AVAL.

5. For variable pairs designated as having a one-to-one relationship within a specified scope (e.g., within a parameter, within a study), if both variables are present in the dataset and there exists a row in that scope on which both variables are populated, then there must be a one-to-one relationship between the two variables on all rows within the scope on which both variables are populated. The scope noted in this document should be considered the minimum level for the mapping; it does not preclude the producer from using a broader level of scope. For example, if a one-to-one relationship is specified as within a PARAM, the producer may elect to use the same one-to-one relationship across all PARAMs within the dataset or study. In addition, note that "within a parameter" means "within a parameter within a dataset."

6. In a pair of corresponding variables (e.g., TRTP and TRTPN), the primary or most commonly used variable does not have the suffix or extension (i.e., N for numeric or C for character). The relevant suffix is used only on the name of the secondary member of the variable pair. For example, in the (TRTP, TRTPN) pair, the primary variable, TRTP, is character, but it is not named TRTPC. Similarly in the (APERIOD, APERIODC) pair, the primary variable, APERIOD, is numeric, but it is not named APERIODN. When a secondary variable is included in the dataset, then the primary variable must also be included. . If both variables of a variable pair are present, there must be a one-to-one relationship between the values of the two variables, as described in Item 5 above.

7. In general, if an SDTM character variable is converted to a numeric variable in an ADaM dataset, then it should be named as it is in the SDTM dataset with an "N" suffix added. For example, the numeric version

8. Variables whose names end in FL are character flag (or indicator) variables with at most two possible nonmissing values, Y or N (i.e., yes or no). The name of the corresponding numeric flag (or indicator) variable ends in FN. If the flag is included in an ADaM dataset, the character version (*FL) is required but the corresponding numeric version (*FN) can also be included. If both versions of the flag are included, there must be a one-to-one relationship between the values of the two variables, as described in Section 3.1.4, Flag Variable Conventions.

9. Variables whose names end in GRy, Gy, or CATy are grouping variables, where "y" refers to the grouping scheme or algorithm (not the category within the grouping). For example, SITEGR3 is the name of a variable containing site group (pooled site) names, where the grouping has been done according to the third site-grouping algorithm; SITEGR3 does not mean the third group of sites. Within this document, CATy is the suffix used for categorization of ADaM-specified analysis variables (e.g., CHGCATy categorizes CHG).

10. It is recommended that producer-defined grouping or categorization variables begin with the name of the variable being grouped and end in GRy (e.g., variable ABCGRy is a character description of a grouping or categorization of the values from the ABC variable for analysis purposes). If any grouping of values from an SDTM variable is done, the name of the derived ADaM character grouping variable should begin with the SDTM variable name and end in GRy (GRyN for the numeric equivalent) where y is an integer [1-99, not zero-padded] representing a grouping scheme. For example, if a character analysis variable is created to contain values of Caucasian and Non-Caucasian from the SDTM RACE variable, then it should be named RACEGRy and its numeric equivalent should be named RACEGRyN (e.g., RACEGR1, RACEGR1N). As described in Table 3.1.5.1, Gy can be used as an abbreviated form of GRy when the use of GRy would create a variable name longer than 8 characters. Truncation of the original variable name may be necessary when appending suffix fragments GRy, GRyN, Gy, or GyN.

## 3.1.2 Timing Variable Conventions

1. Numeric date, time, and datetime variables should be formatted, so as to be human-readable with no loss of precision.

2. Variables whose names end in DT are numeric dates.

3. Variables whose names end in DTM are numeric datetimes.

4. Variables whose names end in TM are numeric times.

5. If a *DTM and associated *TM variable exist, then the *TM value must match the time part of the *DTM value when the *DTM variable is populated. If a *DTM and associated *DT variable exist, then the *DT value must match the date part of the *DTM value when the *DTM variable is populated.

6. Names of timing start variables end with an S followed by the characters indicating the type of timing (i.e., SDT, STM, SDTM), unless otherwise specified elsewhere in Section 3, Standard ADaM Variables.

7. Names of timing end variables end with an E followed by the characters indicating the type of timing (i.e., EDT, ETM, EDTM), unless otherwise specified elsewhere in Section 3, Standard ADaM Variables.

8. Variables whose names end in DY are relative day variables. In the ADaM as in the SDTM, there is no Day 0. If there is a need to create a relative day variable that includes Day 0, then its name must not end in DY.

9. ADaM relative day variables need not be anchored by DM.RFSTDTC. The anchor (i.e., reference) date variable must be indicated in the variable-level metadata for the relative day variable. The anchor date

10. Table 3.3.3.3 presents standard suffix naming conventions for producer-defined supportive variables

containing numeric dates, times, datetimes, and relative days, as well as date and time imputation flags. These conventions are applicable to all ADaM datasets. The asterisk that appears in a variable name in the table must be replaced by a suitable character string, so that the actual variable name is meaningful and complies with the restrictions noted in Section 3.1.1, General Variable Conventions.

11. The reader is cautioned that the root or prefix (represented by *) of such producer-specified supportive ADaM date, time and datetime variable names must be chosen with care, to prevent unintended conflicts among other such names and standard numeric versions of possible SDTM variable names. In particular, potentially problematic values for producer-defined roots/prefixes (*) include:

a. One-letter prefixes. For an example of the problem, if * is Q, then a date *DT would be QDT; however, a starting date *SDT would be QSDT, which would potentially be confusing if the producer intended QSDT to be something other than the numeric date version of the SDTM variable QSDTC.

b. Two-letter prefixes, except when intentionally chosen to refer explicitly to a specific SDTM

domain and its --DTC, --STDTC, and/or --ENDTC variables. For an example of an appropriate intentional use of a 2-letter prefix, if * is LB, then *DT is LBDT, the numeric date version of SDTM variable LBDTC. For an example of the problem, if * is QQ, then a date *DT would be QQDT, which would potentially be confusing if the producer intended QQDT to be something other than the numeric date version of a potential SDTM variable QQDTC.

c. Three-letter prefixes ending in S or E. For an example of the problem, if * is QQS, then a date *DT would be QQSDT, which would potentially be confusing if the producer intended QQSDT to be something other than the numeric date version of a potential SDTM variable QQSTDTC.

12. In general, all 3 (*DT, *TM, *DTM) are not required. Include only the *DT, *TM, and *DTM variables needed for analysis or review. However, when a *DTM variable exists, it is good practice to include a corresponding *DT variable.

For more information regarding date and time variable conventions, refer to Table 3.3.3.3.

## 3.1.3 Date and Time Imputation Flag Variables

When a date or time is imputed, it is required that the variable containing the imputed value be accompanied by a date or time imputation flag variable. The variable fragments to be used for these variables are DTF and TMF, as defined in Table 3.1.5.1. DF and TF can be used as abbreviated forms of DTF and TMF, respectively, when the use of DTF or TMF would create a variable name longer than 8 characters. These additional imputation flag variables are conditionally required. The root, identified by "*", of the names of each pair of variables, *DT and *DTF (or *DF), should be identical. The same is true for the corresponding time and imputation flag variables *TM and *TMF (or *TF). Thus it is good practice to limit roots to 5 characters in length.

Section 3 contains sets of timing variables which share a common prefix, such as TRTSDT, TRTSTM, and TRTSDTM. It should be noted that in many instances in Section 3, specific DTF and TMF flags are defined within sets of timing variables. However, imputation flags should be created for all date or time variables when imputation has been performed, even if there is not a specific imputation flag variable mentioned in Section 3. For example, the imputation flag variable has not been listed for EOSDT, but EOSDTF must be present if date imputation was performed.

1. As described in Table 3.1.5.1, variables whose names end in DTF are date imputation flags. *DTF

variables represent the highest level of imputation of the *DT variable based on the source SDTM dataset DTC variable. *DTF = Y if the year is imputed. *DTF = M if year is present and month is imputed. *DTF = D if only day is imputed. *DTF = null if *DT equals the SDTM dataset DTC variable date part

Table 3.1.3.1 Some Examples of Setting of Date Imputation Flag

Missing Elements SDTM --DTC String ADaM Date Value (*DT Variable)a,b (## indicates imputed portion)

Imputation flag (*DTF variable)

None YYYY-MM-DD YYYY-MM-DD Blank Day YYYY-MM YYYY-MM-## D Month YYYY---DD YYYY-##-DD M Month and Day YYYY YYYY-##-## M Year --MM-DD ####-MM-DD Y Year and Month ----DD ####-##-DD Y Year and Month and Day ####-##-## Y

aThe ISO formats used in the ADaM Date Value column are for the purposes of illustration, and are not intended to imply any type of display standard or requirement. The DT variable is numeric and the producer will determine the appropriate display format.

bThe indication of imputed values is not intended to imply an imputation rule or standard. For example, if the month is missing, imputation rules might specify that the collected day value be ignored so that both month and day are imputed.

2. As described in Table 3.1.5.1, variables whose names end in TMF are time imputation flags. *TMF

variables represent the level of imputation of the *TM (and *DTM) variable based on the source SDTM dataset DTC variable. *TMF = H if the entire time is imputed. *TMF = M if minutes and seconds are imputed. *TMF = S if only seconds are imputed. *TMF = null if *TM equals the SDTM DTC variable time part equivalent. For a given SDTM DTC variable, if only hours and minutes are ever collected, and seconds are imputed in *DTM as 00, then it is not necessary to set *TMF to "S". However if seconds are generally collected but are missing in a given value of the DTC variable and imputed as 00, or if a collected value of seconds is changed in the creation of *DTM, then *TMF should be set to "S". If a time was imputed *TMF must be populated and is required. Both *DTF and *TMF may be needed to describe the level of imputation in *DTM if imputation was done.

Note that using SDTM --DTC source variables for comparison purposes in analysis algorithms may be problematic in the presence of missing date or time elements. SDTM --DTC variables containing date, time, and datetime values are character strings that, in the presence of missing elements (i.e., year, month, day, hour, minute, second), sort or compare in a manner that may be equivalent to imputation of missing elements with the lowest possible value. For example, if in a given --DTC variable in a dataset, dates are present on all records but time is missing on some records, then within any given date, the records with missing time may sort or compare before the records that contain a value of time. Thus the --DTC variable would sort or compare in a manner that is equivalent to imputing midnight when time is missing. The sort or comparison may work mechanically, but imputing midnight may not be the most appropriate thing to do for statistical analysis. Further, the effective imputation of midnight would be hidden and not made explicit. It is important to consider the implications of implicit or explicit imputation whenever dates, times, or datetimes are compared or sorted.

## 3.1.4 Flag Variable Conventions

1. The terms "flag" and "indicator" are used interchangeably within this document, and "flag variables" are sometimes referred to simply as "flags."

2. Population flags must be included in a dataset if the dataset is analyzed by the given population. At least 1 population flag is required for datasets used for analysis. A character indicator variable is required for every population that is defined in the statistical analysis plan (SAP). All applicable subject-level population flags must be present in the ADSL.

3. Character and numeric subject-level population flag names end in FL and FN, respectively. Similarly, parameter-level population flag names end in PFL and PFN, and record-level population flag names end in RFL and RFN. Please also refer to Item 8 in Section 3.1.1, General Variable Conventions.

4. For subject-level character population flag variables: N = no (not included in the population), Y = yes (included). Null values are not allowed.

6. For parameter-level and record-level character population flag variables: N = no (not included), Y = yes (included). Null values are allowed.

7. For parameter-level and record-level numeric population flag variables, 0 = no (not included), 1 = yes (included). Null values are allowed.

8. In addition to the population flag variables defined in Section 3, Standard ADaM Variables, other

population flag variables may be added to ADaM datasets as needed, and must comply with these conventions.

9. For character flags with variable names that end in FL and that are not population flags, a scheme of Y/N/null, or Y/null may be specified. As indicated in Tables 3.3.4.3.1 and 3.3.8.1, some common character flags use the scheme Y/null. The choice of Y/N/null vs Y/null is dependent on analysis needs. Y/N/null should be used when N and null values need to be analyzed differently. Y/null can be used when the need is to analyze just the Y values. Corresponding 1/0/null and 1/null schemes apply to numeric flags with variable names that end in FN and which are not population indicators.

10. Additional flags may be added if their names and values comply with these conventions.

## 3.1.5 Variable Naming Fragments

Table 3.1.5.1 contains a list of standard suffix fragments (i.e., variable name fragments used as the last part of a variable name) that are required when naming variables in ADaM datasets, as defined in Section 3.1, ADaM Variable Conventions. For these fragments, it is a requirement that the appropriate fragment be used whenever the concept applies and that the fragment is reserved to be used only for the corresponding concept. For example, a variable whose name ends in DT must contain a numeric date, and a variable created to contain a numeric date must have a name ending in DT.

Table 3.1.5.1 Required Suffix Fragments for Use in Naming ADaM Variables

Fragment CDISC Notes

GRy Suffix used in names of grouping variables, where "y" refers to the grouping scheme or algorithm (not the category within the grouping). Note that GRy can be abbreviated to Gy when necessary to comply with the variable name length limit of 8 characters. The corresponding numeric version of the variable will use the suffix GRyN (or GyN if the Gy abbreviation is used). For more information on grouping variables see Section 3.1.1, General Variable Conventions. See Table 3.2.2 for examples of grouping variables.

FL Suffix used in names of character flag variables, when the valid values of the variable are Y/null or Y/N/null. The corresponding numeric version of the variable will use the suffix FN. For more information on flag variables, see Section 3.1.1, General Variable Conventions, and Section 3.1.4, Flag Variable Conventions. See Table 3.2.3, Table 3.3.4.3.1, and Table 3.3.8.1 for examples of flag variables.

DT Suffix used in names of numeric date variables. For more information on timing variables, see Section 3.1.2, Timing Variable Conventions. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing variables.

TM Suffix used in names of numeric time variables. For more information on timing variables, see Section 3.1.2, Timing Variable Conventions. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing variables. Note that although ADaM variable ARELTM ends in TM, it is an exception, and is not a numeric time variable. In addition, the SDTM variables -- ELTM are not numeric time variables.

DTM Suffix used in names of numeric datetime variables. For more information on timing variables, see Section 3.1.2, Timing Variable Conventions. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing variables.

DTF Suffix used in names of date imputation flag variables. Note that DTF can be abbreviated to DF to comply with the variable name length limit of 8 characters. For more information, see Section 3.1.3, Date and Time Imputation Flag Variables. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing imputation variables.

TMF Suffix used in names of time imputation flag variables. Note that TMF can be abbreviated to TF to comply with the variable name length limit of 8 characters. For more information, see Section 3.1.3, Date and Time Imputation Flag Variables. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing imputation variables.

DY Suffix used in names of relative day variables that do not include day 0. For more information on timing variables, see Section 3.1.2, Timing Variable Conventions. See Section 3.3.3, Timing Variables for BDS Datasets, for examples of timing variables.

Table 3.1.5.2 contains a list of additional standard reserved fragments to use as a guide when naming variables in ADaM datasets. This list should be used in addition to the list of timing fragments defined in Table 3.3.3.3 and the

Table 3.1.5.2 Additional Fragments that May Be Used in Naming ADaM Variables

Fragment CDISC Notes

BL Baseline. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable. Not to be used to support more than one baseline definition for AVAL in BDS datasets. See paragraph immediately following this table.

CHG Change. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable. Not to be used to support change from more than one baseline for AVAL in BDS datasets. See paragraph immediately following this table.

FU Follow-up. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

OT On treatment. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

RU Run-in. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

SC Screening. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

TA Taper. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

TI Titer. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

U Units. The position of this fragment is at the end of the variable, as a suffix. To identify the units for a variable, a separate variable can be created, using the name of the original variable with a "U" suffix added. To keep within the 8-character variable name length limit, some truncation may be necessary prior to appending the U. In situations where the units do not vary within the ADaM dataset, it may be preferable to simply include the units in the variable's label and metadata. The approach taken will be determined by the producer, based on the requirements of the analysis and review of the dataset. Note that there is no separate units variable for BDS variables PARAM or AVAL, since the units of AVAL will be included in the value of PARAM.

WA Washout. As described below, the position of this fragment within the variable name is dependent on the purpose of the variable.

Note that in BDS datasets, there is only one baseline variable, BASE, and only one change from baseline variable, CHG. The BL and CHG fragments must not be used to create BDS variables containing alternative baselines and changes from baseline for AVAL. Additional definitions of baseline relevant to a given parameter must be accommodated by the addition of rows rather than addition of variables. See Section 3.3.4, Analysis Parameter Variables for BDS Datasets, and Section 4.2.1.6, Rule 6. However, if the baseline or change from baseline of a different parameter is needed in the analysis of a given parameter, for example, as a covariate in an analysis of covariance, that analysis-enabling variable may be added and its name should contain the fragment BL or CHG.

There are 2 main categories of variable names relative to timepoints: content at a particular timepoint (e.g., weight at baseline) and timepoint timing (e.g., screening date). Assembly of these types of variable names using timing fragments defined in Table 3.1.5.2 is as follows:

Content at a timepoint: Because the timing of a variable qualifies the content of the variable, timing fragments are used as the variable name suffix. The complete variable naming convention is *(xx)FF, where * represents the content of the variable (up to 4 characters) and FF represents the timing fragment. For any timing fragments that are repeated for multiple periods, the period number (xx) should be placed before the suffix. If period numbers are not needed, the variable will be of the form *FF, with * representing the content of the variable (up to 6 characters)

Timepoint timing: If timepoint variables are needed that would use these timing fragments, the timing fragments will become the prefix of the variable name. For dates, then, the structure of the variable name is FF(xx)*, where * represents the date fragment (e.g., DT, SDT, EDTM, etc.; up to 4 characters) and FF represents the timing fragment. This scheme is consistent with ADSL timepoint variables such as RANDDT, TR01SDT.

Some examples of variable names that follow these guidelines are

# ADaM-IG Variables


## ADSL Variables

• WEIGHTSC or WTSC – Screening weight. Other abbreviations of weight are also acceptable.

• RUSDT – Run-in start date, using the timing fragment as the prefix in a timing variable as defined in Table 3.3.3.3.

• WA01SDT, WA01EDT, WA02SDT, and WA02EDT – Washout start and end dates for two periods, using the timing fragment as the prefix in a timing variable as defined in Table 3.3.3.3.

3.1.6 Additional Information about Section 3

In general, the variable labels specified in Section 3, Standard ADaM Variables, are required. There are only 2 exceptions to this rule:

1. Descriptive text is allowed at the end of the labels of variables whose names contain indexes "y" or "zz"; and

2. Variable labels containing a word or phrase in curly brackets, e.g., {Time} (the label for *TM variables), should be replaced by the producer with appropriate text. The label must contain the bracketed word or phrase somewhere in the text. For example, *STM must use the phrase "Start Time" in the label, so labels such as "Start Time of Rescue Med" or "Rescue Med Start Time" are both valid.

It is important to note that the standard variable labels by no means imply the use of standard derivation algorithms across studies and/or producers.

It should be noted that when the CDISC Notes for a variable refer to another variable, it is understood that this means "on the same record or row." For example, "The numeric code for TRTP" is understood to mean "The numeric code for TRTP on the same record."

Controlled Terminology has been developed for the values of certain ADaM variables. The most current CDISC terminology sets can be accessed via the CDISC website (http://www.cdisc.org/terminology). In the tables in this section, the parenthesized external codelist name appears in the Codelist/ Controlled Terms column, where relevant. Examples of controlled terms in this document should be considered examples only; the official source is the most current CDISC set available through the website.

Note that CDISC Controlled Terminology sets cannot represent null (absence of a value) in the list of valid terms because "null" is not a term. However, unless specified in the definition for a specific variable, null is allowed.

Additional variables not defined in this section, may be necessary (e.g., to enable analysis, to support traceability, to facilitate presentation of the data), and may therefore be added to ADaM datasets, providing that they adhere to the ADaM naming conventions and rules as defined in this document.

3.2 ADSL Variables

As previously noted, an ADaM-compliant ADSL dataset and its related metadata are required in a CDISC-based submission of data from a clinical trial even if no other ADaM datasets are submitted. The structure of the ADSL is 1 record per subject, regardless of the type of clinical trial design.

This section lists standard ADSL variables. Section 2.3.1, The ADaM Subject-Level Analysis Dataset (ADSL), describes the content of the ADSL and addresses the kinds of variables that are and are not appropriate for inclusion in the ADSL. Within a given study, USUBJID is the key variable that links the ADSL to other datasets (both SDTM and ADaM).

For ADSL variables, the scope is "within the study." For example, the definition of SITEGR1 is consistent for all datasets within a study. It is acknowledged that the scope of USUBJID extends beyond the study, as defined in the SDTM.

There may be situations where highly derived variables are to be included in the ADSL yet the derivation of these variables may better be performed in another ADaM dataset. For example, consider the analysis need to include the baseline value of a derived parameter that is a composite score based on up to seven other parameters. These

### ADSL Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Req | DM.STUDYID |
| USUBJID | Unique Subject Identifier | Char |  | Req | DM.USUBJID |
| SUBJID | Subject Identifier for the Study | Char |  | Req | DM.SUBJID. SUBJID is required in ADSL, but permissible in other datasets. |
| SITEID | Study Site Identifier | Char |  | Req | DM.SITEID. SITEID is required in ADSL, but permissible in other datasets. |
| SITEGRy | Pooled Site Group y | Char |  | Perm | Character description of a grouping or pooling of clinical sites for analysis purposes. For example, SITEGR3 is the name of a variable containing site group (pooled site) names, where the grouping has been done according to the third site grouping algorithm, defined in variable metadata; SITEGR3 does not mean the third group of sites. |

### ADSL Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SITEGRyN | Pooled Site Group y (N) | Num |  | Perm | Numeric representation of SITEGRy. There must be a one-to-one relationship between SITEGRyN and SITEGRy within a study. SITEGRyN cannot be present unless SITEGRy is also present. When SITEGRy and SITEGRyN are present, then on a given record, either both must be populated or both must be null. |
| REGIONy | Geographic Region y | Char |  | Perm | Character description of geographical region. For example, REGION1 might have values of "Asia", "Europe", "North America", "Rest of World"; REGION2 might have values of "United States", "Rest of World". |
| REGIONyN | Geographic Region y (N) | Num |  | Perm | Numeric representation of REGIONy. Orders REGIONy for analysis and reporting.There must be a one-to- one relationship between REGIONyN and REGIONy within a study. REGIONyN cannot be present unless REGIONy is also present. When REGIONy and REGIONyN are present, then on a given record, either both must be populated or both must be null. |

### ADSL Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AGE | Age | Num |  | Req | DM.AGE. If analysis needs require a derived age that does not match DM.AGE, then AAGE must be added |
| AGEU | Age Units | Char | (AGEU) | Req | DM.AGEU |
| AGEGRy | Pooled Age Group y | Char |  | Perm | Character description of a grouping or pooling of the subject's age for analysis purposes. For example, AGEGR1 might have values of "<18", "18-65", and ">65"; AGEGR2 might have values of "Less than 35 y old" and "At least 35 y old". |
| AGEGRyN | Pooled Age Group y (N) | Num |  | Perm | Numeric representation of AGEGRy. Orders the grouping or pooling of subject age for analysis and reporting. There must be a one-to-one relationship between AGEGRyN and AGEGRy within a study. AGEGRyN cannot be present unless AGEGRy is also present. When AGEGRy and AGEGRyN are present, then on a given record, either both must be populated or both must be null. |

### ADSL Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AAGE | Analysis Age | Num |  | Cond | Age used for analysis that may be derived differently than DM.AGE. AAGE is required if age is calculated differently than DM.AGE. |
| SEX | Sex | Char | (SEX) | Req | DM.SEX. |
| RACE | Race | Char | (RACE) | Req | DM.RACE. |
| RACEGRy | Pooled Race Group y | Char |  | Perm | Character description of a grouping or pooling of the subject's race for analysis purposes. |
| RACEGRyN | Pooled Race Group y (N) | Num |  | Perm | Numeric representation of RACEGRy. Orders the grouping or pooling of subject race for analysis and reporting. There must be a one-to-one relationship between RACEGRyN and RACEGRy within a study. RACEGRyN cannot be present unless RACEGRy is also present. When RACEGRy and RACEGRyN are present, then on a given record, either both must be populated or both must be null. |

### ADSL Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| FASFL | Full Analysis Set Population Flag | Char | Y, N | Cond | These flags identify whether or not the subject is included in the specified population. A minimum of one subject-level population flag variable is required in ADSL. Not all of the indicators listed here need to be included in ADSL. As stated in Section 3.1.4, Flag Variable Conventions, only those indicators corresponding to populations defined in the statistical analysis plan or populations used as a basis for analysis need be included in ADSL. This list of flags is not meant to be all-inclusive. Additional population flags may be added. The values of subject-level population flags cannot be blank. If a flag is used, the corresponding numeric version (*FN, where 0 = No and 1 = Yes) of the population flag can also be included. Please also refer to Section 3.1.4, Flag Variable Conventions. |
| SAFFL | Safety Population Flag | Char | Y, N | Cond |  |

### ADSL Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ITTFL | Intent-To-Treat Population Flag | Char | Y, N | Cond |  |
| PPROTFL | Per-Protocol Population Flag | Char | Y, N | Cond |  |
| COMPLFL | Completers Population Flag | Char | Y, N | Cond |  |
| RANDFL | Randomized Population Flag | Char | Y, N | Cond |  |
| ENRLFL | Enrolled Population Flag | Char | Y, N | Cond |  |
| ARM | Description of Planned Arm | Char |  | Req | DM.ARM |
| ACTARM | Description of Actual Arm | Char |  | Perm | DM.ACTARM |
| TRTxxP | Planned Treatment for Period xx | Char |  | Req | Subject-level identifier that represents the planned treatment for period xx. In a one-period randomized trial, TRT01P would be the treatment to which the subject was randomized. TRTxxP might be derived from the SDTM DM variable ARM. At least TRT01P is required. |

### ADSL Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTxxPN | Planned Treatment for Period xx (N) | Num |  | Perm | Numeric representation of TRTxxP. There must be a one-to-one relationship between TRTxxPN and TRTxxP within a study. TRTxxPN cannot be present unless TRTxxP is also present. When TRTxxP and TRTxxPN are present, then on a given record, either both must be populated or both must be null. |
| TRTxxA | Actual Treatment for Period xx | Char |  | Cond | Subject-level identifier that represents the actual treatment for the subject for period xx. Required when actual treatment does not match planned and there is an analysis of the data as treated. |

### ADSL Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTxxAN | Actual Treatment for Period xx (N) | Num |  | Perm | Numeric representation of TRTxxA. There must be a one-to-one relationship between TRTxxAN and TRTxxA within a study. TRTxxAN cannot be present unless TRTxxA is also present. When TRTxxA and TRTxxAN are present, then on a given record, either both must be populated or both must be null. |
| TRTSEQP | Planned Sequence of Treatments | Char |  | Cond | Required when there is an analysis based on the sequence of treatments, for example in a crossover design. TRTSEQP is not necessarily equal to ARM, for example if ARM contains elements that are not relevant to analysis of treatments or ARM is not fully descriptive (e.g., "GROUP 1," "GROUP 2"). When analyzing based on the sequence of treatments, TRTSEQP is required even if identical to ARM. |

### ADSL Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTSEQPN | Planned Sequence of Treatments (N) | Num |  | Perm | Numeric representation of TRTSEQP. There must be a one-to-one relationship between TRTSEQPN and TRTSEQP within a study. TRTSEQPN cannot be present unless TRTSEQP is also present. When TRTSEQP and TRTSEQPN are present, then on a given record, either both must be populated or both must be null. |
| TRTSEQA | Actual Sequence of Treatments | Char |  | Cond | TRTSEQA is required if a situation occurred in the conduct of the trial where a subject received a sequence of treatments other than what was planned and there is an analysis based on the sequence of treatments. |

### ADSL Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTSEQAN | Actual Sequence of Treatments (N) | Num |  | Perm | Numeric representation of TRTSEQA. There must be a one-to-one relationship between TRTSEQAN and TRTSEQA within a study. TRTSEQAN cannot be present unless TRTSEQA is also present. When TRTSEQA and TRTSEQAN are present, then on a given record, either both must be populated or both must be null. |
| TRxxPGy | Planned Pooled Treatment y for Period xx | Char |  | Perm | Planned pooled treatment y for period xx. Useful when planned treatments (TRTxxP) in the specified period xx are pooled together for analysis according to pooling algorithm y. For example when in period 2 the first pooling algorithm dictates that all doses of Drug A (TR02PG1="All doses of Drug A") are pooled together for comparison to all doses of Drug B (TR02PG1="All doses of Drug B"). Each value of TRTxxP is pooled within at most one value of TRxxPGy. |

### ADSL Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxPGyN | Planned Pooled Trt y for Period xx (N) | Num |  | Perm | Numeric representation of TRxxPGy. There must be a one-to-one relationship between TRxxPGyN and TRxxPGy within a study. TRxxPGyN cannot be present unless TRxxPGy is also present. When TRxxPGy and TRxxPGyN are present, then on a given record, either both must be populated or both must be null. |
| TRxxAGy | Actual Pooled Treatment y for Period xx | Char |  | Cond | Actual pooled treatment y for period xx. Required when TRxxPGy is present and TRTxxA is present. |
| TRxxAGyN | Actual Pooled Trt y for Period xx (N) | Num |  | Perm | Numeric representation of TRxxAGy. There must be a one-to-one relationship between TRxxAGyN and TRxxAGy within a study. TRxxAGyN cannot be present unless TRxxAGy is also present. When TRxxAGy and TRxxAGyN are present, then on a given record, either both must be populated or both must be null. |

### ADSL Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TSEQPGy | Planned Pooled Treatment Sequence y | Char |  | Perm | Planned pooled treatment sequence y. Useful when planned treatment sequences (TRTSEQP) are pooled together for analysis according to pooling algorithm y. For example, this might be used in an analysis of an extension study when the analysis is based on what the subject received in the parent study as well as in the extension study. |
| TSEQPGyN | Planned Pooled Treatment Sequence y (N) | Num |  | Perm | Numeric representation of TSEQPGy. There must be a one-to-one relationship between TSEQPGyN and TSEQPGy within a study. TSEQPGyN cannot be present unless TSEQPGy is also present. When TSEQPGy and TSEQPGyN are present, then on a given record, either both must be populated or both must be null. |
| TSEQAGy | Actual Pooled Treatment Sequence y | Char |  | Cond | Actual pooled treatment sequence y. Required when TSEQPGy is present and TRTSEQA is present. |

### ADSL Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TSEQAGyN | Actual Pooled Treatment Sequence y (N) | Num |  | Perm | Numeric representation of TSEQAGy. There must be a one-to-one relationship between TSEQAGyN and TSEQAGy within a study. TSEQAGyN cannot be present unless TSEQAGy is also present. When TSEQAGy and TSEQAGyN are present, then on a given record, either both must be populated or both must be null. |
| DOSExxP | Planned Treatment Dose for Period xx | Num |  | Perm | Subject-level identifier that represents the planned treatment dosage for period xx. |
| DOSExxA | Actual Treatment Dose for Period xx | Num |  | Perm | Subject-level identifier that represents the actual treatment dosage for period xx. |
| DOSExxU | Units for Dose for Period xx | Char |  | Perm | The units for DOSExxP and DOSExxA. It is permissible to use suffixes such as "P" and "A" if needed, with labels modified accordingly. |

### ADSL Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTSDT | Date of First Exposure to Treatment | Num |  | Cond | Date of first exposure to treatment for a subject in a study. TRTSDT and/or TRTSDTM are required if there is an investigational product. Note that TRTSDT is not required to have the same value as the SDTM DM variable RFXSTDTC. While both of these dates reflect the concept of first exposure, the ADaM date may be derived to support the analysis which may not necessarily be the very first date in the SDTM EX domain. |
| TRTSTM | Time of First Exposure to Treatment | Num |  | Perm | Time of first exposure to treatment for a subject in a study. |
| TRTSDTM | Datetime of First Exposure to Treatment | Num |  | Cond | Datetime of first exposure to treatment for a subject in a study. TRTSDT and/or TRTSDTM are required if there is an investigational product. |

### ADSL Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTSDTF | Date of First Exposure Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of date of first exposure to treatment. If TRTSDT (or the date part of TRTSDTM) was imputed, TRTSDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| TRTSTMF | Time of First Exposure Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of time of first exposure to treatment. If TRTSTM (or the time part of TRTSDTM) was imputed, TRTSTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTEDT | Date of Last Exposure to Treatment | Num |  | Cond | Date of last exposure to treatment for a subject in a study. TRTEDT and/or TRTEDTM are required if there is an investigational product. Note that TRTEDT is not required to have the same value as the SDTM DM variable RFXENDTC. While both of these dates reflect the concept of last exposure, the ADaM date may be derived to support the analysis which may not necessarily be the very last date in the SDTM EX domain. |
| TRTETM | Time of Last Exposure to Treatment | Num |  | Perm | Time of last exposure to treatment for a subject in a study. |
| TRTEDTM | Datetime of Last Exposure to Treatment | Num |  | Cond | Datetime of last exposure to treatment for a subject in a study. TRTEDT and/or TRTEDTM are required if there is an investigational product. |

### ADSL Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTEDTF | Date of Last Exposure Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of date of last exposure to treatment. If TRTEDT (or the date part of TRTEDTM) was imputed, TRTEDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| TRTETMF | Time of Last Exposure Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of time of last exposure to treatment. If TRTETM (or the time part of TRTEDTM) was imputed, TRTETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxSDT | Date of First Exposure in Period xx | Num |  | Cond | Date of first exposure to treatment in period xx. TRxxSDT and/or TRxxSDTM are only required in trial designs where multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). Examples include crossover designs or designs where multiple periods exist for the same treatment. |
| TRxxSTM | Time of First Exposure in Period xx | Num |  | Cond | Starting time of exposure to treatment in period xx. TRxxSTM and/or TRxxSDTM are only required in trial designs where starting time is important to the analysis and multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). |

### ADSL Variables (part 19)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxSDTM | Datetime of First Exposure in Period xx | Num |  | Cond | Datetime of first exposure to treatment in period xx. TRxxSDTM is only required in trial designs where multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). |
| TRxxSDTF | Date 1st Exposure Period xx Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of date of first exposure to treatment in period xx. If TRxxSDT (or the date part of TRxxSDTM) was imputed, TRxxSDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| TRxxSTMF | Time 1st Exposure Period xx Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of time of first exposure to treatment in period xx. If TRxxSTM (or the time part of TRxxSDTM) was imputed, TRxxSTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 20)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxEDT | Date of Last Exposure in Period xx | Num |  | Cond | Date of last exposure to treatment in period xx. TRxxEDT and/or TRxxEDTM are only required in trial designs where multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). |
| TRxxETM | Time of Last Exposure in Period xx | Num |  | Cond | Ending time of exposure to treatment in period xx. TRxxETM and/or TRxxEDTM are only required in trial designs where ending time is important to the analysis and multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). |
| TRxxEDTM | Datetime of Last Exposure in Period xx | Num |  | Cond | Datetime of last exposure to treatment in period xx. TRxxEDTM is only required in trial designs where multiple treatment periods are defined (i.e., required when there is a TRTxxP other than TRT01P). |

### ADSL Variables (part 21)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxEDTF | Date Last Exposure Period xx Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of date of last exposure to treatment in period xx. If TRxxEDT (or the date part of TRxxEDTM) was imputed, TRxxEDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| TRxxETMF | Time Last Exposure Period xx Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of time of last exposure to treatment in period xx. If TRxxETM (or the time part of TRxxEDTM) was imputed, TRxxETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APxxSDT | Period xx Start Date | Num |  | Perm | The starting date of period xx. |
| APxxSTM | Period xx Start Time | Num |  | Perm | The starting time of period xx. |
| APxxSDTM | Period xx Start Datetime | Num |  | Perm | The starting datetime of period xx. |

### ADSL Variables (part 22)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APxxSDTF | Period xx Start Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of period xx start date. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APxxSTMF | Period xx Start Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of period xx start time. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APxxEDT | Period xx End Date | Num |  | Perm | The ending date of period xx. |
| APxxETM | Period xx End Time | Num |  | Perm | The ending time of period xx. |
| APxxEDTM | Period xx End Datetime | Num |  | Perm | The ending datetime of period xx. |
| APxxEDTF | Period xx End Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of period xx end date. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 23)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APxxETMF | Period xx End Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of period xx end time. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PxxSw | Description of Period xx Subperiod w | Char |  | Perm | Description of analysis subperiod w within period xx. |
| PxxSwSDT | Period xx Subperiod w Start Date | Num |  | Perm | The starting date of subperiod w within period xx. |
| PxxSwSTM | Period xx Subperiod w Start Time | Num |  | Perm | The starting time of subperiod w within period xx. |
| PxxSwSDM | Period xx Subperiod w Start Datetime | Num |  | Perm | The starting datetime of subperiod w within period xx. |
| PxxSwSDF | Period xx Subper w Start Date Imput Flag | Char | (DATEFL) | Cond | The level of imputation of the start date for subperiod w within period xx. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 24)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PxxSwSTF | Period xx Subper w Start Time Imput Flag | Char | (TIMEFL) | Cond | The level of imputation of the start time for subperiod w within period xx. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PxxSwEDT | Period xx Subperiod w End Date | Num |  | Perm | The ending date of subperiod w within period xx. |
| PxxSwETM | Period xx Subperiod w End Time | Num |  | Perm | The ending time of subperiod w within period xx. |
| PxxSwEDM | Period xx Subperiod w End Datetime | Num |  | Perm | The ending datetime of subperiod w within period xx. |
| PxxSwEDF | Period xx Subper w End Date Imput Flag | Char | (DATEFL) | Cond | The level of imputation of the end date for subperiod w within period xx. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 25)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PxxSwETF | Period xx Subper w End Time Imput Flag | Char | (TIMEFL) | Cond | The level of imputation of the end time for subperiod w within period xx. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APHASEw | Description of Phase w | Char |  | Perm | Description of analysis phase w. Analysis phase is independent of TRTxxP within ADSL, and may be populated for spans of time where a subject is not on treatment. |
| PHwSDT | Phase w Start Date | Num |  | Perm | The starting date of phase w. |
| PHwSTM | Phase w Start Time | Num |  | Perm | The starting time of phase w. |
| PHwSDTM | Phase w Start Datetime | Num |  | Perm | The starting datetime of phase w. |
| PHwSDTF | Phase w Start Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of the start date for phase w. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 26)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PHwSTMF | Phase w Start Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of the start time for phase w. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHwEDT | Phase w End Date | Num |  | Perm | The ending date of phase w. |
| PHwETM | Phase w End Time | Num |  | Perm | The ending time of phase w. |
| PHwEDTM | Phase w End Datetime | Num |  | Perm | The ending datetime of phase w. |
| PHwEDTF | Phase w End Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of the end date for phase w. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHwETMF | Phase w End Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of the end time for phase w. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### ADSL Variables (part 27)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| EOSSTT | End of Study Status | Char | (SBJTSTAT) | Perm | The subject's status as of the end of study or data cutoff. Examples: COMPLETED, DISCONTINUED, ONGOING. |
| EOSDT | End of Study Date | Num |  | Perm | Date subject ended the study - either date of completion or date of discontinuation or data cutoff date for interim analyses. |
| DCSREAS | Reason for Discontinuation from Study | Char |  | Perm | Reason for subject's discontinuation from study. The source would most likely be the SDTM DS dataset. Null for subjects who completed the study. |
| DCSREASP | Reason Spec for Discont from Study | Char |  | Perm | Additional detail regarding subject's discontinuation from study (e.g., description of "other"). |
| EOTSTT | End of Treatment Status | Char | (SBJTSTAT) | Perm | The subject's status as of the end of treatment or data cutoff. Examples: COMPLETED, DISCONTINUED, ONGOING. |

### ADSL Variables (part 28)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| DCTREAS | Reason for Discontinuation of Treatment | Char |  | Perm | If a subject discontinued treatment in the study, then this variable indicates the reason for discontinuation. This is for discontinuation of treatment in the overall study and not to be used for discontinuation reason within individual treatment periods. |
| DCTREASP | Reason Specify for Discont of Treatment | Char |  | Perm | Additional detail regarding subject's discontinuation from treatment (e.g., description of "other"). |
| EOTxxSTT | End of Treatment Status in Period xx | Char | (SBJTSTAT) | Perm | The subject's treatment status as of the end of period xx, or data cutoff if within period xx. Examples: COMPLETED, DISCONTINUED, ONGOING. |
| DCTxxRS | Reason for Discont of Treat in Period xx | Char |  | Perm | Reason for discontinuing treatment in period xx. |
| DCTxxRSP | Reason Spec for Disc of Trt in Period xx | Char |  | Perm | Additional detail regarding subject's discontinuation of treatment in period xx (e.g., description of "other"). |

### ADSL Variables (part 29)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| EOPxxSTT | End of Period xx Status | Char | (SBJTSTAT) | Perm | The subject's status as of the end of period xx, or data cutoff if within period xx. Examples: COMPLETED, DISCONTINUED, ONGOING. |
| DCPxxRS | Reason for Discont from Period xx | Char |  | Perm | Reason for discontinuing analysis period xx. |
| DCPxxRSP | Reason Spec for Discont from Period xx | Char |  | Perm | Additional detail regarding subject's discontinuation from period xx (e.g., description of "other"). |
| RFICDT | Date of Informed Consent | Num |  | Perm | Date subject gave informed consent. Generally equivalent to DM.RFICDTC. |
| ENRLDT | Date of Enrollment | Num |  | Perm | Date of subject's enrollment into trial. |
| RANDDT | Date of Randomization | Num |  | Cond | Required in randomized trials. |

### ADSL Variables (part 30)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| RFICyDT | Date of Informed Consent y | Num |  | Perm | This variable may be used in the case where there are multiple consent dates within a study. This date does not need to repeat the date in RFICDT. "y" can start with 1 but it is not required to start with 1. |
| ENRLyDT | Date of Enrollment y | Num |  | Perm | This variable may be used in the case where there are multiple enrollment dates within a study. This date does not need to repeat the date in ENRLDT. "y" can start with 1 but it is not required to start with 1. |
| RANDyDT | Date of Randomization y | Num |  | Perm | This variable may be used in the case where there are multiple randomization dates within a study. This date does not need to repeat the date in RANDDT. "y" can start with 1 but it is not required to start with 1. |

### ADSL Variables (part 31)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| LSTALVDT | Date Last Known Alive | Num |  | Perm | If this variable is included in ADSL, the best practice is to populate it for everyone. If the derivation for subjects who died differs from the derivation for subjects who are not known to have died, the differences should be noted in metadata. |
| TRCMP | Treatment Compliance (%) | Num |  | Perm | Overall percent compliance with treatment in the trial. TRCMP may be useful for inclusion in ADSL for reasons such as defining subgroups and/or populations. |
| TRCMPGy | Treatment Compliance (%) Group y | Char |  | Perm | Grouping "y" of TRCMP, treatment compliance percentage. |

### ADSL Variables (part 32)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRCMPGyN | Treatment Compliance (%) Group y (N) | Num |  | Perm | Numeric representation of treatment compliance (%) grouping "y". There must be a one-to-one relationship between TRCMPGyN and TRCMPGy within a study. TRCMPGyN cannot be present unless TRCMPGy is also present. When TRCMPGy and TRCMPGyN are present, then on a given record, either both must be populated or both must be null. |
| TRxxDURD | Treatment Duration in Period xx (Days) | Num |  | Perm | Treatment duration for period xx as measured in days. More than one of TRxxDURD, TRxxDURM, and TRxxDURY can be populated, but each represents the entire duration in its respective units. |
| TRxxDURM | Treatment Duration in Period xx (Months) | Num |  | Perm | Treatment duration for period xx, as measure in months. More than one of TRxxDURD, TRxxDURM, and TRxxDURY can be populated, but each represents the entire duration in its respective units. |

### ADSL Variables (part 33)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRxxDURY | Treatment Duration in Period xx (Years) | Num |  | Perm | Treatment duration for period xx, as measured in years. More than one of TRxxDURD, TRxxDURM, and TRxxDURY can be populated, but each represents the entire duration in its respective units. |
| TRTDURD | Total Treatment Duration (Days) | Num |  | Perm | Total treatment duration, as measured in days. More than one of TRTDURD, TRTDURM, and TRTDURY can be populated, but each represents the entire duration in its respective units. |
| TRTDURM | Total Treatment Duration (Months) | Num |  | Perm | Total treatment duration, as measured in months. More than one of TRTDURD, TRTDURM, and TRTDURY can be populated, but each represents the entire duration in its respective units. |
| TRTDURY | Total Treatment Duration (Years) | Num |  | Perm | Total treatment duration, as measured in years. More than one of TRTDURD, TRTDURM, and TRTDURY can be populated, but each represents the entire duration in its respective units. |

### ADSL Variables (part 34)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| DTHDT | Date of Death | Num |  | Perm | Date of subject's death. Derived from DM.DTHDTC. |
| DTHDTF | Date of Death Imputation Flag | Char | (DATEFL) | Cond | Imputation flag for date of subject's death. If DTHDT was imputed, DTHDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| DTHCAUS | Cause of Death | Char |  | Perm | Cause of Death. |
| DTHCAUSN | Cause of Death (N) | Num |  | Perm | Numeric representation of cause of death. There must be a one-to-one relationship between DTHCAUSN and DTHCAUS within a study. DTHCAUSN cannot be present unless DTHCAUS is also present. When DTHCAUS and DTHCAUSN are present, then on a given record, either both must be populated or both must be null. |
| DTHCGRy | Cause of Death Group y | Char |  | Perm | Grouping "y" of DTHCAUS, the subject's cause of death. |

### ADSL Variables (part 35)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| DTHCGRyN | Cause of Death Group y (N) | Num |  | Perm | Numeric representation of grouping "y" of the subject's cause of death. There must be a one-to-one relationship between DTHCGRyN and DTHCGRy within a study. DTHCGyN cannot be present unless DTHCGy is also present. When DTHCGy and DTHCGyN are present, then on a given record, either both must be populated or both must be null. |
| STRATAR | Strata Used for Randomization | Char |  | Perm | STRATAR contains the combination of values of the individual stratification factors used for randomization. The exact format should be determined by the sponsor. This variable is intended for studies that use stratified randomization. For example, ">=50, Treatment experienced, N" |

### ADSL Variables (part 36)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STRATARN | Strata Used for Randomization (N) | Num |  | Perm | Numeric representation of STRATAR. For example, STRATARN=3 when STRATAR=">=50, Treatment experienced, N". There must be a one-to-one relationship between STRATARN and STRATAR within a study. STRATARN cannot be present unless STRATAR is also present. When STRATAR and STRATARN are present, then on a given record, either both must be populated or both must be null. |
| STRATwD | Description of Stratification Factor w | Char |  | Perm | STRATwD is a full text description of the stratification factor "w". This text description will remain constant for all subjects. These descriptive variables are included to quickly and clearly communicate critical study design information as well as to facilitate integration. For example, STRAT3D="Hypertension" |
| STRATwR | Strat Factor w Value Used for Rand | Char |  | Perm | STRATwR is the subject-level value of the "w'th" stratification factor used for randomization. For example, STRAT3R="N" |

### ADSL Variables (part 37)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STRATwRN | Strat Factor w Value Used for Rand (N) | Num |  | Perm | Numeric representation of STRATwR. For example, STRAT3RN=0 when STRAT3R="N". There must be a one-to-one relationship between STRATwRN and STRATwR within a study. STRATwRN cannot be present unless STRATwR is also present. When STRATwR and STRATwRN are present, then on a given record, either both must be populated or both must be null. |

### ADSL Variables (part 38)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STRATAV | Strata from Verification Source | Char |  | Perm | STRATAV contains the entire string value represents the combination of values of the individual stratification factors that should have been used and represents the "as verified" value. The STRATAV variables are based on the source documentation and are determined after randomization. If the values used for the randomization of a given subject were all correct, then STRATAV will equal STRATAR. Otherwise, one or more components of the text string for STRATAR and STRATAV will be different. The exact format should be determined by the sponsor. For example, ">=50, Treatment experienced, Y" |

### ADSL Variables (part 39)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STRATAVN | Strata from Verification Source (N) | Num |  | Perm | Numeric representation of STRATAV. For example, STRATAVN=4 when STRATVR=">=50, Treatment experienced, Y". There must be a one-to-one relationship between STRATAVN and STRATAV within a study. STRATAVN cannot be present unless STRATAV is also present. When STRATAV and STRATAVN are present, then on a given record, either both must be populated or both must be null. |
| STRATwV | Strat Factor w Value from Verif Source | Char |  | Perm | STRATwV is the "as verified" subject-level value of the "w'th" stratification factor. If the value based on randomization was correct, then STRATwV will equal STRATwR. For example, STRAT3V="Y" |

### ADSL Variables (part 40)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STRATwVN | Strat Fact w Val from Verif Source (N) | Num |  | Perm | Numeric representation of STRATwV. For example, STRAT3VN=1 when STRAT3V="Y". There must be a one-to-one relationship between STRATwVN and STRATwV within a study. STRATwVN cannot be present unless STRATwV is also present. When STRATwV and STRATwVN are present, then on a given record, either both must be populated or both must be null. |

## ADaM Basic Data Structure (BDS) Variables

3.3 ADaM Basic Data Structure (BDS) Variables

The ADaM Model document introduces the ADaM Basic Data Structure. A BDS dataset contains 1 or more records per subject, per analysis parameter, per analysis timepoint. An analysis timepoint is conditionally required, depending on the analysis. In situations where there is no analysis timepoint, the structure is 1 or more records per subject per analysis parameter. Typically there are several BDS datasets in a study. This section of the ADaMIG defines the standard variables used in BDS datasets. See Section 3.2, ADSL Variables, for ADSL variables, any of which may also be included in BDS datasets to support traceability or enable analysis.

In this section, "within a given study, subject, and dataset" is implied, unless otherwise stated. For example, the description of ABLFL defines it as a variable that indicates baseline record for each parameter, or, if there is more than 1 baseline definition, for each parameter and baseline type (BASETYPE). It should be understood that the baseline record is for the subject identified by USUBJID. In addition, note that "within a parameter" means "within a parameter within a dataset."

3.3.1 Identifier Variables for BDS Datasets

Table 3.3.1.1 Identifier Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Req | DM.STUDYID, ADSL STUDYID, and/or STUDYID from another ADaM or SDTM dataset appropriate to the analysis. |
| USUBJID | Unique Subject Identifier | Char |  | Req | DM.USUBJID, ADSL.USUBJID, and/or USUBJID from another ADaM or SDTM dataset appropriate to the analysis. |
| SUBJID | Subject Identifier for the Study | Char |  | Perm | DM.SUBJID, ADSL.SUBJID, and/or SUBJID from another ADaM dataset appropriate to the analysis. SUBJID is required in ADSL, but permissible in other datasets. |
| SITEID | Study Site Identifier | Char |  | Perm | DM.SITEID, ADSL.SITEID, and/or SITEID from another ADaM dataset appropriate to the analysis. SITEID is required in ADSL, but permissible in other datasets. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASEQ | Analysis Sequence Number | Num |  | Perm | Sequence number given to ensure uniqueness of subject records within an ADaM dataset. As long as values are unique within a subject within the dataset, any valid number can be used for ASEQ. ASEQ uniquely indexes records within a subject within an ADaM dataset. ASEQ is useful for traceability when the dataset is used as input to another ADaM dataset. To refer to a record in a predecessor ADaM dataset, set SRCDOM to the name of the predecessor dataset, and set SRCSEQ to the value of ASEQ in the predecessor dataset. |

## Identifier Variables for BDS Datasets

3.3 ADaM Basic Data Structure (BDS) Variables

The ADaM Model document introduces the ADaM Basic Data Structure. A BDS dataset contains 1 or more records per subject, per analysis parameter, per analysis timepoint. An analysis timepoint is conditionally required, depending on the analysis. In situations where there is no analysis timepoint, the structure is 1 or more records per subject per analysis parameter. Typically there are several BDS datasets in a study. This section of the ADaMIG defines the standard variables used in BDS datasets. See Section 3.2, ADSL Variables, for ADSL variables, any of which may also be included in BDS datasets to support traceability or enable analysis.

In this section, "within a given study, subject, and dataset" is implied, unless otherwise stated. For example, the description of ABLFL defines it as a variable that indicates baseline record for each parameter, or, if there is more than 1 baseline definition, for each parameter and baseline type (BASETYPE). It should be understood that the baseline record is for the subject identified by USUBJID. In addition, note that "within a parameter" means "within a parameter within a dataset."

3.3.1 Identifier Variables for BDS Datasets

Table 3.3.1.1 Identifier Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Req | DM.STUDYID, ADSL STUDYID, and/or STUDYID from another ADaM or SDTM dataset appropriate to the analysis. |
| USUBJID | Unique Subject Identifier | Char |  | Req | DM.USUBJID, ADSL.USUBJID, and/or USUBJID from another ADaM or SDTM dataset appropriate to the analysis. |
| SUBJID | Subject Identifier for the Study | Char |  | Perm | DM.SUBJID, ADSL.SUBJID, and/or SUBJID from another ADaM dataset appropriate to the analysis. SUBJID is required in ADSL, but permissible in other datasets. |
| SITEID | Study Site Identifier | Char |  | Perm | DM.SITEID, ADSL.SITEID, and/or SITEID from another ADaM dataset appropriate to the analysis. SITEID is required in ADSL, but permissible in other datasets. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASEQ | Analysis Sequence Number | Num |  | Perm | Sequence number given to ensure uniqueness of subject records within an ADaM dataset. As long as values are unique within a subject within the dataset, any valid number can be used for ASEQ. ASEQ uniquely indexes records within a subject within an ADaM dataset. ASEQ is useful for traceability when the dataset is used as input to another ADaM dataset. To refer to a record in a predecessor ADaM dataset, set SRCDOM to the name of the predecessor dataset, and set SRCSEQ to the value of ASEQ in the predecessor dataset. |

## Record-Level Treatment and Dose Variables for BDS Datasets

3.3 ADaM Basic Data Structure (BDS) Variables

The ADaM Model document introduces the ADaM Basic Data Structure. A BDS dataset contains 1 or more records per subject, per analysis parameter, per analysis timepoint. An analysis timepoint is conditionally required, depending on the analysis. In situations where there is no analysis timepoint, the structure is 1 or more records per subject per analysis parameter. Typically there are several BDS datasets in a study. This section of the ADaMIG defines the standard variables used in BDS datasets. See Section 3.2, ADSL Variables, for ADSL variables, any of which may also be included in BDS datasets to support traceability or enable analysis.

In this section, "within a given study, subject, and dataset" is implied, unless otherwise stated. For example, the description of ABLFL defines it as a variable that indicates baseline record for each parameter, or, if there is more than 1 baseline definition, for each parameter and baseline type (BASETYPE). It should be understood that the baseline record is for the subject identified by USUBJID. In addition, note that "within a parameter" means "within a parameter within a dataset."

3.3.1 Identifier Variables for BDS Datasets

Table 3.3.1.1 Identifier Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Req | DM.STUDYID, ADSL STUDYID, and/or STUDYID from another ADaM or SDTM dataset appropriate to the analysis. |
| USUBJID | Unique Subject Identifier | Char |  | Req | DM.USUBJID, ADSL.USUBJID, and/or USUBJID from another ADaM or SDTM dataset appropriate to the analysis. |
| SUBJID | Subject Identifier for the Study | Char |  | Perm | DM.SUBJID, ADSL.SUBJID, and/or SUBJID from another ADaM dataset appropriate to the analysis. SUBJID is required in ADSL, but permissible in other datasets. |
| SITEID | Study Site Identifier | Char |  | Perm | DM.SITEID, ADSL.SITEID, and/or SITEID from another ADaM dataset appropriate to the analysis. SITEID is required in ADSL, but permissible in other datasets. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASEQ | Analysis Sequence Number | Num |  | Perm | Sequence number given to ensure uniqueness of subject records within an ADaM dataset. As long as values are unique within a subject within the dataset, any valid number can be used for ASEQ. ASEQ uniquely indexes records within a subject within an ADaM dataset. ASEQ is useful for traceability when the dataset is used as input to another ADaM dataset. To refer to a record in a predecessor ADaM dataset, set SRCDOM to the name of the predecessor dataset, and set SRCSEQ to the value of ASEQ in the predecessor dataset. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTP | Planned Treatment | Char |  | Cond | TRTP is a record-level identifier that represents the planned treatment attributed to a record for analysis purposes. TRTP indicates how treatment varies by record within a subject and enables analysis of crossover and other designs. Though there is no requirement that TRTP will correspond to the TRTxxP as defined by the record's value of APERIOD, if populated, TRTP must match at least one value of the character planned treatment variables in ADSL (e.g., TRTxxP, TRTSEQP, TRxxPGy). As noted previously, at least one treatment variable is required even in non-randomized trials. This requirement is satisfied by any subject-level or record-level treatment variables (e.g., TRTxxP, TRTP, TRTA). Even if not used for analysis, any ADSL treatment variable may be included in the BDS dataset. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTPN | Planned Treatment (N) | Num |  | Perm | Numeric representation of TRTP. There must be a one-to-one relationship between TRTPN and TRTP within a study. TRTPN cannot be present unless TRTP is also present. When TRTP and TRTPN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTA | Actual Treatment | Char |  | Cond | TRTA is a record-level identifier that represents the actual treatment attributed to a record for analysis purposes. TRTA indicates how treatment varies by record within a subject and enables analysis of crossover and other multi-period designs. Though there is no requirement that TRTA will correspond to the TRTxxA as defined by the record's value of APERIOD, TRTA must match at least one value of the character actual treatment variables in ADSL (e.g., TRTxxA, TRTSEQA, TRxxAGy). As noted previously, at least one treatment variable is required. This requirement is satisfied by any subject-level or record-level treatment variables (e.g., TRTxxP, TRTP, TRTA). Even if not used for analysis, any ADSL treatment variable may be included in the BDS dataset. |

### BDS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTAN | Actual Treatment (N) | Num |  | Perm | Numeric representation of TRTA. There must be a one-to-one relationship between TRTAN and TRTA within a study. TRTAN cannot be present unless TRTA is also present. When TRTA and TRTAN are present, then on a given record, either both must be populated or both must be null. |
| TRTPGy | Planned Pooled Treatment y | Char |  | Perm | TRTPGy is the planned pooled treatment y attributed to a record for analysis purposes. "y" represents an integer [1-99, not zero-padded] corresponding to a particular pooling scheme. Useful when planned treatments (TRTP) are pooled together for analysis, for example when all doses of Drug A (TRTPG1=All doses of Drug A) are compared to all doses of Drug B (TRTPG1=All doses of Drug B). Each value of TRTP is pooled within at most one value of TRTPGy. |

### BDS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTPGyN | Planned Pooled Treatment y (N) | Num |  | Perm | Numeric representation of TRTPGy. There must be a one-to-one relationship between TRTPGyN and TRTPGy within a study. TRTPGyN cannot be present unless TRTPGy is also present. When TRTPGy and TRTPGyN are present, then on a given record, either both must be populated or both must be null. |
| TRTAGy | Actual Pooled Treatment y | Char |  | Cond | TRTAGy is the actual pooled treatment y attributed to a record for analysis purposes. "y" represents an integer [1-99, not zero-padded] corresponding to a particular pooling scheme. Required when TRTPGy is present and TRTA is present. |

### BDS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| TRTAGyN | Actual Pooled Treatment y (N) | Num |  | Perm | Numeric representation of TRTAGy. There must be a one-to-one relationship between TRTAGyN and TRTAGy within a study. TRTAGyN cannot be present unless TRTAGy is also present. When TRTAGy and TRTAGyN are present, then on a given record, either both must be populated or both must be null. |

## Timing Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| DOSEP | Planned Treatment Dose | Num |  | Perm | DOSEP represents the planned treatment dosage associated with the record. |
| DOSCUMP | Cumulative Planned Treatment Dose | Num |  | Perm | Cumulative planned dosage of treatment for the subject at the point in time of the record (e.g., ADT). |
| DOSEA | Actual Treatment Dose | Num |  | Perm | DOSEA represents the actual treatment dosage associated with the record. |
| DOSCUMA | Cumulative Actual Treatment Dose | Num |  | Perm | Cumulative actual dosage of treatment for the subject at the point in time of the record (e.g., ADT). |
| DOSEU | Treatment Dose Units | Char |  | Perm | The units for DOSEP, DOSCUMP, DOSEA, and DOSCUMA. It is permissible to use suffixes such as "P" and "A" if needed, with labels modified accordingly. |
| ADT | Analysis Date | Num |  | Cond | The date associated with AVAL and/or AVALC in numeric format. |
| ATM | Analysis Time | Num |  | Cond | The time associated with AVAL and/or AVALC in numeric format. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ADTM | Analysis Datetime | Num |  | Cond | The datetime associated with AVAL and/or AVALC in numeric format. |
| ADY | Analysis Relative Day | Num |  | Cond | The relative day of AVAL and/or AVALC. The number of days from an anchor date (not necessarily DM.RFSTDTC) to ADT. See Section 3.1.2, Timing Variable Conventions. If a dataset contains more than one record per parameter per subject, then an SDTM or ADaM relative timing variable must be present (ADY would meet this requirement). |
| ADTF | Analysis Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of analysis date. If ADT (or the date part of ADTM) was imputed, ADTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATMF | Analysis Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of analysis time. If ATM (or the time part of ADTM) was imputed, ATMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| ASTDT | Analysis Start Date | Num |  | Cond | The start date associated with AVAL and/or AVALC. ASTDT and AENDT may be useful for traceability when AVAL summarizes data collected over an interval of time, or when AVAL is a duration. |
| ASTTM | Analysis Start Time | Num |  | Cond | The start time associated with AVAL and/or AVALC. ASTTM and AENTM may be useful for traceability when AVAL summarizes data collected over an interval of time, or when AVAL is a duration. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASTDTM | Analysis Start Datetime | Num |  | Cond | The start datetime associated with AVAL and/or AVALC. ASTDTM and AENDTM may be useful for traceability when AVAL summarizes data collected over an interval of time, or when AVAL is a duration. |
| ASTDY | Analysis Start Relative Day | Num |  | Cond | The number of days from an anchor date (not necessarily DM.RFSTDTC) to ASTDT. See Section 3.1.2, Timing Variable Conventions. If a dataset contains more than one record per parameter per subject then, an SDTM or ADaM relative timing variable must be present (ASTDY would meet this requirement). |
| ASTDTF | Analysis Start Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of analysis start date. If ASTDT (or the date part of ASTDTM) was imputed, ASTDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASTTMF | Analysis Start Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of analysis start time. If ASTTM (or the time part of ASTDTM) was imputed, ASTTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| AENDT | Analysis End Date | Num |  | Cond | The end date associated with AVAL and/or AVALC. See also ASTDT. |
| AENTM | Analysis End Time | Num |  | Cond | The end time associated with AVAL and/or AVALC. See also ASTTM. |
| AENDTM | Analysis End Datetime | Num |  | Cond | The end datetime associated with AVAL and/or AVALC. See also ASTDTM. |
| AENDY | Analysis End Relative Day | Num |  | Cond | The number of days from an anchor date (not necessarily DM.RFSTDTC) to AENDT. See Section 3.1.2, Timing Variable Conventions. If a dataset contains more than one record per parameter per subject, then an SDTM or ADaM relative timing variable must be present (AENDY would meet this requirement). |

### BDS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AENDTF | Analysis End Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of analysis end date. If AENDT (or the date part of AENDTM) was imputed, AENDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| AENTMF | Analysis End Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of analysis end time. If AENTM (or the time part of AENDTM) was imputed, AENTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### BDS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AVISIT | Analysis Visit | Char |  | Cond | The analysis visit description; required if an analysis is done by nominal, assigned or analysis visit. AVISIT may contain the visit names as observed (i.e., from SDTM VISIT), derived visit names, time window names, conceptual descriptions (such as Average, Endpoint, etc.), or a combination of any of these. AVISIT is a derived field and does not have to map to VISIT from the SDTM. AVISIT represents the analysis visit of the record, but it does not mean that the record was analyzed. There are often multiple records for the same subject and parameter that have the same value of AVISIT. ANLzzFL and other variables may be needed to identify the records selected for any given analysis. See Section 3.3.8, Indicator Variables for BDS Datasets, for information about flag variables. AVISIT should be unique for a given analysis visit window. In the event that a record does not fall within any predefined analysis timepoint window, AVISIT can be populated in any way that the producer chooses to indicate this fact (e.g., blank or "Not Windowed"). The way that AVISIT is calculated, including the variables used in its derivation, should be indicated in the variable metadata for AVISIT. The values and the rules for deriving AVISIT may be different for different parameters within the same dataset. Values of AVISIT are producer-defined, and are often directly usable in Clinical Study Report displays. If a dataset contains more than one record per parameter per subject, then an SDTM or ADaM relative timing variable must be present (AVISIT could meet this requirement). |

### BDS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AVISITN | Analysis Visit (N) | Num |  | Perm | Numeric representation of AVISIT. Since study visits are usually defined by certain timepoints, defining AVISITN so that it represents the timepoint associated with the visit can facilitate plotting and interpretation of the values. Alternatively, AVISITN may be a protocol visit number, a cycle number, an analysis visit number, or any other number logically related to AVISIT or useful for sorting that is needed for analysis. There must be a one-to-one relationship between AVISITN and AVISIT (i.e., AVISITN has the same value for each distinct AVISIT) within a parameter. A best practice is to extend the one-to-one relationship to within a study, but this is not an ADaM requirement. In the event that a record does not fall within any predefined analysis timepoint window, AVISITN can be populated in any way that the producer chooses to indicate this fact (e.g., may be null). Values of AVISITN are producer-defined. AVISITN cannot be present unless AVISIT is also present. On a given record, AVISITN cannot be populated if AVISIT is null. AVISITN can be null when AVISIT is populated, as long as the one-to-one relationship is maintained within a parameter on all rows on which both variables are populated. |

### BDS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATPT | Analysis Timepoint | Char |  | Cond | The analysis timepoint description; required if an analysis is done by nominal, assigned or analysis timepoint (instead of or in addition to by-visit). Timepoints are relative to ATPTREF. ATPT may contain the timepoint names as observed (i.e., from SDTM --TPT), derived timepoint names, time window names, conceptual descriptions (such as Average, Endpoint, etc.), or a combination of any of these. This variable is often used in conjunction with AVISIT. ATPT represents the analysis timepoint of the record. ATPT can be within an analysis visit (e.g., blood pressure assessments at 10 min, 20 min, and 30 min post-dose at AVISIT=Week 1) or can be unrelated to AVISIT (e.g., migraine symptoms 30 min, 60 min, and 120 min post-dose for attack 1). The way that ATPT is calculated, including the variables used in its derivation, should be indicated in the variable metadata for ATPT. The values and the rules for deriving ATPT may be different for different parameters within the same dataset. Values of ATPT are producer-defined, and are often directly usable in Clinical Study Report displays. If a dataset contains more than one record per parameter per subject, then an SDTM or ADaM relative timing variable must be present (ATPT could meet this requirement). |

### BDS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATPTN | Analysis Timepoint (N) | Num |  | Perm | Numeric representation of ATPT. Defining ATPTN so that its values represent the planned timepoints (e.g., minutes or hours after dosing) is not required but can facilitate plotting and interpretation of the values. There must be a one-to-one relationship between ATPTN and ATPT within a parameter. (Best practice would dictate that the mapping would be one-to-one within a study, but that is not an ADaM requirement.) ATPTN cannot be present unless ATPT is also present. When ATPT and ATPTN are present, then on a given record, either both must be populated or both must be null. |
| ATPTREF | Analysis Timepoint Reference | Char |  | Perm | Description of the fixed reference point referred to by ATPT/ATPTN (e.g., time of dose). |

### BDS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APHASE | Phase | Char |  | Perm | APHASE is a categorization of timing within a study, for example a higher-level categorization of APERIOD or an analysis epoch. For example, APHASE could describe spans of time for SCREENING, ON TREATMENT, and FOLLOW-UP. APHASE may be used alone or in addition to APERIOD. APHASE is independent of TRTxxP within ADSL. APHASE may be populated for spans of time where a subject is not on treatment. The value of APHASE (if populated) must be one of the values found in the ADSL APHASEw variables. |

### BDS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APHASEN | Phase (N) | Num |  | Perm | Numeric representation of APHASE. The value of APHASEN (if populated) must be one of the w values found in the ADSL APHASEw variable names. There must be a one-to-one relationship between APHASEN and APHASE within a study, which must be the same as the one-to-one mapping between w and APHASEw in ADSL. APHASEN cannot be present unless APHASE is also present. When APHASE and APHASEN are present, then on a given record, either both must be populated or both must be null. |
| APERIOD | Period | Num |  | Cond | APERIOD is a record-level timing variable that represents the analysis period within the study associated with the record for analysis purposes. The value of APERIOD (if populated) must be one of the xx values found in the ADSL TRTxxP variable names. APERIOD is required if ASPER is present. APERIOD must be populated on all records where ASPER is populated. |

### BDS Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APERIODC | Period (C) | Char |  | Perm | Text characterizing to which analysis period the record belongs. There must be a one-to-one relationship between APERIODC and APERIOD within a study. APERIODC cannot be present unless APERIOD is also present. When APERIOD and APERIODC are present, then on a given record, either both must be populated or both must be null. |
| ASPER | Subperiod within Period | Num |  | Perm | The numeric value characterizing a sublevel within APERIOD to which the record belongs. Within each APERIOD, the first ASPER is 1 (i.e., it resets to 1 when the APERIOD value changes). The value of ASPER (if populated) must be one of the w values found in the ADSL PxxSw variable names. |

### BDS Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASPERC | Subperiod within Period (C) | Char |  | Perm | Text characterizing to which subperiod the record belongs. There must be a one-to-one relationship between ASPERC and ASPER within a value of APERIOD, which must be the same as the one-to-one mapping between PxxSw and w in ADSL, where xx is equal to the value of APERIOD. The value of ASPERC (if populated) must be one of the values found in the ADSL PxxSw variables. ASPERC cannot be present unless ASPER is also present. When ASPER and ASPERC are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ARELTM | Analysis Relative Time | Num |  | Perm | The time relative to an anchor time. The amount of time from an anchor time to ATM. When ARELTM is present, the anchor time variable and ARELTMU must also be included in the dataset, and the anchor time variable must be identified in the metadata for ARELTM. |
| ARELTMU | Analysis Relative Time Unit | Char |  | Perm | The units of ARELTM. For example, "HOURS" or "MINUTES." ARELTMU is required if ARELTM is present. |
| APERSDT | Period Start Date | Num |  | Perm | The starting date for the period defined by APERIOD. |
| APERSTM | Period Start Time | Num |  | Perm | The starting time for the period defined by APERIOD. |
| APERSDTM | Period Start Datetime | Num |  | Perm | The starting datetime for the period defined by APERIOD. |

### BDS Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APERSDTF | Period Start Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of period start date. If APERSDT (or the date part of APERSDTM) was imputed, APERSDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APERSTMF | Period Start Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of period start time. If APERSTM (or the time part of APERSDTM) was imputed, APERSTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APEREDT | Period End Date | Num |  | Perm | The ending date for the period defined by APERIOD. |
| APERETM | Period End Time | Num |  | Perm | The ending time for the period defined by APERIOD. |
| APEREDTM | Period End Datetime | Num |  | Perm | The ending datetime for the period defined by APERIOD. |

### BDS Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| APEREDTF | Period End Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of period end date. If APEREDT (or the date part of APEREDTM) was imputed, APEREDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| APERETMF | Period End Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of period end time. If APERETM (or the time part of APEREDTM) was imputed, APERETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| ASPRSDT | Subperiod Start Date | Num |  | Perm | The starting date for the subperiod defined by ASPER. |
| ASPRSTM | Subperiod Start Time | Num |  | Perm | The starting time for the subperiod defined by ASPER. |
| ASPRSDTM | Subperiod Start Datetime | Num |  | Perm | The starting datetime for the subperiod defined by ASPER. |

### BDS Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASPRSDTF | Subperiod Start Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of subperiod start date. If ASPRSDT (or the date part of ASPRSDTM) was imputed, ASPRSDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| ASPRSTMF | Subperiod Start Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of subperiod start time. If ASPRSTM (or the time part of ASPRSDTM) was imputed, ASPRSTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| ASPREDT | Subperiod End Date | Num |  | Perm | The ending date for the subperiod defined by ASPER. |
| ASPRETM | Subperiod End Time | Num |  | Perm | The ending time for the subperiod defined by ASPER. |
| ASPREDTM | Subperiod End Datetime | Num |  | Perm | The ending datetime for the subperiod defined by ASPER. |

### BDS Variables (part 19)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ASPREDTF | Subperiod End Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of subperiod end date. If ASPREDT (or the date part of ASPREDTM) was imputed, ASPREDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| ASPRETMF | Subperiod End Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of subperiod end time. If ASPRETM (or the time part of ASPREDTM) was imputed, ASPRETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHSDT | Phase Start Date | Num |  | Perm | The starting date for the phase defined by APHASE. |
| PHSTM | Phase Start Time | Num |  | Perm | The starting time for the phase defined by APHASE. |
| PHSDTM | Phase Start Datetime | Num |  | Perm | The starting datetime for the phase defined by APHASE. |

### BDS Variables (part 20)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PHSDTF | Phase Start Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of phase start date. If PHSDT (or the date part of PHSDTM) was imputed, PHSDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHSTMF | Phase Start Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of phase start time. If PHSTM (or the time part of PHSDTM) was imputed, PHSTMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHEDT | Phase End Date | Num |  | Perm | The ending date for the phase defined by APHASE. |
| PHETM | Phase End Time | Num |  | Perm | The ending time for the phase defined by APHASE. |
| PHEDTM | Phase End Datetime | Num |  | Perm | The ending datetime for the phase defined by APHASE. |

### BDS Variables (part 21)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PHEDTF | Phase End Date Imput. Flag | Char | (DATEFL) | Cond | The level of imputation of phase end date. If PHEDT (or the date part of PHEDTM) was imputed, PHEDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| PHETMF | Phase End Time Imput. Flag | Char | (TIMEFL) | Cond | The level of imputation of phase end time. If PHETM (or the time part of PHEDTM) was imputed, PHETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *DT | {Date} | Num |  | Perm | Analysis date not directly characterizing AVAL and/or AVALC in numeric format. |
| *TM | {Time} | Num |  | Perm | Analysis time not directly characterizing AVAL and/or AVALC in numeric format. |
| *DTM | {Datetime} | Num |  | Perm | Analysis datetime not directly characterizing AVAL and/or AVALC in numeric format. |
| *ADY | {Relative Day} | Num |  | Perm | Analysis relative day not directly characterizing AVAL and/or AVALC. |

### BDS Variables (part 22)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| *DTF | {Date Imputation Flag} | Char | (DATEFL) | Cond | The level of imputation of *DT. If *DT (or the date part of *DTM) was imputed, *DTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *TMF | {Time Imputation Flag} | Char | (TIMEFL) | Cond | The level of imputation of *TM. If *TM (or the time part of *DTM) was imputed, *TMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *SDT | {Start Date} | Num |  | Perm | Starting analysis date not directly characterizing AVAL and/or AVALC in numeric format. |
| *STM | {Start Time} | Num |  | Perm | Starting analysis time not directly characterizing AVAL and/or AVALC in numeric format. |
| *SDTM | {Start Datetime} | Num |  | Perm | Starting analysis datetime not directly characterizing AVAL and/or AVALC in numeric format. |
| *SDY | {Relative Start Day} | Num |  | Perm | Starting analysis relative day not directly characterizing AVAL and/or AVALC. |

### BDS Variables (part 23)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| *SDTF | {Start Date Imputation Flag} | Char | (DATEFL) | Cond | The level of imputation of *SDT. If *SDT (or the date part of *SDTM) was imputed, *SDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *STMF | {Start Time Imputation Flag} | Char | (TIMEFL) | Cond | The level of imputation of *STM. If *STM (or the time part of *SDTM) was imputed, *STMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *EDT | {End Date} | Num |  | Perm | Ending analysis date not directly characterizing AVAL and/or AVALC in numeric format. |
| *ETM | {End Time} | Num |  | Perm | Ending analysis time not directly characterizing AVAL and/or AVALC in numeric format. |
| *EDTM | {End Datetime} | Num |  | Perm | Ending analysis datetime not directly characterizing AVAL and/or AVALC in numeric format. |
| *EDY | {Relative End Day} | Num |  | Perm | Ending analysis relative day not directly characterizing AVAL and/or AVALC. |

## Analysis Parameter Variables for BDS Datasets

*EDTF {End Date Imputation Flag} Char (DATEFL) Cond The level of imputation of *EDT. If *EDT (or the date part of *EDTM) was imputed, *EDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. *ETMF {End Time Imputation Flag} Char (TIMEFL) Cond The level of imputation of *ETM. If *ETM (or the time part of *EDTM) was imputed, *ETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables.

3.3.4 Analysis Parameter Variables for BDS Datasets

3.3.4.1 Analysis Parameter Variables

Table 3.3.4.1.1 Analysis Parameter Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| *EDTF | {End Date Imputation Flag} | Char | (DATEFL) | Cond | The level of imputation of *EDT. If *EDT (or the date part of *EDTM) was imputed, *EDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *ETMF | {End Time Imputation Flag} | Char | (TIMEFL) | Cond | The level of imputation of *ETM. If *ETM (or the time part of *EDTM) was imputed, *ETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAM | Parameter | Char |  | Req | The description of the analysis parameter. PARAM must include all descriptive and qualifying information relevant to the analysis purpose of the parameter. Some examples are: "Supine Systolic Blood Pressure (mm Hg)", "Log10 (Weight (kg))", "Time to First Hypertension Event (Days)", and "Estimated Tumor Growth Rate". PARAM should be sufficient to describe unambiguously the contents of AVAL and/or AVALC. Examples of qualifying information that might be relevant to analysis, and are therefore candidates for inclusion in PARAM, are units, specimen type, location, position, machine type, and transformation function. There is no need to include qualifiers that are not relevant to the analysis of PARAM. In contrast to SDTM --TEST, no additional variable is needed to further qualify PARAM. PARAM is restricted to a maximum of 200 characters. If the value of PARAM will be used as a variable label in a transposed dataset, then the producer may wish to limit the value of PARAM to 40 characters. Such limitation to 40 characters should not compromise the integrity of the description. PARAM is often directly usable in Clinical Study Report displays. Note that in the ADaMIG, "parameter" is a synonym of "analysis parameter." PARAM must be present and populated on every record in a BDS dataset. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAMCD | Parameter Code | Char |  | Req | The short name of the analysis parameter in PARAM. The values of PARAMCD must be no more than 8 characters in length, start with a letter (not underscore), and be comprised only of letters (A-Z), underscore ( ), and numerals (0-9). These constraints will allow for a BDS dataset to be transposed in such a way that _ the values of PARAMCD can be used as valid ADaM variable names per Section 3.1.1, General Variable Conventions. There must be a one-to-one relationship between PARAM and PARAMCD within a dataset. PARAMCD must be present and populated on every record in a BDS dataset. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAMN | Parameter (N) | Num |  | Perm | Numeric representation of PARAM. Useful for ordering and programmatic manipulation. There must be a one-to-one relationship between PARAM and PARAMN within a dataset for all parameters where PARAMN is populated. if PARAMN is populated on any record for a PARAM, it must be populated on every record for that PARAM. |
| PARCATy | Parameter Category y | Char |  | Perm | A categorization of PARAM within a dataset. For example, values of PARCAT1 might group the parameters having to do with a particular questionnaire, lab specimen type, or area of investigation. Note that PARCATy is not a qualifier for PARAM. PARAM to PARCATy is a many-to-one mapping; any given PARAM may be associated with at most one level of PARCATy (e.g., one level of PARCAT1 and one level of PARCAT2). |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARCATyN | Parameter Category y (N) | Num |  | Perm | Numeric representation of PARCATy. Useful for the ordering of values of PARCATy or for other purposes. There must be a one-to-one relationship between PARCATy and PARCATyN within a dataset. PARCATyN cannot be present unless PARCATy is also present. When PARCATy and PARCATyN are present, then on a given record, either both must be populated or both must be null. |

## Analysis Parameter Variables

*EDTF {End Date Imputation Flag} Char (DATEFL) Cond The level of imputation of *EDT. If *EDT (or the date part of *EDTM) was imputed, *EDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. *ETMF {End Time Imputation Flag} Char (TIMEFL) Cond The level of imputation of *ETM. If *ETM (or the time part of *EDTM) was imputed, *ETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables.

3.3.4 Analysis Parameter Variables for BDS Datasets

3.3.4.1 Analysis Parameter Variables

Table 3.3.4.1.1 Analysis Parameter Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| *EDTF | {End Date Imputation Flag} | Char | (DATEFL) | Cond | The level of imputation of *EDT. If *EDT (or the date part of *EDTM) was imputed, *EDTF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| *ETMF | {End Time Imputation Flag} | Char | (TIMEFL) | Cond | The level of imputation of *ETM. If *ETM (or the time part of *EDTM) was imputed, *ETMF must be populated and is required. See Section 3.1.3, Date and Time Imputation Flag Variables. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAM | Parameter | Char |  | Req | The description of the analysis parameter. PARAM must include all descriptive and qualifying information relevant to the analysis purpose of the parameter. Some examples are: "Supine Systolic Blood Pressure (mm Hg)", "Log10 (Weight (kg))", "Time to First Hypertension Event (Days)", and "Estimated Tumor Growth Rate". PARAM should be sufficient to describe unambiguously the contents of AVAL and/or AVALC. Examples of qualifying information that might be relevant to analysis, and are therefore candidates for inclusion in PARAM, are units, specimen type, location, position, machine type, and transformation function. There is no need to include qualifiers that are not relevant to the analysis of PARAM. In contrast to SDTM --TEST, no additional variable is needed to further qualify PARAM. PARAM is restricted to a maximum of 200 characters. If the value of PARAM will be used as a variable label in a transposed dataset, then the producer may wish to limit the value of PARAM to 40 characters. Such limitation to 40 characters should not compromise the integrity of the description. PARAM is often directly usable in Clinical Study Report displays. Note that in the ADaMIG, "parameter" is a synonym of "analysis parameter." PARAM must be present and populated on every record in a BDS dataset. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAMCD | Parameter Code | Char |  | Req | The short name of the analysis parameter in PARAM. The values of PARAMCD must be no more than 8 characters in length, start with a letter (not underscore), and be comprised only of letters (A-Z), underscore ( ), and numerals (0-9). These constraints will allow for a BDS dataset to be transposed in such a way that _ the values of PARAMCD can be used as valid ADaM variable names per Section 3.1.1, General Variable Conventions. There must be a one-to-one relationship between PARAM and PARAMCD within a dataset. PARAMCD must be present and populated on every record in a BDS dataset. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARAMN | Parameter (N) | Num |  | Perm | Numeric representation of PARAM. Useful for ordering and programmatic manipulation. There must be a one-to-one relationship between PARAM and PARAMN within a dataset for all parameters where PARAMN is populated. if PARAMN is populated on any record for a PARAM, it must be populated on every record for that PARAM. |
| PARCATy | Parameter Category y | Char |  | Perm | A categorization of PARAM within a dataset. For example, values of PARCAT1 might group the parameters having to do with a particular questionnaire, lab specimen type, or area of investigation. Note that PARCATy is not a qualifier for PARAM. PARAM to PARCATy is a many-to-one mapping; any given PARAM may be associated with at most one level of PARCATy (e.g., one level of PARCAT1 and one level of PARCAT2). |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PARCATyN | Parameter Category y (N) | Num |  | Perm | Numeric representation of PARCATy. Useful for the ordering of values of PARCATy or for other purposes. There must be a one-to-one relationship between PARCATy and PARCATyN within a dataset. PARCATyN cannot be present unless PARCATy is also present. When PARCATy and PARCATyN are present, then on a given record, either both must be populated or both must be null. |
| AVAL | Analysis Value | Num |  | Cond | Numeric analysis value described by PARAM. On a given record, it is permissible for AVAL, AVALC, or both to be null. AVAL is required if AVALC is not present, since either AVAL or AVALC must be present in the dataset. |

### BDS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AVALC | Analysis Value (C) | Char |  | Cond | Character analysis value described by PARAM. AVALC can be a character string mapping to AVAL, but if so there must be a one-to-one relationship between AVAL and AVALC within a given PARAM. AVALC should not be used to categorize the values of AVAL. Within a given parameter, if there exists a row on which both AVALC and AVAL are populated, then there must be a one-to-one relationship between AVALC and AVAL on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either AVAL or AVALC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for AVAL, AVALC, or both to be null. AVALC is required if AVAL is not present, since either AVAL or AVALC must be present in the dataset. |

### BDS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AVALCATy | Analysis Value Category y | Char |  | Perm | A categorization of AVAL or AVALC within a parameter. Not necessarily a one-to-one mapping to AVAL and/or AVALC. For example, if PARAM is "Headache Severity" and AVAL has values 0, 1, 2, or 3, AVALCAT1 can categorize AVAL into "None or Mild" (for AVAL 0 or 1) and "Moderate or Severe" (for AVAL 2 or 3). AVALCATy is parameter variant. |
| AVALCAyN | Analysis Value Category y (N) | Num |  | Perm | Numeric representation of AVALCATy. Useful for ordering of values of AVALCATy or for other purposes. There must be a one-to-one relationship between AVALCAyN and AVALCATy within a parameter. AVALCAyN cannot be present unless AVALCATy is also present. When AVALCATy and AVALCAyN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BASE | Baseline Value | Num |  | Cond | The subject's baseline analysis value for a parameter and baseline definition (i.e., BASETYPE) if present. BASE contains the value of AVAL copied from a record within the parameter on which ABLFL = "Y". Required if dataset supports analysis or review of numeric baseline value or functions of numeric baseline value. If BASE is populated for a parameter, and BASE is non-null for a subject for that parameter, then there must be a record flagged by ABLFL for that subject and parameter. Note that a baseline record may be derived (e.g., it may be an average) in which case DTYPE must be populated on the baseline record. |

### BDS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BASEC | Baseline Value (C) | Char |  | Perm | The subject's baseline value of AVALC for a parameter and baseline definition (i.e., BASETYPE) if present. May be needed when AVALC is of interest. BASEC contains the value of AVALC copied from a record within the parameter on which ABLFL = "Y". If both AVAL and AVALC are populated within a parameter, the baseline record for AVALC must be the same record as that for AVAL. Within a given parameter, if there exists a row on which both BASEC and BASE are populated, then there must be a one-to-one relationship between BASEC and BASE on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either BASE or BASEC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for BASE, BASEC, or both to be null. |

### BDS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BASECATy | Baseline Category y | Char |  | Perm | A categorization of BASE or BASEC within a parameter. Not necessarily a one-to-one mapping to BASE or BASEC. For example, if PARAM is "Headache Severity" and AVAL has values 0, 1, 2, or 3, BASECAT1 can categorize BASE into "None or Mild" (for BASE 0 or 1) and "Moderate or Severe" (for BASE 2 or 3). |
| BASECAyN | Baseline Category y (N) | Num |  | Perm | Numeric representation of BASECATy. Useful for ordering of values of BASECATy or for other purposes. There must be a one-to-one relationship between BASECAyN and BASECATy within a parameter. BASECAyN cannot be present unless BASECATy is also present. When BASECATy and BASECAyN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BASETYPE | Baseline Type | Char |  | Cond | Producer-defined text describing the definition of baseline relevant to the value of BASE on the current record. Required when there are multiple ways that baseline is defined. If used for any PARAM within a dataset, it must be non-null for all records for that PARAM within that dataset where either BASE or BASEC are also non-null. Refer to Section 4.2.1.6, Rule 6, for an example. |
| CHG | Change from Baseline | Num |  | Perm | Change from baseline analysis value. Equal to AVAL-BASE. If used for a given PARAM, should be populated for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of CHG is left to producer choice. |

### BDS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CHGCATy | Change from Baseline Category y | Char |  | Perm | A categorization of CHG within a parameter. Not necessarily a one-to-one mapping to CHG. The definition of CHGCATy may vary by PARAM. For example, CHGCAT1 may be used to categorize CHG with respect to ranges of change in SYSBP; "-10 to -5 mm Hg", "-5 to 0 mm Hg" categories. |
| CHGCATyN | Change from Baseline Category y (N) | Num |  | Perm | Numeric representation of CHGCATy. Useful for ordering of values of CHGCATy or for other purposes. There must be a one-to-one relationship between CHGCATyN and CHGCATy within a parameter. CHGCATyN cannot be present unless CHGCATy is also present. When CHGCATy and CHGCATyN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PCHG | Percent Change from Baseline | Num |  | Perm | Percent change from baseline analysis value. Equal to ((AVAL-BASE)/BASE)*100. If used for a given PARAM, should be populated (when calculable) for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of PCHG is left to producer choice. |
| PCHGCATy | Percent Chg from Baseline Category y | Char |  | Perm | A categorization of PCHG within a parameter. Not necessarily a one-to-one mapping to PCHG. The definition of PCHGCATy may vary by PARAM. For example, PCHGCAT1 may be used to categorize PCHG with respect to ranges of change in SYSBP; ">5%", ">10%" categories. |

### BDS Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PCHGCAyN | Percent Chg from Baseline Category y (N) | Num |  | Perm | Numeric representation of PCHGCATy. Useful for ordering of values of PCHGCATy or for other purposes. There must be a one-to-one relationship between PCHGCAyN and PCHGCATy within a parameter. PCHGCAyN cannot be present unless PCHGCATy is also present. When PCHGCATy and PCHGCAyN are present, then on a given record, either both must be populated or both must be null. |
| R2BASE | Ratio to Baseline | Num |  | Perm | Ratio to the baseline value. Equal to AVAL / BASE. If used for a given PARAM, should be populated for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of R2BASE is left to producer choice. |

### BDS Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| R2AyLO | Ratio to Analysis Range y Lower Limit | Num |  | Perm | Ratio to the lower limit of the analysis range y. Equal to AVAL / AyLO. AyLO must exist in the ADaM dataset. If used for a given PARAM, should be populated for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of R2AyLO is left to producer choice. |
| R2AyHI | Ratio to Analysis Range y Upper Limit | Num |  | Perm | Ratio to the upper limit of the analysis range y. Equal to AVAL / AyHI. AyHI must exist in the ADaM dataset. If used for a given PARAM, should be populated for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of R2AyHI is left to producer choice. |

### BDS Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SHIFTy | Shift y | Char |  | Perm | A shift in values depending on the defined pairing for group y within a parameter. SHIFTy can only be based on the change in value of any of the following pairs (BASECATy, AVALCATy), (BNRIND, ANRIND), (ByIND, AyIND), (BTOXGR, ATOXGR), (BTOXGRL, ATOXGRL), (BTOXGRH, ATOXGRH), (BASE, AVAL) or (BASEC, AVALC). Useful for shift tables. For example, "NORMAL to HIGH". If used for a given PARAM, should be populated (when calculable) for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate baseline and pre-baseline values of SHIFTy is left to producer choice. |

### BDS Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SHIFTyN | Shift y (N) | Num |  | Perm | Numeric representation of SHIFTy. There must be a one-to-one relationship between SHIFTyN and SHIFTy within a parameter.SHIFTyN cannot be present unless SHIFTy is also present. When SHIFTy and SHIFTyN are present, then on a given record, either both must be populated or both must be null.If SHIFTyN is used for a given PARAM, SHIFTy and SHIFTyN should be populated (when calculable) for all post-baseline records of that PARAM regardless of whether that record is used for analysis. |
| BCHG | Change to Baseline | Num |  | Perm | Change to baseline analysis value. Equal to BASE-AVAL. If used for a given PARAM, should be populated for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of BCHG is left to producer choice. |

### BDS Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BCHGCATy | Change to Baseline Category y | Char |  | Perm | A categorization of BCHG within a parameter. Not necessarily a one-to-one mapping to BCHG. The definition of BCHGCATy may vary by PARAM. For example, BCHGCAT1 may be used to categorize BCHG with respect to ranges of change in SYSBP; "-10 to -5 mm Hg", "-5 to 0 mm Hg" categories. |
| BCHGCAyN | Change to Baseline Category y (N) | Num |  | Perm | Numeric representation of BCHGCATy. Useful for ordering of values of BCHGCATy or for other purposes. There must be a one-to-one relationship between BCHGCAyN and BCHGCATy within a parameter. BCHGCAyN cannot be present unless BCHGCATy is also present. When BCHGCATy and BCHGCAyN are present, then on a given record, either both must be populated or both must be null. |

## PARAM, AVAL, and AVALC

PBCHG Percent Change to Baseline

Num Perm Percent change to baseline analysis value. Equal to ((BASE-AVAL)/AVAL)*100. If used for a given PARAM, should be populated (when calculable) for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of PBCHG is left to producer choice PBCHGCAy Percent Change to Baseline Category y

Char Perm A categorization of PBCHG within a parameter. Not necessarily a one-to-one mapping to PBCHG. The definition of PBCHGCAy may vary by PARAM. For example, PBCHGCA1 may be used to categorize PBCHG with respect to ranges of change in SYSBP; ">5%", ">10%" categories. PBCHGCyN Percent Change to Baseline Category y (N)

Num Perm Numeric representation of PBCHGCAy. Useful for ordering of values of PBCHGCAy or for other purposes. There must be a one-to-one relationship between PBCHGCyN and PBCHGCAy within a parameter. PBCHGCyN cannot be present unless PBCHGCAy is also present. When PBCHGCAy and PBCHGCyN are present, then on a given record, either both must be populated or both must be null.

Users may create additional variables that are parameter-invariant functions of AVAL and BASE on the same row. See Section 4.2, Creation of Derived Columns Versus Creation of Derived Rows, for the rules governing when derivations are added as rows, and when they are added as columns.

3.3.4.2 PARAM, AVAL, and AVALC

It is important to understand a key difference in approach between the SDTM Findings class variable --TEST and the ADaM BDS variable PARAM. SDTM -- TEST is designed to work in conjunction with other variables called "qualifiers" (e.g., specimen type, machine type, body position) in order to describe the collected result. In contrast, the ADaM BDS variable PARAM does not have any accompanying qualifier variables. PARAM is the only variable that describes AVAL or AVALC. Qualifiers are not allowed.

PARAM is created to meet an analysis need, not just because something was collected. PARAM may describe an analysis value that is highly derived from subject data from any combination of SDTM domains of any class or classes, and/or any ADaM dataset. PARAM describes what is in AVAL or AVALC.

For most parameters, only AVAL or AVALC will be populated, not both. That both --STRESC and --STRESN are present and populated in SDTM Findings class domains does not imply that both AVAL and AVALC must be present and populated in BDS datasets. AVAL and AVALC have a different purpose than -- STRESN and --STRESC. For example, for parameters corresponding to numeric tests in SDTM Findings class domains, it is not recommended to copy SDTM -- STRESC into AVALC, because there is no analysis need for a character value. Further, doing so may result in breaking the one-to-one mapping requirement in some cases. If it is desired for traceability or listing purposes to bring the value of --STRESC into the ADaM dataset, the variable --STRESC may be copied as is without renaming it.

AVAL and AVALC are both populated only when one-to-one mapping may be useful, for example:

• When PARAM describes the numeric score of an individual question from a questionnaire, AVAL contains the score, and AVALC can be populated with the question answer text. Populating AVALC with the question answer text is supportive of review, and may help the consumer understand the meaning of the numeric score that is the subject of the parameter. Within the parameter, there is a one-to-one relationship between AVAL and AVALC on the rows on which both are populated.

• When PARAM describes a character-valued response from a set of possible values, the result is contained in AVALC. If desired for ordering or other reasons, AVAL can also be populated, as long as the result of populating both AVAL and AVALC for the parameter is that they are a one-to-one map on the rows on which both are populated.

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PBCHG | Percent Change to Baseline | Num |  | Perm | Percent change to baseline analysis value. Equal to ((BASE-AVAL)/AVAL)*100. If used for a given PARAM, should be populated (when calculable) for all post-baseline records of that PARAM regardless of whether that record is used for analysis. The decision on how to populate pre-baseline and baseline values of PBCHG is left to producer choice |
| PBCHGCAy | Percent Change to Baseline Category y | Char |  | Perm | A categorization of PBCHG within a parameter. Not necessarily a one-to-one mapping to PBCHG. The definition of PBCHGCAy may vary by PARAM. For example, PBCHGCA1 may be used to categorize PBCHG with respect to ranges of change in SYSBP; ">5%", ">10%" categories. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| PBCHGCyN | Percent Change to Baseline Category y (N) | Num |  | Perm | Numeric representation of PBCHGCAy. Useful for ordering of values of PBCHGCAy or for other purposes. There must be a one-to-one relationship between PBCHGCyN and PBCHGCAy within a parameter. PBCHGCyN cannot be present unless PBCHGCAy is also present. When PBCHGCAy and PBCHGCyN are present, then on a given record, either both must be populated or both must be null. |

## Analysis Parameter Criteria Variables for BDS Datasets

3.3.4.3 Analysis Parameter Criteria Variables for BDS Datasets

Table 3.3.4.3.1 BDS Analysis Parameter Criteria Variables

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CRITy | Analysis Criterion y | Char |  | Perm | A text string identifying a pre-specified criterion within a parameter, for example SYSBP > 90. Required if CRITyFL is present. In some cases, the presence of the text string indicates that the criterion is satisfied on this record and CRITyFL is set to Y, while a null value indicates that the criterion is not satisfied or is not evaluable and is accompanied by a null value in CRITyFL. In other cases, the text string identifies the criterion being evaluated and is populated on every row for the parameter, but whether or not the criterion is satisfied is indicated by the value of the variable CRITyFL. See CRITyFL and CRITyFN. Refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion of CRITy, CRITyFL and CRITyFN. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CRITyFL | Criterion y Evaluation Result Flag | Char | Y or Y, N | Cond | Character flag variable indicating whether the criterion defined in CRITy was met by the data on the record. See CRITy for more information regarding how to use CRITy and CRITyFL to indicate whether a criterion is met. Required if CRITy is present. Refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion. |
| CRITyFN | Criterion y Evaluation Result Flag (N) | Num | 1 or 1, 0 | Perm | Numeric representation of CRITyFL. There must be a one-to-one relationship between CRITyFN and CRITyFL within a parameter. CRITyFN cannot be present unless CRITyFL is also present. When CRITyFL and CRITyFN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| MCRITy | Analysis Multi-Response Criterion y | Char |  | Perm | A text string identifying a pre-specified criterion within a parameter, where the criterion can have multiple responses (as opposed to CRITy which has binary responses). Required if MCRITyML is present. For example, the grade of a lab analyte is compared to the baseline grade, with the possible conditions being 0 to 1, 0 to 2, etc. The text string identifies the criterion being evaluated (for example, "Grade increase") and is populated on every row for the parameter; which level of the criterion is satisfied is indicated by the value of the variable MCRITyML (for example "0 to 1", "0 to 2", etc.). See MCRITyML and MCRITyMN below, and refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion of MCRITy, MCRITyML, and MCRITyMN. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| MCRITyML | Multi-Response Criterion y Evaluation | Char |  | Cond | Character variable indicating which level of the criterion defined in MCRITy was met by the data on the record. See MCRITy for more information regarding how to use MCRITy and MCRITyML to indicate whether a criterion was met. Content is sponsor-defined. Required if MCRITy is present. |
| MCRITyMN | Multi-Response Criterion y Eval (N) | Num |  | Perm | Numeric representation of MCRITyML. There must be a one-to-one relationship between MCRITyMN and MCRITyML within a parameter. Content is sponsor-defined. MCRITyMN cannot be present unless MCRITyML is also present. When MCRITyML and MCRITyMN are present, then on a given record, either both must be populated or both must be null. |

## Analysis Descriptor Variables for BDS Datasets

3.3.4.3 Analysis Parameter Criteria Variables for BDS Datasets

Table 3.3.4.3.1 BDS Analysis Parameter Criteria Variables

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CRITy | Analysis Criterion y | Char |  | Perm | A text string identifying a pre-specified criterion within a parameter, for example SYSBP > 90. Required if CRITyFL is present. In some cases, the presence of the text string indicates that the criterion is satisfied on this record and CRITyFL is set to Y, while a null value indicates that the criterion is not satisfied or is not evaluable and is accompanied by a null value in CRITyFL. In other cases, the text string identifies the criterion being evaluated and is populated on every row for the parameter, but whether or not the criterion is satisfied is indicated by the value of the variable CRITyFL. See CRITyFL and CRITyFN. Refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion of CRITy, CRITyFL and CRITyFN. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CRITyFL | Criterion y Evaluation Result Flag | Char | Y or Y, N | Cond | Character flag variable indicating whether the criterion defined in CRITy was met by the data on the record. See CRITy for more information regarding how to use CRITy and CRITyFL to indicate whether a criterion is met. Required if CRITy is present. Refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion. |
| CRITyFN | Criterion y Evaluation Result Flag (N) | Num | 1 or 1, 0 | Perm | Numeric representation of CRITyFL. There must be a one-to-one relationship between CRITyFN and CRITyFL within a parameter. CRITyFN cannot be present unless CRITyFL is also present. When CRITyFL and CRITyFN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| MCRITy | Analysis Multi-Response Criterion y | Char |  | Perm | A text string identifying a pre-specified criterion within a parameter, where the criterion can have multiple responses (as opposed to CRITy which has binary responses). Required if MCRITyML is present. For example, the grade of a lab analyte is compared to the baseline grade, with the possible conditions being 0 to 1, 0 to 2, etc. The text string identifies the criterion being evaluated (for example, "Grade increase") and is populated on every row for the parameter; which level of the criterion is satisfied is indicated by the value of the variable MCRITyML (for example "0 to 1", "0 to 2", etc.). See MCRITyML and MCRITyMN below, and refer to Section 4.7, Identification of Records which Satisfy a Predefined Criterion for Analysis Purposes, for additional discussion of MCRITy, MCRITyML, and MCRITyMN. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| MCRITyML | Multi-Response Criterion y Evaluation | Char |  | Cond | Character variable indicating which level of the criterion defined in MCRITy was met by the data on the record. See MCRITy for more information regarding how to use MCRITy and MCRITyML to indicate whether a criterion was met. Content is sponsor-defined. Required if MCRITy is present. |
| MCRITyMN | Multi-Response Criterion y Eval (N) | Num |  | Perm | Numeric representation of MCRITyML. There must be a one-to-one relationship between MCRITyMN and MCRITyML within a parameter. Content is sponsor-defined. MCRITyMN cannot be present unless MCRITyML is also present. When MCRITyML and MCRITyMN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| DTYPE | Derivation Type | Char | (DTYPE) | Cond | Analysis value derivation method. DTYPE is used to denote, and must be populated, when the value of AVAL or AVALC has been imputed or derived differently than the other analysis values within the parameter. DTYPE is required to be populated even if AVAL and AVALC are null on the derived record. Three common situations when DTYPE should be populated: • A new row is added within a parameter with the analysis value populated based on other rows within the parameter. • A new row is added within a parameter with the analysis value populated based on a constant value or data from other subjects. • An analysis value (AVAL or AVALC) on an existing record is being replaced with a value based on a pre- specified algorithm. DTYPE is used to denote analysis values that are "special cases" within a parameter. For each value of DTYPE, the precise derivation algorithm must be defined in analysis variable metadata, even for DTYPE values in the CDISC Controlled Terminology. The controlled terminology for DTYPE is extensible. See Section 4, Implementation Issues, Standard Solutions, and Examples for examples of the use of DTYPE. Some examples of DTYPE values: |

## Time-to-Event Variables for BDS Datasets

• LOCF = last observation carried forward • WOCF = worst observation carried forward • AVERAGE = average of values

If analysis timepoints are defined by relative day or hour windows, then the variables in Table 3.3.5.2 may be used along with ADY or ARELTM to clarify how the record representing each analysis timepoint was chosen from among the possible candidates. The record chosen is indicated by the analyzed record flag ANLzzFL (see Table 3.3.8.1). Note that the variables in Table 3.3.5.2 may not be applicable in all situations and are presented as an option.

Table 3.3.5.2 Analysis Visit Windowing Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AWRANGE | Analysis Window Valid Relative Range | Char |  | Perm | The range of values that are valid for a given analysis timepoint (a given value of AVISIT). For example, "5-9 DAYS". |
| AWTARGET | Analysis Window Target | Num |  | Perm | The target or most desired analysis relative day (ADY) value or analysis relative time (ARELTM) value for a given value of AVISIT. |
| AWTDIFF | Analysis Window Diff from Target | Num |  | Perm | Absolute difference between ADY or ARELTM and AWTARGET. It will be necessary to adjust for the fact that there is no Day 0 in the event that ADY and AWTARGET are not of the same sign. If the sign of the difference is important, then AWTDIFF might have to be used in conjunction with ADY or ARELTM and possibly AWTARGET when choosing among records. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AWLO | Analysis Window Beginning Timepoint | Num |  | Perm | The value of the beginning timepoint (inclusive) needs to be used in conjunction to AWRANGE. For example, if AWRANGE is "5-9 DAYS", then AWLO is "5". |
| AWHI | Analysis Window Ending Timepoint | Num |  | Perm | The value of the ending timepoint (inclusive) needs to be used in conjunction to AWRANGE. For example, if AWRANGE is "5-9 DAYS", then AWHI is "9". |
| AWU | Analysis Window Unit | Char |  | Perm | Unit used for AWTARGET, AWTDIFF, AWLO and AWHI. Examples: DAYS, HOURS. |
| STARTDT | Time-to-Event Origin Date for Subject | Num |  | Perm | The original date of risk for the time-to-event analysis. This is generally the point at which a subject is first at risk for the event of interest evaluation (as defined in the Protocol or SAP). For example, this may be the randomization date or the date of first study therapy exposure. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| STARTDTM | Time-to-Event Origin Datetime | Num |  | Perm | The original datetime of risk for the time-to-event analysis. This is generally the point at which a subject is first at risk for the event of interest evaluation (as defined in the Protocol or SAP). For example, this may be the randomization datetime or the datetime of first study therapy exposure. |
| STARTDTF | Origin Date Imputation Flag | Char | (DATEFL) | Cond | The level of imputation of the start date. See Section 3.1.3, Date and Time Imputation Flag Variables. |
| STARTTMF | Origin Time Imputation Flag | Char | (TIMEFL) | Cond | The level of imputation of the start time. See Section 3.1.3, Date and Time Imputation Flag Variables. |

## Toxicity and Range Variables for BDS Datasets

CNSR Censor Num Cond Defines whether the event was censored for the subject within the parameter (period of observation truncated prior to event being observed). It is strongly recommended to use 0 as an event indicator and positive integers as censoring indicators. It is also recommended that unique positive integers be used to indicate coded descriptions of censoring reasons. CNSR is required for time-to-event parameters. EVNTDESC Event or Censoring Description

Char Perm Description of the event of interest or censoring reason for the subject within the parameter.

CNSDTDSC Censor Date Description Char Perm Describes the circumstance represented by the censoring date if different from the event date that warrants censoring.

3.3.7 Toxicity and Range Variables for BDS Datasets

Table 3.3.7.1 Toxicity and Range Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| CNSR | Censor | Num |  | Cond | Defines whether the event was censored for the subject within the parameter (period of observation truncated prior to event being observed). It is strongly recommended to use 0 as an event indicator and positive integers as censoring indicators. It is also recommended that unique positive integers be used to indicate coded descriptions of censoring reasons. CNSR is required for time-to-event parameters. |
| EVNTDESC | Event or Censoring Description | Char |  | Perm | Description of the event of interest or censoring reason for the subject within the parameter. |
| CNSDTDSC | Censor Date Description | Char |  | Perm | Describes the circumstance represented by the censoring date if different from the event date that warrants censoring. |
| ATOXGR | Analysis Toxicity Grade | Char |  | Perm | Toxicity grade of AVAL or AVALC for analysis; may be based on SDTM --TOXGR or an imputed or assigned value. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATOXGRN | Analysis Toxicity Grade (N) | Num |  | Perm | Numeric representation of ATOXGR. There must be a one-to-one relationship between ATOXGRN and ATOXGR within a parameter. ATOXGRN cannot be present unless ATOXGR is also present. When ATOXGR and ATOXGRN are present, then on a given record, either both must be populated or both must be null. |
| BTOXGR | Baseline Toxicity Grade | Char |  | Perm | ATOXGR of the baseline record identified by ABLFL. |
| BTOXGRN | Baseline Toxicity Grade (N) | Num |  | Perm | Numeric representation of BTOXGR. There must be a one-to-one relationship between BTOXGRN and BTOXGR within a parameter. BTOXGRN cannot be present unless BTOXGR is also present. When BTOXGR and BTOXGRN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANRIND | Analysis Reference Range Indicator | Char |  | Perm | Indicates where AVAL or AVALC falls with respect to the normal reference range for analysis; may be based on SDTM --NRIND or an imputed or assigned value. |
| BNRIND | Baseline Reference Range Indicator | Char |  | Perm | ANRIND of the baseline record identified by ABLFL. |
| ANRLO | Analysis Normal Range Lower Limit | Num |  | Perm | Normal range lower limit for analysis; may be based on SDTM --NRLO or an imputed or assigned value. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANRLOC | Analysis Normal Range Lower Limit (C) | Char |  | Perm | Character analysis normal range lower limit. ANRLOC can be a character string mapping to ANRLO, but if so there must be a one-to-one relationship between ANRLO and ANRLOC within a given PARAM. ANRLOC should not be used to categorize the values of ANRLO. Within a given parameter, if there exists a row on which both ANRLOC and ANRLO are populated, then there must be a one-to-one relationship between ANRLOC and ANRLO on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either ANRLO or ANRLOC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for ANRLO, ANRLOC, or both to be null. |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANRHI | Analysis Normal Range Upper Limit | Num |  | Perm | Normal range upper limit for analysis; may be based on SDTM --NRHI or an imputed or assigned value. |

### BDS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANRHIC | Analysis Normal Range Upper Limit (C) | Char |  | Perm | Character analysis normal range upper limit. ANRHIC can be a character string mapping to ANRHI, but if so there must be a one-to-one relationship between ANRHI and ANRHIC within a given PARAM. ANRHIC should not be used to categorize the values of ANRHI. Within a given parameter, if there exists a row on which both ANRHIC and ANRHI are populated, then there must be a one-to-one relationship between ANRHIC and ANRHI on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either ANRHI or ANRHIC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for ANRHI, ANRHIC, or both to be null. |

### BDS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AyLO | Analysis Range y Lower Limit | Num |  | Cond | AyLO and/or AyHI are used for analysis ranges other than the normal range. AyLO and/or AyHI are created to capture the different levels of cutoff values used to determine whether an analysis is within a clinically acceptable value range or outside that value range. AyLO and/or AyHI are usually but not necessarily constants, parameter-specific constants, or subject-specific constants. AyLO must be included if R2AyLO is included in the dataset. |

### BDS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AyLOC | Analysis Range y Lower Limit (C) | Char |  | Perm | Character analysis range y lower limit. AyLOC can be a character string mapping to AyLO, but if so there must be a one-to-one relationship between AyLO and AyLOC within a given PARAM. AyLOC should not be used to categorize the values of AyLO. Within a given parameter, if there exists a row on which both AyLOC and AyLO are populated, then there must be a one-to-one relationship between AyLOC and AyLO on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either AyLO or AyLOC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for AyLO, AyLOC, or both to be null. |

### BDS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AyHI | Analysis Range y Upper Limit | Num |  | Cond | See AyLO. For example, if ECG QTc values are summarized based on values >450, values >480, and values >500, there is a need for 3 "hi value" range variables against which to compare values: A1HI=450, A2HI=480, A3HI=500. AyHI must be included if R2AyHI is included in the dataset. |

### BDS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AyHIC | Analysis Range y Upper Limit (C) | Char |  | Perm | Character analysis range y upper limit. AyHIC can be a character string mapping to AyHI, but if so there must be a one-to-one relationship between AyHI and AyHIC within a given PARAM. AyHIC should not be used to categorize the values of AyHI. Within a given parameter, if there exists a row on which both AyHIC and AyHI are populated, then there must be a one-to-one relationship between AyHIC and AyHI on all rows on which both variables are populated. (In other words, there is no requirement that records with a null value in either AyHI or AyHIC be included when determining whether the one-to-one relationship requirement is satisfied.) On a given record, it is permissible for AyHI, AyHIC, or both to be null. |

### BDS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| AyIND | Analysis Range y Indicator | Char |  | Perm | Indicates relationship of AVAL to the analysis range variables AyLO and/or AyHI, or the relationship of AVALC to the analysis range variables AyLOC and/or AyHIC. |
| ByIND | Baseline Analysis Range y Indicator | Char |  | Perm | AyIND of the baseline record identified by ABLFL. |
| ATOXGRL | Analysis Toxicity Grade Low | Char |  | Perm | Low toxicity grade of AVAL or AVALC for analysis; may be based on SDTM --TOXGR or an imputed or assigned value. Used to assess when a subject's lab value falls within the low toxicity range. |
| ATOXGRLN | Analysis Toxicity Grade Low (N) | Num |  | Perm | Numeric representation of ATOXGRL. There must be a one-to-one relationship between ATOXGRLN and ATOXGRL within a parameter. ATOXGRLN cannot be present unless ATOXGRL is also present. When ATOXGRL and ATOXGRLN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATOXGRH | Analysis Toxicity Grade High | Char |  | Perm | High toxicity grade of AVAL or AVALC for analysis; may be based on SDTM --TOXGR or an imputed or assigned value. Used to assess when a subject's lab value falls within the high toxicity range. |
| ATOXGRHN | Analysis Toxicity Grade High (N) | Num |  | Perm | Numeric representation of ATOXGRH. There must be a one-to-one relationship between ATOXGRHN and ATOXGRH within a parameter. ATOXGRHN cannot be present unless ATOXGRH is also present. When ATOXGRH and ATOXGRHN are present, then on a given record, either both must be populated or both must be null. |
| BTOXGRL | Baseline Toxicity Grade Low | Char |  | Perm | ATOXGRL of the baseline record identified by ABLFL. |
| BTOXGRLN | Baseline Toxicity Grade Low (N) | Num |  | Perm | Numeric representation of BTOXGRL. There must be a one-to-one relationship between BTOXGRLN and BTOXGRL within a parameter. |

## Indicator Variables for BDS Datasets

BTOXGRLN cannot be present unless BTOXGRL is also present. When BTOXGRL and BTOXGRLN are present, then on a given record, either both must be populated or both must be null. BTOXGRH Baseline Toxicity Grade High Char Perm ATOXGRH of the baseline record identified by ABLFL. BTOXGRHN Baseline Toxicity Grade High

(N)

Num Perm Numeric representation of BTOXGRH. There must be a one-to-one relationship between BTOXGRHN and BTOXGRH within a parameter. BTOXGRHN cannot be present unless BTOXGRH is also present. When BTOXGRH and BTOXGRHN are present, then on a given record, either both must be populated or both must be null. ATOXDSCL Analysis Toxicity Description Low

Char Perm The analysis toxicity term used to describe toxicity in the low direction. ATOXDSCL is only populated if AVAL is populated and the PARAM is evaluated for toxicity in the low direction. There is a one-to-one relationship between ATOXDSCL and PARAM within a subject. The intent of this variable is to describe the type of toxicity being evaluated and not the level of toxicity on the specific record. ATOXDSCH Analysis Toxicity Description High

Char Perm The analysis toxicity term used to describe toxicity in the high direction. ATOXDSCH is only populated if AVAL is populated and the PARAM is evaluated for toxicity in the high direction. There is a one-to-one relationship between ATOXDSCH and PARAM within a subject. The intent of this variable is to describe the type of toxicity being evaluated and not the level of toxicity on the specific record.

See Section 4.9, Examples of Bi-directional Lab Toxicity Variables, for some examples of the use of these variables.

3.3.8 Indicator Variables for BDS Datasets

Refer to Section 3.1.4, Flag Variable Conventions, for important points about the use of flag variables. See Section 3.5, Differences Between SDTM and ADaM Population and Baseline Flags, for a discussion of the differences between ADaM and SDTM population and baseline flags, and for a discussion of parameterlevel and record-level population flags. For flag variables, values of only "Y" or null are used when a value of "N" is unimportant to the analysis (i.e., "N" and null are treated the same in the analysis). Flag values of "Y", "N", or null should be used when "N" and null are treated differently in the analysis. In Tables 3.3.8.1 and 3.3.8.2, the values shown in the Codelist/Controlled Terms column support common statistical needs. If required, the codelist/controlled terms values can be changed from "Y" to "Y, N".

Table 3.3.8.1 Flag Variables for BDS Datasets

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| BTOXGRH | Baseline Toxicity Grade High | Char |  | Perm | ATOXGRH of the baseline record identified by ABLFL. |
| BTOXGRHN | Baseline Toxicity Grade High (N) | Num |  | Perm | Numeric representation of BTOXGRH. There must be a one-to-one relationship between BTOXGRHN and BTOXGRH within a parameter. BTOXGRHN cannot be present unless BTOXGRH is also present. When BTOXGRH and BTOXGRHN are present, then on a given record, either both must be populated or both must be null. |
| ATOXDSCL | Analysis Toxicity Description Low | Char |  | Perm | The analysis toxicity term used to describe toxicity in the low direction. ATOXDSCL is only populated if AVAL is populated and the PARAM is evaluated for toxicity in the low direction. There is a one-to-one relationship between ATOXDSCL and PARAM within a subject. The intent of this variable is to describe the type of toxicity being evaluated and not the level of toxicity on the specific record. |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ATOXDSCH | Analysis Toxicity Description High | Char |  | Perm | The analysis toxicity term used to describe toxicity in the high direction. ATOXDSCH is only populated if AVAL is populated and the PARAM is evaluated for toxicity in the high direction. There is a one-to-one relationship between ATOXDSCH and PARAM within a subject. The intent of this variable is to describe the type of toxicity being evaluated and not the level of toxicity on the specific record. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ABLFL | Baseline Record Flag | Char | Y | Cond | Character indicator to identify the baseline record for each subject, parameter, and baseline type (BASETYPE) combination. See BASETYPE in Table 3.3.4.1.1. ABLFL is required if BASE is present in the dataset. A baseline record may be derived (e.g., it may be an average), in which case DTYPE must also be populated. If BASE is populated for a parameter, and BASE is non-null for a subject for that parameter, then there must be a record flagged by ABLFL for that subject and parameter. |
| ABLFN | Baseline Record Flag (N) | Num | 1 | Perm | Numeric representation of ABLFL. There must be a one-to-one relationship between ABLFN and ABLFL. ABLFN cannot be present unless ABLFL is also present. When ABLFL and ABLFN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANLzzFL | Analysis Flag zz | Char | Y | Cond | ANLzzFL is a conditionally required flag to be used in addition to other selection variables when the other selection variables in combination are insufficient to identify the exact set of records used for one or more analyses. Often one ANLzzFL will serve to support the accurate selection of records for more than one analysis. Note that it is allowable to add additional descriptive text to the label (see Section 3.1.6, Additional Information about Section 3, Item 1). When defining the set of records used in a particular analysis or family of analyses, ANLzzFL is supplemental to, and is intended to be used in conjunction with, other selection variables, such as subject-level, parameter-level and record-level population flags, AVISIT, DTYPE, grouping variables such as SITEGRy, and others. The lower-case letter "zz" in the variable name is an index for the zzth record selection algorithm where "zz" is replaced with a zero-padded two-digit integer [01-99]. Every record selection algorithm "zz" (i.e., every algorithm for populating an ANLzzFL) must be defined in variable metadata. When the set of records that the algorithm "zz" operates on is pre-filtered by application of other criteria, such as a record-level population flag, then the selection algorithm definition in the metadata must so specify. Note that the ANLzzFL value of Y indicates that the record fulfilled the requirements of the algorithm, but does not necessarily imply that the record was actually used in one or more analyses, as whether or not a record is used also depends on the other selection variables applied. The ANLzzFL flag is useful in many circumstances; an example is when there is more than one record for an analysis timepoint within a subject and parameter, as it can be used to identify the record chosen to represent the timepoint for an analysis. "zz" is an index for a record selection algorithm, such as "record closest to target relative day for the AVISIT, with ties broken by the latest record, for each AVISIT within <list of AVISITS>." Note that it is not required that a specific ANLzzFL variable has the same definition across a project or even across datasets within a study. There is also no requirement that the ANLzzFL variables in a dataset or study be used in numerical order; e.g. ANL02FL might occur in a dataset or study without ANL01FL present in the same dataset or study. |

### BDS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ANLzzFN | Analysis Flag zz (N) | Num | 1 | Perm | Numeric representation of ANLzzFL. There must be a one-to-one relationship between ANLzzFN and ANLzzFL within a dataset. ANLzzFN cannot be present unless ANLzzFL is also present. When ANLzzFL and ANLzzFN are present, then on a given record, either both must be populated or both must be null. |
| ONTRTFL | On Treatment Record Flag | Char | Y | Perm | Character indicator of whether the observation occurred while the subject was on treatment. ONTRTFL is producer-defined, and its definition may vary across datasets in a study based on analysis needs. |
| ONTRTFN | On Treatment Record Flag (N) | Num | 1 | Perm | Numeric representation of ONTRTFL. There must be a one-to-one relationship between ONTRTFN and ONTRTFL within a dataset. ONTRTFN cannot be present unless ONTRTFL is also present. When ONTRTFL and ONTRTFN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| LVOTFL | Last Value On Treatment Record Flag | Char | Y | Perm | Character indicator of the subject's last non-missing value on treatment for each parameter. |
| LVOTFN | Last Value On Treatment Record Flag (N) | Num | 1 | Perm | Numeric representation of LVOTFL. There must be a one-to-one relationship between LVOTFN and LVOTFL within a dataset. LVOTFN cannot be present unless LVOTFL is also present. When LVOTFL and LVOTFN are present, then on a given record, either both must be populated or both must be null. |

### BDS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| ITTRFL | Intent-To-Treat Record-Level Flag | Char | Y | Perm | These indicators identify whether or not the subject was in the specified analysis for the specific record. Useful when the subject is included in the subject-level population, but there are records for the subject that do not satisfy requirements for the population. The valid values of these record-level population indicators are Y or null. If a flag is used, the corresponding numeric version (*FN, where 1=Yes) of the flag can also be included. As described in Item 8 in Section 3.1.1 General Variable Conventions, the *FN version of the variable can be included only if the corresponding *FL is also included. Additional indicators may also be used; refer to Section 3.1.4, Flag Variable Conventions. |
| SAFRFL | Safety Analysis Record- Level Flag | Char | Y | Perm |  |
| FASRFL | Full Analysis Set Record- Level Flag | Char | Y | Perm |  |
| PPROTRFL | Per-Protocol Record-Level Flag | Char | Y | Perm |  |

### BDS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| COMPLRFL | Completers Record-Level Flag | Char | Y | Perm |  |
| ITTPFL | Intent-To-Treat Parameter- Level Flag | Char | Y | Perm |  |

## Datapoint Traceability Variables

SAFPFL Safety Analysis ParameterLevel Flag

Char Y Perm These indicators identify whether or not the subject was in the specified analysis for the specific parameter. Useful when the subject is included in the subject-level population, but there are parameters for which the subject does not satisfy requirements for the population. The valid values of these parameter-level population indicators are Y or null. If a flag is used, the corresponding numeric version (*FN, where 1=Yes) of the flag can also be included. As described in Item 8 in Section 3.1.1 General Variable Conventions, the *FN version of the variable can be included only if the corresponding *FL is also included. Additional indicators may also be used; refer to Section 3.1.4, Flag Variable Conventions.

FASPFL Full Analysis Set ParameterLevel Flag

Char Y Perm

PPROTPFL Per-Protocol ParameterLevel Flag

Char Y Perm

COMPLPFL Completers Parameter-Level Flag

Char Y Perm

3.3.9 Datapoint Traceability Variables

Variables to support datapoint traceability should be included whenever practical and feasible. Primary candidates for datapoint traceability, when used in conjunction with USUBJID, include the dataset or domain name, the name of the source variable, and the relevant sequence number (SDTM domain -‑SEQ value or the ADaM ASEQ value). The ADaM ASEQ variable (see Table 3.3.1.1) facilitates datapoint traceability by providing sequence numbers that are unique within a subject within an ADaM dataset, ensuring uniqueness of a record when used in combination with USUBJID.

Table 3.3.9.1 defines additional variables useful in certain situations to facilitate datapoint traceability. These variables are useful in situations where a single ADaM dataset or multiple SDTM datasets and/or ADaM datasets were used to create an ADaM dataset. Section 4.4, Inclusion of Input Data That Are Not Analyzed But That Support a Derivation in the ADaM Dataset, contains an example of how to use these variables.

Variables used for datapoint traceability may also include any other variables that facilitate transparency and clarity of derivations and analysis.

Table 3.3.9.1 Datapoint Traceability Variables

### BDS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SAFPFL | Safety Analysis Parameter- Level Flag | Char | Y | Perm | These indicators identify whether or not the subject was in the specified analysis for the specific parameter. Useful when the subject is included in the subject-level population, but there are parameters for which the subject does not satisfy requirements for the population. The valid values of these parameter-level population indicators are Y or null. If a flag is used, the corresponding numeric version (*FN, where 1=Yes) of the flag can also be included. As described in Item 8 in Section 3.1.1 General Variable Conventions, the *FN version of the variable can be included only if the corresponding *FL is also included. Additional indicators may also be used; refer to Section 3.1.4, Flag Variable Conventions. |
| FASPFL | Full Analysis Set Parameter- Level Flag | Char | Y | Perm |  |
| PPROTPFL | Per-Protocol Parameter- Level Flag | Char | Y | Perm |  |
| COMPLPFL | Completers Parameter-Level Flag | Char | Y | Perm |  |

### BDS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SRCDOM | Source Data | Char |  | Perm | The SDTM domain name or ADaM dataset name that relates to the analysis value (i.e., AVAL or AVALC in a BDS dataset). If the source data is a supplemental qualifier in SDTM, this variable will contain the value of RDOMAIN in SUPP-- or SUPPQUAL. |
| SRCVAR | Source Variable | Char |  | Perm | The name of the column (in the domain or dataset identified by SRCDOM) that relates to the analysis value (i.e., AVAL or AVALC in a BDS dataset). In the event that SRCDOM is a SUPPQUAL, then SRCVAR will be populated with the value of the related QNAM. |

### BDS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Core | CDISC Notes |
|---|---|---|---|---|---|
| SRCSEQ | Source Sequence Number | Num |  | Perm | The sequence number --SEQ or ASEQ of the row (in the domain or dataset identified by SRCDOM) that relates to the analysis value (i.e., AVAL or AVALC in a BDS dataset). In the event that SRCDOM is a SUPPQUAL, then this variable will contain the sequence number of the relevant related domain record. |
