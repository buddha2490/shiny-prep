---
title: "SDTM-IG"
version: "3.4"
package_title: "CDISC SDTM Implementation Guide: Human Clinical Trials v3.4"
description: "Study Data Tabulation Model Implementation Guide v3.4 — domain specifications, variable definitions, controlled terminology references, and conventions for SDTM datasets (naming, missing values, dates, coding)."
---

# SDTM-IG

*CDISC Study Data Tabulation Model Implementation Guide for Human Clinical Trials, version 3.4.* Reference extract: domain variable specifications, per-domain assumptions, and cross-cutting conventions. Example data tables from the source PDF are omitted.

# SDTM-IG Conventions


## 4.1.2 Relationship to Analysis Datasets

Specific guidance on preparing analysis datasets can be found in the CDISC Analysis Data Model (ADaM) at https://www.cdisc.org/standards/foundational/adam.

## 4.1.3 Additional Timing Variables

Additional Timing variables can be added as needed to a standard domain model based on the 3 general observation classes, except for the cases specified in Assumption 4.4.8, Date and Time Reported in a Domain Based on Findings. Timing variables can be added to special-purpose domains only where specified in the SDTMIG domain model assumptions. Timing variables cannot be added to SUPPQUAL datasets or to RELREC (described in Section 8, Representing Relationships and Data).

## 4.1.3.1 EPOCH Variable Guidance

When EPOCH is included in a Findings class domain, it should be based on the --DTC variable, since this is the date/time of the test or, for tests performed on specimens, the date/time of specimen collection. For observations in Interventions or Events class domains, EPOCH should be based on the --STDTC variable, since this is the start of the intervention or event. A possible, though unlikely, exception would be a finding based on an interval specimen collection that started in one epoch but ended in another. --ENDTC might be a more appropriate basis for EPOCH in such a case.

Sponsors should not impute EPOCH values, but should, where possible, assign EPOCH values on the basis of CRF instructions and structure, even if EPOCH was not directly collected and date/time data was not collected with sufficient precision to permit assignment of an observation to an EPOCH on the basis of date/time data alone. If it is not possible to determine the epoch of an observation, then EPOCH should be null. Methods for assigning EPOCH values can be described in the Define-XML document.

Because EPOCH is a study-design construct, it is not applicable to interventions or events that started before the subject's participation in a study, nor to findings performed before participation in a study. For such records, EPOCH should be null. Note that a subject's participation in a study includes screening, which generally occurs before the reference start date (RFSTDTC) in the Demographics (DM) domain.

## 4.1.4 Order of the Variables

The order of variables in the Define-XML document must reflect the order of variables in the dataset. The order of variables in CDISC domain models has been chosen to facilitate the review of the models and application of the models. Variables for the 3 general observation classes must be ordered with Identifiers variables first, followed by Topic, Qualifier, and Timing variables. Within each role, variables must be ordered as shown in SDTM Sections 3.1.1, The Interventions Observation Class; 3.1.2, The Events Observation Class; 3.1.3, The Findings Observation Class; 3.1.3.1, Findings About Events or Interventions; 3.1.4, Identifiers for All Classes; and 3.1.5, Timing Variables for All Classes.

## 4.1.5 SDTM Core Designations

Three categories are specified in the Core column in the domain models:

• An Expected variable is any variable necessary to make a record useful in the context of a specific domain. Expected variables may contain some null values, but in most cases will not contain null values for every record. When the study does not include the data item for an expected variable, however, a null column must still be included in the dataset, and a comment must be included in the Define-XML document to state that the study does not include the data item.

• A Permissible variable should be used in an SDTM dataset wherever appropriate. Although domain specification tables list only some of the identifier, timing, and general observation class variables listed in SDTM Variables Not Allowed in the SDTMIG) or by specific domain assumptions.

o Domain assumptions that say a Permissible variable is "generally not used" do not prohibit use of the variable.

o If a study includes a data item that would be represented in a Permissible variable, then that variable must be included in the SDTM dataset, even if null. Indicate no data were available for that variable in the Define-XML document.

o If a study did not include a data item that would be represented in a Permissible variable, then that variable should not be included in the SDTM dataset and should not be declared in the Define-XML document.

## 4.1.6 Additional Guidance on Dataset Naming

SDTM datasets are normally named to be consistent with the domain code; for example, the Demographics dataset (DM) is named dm.xpt. (See the SDTM Domain Abbreviation codelist, C66734, in CDISC Controlled Terminology (https://www.cancer.gov/research/resources/terminology/cdisc) for standard domain codes). Exceptions to this rule are described in Section 4.1.7, Splitting Domains, for general observation class datasets and in Section 8, Representing Relationships and Data, for RELREC and SUPP-- datasets.

In some cases, sponsors may need to define new custom domains and may be concerned that CDISC domain codes defined in the future will conflict with those they choose to use. To eliminate any risk of a sponsor using a name that CDISC later determines to have a different meaning, domain codes beginning with the letters X, Y, and Z have been reserved for the creation of custom domains. Any letter or number may be used in the second position. Note the use of codes beginning with X, Y, or Z is optional, and not required for custom domains.

## 4.1.7 Splitting Domains

Sponsors may choose to split a domain of topically related information into physically separate datasets.

• A domain based on a general observation class may be split according to values in --CAT. When a domain is split on --CAT, --CAT must not be null.

• The Findings About (FA) domain (see Section 6.4.4, Findings About Events or Interventions) may alternatively be split based on the domain of the value in --OBJ. For example, FACM would store findings about Concomitant/Prior Medications (CM) records. See Section 6.4.2, Naming Findings About Domains, for more details.

The following rules must be adhered to when splitting a domain into separate datasets to ensure they can be appended back into 1 domain dataset:

1. The value of DOMAIN must be consistent across the separate datasets as it would have been if they had not

been split (e.g., QS, FA).

2. All variables that require a domain prefix (e.g., --TESTCD, --LOC) must use the value of DOMAIN as the

prefix value (e.g., QS, FA).

3. --SEQ must be unique within USUBJID for all records across all the split datasets. If there are 1000 records

for a USUBJID across the separate datasets, all 1000 records need unique values for --SEQ.

IDVAR would generally be --SEQ. When IDVAR is a value other than --SEQ (e.g., --GRPID, --REFID, -- SPID), care should be used to ensure that the parent records across the split datasets have unique values for the variable specified in IDVAR, so that related children records do not accidentally join back to incorrect parent records.

5. Permissible variables included in one split dataset need not be included in all split datasets.

6. For domains with 2-letter domain codes (i.e., other than SUPPxx and RELREC), split dataset names can be

up to 4 characters in length. For example, if splitting by --CAT, dataset names would be the domain name plus up to 2 additional characters (e.g., QS36 for SF-36). If splitting Findings About by parent domain, then the dataset name would be the domain code, "FA", plus the 2-character domain code for parent domain code (e.g., "FACM"). The 4-character dataset-name limitation allows the use of a Supplemental Qualifier dataset associated with the split dataset.

7. Supplemental Qualifier datasets for split domains would also be split. The nomenclature would include the

additional 1 to 2 characters used to identify the split dataset (e.g., SUPPQS36, SUPPFACM). The value of RDOMAIN in the SUPP-- datasets would be the 2-character domain code (e.g., QS, FA).

8. In RELREC, if a dataset-level relationship is defined for a split Findings About domain, then RDOMAIN

may contain the 4-character dataset name, rather than the domain name "FA", as shown in the following example.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC CM CMSPID ONE 1 2 ABC FACM FASPID MANY 1

(https://www.cdisc.org/standards/foundational/sdtmig/) for the naming of split AP datasets.

10. See the SDTM Define-XML specification (https://www.cdisc.org/standards/data-exchange/define-xml) for

details regarding metadata representation when a domain is split into different datasets. For additional examples, see the Metadata Submission Guideline (MSG) for SDTMIG (https://www.cdisc.org/standards/foundational/sdtmig/).

Note that submission of split SDTM domains may be subject to additional dataset-splitting conventions as defined by regulators via technical specifications and/or as negotiated with regulatory reviewers.

## 4.1.7.1 Example of Splitting Questionnaires

QRS datasets are routinely created and reviewed for the individual QRS instrument. This example shows the QS domain data split into 3 datasets: Clinical Global Impression (QSCG), Pain Intensity (QSPI), and Satisfaction of Life Scale (QSSW). Each dataset represents a subset of the QS domain data and has only 1 value of QSCAT.

Dataset for Clinical Global Impressions qscg.xpt

Row STUDYID DOMAIN USUBJID QSSEQ QSTESTCD QSTEST QSCAT QSORRES QSSTRESC QSSTRESN QSLOBXFL VISITNUM VISIT VISITDY QSDTC QSDY 1 CDISC01 QS CDISC01.100008 1 CGI0201 CGI02-Severity CGI Moderate 4 4 Y 1 WEEK 1 1 1 2 CDISC01 QS CDISC01.100008 2 CGI0201 CGI02-Severity CGI Mild 3 3 2 WEEK 2 7 7 3 CDISC01 QS CDISC01.100008 3 CGI0202 CGI02-Change CGI Minimally Improved 3 3 2 WEEK 2 7 7 4 CDISC01 QS CDISC01.100008 4 CGI0203 CGI02-Improvement CGI A little better 3 3 2 WEEK 2 7 7 5 CDISC01 QS CDISC01.100014 1 CGI0201 CGI02-Severity CGI Moderate 4 4 Y 1 WEEK 1 1 1 6 CDISC01 QS CDISC01.100014 2 CGI0201 CGI02-Severity CGI Mild 3 3 2 WEEK 2 7 7 7 CDISC01 QS CDISC01.100014 3 CGI0202 CGI02-Change CGI Minimally Improved 3 3 2 WEEK 2 7 7 8 CDISC01 QS CDISC01.100014 4 CGI0203 CGI02-Improvement CGI A little better 3 3 2 WEEK 2 7 7

Dataset for Pain Intensity qspi.xpt

Row STUDYID DOMAIN USUBJID QSSEQ QSTESTCD QSTEST QSCAT QSSCAT QSORRES QSORRESU QSSTRESC QSSTRESN QSSTRESU QSLOC QSMETHOD QSLOBXFL VISITNUM QSDTC QSDY QSEVLINT 1 CDISC01 QS CDISC01.100008 1 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA WORST PAIN

IMAGINABLE

100 100 BACK VISUAL ANALOG SCALE (100 MM)

Y 1 2003-0415

1 -PT24H

2 CDISC01 QS CDISC01.100008 2 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA 50 mm 50 50 mm BACK VISUAL ANALOG SCALE (100 MM)

2 2003-0421

7 -PT24H

3 CDISC01 QS CDISC01.100008 3 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA 60 mm 60 60 mm BACK VISUAL ANALOG SCALE (100 MM)

3 2003-0428

14 -PT24H

4 CDISC01 QS CDISC01.100014 4 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA WORST PAIN

IMAGINABLE

100 100 BACK VISUAL ANALOG SCALE (100 MM)

Y 1 2003-0415

1 -PT24H

5 CDISC01 QS CDISC01.100014 5 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA 50 mm 50 50 mm BACK VISUAL ANALOG SCALE (100 MM)

2 2003-0421

7 -PT24H

6 CDISC01 QS CDISC01.100014 6 PI0101 PI01-Pain Intensity

PI FIBROMYALGIA 60 mm 60 60 mm BACK VISUAL ANALOG SCALE (100 MM)

3 2003-0428

14 -PT24H

Dataset for Satisfaction of Life Scale qssw.xpt

Row STUDYID DOMAIN USUBJID QSSEQ QSTESTCD QSTEST QSCAT QSORRES QSSTRESC QSSTRESN QSLOBXFL VISITNUM QSDTC QSDY 1 CDISC01 QS CDISC01.100008 1 SWLS0101 SWLS01-My Life is Close to Ideal SWLS Slightly agree 5 5 Y 1 1 2 CDISC01 QS CDISC01.100008 2 SWLS0102 SWLS01-My Life Conditions are Excellent SWLS Neither agree nor disagree 4 4 Y 1 1 3 CDISC01 QS CDISC01.100008 3 SWLS0103 SWLS01-I Am Satisfied with My Life SWLS Agree 6 6 Y 1 1 4 CDISC01 QS CDISC01.100008 4 SWLS0104 SWLS01-Have Gotten Important Things SWLS Disagree 2 2 Y 1 1 5 CDISC01 QS CDISC01.100008 5 SWLS0105 SWLS01-Live Life Over Change Nothing SWLS Strongly disagree 1 1 Y 1 1 6 CDISC01 QS CDISC01.100014 6 SWLS0101 SWLS01-My Life is Close to Ideal SWLS Slightly agree 5 5 Y 1 1 7 CDISC01 QS CDISC01.100014 7 SWLS0102 SWLS01-My Life Conditions are Excellent SWLS Neither agree nor disagree 4 4 Y 1 1 8 CDISC01 QS CDISC01.100014 8 SWLS0103 SWLS01-I Am Satisfied with My Life SWLS Agree 6 6 Y 1 1 9 CDISC01 QS CDISC01.100014 9 SWLS0104 SWLS01-Have Gotten Important Things SWLS Disagree 2 2 Y 1 1 10 CDISC01 QS CDISC01.100014 10 SWLS0105 SWLS01-Live Life Over Change Nothing SWLS Strongly disagree 1 1 Y 1 1

SUPPQS Domains

Supplemental Qualifiers for QSCG suppqscg.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 CDISC01 QS CDISC01.100008 QSCAT CGI QSLANG Questionnaire Language GERMAN CRF 2 CDISC01 QS CDISC01.100014 QSCAT CGI QSLANG Questionnaire Language FRENCH CRF

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 CDISC01 QS CDISC01.100008 QSTESTCD PI0101 QSANTXLO Anchor Text Low NO PAIN CRF 2 CDISC01 QS CDISC01.100008 QSTESTCD PI0101 QSANTXHI Anchor Text High

WORST PAIN IMAGINABLE

CRF

3 CDISC01 QS CDISC01.100008 QSTESTCD PI0101 QSANVLLO Anchor Value

Low

0 CRF

4 CDISC01 QS CDISC01.100008 QSTESTCD PI0101 QSANVLHI Anchor Value High

100 CRF

5 CDISC01 QS CDISC01.100008 QSCAT PI QSLANG Questionnaire Language

GERMAN CRF

6 CDISC01 QS CDISC01.100014 QSTESTCD PI0101 QSANTXLO Anchor Text Low NO PAIN CRF 7 CDISC01 QS CDISC01.100014 QSTESTCD PI0101 QSANTXHI Anchor Text High

WORST PAIN IMAGINABLE

CRF

8 CDISC01 QS CDISC01.100014 QSTESTCD PI0101 QSANVLLO Anchor Value

Low

0 CRF

9 CDISC01 QS CDISC01.100014 QSTESTCD PI0101 QSANVLHI Anchor Value High

100 CRF

10 CDISC01 QS CDISC01.100014 QSCAT PI QSLANG Questionnaire Language

FRENCH CRF

Supplemental Qualifiers for QSSW suppqssw.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 CDISC01 QS CDISC01.100008 QSCAT SWLS QSLANG Questionnaire Language GERMAN CRF 2 CDISC01 QS CDISC01.100014 QSCAT SWLS QSLANG Questionnaire Language FRENCH CRF

## 4.1.8.1 Origin Metadata for Variables

The origin element in the Define-XML document file is used to indicate where the data originated. Its purpose is to unambiguously communicate to the reviewer the origin of the data source. For example, data could be collected (on the CRF, from a vendor, or from a device), derived, or assigned; CRF data should be traceable to an annotated CRF and derived data should be traceable to some derivation algorithm. The Define-XML specification is the definitive source of allowable origin values. Additional guidance and supporting examples can be referenced using the Metadata Submission Guidelines (MSG) for SDTMIG.

## 4.1.8.2 Origin Metadata for Records

Sponsors are cautioned to recognize that a derived origin means that all values for that variable were derived, and that collected on the CRF applies to all values as well. In some cases, both collected and derived values may be reported in the same field. For example, some records in a Findings dataset such as Questionnaires (QS) contain values collected from the CRF; other records may contain derived values, such as a total score. When both derived and collected values are reported in a variable, the origin is to be described using value-level metadata in the DefineXML document.

## 4.1.9 Assigning Natural Keys in the Metadata

Section 3.2, Using the CDISC Domain Models in Regulatory Submissions – Dataset Metadata, indicates that a sponsor should include in the metadata the variables that contribute to the natural key for a domain. In a case where a dataset includes a mix of records with different natural keys, the natural key that provides the most granularity is the one that should be provided. The following example illustrates how to do this, and include a case where a Supplemental Qualifier variable is referenced because it forms part of the natural key.

Musculoskeletal System Findings (MK) Domain Example

Sponsor A chooses the following natural key for the MK domain:

STUDYID, USUBJID, VISTNUM, MKTESTCD

Sponsor B collects data in such a way that the location (MKLOC and MKLAT) and method (MKMETHOD) variables need to be included in the natural key to identify a unique row. Sponsor B then defines the following natural key for the MK domain.

In certain instances a Supplemental Qualifier variable (i.e., a QNAM value; see Section 8.4, Relating Non-standard Variable Values to a Parent Domain) might also contribute to the natural key of a record, and therefore needs to be referenced as part of the natural key for a domain. The important concept here is that a domain is not limited by physical structure. A domain may comprise more than 1 physical dataset (e.g., the main domain dataset and its associated Supplemental Qualifiers dataset). Supplemental Qualifier variables should be referenced in the natural key by using a 2-part name. The word QNAM must be used as the first part of the name to indicate that the contributing variable exists in a domain-specific SUPP--; the second part is the value of QNAM that ultimately becomes a column reference when the SUPPQUAL records are joined on to the main domain dataset (e.g., QNAM.XVAR when the SUPP-- record has a QNAM of "XVAR") .

In this example, sponsor B might have collected data that used different imaging methods, using imaging devices with different makes and models, and using different hand positions. The sponsor considers the make and model information and hand position to be essential data that contributes to the uniqueness of the test result, and so includes a device identifier (SPDEVID) in the data and creates a Supplemental Qualifier variable for hand position (QNAM = "MKHNDPOS"). The natural key is then defined as follows:

STUDYID, USUBJID, SPDEVID, VISITNUM, MKTESTCD, MKLOC, MKLAT, MKMETHOD,

QNAM.MKHNDPOS

where the notation "QNAM.MKHNDPOS" means the Supplemental Qualifier whose QNAM is "MKHNDPOS".This approach becomes very useful in a Findings domain when --TESTCD values are "generic" and rely on other variables to completely describe the test. The use of generic test codes helps to create distinct lists of manageable controlled terminology for --TESTCD. In studies where multiple repetitive tests or measurements are being made, for example in a rheumatoid arthritis study where repetitive measurements of bone erosion in the hands and wrists might be made using both X-ray and MRI equipment, the generic MKTEST "Sharp/Genant Bone Erosion Score" would be used in combination with other variables to fully identify the result.

Taking just the phalanges, a sponsor might want to express the following in a test in order to make it unique:

• Left or right hand

• Phalangeal joint position (which finger, which joint)

• Rotation of the hand

• Method of measurement (x-ray or MRI)

• Machine make and model

When CDISC Controlled Terminology for a test is not available, and a sponsor creates --TEST and --TESTCD values, trying to encapsulate all information about a test within a unique value of a --TESTCD is not a recommended approach for the following reasons:

• It results in the creation of a potentially large number of test codes.

• The 8-character values of --TESTCD become less intuitively meaningful.

• Multiple test codes are essentially representing the same test or measurement simply to accommodate attributes of a test within the --TESTCD value itself (e.g., to represent a body location at which a measurement was taken).

As a result, the preferred approach would be to use a generic (or simple) test code that requires associated qualifier variables to fully express the test detail. This approach was used in creating the CDISC Controlled Terminology used in this example:

The MKTESTCD value "SGBESCR" is a generic test code, and additional information about the test is provided by separate qualifier variables. The variables that completely specify a test may include domain variables and supplemental qualifier variables. Expressing the natural key becomes very important in this situation in order to communicate the variables that contribute to the uniqueness of a test.

The following variables would be used to fully describe the test. The natural key for this domain includes both parent dataset variables and a supplemental qualifier variable that contribute to the natural key of each row and to describe the uniqueness of the test.

SPDEVID MKTESTCD MKTEST MKLOC MKLAT MKMETHOD QNAM.MKHNDPOS ACME3000 SGBESCR Sharp/Genant Bone Erosion Score

METACARPOPHALANGEAL JOINT 1

LEFT X-RAY PALM UP

## 4.2.1 Variable-naming Conventions

SDTM variables are named according to a set of conventions, using fragment names (see Appendix D, CDISC Variable-naming Fragments). Variables with names ending in "CD" are "short" versions of associated variables that do not include the "CD" suffix (e.g., --TESTCD is the short version of --TEST).

Values of --TESTCD must be limited to 8 characters and cannot start with a number, nor can they contain characters other than letters, numbers, or underscores. This is to avoid possible incompatibility with SAS v5 transport files. This limitation will be in effect until the use of other formats (e.g., Dataset-XML) becomes acceptable to regulatory authorities.

Because QNAM serves the same purpose as --TESTCD within supplemental qualifier datasets, values of QNAM are subject to the same restrictions as values of --TESTCD.

Values of other "CD" variables are not subject to the same restrictions as --TESTCD:

• ETCD (the companion to ELEMENT) and TSPARMCD (the companion to TSPARM) are limited to 8 characters and do not have the character restrictions that apply to --TESTCD. These values should be short for ease of use in programming, but it is not expected that they will need to serve as variable names.

• ARMCD is limited to 20 characters and does not have the character restrictions that apply to --TESTCD. The maximum length of ARMCD is longer than for other "short" variables to accommodate the kind of values that are likely to be needed for crossover trials. For example, if ARMCD values for a 7-period crossover were constructed using 2-character abbreviations for each treatment and separating hyphens, the length of ARMCD values would be 20. This same rule applies to the ACTARMCD variable.

Variable descriptive names (labels), up to 40 characters, should be provided as data variable labels for all variables, including Supplemental Qualifier variables.

Use of variable names (other than domain prefixes), formats, decodes, terminology, and data types for the same type of data (even for custom domains and Supplemental Qualifiers) should be consistent within and across studies within a submission.

## 4.2.2 Two-character Domain Identifier

In order to minimize the risk of difficulty when merging/joining domains for reporting purposes, the 2-character domain identifier is used as a prefix in most variable names.

Variables in domain specification tables (see Section 5, Models for Special-purpose Domains; Section 6, Domain Models Based on the General Observation Classes; Section 7, Trial Design Model Datasets; Section 8, Representing Relationships and Data; and Section 9, Study References) already specify the complete variable names. When adding variables from the SDTM to standard domains or creating custom domains based on the general observation classes, sponsors must replace the "--" prefix in the SDTM tables of General Observation Class, Timing, and Identifier variables with the 2-character domain identifier (DOMAIN) value for that domain/dataset. The 2-character domain code is limited to A-Z for the first character, and A-Z, 0-9 for the second character. No other characters are allowed. This is for compatibility with SAS v5 transport files and with file naming requirements as part of the Electronic Common Technical Document (eCTD).

The following variables are exceptions to the philosophy that all variable names are prefixed with the domain identifier:

• Required Identifiers (STUDYID, DOMAIN, USUBJID)

• Commonly used grouping and merge keys (e.g., VISIT, VISITNUM, VISITDY)

• All Demographics (DM) domain variables other than DMDTC and DMDY

• All variables in RELREC and SUPPQUAL, and some variables in the Comments and Trial Design datasets

Required identifiers are not prefixed because they are usually used as keys when merging/joining observations. The --SEQ and the optional Identifiers --GRPID and --REFID are prefixed because they may be used as keys when relating observations across domains.

## 4.2.3 Use of "Subject" and USUBJID

"Subject" is used to generically refer to both patients and healthy volunteers in order to be consistent with the recommendation in FDA guidance. The term "subject" should be used consistently in all labels and Define-XML document comments. To identify a subject uniquely across all studies for all applications or submissions involving the product, a unique identifier (USUBJID) should be assigned and included in all datasets.

The unique subject identifier (USUBJID) is required in all datasets containing subject-level data. USUBJID values must be unique for each trial participant (subject) across all trials in the submission. This means that no 2 or more subjects, across all trials in the submission, may have the same USUBJID. In addition, the same person who participates in multiple clinical trials (when this is known) must be assigned the same USUBJID value in all trials.

CDISC does not recommend any specific format for the values of USUBJID, only that the values need to be unique for all subjects in the submission, and across multiple submissions for the same compound. Many sponsors concatenate values for the study, site, and subject into USUBJID, but this is not a requirement. It is acceptable to use any format for USUBJID, as long as the values are unique across all subjects.

The following dm.xpt sample rows illustrate a single subject who participates in 2 studies, first in ACME01 and later in ACME14. Note that this is only one example of the possible values for USUBJID.

dm.xpt

Row STUDYID DOMAIN USUBJID SUBJID SITEID INVNAM 1 ACME01 DM ACME01-05-001 001 05 John Doe dm.xpt

Row STUDYID DOMAIN USUBJID SUBJID SITEID INVNAM 1 ACME14 DM ACME01-05-001 017 14 Mary Smith

## 4.2.4 Text Case in Submitted Data

It is recommended that text data be submitted in text that is all upper case (e.g., NEGATIVE). Exceptions may include long text data (e.g., comment text) and values of --TEST in Findings datasets (which may be more readable in title case if used as labels in transposed views). Values from CDISC Controlled Terminology or external code systems (e.g., MedDRA, SNOMED) or response values for QRS instruments specified by the instrument documentation should be in the case specified by those sources, which may be mixed case. The case used in the text data must match the case used in the controlled terminology provided in the Define-XML document.

## 4.2.5 Convention for Missing Values

Missing values for individual data items should be represented by nulls. Conventions for representing observations not done, using the SDTM --STAT and --REASND variables, are addressed in Section 4.5.1.2, Tests Not Done, and the individual domain models.

## 4.2.6 Grouping Variables and Categorization

Grouping variables are Identifiers and Qualifiers variables—such as the --CAT (Category) and --SCAT (Subcategory)—that group records in the SDTM domains/datasets and can be assigned by sponsors to categorize topic-variable values. For example, a lab record with LBTEST = "SODIUM" might have LBCAT = "CHEMISTRY" and LBSCAT = "ELECTROLYTES". Values for --CAT and --SCAT should not be redundant with the domain name or dictionary classification provided by --DECOD and --BODSYS.

STUDYID DOMAIN

--CAT --SCAT USUBJID --GRPID --LNKID --LNKGRP

How Grouping Variables Group Data

For the subject

1. All records with the same USUBJID value are a group of records that describe that subject.

Across subjects (records with different USUBJID values)

1. All records with the same STUDYID value are a group of records that describe that study.

2. All records with the same DOMAIN value are a group of records that describe that domain.

3. --CAT (Category) and --SCAT (Sub-category) values further subset groups within the domain. Generally, -

-CAT/--SCAT values have meaning within a particular domain. However, it is possible to use the same values for --CAT/--SCAT in related domains (e.g., MH and AE). When values are used across domains, the meanings should be the same. Examples of where --CAT/--SCAT may have meaning across domains/datasets include:

a. Cases where different domains in the same general observation class contain similar conceptual information. Adverse Events (AE), Medical History (MH), and Clinical Events (CE), for example, are conceptually the same data, the only differences being when the event started relative to the study start and whether the event is considered a regulatory-reportable adverse event in the study. Neurotoxicities collected in oncology trials both as separate Medical History CRFs (MH domain) and Adverse Event CRFs (AE domain) could both identify/collect "Paresthesia of the left arm". In both domains, the -- CAT variable could have the value of "NEUROTOXICITY".

b. Cases where multiple datasets are necessary to capture data about the same topic. Following the

oncology example, the existence and start and stop date of paresthesia of the left arm may be reported as an adverse event (AE domain), whereas the severity of the event is captured at multiple visits and recorded as Findings About (FA dataset). In both cases the --CAT variable could have a value of "NEUROTOXICITY".

c. Cases where multiple domains are necessary to capture data that were collected together and have an implicit relationship, perhaps identified in the Related Records (RELREC) special-purpose dataset.

Stress-test data collection may capture the following:

i. Information about the occurrence, start, stop, and duration of the test (in the Procedures (PR)

domain)

ii. Vital Signs recorded during the stress test (VS domain)

iii. Treatments (e.g., oxygen) administered during the stress test (in an Interventions domain)

In such cases, the data collected during the stress tests recorded in 3 separate domains may all have --CAT/--SCAT values (STRESS TEST) that identify that data were collected during the stress test.

Within subjects (records with the same USUBJID values)

1. --GRPID values further group (subset) records within USUBJID. All records in the same domain with the

same --GRPID value are a group of records within USUBJID. Unlike --CAT and --SCAT, --GRPID values are not intended to have any meaning across subjects and are usually assigned during or after data collection.

--LNKID and --LNKGRP express values that are used to link records in separate domains. As such, these variables are often used in IDVAR in a RELREC relationship when there is a dataset-to-dataset relationship.

1. --LNKID is a grouping identifier used to identify a record in one domain that is related to records in

another domain, often forming a one-to-many relationship.

2. --LNKGRP is a grouping identifier used to identify a group of records in one domain that is related to a

record in another domain, often forming a many-to-one relationship.

Differences Between Grouping Variables

The primary distinctions between --CAT/--SCAT and --GRPID are:

1. --CAT/--SCAT are known (identified) about the data before it is collected.

2. --CAT/--SCAT values group data across subjects.

3. --CAT/--SCAT may have some controlled terminology.

4. --GRPID is usually assigned during or after data collection at the discretion of the sponsor.

5. --GRPID groups data only within a subject.

6. --GRPID values are sponsor-defined, and will not be subject to controlled terminology.

Therefore, data that would be the same across subjects is usually more appropriate in --CAT/--SCAT, and data that would vary across subjects is usually more appropriate in --GRPID. For example, a concomitant medication administered as part of a known combination therapy for all subjects (e.g., "Mayo Clinic Regimen") would more appropriately use --CAT/--SCAT to identify the medication as part of that regimen. Groups of medications recorded on a Serious Adverse Event (SAE) form as treatments for the SAE would more appropriately use --GRPID because groupings are likely to differ across subjects.

In domains based on the Findings general observation class, the --RESCAT variable can be used to categorize results after the fact. --CAT and --SCAT by contrast, are generally defined by the sponsor or used by the investigator at the point of collection, not after assessing the value of Findings results.

## 4.2.7 Submitting Free Text from the CRF

Sponsors often collect free-text data on a CRF to supplement a standard field. This often occurs as part of a list of choices accompanied by "Other, specify." The manner in which these data are submitted will vary based on their role.

## 4.2.7.1 "Specify" Values for Non-result Qualifier Variables

When free-text information is collected to supplement a standard non-result qualifier field, the free-text value should be placed in the SUPP-- dataset described in Section 8.4, Relating Non-standard Variable Values to a Parent Domain. When applicable, controlled terminology should be used for SUPP-- field names (QNAM) and their associated labels (QLABEL; see Section 8.4, Relating Non-standard Variable Values to a Parent Domain, and Appendix C1, Supplemental Qualifiers Name Codes).

For example, when a description of "Other Medically Important Serious Adverse Event" category is collected on a CRF, the free-text description should be stored in the SUPPAE dataset.

• AESMIE = "Y"

• SUPPAE QNAM = "AESOSP", QLABEL = "Other Medically Important SAE", QVAL = "HIGH RISK FOR ADDITIONAL THROMBOSIS"

Reason for Dose Adjustment (EXADJ) Describe

 Adverse Event

 Insufficient Response

 Non-medical Reason

The free-text description should be stored in the SUPPEX dataset.

• EXADJ = "NONMEDICAL REASON"

• SUPPEX QNAM = "EXADJDSC", QLABEL = "Reason For Dose Adjustment Description", QVAL = "PATIENT MISUNDERSTOOD INSTRUCTIONS"

Note that QNAM references the "parent" variable name with the addition of "DSC". Likewise, the label is a modification of the parent variable label.

When the CRF includes a list of values for a qualifier field that includes "Other" and the "Other" is supplemented with a "Specify" free-text field, then the manner in which the free-text "Specify" value is submitted will vary based on the sponsor's coding practice and analysis requirements.

For example, consider a CRF that collects the indication for an analgesic concomitant medication (CMINDC) using a list of prespecified values and an "Other, specify" field :

Indication for analgesic o Post-operative pain o Headache o Menstrual pain o Myalgia o Toothache o Other,

specify: ________________

An investigator has selected "OTHER" and specified "Broken arm". Several options are available for submission of this data:

1. If the sponsor wishes to maintain controlled terminology for the CMINDC field and limit the terminology

to the 5 prespecified choices, then the free text is placed in SUPPCM.

CMINDC OTHER

QNAM QLABEL QVAL CMINDOTH Other Indication BROKEN ARM

2. If the sponsor wishes to maintain controlled terminology for CMINDC but will expand the terminology

based on values seen in the "Other, specify" field, then the value of CMINDC will reflect the sponsor's coding decision and SUPPCM could be used to store the verbatim text.

CMINDC FRACTURE

QNAM QLABEL QVAL CMINDOTH Other Indication BROKEN ARM

Note that the sponsor might choose a different value for CMINDC (e.g., "BONE FRACTURE") depending on the sponsor's coding practice and analysis requirements.

3. If the sponsor does not require that controlled terminology be maintained and wishes for all responses to be

stored in a single variable, then CMINDC will be used and SUPPCM is not required.

CMINDC BROKEN ARM

## 4.2.7.2 "Specify" Values for Result Qualifier Variables

When the CRF includes a list of values for a result field that includes "Other" and the "Other" is supplemented with a "Specify" free-text field, then the manner in which the free-text "Specify" value is submitted will vary based on the sponsor's coding practice and analysis requirements.

For example, consider a CRF where the sponsor requests the subject's eye color:

Eye Color o Brown o Black o Blue o Green o Other, specify: ________________

An investigator has selected "OTHER" and specified "BLUEISH GRAY". As in the preceding discussion for nonresult qualifier values, the sponsor has several options for submission:

1. If the sponsor wishes to maintain controlled terminology in the standard result field and limit the

terminology to the 5 prespecified choices, then the free text is placed in --ORRES and the controlled terminology in --STRESC.

SCTEST SCORRES SCSTRESC Eye Color BLUEISH GRAY OTHER

2. If the sponsor wishes to maintain controlled terminology in the standard result field, but will expand the

terminology based on values seen in the "Other, specify" field, then the free text is placed in --ORRES and the value of --STRESC will reflect the sponsor's coding decision.

SCTEST SCORRES SCSTRESC Eye Color BLUEISH GRAY GRAY

3. If the sponsor does not require that controlled terminology be maintained, the verbatim value will be copied

to --STRESC.

SCTEST SCORRES SCSTRESC Eye Color BLUEISH GRAY BLUEISH GRAY

## 4.2.7.3 "Specify" Values for Topic Variables

Interventions

If a list of specific treatments is provided along with "Other, Specify", --TRT should be populated with the name of the treatment found in the specified text. If the sponsor wishes to distinguish between the prespecified list of treatments and those recorded in "Other, Specify," the --PRESP variable could be used. For example:

Indicate which of the following concomitant medications was used to treat the subject’s headaches:

o Acetaminophen o Aspirin o Ibuprofen o Naproxen o Other,

specify: ________________

If ibuprofen and diclofenac were reported, the CM dataset would include the following:

CMTRT CMPRESP IBUPROFEN Y DICLOFENAC

Events

"Other, Specify" for events may be handled similarly to Interventions. --TERM should be populated with the description of the event found in the specified text and --PRESP could be used to distinguish between prespecified and free-text responses.

"Other, Specify" for tests may be handled similarly to Interventions. --TESTCD and --TEST should be populated with the code and description of the test found in the specified text. If specific tests are not listed on the CRF and the investigator has the option of writing in tests, then the name of the test would have to be coded to ensure that all -- TESTCD and --TEST values are consistent with the test controlled terminology.For example, a lab CRF collected values for hemoglobin, hematocrit, and "Other, specify". The value the investigator wrote for "Other, specify" was "Prothrombin time" with an associated result and units. The sponsor would submit the controlled terminology for this test: LBTESTCD would be "PT" and LBTEST would be "Prothrombin Time", rather than the verbatim term, "Prothrombin time" supplied by the investigator.

## 4.2.7.4 "Specify" Values for --OBJ

As illustrated in the following figure, when findings are collected about an event or intervention, and the name of the event or intervention is collected in an "Other, specify" CRF field, the value in --OBJ variable depends on whether the Findings record has a parent record and whether the "Other, specify" value was coded. See also Section 6.4.3, Variables Unique to Findings About.

Figure. Decision Tree for Populating --OBJ

## 4.2.8.1 Multiple Values for an Intervention or Event Topic Variable

If multiple values are reported for an intervention or event topic variable (e.g., --TRT in an Interventions general observation-class dataset or --TERM in an Events general observation-class dataset), it is expected that the sponsor will split the values into multiple records or otherwise resolve the multiplicity per the sponsor's data management standard operating procedures. For example, if an adverse event term of "Headache and nausea" or a concomitant medication of "Tylenol and Benadryl" is reported, sponsors will often split the original report into separate records and/or query the site for clarification. By the time of submission, datasets should be in conformance with the record structures described in the SDTMIG.

Note: The Disposition (DS) dataset is an exception to the general rule of splitting multiple topic values into separate records. For DS, 1 record for each disposition or protocol milestone is permitted according to the domain structure. For cases of multiple reasons for discontinuation see Section 6.2.4, Disposition, assumption 5 for additional information.

## 4.2.8.2 Multiple Values for a Findings Result Variable

If multiple result values (--ORRES) are reported for a test in a Findings class dataset, multiple records should be submitted for that --TESTCD.

• EGTESTCD = "SPRTARRY", EGTEST = "Supraventricular Tachyarrhythmias", EGORRES = "ATRIAL FIBRILLATION"

• EGTESTCD = "SPRTARRY", EGTEST = "Supraventricular Tachyarrhythmias", EGORRES = "ATRIAL FLUTTER"

When a finding can have multiple results, the key structure for the findings dataset must be adequate to distinguish between the multiple results. See Section 4.1.9, Assigning Natural Keys in the Metadata.

## 4.2.8.3 Multiple Values for a Non-result Qualifier Variable

The SDTM permits 1 value for each qualifier variable per record. If multiple values exist (e.g., due to a "Check all that apply" instruction on a CRF), then the value for the qualifier variable should be "MULTIPLE" and SUPP-- should be used to store the individual responses. It is recommended that the SUPP-- QNAM value reference the corresponding standard domain variable with an appended number or letter. In some cases, the standard variable name will be shortened to meet the 8-character variable name requirement, or it may be clearer to append a meaningful character string as shown in the second Adverse Events (AE) example below, where the first 3 characters of the drug name are appended. Likewise, the QLABEL value should be similar to the standard label. The values stored in QVAL should be consistent with the controlled terminology associated with the standard variable. See Section 8.4, Relating Non-standard Variable Values to a Parent Domain, for additional guidance on maintaining appropriately unique QNAM values.

The following example includes selected variables from the ae.xpt and suppae.xpt datasets for a rash with locations on the face, neck, and chest.

ae.xpt

AETERM AELOC RASH MULTIPLE

suppae.xpt

QNAM QLABEL QVAL AELOC1 Location of the Reaction 1 FACE AELOC2 Location of the Reaction 2 NECK AELOC3 Location of the Reaction 3 CHEST

In some cases, values for QNAM and QLABEL more specific than these may be needed.

For example, a sponsor might conduct a study with 2 study drugs (e.g., open-label study of Abcicin + Xyzamin), and may require the investigator assess causality and describe action taken for each drug for the rash:

ae.xpt

AETERM AEREL AEACN RASH MULTIPLE MULTIPLE

suppae.xpt

QNAM QLABEL QVAL AERELABC Causality of Abcicin POSSIBLY RELATED AERELXYZ Causality of Xyzamin UNLIKELY RELATED AEACNABC Action Taken with Abcicin DOSE REDUCED AEACNXYZ Action Taken with Xyzamin DOSE NOT CHANGED

In each of these examples, the use of SUPPAE should be documented in the Define-XML document and the annotated CRF. The controlled terminology used should be documented as part of value-level metadata.

If the sponsor has clearly documented that one response is of primary interest (e.g., in the CRF, protocol, or analysis plan), the standard domain variable may be populated with the primary response and SUPP-- may be used to store the secondary response(s).

For example, if Abcicin is designated as the primary study drug in the example above:

ae.xpt

AETERM AEREL AEACN RASH POSSIBLY RELATED DOSE REDUCED

QNAM QLABEL QVAL AERELX Causality of Xyzamin UNLIKELY RELATED AEACNX Action Taken with Xyzamin DOSE NOT CHANGED

Note that in the latter case, the label for standard variables AEREL and AEACN will have no indication that they pertain to Abcicin. This association must be clearly documented in the metadata and annotated CRF.

## 4.2.8.4 Multiple Values for a Parameter

If multiple values (--VAL) are reported for a parameter in a Trial Design or Study Reference dataset (e.g., TS, OI), multiple records should be submitted for that --PARMCD.

For example,

• TSPARMCD = "TTYPE", TSPARM = "Trial Type", TSVAL = "EFFICACY"

• TSPARMCD = "TTYPE", TSPARM = "Trial Type", TSVAL = "SAFETY"

When a parameter can have multiple values, the key structure for the dataset must be adequate to distinguish between the multiple records. See Section 4.1.9, Assigning Natural Keys in the Metadata.

## 4.2.9 Variable Lengths

When variable length is referenced in the SDTMIG, this refers to the length in bytes of ASCII character strings.

Very large transport files have become an issue for certain regulatory authorities (e.g., US FDA) to process. One of the main contributors to large file sizes has been sponsors using the maximum length of 200 for character variables. To help rectify this situation:

• The maximum SAS v5 transport file character variable length of 200 characters should not be used unless necessary.

• Sponsors should consider the nature of the data and apply reasonable, appropriate lengths to variables. For example:

o The length of flags will always be 1.

o --TESTCD and IDVAR will never be more than 8, so the length can always be set to 8.

o The length for variables that use controlled terminology can be set to the length of the longest term.

## 4.3 Coding and Controlled Terminology Assumptions

Examples provided in the CDISC Notes column and domain examples are only examples and not intended to imply controlled terminology. For current CDISC Controlled Terminology, visit https://datascience.cancer.gov/resources/cancer-vocabulary/cdisc-terminology.

## 4.3.1 Controlled Terms, Codelist or Format Column

As of SDTMIG v3.3, controlled terminology is represented in the following ways:

• A single asterisk (*) when CDISC Controlled Terminology is not currently available but the SDS Team expects that sponsors may have their own controlled terminology and/or the CDISC Controlled Terminology Team may develop controlled terminology in the future

• The single applicable value for the variable DOMAIN (e.g., "PR")

• The name of a CDISC codelist, represented as a hyperlink in parentheses (e.g., "(NY)")

• A short reference to an external terminology (e.g., "MedDRA", "ISO 3166-1 alpha-3")

In addition, the Controlled Terms, Codelist or Format column has been used to indicate variables that use an ISO 8601 format.

## 4.3.2 Controlled Terminology Text Case

Terms from controlled terminology should be in the case that appears the source codelist or code system (e.g., CDISC codelist or external code system such as MedDRA). See Section 4.2.4, Text Case in Submitted Data.

## 4.3.3 Controlled Terminology Values

The controlled terminology or a reference to the controlled terminology should be included in the Define-XML document file wherever applicable. All values in the permissible value set for the study should be included, whether or not they are represented in the submitted data. Note that a null value should not be included in the permissible value set. A null value is implied for any list of controlled terms unless the variable is "Required" (see Section 4.1.5, SDTM Core Designations).

When a domain or dataset specification includes a codelist for a variable, not every value in that codelist may have been part of planned data collection; only values that were part of planned data collection should be included in the Define-XML document. For example, --PRESP variables are associated with the NY codelist, but only the value "Y" is allowed in --PRESP variables. Future versions of the Define-XML specification are expected to include information on representing subsets of controlled terminology.

## 4.3.4 Use of Controlled Terminology and Arbitrary Number Codes

Controlled terminology or human-readable text should be used instead of arbitrary number codes in order to reduce ambiguity for submission reviewers. For example, CMDECOD would contain human-readable dictionary text rather than a numeric code. Numeric code values may be submitted as Supplemental Qualifiers if necessary.

## 4.3.5 Storing Controlled Terminology for Synonym Qualifier Variables

• For events such as adverse events and medical history, populate --DECOD with the dictionary's preferred term and populate --BODSYS with the preferred body system name. If a dictionary is multi-axial, the value in --BODSYS should represent the system organ class (SOC) used for the sponsor's analysis and summary tables, which may not necessarily be the primary SOC. Populate --SOC with the dictionary-derived primary SOC. In cases where the primary SOC was used for analysis, --BODSYS and --SOC are the same.

• If MedDRA is used to code events, the intermediate levels in the MedDRA hierarchy should also be represented in the dataset. A pair of variables has been defined for each of the levels of the hierarchy other than SOC and Preferred Term (PT): one to represent the text description and the other to represent the code value associated with it. For example, --LLT should be used to represent the Lowest Level Term text description and --LLTCD should be used to represent the Lowest Level Term code value.

• For concomitant medications, populate CMDECOD with the drug's generic name and populate CMCLAS with the drug class used for the sponsor's analysis and summary tables. If coding to multiple classes, follow Section 4.2.8.1, Multiple Values for an Intervention or Event Topic Variable, or omit CMCLAS.

• For concomitant medications, supplemental qualifiers may be used to represent additional coding dictionary information (e.g., a drug's ATC codes from the WHO Drug Dictionary; see Section 8.4, Relating Non-standard Variable Values to a Parent Domain).

The sponsor is expected to provide the dictionary name and version used to map the terms by utilizing the DefineXML external codelist attributes.

## 4.3.6 Storing Topic Variables for General Domain Models

The topic variable for the Interventions and Events general observation-class models is often stored as verbatim text. For an Events domain, the topic variable is --TERM. For an Interventions domain, the topic variable is --TRT. For a Findings domain, the topic variable --TESTCD should use controlled terminology (e.g., "SYSBP" for systolic blood pressure). If CDISC Controlled Terminology exists, it should be used; otherwise, sponsors should define their own controlled list of terms. If the verbatim topic variable in an Interventions or Event domain is modified to facilitate coding, the modified text is stored in --MODIFY. In most cases—other than Physical Examination (PE)—the

Domain Original Verbatim Modified Verbatim Standardized Value AE AETERM AEMODIFY AEDECOD DS DSTERM DSDECOD CM CMTRT CMMODIFY CMDECOD MH MHTERM MHMODIFY MHDECOD PE PEORRES PEMODIFY PESTRESC

## 4.3.7 Use of "Yes" and "No" Values

Variables where the response is "Yes" or "No" ("Y" or "N") should normally be populated for both "Y" and "N" responses. This eliminates confusion regarding whether a blank response indicates "N" or is a missing value. However, some variables are collected or derived in a manner that allows only 1 response, such as when a single checkbox indicates "Yes". In situations such as these, where it is unambiguous to populate only the response of interest, it is permissible to populate only 1 value ("Y" or "N") and leave the alternate value blank. An example of when it would be acceptable to use only a value of "Y" would be for Last Observation Before Exposure Flag (-- LOBXFL) variables, where "N" is not necessary to indicate that a value is not the last observation before exposure.

Note: Permissible values for variables with controlled terms of "Y" or "N" may be extended to include "U" or "NA" if it is the sponsor's practice to explicitly collect or derive values indicating "Unknown" or "Not Applicable" for that variable.

## 4.4 Actual and Relative Time Assumptions

Timing variables (SDTM Section 3.1.5, Timing Variables for All Classes) are an essential component of all SDTM subject-level domain datasets. In general, all domains based on the 3 general observation classes should have at least 1 timing variable. In the Events or Interventions general observation class, this could be the start date of the event or intervention. In the Findings observation class, where data are usually collected at multiple visits, at least 1 timing variable must be used.

The SDTMIG requires dates and times of day to be stored according to the international standard ISO 8601 (http://www.iso.org). ISO 8601 provides a text-based representation of dates and/or times, intervals of time, and durations of time.

## 4.4.1 Formats for Date/Time Variables

An SDTM DTC variable may include data that is represented in ISO 8601 format as a complete date/time, a partial date/time, or an incomplete date/time.

The SDTMIG template uses ISO 8601 for calendar dates and times of day, which are expressed as follows:

• YYYY-MM-DDThh:mm:ss(.n+)?(((+|-)hh:mm)|Z)?

where:

• [YYYY] = four-digit year

• [MM] = two-digit representation of the month (01-12, 01=January, etc.)

• [DD] = two-digit day of the month (01 through 31)

• [T] = (time designator) indicates time information follows

• [hh] = two digits of hour (00 through 23) (am/pm is NOT allowed)

• [mm] = two digits of minute (00 through 59)

• [ss] = two digits of second (00 through 59) The last two components, indicated in the format pattern with a question mark, are optional:

• [(.n+)?] = optional fractions of seconds

• [(((+|-)hh:mm)|Z)?] = optional time zone

Other characters defined for use within the ISO 8601 standard are:

• [-] (hyphen): to separate the time elements "year" from "month" and "month" from "day" and to represent missing date components.

• [:] (colon): to separate the time elements "hour" from "minute" and "minute" from "second"

• [/] (solidus): to separate components in the representation of date/time intervals

• [P] (duration designator): precedes the components that represent the duration

Spaces are not allowed in any ISO 8601 representations.

Key aspects of the ISO 8601 standard are as follows:

• ISO 8601 represents dates as a text string using the notation YYYY-MM-DD.

• ISO 8601 represents times as a text string using the notation hh:mm:ss(.n+)?(((+|-)hh:mm)|Z)?.

• The SDTM and the SDTMIG require use of the ISO 8601 extended format, which requires hyphen delimiters for date components and colon delimiters for time components. The ISO 8601 basic format, which does not require delimiters, should not be used in SDTM datasets.

• When a date is stored with a time in the same variable (as a date/time), the date is written in front of the time and the time is preceded with "T" using the notation YYYY-MM-DDThh:mm:ss (e.g. 2001-1226T00:00:01).

Implementation of the ISO 8601 standard means that date/time variables are character/text data types. The SDTM fragment employed for date/time character variables is DTC.

## 4.4.2 Date/Time Precision

The concept of representing date/time precision is handled through use of the ISO 8601 standard. According to ISO 8601, precision (also referred to by ISO 8601 as "completeness" or "representations with reduced accuracy") can be inferred from the presence or absence of components in the date and/or time values. Missing components are represented by right truncation or a hyphen (for intermediate components that are missing). If the date and time values are completely missing, the SDTM date field should be null. Every component except year is represented as 2 digits. Years are represented as 4 digits; for all other components, 1-digit numbers are always padded with a leading zero.

The following table provides examples of ISO 8601 representations of complete and truncated date/time values using ISO 8601 "appropriate right truncations" of incomplete date/time representations. Note that if no time component is represented, the [T] time designator (in addition to the missing time) must be omitted in ISO 8601 representation.

Date and Time as Originally Recorded Precision ISO 8601 Date/Time 1 December 15, 2003 13:14:17.123 Date/time, including fractional seconds 2003-12-15T13:14:17.123 2 December 15, 2003 13:14:17 Date/time to the nearest second 2003-12-15T13:14:17 3 December 15, 2003 13:14 Unknown seconds 2003-12-15T13:14 4 December 15, 2003 13 Unknown minutes and seconds 2003-12-15T13 5 December 15, 2003 Unknown time 6 December, 2003 Unknown day and time 2003-12 7 2003 Unknown month, day, and time 2003

This date and date/time model also provides for imprecise or estimated dates, such as those commonly seen in Medical History. To represent these intervals while applying the ISO 8601 standard, it is recommended that the sponsor concatenate the date/time values (using the most complete representation of the date/time known) that describe the beginning and the end of the interval of uncertainty and separate them with a solidus, as shown in the following table.

Other uncertainty intervals may be represented by the omission of components of the date when these components are unknown or missing. As previously mentioned, ISO 8601 represents missing intermediate components through the use of a hyphen where the missing component would normally be represented. This may be used in addition to "appropriate right truncations" for incomplete date/time representations. When components are omitted, the expected delimiters must still be kept in place and only a single hyphen is to be used to indicate an omitted component. Examples of this method of omitted component representation are shown in the following table.

Date and Time as Originally Recorded Level of Uncertainty ISO 8601 Date/Time 1 December 15, 2003 13:15:17 Date/time to the nearest second 2003-1215T13:15:17 2 December 15, 2003 ??:15 Unknown hour with known minutes 2003-12-15T-:15 3 December 15, 2003 13:??:17 Unknown minutes with known date, hours, and seconds

2003-12-15T13:-:17

4 The 15th of some month in 2003, time not collected Unknown month and time with known year and day

2003---15

5 December 15, but can't remember the year, time not

collected

Unknown year with known month and day --12-15

6 7:15 of some unknown date Unknown date with known hour and minute -----T07:15

Note that row 6, where a time is reported with no date information, represents a very unusual situation. Because most data are collected as part of a visit, when only a time appears on a CRF, it is expected that the date of the visit would usually be used as the date of collection.

Using a character-based data type to implement the ISO 8601 date/time standard will ensure that the date/time information will be machine- and human-readable without the need for further manipulation, and will be platform- and software-independent.

## 4.4.3.1 Intervals of Time and Use of Duration

As defined by ISO 8601, an interval of time is the part of a time axis, limited by 2 time "instants" such as the times represented in SDTM by the variables --STDTC and --ENDTC. These variables represent the 2 instants that bound an interval of time; the duration is the quantity of time that is equal to the difference between these time points.

ISO 8601 allows an interval to be represented in multiple ways. One representation, shown below, uses 2 dates in the format:

YYYY-MM-DDThh:mm:ss/YYYY-MM-DDThh:mm:ss

Although this example represents the interval (by providing the start date/time and end date/time to bound the interval of time), it does not provide the value of the duration (the quantity of time).

Duration is frequently used during a review; however, the duration timing variable (--DUR) should generally be used in a domain if it was collected in lieu of a start date/time (--STDTC) and end date/time (--ENDTC). If both -- STDTC and --ENDTC are collected, durations can be calculated by the difference in these 2 values, and need not be in the submission dataset.

Both duration and duration units can be provided in the single --DUR variable, in accordance with the ISO 8601 standard. The values provided in --DUR should follow 1 of the following ISO 8601 duration formats:

PnYnMnDTnHnMnS

- or - PnW

where the letter designation is defined as:

• [P] (duration designator): precedes the alphanumeric text string that represents the duration. Note that the use of the character "P" is based on the historical use of the term "period" for duration.

• [n] represents a positive number or zero.

• [W] is used as week designator, preceding a data element that represents the number of calendar weeks within the calendar year (e.g., P6W represents 6 weeks of calendar time).

The letter "P" must precede other values in the ISO 8601 representation of duration. The "n" preceding each letter represents the number of years, months, days, hours, minutes, seconds, or the number of weeks. As with the date/time format, "T" is used to separate the date components from time components.

Note that weeks cannot be mixed with any other date/time components such as days or months in duration expressions.

As is the case with the date/time representation in --DTC, --STDTC, or --ENDTC, only the components of duration that are known or collected need to be represented. As is the case with the date/time representation, if no time component is represented, the [T] time designator (in addition to the missing time) must be omitted in ISO 8601 representation.

ISO 8601 also allows that the "lowest-order components" of duration being represented may be represented in decimal format. This may be useful if data are collected in formats such as "one and one-half years", "two and a half weeks", "half a week" or "quarter of an hour" and the sponsor wishes to represent this "precision" (or lack of precision) in ISO 8601 representation. This is ONLY allowed in the lowest-order (right-most) component in any duration representation.

The following table provides some examples of ISO 8601-compliant representations of durations.

Duration as originally recorded ISO 8601 Duration 2 years P2Y 10 weeks P10W 3 months 14 days P3M14D 3 days P3D 6 months 17 days 3 hours P6M17DT3H 14 days 7 hours 57 minutes P14DT7H57M 42 minutes 18 seconds PT42M18S One-half hour PT0.5H 5 days 12¼ hours P5DT12.25H 4 ½ weeks P4.5W

Note that a leading zero is required with decimal values less than 1.

## 4.4.3.2 Interval with Uncertainty

When an interval of time is an amount of time (duration) following an event whose start date/time is recorded (with some level of precision, e.g., when one knows the start date/time and the duration following the start date/time), the correct ISO 8601 usage to represent this interval is:

YYYY-MM-DDThh:mm:ss/PnYnMnDTnHnMnS

where the start date/time is represented before the solidus or foreword slash [/], the "Pn…" following the solidus represents a "duration," and the entire representation is known as an "interval." Note that this is the recommended representation of elapsed time, given a start date/time and the duration elapsed. When an interval of time is an amount of time (duration) measured prior to an event whose start date/time is recorded (with some level of precision, e.g., where one knows the end date/time and the duration preceding that end date/time), the syntax is:

PnYnMnDTnHnMnS/YYYY-MM-DDThh:mm:ss

where the duration, "Pn…", is represented before the solidus [/], the end date/time is represented following the solidus, and the entire representation is known as an "interval."

## 4.4.4 Use of the Study Day Variables

The permissible study day variables (i.e., --DY, --STDY, --ENDY) describe the relative day of the observation starting with the reference date as day 1. They are determined by comparing the date portion of the respective date/time variables (--DTC, --STDTC, and --ENDTC) to the date portion of the subject reference start date (RFSTDTC from the Demographics domain).

All study day values are integers. Thus, to calculate Study Day:

--DY = (date portion of --DTC) - (date portion of RFSTDTC) + 1 if --DTC is on or after RFSTDTC --DY = (date portion of --DTC) - (date portion of RFSTDTC) if --DTC precedes RFSTDTC

This method should be used across all domains.

## 4.4.5 Clinical Encounters and Visits

All domains based on the 3 general observation classes should have at least 1 timing variable. For domains in the Events or Interventions observation classes, and for domains in the Findings observation class, for which data are collected only once during the study, the most appropriate timing variable may be a date (e.g., --DTC, --STDTC) or some other timing variable. For studies that are designed with a prospectively defined schedule of visit-based activities, domains for data that are to be collected more than once per subject (e.g., labs, ECG, vital signs) are expected to include VISITNUM as a timing variable.

Clinical encounters are described by the CDISC visit variables. For planned visits, values of VISIT, VISITNUM, and VISITDY must be those defined in the Trial Visits (TV) dataset (see Section 7.3.1, Trial Visits). For planned visits:

• Values of VISITNUM are used for sorting and should, wherever possible, match the planned chronological order of visits. Occasionally, a protocol will define a planned visit whose timing is unpredictable (e.g., planned in response to an adverse event, a threshold test value, or a disease event), and completely chronological values of VISITNUM may not be possible in such cases.

• There should be a one-to-one relationship between values of VISIT and VISITNUM.

• For visits that may last more than 1 calendar day, VISITDY should be the planned day of the start of the visit.

Sponsor practices for populating visit variables for unplanned visits may vary.

• VISITNUM should generally be populated, even for unplanned visits, as it is expected in many Findings domains, as described above. The easiest method of populating VISITNUM for unplanned visits is to assign the same value (e.g., 99) to all unplanned visits, although this method provides no differentiation between the unplanned visits and does not provide chronological sorting. Methods that provide a one-toone relationship between visits and values of VISITNUM, that are consistent across domains, and that assign VISITNUM values that sort chronologically require more work and must be applied after all of a subject's unplanned visits are known.

• VISIT may be left null or may be populated with a generic value (e.g., "Unscheduled") for all unplanned visits, or individual values may be assigned to different unplanned visits.

• VISITDY must not be populated for unplanned visits; VISITDY is, by definition, the planned study day of visit. The actual study day of an unplanned visit belongs in a --DY variable.

The following lb.xpt sample rows show how visit identifiers might be used for lab data.

lb.xpt

USUBJID VISIT VISITNUM VISITDY LBDY 001 Week 1 2 7 7 001 Week 2 3 14 13 001 Week 2 Unscheduled 3.1 17

## 4.4.6 Representing Additional Study Days

The SDTM allows for the representation of study days relative to the RFSTDTC reference start date variable in the DM dataset, using variables --DY, as described in Section 4.4.4, Use of the "Study Day" Variables. The calculation of additional study days within subdivisions of time in a clinical trial may be based on 1 or more sponsor-defined reference dates not represented by RFSTDTC. In such cases, the sponsor may define supplemental qualifier variables and the Define-XML document should reflect the reference dates used to calculate such study days. If the sponsor wishes to define "day within element" or "day within epoch", the reference date/time will be an element start date/time in the Subject Elements (SE) dataset (see Section 5.3, Subject Elements).

## 4.4.7 Use of Relative Timing Variables

STRF and --ENRF

The variables --STRF and --ENRF represent the timing of an observation relative to the sponsor-defined study reference period, when information such as "BEFORE", "PRIOR", "ONGOING"', or "CONTINUING" is collected in lieu of a date and this collected information is in relation to the sponsor-defined study reference period. The sponsor-defined study reference period is the continuous period of time defined by the discrete starting point, RFSTDTC, and the discrete ending point, RFENDTC, for each subject in the Demographics (DM) dataset.

--STRF is used to identify the start of an observation relative to the sponsor-defined study reference period.

--ENRF is used to identify the end of an observation relative to the sponsor-defined study reference period.

Allowable values for --STRF are "BEFORE", "DURING", "DURING/AFTER", "AFTER", and "UNKNOWN". Although "COINCIDENT" and "ONGOING" are in the STENRF codelist, they describe timing relative to a point in time rather than an interval of time, so are not appropriate for use with --STRF variables. It would be unusual for an event or intervention to be recorded as starting "AFTER" the study reference period, but could be possible, depending on how the study reference period is defined in a particular study.

Allowable values for --ENRF are "BEFORE", "DURING", "DURING/AFTER", "AFTER" and "UNKNOWN". If -- ENRF is used, then --ENRF = "AFTER" means that the event did not end before or during the study reference period. Although "COINCIDENT" and "ONGOING" are in the STENRF codelist, they describe timing relative to a point in time rather than an interval of time, so are not appropriate for use with --ENRF variables.As an example, a CRF checkbox that identifies concomitant medication use that began prior to the study reference period would translate into CMSTRF = "BEFORE", if selected. Note that in this example, the information collected is with respect to the start of the concomitant medication use only, and therefore the collected data corresponds to variable CMSTRF, not CMENRF. Note also that the information collected is relative to the study reference period, which meets the definition of CMSTRF.Some sponsors may wish to derive --STRF and --ENRF for analysis or reporting purposes even when dates are collected. Sponsors are cautioned that doing so in conjunction with directly collecting or mapping data such as "BEFORE", "PRIOR", and "ONGOING" to --STRF and --ENRF will blur the distinction between collected and derived values within the domain. Sponsors wishing to do such derivations are instead encouraged to use analysis datasets for this derived data.

In general, sponsors are cautioned that representing information using variables --STRF and --ENRF may not be as precise as other methods, particularly because information is often collected relative to a point in time or to a period of time other than the one defined as the study reference period. SDTMIG v3.1.2 attempted to address these limitations by the addition of 4 new relative timing variables, which are described in the following section. Sponsors should use the set of variables that allows for accurate representation of collected data. In many cases, this will mean using these new relative timing variables in place of --STRF and --ENRF.

--STRTPT, --STTPT, --ENRTPT, and --ENTPT

Although the variables --STRF and --ENRF are useful in the case when relative timing assessments are made coincident with the start and end of the study reference period, they may not be suitable for expressing relative timing assessments (e.g., "Prior", "Ongoing") that are collected at other times of the study. As a result, 4 new timing variables were added in SDTMIG v3.1.2 to express a similar concept at any point in time. The variables --STRTPT and --ENRTPT contain values similar to --STRF and --ENRF, but may be anchored with any timing description or date/time value expressed in the respective --STTPT and --ENTPT variables, and are not limited to the study reference period. Unlike the variables --STRF and --ENRF, which for all domains are defined relative to one study

If the reference time point corresponds to the date of collection or assessment:

• Start values: An observation can start BEFORE that time point, can start COINCIDENT with that time point, or it can be UNKNOWN when it started.

• End values: An observation can end BEFORE that time point, can end COINCIDENT with that time point, can be known that it did not end but was ONGOING, or it can be UNKNOWN when it ended or if it was ongoing.

• AFTER is not a valid value in this case because it would represent an event after the date of collection.

If the reference time point is prior to the date of collection or assessment:

• Start values: An observation can start BEFORE the reference point, can start COINCIDENT with the reference point, can start AFTER the reference point, or it can be UNKNOWN when it started.

• End values: An observation can end BEFORE the reference point, can end COINCIDENT with the reference point, can end AFTER the reference point, can be known that it did not end but was ONGOING, or it can be UNKNOWN when it ended or if it was ongoing.

Although "DURING" and "DURING/AFTER" are in the STENRF codelist, they describe timing relative to an interval of time rather than a point in time, so are not allowable for use with --STRTPT and --ENRTPT variables.

Examples of --STRTPT, --STTPT, --ENRTPT, and --ENTPT

Example 1: Medical History

Assumptions:

• CRF contains "Year Started" and checkbox for "Active"

• "Date of Assessment" is collected

Example when "Active" is checked:

• MHDTC = date of assessment value (e.g., "2006-11-02")

• MHSTDTC = year of condition start (e.g., "2002")

• MHENRTPT = "ONGOING"

• MHENTPT = date of assessment value (e.g., "2006-11-02")

Figure. Example of --ENRTPT and --ENTPT for Medical History

Example 2: Prior and Concomitant Medications

Assumptions:

• CRF includes collection of "Start Date" and "Stop Date", and checkboxes for

o "Prior" if start date was before the screening visit and was unknown or uncollected

o "Continuing" if medication had not stopped as of the final study visit, so no end date was collected

Example when both "Prior" and "Continuing" are checked:

• CMSTDTC is null

• CMENDTC is null

• CMSTRTPT = "BEFORE"

• CMSTTPT is screening date (e.g., "2006-10-21")

• CMENRTPT = "ONGOING"

• CMENTPT is final study visit date (e.g., "2006-11-02")

Example 3: Adverse Events

Assumptions:

• CRF contains "Start Date", "Stop Date"

• Collection of "Outcome" includes checkboxes for "Continuing" and "Unknown", to be used, if necessary, at the end of the subject's participation in the trial

• No assessment date or visit information was collected

Example when "Unknown" is checked:

• AESTDTC is start date (e.g., "2006-10-01")

• AEENDTC is null

• AEENRTPT = "UNKNOWN"

• AEENTPT is final subject contact date (e.g., "2006-11-02")

## 4.4.8 Date and Time Reported in a Domain Based on Findings

When the date/time of collection is reported in any domain, the date/time should go into the --DTC field (e.g., EGDTC for Date/Time of ECG). For any domain based on the Findings general observation class (e.g., lab tests based on a specimen), the collection date is likely to be tied to when the source of the finding was captured, not necessarily when the data were recorded. In order to ensure that the critical timing information is always represented in the same variable, the --DTC variable is used to represent the time of specimen collection. For example, in the Laboratory Test Results (LB) domain, the LBDTC variable would be used for all single-point blood collections or spot urine collections. For timed lab collections (e.g., 24-hour urine collections) the LBDTC variable would be used for the start date/time of the collection and LBENDTC for the end date/time of the collection. This approach allows the single-point and interval collections to use the same date/time variables consistently across all datasets for the Findings general observation class. The following table illustrates the proper use of these variables. Note that -- STDTC should not be used in the Findings general observation class and is therefore blank in this table.

Collection Type --DTC --STDTC --ENDTC Single-point Collection X Interval Collection X X

## 4.4.9 Use of Dates as Result Variables

Dates are generally used only as timing variables to describe the timing of an event, intervention, or collection activity, but there may be occasions when it may be preferable to model a date as a result (--ORRES) in a Findings dataset. Note that using a date as a result to a Findings question is unusual and atypical, and should be approached

• Calculated due date

• Date of last day on the job

• Date of high school graduation

One approach to modeling these data would be to place the text of the question in --TEST and the response to the question (a date represented in ISO 8601 format) in --ORRES and --STRESC, as long as these date results do not contain the dates of medically significant events or interventions.

Again, use extreme caution when storing dates as the results of findings. Remember, in most cases, these dates should be timing variables associated with a record in an Intervention or Events dataset.

## 4.4.10 Representing Time Points

Time points can be represented using the time point variables --TPT, --TPTNUM, --ELTM, and the time-point anchors --TPTREF (text description) and --RFTDTC (the date/time). Note that time-point data will usually have an associated --DTC value. The interrelationship of these variables is shown in the following figure.

Figure. Representing Time Points

Values for these variables for vital signs measurements taken at 30, 60, and 90 minutes after dosing would look like the following.

VSTPTNUM VSTPT VSELTM VSTPTREF VSRFTDTC VSDTC 1 30 MIN PT30M DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-01T08:30 2 60 MIN PT1H DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-01T09:01 3 90 MIN PT1H30M DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-01T09:32

Note that VSELTM is the planned elapsed time, not the actual elapsed time. The actual elapsed time could be derived in an analysis dataset, if desired, as VSDTC-VSRFTDTC.

Values for these variables for urine collections taken pre-dose, and from 0-12 hours and 12-24 hours after dosing would look like the following.

LBTPTNUM LBTPT LBELTM LBTPTREF LBRFTDTC LBDTC 1 15 MIN PRE-DOSE -PT15M DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-01T07:45 2 0-12 HOURS PT12H DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-01T20:35 3 12-24 HOURS PT24H DOSE ADMINISTRATION 2006-08-01T08:00 2006-08-02T08:40

Note that the value in LBELTM represents the end of the specimen collection interval.

When time points are represented in SDTMIG domains, both --TPT and --TPTNUM must be used. Time points may or may not have an associated --TPTREF. Sometimes, --TPTNUM may be used as a key for multiple values collected for the same test within a visit; as such, there is no dependence upon an anchor such as --TPTREF, but there will be a dependency upon VISITNUM. In such cases, VISITNUM will be required to confer uniqueness to values of --TPTNUM.

Not all time points will require all 3 variables to provide uniqueness. In fact, in some cases a time point may be uniquely identified without the use of VISIT, or without the use of --TPTREF, or without the use of either. For instance:

• A trial might have time points only within 1 visit, so that the contribution of VISITNUM to uniqueness is trivial. (VISITNUM would be populated, but would not contribute to uniqueness.)

• A trial might have time points that do not relate to any visit, such as time points relative to a dose of drug self-administered by the subject at home. (Visit variables would not be included, but --TPTREF and other time point variables would be populated.)

• A trial may have only 1 reference time point per visit, and all reference time points may be similar, so that only 1 value of --TPTREF (e.g., "DOSE") is needed. (--TPTREF would be populated, but would not contribute to uniqueness.)

• A trial may have time points not related to a reference time point. For instance, --TPTNUM values could be used to distinguish first, second, and third repeats of a measurement scheduled without any relationship to dosing (–TPTREF and --ELTM would not be included.) In this case, where the protocol calls for repeated measurements but does not specify timing of the measurements, the --REPNUM variable could be used instead of time-point variables.

For trials with many time points, the requirement to provide uniqueness using only VISITNUM, --TPTREF, and -- TPTNUM may lead to a scheme where multiple natural keys are combined into the values of one of these variables.

For instance, in a crossover trial with multiple doses on multiple days within each period, either of the following options could be used.

1. VISITNUM might be used to designate period, --TPTREF might be used to designate the day and the dose,

and --TPTNUM might be used to designate the timing relative to the reference time point.

2. VISITNUM might be used to designate period and day within period, --TPTREF might be used to

designate the dose within the day, and --TPTNUM might be used to designate the timing relative to the reference time point.

Option 1

VISIT VISITNUM --TPT --TPTNUM --TPTREF PERIOD 1 3 PRE-DOSE 1 DAY 1, AM DOSE 1H 2 4H 3 PRE-DOSE 1 DAY 1, PM DOSE 1H 2 4H 3 PRE-DOSE 1 DAY 5, AM DOSE 1H 2 4H 3 PRE-DOSE 1 DAY 5, PM DOSE 1H 2 4H 3 PERIOD 2 4 PRE-DOSE 1 DAY 1, AM DOSE 1H 2 4H 3 PRE-DOSE 1 DAY 1, PM DOSE 1H 2 4H 3

VISIT VISITNUM --TPT --TPTNUM --TPTREF PERIOD 1, DAY 1 3 PRE-DOSE 1 AM DOSE 1H 2 4H 3 PRE-DOSE 1 PM DOSE 1H 2 4H 3 PERIOD 1, DAY 5 4 PRE-DOSE 1 AM DOSE 1H 2 4H 3 PRE-DOSE 1 PM DOSE 1H 2 4H 3 PERIOD 2, DAY 1 5 PRE-DOSE 1 AM DOSE 1H 2 4H 3 PRE-DOSE 1 PM DOSE 1H 2 4H 3

Within the context that defines uniqueness for a time point (which may include domain, visit, and reference time point), there must be a one-to-one relationship between values of --TPT and --TPTNUM. In other words, if domain, visit, and reference time point uniquely identify subject data, then if 2 subjects have records with the same values of DOMAIN, VISITNUM, --TPTREF, and --TPTNUM, these records may not have different time point descriptions in --TPT.

Within the context that defines uniqueness for a time point, there is likely to be a one-to-one relationship between most values of --TPT and --ELTM. However, because --ELTM can only be populated with ISO 8601 periods of time (as described in Section 4.4.3, Intervals of Time and Use of Duration for --DUR Variables), --ELTM may not be populated for all time points. For example, --ELTM is likely to be null for time points described by text such as "pre-dose" or "before breakfast." When --ELTM is populated, if 2 subjects have records with the same values of DOMAIN, VISITNUM, --TPTREF, and --TPTNUM, then these records may not have different values in --ELTM.

When the protocol describes a time point with text (e.g., "4-6 hours after dose," "12 hours +/- 2 hours after dose"), the sponsor may choose whether and how to populate --ELTM. For example, a time point described as "4-6 hours after dose" might be associated with an --ELTM value of PT4H. A time point described as "12 hours +/- 2 hours after dose" might be associated with an --ELTM value of PT12H. Conventions for populating --ELTM should be consistent (the examples just given would probably not both be used in the same trial). It would be good practice to indicate the range of intended timings by some convention in the values used to populate --TPT.

Sponsors may, of course, use more stringent requirements for populating --TPTNUM, --TPT, and --ELTM. For instance, a sponsor could decide that all time points with a particular --ELTM value would have the same values of - -TPTNUM, and --TPT, across all visits, reference time points, and domains.

## 4.4.11 Disease Milestones and Disease Milestone Timing Variables

A disease milestone is an event or activity that can be anticipated in the course of a disease, but whose timing is not controlled by the study schedule. A disease milestone may be something that occurred pre-study, but which represents a time at which data would have been collected (e.g., diagnosis of the disease under study). A disease milestone may also be something which is anticipated to occur during a study and which, if it occurs, triggers the collection of related data outside the regular schedule of visits (e.g., adverse event of interest). The types of disease milestones for a study are defined in the study-level Trial Disease Milestones (TM) dataset (see Section 7.3.3, Trial Disease Milestones). The times at which disease milestones occurred for a particular subject are summarized in the special-purpose Subject Disease Milestones (SM) domain (see Section 5.4, Subject Disease Milestones), a domain similar in structure to the Subject Visits (SV) and Subject Elements (SE) domains.

Not all studies will have disease milestones. If a study does not have disease milestones, the TM and SM domains will not be present and the disease milestones timing variables may not be included in other domains.

Instances of disease milestones are given names at a subject level. The name of a disease milestone is composed of a character string that depends on the disease milestone type (MIDSTYPE in TM and SM) and, if the type of disease milestone is one that may occur multiple times, a chronological sequence number for this disease milestone among other instances of the same type for the subject. The character string used in the name of a disease milestone is usually a short form of the disease milestone type. For example, if the type of disease milestone is "EPISODE OF DISEASE UNDER STUDY", the values of MIDS for instances of this type of event could include "EPISODE1", "EPISODE2"; or "EPISODE01", "EPISODE02", and so on. The association between the longer text in MIDSTYPE and the shorter text in MIDS can be seen in SM, which includes both variables.

Disease Milestone Name (MIDS)

If something that has been defined as a disease milestone for a particular study occurrs for a particular subject, it is represented as usual: in the appropriate findings, intervention, or events class record. In addition, this record will include the MIDS timing variable, populated with the name of the disease milestone. The timing of a disease milestone is also represented in the special-purpose SM domain.

The record that represents a disease milestone does not include values for the timing variables RELMIDS and MIDSDTC, which are used to represent the timing of other observations relative to a disease milestone. The usual timing variables in the record for a disease milestone (e.g., --DTC, --STDTC, --ENDTC) provide the needed timing for this observation and for the timing information represented in the SM domain.

Timing Relative to a Disease Milestone (MIDS, RELMIDS, MIDSDTC)

For an observation triggered by the occurrence of a disease milestone, the relationship of the observation to the disease milestone can be represented using the disease milestones timing variables MIDS, RELMIDS, and MIDSDTC to describe the timing of the observation.

• MIDS is populated with the name of a disease milestone for this subject. MIDS is the “anchor” for describing the timing of the observation relative to the disease milestone. In this sense, its function is similar to --TPTREF for time points.

• RELMIDS is usually populated with a textual description of the temporal relationship between the observation and the disease milestone named in MIDS. Controlled Terminology has not yet been developed for RELMIDS, but is likely to include terms such as "IMMEDIATELY BEFORE", "AT START OF", "DURING", "AT END OF", and "SHORTLY AFTER". It is similar to --ELTM, except that --ELTM is represented ISO 8601 duration.

• MIDSDTC is populated with the date/time of the disease milestone. This is the --DTC for a finding, or the - -STDTC for an event or intervention, and is the date recorded in SMSTDTC in the SM domain. Its function is similar to --RFTDTC for time points.

In some cases, data collected in conjunction with a disease milestone do not include the collection of a separate date for the related observation. This is particularly common for pre-study disease milestones, but may occur with onstudy disease milestones as well. In such cases, MIDSDTC provides a related date/time in records that would not otherwise contain any date. In records that do contain date/time(s) of the observation, MIDSDTC allows easy comparison of the date(s) of the observation to the (start) date of the disease milestone. In such cases, it functions much like the reference time point date/time (--RFTDTC) in observations at time points.

When a disease milestone is an event or intervention, some data triggered by the disease milestone may be modeled as findings about the disease milestone (i.e., FAOBJ is the disease milestone). In such cases, RELMIDS should be used to describe the temporal relationship between the disease milestone and the subject of the question being asked in the finding, rather than as describing when the question was asked.

• When the subject of the question is the disease milestone itself, RELMIDS may be populated with a value such as “ENTIRE EVENT” or “ENTIRE TREATMENT”.

• When the subject of the question is a question about the occurrence of some activity or event related to the disease milestone, RELMIDS acts like an evaluation interval, describing the period of time on which the question is focused.

o RELMIDS would be “DURING” for questions about things that may have occurred while an event or intervention disease milestone was in progress.

o For sequelae of a disease milestone, RELMIDS would have a value such as “AT DISCHARGE” or “WEEK AFTER”, or simply “AFTER”.

Use of Disease Milestone Timing Variables with Other Timing Variables

The disease milestone timing variables provide timing relative to an activity or event that has been identified, for the particular study, as a disease milestone. Their use does not preclude the use of variables that collect actual date/times or timing relative to the study schedule.

• The use of actual date/times is unaffected. The disease milestone timing variables may provide timing information in cases where actual date/times are unavailable, particularly for pre-study disease milestones. When the question text for an observation references a disease milestone but a separate date for the observation is not collected, the disease milestone timing variables should be populated but the actual date/s should not be imputed by populating them with the date of the disease milestone. Examples of such questions include disease stage at initial diagnosis of disease under study, or treatment for most recent disease episode.

• Study-day variables should be populated wherever complete actual date/times are populated. This includes negative study days for pre-study observations.

• The timing variables EPOCH and TAETORD (Planned Order of Element within Arm) may be populated for on-study observations associated with disease milestones. However, pre-study disease milestones— those which occur before the start of study participation when informed consent is obtained—by definition do not have an associated EPOCH or TAETORD.

• Visit variables are expected in many Findings domains, but findings triggered by the occurrence of a study milestone might not occur at a scheduled visit.

o Findings associated with pre-study disease milestones are often collected at a screening visit, although the test was not performed at that visit.

o For findings associated with on-study disease milestones but not conducted at a scheduled visit, practices for populating VISITNUM as for an unscheduled visit should be followed.

• The use of time-point variables with disease milestone variables may occur in cases where a disease milestone triggers treatment, and time points relative to treatment are part of the study schedule. For instance, a migraine trial may call for assessments of symptom severity at prescribed times after treatment of the migraine. If the migraine episodes were treated as disease milestones, then the disease milestone timing variables might be populated in the exposure and symptom-severity records. If the study planned to treat multiple migraine episodes, the MIDS variable would provide a convenient way to determine the episode with which data were associated.

o An evaluation interval variable (--EVLINT or --EVINTX) can be used in conjunction with disease milestone variables. For instance, patient-reported outcome (PRO) instruments might be administered at the time of a disease milestone, and the questions in the instrument might include an evaluation interval.

• The timing variables for start and end of an event or intervention relative to the study reference period (-- STRF and --ENRF) or relative to a reference time point (--STRTPT and --STTPT, --ENRTPT and -- ENTPT) can be used in conjunction with disease milestone variables. For example, a concomitant medication could be collected in association with a disease milestone, so that the disease milestone timing variables were populated but relative timing variables used for the start or end of the concomitant medication.

• The timing variables for start and end of a planned assessment interval might be populated for an assessment triggered by a disease milestone, if applicable. For example, the occurrence of a particular event might trigger both a treatment and Holter monitoring for 24 hours after the treatment.

Linking and Disease Milestones

When disease milestones have been defined for a study, the MIDS variable serves to link observations associated with a disease milestone in a way similar to the way that VISITNUM links observations collected at a visit. If disease milestones were not defined for the study, it would be possible to link records associated with a disease milestone using RELREC, but the use of disease milestones has certain advantages:

• RELREC indicates that there is a relationship between records or datasets, but not the nature of the relationship. Records with the same MIDS value are related to the same disease milestone.

• When disease milestones are defined, it is not necessary to create RELREC records to establish relationships between observations associated with a disease milestone.

## 4.5.1.1 Original and Standardized Results

The --ORRES variable contains the result of the measurement or finding as originally received or collected. -- ORRES is an expected variable and should always be populated, except (1) when --STAT = "NOT DONE" (because there is no result for such a record) or (2) for derived records.

Note: Records with --DRVFL = "Y" may combine data collected at more than 1 visit. In such cases, sponsors must define the value for VISITNUM, addressing the correct temporal sequence. If a new record is derived for a dataset by the sponsor or their agent (e.g., a CRO), then that new record should be flagged as derived.For example, in electrocardiogram (ECG) data, if a corrected QT interval value derived in-house by the sponsor were represented in an SDTM record, then EGDRVFL would be "Y". If a corrected QT interval value was received from a vendor or was produced by the ECG machine, the derived flag would be null.

When --ORRES is populated, --STRESC must also be populated, regardless of whether the data values are character or numeric. The variable --STRESC is populated either by the conversion of values in --ORRES to values with standard units, or by the assignment of the value of --ORRES, as in the Physical Examination (PE) domain, where -- STRESC could contain a dictionary-derived term. A further step is necessary when --STRESC contains numeric values. These are converted to numeric type and written to --STRESN. Because --STRESC may contain a mixture of numeric and character values, --STRESN may contain null values, as shown in the following figure.

Figure. Original to Standardized Results

When the original measurement or finding is a selection from a defined codelist, in general, the --ORRES and -- STRESC variables contain results in decoded format (i.e., the textual interpretation of whichever code was selected from the codelist). In some cases where the code values in the codelist are statistically meaningful standardized values or scores, which are defined by sponsors or by valid methodologies such as SF36 questionnaires, the -- ORRES variables will contain the decoded format, whereas the --STRESC variables as well as the --STRESN variables will contain the standardized values or scores.

Occasionally data that are intended to be numeric are collected with characters attached that cause the character-tonumeric conversion to fail. For example, numeric cell counts in the source data may be specified with a greater than (>) or less than (<) sign attached (e.g., >10,000, <1). In these cases, the value with the greater than (>) or less than (<) sign attached should be moved to the --STRESC variable, and --STRESN should be null. The rules for

## 4.5.1.2 Tests Not Done

If the data on the CRF is missing and "Yes/No" or "Done/Not Done" was not explicitly captured, a record should not be created to indicate that the data was not collected, with the exception of QRS. Regulatory agencies may require a record for all items on a CRF in QRS datasets (e.g., FT, QS, and clinical classifications in RS).

If a record is created for a test not done, --REASND is populated only if a reason was explicitly collected except for QRS logically skipped items.

When an entire examination (e.g., laboratory draw, ECG, vital signs, physical examination), a group of tests (e.g., hematology, urinalysis), or an individual test (e.g., glucose, PR interval, blood pressure, hearing) is not done, and this information is explicitly captured with a "Yes/No" or "Done/Not Done" question, this information should be represented in the dataset. The reason for the missing information may or may not have been collected.

A sponsor has the following options:

1. Submit individual records for each test not done.

2. Submit 1 record for a group of tests that were not done.

The following example illustrates the single-record approach for representing a group of tests not done.

If a single record is used to represent a group of tests were not done:

• --TESTCD should be --ALL

• --TEST should be <Domain description>

• --CAT should be <Name of group of tests>

• --ORRES should be null

• --STAT should be "NOT DONE"

• --REASND, if collected, might be "Specimen lost"

For example, if urinalysis tests were not done, then:

• LBTESTCD would be "LBALL"

• LBTEST would be "Laboratory Test Results"

• LBCAT would be "URINALYSIS"

• LBORRES would be null

• LBSTAT would be "NOT DONE"

• LBREASND, if collected, might be "Subject could not void"

## 4.5.1.3 Examples of Original and Standard Units and Test Not Done

The following examples are meant to illustrate the use of Findings results variables, and are not meant as comprehensive domain examples. Certain required and expected variables are omitted (e.g., USUBJID), and the samples may represent data for more than 1 subject.

Example 1

Row 1: A numeric value was converted to the standard unit.

Row 2: A numeric value was copied; the original unit was the standard unit so conversion was not needed.

Rows 3-4: A character result was copied from the LBORRES to LBSTRESC. Since this is not a numeric result, LBSTRESN is null.

Row 5: A character result was converted to a standardized format.

Row 7: A result was derived from multiple results, so LBDRVFL = "Y". Note that the original collected data are not shown in this example.

Row 8: A result for LBTEST = "HCT" is missing for visit 2, as indicated by LBSTAT = “NOT DONE”; neither LBORRES nor LBSTRESC is populated.

Row 9: Tests in the category "HEMATOLOGY" were not done at visit 3, as indicated by LBTESTCD = "LBALL" and LBSTAT = “NOT DONE”.

Row 10: None of the tests in the LB domain were done at visit 4, as indicated by LBTESTCD = "LBALL", a null LBCAT value, and LBSTAT = “NOT DONE”.

Row 11: Shows a result collected as an inequality. The unit collected was the standard unit, so the result required no conversion and was copied to LBSTRESC.

Row 12: Shows a result collected as an inequality. In LBSTRESC, the numeric part of LBORRES has been converted to the standard unit, and the less than (<) sign has been retained. LBSTRESN is not populated.

lb.xpt

Row LBTESTCD LBCAT LBORRES LBORRESU LBSTRESC LBSTRESN LBSTRESU LBSTAT LBLOBXFL VISITNUM LBDTC 1 GLUC CHEMISTRY 6.0 mg/dL 60.0 60.0 mg/L 1 2 ALT CHEMISTRY 12.1 mg/L 12.1 12.1 mg/L 1 3 BACT URINALYSIS MODERATE MODERATE 1 4 RBC URINALYSIS TRACE TRACE 1 5 WBC URINALYSIS ++ 2+ 1 6 KETONES CHEMISTRY BLQ mg/L BLQ mg/L 1 7 MCHC HEMATOLOGY 33.8 33.8 g/dL Y 3 8 HCT HEMATOLOGY NOT DONE 2 9 LBALL HEMATOLOGY NOT DONE 3 10 LBALL NOT DONE 4 11 WBC HEMATOLOGY <4, 000 10^6/L <4,000 10^6/L 6 12 BILI CHEMISTRY <0.1 mg/dL <1.71 umol/L 6

Example 2

Row 1: A numeric result was collected in standard units. Because no conversion was necessary, the result was copied into LBSTRESC and LBSTRESN.

Rows 2-3: Numeric results were converted to standard units.

Row 4: Character values were copied to EGSTRESC. EGSTRESN is null.

Row 5: The overall interpretation of the ECG is represented as a separate test.

Row 6: The result for EGTESTCD = "PRAG" was missing at visit 2, as indicated by EGSTAT = "NOT DONE"; neither EGORRES nor EGSTRESC is populated.

Row 7: At visit 3, there were no ECG results, as indicated by EGTESTCD = "EGALL" and EGSTAT = "NOT DONE".

eg.xpt

Row EGTESTCD EGTEST EGORRES EGORRESU EGSTRESC EGSTRESN EGSTRESU EGSTAT VISITNUM EGDTC 1 QRSAG PR Interval, Aggregate 0.362 sec 0.362 0.362 sec 1 2 QTAG QT Interval, Aggregate 221 msec 0.221 0.221 sec 1 3 QTCBAG QTcB Interval, Aggregate 412 msec 0.412 0.412 sec 1

Row EGTESTCD EGTEST EGORRES EGORRESU EGSTRESC EGSTRESN EGSTRESU EGSTAT VISITNUM EGDTC 4 SPRTARRY Supraventricular Tachyarrhythmias ATRIAL FLUTTER ATRIAL FLUTTER 1 6 INTP Interpretation ABNORMAL ABNORMAL 1 5 PRAG PR Interval, Aggregate NOT DONE 2 7 EGALL ECG Test Results NOT DONE 3

Example 3

Rows 1-2: Numeric values were converted to standard units.

Row 3: A result for VSTESTCD = "HR" is missing, as indicated by VSSTAT = "NOT DONE"; neither VSORRES nor VSSTRESC is populated.

Rows 4-5: Two measurements for VSTESTCD= "SYSBP" were done at visit 1.

Row 6: A third measurement for VSTESTCD = "SYSBP" at visit 1 was a derived record, as indicated by VSDRVFL = "Y".

Row 7: At visit 2, there were no Vital Signs results, as indicated by VSTESTCD = "VSALL" and VSSTAT = "NOT DONE".

vs.xpt

Row VSTESTCD VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU VSSTAT VSDRVFL VISITNUM VSDTC 1 HEIGHT 60 in 152 152 cm 1 2 WEIGHT 110 LB 50 50 kg 1 3 HR NOT DONE 1 4 SYSBP 96 mmHg 96 96 mmHg 1 5 SYSBP 100 mmHg 100 100 mmHg 1 6 SYSBP 98 98 mmHg Y 1 7 VSALL NOT DONE 2

## 4.5.2 Linking Multiple Observations

See Section 8, Representing Relationships and Data, for guidance on expressing relationships among multiple observations.

## 4.5.3.1 Test Name (--TEST) Greater than 40 Characters

Sponsors may have test descriptions (--TEST) longer than 40 characters in their operational database. Because the --TEST variable is meant to serve as a label for a --TESTCD when a Findings dataset is transposed to a more horizontal format, the length of --TEST is limited to 40 characters (except as noted below) to conform to the limitations of the SAS V5 transport file format (https://documentation.sas.com/). Therefore, sponsors have the choice to either insert the first 40 characters or a text string abbreviated to 40 characters in --TEST. Sponsors have the following options for including the full description for these variables in the study metadata:

• If the annotated CRF contains the full text, provide a reference to the aCRF page containing the full test description in the Define-XML document origin definition for --TEST.

• If the annotated CRF does not specify the full text, then the full text should be documented in the Define-XML document and/or other submission materials (e.g., the clinical study data reviewer's guide).

This convention should also be applied to the qualifier value label (QLABEL) in Supplemental Qualifiers (SUPP--) datasets. IETEST values in the Inclusion/Exclusion Criteria Not Met (IE) and Trial Inclusion/Exclusion Criteria (TI) domains are exceptions to the 40-character rule and are limited to 200 characters, because these are not expected to be transformed to column labels. Values of IETEST that exceed 200 characters should be described in study metadata as per the convention above. See Section 6.3.4, Inclusion/Exclusion Criteria Not Met, assumption 3; and Section 7.4.1, Trial Inclusion/Exclusion Criteria, assumption 5.

## 4.5.3.2 Text Strings Greater than 200 Characters in Other Variables

Some sponsors may collect data values longer than 200 characters for some variables. Because of the current requirement for the SAS V5 transport file format, it is not possible to store long text strings using only 1 variable. Therefore, the SDTMIG has defined conventions for storing long text strings using multiple variables.

For general observation-class variables and supplemental qualifiers (i.e., non-standard variables, NSVs), the conventions are as follows:

• The first 200 characters of text should be stored in the parent domain variable and each additional 200 characters of text should be stored in a record in the SUPP-- dataset (see Section 8.4, Relating Nonstandard Variable Values to a Parent Domain).

• When splitting a text string into several records, the text should be split between words to improve readability.

• When the text longer than 200 characters is for a supplemental qualifier, the first QNAM should describe the NSV without any numeric suffix.

• The value for QNAMs for additional text (>200 characters) should contain a sequential variable name, which is formed by appending a 1-digit integer, beginning with 1, to the original domain variable name.

• The value for QLABEL should be the original domain variable label.

o The reason a digit integer or suffix is not appended to the label is because the long text string represents a single value for a variable. The physical representation (i.e., SAS V5 transport file format) does not change the concept described by the label.

o This is different conceptually from when there are multiple values for a non-result qualifier variable and values are individually stored in SUPP--. In that case, both QNAM and QLABEL must be uniquely named (see Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable) because they represent multiple values for a single variable.

o In cases where the standard domain variable name is already 8 characters in length, sponsors should replace the last character with a digit when creating values for QNAM. As an example, for Other Action Taken in Adverse Events (AEACNOTH), values for QNAM for the SUPPAE records would have the values AEACNOT1, AEACNOT2, and so on.

Example 1

In this example, the text entered for MHTERM was longer than 200 characters and required 2 supplemental qualifier variables for the text that extended beyond what could be represented in the standard variable.

mh.xpt

Row STUDYID DOMAIN USUBJID MHSEQ MHTERM 1 12345 MH 99-123 6 1st ~200 chars of text, split between words suppmh.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 12345 MH 99-123 MHSEQ 6 MHTERM1 Reported Term for the

Medical History

2nd ~200 chars of text, split between words

CRF

2 12345 MH 99-123 MHSEQ 6 MHTERM2 Reported Term for the

Medical History

last 100 or more chars of text

CRF

Example 2

In this example, the text entered for AEACNOTH was longer than 200 characters, but required only 1 supplemental qualifier for the text that extended beyond what could be represented in the standard variable.

Row STUDYID DOMAIN USUBJID AESEQ AETERM AEACNOTH 1 12345 AE 99-123 4 HEART FAILURE 1st ~200 characters of text, split between words suppae.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 12345 AE 99-123 AESEQ 4 AEACNOT1 Other Action Taken remaining characters of text CRF

Example 3

pr.xpt

Row STUDYID DOMAIN USUBJID PRSEQ PRTRT 1 12345 PR 99-123 4 KIDNEY TRANSPLANT

In this example, the text of the supplemental qualifier PRREAS was longer than 200 characters, but required only 1 additional supplemental qualifier to represent the remaining text.

supppr.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 12345 PR 99-123 PRSEQ 4 PRREAS Reason 1st ~200 characters of text, split between words CRF 2 12345 PR 99-123 PRSEQ 4 PRREAS1 Reason remaining characters of text CRF

The following domains have specialized conventions for representing values longer than 200 characters:

• CO (see Section 5.1, Comments, assumption 4)

• IE (see Section 6.3.4, Inclusion/Exclusion Criteria Not Met, assumption 3)

• TS (see Section 7.4.2, Trial Summary Information, assumption 4)

• TI (see Section 7.4.1, Trial Inclusion/Exclusion Criteria, assumption 5)

The following table summarizes the conventions and notes the specializations.

Text Strings >200 Char Conventions General Observation Class and Supplemental Qualifier Variables

Text Strings >200 Char Conventions CO.COVAL

Text Strings >200 Char Conventions TS.TSVAL

Text Strings >200 Char Conventions TI.IETEST and IE.IETEST

The first 200 characters of text should be stored in the variable and each additional 200 characters of text should be stored as a record in the SUPP-- dataset

The first 200 characters of text should be stored in COVAL and each additional 200 characters of text should be stored in COVAL1 to COVALn.

The first 200 characters of text should be stored in TSVAL and each additional 200 characters of text should be stored in TSVAL1 to TSVALn.

If the inclusion/exclusion criteria text is >200 characters, put meaningful text in IETEST and describe the full text in the study metadata.

When splitting a text string into several records, the text should be split between words to improve readability.

When splitting a text string into several records, the text should be split between words to improve readability.

When splitting a text string into several records, the text should be split between words to improve readability.

Not applicable.

The value for QLABEL should be the original domain variable label.

The variable labels for COVAL1 to COVALn should be "Comment".

The variable labels for TSVAL1 to TSVALn should be "Parameter Value".

Not applicable.

## 4.5.4 Evaluators in the Interventions and Events Observation Classes

Because observations may originate from more than 1 source (e.g., investigator, independent assessor), observations recorded in the Findings class include the --EVAL qualifier. For the Interventions and Events observation classes, which do not include the --EVAL variable, all data are assumed to be attributed to the principal investigator. The QEVAL variable can be used to describe the evaluator for any data item in a SUPP-- dataset (see Section 8.4.1, Supplemental Qualifiers – SUPP-- Datasets), but is not required when the data are objective. For observations that have primary and secondary evaluations of specific qualifier variables, sponsors should put data from the primary evaluation into the standard domain dataset and data from the secondary evaluation into the Supplemental Qualifier datasets (SUPP--). Within each SUPP-- record, the value for QNAM should be formed by appending a "1" to the corresponding standard domain variable name. In cases where the standard domain variable name is already 8 characters in length, sponsors should replace the last character with a "1" (incremented for each additional attribution).

This example illustrates a case where an adjudication committee evaluated an adverse event. The evaluations of the adverse event by the primary investigator were represented in the standard AE dataset. The evaluations of the adjudication committee were represented in SUPPAE. See Section 8.4, Relating Non-standard Variable Values to a

suppae.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 12345 AE 99-123 AESEQ 3 AESEV1 Severity/ Intensity MILD CRF ADJUDICATION COMMITTEE 2 12345 AE 99-123 AESEQ 3 AEREL1 Causality POSSIBLY RELATED

CRF ADJUDICATION COMMITTEE 3 12345 AE 99-123 AESEQ 3 AERELNS1 Relationship to

Non-study Treatment

Possibly related to aspirin use

CRF ADJUDICATION COMMITTEE

## 4.5.5 Clinical Significance for Findings Observation Class Data

For assessments of clinical significance when the overall interpretation is a record in the domain, use the --CLSIG (Clinically Significant) variable on the record that contains the overall interpretation or a particular result. For example, EGCLSIG = "Y" indicates that an ECG result of "ATRIAL FIBRILLATION" was clinically significant.

Separate from clinical significance are results of "NORMAL" or "ABNORMAL", or lab values that are out of normal range. Examples of the latter include:

• An ECG test with EGTESTCD = "INTP" (which addresses the ECG as a whole) should have a result or of "NORMAL" or "ABNORMAL". A record for EGTESTCD = "INTP" may also have EGCLSIG indicating whether the result is clinically significant.

• A record for a vital signs measurement (e.g., systolic blood pressure) or a lab test (e.g., hematocrit) that contains a measurement may have a normal range and a normal range indicator. It could also have --CLSIG indicating whether the result was clinically significant.

## 4.5.6 Supplemental Reason Variables

The SDTM general observation classes include the --REASND variable to submit the reason a response is not present (a result in a findings class or an --OCCUR value in an events or interventions variable). For Events and Interventions domains where prespecified occurrences have a reason for the "Y" or "N" value of --OCCUR, the reason can be represented with the variable --REASOC. However, sponsors sometimes collect the reason that something was done. For the Interventions general observation class, --INDC is available to represent the medical condition for which the intervention was given, and --ADJ is available to represent the reason for a dose adjustment. For the Findings general observation class, --REASPF is available to represent the reason a test was performed. If the sponsor collects a reason for performing an activity represented in an Events domain where the topic is not a medical condition, or a reason for an intervention other than a medical indication, the reason can be represented in the SUPP-- dataset (as described in Section 8.4.1, Supplemental Qualifiers – SUPP-- Datasets) using the supplemental qualifier with QNAM of "--REAS" listed in Appendix C1, Supplemental Qualifiers Name Codes. If multiple reasons are reported, refer to Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable.

For example, if the sponsor collected the reason for admission to a nursing home was for rehabilitation, a SUPPHO record might be populated as follows.

suppho.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 12345 HO 99-123 HOSEQ 3 HOREAS Reason REHABILITATION CRF

## 4.5.7 Presence or Absence of Prespecified Interventions and Events

Interventions (e.g., concomitant medications) and events (e.g., medical history) can generally be collected in 2 different ways, by recording either verbatim free text or the responses to a prespecified list of treatments or terms. Because the method of solicitation for information on treatments and terms may affect the frequency at which they are reported, whether they were prespecified may be of interest to reviewers. The --PRESP variable is used to indicate whether a specific intervention (--TRT) or event (--TERM) was solicited. The --PRESP variable has controlled terminology of "Y" (for "Yes") or a null value. It is a permissible variable, and should only be used when the topic variable values come from a prespecified list. Questions such as "Did the subject have any concomitant medications?" or "Did the subject have any medical history?" should not have records in an SDTM domain because

The --OCCUR variable is used to indicate whether a prespecified intervention or event occurred or did not occur. It has controlled terminology of "Y" and "N" (for "Yes" and "No"). It is a permissible variable and may be omitted from the dataset if no topic-variable values were prespecified.

If a study collects both prespecified interventions and events as well as free-text events and interventions, the value of --OCCUR should be "Y" or "N" for all prespecified interventions and events, and null for those reported as free text.

The --STAT and --REASND variables can be used to provide information about prespecified interventions and events for which there is no response (e.g., investigator forgot to ask). As in Findings, --STAT has controlled terminology of NOT DONE.

Situation Value of --PRESP Value of --OCCUR Value of --STAT Spontaneously reported event occurred Prespecified event occurred Y Y Prespecified event did not occur Y N Prespecified event has no response Y NOT DONE

Collection design may prespecify specific treatments or terms or prespecify a group of treatments or terms (e.g., "Was a short-acting bronchodilator taken in the 8 hours prior to spirometry?"). When an explicit question asks about the occurrence of a group of interventions or events, the group value should be represented in --TRT or --TERM, respectively.

Refer to the standard domains in the Events and Interventions general observation classes for additional assumptions and examples.

## 4.5.8 Accounting for Long-term Follow-up

Studies often include long-term follow-up assessments to monitor a subject's condition. Use cases include studies in terminally ill populations that periodically assess survival and studies involving chronic disease that include followup to assess relapse. Long-term follow-up is often conducted via telephone calls rather than clinic visits. Regardless of the method of contact, the information should be stored in the appropriate topic-based domain.

Overall study conclusion in the Disposition (DS) domain occurs once all contact with the subject ceases. If a study has a clinical treatment phase followed by a long-term follow-up phase, these 2 segments of the study can be represented as separate epochs within the overall study, each with its own epoch disposition record.

The following example illustrates the recommended SDTM approach to storing these data.

An oncology study encompasses 2 months of clinical treatment and assessments followed by once-monthly telephone contacts. The contacts continue until the subject dies. During the telephone contact, the investigator collects information on the subject's survival status and medication use. The answers to certain questions may trigger other data collection. For example, if the subject's survival status is "dead", then this indicates that the subject has ceased participation in the study, so a study discontinuation record would need to be created. In SDTM, the data related to these follow-up telephone contacts should be stored as follows:

1. Concomitant medications reported during the contact should be stored in the CM domain.

2. The subject's survival status should be stored in the Subject Status (SS) domain.

3. The disposition of the subject at the time of the final follow-up contact should be stored in DS. Note that

overall study conclusion is the point where any contact with the subject ceases, which in this example is also the conclusion of long-term follow-up. The disposition of the subject at the conclusion of the 2-month clinical treatment phase would be stored in DS as the conclusion to that epoch. Long-term follow-up would be represented as a separate epoch. Therefore, in this example the subject could have 3 disposition records in DS, with both the follow-up epoch disposition and the overall study conclusion disposition being collected at the final telephone contact. See Section 6.2.4, Disposition, for detailed assumptions and examples.

4. If the subject's survival status is "dead", the Demographics (DM) variables DTHDTC and DTHFL must be

appropriately populated.

Visits (TV).

6. The contacts would be recorded in Subject Visits (SV) and Subject Elements (SE) consistent with the way

they are represented in TV and TE.

## 4.5.9 Baseline Values

The variable --LOBXFL was introduced in SDTMIG v3.3 to address the need for a consistent definition of a value that can serve as a reference with which to compare post-treatment values. This generic definition approximates the concept of baseline and can be used to calculate post-treatment changes. In domains where --BLFL was expected, its core value was changed from expected to permissible and the variable --LOBXFL, with a core value of expected, was added to contain the consistent definition. In domains where --BLFL was permissible, the variable --LOBXFL was added with a core value of permissible.

The following table shows a set of similar flag variables and their usage across the SDTM and ADaM.

Variable Structure

Where It Is Defined

Requirement in That Structure

Definition Intended Use

-- LOBXFL

SDTM Findings

Expected or Permissible

Last non-missing value prior to RFXSTDTC (operationally derived)

Consistent pre-treatment reference value baseline for use across all studies and sponsors ABLFL ADaM BDS Conditionally Required

Flags the record that is the source of the baseline value for a given parameter specified in the statistical analysis plan (SAP; may differ both across and within studies and datasets)

Baseline for ADaM analysis as specified in the SAP

--BLFL SDTM Findings

Permissible (formerly Expected in some domains)

A baseline defined by the sponsor (could be derived in the same manner as --LOBXFL or ABLFL, but is not required to be)

Any sponsor-defined baseline use

As shown in the table, each variable serves a specific need. The SDTM variable --LOBXFL (and/or --BLFL, if used) can be copied to ADaM for traceability and transparency, but only the ADaM variable ABLFL would be used to signify baseline for analysis. The content of --LOBXFL and ABLFL will be exactly the same when the SAP specifies that the baseline used for analysis is the last non-missing value prior to RFXSTDTC.

# SDTM-IG Domains


## Comments (CO)

*Structure: One record per comment per subject, Tabulation.*

A special-purpose domain that contains comments that may be collected alongside other data.

### CO Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | CO | Identifier | Two-character abbreviation for the domain. | Req |
| RDOMAIN | Related Domain Abbreviation | Char | (DOMAIN) | Record Qualifier | Two-character abbreviation for the domain of the parent record(s). Null for comments collected on a general comments or additional information CRF page. | Perm |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| COSEQ | Sequence Number | Num |  | Identifier | Sequence Number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| IDVAR | Identifying Variable | Char | * | Record Qualifier | Identifying variable in the parent dataset that identifies the record(s) to which the comment applies. Examples AESEQ or CMGRPID. Used only when individual comments are related to domain records. Null for comments collected on separate CRFs. | Perm |

### CO Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| IDVARVAL | Identifying Variable Value | Char |  | Record Qualifier | Value of identifying variable of the parent record(s). Used only when individual comments are related to domain records. Null for comments collected on separate CRFs. | Perm |
| COREF | Comment Reference | Char |  | Record Qualifier | Sponsor-defined reference associated with the comment. May be the CRF page number (e.g., 650), or a module name (e.g., DEMOG), or a combination of information that identifies the reference (e.g. 650- VITALS-VISIT 2). | Perm |
| COVAL | Comment | Char |  | Topic | The text of the comment. Text over 200 characters can be added to additional columns COVAL1- COVALn. See Assumption 3. | Req |
| COEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Example: "INVESTIGATOR". | Perm |

### CO Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| COEVALID | Evaluator Identifier | Char | (MEDEVAL) | Record Qualifier | Used to distinguish multiple evaluators with the same role recorded in --EVAL. Examples: "RADIOLOGIST", "RADIOLOGIST 1", "RADIOLOGIST 2". | Perm |
| CODTC | Date/Time of Comment | Char | ISO 8601 datetime or interval | Timing | Date/time of comment on dedicated comment form. Should be null if this is a child record of another domain or if comment date was not collected. | Perm |
| CODY | Study Day of Comment | Num |  | Timing | Study day of the comment, in integer days. The algorithm for calculations must be relative to the sponsor- defined RFSTDTC variable in the Demographics (DM) domain. | Perm |

### CO Assumptions

1. The Comments special-purpose domain provides a solution for submitting free-text comments related to data in 1 or more SDTM domains (as described

in Section 8.5, Relating Comments to a Parent Domain) or collected on a separate CRF page dedicated to comments. Comments are generally not responses to specific questions; instead, comments usually consist of voluntary free-text or unsolicited observations.

2. Although the structure for the Comments domain in the SDTM is "One record per comment", USUBJID is required in the comments domain for human

clinical trials, so the structure of the Comments domain in the SDTMIG is "One record per comment per subject."

3. The CO dataset accommodates 3 sources of comments:

a. Those unrelated to a specific domain or parent record(s), in which case the values of the variables RDOMAIN, IDVAR, and IDVARVAL are null. CODTC should be populated if captured. See Example 1, row 1.

b. Those related to a domain but not to specific parent record(s), in which case the value of the variable RDOMAIN is set to the DOMAIN code of the

parent domain and the variables IDVAR and IDVARVAL are null. CODTC should be populated if captured. See Example 1, row 2.

c. Those related to a specific parent record or group of parent records, in which case the value of the variable RDOMAIN is set to the DOMAIN code of the parent record(s) and the variables IDVAR and IDVARVAL are populated with the key variable name and value of the parent record(s). Assumptions for populating IDVAR and IDVARVAL are further described in Section 8.5, Relating Comments to a Parent Domain. CODTC should be null because the timing of the parent record(s) is inherited by the comment record. See Example 1, rows 3-5.

4. When the comment text is longer than 200 characters, the first 200 characters of the comment will be in COVAL, the next 200 in COVAL1, and

additional text stored as needed to COVALn. See Example 1, rows 3-4. Additional information about how to relate comments to parent SDTM records is provided in Section 8.5, Relating Comments to a Parent Domain.

5. The variable COREF may be null unless it is used to identify the source of the comment. See Example 1, rows 1 and 5.

6. Identifier variables and Timing variables may be added to the CO domain, but the following qualifiers would generally not be used in CO: --GRPID, --

REFID, --SPID, TAETORD, --TPT, --TPTNUM, --ELTM, --TPTREF, --RFTDTC.

## Demographics (DM)

*Structure: One record per subject, Tabulation.*

A special-purpose domain that includes a set of essential standard variables that describe each subject in a clinical study. It is the parent domain for all other observations for human clinical subjects.

### DM Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | DM | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. This must be a unique value, and could be a compound identifier formed by concatenating STUDYID-SITEID-SUBJID. | Req |
| SUBJID | Subject Identifier for the Study | Char |  | Topic | Subject identifier, which must be unique within the study. Often the ID of the subject as recorded on a CRF. | Req |
| RFSTDTC | Subject Reference Start Date/Time | Char | ISO 8601 datetime or interval | Record Qualifier | Reference start date/time for the subject in ISO 8601 character format. Usually equivalent to date/time when subject was first exposed to study treatment. See assumption 9 for additional detail on when RFSTDTC may be null. | Exp |

### DM Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RFENDTC | Subject Reference End Date/Time | Char | ISO 8601 datetime or interval | Record Qualifier | Reference end date/time for the subject in ISO 8601 character format. Usually equivalent to the date/time when subject was determined to have ended the trial, and often equivalent to date/time of last exposure to study treatment. Required for all randomized subjects; null for screen failures or unassigned subjects. | Exp |
| RFXSTDTC | Date/Time of First Study Treatment | Char | ISO 8601 datetime or interval | Record Qualifier | First date/time of exposure to any protocol-specified treatment or therapy, equal to the earliest value of EXSTDTC. | Exp |
| RFXENDTC | Date/Time of Last Study Treatment | Char | ISO 8601 datetime or interval | Record Qualifier | Last date/time of exposure to any protocol-specified treatment or therapy, equal to the latest value of EXENDTC (or the latest value of EXSTDTC if EXENDTC was not collected or is missing). | Exp |

### DM Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RFCSTDTC | Date/Time of First Challenge Agent Admin | Char | ISO 8601 datetime or interval | Record Qualifier | Used only when protocol specifies a challenge agent to induce a condition that the investigational treatment is intended to cure, mitigate, treat, or prevent. Equal to the earliest value of AGSTDTC for the challenge agent. | Perm |
| RFCENDTC | Date/Time of Last Challenge Agent Admin | Char | ISO 8601 datetime or interval | Record Qualifier | Used only when protocol specifies a challenge agent to induce a condition that the investigational treatment is intended to cure, mitigate, treat, or prevent. Equal to the latest value of AGENDTC for the challenge agent (or the latest value of AGSTDTC if AGENDTC was not collected or is missing). | Perm |

### DM Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RFICDTC | Date/Time of Informed Consent | Char | ISO 8601 datetime or interval | Record Qualifier | Date/time of informed consent in ISO 8601 character format. This will be the same as the date of informed consent in the Disposition domain, if that protocol milestone is documented. Would be null only in studies not collecting the date of informed consent. | Exp |
| RFPENDTC | Date/Time of End of Participation | Char | ISO 8601 datetime or interval | Record Qualifier | Date/time when subject ended participation or follow-up in a trial, as defined in the protocol, in ISO 8601 character format. Should correspond to the last known date of contact. Examples include completion date, withdrawal date, last follow-up, date recorded for lost to follow up, and death date. | Exp |

### DM Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DTHDTC | Date/Time of Death | Char | ISO 8601 datetime or interval | Record Qualifier | Date/time of death for any subject who died, in ISO 8601 format. Should represent the date/time that is captured in the clinical-trial database. | Exp |
| DTHFL | Subject Death Flag | Char | (NY) | Record Qualifier | Indicates the subject died. Should be "Y" or null. Should be populated even when the death date is unknown. | Exp |
| SITEID | Study Site Identifier | Char | * | Record Qualifier | Unique identifier for a site within a study. | Req |
| INVID | Investigator Identifier | Char |  | Record Qualifier | An identifier to describe the Investigator for the study. May be used in addition to SITEID. Not needed if SITEID is equivalent to INVID. | Perm |
| INVNAM | Investigator Name | Char |  | Synonym Qualifier | Name of the investigator for a site. | Perm |
| BRTHDTC | Date/Time of Birth | Char | ISO 8601 datetime or interval | Record Qualifier | Date/time of birth of the subject. | Perm |

### DM Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGE | Age | Num |  | Record Qualifier | Age expressed in AGEU. May be derived from RFSTDTC and BRTHDTC, but BRTHDTC may not be available in all cases (due to subject privacy concerns). | Exp |
| AGEU | Age Units | Char | (AGEU) | Variable Qualifier | Units associated with AGE. | Exp |
| SEX | Sex | Char | (SEX) | Record Qualifier | Sex of the subject. | Req |
| RACE | Race | Char | (RACE) | Record Qualifier | Race of the subject. Sponsors should refer to the FDA guidance2 regarding the collection of race. See assumption below regarding RACE. | Exp |
| ETHNIC | Ethnicity | Char | (ETHNIC) | Record Qualifier | The ethnicity of the subject. Sponsors should refer to the FDA guidance1 regarding the collection of ethnicity. | Perm |

### DM Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ARMCD | Planned Arm Code | Char | * | Record Qualifier | ARMCD is limited to 20 characters. It is not subject to the character restrictions that apply to TESTCD. The maximum length of ARMCD is longer than for other "short" variables to accommodate the kind of values that are likely to be needed for crossover trials. For example, if ARMCD values for a 7-period crossover were constructed using 2-character abbreviations for each treatment and separating hyphens, the length of ARMCD values would be 20. If the subject was not assigned to a trial arm, ARMCD is null and ARMNRS is populated. With the exception of studies which use multistage arm assignments, must be a value of ARMCD in the Trial Arms dataset. | Exp |

### DM Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ARM | Description of Planned Arm | Char | * | Synonym Qualifier | Name of the arm to which the subject was assigned. If the subject was not assigned to an arm, ARM is null and ARMNRS is populated. With the exception of studies which use multistage arm assignments, must be a value of ARM in the Trial Arms dataset. | Exp |

### DM Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ACTARMCD | Actual Arm Code | Char | * | Record Qualifier | Code of actual arm. ACTARMCD is limited to 20 characters. It is not subject to the character restrictions that apply to TESTCD. The maximum length of ACTARMCD is longer than for other short variables to accommodate the kind of values that are likely to be needed for crossover trials. With the exception of studies which use multistage arm assignments, must be a value of ARMCD in the Trial Arms dataset. If the subject was not assigned to an arm or followed a course not described by any planned arm, ACTARMCD is null and ARMNRS is populated. | Exp |

### DM Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ACTARM | Description of Actual Arm | Char | * | Synonym Qualifier | Description of actual arm. With the exception of studies which use multistage arm assignments, must be a value of ARM in the Trial Arms dataset. If the subject was not assigned to an arm or followed a course not described by any planned arm, ACTARM is null and ARMNRS is populated. | Exp |
| ARMNRS | Reason Arm and/or Actual Arm is Null | Char | (ARMNULRS) | Record Qualifier | A coded reason that arm variables (ARM and ARMCD) and/or actual arm variables (ACTARM and ACTARMCD) are null. Examples: "SCREEN FAILURE", "NOT ASSIGNED", "ASSIGNED, NOT TREATED", "UNPLANNED TREATMENT". It is assumed that if the arm and actual arm variables are null, the same reason applies to both arm and actual arm. | Exp |

### DM Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ACTARMUD | Description of Unplanned Actual Arm | Char |  | Record Qualifier | A description of actual treatment for a subject who did not receive treatment described in a planned trial arm. | Exp |
| COUNTRY | Country | Char |  | Record Qualifier | Country of the investigational site in which the subject participated in the trial. Generally represented using ISO 3166-1 Alpha-3. Note that regulatory agency specific requirements (e.g., US FDA) may require other terminologies; in such cases, follow regulatory requirements. | Req |
| DMDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of demographic data collection. | Perm |
| DMDY | Study Day of Collection | Num |  | Timing | Study day of collection measured as integer days. | Perm |

### DM Assumptions

1. Investigator and site identification: Companies use different methods to distinguish sites and investigators.

CDISC assumes that SITEID will always be present, with INVID and INVNAM used as necessary. This should be done consistently and the meaning of the variable made clear in the Define-XML document.

2. Every subject in a study must have a subject identifier (SUBJID). In some cases a subject may participate

in more than 1 study. To identify a subject uniquely across all studies for all applications or submissions involving the product, a unique identifier (USUBJID) must be included in all datasets. Subjects occasionally change sites during the course of a clinical trial. Sponsors must decide how to populate variables such as USUBJID, SUBJID and SITEID based on their operational and analysis needs, but only 1 DM record should be submitted for each subject. The Supplemental Qualifiers dataset may be used if appropriate to provide additional information.

3. Concerns for subject privacy suggest caution regarding the collection of variables like BRTHDTC. This

variable is included in the Demographics model in the event that a sponsor intends to submit it; however, sponsors should follow regulatory guidelines and guidance as appropriate.

4. With the exception of trials that use multistage processes to assign subjects to arms described below, ARM

and ACTARM must be populated with ARM values from the Trial Arms (TA) dataset and ARMCD and ACTARMCD must be populated with ARMCD values from the TA dataset or be null. The ARM and ARMCD values in the TA dataset have a one-to-one relationship, and that one-to-one relationship must be preserved in the values used to populate ARM and ARMCD in DM, and to populate the values of ACTARM and ACTARMCD in DM.

a. Rules for the arm-related variables:

i. If ARMCD is null, then ARM must be null and ARMNRS must be populated with the reason

ARMCD is null.

ii. If ACTARMCD is null, then ACTARM must be null and ARMNRS must be populated with the

reason ACTARMCD is null. Both ARMCD and ACTARMCD will be null for subjects who were not assigned to treatment. The same reason will provide the reason that both are null.

iii. ARMNRS may not be populated if both ARMCD and ACTARMCD are populated. ARMCD and

ACTARMCD will be populated if the subject was assigned to an arm and received treatment consistent with 1 of the arms in the TA dataset. If ARMCD and ACTARMCD are not the same, that is sufficient to explain the situation; ARMNRS should not be populated.

iv. If ARMNRS is populated with "UNPLANNED TREATMENT", ACTARMUD should be

populated with a description of the unplanned treatment received.

b. Multistage assignment to treatment: Some trials use a multistage process for assigning a subject to an

arm (see Section 7.2.1, Trial Arms, Example Trial 3). In such a case, best practice is to create ARMCD values composed of codes representing the results of the multiple stages of the treatment assignment process. If a subject is partially assigned, then truncated codes representing the stages completed can be used in ARMCD, and similar truncated codes can be used in ACTARMCD. The descriptions used to populate ARM and ACTARM should be similarly truncated, and the one-to-one relationship between these truncated codes should be maintained for all affected subjects in the trial. Example 3 below provides an example of this situation; see also Section 5.3, Subject Elements, Example 2. Note that this use of values not in the TA dataset is allowable only for trials with multistage assignment to arms and to subjects in those trials who do not complete all stages of the assignment.

c. Examples illustrating the arm-related variables

i. Example 1 below shows how to handle a subject who was a screen failure and was never treated.

ii. The Subject Elements (SE) dataset records the series of elements a subject passed through in the

course of a trial, and these determine the value of ACTARMCD. The following examples include sample data for both datasets to illustrate this relationship.

1. Example 2 below shows how subjects who started the trial but were never assigned to an arm

would be handled.

treatment that was not the one to which they were assigned.

3. Section 5.3, Subject Elements, Example 2 illustrates a situation in which a subject received a

set of treatments different from that for any of the planned arms.

5. Study population flags should not be included in SDTM data. The standard supplemental qualifiers

included in previous versions of the SDTMIG (COMPLT, FULLSET, ITT, PPROT, SAFETY) should not be used. Note: The ADaM Subject-level Analysis Dataset (ADSL) specifies standard variable names for the most common populations and requires the inclusion of these flags when necessary for analysis; consult the ADaMIG for more information about these variables.

6. Submission of multiple race responses should be represented in the Demographics (DM) domain and

Supplemental Qualifiers (SUPPDM) dataset as described in Section 4.2.8.3, Multiple Values for a Nonresult Qualifier Variable. If multiple races are collected, then the value of RACE should be “MULTIPLE” and the additional information will be included in the Supplemental Qualifiers dataset. Controlled terminology for RACE should be used in both DM and SUPPDM so that consistent values are available for summaries regardless of whether the data are found in a column or row. If multiple races were collected and 1 was designated as primary, RACE in DM should be the primary race and additional races should be reported in SUPPDM. When additional free-text information is reported about subject's race using “Other, Specify”, sponsors should refer to Section 4.2.7.1, "Specify" Values for Non-Result Qualifier Variables. If race was collected via an "Other, Specify" field and the sponsor chooses not to map the value as described in the current FDA guidance (see CDISC Notes for RACE in the domain specification), then the value of RACE should be “OTHER”. For subjects who refuse to provide or do not know their race information, the value of RACE could be “UNKNOWN”. See DM Example 4, DM Example 5, DM Example 6, and DM Example 7.

a. The Racec-Ethnicc Codetable (available at https://www.cdisc.org/standards/terminology/controlledterminology) represents associations between collected race values and published race Controlled Terminology, as well as collected ethnicity values and published ethnicity Controlled Terminology.

7. RFSTDTC, RFENDTC, RFXSTDTC, RFXENDTC, RFCSTDTC, RFCENDTC, RFICDTC, RFPENDTC,

DTHDTC, and BRTHDTC represent date/time values, but they are considered to have a record qualifier role in DM. They are not considered to be timing variables because they are not intended for use in the general observation classes.

8. Additional permissible identifier, qualifier, and timing variables:

a. Only the following timing variables are permissible and may be added as appropriate: VISITNUM, VISIT, VISITDY. The record qualifier DMXFN (External File Name) is the only additional qualifier variable that may be added, which is adopted from the Findings general observation class, may also be used to refer to an external file, such as a patient narrative.

b. The order of these additional variables within the domain should follow the rules as described in

Section 4.1.4, Order of the Variables, and the order described in Section 4.2, General Variable Assumptions.

9. As described in Section 4.1.4, Order of the Variables, RFSTDTC is used to calculate study day variables.

RFSTDTC is usually defined as the date/time when a subject was first exposed to study drug. This definition applies for most interventional studies, when the start of treatment is the natural and preferred starting point for study day variables and thus the logical value for RFSTDTC. In such studies, when data are submitted for subjects who are ineligible for treatment (e.g., screen failures with ARMNRS = "SCREEN FAILURE"), subjects who were enrolled but not assigned to an arm (e.g., ARMNRS = "NOT ASSIGNED"), or subjects who were randomized but not treated (e.g., ARMNRS = "NOT TREATED"), RFSTDTC will be null. For studies with designs that include a substantial portion of subjects who are not expected to be treated, a different protocol milestone may be chosen as the starting point for study day variables. Some examples include non-interventional or observational studies, studies with a no-treatment arm, and studies where there is a delay between randomization and treatment.

10. The DM domain contains several pairs of reference period variables: RFSTDTC and RFENDTC,

RFXSTDTC and RFXENDTC, RFCSTDTC and RFCENDTC, and RFICDTC and RFPENDTC. There are 4 sets of reference variables to accommodate distinct reference-period definitions and there are instances

a. RFSTDTC and RFENDTC: This pair of variables is sponsor-defined, but usually represents the date/time of first and last study exposure. However, there are certain study designs where the start of the reference period is defined differently, such as studies that have a washout period before randomization or have a medical procedure required during screening (e.g., biopsy). In these cases, RFSTDTC may be the enrollment date, which is prior to first dose. Because study day values are calculated using RFSTDTC, in this case study days would not be based on the date of first dose.

b. RFXSTDTC and RFXENDTC: This pair of variables defines a consistent reference period for all

interventional studies and is not open to customization. RFXSTDTC and RFXENDTC always represent the date/time of first and last study exposure. The study reference period often duplicates the reference period defined in RFSTDTC and RFENDTC, but not always. Therefore, this pair of variables is important as they guarantee that a reviewer will always be able to reference the first and last study exposure reference period. RFXSTDTC should be the same as SESTDTC for the first treatment element described in the SE dataset. RFXENDTC may often be the same as the SEENDTC for the last treatment element described in the SE dataset.

c. RFCSTDTC and RFCENDTC: This pair of variables is used only when the study uses a protocolspecified challenge agent to induce a condition that the investigational treatment is intended to cure, mitigate, treat, or prevent. RFCSTDTC and RFCENDTC always represent the date/time of first and last exposure to the challenge agent.

d. RFICDTC and RFPENDTC: The definitions of this pair of variables are consistent in every study in

which they are used: They represent the entire period of a subject’s involvement in a study, from providing informed consent through the last participation event or activity. There may be times when this period coincides with other reference periods but that is unusual. An example of when these periods might coincide with the study reference period, RFSTDTC to RFENDTC, might be an observational trial where no study intervention is administered. RFICDTC should correspond to the date of the informed consent protocol milestone in Disposition (DS), if that protocol milestone is documented in DS. In the event that there are multiple informed consents, this will be the date of the first. RFPENDTC will be the last date of participation for a subject for data included in a submission. This should be the last date of any record for the subject in the database at the time it is locked for submission. As such, it may not be the last date of participation in the study if the submission includes interim data.

## Subject Elements (SE)

*Structure: One record per actual Element per subject, Tabulation.*

A special-purpose domain that contains the actual order of elements followed by the subject, together with the start date/time and end date/time for each element.

The Subject Elements dataset consolidates information about the timing of each subject’s progress through the epochs and elements of the trial. For elements that involve study treatments, the identification of which element the subject passed through (e.g., drug X vs. placebo) is likely to derive from data in the Exposure domain or another Interventions domain. The dates of a subject’s transition from one element to the next will be taken from the Interventions domain(s) and from other relevant domains, according to the definitions (TESTRL values) in the Trial Elements (TE) dataset (see Section 7.2.2, Trial Elements).

The SE dataset is particularly useful for studies with multiple treatment periods, such as crossover studies. The SE dataset contains the date/times at which a subject moved from one element to another, so when this dataset, the Trial Arms (TA; see Section 7.2.1, Trial Arms) dataset, and the Trial Elements (TE; see Section 7.2.2, Trial Elements) dataset are included in a submission, reviewers can relate all observations made about a subject to that subject’s progression through the trial.

• Comparison of the --DTC of a finding observation to the element transition dates (values of SESTDTC and SEENDTC) identifies which element the subject was in at the time of the finding. Similarly, one can determine the element during which an event or intervention started or ended.

• “Day within Element” or “Day within Epoch” can be derived. Such variables relate an observation to the start of an element or epoch in the same way that study day (--DY) variables relate it to the reference start date (RFSTDTC) for the study as a whole. See Section 4.4.4, Use of the "Study Day" Variables.

• Having knowledge of SE start and end dates can be helpful in the determination of baseline values.

### SE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SESEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. Should be assigned to be consistent chronological order. | Req |

### SE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ETCD | Element Code | Char | * | Topic | 1. ETCD (the companion to ELEMENT) is limited to 8 characters and does not have special character restrictions. These values should be short for ease of use in programming, but it is not expected that ETCD will need to serve as a variable name. 2. If an encountered element differs from the planned element to the point that it is considered a new element, then use "UNPLAN" as the value for ETCD to represent this element. | Req |
| ELEMENT | Description of Element | Char | * | Synonym Qualifier | The name of the element. If ETCD has a value of "UNPLAN", then ELEMENT should be null. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the subject's assigned trial arm. | Perm |

### SE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the element in the planned sequence of elements for the arm to which the subject was assigned. | Perm |
| SESTDTC | Start Date/Time of Element | Char | ISO 8601 datetime or interval | Timing | Start date/time for an element for each subject. | Req |
| SEENDTC | End Date/Time of Element | Char | ISO 8601 datetime or interval | Timing | End date/time for an element for each subject. | Exp |
| SESTDY | Study Day of Start of Element | Num |  | Timing | Study day of start of element relative to the sponsor-defined RFSTDTC. | Perm |
| SEENDY | Study Day of End of Element | Num |  | Timing | Study day of end of element relative to the sponsor-defined RFSTDTC. | Perm |
| SEUPDES | Description of Unplanned Element | Char |  | Synonym Qualifier | Description of what happened to the subject during an unplanned element. Used only if ETCD has the value of "UNPLAN". | Perm |

### SE Assumptions

Submission of the SE dataset is strongly recommended, as it provides information needed by reviewers to place observations in context within the study. As noted in the SE - Description/Overview, the TE and TA datasets should also be submitted, as these define the design and the terms referenced by the SE dataset.

The SE domain allows the submission of data on the timing of the trial elements a subject actually passed through in their participation in the trial. Section 7.2.2, Trial Elements, and Section 7.2.1, Trial Arms, provide additional information on these datasets, which define a trial's planned elements and describe the planned sequences of elements for the arms of the trial.

1. For any particular subject, the dates in the SE table are the dates when the transition events identified in the TE table occurred. Judgment may be needed

to match actual events in a subject's experience with the definitions of transition events (i.e., events that mark the start of new elements) in the TE table; actual events may vary from the plan. For instance, in a single-dose pharmacokinetics (PK) study, the transition events might correspond to study drug doses of 5 and 10 mg. If a subject actually received a dose of 7 mg when they were scheduled to receive 5 mg, a decision will have to be made on how to represent this in the SE domain.

2. If the date/time of a transition element was not collected directly, the method used to infer the element start date/time should be explained in the

Comments column of the Define-XML document.

3. Judgment will also have to be used in deciding how to represent a subject's experience if an element does not proceed or end as planned. For instance,

the plan might identify a trial element that is to start with the first of a series of 5 daily doses and end after 1 week, when the subject transitions to the next treatment element. If the subject actually started the next treatment epoch (see Section 7.1, Introduction to Trial Design Model Datasets, and Section 7.1.2, Definitions of Trial Design Concepts) after 4 weeks, the sponsor would have to decide whether to represent this as an abnormally long element, or as a normal element plus an unplanned non-treatment element.

## Subject Disease Milestones (SM)

*Structure: One record per Disease Milestone per subject, Tabulation.*

A special-purpose domain that is designed to record the timing, for each subject, of disease milestones that have been defined in the Trial Disease Milestones (TM) domain.

### SM Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SM | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SMSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of subject records. Should be assigned to be consistent chronological order. | Req |
| MIDS | Disease Milestone Instance Name | Char | * | Topic | Name of the specific disease milestone. For types of disease milestones that can occur multiple times, the name will end with a sequence number. Example: "HYPO1". | Req |
| MIDSTYPE | Disease Milestone Type | Char | * | Record Qualifier | The type of disease milestone. Example: "HYPOGLYCEMIC EVENT". | Req |

### SM Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SMSTDTC | Start Date/Time of Milestone | Char | ISO 8601 datetime or interval | Timing | Start date/time of milestone instance (if milestone is an intervention or event) or date of milestone (if Milestone is a finding). | Exp |
| SMENDTC | End Date/Time of Milestone | Char | ISO 8601 datetime or interval | Timing | End date/time of disease milestone instance. | Exp |
| SMSTDY | Study Day of Start of Milestone | Num |  | Timing | Study day of start of disease milestone instance, relative to the sponsor-defined RFSTDTC. | Exp |
| SMENDY | Study Day of End of Milestone | Num |  | Timing | Study day of end of disease milestone instance, relative to the sponsor-defined RFSTDTC. | Exp |

### SM Assumptions

1. Disease milestones are observations or activities whose timings are of interest in the study. The types of disease milestones are defined at the study level

in the TM dataset. The purpose of the SM dataset is to provide a summary timeline of the milestones for a particular subject.

2. The name of the disease milestone is recorded in MIDS.

a. For disease milestones that can occur only once (TMRPT = "N"), the value of MIDS may be the value in MIDSTYPE or may an abbreviated version.

## Subject Visits (SV)

*Structure: One record per actual or planned visit per subject, Tabulation.*

A special purpose domain that contains information for each subject's actual and planned visits.

The Subject Visits domain consolidates information about the timing of subject visits that is otherwise spread over domains that include the visit variables (VISITNUM and possibly VISIT and/or VISITDY). Unless the beginning and end of each visit is collected, populating the SV dataset will involve derivations. In a simple case, where, for each subject visit, exactly 1 date appears in every such domain, the SV dataset can be created easily by populating both SVSTDTC and SVENDTC with the single date for a visit. When there are multiple dates and/or date/times for a visit for a particular subject, the derivation of values for SVSTDTC and SVENDTC may be more complex. The method for deriving these values should be consistent with the visit definitions in the Trial Visits (TV) dataset (see Section 7.3.1, Trial Visits). For some studies, a visit may be defined to correspond with a clinic visit that occurs within 1 day, whereas for other studies, a visit may reflect data collection over a multiday period.

The SV dataset provides reviewers with a summary of a subject’s visits over the course of their participation in a study. Comparison of an individual subject’s SV dataset with the TV dataset, which describes the planned visits for the trial, supports the identification of planned but not expected visits due to a subject not completing the study. Comparison of the values of SVSTDY and SVENDY to VISIT and/or VISITDY can often highlight departures from the planned timing of visits.

### SV Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SV | Identifier | Two-character abbreviation for the domain most relevant to the observation. The domain abbreviation is also used as a prefix for variables to ensure uniqueness when datasets are merged. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| VISITNUM | Visit Number | Num |  | Topic | Clinical encounter number. Numeric version of VISIT, used for sorting. | Req |
| VISIT | Visit Name | Char |  | Synonym Qualifier | Protocol-defined description of a clinical encounter. | Perm |
| SVPRESP | Pre-specified | Char | (NY) | Variable Qualifier | Used to indicate whether the visit was planned (i.e., visits specified in the TV domain). Value is "Y" for planned visits, null for unplanned visits. | Exp |

### SV Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SVOCCUR | Occurrence | Char | (NY) | Record Qualifier | Used to record whether a planned visit occurred. The value is null for unplanned visits. | Exp |
| SVREASOC | Reason for Occur Value | Char |  | Record Qualifier | The reason for the value in SVOCCUR. If SVOCCUR="N", SVREASOC is the reason the visit did not occur. | Perm |
| SVCNTMOD | Contact Mode | Char | (CNTMODE) | Record Qualifier | The way in which the visit was conducted. Examples: "IN PERSON", "TELEPHONE CALL", "IVRS". | Perm |
| SVEPCHGI | Epi/Pandemic Related Change Indicator | Char | (NY) | Record Qualifier | Indicates whether the visit was changed due to an epidemic or pandemic. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| SVSTDTC | Start Date/Time of Observation | Char | ISO 8601 datetime or interval | Timing | Start date/time of an observation represented in IS0 8601 character format. | Exp |

### SV Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SVENDTC | End Date/Time of Observation | Char | ISO 8601 datetime or interval | Timing | End date/time of the observation represented in IS0 8601 character format. | Exp |
| SVSTDY | Study Day of Start of Observation | Num |  | Timing | Actual study day of start of observation expressed in integer days relative to the sponsor- defined RFSTDTC in Demographics. | Perm |
| SVENDY | Study Day of End of Observation | Num |  | Timing | Actual study day of end of observation expressed in integer days relative to the sponsor- defined RFSTDTC in Demographics. | Perm |
| SVUPDES | Description of Unplanned Visit | Char |  | Record Qualifier | Description of what happened to the subject during an unplanned visit. Only populated for unplanned visits. | Perm |

### SV Assumptions

1. The Subject Visits domain allows the submission of data on the timing of the trial visits for a subject, including both those visits they actually passed

through in their participation in the trial and those visits that did not occur. Refer to Section 7.3.1, Trial Visits (TV), as the TV dataset defines the planned visits for the trial.

2. Subjects can have 1 and only 1 record per VISITNUM.

3. Subjects who screen fail, withdraw, die, or otherwise discontinue study participation will not have records for planned visits subsequent to their final

disposition event.

4. Planned and unplanned visits with a subject, whether or not they are physical visits to the investigational site, are represented in this domain.

a. SVPRESP = "Y" identifies rows for planned visits.

b. For planned visits, SVOCCUR indicates whether the visit occurred.

c. For unplanned visits, SVPRESP and SVOCCUR are null.

d. See Section 4.5.7, Presence or Absence of Prespecified Interventions and Events, for more information on the use of --PRESP and --OCCUR.

5. The identification of an actual visit with a planned visit sometimes calls for judgment. In general, data collection forms are prepared for particular visits,

and the fact that data was collected on a form labeled with a planned visit is sufficient to make the association. Occasionally, the association will not be so clear, and the sponsor will need to make decisions about how to label actual visits. The sponsor's rules for making such decisions should be documented in the Define-XML document.

6. Records for unplanned visits should be included in the SV dataset. For unplanned visits, SVUPDES can be populated with a description of the reason

for the unplanned visit. Some judgment may be required to determine what constitutes an unplanned visit. When data are collected outside a planned visit, that act of collecting data may or may not be described as a "visit." The encounter should generally be treated as a visit if data from the encounter are included in any domain for which VISITNUM is included; a record with a missing value for VISITNUM is generally less useful than a record with

7. The variable SVCNTMOD is used to record the way in which the visit was conducted. For example, for visits to a clinic, SVCNTMOD = "IN

PERSON", visits conducted remotely might have values such as "TELEPHONE", "REMOTE AUDIO VIDEO", or "IVRS". If there are multiple contact modes, refer to Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable.

8. The planned study day of visit variable (VISITDY) should not be populated for unplanned visits.

9. If SVSTDY is included, it is the actual study day corresponding to SVSTDTC. In studies for which VISITDY has been populated, it may be desirable to

populate SVSTDY, as this will facilitate the comparison of planned (VISITDY) and actual (SVSTDY) study days for the start of a visit.

10. If SVENDY is included, it is the actual day corresponding to SVENDTC.

11. For many studies, all visits are assumed to occur within 1 calendar day, and only 1 date is collected for the visit. In such a case, the values for

SVENDTC duplicate values in SVSTDTC. However, if the data for a visit is actually collected over several physical visits and/or over several days, then SVSTDTC and SVENDTC should reflect this fact. Note that it is fairly common for screening data to be collected over several days, but for the data to be treated as belonging to a single planned screening visit, even in studies for which all other visits are single-day visits.

12. Differentiating between planned and unplanned visits may be challenging if unplanned assessments (e.g., repeat labs) are performed during the time

period of a planned visit.

13. Algorithms for populating SVSTDTC and SVENDTC from the dates of assessments performed at a visit may be particularly challenging for screening

visits, since baseline values collected at a screening visit are sometimes historical data from tests performed before the subject started screening for the trial. Therefore dates prior to informed consent are not part of the determination of SVSTDTC.

14. The following Identifier variables are permissible and may be added as appropriate: --SEQ, --GRPID, --REFID, and --SPID.

15. Care should be taken in adding additional timing variables:

a. If TAETORD and/or EPOCH are added, then the values must be those at the start of the visit.

b. The purpose of --DTC and --DY in other domains with start and end dates (Event and Intervention Domains) is to record the date on which

data was collected. For a visit that occurred, it is not necessary to submit the date on which information about the visit was recorded. When SVPRESP = "Y" and SVOCCUR = "N", --DTC and --DY are available for use to represent the date on which it was recorded that the visit did not take place.

c. --DUR could be added if the duration of a visit was collected.

d. It would be inappropriate to add the variables that support time points (--TPT, --TPTNUM, --ELTM, --TPTREF, and --RFTDTC), because the

topic of this dataset is visits.

e. --STRF and --ENRF could be used to say whether a visit started and ended before, during, or after the study reference period, although this seems unnecessary.

f. --STRTPT, --STTPT, --ENRTPT, and --ENTPT could be used to say that a visit started or ended before or after particular dates, although this seems unnecessary.

16. SVOCCUR = "N" records are only to be created for planned visits that were expected to occur before the end of the subject's participation.

## Procedure Agents (AG)

*Structure: One record per recorded intervention occurrence per subject, Tabulation.*

An interventions domain that contains the agents administered to the subject as part of a procedure or assessment, as opposed to drugs, medications and therapies administered with therapeutic intent.

### AG Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | AG | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| AGSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| AGGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| AGSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number from the procedure or test page. | Perm |

### AG Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains.This may be a one-to-one or a one-to-many relationship. | Perm |
| AGLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains.This will usually be a many-to-one relationship. | Perm |
| AGTRT | Reported Agent Name | Char |  | Topic | Verbatim medication name that is either preprinted or collected on a CRF. | Req |
| AGMODIFY | Modified Reported Name | Char |  | Synonym Qualifier | If AGTRT is modified to facilitate coding, then AGMODIFY will contain the modified text. | Perm |

### AG Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGDECOD | Standardized Agent Name | Char | * | Synonym Qualifier | Standardized or dictionary-derived text description of AGTRT or AGMODIFY. Equivalent to the generic medication name in WHO Drug. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document. If an intervention term does not have a decode value in the dictionary, then AGDECOD will be left blank. | Perm |
| AGCAT | Category for Agent | Char | * | Grouping Qualifier | Used to define a category of agent. Examples: "CHALLENGE AGENT", "PET TRACER". | Perm |
| AGSCAT | Subcategory for Agent | Char | * | Grouping Qualifier | Further categorization of agent. | Perm |
| AGPRESP | AG Pre-Specified | Char | (NY) | Variable Qualifier | Used to indicate whether ("Y"/null) information about the use of a specific agent was solicited on the CRF. | Perm |

### AG Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGOCCUR | AG Occurrence | Char | (NY) | Record Qualifier | When the use of specific agent is solicited, AGOCCUR is used to indicate whether ("Y"/"N") use of the agent occurred. Values are null for agents not specifically solicited. | Perm |
| AGSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question about a prespecified agent was not answered. Should be null or have a value of "NOT DONE". | Perm |
| AGREASND | Reason Procedure Agent Not Collected | Char |  | Record Qualifier | Describes the reason a response to a question about the occurrence of a procedure agent was not collected. Used in conjunction with AGSTAT when value is "NOT DONE". | Perm |

### AG Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGCLAS | Agent Class | Char | * | Variable Qualifier | Drug class. May be obtained from coding. When coding to a single class, populate with class value. If using a dictionary and coding to multiple classes, follow guidance in Section 4.2.8.3, Multiple Values for a Non- result Qualifier Variable, or omit AGCLAS. | Perm |
| AGCLASCD | Agent Class Code | Char | * | Variable Qualifier | Class code corresponding to AGCLAS. Drug class. May be obtained from coding. When coding to a single class, populate with class code. If using a dictionary and coding to multiple classes, follow guidance in Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable, or omit AGCLASCD. | Perm |
| AGDOSE | Dose per Administration | Num |  | Record Qualifier | Amount of AGTRT taken. | Perm |
| AGDOSTXT | Dose Description | Char |  | Record Qualifier | Dosing amounts or a range of dosing information collected in text form. Units may be stored in AGDOSU. Examples: "200-400", "15-20". | Perm |

### AG Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGDOSU | Dose Units | Char | (UNIT) | Variable Qualifier | Units for AGDOSE and AGDOSTXT. Examples: "ng", "mg", "mg/kg". | Perm |
| AGDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dose form for AGTRT. Examples: "TABLET", "AEROSOL". | Perm |
| AGDOSFRQ | Dosing Frequency per Interval | Char | (FREQ) | Record Qualifier | Usually expressed as the number of repeated administrations of AGDOSE within a specific time period. Example: "ONCE". | Perm |
| AGROUTE | Route of Administration | Char | (ROUTE) | Variable Qualifier | Route of administration for AGTRT. Example: "ORAL". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | 1. Clinical encounter number. 2. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | 1. Protocol-defined description of clinical encounter. 2. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### AG Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the agent administration started. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the agent administration started. | Perm |
| AGSTDTC | Start Date/Time of Agent | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by AGTRT and the dosing variables began. | Perm |
| AGENDTC | End Date/Time of Agent | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by AGTRT and the dosing variables ended. | Perm |
| AGSTDY | Study Day of Start of Agent | Num |  | Timing | Study day of start of agent relative to the sponsor-defined RFSTDTC. | Perm |
| AGENDY | Study Day of End of Agent | Num |  | Timing | Study day of end of agent relative to the sponsor-defined RFSTDTC. | Perm |

### AG Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGDUR | Duration of Agent | Char | ISO 8601 duration | Timing | Collected duration for an agent episode. Used only if collected on the CRF and not derived from start and end date/times. | Perm |
| AGSTRF | Start Relative to Reference Period | Char | (STENRF) | Timing | Describes the start of the agent relative to sponsor-defined reference period. The sponsor-defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). If information such as "PRIOR", "ONGOING", or "CONTINUING" was collected, this information may be translated into AGSTRF. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### AG Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGENRF | End Relative to Reference Period | Char | (STENRF) | Timing | Describes the end of the agent relative to the sponsor-defined reference period. The sponsor-defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). If information such as "PRIOR", "ONGOING", or "CONTINUING" was collected, this information may be translated into AGENRF. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| AGSTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the agent as being before or after the sponsor-defined reference time point defined by variable AGSTTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### AG Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AGSTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by AGSTRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |
| AGENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the agent as being before or after the reference time point defined by variable AGENTPT. Identifies the end of the agent as being before or after the sponsor-defined reference time point defined by variable AGENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| AGENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by AGENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### AG Assumptions

1. Purpose of the domain: Some tests involve administration of substances, and it has been unclear in which domain these should be represented.

a. The Concomitant/Prior Medications (CM) domain seemed particularly inappropriate when the substance was one that would never be given as a medication. Even substances that are medications are not being used as such when they are given as part of a testing procedure.

b. The Exposure (EX) domain also seemed inappropriate; although the testing procedure might be part of the study plan, these data would not be used

or analyzed in the same way as data about study treatments. The AG domain was created to fill this gap.

c. The AG domain has advantages over the Procedures (PR) domain for this purpose. It allows recording of multiple substance administrations for a single testing procedure. It also separates data about substance administrations from data about procedures that do not involve substance administration.

d. Information about the conduct of the procedure with which the procedure agent administration was associated, if collected, should be represented in

the PR domain.

2. Examples and structure

a. Examples of agents administered as part of a procedure include a short-acting bronchodilator administered as part of a reversibility assessment and contrast agents or radio-labeled substances used in imaging studies.

## Concomitant/Prior Medications (CM)

*Structure: One record per recorded intervention occurrence or constant-dosing interval.*

An interventions domain that contains concomitant and prior medications used by the subject, such as those given on an as needed basis or condition-appropriate medications.

### CM Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | CM | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| CMSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| CMGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| CMSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. Example: a number preprinted on the CRF as an explicit line identifier or record identifier defined in the sponsor's operational database. Example: line number on a concomitant medication page. | Perm |

### CM Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CMTRT | Reported Name of Drug, Med, or Therapy | Char |  | Topic | Verbatim medication name that is either preprinted or collected on a CRF. | Req |
| CMMODIFY | Modified Reported Name | Char |  | Synonym Qualifier | If CMTRT is modified to facilitate coding, then CMMODIFY will contain the modified text. | Perm |
| CMDECOD | Standardized Medication Name | Char |  | Synonym Qualifier | Standardized or dictionary-derived text description of CMTRT or CMMODIFY. Equivalent to the generic drug name in WHO Drug. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document. If an intervention term does not have a decode value in the dictionary, then CMDECOD will be left blank. | Perm |
| CMCAT | Category for Medication | Char |  | Grouping Qualifier | Used to define a category of medications/treatment. Examples: "PRIOR", "CONCOMITANT", "ANTI- CANCER MEDICATION", "GENERAL CONMED". | Perm |

### CM Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CMSCAT | Subcategory for Medication | Char |  | Grouping Qualifier | A further categorization of medications/treatment. Examples: "CHEMOTHERAPY", "HORMONAL THERAPY", "ALTERNATIVE THERAPY". | Perm |
| CMPRESP | CM Pre-specified | Char | (NY) | Variable Qualifier | Used to indicate whether ("Y"/null) information about the use of a specific medication was solicited on the CRF. | Perm |
| CMOCCUR | CM Occurrence | Char | (NY) | Record Qualifier | When the use of a specific medication is solicited. CMOCCUR is used to indicate whether ("Y"/"N") use of the medication occurred. Values are null for medications not specifically solicited. | Perm |
| CMSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question about the occurrence of a prespecified intervention was not answered. Should be null or have a value of "NOT DONE". | Perm |
| CMREASND | Reason Medication Not Collected | Char |  | Record Qualifier | Reason not done. Used in conjunction with CMSTAT when value is "NOT DONE". | Perm |

### CM Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CMINDC | Indication | Char |  | Record Qualifier | Denotes why a medication was taken or administered. Examples: "NAUSEA", "HYPERTENSION". | Perm |
| CMCLAS | Medication Class | Char |  | Variable Qualifier | Drug class. May be obtained from coding. When coding to a single class, populate with class value. If using a dictionary and coding to multiple classes, then follow Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable, or omit CMCLAS. | Perm |

### CM Assumptions

1. The structure of the CM domain is 1 record per medication intervention episode, constant-dosing interval, or prespecified medication assessment per

subject. It is the sponsor's responsibility to define an intervention episode. This definition may vary based on the sponsor's requirements for review and analysis. The submission dataset structure may differ from the structure used for collection. One common approach is to submit a new record when there is a change in the dosing regimen. Another approach is to collapse all records for a medication to a summary level with either a dose range or the highest dose level. Other approaches may also be reasonable as long as they meet the sponsor's evaluation requirements.

2. CM description and coding

a. CMTRT is the topic variable and captures the name of the concomitant medication/therapy or the prespecified term used to collect information about the occurrence of any of a group of medications and/or therapies. It is a required variable and must have a value. CMTRT only includes the medication/therapy name and does not include dosage, formulation, or other qualifying information. For example, “ASPIRIN 100MG TABLET” is not a valid value for CMTRT. This example should be expressed as CMTRT= “ASPIRIN”, CMDOSE= “100”, CMDOSU= “MG”, and CMDOSFRM= “TABLET”. When referring to a prespecified group of medications/therapies, CMTRT contains the description of the group used to solicit the occurrence response.

b. CMMODIFY should be included if the sponsor’s procedure permits modification of a verbatim term for coding.

c. CMDECOD is the standardized medication/therapy term derived by the sponsor from the coding dictionary. It is expected that the reported term (CMTRT) or the modified term (CMMODIFY) will be coded using a standard dictionary. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document.

d. When CMDECOD values from the WHODrug Dictionary are longer than 200 characters, split the values at semicolons rather than spaces when

implementing guidance in Section 4.5.3.2, Text Strings Greater than 200 Characters.

3. Prespecified terms; presence or absence of concomitant medications

a. Information on concomitant medications is generally collected in 2 different ways, either by recording free text or using a prespecified list of terms. Because the solicitation of information on specific concomitant medications may affect the frequency at which they are reported, the fact that a specific medication was solicited may be of interest to reviewers. CMPRESP and CMOCCUR are used together to indicate whether the intervention in CMTRT was prespecified and whether it occurred, respectively.

## Exposure (EX)

*Structure: One record per protocol-specified study treatment, constant-dosing interval, per subject, Tabulation.*

An interventions domain that contains the details of a subject's exposure to protocol-specified study treatment. Study treatment may be any intervention that is prospectively defined as a test material within a study, and is typically but not always supplied to the subject.

### EX Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | EX | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| EXSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| EXGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| EXREFID | Reference ID | Char |  | Identifier | Internal or external identifier (e.g., kit number, bottle label, vial identifier). | Perm |
| EXSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a CRF page. | Perm |

### EX Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EXLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. | Perm |
| EXLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related, grouped records across domains. | Perm |
| EXTRT | Name of Treatment | Char | * | Topic | Name of the protocol-specified study treatment given during the dosing period for the observation. | Req |
| EXCAT | Category of Treatment | Char | * | Grouping Qualifier | Used to define a category of EXTRT values. | Perm |
| EXSCAT | Subcategory of Treatment | Char | * | Grouping Qualifier | A further categorization of EXCAT values. | Perm |
| EXDOSE | Dose | Num |  | Record Qualifier | Amount of EXTRT when numeric. Not populated when EXDOSTXT is populated. | Exp |
| EXDOSTXT | Dose Description | Char |  | Record Qualifier | Amount of EXTRT when non-numeric. Dosing amounts or a range of dosing information collected in text form. Example: "200-400". Not populated when EXDOSE is populated. | Perm |

### EX Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EXDOSU | Dose Units | Char | (UNIT) | Variable Qualifier | Units for EXDOSE, EXDOSTOT, or EXDOSTXT representing protocol-specified values. Examples: "ng", "mg", "mg/kg", "mg/m2". | Exp |
| EXDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dose form for EXTRT. Examples: "TABLET", "LOTION". | Exp |
| EXDOSFRQ | Dosing Frequency per Interval | Char | (FREQ) | Record Qualifier | Usually expressed as the number of repeated administrations of EXDOSE within a specific time period. Examples: "Q2H", "QD", "BID". | Perm |
| EXDOSRGM | Intended Dose Regimen | Char |  | Record Qualifier | Text description of the intended schedule or regimen for the Intervention. Example: "TWO WEEKS ON, TWO WEEKS OFF". | Perm |
| EXROUTE | Route of Administration | Char | (ROUTE) | Variable Qualifier | Route of administration for the intervention. Examples: "ORAL", "INTRAVENOUS". | Perm |
| EXLOT | Lot Number | Char |  | Record Qualifier | Lot number of the intervention product. | Perm |
| EXLOC | Location of Dose Administration | Char | (LOC) | Record Qualifier | Specifies location of administration. Examples: "ARM", "LIP". | Perm |

### EX Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EXLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location further detailing laterality of the intervention administration. Examples: "LEFT", "RIGHT". | Perm |
| EXDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL", "UPPER". | Perm |
| EXFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. Examples: "Y", "N". | Perm |
| EXADJ | Reason for Dose Adjustment | Char | * | Record Qualifier | Describes reason or explanation of why a dose is adjusted. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Trial epoch of the exposure record. Examples: "RUN-IN", "TREATMENT". | Perm |
| EXSTDTC | Start Date/Time of Treatment | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by EXTRT and EXDOSE began. | Exp |

### EX Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EXENDTC | End Date/Time of Treatment | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by EXTRT and EXDOSE ended. For administrations considered given at a point in time (e.g., oral tablet, pre-filled syringe injection), where only an administration date/time is collected, EXSTDTC should be copied to EXENDTC as the standard representation. | Exp |
| EXSTDY | Study Day of Start of Treatment | Num |  | Timing | Study day of EXSTDTC relative to DM.RFSTDTC. | Perm |
| EXENDY | Study Day of End of Treatment | Num |  | Timing | Study day of EXENDTC relative to DM.RFSTDTC. | Perm |
| EXDUR | Duration of Treatment | Char | ISO 8601 duration | Timing | Collected duration of administration. Used only if collected on the CRF and not derived from start and end date/times. | Perm |

### EX Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EXTPT | Planned Time Point Name | Char |  | Timing | Text description of time when administration should occur. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See EXTPTNUM and EXTPTREF. | Perm |
| EXTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of EXTPT to aid in sorting. | Perm |
| EXELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to the planned fixed reference (EXTPTREF). This variable is useful where there are repetitive measures. Not a clock time. | Perm |
| EXTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by EXELTM, EXTPTNUM, and EXTPT. Examples: PREVIOUS DOSE, PREVIOUS MEAL. | Perm |
| EXRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by EXTPTREF. | Perm |

### EX Assumptions

1. EX structure and use

a. Examples of treatments represented in the EX domain include but are not limited to placebo, active comparators, and investigational products. Treatments that are not protocol-specified should be represented in the Concomitant/Prior Medications (CM) or another Interventions domain as appropriate.

b. The EX domain is recognized in most cases as a derived dataset where EXDOSU reflects the protocol-specified unit per study treatment. Collected

data points (e.g., number of tablets, total volume infused) along with additional inputs (e.g., randomization file, concentration, dosage strength, product accountability) are used to derive records in the EX domain.

i. Derived from actual observation of the administration of drug by the investigator

ii. Derived from automated dispensing device that records administrations

iii. Derived from subject recall

iv. Derived from product accountability data

v. Derived from the protocol. When a study is still masked and protocol-specified study treatment doses cannot yet be reflected in the protocol-

specified unit due to blinding requirements, then the EX domain is not expected to be populated.

d. The EX domain should contain 1 record per constant-dosing interval per subject. Sponsors define the constant-dosing interval, which may include

any period of time that can be described in terms of a known treatment given at a consistent dose, frequency, infusion rate, and so on. For example, for a study with once-a-week administration of a standard dose for 6 weeks, exposure may be represented as:

i. a single record per subject, spanning the entire 6-week treatment phase, if information about each dose is not collected; or

ii. up to 6 records (1 for each weekly administration), if the sponsor monitors each treatment administration.

2. Exposure treatment description

a. EXTRT captures the name of the protocol-specified study treatment and is the topic variable. It is a required variable and must have a value. EXTRT must include only the treatment name and must not include dosage, formulation, or other qualifying information. For example, "ASPIRIN 100MG TABLET" is not a valid value for EXTRT. This example should be expressed as EXTRT = "ASPIRIN", EXDOSE = "100", EXDOSU = "mg", and EXDOSFRM = "TABLET".

b. Doses of placebo should be represented by EXTRT = "PLACEBO" and EXDOSE = "0" (indicating 0 mg of active ingredient was taken or

administered).

3. Categorization and grouping

a. EXCAT and EXSCAT may be used when appropriate to categorize treatments into categories and subcategories. For example, if a study contains several active comparator medications, EXCAT may be set to "ACTIVE COMPARATOR". Such categorization may not be useful in all studies, so these variables are permissible.

4. Timing variables

a. The timing of exposure to study treatment is captured by the start/end date and start/end time of each constant-dosing interval. If the subject is only exposed to study medication within a clinical encounter (e.g., if an injection is administered at the clinic), VISITNUM may be added to the domain as an additional timing variable. VISITDY and VISIT would then also be permissible qualifiers. However, if the beginning and end of a constantdosing interval is not confined within the time limits of a clinical encounter (e.g., if a subject takes pills at home), then it is not appropriate to include VISITNUM in the EX domain. This is because EX is designed to capture the timing of exposure to treatment, not the timing of dispensing treatment. Further, VISITNUM should not be used to indicate that treatment began at a particular visit and continued for a period of time. The SDTM does not have any provision for recording "start visit" and "end visit" of exposure.

## Exposure as Collected (EC)

*Structure: One record per protocol-specified study treatment, collected-dosing interval, per.*

An interventions domain that contains information about protocol-specified study treatment administrations, as collected.

### EC Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | EC | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| ECSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| ECGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| ECREFID | Reference ID | Char |  | Identifier | Internal or external identifier (e.g., kit number, bottle label, vial identifier). | Perm |
| ECSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a CRF page. | Perm |

### EC Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. | Perm |
| ECLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related, grouped records across domains. | Perm |
| ECTRT | Name of Treatment | Char | * | Topic | Name of the intervention treatment known to the subject and/or administrator. | Req |
| ECMOOD | Mood | Char | (BRDGMOOD) | Record Qualifier | Mode or condition of the record specifying whether the intervention (activity) is intended to happen or has happened. Values align with BRIDG pillars (e.g., scheduled context, performed context) and HL7 activity moods (e.g., intent, event). Examples: "SCHEDULED", "PERFORMED". | Perm |
| ECCAT | Category of Treatment | Char | * | Grouping Qualifier | Used to define a category of related ECTRT values. | Perm |
| ECSCAT | Subcategory of Treatment | Char | * | Grouping Qualifier | A further categorization of ECCAT values. | Perm |
| ECPRESP | Pre-Specified | Char | (NY) | Variable Qualifier | Used when a specific intervention is prespecified. Values should be "Y" or null. | Perm |

### EC Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECOCCUR | Occurrence | Char | (NY) | Record Qualifier | Used to indicate whether a treatment occurred when information about the occurrence is solicited. ECOCCUR = "N" when a treatment was not taken, not given, or missed. | Perm |
| ECREASOC | Reason for Occur Value | Char |  | Record Qualifier | The reason for the value in --OCCUR. If --OCCUR = "N", this is the reason the exposure did not occur. | Perm |
| ECDOSE | Dose | Num |  | Record Qualifier | Amount of ECTRT when numeric. Not populated when ECDOSTXT is populated. | Exp |
| ECDOSTXT | Dose Description | Char |  | Record Qualifier | Amount of ECTRT when non-numeric. Dosing amounts or a range of dosing information collected in text form. Example: "200-400". Not populated when ECDOSE is populated. | Perm |
| ECDOSU | Dose Units | Char | (UNIT) | Variable Qualifier | Units for ECDOSE, ECDOSTOT, or ECDOSTXT. | Exp |
| ECDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dose form for ECTRT. Examples: "TABLET", "LOTION". | Exp |

### EC Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECDOSFRQ | Dosing Frequency per Interval | Char | (FREQ) | Record Qualifier | Usually expressed as the number of repeated administrations of ECDOSE within a specific time period. Examples: "Q2H", "QD", "BID". | Perm |
| ECDOSTOT | Total Daily Dose | Num |  | Record Qualifier | Total daily dose of ECTRT using the units in ECDOSU. Used when dosing is collected as total daily dose. | Perm |
| ECDOSRGM | Intended Dose Regimen | Char |  | Record Qualifier | Text description of the intended schedule or regimen for the Intervention. Example: "TWO WEEKS ON", "TWO WEEKS OFF". | Perm |
| ECROUTE | Route of Administration | Char | (ROUTE) | Variable Qualifier | Route of administration for the intervention. Examples: "ORAL", "INTRAVENOUS". | Perm |
| ECLOT | Lot Number | Char |  | Record Qualifier | Lot number of the ECTRT product. | Perm |
| ECLOC | Location of Dose Administration | Char | (LOC) | Record Qualifier | Specifies location of administration. Example: "ARM", "LIP". | Perm |

### EC Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location further detailing laterality of the intervention administration. Examples: "LEFT", "RIGHT". | Perm |
| ECDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL", "UPPER". | Perm |
| ECPORTOT | Portion or Totality | Char | (PORTOT) | Variable Qualifier | Qualifier for anatomical location further detailing distribution (i.e., arrangement of, apportioning of). Examples: "ENTIRE", "SINGLE", "SEGMENT". | Perm |
| ECFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. Examples: "Y", "N". | Perm |
| ECPSTRG | Pharmaceutical Strength | Num |  | Record Qualifier | Amount of an active ingredient expressed quantitatively per dosage unit, per unit of volume, or per unit of weight, according to the pharmaceutical dose form. | Perm |
| ECPSTRGU | Pharmaceutical Strength Units | Char | (UNIT) | Variable Qualifier | Unit for ECPSTRG. Examples: "mg/TABLET", "mg/mL". | Perm |
| ECADJ | Reason for Dose Adjustment | Char |  | Record Qualifier | Describes reason or explanation of why a dose is adjusted. | Perm |

### EC Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Trial epoch of the exposure as collected record. Examples: "RUN-IN", "TREATMENT". | Perm |
| ECSTDTC | Start Date/Time of Treatment | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by ECTRT and ECDOSE began. | Exp |
| ECENDTC | End Date/Time of Treatment | Char | ISO 8601 datetime or interval | Timing | The date/time when administration of the treatment indicated by ECTRT and ECDOSE ended. For administrations considered given at a point in time (e.g., oral tablet, pre-filled syringe injection), where only an administration date/time is collected, ECSTDTC should be copied to ECENDTC as the standard representation. | Exp |
| ECSTDY | Study Day of Start of Treatment | Num |  | Timing | Study day of ECSTDTC relative to the sponsor-defined DM.RFSTDTC. | Perm |

### EC Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECENDY | Study Day of End of Treatment | Num |  | Timing | Study day of ECENDTC relative to the sponsor-defined DM.RFSTDTC. | Perm |
| ECDUR | Duration of Treatment | Char | ISO 8601 duration | Timing | Collected duration of administration. Used only if collected on the CRF and not derived from start and end date/times. | Perm |
| ECTPT | Planned Time Point Name | Char |  | Timing | Text description of time when administration should occur. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See ECTPTNUM and ECTPTREF. | Perm |
| ECTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of ECTPT to aid in sorting. | Perm |
| ECELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to the planned fixed reference (ECTPTREF). This variable is useful where there are repetitive measures. Not a clock time. | Perm |

### EC Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ECTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by ECELTM, ECTPTNUM, and ECTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| ECRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by ECTPTREF. | Perm |

### EC Assumptions

1. The EC domain model reflects protocol-specified study treatment administrations, as collected.

a. EC should be used in all cases where collected exposure information cannot or should not be directly represented in the Exposure (EX) domain. For example, administrations collected in tablets when the protocol-specified unit is mg, or administrations collected in mL when the protocol-specified unit is mg/kg. Product accountability details (e.g., amount dispensed, amount returned) are represented in the DA domain, not in EC.

b. Collected exposure data are in most cases represented in a combination of 1 or more of EC, DA, or Findings About Events or Interventions (FA)

domains. If the entire EC dataset is an exact duplicate of the entire EX dataset, then EC is optional and at the sponsor's discretion.

c. Collected exposure log data points descriptive of administrations typically reflect amounts at the product-level (e.g., number of tablets, number of mL).

2. Treatment description (ECTRT) is sponsor-defined and should reflect how the protocol-specified study treatment is known or referred to in data

collection. In an open-label study, ECTRT should store the treatment name. In a masked study, if treatment is collected and known as tablet A to the subject or administrator, then ECTRT = "TABLET A". If, in a masked study, the treatment is not known by a synonym and the data are to be exchanged between sponsors, partners, and/or regulatory agency(s), then assign ECTRT the value of "MASKED".

3. ECMOOD is permissible; when implemented, it must be populated for all records.

a. Values of ECMOOD, to date include:

i. "SCHEDULED" (for collected subject-level intended dose records)

ii. "PERFORMED" (for collected subject-level actual dose records)

ECDOSFRQ are known at scheduling and administration, then the variables would be populated on both records. If ECLOC is determined at the time of administration, then it would be populated on the Performed record only.

c. Appropriate timing variable(s) should be populated. Note: Details on Scheduled records may describe timing at a higher level than Performed records.

d. ECOCCUR is generally not applicable for Scheduled records.

e. An activity may be rescheduled or modified multiple times before being performed. Representation of Scheduled records is dependent on the collected, available data. If each rescheduled or modified activity is collected, then multiple Scheduled records may be represented. If only the final scheduled activity is collected, then it would be the only Scheduled record represented.

4. Doses not taken, not given, or missed

a. The record qualifier --OCCUR, with value of "N", is available in domains based on the Interventions and Events General Observation Classes as the standard way to represent whether an intervention or event did not happen. In the EC domain, ECOCCUR value of "N" indicates a dose was not taken, not given, or missed. For example, if zero tablets are taken within a timeframe or zero mL is infused at a visit, then ECOCCUR = "N" is the standard representation of the collected doses not taken, not given, or missed. Dose amount variables (e.g., ECDOSE, ECDOSTXT) must not be set to zero (0) as an alternative method for indicating doses not taken, not given, or missed.

b. The population of qualifier variables (e.g., grouping, record) and additional timing variables (e.g., date of collection, visit, time point) for records

representing information collected about doses not taken, not given, or missed should be populated with equal granularity as administered records, when known and/or applicable. Qualifiers that indicate dose amount (e.g., ECDOSE, ECDOSTXT) may be populated with positive (non-zero) values in cases where the sponsor feels it is necessary and/or appropriate to represent specific dose amounts not taken, not given, or missed.

c. If a reason why a dose was not given is collected, it is represented in ECREASOC, the reason why ECOCCUR = "N".

5. Timing variables

a. Timing variables in the EC domain should reflect administrations by the intervals they were collected (e.g., constant-dosing intervals, visits, targeted dates like first dose, last dose).

b. For administrations considered given at a point in time (e.g., oral tablet, pre-filled syringe injection), where only an administration date/time is

collected, ECSTDTC should be copied to ECENDTC.

6. The degree of summarization of records from EC to EX is sponsor-defined to support study purpose and analysis. When the relationship between EC

and EX records can be described in RELREC, then it should be defined. EX derivations must be described in the Define-XML document.

7. Additional interventions qualifiers

a. --DOSTOT is under evaluation for potential deprecation and replacement with a mechanism to describe total dose over any interval of time (e.g., day, week, month). Sponsors considering ECDOSTOT may want to consider using other dose amount variables (ECDOSE or ECDOSTXT) in combination with frequency (ECDOSFRQ) and timing variables to represent the data.

b. Any identifier variables, timing variables, or findings general observation-class qualifiers may be added to the EC domain, but the following

qualifiers would generally not be used: --STAT and --REASND.

6.1.3.3 Exposure/Exposure as Collected Examples

Example 1

This is an example of a double-blind study comparing drug X extended release (ER; 2 500-mg tablets once daily) vs. drug Z (2 250-mg tablets once daily). Per example CRFs, subject ABC1001 took 2 tablets from 2011-01-14 to 2011-01-28 and subject ABC2001 took 2 tablets within the same timeframe but missed dosing on 2011-01-24.

Exposure CRF:

Subject: ABC1001

Bottle Number of Tablets Taken Daily Reason for Variation Start Date End Date A 2 2011-01-14 2011-01-28

Subject: ABC2001

Bottle Number of Tablets Taken Daily Reason for Variation Start Date End Date A 2 2011-01-14 2011-01-23 A 0 Patient mistake 2011-01-24 2011-01-24 A 2 2011-01-25 2011-01-28

Upon unmasking, it became known that subject ABC1001 received drug X and Subject ABC2001 received drug Z. The EC dataset shows the administrations of study treatment as collected.

Rows 1-2, 4: Show treatments administered.

Row 3: Shows that the zero for Number of Tablets Taken Daily on the CRF was represented as ECOCCUR = "N". The reason this treatment did not occur is represented in ECREASOC.

ec.xpt

Row STUDYID DOMAIN USUBJID ECSEQ ECLNKID ECTRT ECPRESP ECOCCUR ECREASOC ECDOSE ECDOSU ECDOSFRQ EPOCH ECSTDTC ECENDTC ECSTDY ECENDY 1 ABC EC ABC1001 1 A220110114

BOTTLE A

Y Y 2 TABLET QD TREATMENT 2011-01-

2011-0128

1 15

2 ABC EC ABC2001 1 A220110114

BOTTLE A

Y Y 2 TABLET QD TREATMENT 2011-01-

2011-0123

1 10

3 ABC EC ABC2001 2 A020110124

BOTTLE A

Y N PATIENT MISTAKE

TABLET QD TREATMENT 2011-01-

2011-0124

11 11

4 ABC EC ABC2001 3 A220110125

BOTTLE A

Y Y 2 TABLET QD TREATMENT 2011-01-

2011-0128

12 15

The EX dataset shows the unmasked administrations. Two tablets from bottle A became 1000 mg of drug X extended release for subject ABC1001, but 500 mg of drug Z for subject ABC2001. Note that there is no record in the EX dataset for non-occurrence of study treatment. The non-occurrence of study drug for subject ABC2001 is reflected in the gap in time between the 2 EX records.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXLNKID EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EPOCH EXSTDTC EXENDTC EXSTDY EXENDY 1 ABC EX ABC1001 1 A220110114

DRUG X

1000 mg TABLET, EXTENDED RELEASE

QD ORAL TREATMENT 2011-01-

2011-0128

1 15

2 ABC EX ABC2001 1 A220110114

DRUG Z

500 mg TABLET QD ORAL TREATMENT 2011-01-

2011-0123

1 10

3 ABC EX ABC2001 2 A220110125

DRUG Z

500 mg TABLET QD ORAL TREATMENT 2011-01-

2011-0128

12 15

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC EC ECLNKID ONE 1 2 ABC EX EXLNKID ONE 1

Example 2

This example shows data from an open-label study. A subject received drug X as a 20 mg/mL solution administered across 3 injection sites to deliver a total dose of 3 mg/kg. The subject's weight was 100 kg.

Exposure CRF

Visit 3

Date

Injection 1

Volume Given (mL) 5

Location ABDOMEN

Side LEFT

Injection 2

Volume Given (mL) 5

Location ABDOMEN

Side CENTER

Injection 3

Volume Given (mL) 5

Location ABDOMEN

Side RIGHT

The collected administration amounts, in mL, and their locations are represented in the EC dataset.

ec.xpt

Row STUDYID DOMAIN USUBJID ECSEQ ECSPID ECLNKID ECTRT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRM ECDOSFRQ ECROUTE ECLOC ECLAT VISITNUM VISIT EPOCH ECSTDTC ECENDTC ECSTDY ECENDY 1 ABC EC ABC3001 1 INJ1 V3 DRUG X

Y Y 5 mL INJECTION ONCE SUBCUTANEOUS ABDOMINAL

CAVITY

LEFT 3 VISIT 3

TREATMENT 2009-05-

2009-0510

21 21

2 ABC EC ABC3001 2 INJ2 V3 DRUG X

Y Y 5 mL INJECTION ONCE SUBCUTANEOUS ABDOMINAL

CAVITY

CENTER 3 VISIT 3

TREATMENT 2009-05-

2009-0510

21 21

3 ABC EC ABC3001 3 INJ3 V3 DRUG X

Y Y 5 mL INJECTION ONCE SUBCUTANEOUS ABDOMINAL

CAVITY

RIGHT 3 VISIT 3

TREATMENT 2009-05-

2009-0510

21 21

The sponsor considered the 3 injections to constitute a single administration, so the EX dataset shows the total dose given in the protocol-specified unit, mg/kg. EXLOC = "ABDOMEN" is included because this location was common to all injections, but EXLAT was not included. If the sponsor had chosen to represent laterality in the EX record, this would have been handled as described in Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXSPID EXLNKID EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXLOC VISITNUM VISIT EPOCH EXSTDTC EXENDTC EXSTDY EXENDY 1 ABC EX ABC3001 1 V3 DRUG X 3 mg/kg INJECTION ONCE SUBCUTANEOUS ABDOMEN 3 VISIT 3 TREATMENT 21 21

The relrec.xpt example reflects a many-to-one dataset-level relationship between EC and EX using --LNKID.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC EC ECLNKID MANY 1 2 ABC EX EXLNKID ONE 1

Example 3

The study in this example was a double-blind study comparing 10, 20, and 30 mg of Drug X once daily vs. placebo. Study treatment was given as 1 tablet each from bottles A, B, and C taken together once daily. The subject in this example took:

• 1 tablet from bottles A, B and C from 2011-01-14 to 2011-01-20

• 0 tablets from bottle B on 2011-01-21, then 2 tablets on 2011-01-22

• 1 tablet from bottles A and C on 2011-01-21 and 2011-01-22

• 1 tablet from ottles A, B and C from 2011-01-23 to 2011-01-28

The EC dataset shows administrations as collected, in tablets.

ec.xpt

Row STUDYID DOMAIN USUBJID ECSEQ ECTRT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRQ EPOCH ECSTDTC ECENDTC ECSTDY ECENDY 1 ABC EC ABC4001 1 BOTTLE A Y Y 1 TABLET QD TREATMENT 1 15 2 ABC EC ABC4001 2 BOTTLE C Y Y 1 TABLET QD TREATMENT 1 15 3 ABC EC ABC4001 3 BOTTLE B Y Y 1 TABLET QD TREATMENT 1 7 4 ABC EC ABC4001 4 BOTTLE B Y N TABLET QD TREATMENT 8 8 5 ABC EC ABC4001 5 BOTTLE B Y Y 2 TABLET QD TREATMENT 9 9 6 ABC EC ABC4001 6 BOTTLE B Y Y 1 TABLET QD TREATMENT 10 15

Upon unmasking, it became known that the subject was randomized to drug X 20 mg and that:

• Bottle A contained 10 mg/tablet

• Bottle B contained 10 mg/tablet

• Bottle C contained placebo (i.e., 0 mg of active ingredient/tablet)

The EX dataset shows the doses administered in the protocol-specified unit (mg). The sponsor considered an administration to consist of the total amount for bottles A, B, and C. The derivation of EX records from multiple EC records should be shown in the Define-XML document.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EPOCH EXSTDTC EXENDTC EXSTDY EXENDY 1 ABC EX ABC4001 1 DRUG X 20 mg TABLET QD ORAL TREATMENT 1 7 2 ABC EX ABC4001 2 DRUG X 10 mg TABLET QD ORAL TREATMENT 8 8 3 ABC EX ABC4001 3 DRUG X 30 mg TABLET QD ORAL TREATMENT 9 9 4 ABC EX ABC4001 4 DRUG X 20 mg TABLET QD ORAL TREATMENT 10 15

The study in this example was an open-label study examining the tolerability of different doses of drug A. The study drug was taken orally, daily for 3 months. Dose adjustments were allowed as needed in response to tolerability or efficacy issues.

The EX dataset shows administrations collected in the protocol-specified unit, mg. No EC dataset was needed because the open-label administrations were collected in the protocol-specified unit; EC would be an exact duplicate of the entire EX domain.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXADJ EPOCH EXSTDTC EXENDTC 1 37841 EX 37841001 1 DRUG A 20 mg TABLET QD ORAL TREATMENT 2002-07-01 2002-10-01 2 37841 EX 37841002 1 DRUG A 20 mg TABLET QD ORAL TREATMENT 2002-04-02 2002-04-21 3 37841 EX 37841002 2 DRUG A 15 mg TABLET QD ORAL Reduced due to toxicity TREATMENT 2002-04-22 2002-07-01 4 37841 EX 37841003 1 DRUG A 20 mg TABLET QD ORAL TREATMENT 2002-05-09 2002-06-01 5 37841 EX 37841003 2 DRUG A 25 mg TABLET QD ORAL Increased due to suboptimal efficacy TREATMENT 2002-06-02 2002-07-01 6 37841 EX 37841003 3 DRUG A 30 mg TABLET QD ORAL Increased due to suboptimal efficacy TREATMENT 2002-07-02 2002-08-01

Example 5

This is an example of a double-blind study design comparing 10 and 20 mg of drug X vs. placebo taken daily, morning and evening, for a week.

Subject ABC5001

Bottle Time Point Number of Tablets Taken Start Date End Date A AM 1 B PM 1

Subject ABC5002

Bottle Time Point Number of Tablets Taken Start Date End Date A AM 1 B PM 1

Subject ABC5003

Bottle Time Point Number of Tablets Taken Start Date End Date A AM 1 B PM 1

The EC dataset shows the administrations as collected. The time-point variables ECTPT and ECTPTNUM were used to describe the time of day of administration. This use of time-point variables is novel, representing data about multiple time points, 1 on each day of administration, rather than data for a single time point.

Row STUDYID DOMAIN USUBJID ECSEQ ECLNKID ECTRT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRQ EPOCH ECSTDTC ECENDTC ECSTDY ECENDY ECTPT ECTPTNUM 1 ABC EC ABC5001 1 20120101-20120108-AM BOTTLE A Y Y 1 TABLET QD TREATMENT 1 8 AM 1 2 ABC EC ABC5001 2 20120101-20120108-PM BOTTLE B Y Y 1 TABLET QD TREATMENT 1 8 PM 2 3 ABC EC ABC5002 1 20120201-20120208-AM BOTTLE A Y Y 1 TABLET QD TREATMENT 1 8 AM 1 4 ABC EC ABC5002 2 20120201-20120208-PM BOTTLE B Y Y 1 TABLET QD TREATMENT 1 8 PM 2 5 ABC EC ABC5003 1 20120301-20120308-AM BOTTLE A Y Y 1 TABLET QD TREATMENT 1 8 AM 1 6 ABC EC ABC5003 2 20120301-20120308-PM BOTTLE B Y Y 1 TABLET QD TREATMENT 1 8 PM 2

The EX dataset shows the unmasked administrations in the protocol specified unit, mg. Amount of placebo was represented as 0 mg. The sponsor chose to represent the administrations at the time-point level.

Rows 1-2: Show administrations for a subject who was randomized to the 20 mg drug X arm.

Rows 3-4: Show administrations for a subject who was randomized to the 10 mg drug X arm.

Rows 5-6: Show administrations for a subject who was randomized to the placebo arm.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXLNKID EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EPOCH EXSTDTC EXENDTC EXSTDY EXENDY EXTPT EXTPTNUM 1 ABC EX ABC5001 1 20120101-20120108-AM DRUG X 10 mg TABLET QD ORAL TREATMENT 1 8 AM 1 2 ABC EX ABC5001 2 20120101-20120108-PM DRUG X 10 mg TABLET QD ORAL TREATMENT 1 8 PM 2 3 ABC EX ABC5002 1 20120201-20120208-AM DRUG X 10 mg TABLET QD ORAL TREATMENT 1 8 AM 1 4 ABC EX ABC5002 2 20120201-20120208-PM PLACEBO 0 mg TABLET QD ORAL TREATMENT 1 8 PM 2 5 ABC EX ABC5003 1 20120301-20120308-AM PLACEBO 0 mg TABLET QD ORAL TREATMENT 1 8 AM 1 6 ABC EX ABC5003 2 20120301-20120308-PM PLACEBO 0 mg TABLET QD ORAL TREATMENT 1 8 PM 2

The relrec.xpt example reflects a one-to-one dataset-level relationship between EC and EX using --LNKID.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC EC ECLNKID ONE 1 2 ABC EX EXLNKID ONE 1

Example 6

The study in this example was a single-crossover study comparing once-daily oral administration of drug A 20 mg capsules with drug B 30 mg coated tablets. The study drug was taken for 3 consecutive mornings, 30 minutes prior to a standardized breakfast. There was a 6-day washout period between treatments.

The following CRFs show data for 2 subjects.

Subject 56789001

Period 1 Period 2 Day Bottle 1

\# of capsules

Bottle 2 # of tablets

Start Date/Time End Date/Time Day Bottle 1

\# of capsules

Bottle 2 # of tablets

Start Date/Time End Date/Time

1 1 1 2002-07-01T07:30 2002-07-01T07:30 1 1 1 2002-07-09T07:30 2002-07-09T07:30 2 1 1 2002-07-02T07:30 2002-07-02T07:30 2 1 1 2002-07-10T07:30 2002-07-10T07:30 3 1 1 2002-07-03T07:32 2002-07-03T07:32 3 1 1 2002-07-11T07:34 2002-07-11T07:34

Period 1 Period 2 Day Bottle 1

\# of capsules

Bottle 2 # of tablets

Start Date/Time End Date/Time Day Bottle 1

\# of capsules

Bottle 2 # of tablets

Start Date/Time End Date/Time

1 1 1 2002-07-03T07:30 2002-07-03T07:30 1 1 1 2002-07-11T07:30 2002-07-11T07:30 2 1 1 2002-07-04T07:24 2002-07-04T07:24 2 1 1 2002-07-12T07:43 2002-07-12T07:43 3 1 1 2002-07-05T07:24 2002-07-05T07:24 3 1 1 2002-07-13T07:38 2002-07-13T07:38

The EC dataset shows administrations as collected.

ec.xpt

Row STUDYID DOMAIN USUBJID ECSEQ ECTRT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRM ECDOSFRQ ECROUTE EPOCH ECSTDTC ECENDTC ECSTDY ECENDY ECTPT ECELTM ECTPTREF 1 56789 EC 56789001 1 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0701T07:30

2002-0701T07:30

1 1 30 MINUTES PRIOR

-PT30M STD BREAKFAST 2 56789 EC 56789001 2 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0701T07:30

2002-0701T07:30

1 1 30 MINUTES PRIOR

-PT30M STD BREAKFAST 3 56789 EC 56789001 3 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0702T07:30

2002-0702T07:30

2 2 30 MINUTES PRIOR

-PT30M STD BREAKFAST 4 56789 EC 56789001 4 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0702T07:30

2002-0702T07:30

2 2 30 MINUTES PRIOR

-PT30M STD BREAKFAST 5 56789 EC 56789001 5 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0703T07:32

2002-0703T07:32

3 3 30 MINUTES PRIOR

-PT30M STD BREAKFAST 6 56789 EC 56789001 6 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0703T07:32

2002-0703T07:32

3 3 30 MINUTES PRIOR

-PT30M STD BREAKFAST 7 56789 EC 56789001 7 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0709T07:30

2002-0709T07:30

9 9 30 MINUTES PRIOR

-PT30M STD BREAKFAST 8 56789 EC 56789001 8 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0709T07:30

2002-0709T07:30

9 9 30 MINUTES PRIOR

-PT30M STD BREAKFAST 9 56789 EC 56789001 9 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0710T07:30

2002-0710T07:30

10 10 30 MINUTES PRIOR

-PT30M STD BREAKFAST 10 56789 EC 56789001 10 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0710T07:30

2002-0710T07:30

10 10 30 MINUTES PRIOR

-PT30M STD BREAKFAST 11 56789 EC 56789001 11 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0711T07:34

2002-0711T07:34

11 11 30 MINUTES PRIOR

-PT30M STD BREAKFAST 12 56789 EC 56789001 12 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0711T07:34

2002-0711T07:34

11 11 30 MINUTES PRIOR

-PT30M STD BREAKFAST 13 56789 EC 56789003 1 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0703T07:30

2002-0703T07:30

1 1 30 MINUTES PRIOR

-PT30M STD BREAKFAST 14 56789 EC 56789003 2 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0703T07:30

2002-0703T07:30

1 1 30 MINUTES PRIOR

-PT30M STD BREAKFAST 15 56789 EC 56789003 3 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0704T07:24

2002-0704T07:24

2 2 30 MINUTES PRIOR

-PT30M STD BREAKFAST 16 56789 EC 56789003 4 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0704T07:24

2002-0704T07:24

2 2 30 MINUTES PRIOR

-PT30M STD BREAKFAST 17 56789 EC 56789003 5 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 1

2002-0705T07:24

2002-0705T07:24

3 3 30 MINUTES PRIOR

-PT30M STD BREAKFAST 18 56789 EC 56789003 6 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 1

2002-0705T07:24

2002-0705T07:24

3 3 30 MINUTES PRIOR

-PT30M STD BREAKFAST 19 56789 EC 56789003 7 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0711T07:30

2002-0711T07:30

9 9 30 MINUTES PRIOR

-PT30M STD BREAKFAST 20 56789 EC 56789003 8 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0711T07:30

2002-0711T07:30

9 9 30 MINUTES PRIOR

-PT30M STD BREAKFAST 21 56789 EC 56789003 9 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0712T07:43

2002-0712T07:43

10 10 30 MINUTES PRIOR

-PT30M STD BREAKFAST 22 56789 EC 56789003 10 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0712T07:43

2002-0712T07:43

10 10 30 MINUTES PRIOR

-PT30M STD BREAKFAST

Row STUDYID DOMAIN USUBJID ECSEQ ECTRT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRM ECDOSFRQ ECROUTE EPOCH ECSTDTC ECENDTC ECSTDY ECENDY ECTPT ECELTM ECTPTREF 23 56789 EC 56789003 11 BOTTLE 1

Y Y 1 CAPSULE CAPSULE QD ORAL TREATMENT 2

2002-0713T07:38

2002-0713T07:38

11 11 30 MINUTES PRIOR

-PT30M STD BREAKFAST 24 56789 EC 56789003 12 BOTTLE 2

Y Y 1 TABLET, COATED

TABLET, COATED

QD ORAL TREATMENT 2

2002-0713T07:38

2002-0713T07:38

11 11 30 MINUTES PRIOR

-PT30M STD BREAKFAST

The EX dataset shows the unblinded administrations.

Rows 1-12: Unblinding revealed that subject 56789001 received placebo-coated tablets during the first treatment epoch and placebo capsules during the second treatment epoch.

Rows 13-24: Unblinding revealed that subject 56789003 received placebo capsules during the first treatment epoch and placebo-coated tablets during the second treatment epoch.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EPOCH EXSTDTC EXENDTC EXSTDY EXENDY EXTPT EXELTM EXTPTREF 1 56789 EX 56789001 1 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 1 2002-07-01T07:30 1 1 30 MINUTES PRIOR -PT30M STD BREAKFAST 2 56789 EX 56789001 2 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-01T07:30 1 1 30 MINUTES PRIOR -PT30M STD BREAKFAST 3 56789 EX 56789001 3 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 1 2002-07-02T07:30 2 2 30 MINUTES PRIOR -PT30M STD BREAKFAST 4 56789 EX 56789001 4 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-02T07:30 2 2 30 MINUTES PRIOR -PT30M STD BREAKFAST 5 56789 EX 56789001 5 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 1 2002-07-03T07:32 3 3 30 MINUTES PRIOR -PT30M STD BREAKFAST 6 56789 EX 56789001 6 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-03T07:32 3 3 30 MINUTES PRIOR -PT30M STD BREAKFAST 7 56789 EX 56789001 7 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 2 2002-07-09T07:30 9 9 30 MINUTES PRIOR -PT30M STD BREAKFAST 8 56789 EX 56789001 8 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-09T07:30 9 9 30 MINUTES PRIOR -PT30M STD BREAKFAST 9 56789 EX 56789001 9 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 2 2002-07-10T07:30 10 10 30 MINUTES PRIOR -PT30M STD BREAKFAST 10 56789 EX 56789001 10 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-10T07:30 10 10 30 MINUTES PRIOR -PT30M STD BREAKFAST 11 56789 EX 56789001 11 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 2 2002-07-11T07:34 11 11 30 MINUTES PRIOR -PT30M STD BREAKFAST 12 56789 EX 56789001 12 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-11T07:34 11 11 30 MINUTES PRIOR -PT30M STD BREAKFAST 13 56789 EX 56789003 1 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 1 2002-07-03T07:30 1 1 30 MINUTES PRIOR -PT30M STD BREAKFAST 14 56789 EX 56789003 2 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-03T07:30 1 1 30 MINUTES PRIOR -PT30M STD BREAKFAST 15 56789 EX 56789003 3 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 1 2002-07-04T07:24 2 2 30 MINUTES PRIOR -PT30M STD BREAKFAST 16 56789 EX 56789003 4 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-04T07:24 2 2 30 MINUTES PRIOR -PT30M STD BREAKFAST 17 56789 EX 56789003 5 PLACEBO 0 mg CAPSULE QD ORAL TREATMENT 1 2002-07-05T07:24 3 3 30 MINUTES PRIOR -PT30M STD BREAKFAST 18 56789 EX 56789003 6 DRUG B 30 mg TABLET, COATED QD ORAL TREATMENT 1 2002-07-05T07:24 3 3 30 MINUTES PRIOR -PT30M STD BREAKFAST 19 56789 EX 56789003 7 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 2 2002-07-11T07:30 9 9 30 MINUTES PRIOR -PT30M STD BREAKFAST 20 56789 EX 56789003 8 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-11T07:30 9 9 30 MINUTES PRIOR -PT30M STD BREAKFAST 21 56789 EX 56789003 9 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 2 2002-07-12T07:43 10 10 30 MINUTES PRIOR -PT30M STD BREAKFAST 22 56789 EX 56789003 10 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-12T07:43 10 10 30 MINUTES PRIOR -PT30M STD BREAKFAST 23 56789 EX 56789003 11 DRUG A 20 mg CAPSULE QD ORAL TREATMENT 2 2002-07-13T07:38 11 11 30 MINUTES PRIOR -PT30M STD BREAKFAST 24 56789 EX 56789003 12 PLACEBO 0 mg TABLET, COATED QD ORAL TREATMENT 2 2002-07-13T07:38 11 11 30 MINUTES PRIOR -PT30M STD BREAKFAST

Example 7

The study in this example involved weekly infusions of drug Z 10 mg/kg. If a subject experienced a dose-limiting toxicity (DLT), the intended dose could be reduced to 7.5 mg/kg.

The example CRF below was for subject ABC123-0201, who weighed 55 kg. The CRF shows that:

• The subject's first administration of drug Z was on 2009-02-13; the intended dose was 10 mg/kg, but the actual amount given was 99 mL at 5.5 mg/mL, so the actual dose was 9.9 mg/kg.

• The subject's second administration of drug Z occurred on 2009-02-20; the intended dose was reduced to 7.5 mg/kg due to dose-limiting toxicity, and the infusion was stopped early due to an injection site reaction. However, the actual amount given was 35 mL at a concentration of 4.12 mg/mL, so the calculated actual dose was 2.6 mg/kg.

• The subject's third administration was intended to occur on 2009-02-27; the intended dose was 7.5 mg/kg but, due to a personal reason, the administration did not occur.

• Treatment discontinued due to disease progression • Other, specify: ________________________

• Yes • No If no, give reason:

• Treatment discontinued due to disease progression • Other, specify: ________________________

• Yes • No If no, give reason:

• Treatment discontinued due to disease progression • Other, specify: Personal reason Date 13-FEB-2009 20-FEB-2009 27-FEB-2009 Start Time (24 hour clock) 10:00 11:00 End Time (24 hour clock) 10:45 11:20 Amount (mL) 99 mL 35 mL 0 mL Concentration 5.5 mg/mL 4.12 mg/mL 4.12 mg/mL If dose was adjusted, what was the reason: • Injection site reaction • Adverse event • Other, specify: ______________________

• Injection site reaction • Adverse event • Other, specify: ____________________

• Injection site reaction • Adverse event • Other, specify: ______________________

The EC dataset shows both intended and actual doses of Drug Z, as collected.

Rows 1, 3, 5: Show the collected intended dose levels (mg/kg) and ECMOOD is "SCHEDULED". Scheduled dose is represented in mg/mL.

Rows 2, 4: Show the collected actual administration amounts (mL) and ECMOOD is "PERFORMED". Actual doses are represented using dose in mL and concentration (pharmaceutical strength) in mg/mL.

Row 6: Shows a dose that was not given. ECREASOC shows the reason that ECOCCUR = "N", and ECDOSE is null.

ec.xpt

Row STUDYID DOMAIN USUBJID ECSEQ ECLNKID ECLNKGRP ECTRT ECMOOD ECPRESP ECOCCUR ECREASOC ECDOSE ECDOSU ECPSTRG ECPSTRGU ECADJ VISITNUM VISIT EPOCH ECSTDTC ECENDTC ECSTDY ECENDY 1 ABC123 EC ABC1230201

1 V1 DRUG Z

SCHEDULED 10 mg/kg 1 VISIT 1

TREATMENT 2009-02-13 1 1

2 ABC123 EC ABC1230201

2 20090213 T1000

V1 DRUG Z

PERFORMED Y Y 99 mL 5.5 mg/mL 1 VISIT 1

TREATMENT 2009-02-

13T10:00

2009-0213T10:45

1 1

3 ABC123 EC ABC1230201

3 V2 DRUG Z

SCHEDULED 7.5 mg/kg Dose limiting toxicity

2 VISIT 2

TREATMENT 2009-02-20 8 8

4 ABC123 EC ABC1230201

4 20090220 T1100

V2 DRUG Z

PERFORMED Y Y 35 mL 4.12 mg/mL 2 VISIT 2

TREATMENT 2009-02-

20T11:00

2009-0220T11:20

8 8

5 ABC123 EC ABC1230201

5 V3 DRUG Z

SCHEDULED 7.5 mg/kg 3 VISIT 3

TREATMENT 2009-02-27 15 15

6 ABC123 EC ABC1230201

6 20090227 V3 DRUG Z

PERFORMED Y N PERSONAL REASON

mL 4.12 mg/mL 3 VISIT 3

TREATMENT 2009-02-27 15 15

The EX dataset shows the administrations in protocol-specified unit (mg/kg). There is no record for the intended third dose that was not given. Intended doses in EC (records with ECMOOD = "SCHEDULED") can be compared with actual doses in EX.

Row 1: Shows the subject's first dose.

Row 2: Shows the subject's second dose. The collected explanation for the adjusted dose amount administered at visit 2 is in EXADJ.

Row STUDYID DOMAIN USUBJID EXSEQ EXLNKID EXLNKGRP EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXADJ VISITNUM VISIT EPOCH EXSTDTC EXENDTC EXSTDY EXENDY 1 ABC123 EX ABC1230201

1 20090213T1000 V1 DRUG Z

9.9 mg/kg SOLUTION CONTINUOUS INTRAVENOUS 1 VISIT 1

TREATMENT 2009-02-

13T10:00

2009-0213T10:00

1 1

2 ABC123 EX ABC1230201

2 20090220T1100 V2 DRUG Z

2.6 mg/kg SOLUTION CONTINUOUS INTRAVENOUS Injection site

reaction

2 VISIT 2

TREATMENT 2009-02-

20T11:00

2009-0220T11:00

8 8

To complete this example the relevant records from the Vital Signs domain are represented below, to show the collected weight of the subject which was used for the dosing calculations.

vs.xpt

Row STUDYID DOMAIN USUBJID VSSEQ VSLNKID VSLNKGRP VSTESTCD VSTEST VSORRES VSORRESU VSSTRESC VSSTRESN VSSTRESU VSLOBXFL VISITNUM VISIT VSDTC EPOCH 1 ABC123 VS ABC123-0201 1 20090213T1000 V1 WEIGHT Weight 55 kg 55 55 kg Y 1 VISIT 1 TREATMENT 2 ABC123 VS ABC123-0201 2 20090220T1100 V2 WEIGHT Weight 55 kg 55 55 kg 2 VISIT 2 TREATMENT

The RELREC dataset represents relationships between EC, EX, and VS.

Rows 1-3: Represent the one-to-one-to-one relationship between "PERFORMED" records in EC, records in EX, and records in VS using --LNKID, .

Rows 4-6: Represent the many-to-one-to-one relationship between many records in EC (both "SCHEDULED" and "PERFORMED"), one record in EX, and one record in VS (for each visit), using --LNKGRP.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC123 EC ECLNKID ONE 1 2 ABC123 EX EXLNKID ONE 1 6 ABC123 VS VSLNKID ONE 1 3 ABC123 EC ECLNKGRP MANY 2 4 ABC123 EX EXLNKGRP ONE 2 6 ABC123 VS VSLNKGRP ONE 2

Example 8

In this example, a 100 mg tablet is scheduled to be taken daily. Start and end of dosing were collected, along with deviations from the planned daily dosing. Note: This method of data collection design is not consistent with current CDASH standards.

First Dose Date Last Dose Date

Date Number of Doses Daily If/When Deviated from Plan 2012-01-15 0 2012-01-16 2

The EC dataset shows administrations as collected.

Row 1: Shows the overall dosing interval from first dose date to last dose date.

Row 2: Shows the missed dose on 2012-01-15, which falls within the overall dosing interval.

Row 3: Shows a doubled dose on 2012-01-16, which also falls within the overall dosing interval.

Row STUDYID DOMAIN USUBJID ECSEQ ECTRT ECCAT ECPRESP ECOCCUR ECDOSE ECDOSU ECDOSFRQ EPOCH ECSTDTC ECENDTC ECSTDY ECENDY 1 ABC EC ABC7001 1 BOTTLE A FIRST TO LAST DOSE INTERVAL Y Y 1 TABLET QD TREATMENT 2012-01-13 2012-01-20 1 8 2 ABC EC ABC7001 2 BOTTLE A EXCEPTION DOSE Y N TABLET QD TREATMENT 2012-01-15 2012-01-15 3 3 3 ABC EC ABC7001 3 BOTTLE A EXCEPTION DOSE Y Y 2 TABLET QD TREATMENT 2012-01-16 2012-01-16 4 4

The EX dataset shows the unmasked treatment for this subject, "DRUG X", and represents dosing in nonoverlapping intervals of time. There is no EX record for the missed dose, but the missed dose is reflected in a gap between dates in the EX records.

Row 1: Shows the administration from first dose date to the day before the missed dose.

Row 2: Shows the doubled dose.

Row 3: Shows the remaining administrations to the last dose date.

ex.xpt

Row STUDYID DOMAIN USUBJID EXSEQ EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EPOCH EXSTDTC EXENDTC EXSTDY EXENDY 1 ABC EX ABC7001 1 DRUG X 100 mg TABLET QD ORAL TREATMENT 2012-01-13 2012-01-14 1 2 2 ABC EX ABC7001 2 DRUG X 200 mg TABLET QD ORAL TREATMENT 2012-01-16 2012-01-16 4 4 3 ABC EX ABC7001 3 DRUG X 100 mg TABLET QD ORAL TREATMENT 2012-01-17 2012-01-20 5 8

## Meal Data (ML)

*Structure: One record per food product occurrence or constant intake interval per subject, Tabulation.*

An interventions domain that contains information describing a subject's food product consumption.

### ML Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | ML | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| MLSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| MLGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| MLSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. Examples: a number preprinted on the CRF as an explicit line identifier, record identifier defined in the sponsor's operational database. | Perm |
| MLTRT | Name of Meal | Char | * | Topic | Verbatim food product name that is either preprinted or collected on a CRF. | Req |

### ML Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MLCAT | Category for Meal | Char | * | Grouping Qualifier | Used to define a category of MLTRT values. | Perm |
| MLSCAT | Subcategory for Meal | Char | * | Grouping Qualifier | Used to define a further categorization of MLCAT values. | Perm |
| MLPRESP | ML Pre-specified | Char | (NY) | Variable Qualifier | Used when a specific meal is prespecified on a CRF. Values should be "Y" or null. | Perm |
| MLOCCUR | ML Occurrence | Char | (NY) | Record Qualifier | Used to record whether a prespecified meal occurred when information about the occurrence of a specific meal is solicited. | Perm |
| MLSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate when a question about the occurrence of a prespecified meal was not answered. Should be null or have a value of "NOT DONE". | Perm |

### ML Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MLREASND | Reason Meal Not Collected | Char |  | Record Qualifier | Describes the reason a response to a question about the occurrence of a meal was not collected. Used in conjunction with MLSTAT when value is "NOT DONE". | Perm |
| MLDOSE | Dose | Num |  | Record Qualifier | Amount of MLTRT consumed. Not populated when MLDOSTXT is populated. | Perm |
| MLDOSTXT | Dose Description | Char |  | Record Qualifier | Amount description of MLTRT consumed, collected in text form. Not populated when MLDOSE is populated. Examples: "<1 per day", "200-400". | Perm |
| MLDOSU | Dose Units | Char | (UNIT) | Variable Qualifier | Units for MLDOSE, MLDOSTOT, or MLDOSTXT. | Perm |
| MLDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dosage form for MLTRT. Example: "BAR, CHEWABLE". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |

### ML Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the meal started. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the meal. | Perm |
| MLDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the meal represented in ISO 8601 character format. | Perm |
| MLSTDTC | Start Date/Time of Meal | Char | ISO 8601 datetime or interval | Timing | Start date/time of the meal represented in ISO 8601 character format. | Perm |
| MLENDTC | End Date/Time of Meal | Char | ISO 8601 datetime or interval | Timing | End date/time of the meal represented in ISO 8601 character format. | Perm |

### ML Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MLDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of the visit/collection expressed in integer days relative to the sponsor- defined RFSTDTC in Demographics. | Perm |
| MLSTDY | Study Day of Start of Meal | Num |  | Timing | Actual study day of start of the meal expressed in integer days relative to sponsor-defined RFSTDTC in Demographics. | Perm |
| MLENDY | Study Day of End of Meal | Num |  | Timing | Actual study day of end of the meal expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| MLDUR | Duration of Meal | Char | ISO 8601 duration | Timing | Collected duration of the meal represented in ISO 8601 character format. Used only if collected on the CRF and not derived. | Perm |

### ML Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MLTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point. See MLTPTNUM and MLTPTREF. | Perm |
| MLTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |
| MLELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to the planned fixed reference (MLTPTREF). This variable is useful when there are repetitive measures. Not a clock time or a date/time variable. Represented as an ISO 8601 duration. | Perm |
| MLTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by MLELTM, MLTPTNUM, and MLTPT. | Perm |

### ML Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MLRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by MLTPTREF in ISO 8601 character format. | Perm |
| MIDS | Disease Milestone Instance Name | Char |  | Timing | The name of a specific instance of a disease milestone type (MIDSTYPE) described in the Trial Disease Milestones dataset. This should be unique within a subject. Used only in conjunction with RELMIDS and MIDSDTC. | Perm |
| RELMIDS | Temporal Relation to Milestone Instance | Char |  | Timing | The temporal relationship of the observation to the disease milestone instance name in MIDS. Examples: "IMMEDIATELY BEFORE", "AT TIME OF", "AFTER". | Perm |
| MIDSDTC | Disease Milestone Instance Date/Time | Char | ISO 8601 datetime or interval | Timing | The start date/time of the disease milestone instance name in MIDS, in ISO 8601 format. | Perm |

### ML Assumptions

1. The ML domain is used to represent consumption of any food or nutritional item that would not be represented in the exposure domains (EC/EX),

Concomitant/Prior Medications (CM), Procedure Agents (AG), or Substance Use (SU). Examples of nutritional items that would be represented in other domains include:

a. Investigational nutritional products (represented in EC/EX)

b. Food or drink used to treat hypoglycemic events (represented in CM)

c. Glucose given as part of a glucose tolerance test (represented in AG)

d. Caffeinated drinks (represented in SU)

The nutritional items represented in ML may be prospectively defined within a protocol, collected retrospectively as potential precipitants of clinical events, and/or to describe nutritional intake.

2. Additional timing variables

## Procedures (PR)

*Structure: One record per recorded procedure per occurrence per subject, Tabulation.*

An interventions domain that contains interventional activity intended to have diagnostic, preventive, therapeutic, or palliative effects.

### PR Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | PR | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| PRSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| PRGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. | Perm |
| PRSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. Example: preprinted line identifier on a CRF, record identifier defined in the sponsor's operational database. | Perm |
| PRLNKID | Link ID | Char |  | Identifier | Used to facilitate identification of relationships between records. | Perm |
| PRLNKGRP | Link Group ID | Char |  | Identifier | Used to facilitate identification of relationships between records. | Perm |

### PR Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PRTRT | Reported Name of Procedure | Char |  | Topic | Name of procedure performed, either preprinted or collected on a CRF. | Req |
| PRDECOD | Standardized Procedure Name | Char | (PROCEDUR) | Synonym Qualifier | Standardized or dictionary-derived name of PRTRT. If the codelist "PROCEDUR" is not used, the sponsor is expected to provide the dictionary name and version used to map the terms in the external codelist element in the Define-XML document. If an intervention term does not have a decode value, then PRDECOD will be null. | Perm |
| PRCAT | Category | Char | * | Grouping Qualifier | Used to define a category of procedure values. | Perm |
| PRSCAT | Subcategory | Char | * | Grouping Qualifier | Used to define a further categorization of PRCAT values. | Perm |
| PRPRESP | Pre-specified | Char | (NY) | Variable Qualifier | Used when a specific procedure is pre-specified on a CRF. Values should be "Y" or null. | Perm |

### PR Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PROCCUR | Occurrence | Char | (NY) | Record Qualifier | Used to record whether a prespecified procedure occurred when information about the occurrence of a specific procedure is solicited. | Perm |
| PRINDC | Indication | Char |  | Record Qualifier | Denotes the indication for the procedure (e.g., why the procedure was performed). | Perm |
| PRDOSE | Dose | Num |  | Record Qualifier | Amount of PRTRT administered. Not populated when PRDOSTXT is populated. | Perm |
| PRDOSTXT | Dose Description | Char |  | Record Qualifier | Dosing information collected in text form. Examples: "<1", "200-400". Not populated when PRDOSE is populated. | Perm |
| PRDOSU | Dose Units | Char | (UNIT) | Variable Qualifier | Units for PRDOSE, PRDOSTOT, or PRDOSTXT. | Perm |
| PRDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dose form for PRTRT. | Perm |
| PRDOSFRQ | Dosing Frequency per Interval | Char | (FREQ) | Record Qualifier | Usually expressed as the number of doses given per a specific interval. | Perm |
| PRDOSRGM | Intended Dose Regimen | Char |  | Record Qualifier | Text description of the intended schedule or regimen for the procedure. | Perm |

### PR Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PRROUTE | Route of Administration | Char | (ROUTE) | Variable Qualifier | Route of administration for PRTRT. | Perm |
| PRLOC | Location of Procedure | Char | (LOC) | Record Qualifier | Anatomical location of a procedure. | Perm |
| PRLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. | Perm |
| PRDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. | Perm |
| PRPORTOT | Portion or Totality | Char | (PORTOT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing the distribution, which means arrangement of, apportioning of. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |

### PR Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the procedure. | Perm |
| PRSTDTC | Start Date/Time of Procedure | Char | ISO 8601 datetime or interval | Timing | Start date/time of the procedure represented in ISO 8601 character format. | Exp |
| PRENDTC | End Date/Time of Procedure | Char | ISO 8601 datetime or interval | Timing | End date/time of the procedure represented in ISO 8601 character format. | Perm |
| PRSTDY | Study Day of Start of Procedure | Num |  | Timing | Study day of start of procedure expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| PRENDY | Study Day of End of Procedure | Num |  | Timing | Study day of end of procedure expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### PR Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PRDUR | Duration of Procedure | Char | ISO 8601 duration | Timing | Collected duration of a procedure represented in ISO 8601 character format. Used only if collected on the CRF and not derived from start and end date/times. | Perm |
| PRTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a procedure should be performed. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See PRTPTNUM and PRTPTREF. | Perm |
| PRTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of planned time point used in sorting. | Perm |
| PRELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time in ISO 8601 format relative to a planned fixed reference (PRTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |

### PR Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PRTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by PRELTM, PRTPTNUM, and PRTPT. | Perm |
| PRRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by PRTRTREF in ISO 8601 character format. | Perm |
| PRSTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the observation as being before or after the sponsor-defined reference time point defined by variable PRSTTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| PRSTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by PRSTRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |

### PR Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PRENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the observation as being before or after the sponsor-defined reference time point defined by variable PRENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| PRENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by PRENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### PR Assumptions

1. Some examples of procedures, by type, include the following:

a. Disease screening (e.g., mammogram, pap smear)

b. Endoscopic examinations (e.g., arthroscopy, diagnostic colonoscopy, therapeutic colonoscopy, diagnostic laparoscopy, therapeutic laparoscopy)

c. Diagnostic tests (e.g., amniocentesis, biopsy, catheterization, cutaneous oximetry, finger stick, fluorophotometry, imaging techniques (e.g., DXA scan, CT scan, MRI), phlebotomy, pulmonary function test, skin test, stress test, tympanometry)

d. Therapeutic procedures (e.g., ablation therapy, catheterization, cryotherapy, mechanical ventilation, phototherapy, radiation therapy/radiotherapy,

thermotherapy)

e. Surgical procedures (e.g., curative surgery, diagnostic surgery, palliative surgery, therapeutic surgery, prophylactic surgery, resection, stenting, hysterectomy, tubal ligation, implantation)

The Procedures domain is based on the Interventions observation class. The extent of physiological effect may range from observable to microscopic. Regardless of the extent of effect or whether it is collected in the study, all collected procedures are represented in this domain. The protocol design should specify whether procedure information will be collected.Measurements obtained from procedures are to be represented in their respective Findings domain(s). For example, a biopsy may be performed to obtain a tissue sample that is then evaluated histopathologically. In this case, details of the biopsy procedure can be represented in the PR domain and the histopathology findings in the Microscopic Findings (MI) domain. Describing the relationship between PR and MI records (in RELREC) in this example is dependent on whether the relationship is collected, either explicitly or implicitly.

2. In the Findings Observation Class, the test method is represented in the --METHOD variable (e.g., electrophoresis, gram stain, polymerase chain

reaction). At times, the test method overlaps with diagnostic/therapeutic procedures (e.g., ultrasound, MRI, x-ray) in-scope for the PR domain. The following is recommended: If timing (start, end or duration) or an indicator populating PROCCUR, PRSTAT, or PRREASND is collected, then a PR record should be created. If only the findings from a procedure are collected, then --METHOD in the Findings domain(s) may be sufficient to reflect the procedure and a related PR record is optional. It is at the sponsor’s discretion whether to represent the procedure as both a test method (--METHOD) and related PR record.

3. PRINDC is used to represent a medical indication, a medical condition which makes a treatment advisable. The reason for a procedure may be

something other than a medical indication. For example, an x-ray might be taken to determine whether a fracture was present. Reasons other than medical indications should be represented using the supplemental qualifier PRREAS (see Appendix C1, Supplemental Qualifiers Name Codes).

4. Any identifier variables, timing variables, or interventions general observation-class qualifiers may be added to the PR domain, but the following

qualifiers would generally not be used: --MOOD, --LOT.

## Substance Use (SU)

*Structure: One record per substance type per reported occurrence per subject, Tabulation.*

An interventions domain that contains substance use information that may be used to assess the efficacy and/or safety of therapies that look to mitigate the effects of chronic substance use.

### SU Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SU | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SUSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| SUGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| SUSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a Tobacco & Alcohol Use CRF page. | Perm |
| SUTRT | Reported Name of Substance | Char |  | Topic | Substance name. Examples: "CIGARETTES", "COFFEE". | Req |

### SU Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUMODIFY | Modified Substance Name | Char |  | Synonym Qualifier | If SUTRT is modified, then the modified text is placed here. | Perm |
| SUDECOD | Standardized Substance Name | Char | * | Synonym Qualifier | Standardized or dictionary-derived text description of SUTRT or SUMODIFY if the sponsor chooses to code the substance use. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document. | Perm |
| SUCAT | Category for Substance Use | Char | * | Grouping Qualifier | Used to define a category of related records. Examples: "TOBACCO", "ALCOHOL", or "CAFFEINE". | Perm |
| SUSCAT | Subcategory for Substance Use | Char | * | Grouping Qualifier | A further categorization of substance use. Examples: "CIGARS", "CIGARETTES", "BEER", "WINE". | Perm |
| SUPRESP | SU Pre-Specified | Char | (NY) | Variable Qualifier | Used to indicate whether ("Y"/null) information about the use of a specific substance was solicited on the CRF. | Perm |

### SU Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUOCCUR | SU Occurrence | Char | (NY) | Record Qualifier | When the use of specific substances is solicited, SUOCCUR is used to indicate whether ("Y"/"N") a particular prespecified substance was used. Values are null for substances not specifically solicited. | Perm |
| SUSTAT | Completion Status | Char | (ND) | Record Qualifier | When the use of prespecified substances is solicited, the completion status indicates that there was no response to the question about the prespecified substance. When there is no prespecified list on the CRF, then the completion status indicates that substance use was not assessed for the subject. | Perm |
| SUREASND | Reason Substance Use Not Collected | Char |  | Record Qualifier | Describes the reason substance use was not collected. Used in conjunction with SUSTAT when value of SUSTAT is "NOT DONE". | Perm |

### SU Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUCLAS | Substance Use Class | Char | * | Variable Qualifier | Substance use class. May be obtained from coding. When coding to a single class, populate with class value. If using a dictionary and coding to multiple classes, then follow Section 4.2.8.3, Multiple Values for a Non-result Qualifier Variable, or omit SUCLAS. | Perm |
| SUCLASCD | Substance Use Class Code | Char | * | Variable Qualifier | Code corresponding to SUCLAS. May be obtained from coding. | Perm |
| SUDOSE | Substance Use Consumption | Num |  | Record Qualifier | Amount of SUTRT consumed. Not populated if SUDOSTXT is populated. | Perm |
| SUDOSTXT | Substance Use Consumption Text | Char |  | Record Qualifier | Substance use consumption amounts or a range of consumption information collected in text form. Not populated if SUDOSE is populated. | Perm |
| SUDOSU | Consumption Units | Char | (UNIT) | Variable Qualifier | Units for SUDOSE, SUDOSTOT, or SUDOSTXT. Examples: "oz", "CIGARETTE", "PACK", "g". | Perm |

### SU Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUDOSFRM | Dose Form | Char | (FRM) | Variable Qualifier | Dose form for SUTRT. Examples: "INJECTABLE", "LIQUID", "POWDER". | Perm |
| SUDOSFRQ | Use Frequency Per Interval | Char | (FREQ) | Variable Qualifier | Usually expressed as the number of repeated administrations of SUDOSE within a specific time period. Example: "Q24H" (every day). | Perm |
| SUDOSTOT | Total Daily Consumption | Num |  | Record Qualifier | Total daily use of SUTRT using the units in SUDOSU. Used when dosing is collected as total daily dose. If a sponsor needs to aggregate the data over a period other than daily, then the aggregated total could be recorded in a supplemental qualifier variable. | Perm |
| SUROUTE | Route of Administration | Char | (ROUTE) | Variable Qualifier | Route of administration for SUTRT. Examples: "ORAL", "INTRAVENOUS". | Perm |

### SU Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the substance use started. Null for substances that started before study participation. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the substance use. Null for substances that started before study participation. | Perm |
| SUSTDTC | Start Date/Time of Substance Use | Char | ISO 8601 datetime or interval | Timing | Start date/time of the substance use represented in ISO 8601 character format. | Perm |
| SUENDTC | End Date/Time of Substance Use | Char | ISO 8601 datetime or interval | Timing | End date/time of the substance use represented in ISO 8601 character format. | Perm |
| SUSTDY | Study Day of Start of Substance Use | Num |  | Timing | Study day of start of substance use relative to the sponsor-defined RFSTDTC. | Perm |

### SU Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUENDY | Study Day of End of Substance Use | Num |  | Timing | Study day of end of substance use relative to the sponsor-defined RFSTDTC. | Perm |
| SUDUR | Duration of Substance Use | Char | ISO 8601 duration | Timing | Collected duration of substance use in ISO 8601 format. Used only if collected on the CRF and not derived from start and end date/times. | Perm |
| SUSTRF | Start Relative to Reference Period | Char | (STENRF) | Timing | Describes the start of the substance use relative to the sponsor-defined reference period. The sponsor- defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). If information such as "PRIOR" was collected, this information may be translated into SUSTRF. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### SU Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUENRF | End Relative to Reference Period | Char | (STENRF) | Timing | Describes the end of the substance use with relative to the sponsor-defined reference period. The sponsor- defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). If information such as "PRIOR", "ONGOING", or "CONTINUING" was collected, this information may be translated into SUENRF. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| SUSTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the substance as being before or after the reference time point defined by variable SUSTTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7 , Use of Relative Timing Variables. | Perm |

### SU Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SUSTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by SUSTRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |
| SUENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the substance as being before or after the reference time point defined by variable SUENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7 , Use of Relative Timing Variables. | Perm |
| SUENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by SUENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### SU Assumptions

1. Substance use information may be independent of planned study evaluations, or may be a key outcome (e.g., planned evaluation) of a clinical trial.

a. In many clinical trials, detailed substance use information as provided for in the domain model above may not be required (e.g., the only information collected may be a response to the question “Have you ever smoked tobacco?”); in such cases, many of the qualifier variables would not be submitted.

b. SU may contain responses to questions about use of prespecified substances as well as records of substance use collected as free text.

2. SU description and coding

a. SUTRT captures the verbatim or the prespecified text collected for the substance. It is the topic variable for the SU dataset. SUTRT is a required variable and must have a value.

b. SUMODIFY is a permissible variable and should be included if coding is performed and the sponsor’s procedure permits modification of a

verbatim substance use term for coding. The modified term is listed in SUMODIFY. The variable may be populated as per the sponsor’s procedures.

c. SUDECOD is the preferred term derived by the sponsor from the coding dictionary if coding is performed. It is a permissible variable. Where deemed necessary by the sponsor, the verbatim term (SUTRT) should be coded using a standard dictionary such as WHO Drug. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document.

3. Additional categorization and grouping

a. SUCAT and SUSCAT should not be redundant with the domain code or dictionary classification provided by SUDECOD, or with SUTRT. That is, they should provide a different means of defining or classifying SU records. For example, a sponsor may be interested in identifying all substances that the investigator feels might represent opium use, and to collect such use on a separate CRF page. This categorization might differ from the categorization derived from the coding dictionary.

b. SUGRPID may be used to link (or associate) different records together to form a block of related records within SU at the subject level (see Section

4.2.6, Grouping Variables and Categorization). It should not be used in place of SUCAT or SUSCAT.

4. Timing variables

a. SUSTDTC and SUENDTC may be populated as required.

b. If substance use information is collected more than once within the CRF (indicating that the data are visit-based) then VISITNUM would be added

to the domain as an additional timing variable. VISITDY and VISIT would then be permissible variables.

## Adverse Events (AE)

*Structure: One record per adverse event per subject, Tabulation.*

An events domain that contains data describing untoward medical occurrences in a patient or subjects that are administered a pharmaceutical product and which may not necessarily have a causal relationship with the treatment.

### AE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | AE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | A sequence of characters used by the sponsor to uniquely identify a specific device. Used to represent a device associated in some way with the adverse event. SPDEVID values are defined in the Device Identifiers (DI) domain. | Perm |
| AESEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| AEGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |

### AE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEREFID | Reference ID | Char |  | Identifier | Internal or external identifier such as a serial number on an SAE reporting form. | Perm |
| AESPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. It may be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on an Adverse Events CRF page. | Perm |
| AETERM | Reported Term for the Adverse Event | Char |  | Topic | Verbatim name of the event. | Req |
| AEMODIFY | Modified Reported Term | Char |  | Synonym Qualifier | If AETERM is modified to facilitate coding, then AEMODIFY will contain the modified text. | Perm |
| AELLT | Lowest Level Term | Char | MedDRA | Variable Qualifier | Dictionary-derived text description of the lowest level term. | Exp |
| AELLTCD | Lowest Level Term Code | Num | MedDRA | Variable Qualifier | Dictionary-derived code for the lowest level term. | Exp |

### AE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEDECOD | Dictionary-Derived Term | Char | MedDRA | Synonym Qualifier | Dictionary-derived text description of AETERM or AEMODIFY. Equivalent to the Preferred Term (PT in MedDRA). The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document. | Req |
| AEPTCD | Preferred Term Code | Num | MedDRA | Variable Qualifier | Dictionary-derived code for the preferred term. | Exp |
| AEHLT | High Level Term | Char | MedDRA | Variable Qualifier | Dictionary-derived text description of the high level term for the primary system organ class (SOC). | Exp |
| AEHLTCD | High Level Term Code | Num | MedDRA | Variable Qualifier | Dictionary-derived code for the high level term for the primary SOC. | Exp |
| AEHLGT | High Level Group Term | Char | MedDRA | Variable Qualifier | Dictionary-derived text description of the high level group term for the primary SOC. | Exp |

### AE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEHLGTCD | High Level Group Term Code | Num | MedDRA | Variable Qualifier | Dictionary-derived code for the high level group term for the primary SOC. | Exp |
| AECAT | Category for Adverse Event | Char | * | Grouping Qualifier | Used to define a category of related records. Examples: "BLEEDING", "NEUROPSYCHIATRIC". | Perm |
| AESCAT | Subcategory for Adverse Event | Char | * | Grouping Qualifier | A further categorization of adverse event. Example: "NEUROLOGIC". | Perm |
| AEPRESP | Pre-Specified Adverse Event | Char | (NY) | Variable Qualifier | A value of "Y" indicates that this adverse event was prespecified on the CRF. Values are null for spontaneously reported events (i.e., those collected as free-text verbatim terms). | Perm |

### AE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEBODSYS | Body System or Organ Class | Char | * | Record Qualifier | Dictionary derived. Body system or organ class used by the sponsor from the coding dictionary (e.g., MedDRA). When using a multi-axial dictionary such as MedDRA, this should contain the SOC used for the sponsor's analyses and summary tables, which may not necessarily be the primary SOC. | Exp |
| AEBDSYCD | Body System or Organ Class Code | Num | MedDRA | Variable Qualifier | Dictionary derived. Code for the body system or organ class used by the sponsor. When using a multi- axial dictionary such as MedDRA, this should contain the SOC used for the sponsor's analyses and summary tables, which may not necessarily be the primary SOC. | Exp |
| AESOC | Primary System Organ Class | Char | MedDRA | Variable Qualifier | Dictionary-derived text description of the primary SOC. Will be the same as AEBODSYS if the primary SOC was used for analysis. | Exp |

### AE Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AESOCCD | Primary System Organ Class Code | Num | MedDRA | Variable Qualifier | Dictionary-derived code for the primary SOC. Will be the same as AEBDSYCD if the primary SOC was used for analysis. | Exp |
| AELOC | Location of Event | Char | (LOC) | Record Qualifier | Describes anatomical location relevant for the event (e.g., "ARM" for skin rash). | Perm |
| AESEV | Severity/Intensity | Char | (AESEV) | Record Qualifier | The severity or intensity of the event. Examples: "MILD", "MODERATE", "SEVERE". | Perm |
| AESER | Serious Event | Char | (NY) | Record Qualifier | Is this a serious event? Valid values are "Y" and "N". | Exp |

### AE Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEACN | Action Taken with Study Treatment | Char | (ACN) | Record Qualifier | Describes changes to the study treatment as a result of the event. AEACN is specifically for the relationship to study treatment. AEACNOTH is for actions unrelated to dose adjustments of study treatment. Examples of AEACN values include ICH E2B values: "DRUG WITHDRAWN", "DOSE REDUCED", "DOSE INCREASED", "DOSE NOT CHANGED", "UNKNOWN" and "NOT APPLICABLE". | Exp |
| AEACNOTH | Other Action Taken | Char |  | Record Qualifier | Describes other actions taken as a result of the event that are unrelated to dose adjustments of study treatment. Usually reported as free text. Example: "TREATMENT UNBLINDED. PRIMARY CARE PHYSICIAN NOTIFIED". | Perm |
| AEACNDEV | Action Taken with Device | Char | (DEACNDEV) | Record Qualifier | An action taken with a device as the result of the event. The device may or may not be a device under study. | Perm |

### AE Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEREL | Causality | Char | * | Record Qualifier | Records the investigator's opinion as to the causality of the event to the treatment. ICH does not establish any required or recommended terms for non-device relatedness. ICH E2A and E2B examples include (up-cased here for alignment to SDTM conventions) terms such as "NOT RELATED", "UNLIKELY RELATED", "POSSIBLY RELATED", "RELATED", but these example terms do not establish any conventions or expectations. Controlled terminology may be defined in the future. Check with regulatory authority for population of this variable. | Exp |

### AE Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AERLDEV | Relationship of Event to Device | Char | * | Record Qualifier | A judgment as to the likelihood that the device caused the adverse event. The relationship is to a device identified in the data (i.e., has an SPDEVID). The device may be ancillary or under study. Terminology: • In the EU, follow the European Commission Guidelines on Medical Devices, Clinical Investigations: SAE Reporting (MEDDEV 2.7/3) (e.g., Not Related, Unlikely, Possible, Probable, Causal Relationship), with device-specific definitions. • No required Controlled Terminology in US. | Perm |
| AERELNST | Relationship to Non- Study Treatment | Char |  | Record Qualifier | Records the investigator's opinion as to whether the event may have been due to a treatment other than study drug. May be reported as free text. Example: "MORE LIKELY RELATED TO ASPIRIN USE". | Perm |

### AE Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEPATT | Pattern of Adverse Event | Char | * | Record Qualifier | Used to indicate the pattern of the event over time. Examples: "INTERMITTENT", "CONTINUOUS", "SINGLE EVENT". | Perm |
| AEOUT | Outcome of Adverse Event | Char | (OUT) | Record Qualifier | Description of the outcome of an event. | Perm |
| AESCAN | Involves Cancer | Char | (NY) | Record Qualifier | Was the serious event associated with the development of cancer? Valid values are "Y" and "N". This is a legacy seriousness criterion. It is not included in ICH E2A or E2B. | Perm |
| AESCONG | Congenital Anomaly or Birth Defect | Char | (NY) | Record Qualifier | Was the serious event associated with congenital anomaly or birth defect? Valid values are "Y" and "N". | Perm |
| AESDISAB | Persist or Signif Disability/Incapacity | Char | (NY) | Record Qualifier | Did the serious event result in persistent or significant disability/incapacity? Valid values are "Y" and "N". | Perm |

### AE Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AESDTH | Results in Death | Char | (NY) | Record Qualifier | Did the serious event result in death? Valid values are "Y" and "N". | Perm |
| AESHOSP | Requires or Prolongs Hospitalization | Char | (NY) | Record Qualifier | Did the serious event require or prolong hospitalization? Valid values are "Y" and "N". | Perm |
| AESLIFE | Is Life Threatening | Char | (NY) | Record Qualifier | Was the serious event life-threatening? Valid values are "Y" and "N". | Perm |
| AESOD | Occurred with Overdose | Char | (NY) | Record Qualifier | Did the serious event occur with an overdose? Valid values are "Y" and "N". This is a legacy seriousness criterion. It is not included in ICH E2A or E2B. | Perm |
| AESMIE | Other Medically Important Serious Event | Char | (NY) | Record Qualifier | Do additional categories for seriousness apply? Valid values are "Y" and "N". | Perm |

### AE Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AESINTV | Needs Intervention to Prevent Impairment | Char | (NY) | Record Qualifier | Records whether medical or surgical intervention was necessary to preclude permanent impairment of a body function, or to prevent permanent damage to a body structure, with either situation suspected to be due to the use of a medical product. This variable is used in conjunction with the other "seriousness" variables (e.g., fatal, life-threatening). It is part of the US federal government definition of a serious adverse event; see 21 CFR Part 803.3(w)(3). | Perm |

### AE Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEUNANT | Unanticipated Adverse Device Effect | Char | (NY) | Record Qualifier | Any serious adverse effect on health or safety or any life-threatening problem or death caused by or associated with a device, if that effect, problem, or death was not previously identified in nature, severity, or degree of incidence in the investigational plan or application (including a supplementary plan or application), or any other unanticipated serious problem associated with a device that relates to the rights, safety, or welfare of subjects. (21 CFR Part 812.3(s)). This variable applies only to serious AEs and should hold collected data; if the value is derived, it should be held in ADaM. | Perm |

### AE Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AERLPRT | Rel of AE to Non-Dev- Rel Study Activity | Char | * | Record Qualifier | The investigator's opinion as to the causality of the event as related to other protocol-required activities, actions, or assessments (e.g., medication changes, tests/assessments, other procedures). The relationship is to a protocol-specified, non-device-related activity where the device is identified in the data (i.e., has an SPDEVID). The device may be ancillary or under study. Terminology: • In the EU, follow the European Commission Guidelines on Medical Devices, Clinical Investigations: SAE Reporting (MEDDEV 2.7/3) (e.g., Not Related, Unlikely, Possible, Probable, Causal Relationship), with device-specific definitions. • No required Controlled Terminology in US. | Perm |

### AE Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AERLPRC | Rel of AE to Device- Related Procedure | Char | * | Record Qualifier | The investigator's opinion as to the likelihood that the device-related study procedure (e.g., implant/insertion, revision/adjustment, explant/removal) caused the AE. The relationship is to a device- related procedure where the device is identified in the data (i.e., has an SPDEVID). The device may be ancillary or under study. Terminology: • In the EU, follow the European Commission Guidelines on Medical Devices, Clinical Investigations: SAE Reporting (MEDDEV 2.7/3) (e.g., Not Related, Unlikely, Possible, Probable, Causal Relationship), with device-specific definitions. • No required Controlled Terminology in US. | Perm |
| AECONTRT | Concomitant or Additional Trtmnt Given | Char | (NY) | Record Qualifier | Was another treatment given because of the occurrence of the event? Valid values are "Y" and "N". | Perm |

### AE Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AETOXGR | Standard Toxicity Grade | Char | * | Record Qualifier | Toxicity grade according to a standard toxicity scale (e.g., Common Terminology Criteria for Adverse Events, CTCAE). Sponsors should specify the name of the scale and version used in the metadata (see assumption 7d). If value is from a numeric scale, represent only the number (e.g., "2", not "Grade 2"). | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the adverse event. Examples: "SCREENING", "TREATMENT", "FOLLOW-UP". | Perm |
| AESTDTC | Start Date/Time of Adverse Event | Char | ISO 8601 datetime or interval | Timing | Start date/time of the adverse event represented in ISO 8601 character format. | Exp |

### AE Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEENDTC | End Date/Time of Adverse Event | Char | ISO 8601 datetime or interval | Timing | End date/time of the adverse event represented in ISO 8601 character format. | Exp |
| AESTDY | Study Day of Start of Adverse Event | Num |  | Timing | Study day of start of adverse event relative to the sponsor-defined RFSTDTC. | Perm |
| AEENDY | Study Day of End of Adverse Event | Num |  | Timing | Study day of end of event relative to the sponsor-defined RFSTDTC. | Perm |
| AEDUR | Duration of Adverse Event | Char | ISO 8601 duration | Timing | Collected duration and unit of an adverse event. Used only if collected on the CRF and not derived from start and end date/times. Example: "P1DT2H" (for 1 day, 2 hours). | Perm |

### AE Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| AEENRF | End Relative to Reference Period | Char | (STENRF) | Timing | Describes the end of the event relative to the sponsor-defined reference period. The sponsor-defined reference period is a continuous period of time defined by a discrete starting point (RFSTDTC) and a discrete ending point (RFENDTC) of the trial. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| AEENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the event as being before or after the reference time point defined by variable AEENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| AEENTPT | End Reference Time Point | Char |  | Timing | Description of date/time in ISO 8601 character format of the reference point referred to by AEENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### AE Assumptions

1. The Adverse Events dataset includes clinical data describing "any untoward medical occurrence in a patient or clinical investigation subject

administered a pharmaceutical product and which does not necessarily have to have a causal relationship with this treatment" (ICH E2A). In consultation with regulatory authorities, sponsors may extend or limit the scope of adverse event collection (e.g., collecting pre-treatment events related to trial conduct, not collecting events that are assessed as efficacy endpoints). The events included in the AE dataset should be consistent with the protocol requirements. Adverse events may be captured either as free text or via a prespecified list of terms.

2. AE description and coding

a. AETERM captures the verbatim term collected for the event. It is the topic variable for the AE dataset. AETERM is a required variable and must have a value.

b. AEMODIFY is a permissible variable and should be included if the sponsor’s procedure permits modification of a verbatim term for coding. The

modified term is listed in AEMODIFY. The variable should be populated as per the sponsor’s procedures.

c. AEDECOD is the preferred term derived by the sponsor from the coding dictionary. It is a required variable and must have a value. It is expected that the reported term (AETERM) will be coded using a standard dictionary such as MedDRA. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document.

from the primary SOC designated in the coding dictionary's standard hierarchy. It is expected that this variable will be populated.

3. Additional categorization and grouping

a. AECAT and AESCAT should not be redundant with the domain code or dictionary classification provided by AEDECOD and AEBODSYS (i.e., they should provide a different means of defining or classifying AE records). AECAT and AESCAT are intended for categorizations that are defined in advance. For example, a sponsor may have a CRF page for AEs of special interest and another page for all other AEs. AECAT and AESCAT should not be used for after-the-fact categorizations such as "clinically significant." In cases where a category of AEs of special interest resembles a part of the dictionary hierarchy (e.g., "CARDIAC EVENTS"), the categorization represented by AECAT and AESCAT may differ from the categorization derived from the coding dictionary.

b. AEGRPID may be used to link (or associate) different records together to form a block of related records at the subject level within the AE domain;

see Section 4.2.6, Grouping Variables and Categorization.

4. Prespecified terms; presence or absence of events

a. Adverse events are generally collected in 2 different ways, either by recording free text or using a prespecified list of terms. In the latter case, the solicitation of information on specific adverse events may affect the frequency at which they are reported; therefore, the fact that a specific adverse event was solicited may be of interest to reviewers. An AEPRESP value of “Y” is used to indicate that the event in AETERM was prespecified on the CRF.

b. If it is important to know which adverse events from a prespecified list were not reported as well as those that did occur, these data should be

submitted in a Findings class dataset such as Findings About Events and Interventions (see Section 6.4, Findings About Events or Interventions). A record should be included in that Findings dataset for each prespecified adverse-event term. Records for adverse events that actually occurred should also exist in the AE dataset with AEPRESP set to “Y.”

c. If a study collects both prespecified adverse events and free-text events, the value of AEPRESP should be “Y” for all prespecified events and null for events reported as free text. AEPRESP is a permissible field and may be omitted from the dataset if all adverse events were collected as free text.

d. When adverse events are collected with the recording of free text, a record may be entered into the sponsor’s data management system to indicate

“no adverse events” for a specific subject. For these subjects, do not include a record in the AE submission dataset to indicate that there were no events. Records should be included in the submission AE dataset only for adverse events that have actually occurred.

5. Timing variables

a. Relative timing assessment “Ongoing” is common in the collection of AE information. AEENRF may be used when this relative timing assessment is made coincident with the end of the study reference period for the subject represented in the Demographics (DM) dataset (RFENDTC). AEENRTPT with AEENTPT may be used when "Ongoing" is relative to another date (e.g., the final safety follow-up visit date). See Section 4.4.7, Use of Relative Timing Variables.

b. Additional timing variables (e.g., AEDTC) may be used when appropriate.

6. Actions taken

b. Actions other than concomitant treatments are recorded in:

▪ AEACN, only for actions taken with study treatment

▪ AEACNDEV, for actions with a device

▪ AEACNOTH, for actions that do not involve treatment or a device

7. Other qualifier variables

a. If categories of serious events are collected secondarily to a leading question the values of the variables that capture reasons an event is considered serious (e.g., AESCAN, AESCONG) may be null:

For example, if "Serious?" is answered "No", the values for these variables may be null. However, if "Serious?" is answered "Yes", at least one of them will have a “Y” response. Others may be "N" or null, according to the sponsor’s convention.

Serious? [ ] Yes [ ] No

If yes, check all that apply [ ] Fatal [ ] Life-threatening [ ] Inpatient hospitalization… [ ] etc.

On the other hand, if the CRF is structured so that a response is collected for each seriousness category, all category variables (e.g., AESDTH, AESHOSP) would be populated and AESER would be derived.

b. The serious categories “Involves cancer” (AESCAN) and “Occurred with overdose” (AESOD) are not part of the ICH definition of a serious

adverse event, but these categories are available for use in studies conducted under guidelines that existed prior to the FDA’s adoption of the ICH definition.

c. When a description of "Other Medically Important Serious Adverse Events" category is collected on a CRF, sponsors should place the description in the SUPPAE dataset using the standard supplemental qualifier name code AESOSP as described in Section 8.4, Relating Non-Standard Variables Values to a Parent Domain, and in Appendix C1, Supplemental Qualifiers Name Codes.

d. In studies using toxicity grade according to a standard toxicity scale such as the Common Terminology Criteria for Adverse Events v3.0 (CTCAE),

published by the National Cancer Institute (NCI; available at https://ctep.cancer.gov/protocoldevelopment/), AETOXGR should be used instead of AESEV. In most cases, either AESEV or AETOXGR is populated but not both. There may be cases when a sponsor may need to populate both variables. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document.

e. The structure of the AE domain is 1 record per adverse event per subject. It is the sponsor's responsibility to define an event. This definition may vary based on the sponsor's requirements for characterizing and reporting product safety and is usually described in the protocol. For example, the sponsor may submit 1 record that covers an adverse event from start to finish. Alternatively, if there is a need to evaluate AEs at a more granular level, a sponsor may submit a new record when severity, causality, or seriousness changes or worsens. By submitting these individual records, the sponsor indicates that each is considered to represent a different event. The submission dataset structure may differ from the structure at the time of collection. For example, a sponsor might collect data at each visit in order to meet operational needs, but submit records that summarize the event and contain the highest level of severity, causality, seriousness, and so on. Examples of dataset structure include:

## Biospecimen Events (BE)

*Structure: One record per instance per biospecimen event per biospecimen identifier per subject.*

An events domain that documents actions taken that affect or may affect a specimen (e.g., specimen collection, freezing and thawing, aliquoting, transportation).

### BE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | BE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | Sponsor-defined identifier for a device. | Perm |
| BESEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| BEGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| BEREFID | Reference ID | Char |  | Identifier | Internal or external identifier for the specimen affected or created by the event. | Exp |

### BE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BESPID | Sponsor-Defined Identifier | Char |  | Identifier | Optional sponsor-defined reference number. Example: Line number on a CRF page. | Perm |
| BETERM | Reported Term for the Biospecimen Event | Char |  | Topic | Topic variable for an event observation, which is the verbatim or pre-specified name of the event. | Req |
| BEMODIFY | Modified Reported Term | Char |  | Synonym Qualifier | If the value for BETERM is modified for coding purposes, then the modified text is placed here. | Perm |
| BEDECOD | Dictionary-Derived Term | Char | (BEDECOD) | Synonym Qualifier | Dictionary-derived text description of BETERM or BEMODIFY, if applicable. | Perm |
| BECAT | Category for Biospecimen Event | Char |  | Grouping Qualifier | Used to define a category of topic-variable values. Example: COLLECTION, PREPARATION, TRANSPORT. | Perm |
| BESCAT | Subcategory for Biospecimen Event | Char |  | Grouping Qualifier | A further categorization of BECAT values. | Perm |
| BELOC | Anatomical Location of Event | Char | (LOC) | Record Qualifier | Describes the anatomical location relevant for the event (e.g. BRAIN, LUNG). | Perm |

### BE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BEPARTY | Accountable Party | Char | * | Record Qualifier | Party accountable for the transferable object (e.g. specimen) as a result of the activity performed in the associated BETERM variable. The party could be an individual (e.g., subject), an organization (e.g., sponsor), or a location that is a proxy for an individual or organization (e.g., site). It is usually a somewhat general term that is further identified in the BEPRTYID variable. | Perm |
| BEPRTYID | Identification of Accountable Party | Char |  | Record Qualifier | Identification of the specific party accountable for the transferable object (e.g. Specimen) after the action in BETERM is taken. Used in conjunction with BEPARTY. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |

### BE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BEDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date and time of specimen collection. | Exp |
| BESTDTC | Start Date/Time of Biospecimen Event | Char | ISO 8601 datetime or interval | Timing | Start date/time of the event. | Exp |
| BEENDTC | End Date/Time of Biospecimen Event | Char | ISO 8601 datetime or interval | Timing | End date/time of the event. | Exp |
| BESTDY | Study Day of Start of Biospecimen Event | Num |  | Timing | Actual study day of start of observation expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| BEENDY | Study Day of End of Biospecimen Event | Num |  | Timing | Actual study day of end of observation expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### BE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BEDUR | Duration of Biospecimen Event | Char | ISO 8601 duration | Timing | Collected duration and unit of a biospecimen event. Used only if collected on the CRF and not derived from start and end date/times. Example: P1DT2H (for 1 day, 2 hours). | Perm |

### BE Assumptions

1. The BE domain contains data about actions taken that affect or may affect a specimen, such as specimen collection, freezing and thawing, aliquoting,

and transportation. This domain is intended to be applicable to any specimen tracking data, regardless of the reason for specimen collection.

2. The value in BEREFID identifies the specimen most affected by the event. For aliquoting, this would be the child specimen(s) created by the event,

rather than the parent specimen. BEREFID should not contain any identifiers other than specimen IDs.

3. BELOC holds the relevant anatomic location of the subject, so it should only be populated when the subject participates in and is directly affected by the

event given in BETERM.

4. BEPARTY and BEPRTYID together identify the individual or organization that takes responsibility for the biospecimen as a result of the action in

BETERM. For example, if BETERM is COLLECTED, BEPARTY would be a general term defining the type of responsible party, such as SITE, and BEPRTYID would contain the site identifier, such as 02. If BEPARTY is sufficient to uniquely identify the party (such as SPONSOR in a singlesponsor study), then BEPRTYID may be null.

5. Usually BEPARTY and BEPRTYID refer to who has possession of the biospecimen after the action in BETERM. In the cases where a biospecimen is

lost or destroyed for example, BEPARTY and BEPRTYID may be null.

6. Timing variables:

a. BESTDTC and BEENDTC hold the start and end date/times for the event given in BETERM. If the end date/time is the same as the start date/time for the event, then BEENDTC is null.

b. Unlike other Events domains, BEDTC does not hold the date/time of data collection. Instead, it holds the date/time of specimen collection, in

alignment with the use of --DTC for specimen-related findings. BEDTC values for extracted or otherwise derived specimens are copied from that of the parent specimen.

## Clinical Events (CE)

*Structure: One record per event per subject, Tabulation.*

An events domain that contains clinical events of interest that would not be classified as adverse events.

### CE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | CE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| CESEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| CEGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records for a subject within a domain. | Perm |
| CEREFID | Reference ID | Char |  | Identifier | Internal or external identifier (e.g., lab specimen ID, UUID for an ECG waveform or medical image). | Perm |
| CESPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| CETERM | Reported Term for the Clinical Event | Char |  | Topic | Term for the medical condition or event. Most likely preprinted on CRF. | Req |

### CE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CEDECOD | Dictionary-Derived Term | Char | * | Synonym Qualifier | Controlled terminology for the name of the clinical event. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define- XML document. | Perm |
| CECAT | Category for the Clinical Event | Char | * | Grouping Qualifier | Used to define a category of related records. | Perm |
| CESCAT | Subcategory for the Clinical Event | Char | * | Grouping Qualifier | A further categorization of the condition or event. | Perm |
| CEPRESP | Clinical Event Pre- specified | Char | (NY) | Variable Qualifier | Used to indicate whether the event in CETERM was prespecified. Value is "Y" for prespecified events and null for spontaneously reported events. | Perm |
| CEOCCUR | Clinical Event Occurrence | Char | (NY) | Record Qualifier | Used when the occurrence of specific events is solicited, to indicate whether or not a clinical event occurred. Values are null for spontaneously reported events. | Perm |

### CE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CESTAT | Completion Status | Char | (ND) | Record Qualifier | The status indicates that a question from a prespecified list was not answered. | Perm |
| CEREASND | Reason Clinical Event Not Collected | Char |  | Record Qualifier | Describes the reason clinical event data was not collected. Used in conjunction with CESTAT when value is "NOT DONE". | Perm |
| CEBODSYS | Body System or Organ Class | Char | * | Record Qualifier | Dictionary-derived. Body system or organ class that is involved in an event or measurement from a standard hierarchy (e.g., MedDRA). When using a multi-axial dictionary such as MedDRA, this should contain the SOC used for the sponsor's analyses and summary tables, which may not necessarily be the primary SOC. | Perm |
| CESEV | Severity/Intensity | Char | (SEVRS) | Record Qualifier | The severity or intensity of the event. Examples: "MILD", "MODERATE", "SEVERE". | Perm |

### CE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CETOXGR | Standard Toxicity Grade | Char | * | Record Qualifier | Toxicity grade according to a standard toxicity scale (e.g., Common Terminology Criteria for Adverse Events (CTCAE) v3.0). Sponsor should specify name of the scale and version used in the metadata. If value is from a numeric scale, represent only the number (e.g., "2", not "Grade 2"). | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the clinical event started. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the clinical event. | Perm |
| CEDTC | Date/Time of Event Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time for the clinical event observation represented in ISO 8601 character format. | Perm |

### CE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CESTDTC | Start Date/Time of Clinical Event | Char | ISO 8601 datetime or interval | Timing | Start date/time of the clinical event represented in ISO 8601 character format. | Perm |
| CEENDTC | End Date/Time of Clinical Event | Char | ISO 8601 datetime or interval | Timing | End date/time of the clinical event, represented in ISO 8601 character format. | Perm |
| CEDY | Study Day of Event Collection | Num |  | Timing | Study day of clinical event collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |
| CESTDY | Study Day of Start of Event | Num |  | Timing | Actual study day of start of the clinical event expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### CE Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CEENDY | Study Day of End of Event | Num |  | Timing | Actual study day of end of the clinical event expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| CESTRF | Start Relative to Reference Period | Char | (STENRF) | Timing | Describes the start of the clinical event relative to the sponsor-defined reference period. The sponsor- defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### CE Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CEENRF | End Relative to Reference Period | Char | (STENRF) | Timing | Describes the end of the event relative to the sponsor-defined reference period. The sponsor-defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| CESTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the observation as being before or after the reference time point defined by variable CESTTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| CESTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by --STRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |

### CE Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CEENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the observation as being before or after the sponsor-defined reference time point defined by variable CEENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| CEENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by CEENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### CE Assumptions

1. The determination of events to be considered clinical events versus adverse events should be done carefully and with reference to regulatory guidelines

or consultation with a regulatory review division. Events of clinical interest as defined by the protocol that are not considered AEs should be reflected as CEs.

a. Events considered to be clinical events may include episodes of symptoms of the disease under study (often known as "signs and symptoms"), or events that do not constitute adverse events in themselves, though they might lead to the identification of an adverse event. For example, in a study of an investigational treatment for migraine headaches, migraine headaches may not be considered to be adverse events per protocol. The occurrence of migraines or associated signs and symptoms might be reported in CE.

b. In vaccine trials, certain adverse events may be considered to be signs or symptoms and accordingly determined to be clinical events. If any event is

considered serious, then the serious variable (--SER) and the serious adverse event flags (--SCAN, --SCONG, --SDTH, --SHOSP, --SDISAB, -- SLIFE, --SOD, --SMIE) would be required in the CE domain.

c. Other studies might track the occurrence of specific events as efficacy endpoints. For example, in a study of an investigational treatment for prevention of ischemic stroke, all occurrences of TIA, stroke, and death might be captured as clinical events and assessed as to whether they meet endpoint criteria. Note that other information about these events may be reported in other datasets. For example, the event leading to death would be reported in AE; death would also be a reason for study discontinuation in the Disposition (DS) domain.

2. CEOCCUR and CEPRESP are used together to indicate whether the event in CETERM was prespecified and whether it occurred. CEPRESP can be

used to separate records that correspond to probing questions for prespecified events from those that represent spontaneously reported events, whereas CEOCCUR contains the responses to such questions. The following table shows how these variables are populated in various situations.

Situation Value of CEPRESP

Value of CEOCCUR

Value of CESTAT Spontaneously reported event occurrence Prespecified event occurred Y Y Prespecified event did not occur Y N Prespecified event has no response Y NOT DONE

3. The collection of write-in events on a CE CRF should be considered with caution. Sponsors must ensure that all adverse events are recorded in the AE

domain.

4. Any identifier variable may be added to the CE domain.

## Disposition (DS)

*Structure: One record per disposition status or protocol milestone per subject, Tabulation.*

An events domain that contains information encompassing and representing data related to subject disposition.

### DS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | DS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| DSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| DSGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| DSREFID | Reference ID | Char |  | Identifier | Internal or external identifier. | Perm |
| DSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a Disposition page. | Perm |

### DS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DSTERM | Reported Term for the Disposition Event | Char |  | Topic | Verbatim name of the event or protocol milestone. Some terms in DSTERM will match DSDECOD, but others, such as "Subject moved", will map to controlled terminology in DSDECOD, such as "LOST TO FOLLOW-UP". | Req |
| DSDECOD | Standardized Disposition Term | Char | (NCOMPLT)(PROTMLST)(OTHEVENT) | Synonym Qualifier | Controlled terminology for the name of disposition event or protocol milestone. Examples of protocol milestones: "INFORMED CONSENT OBTAINED", "RANDOMIZED". There are separate codelists used for DSDECOD where the choice depends on the value of DSCAT. Codelist "NCOMPLT" is used for disposition events, codelist "PROTMLST" is used for protocol milestones, and codelist "OTHEVENT" is used for other events. | Req |
| DSCAT | Category for Disposition Event | Char | (DSCAT) | Grouping Qualifier | Used to define a category of related records. | Exp |

### DS Assumptions

1. The Disposition (DS) dataset provides an accounting for all subjects who entered the study and may include protocol milestones, such as randomization,

as well as the subject's completion status or reason for discontinuation for the entire study or each phase or segment of the study, including screening and post-treatment follow-up. Sponsors may choose which disposition events and milestones to submit for a study. See ICH E3, Section 10.1, for information about disposition events.

2. Categorization

a. DSCAT is used to distinguish between disposition events, protocol milestones, and other events. The controlled terminology for DSCAT consists of "DISPOSITION EVENT", "PROTOCOL MILESTONE", and "OTHER EVENT".

b. An event with DSCAT = “DISPOSITION EVENT” describes either disposition of study participation or of a study treatment. It describes whether a

subject completed study participation or a study treatment and, if not, the reason they did not complete it. Dispositions may be described for each epoch (e.g., screening, initial treatment, washout, cross-over treatment, follow-up) or for the study as a whole. If disposition events for both study participation and study treatment(s) are to be represented, then DSSCAT provides this distinction. For records with DSCAT = "DISPOSITION EVENT",

i. DSSCAT = "STUDY PARTICIPATION" is used to represent disposition of study participation.

ii. DSSCAT = "STUDY TREATMENT" is used when a study has only a single treatment.

iii. If a study has multiple treatments, then DSSCAT should name the individual treatment.

c. DSSCAT may be used when DSCAT = "PROTOCOL MILESTONE" or "OTHER EVENT", but would be subject to additional CDISC Controlled Terminology.

d. An event with DSCAT = “PROTOCOL MILESTONE” is a protocol-specified, point-in-time event. Common protocol milestones include

“INFORMED CONSENT OBTAINED” and “RANDOMIZED.” DSSCAT may be used for subcategories of protocol milestones.

e. An event with DSCAT = "OTHER EVENT" is another important event that occurred during a trial, but was not driven by protocol requirements and was not captured in another Events or Interventions class dataset. “TREATMENT UNBLINDED” is an example of an event that would be represented with DSCAT = “OTHER EVENT”.

3. DS description and coding

a. DSDECOD values are drawn from controlled terminology. The controlled terminology depends on the value of DSCAT.

b. When DSCAT = "DISPOSITION EVENT" DSTERM contains either "COMPLETED" or, if the subject did not complete, specific verbatim

information about the reason for non-completion.

i. When DSTERM = "COMPLETED", DSDECOD is the term "COMPLETED" from the Controlled Terminology codelist NCOMPLT.

ii. When DSTERM contains verbatim text, DSDECOD will use the extensible Controlled Terminology codelist NCOMPLT. For example,

DSTERM = "Subject moved" might be coded to DSDECOD = "LOST TO FOLLOW-UP".

c. When DSCAT = "PROTOCOL MILESTONE", DSTERM contains the verbatim (as collected) and/or standardized text, DSDECOD will use the extensible Controlled Terminology codelist PROTMLST.

d. When DSCAT = “OTHER EVENT”, DSDECOD uses sponsor terminology.

i. If a reason for the event was collected, the reason for the event is in DSTERM and the DSDECOD is a term from sponsor terminology. For

example, if treatment was unblinded due to investigator error, this might be represented in a record with DSTERM = "INVESTIGATOR ERROR" and DSDECOD = "TREATMENT UNBLINDED".

ii. If no reason was collected, then DSTERM should be populated with the value in DSDECOD.

4. Timing variables

a. DSSTDTC is expected and is used for the date/time of the disposition event. Events represented in the DS domain do not have end dates; disposition events do not span an interval, but rather occur at a single date/time (e.g., randomization date, disposition of study participation or study treatment).

b. DSSTDTC documents the date/time that a protocol milestone, disposition event, or other event occurred. For an event with DSCAT =

"DISPOSITION EVENT" where DSTERM is not "COMPLETED", the reason for non-completion may be related to an observation reported in another dataset. DSSTDTC is the date/time that the Epoch was completed and is not necessarily the same as the date/time, start date/time, or end date/time of the observation that led to discontinuation. For example, a subject reported severe vertigo on June 1, 2006 (AESTDTC). After ruling out other possible causes, the investigator decided to discontinue study treatment on June 6, 2006 (DSSTDTC). The subject reported that the vertigo had resolved on June 8, 2006 (AEENDTC).

c. EPOCH may be included as a timing variable as in other general observation-class domains. In DS, EPOCH is based on DSSTDTC. The values of EPOCH are drawn from the Trial Arms (TA) dataset (see Section 7.2.1, Trial Arms).

5. Reasons for termination: ICH E3 Section 10.1 indicates that “the specific reason for discontinuation” should be presented, and that summaries should be

“grouped by treatment and by major reason.” The CDISC SDS Team interprets this guidance as requiring 1 standardized disposition term (DSDECOD) per disposition event. If multiple reasons are reported, the sponsor should identify a primary reason and use that to populate DSTERM and DSDECOD. Additional reasons should be submitted in SUPPDS.

## Healthcare Encounters (HO)

*Structure: One record per healthcare encounter per subject, Tabulation.*

An events domain that contains data for inpatient and outpatient healthcare events (e.g., hospitalization, nursing home stay, rehabilitation facility stay, ambulatory surgery).

### HO Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | HO | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| HOSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| HOGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| HOREFID | Reference ID | Char |  | Identifier | Internal or external healthcare encounter identifier. | Perm |
| HOSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a Healthcare Encounters CRF page. | Perm |

### HO Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| HOTERM | Healthcare Encounter Term | Char |  | Topic | Verbatim or preprinted CRF term for the healthcare encounter. | Req |
| HODECOD | Dictionary-Derived Term | Char | (HODECOD) | Synonym Qualifier | Dictionary or sponsor-defined derived text description of HOTERM or the modified topic variable (HOMODIFY). | Perm |
| HOCAT | Category for Healthcare Encounter | Char | * | Grouping Qualifier | Used to define a category of topic-related values. | Perm |
| HOSCAT | Subcategory for Healthcare Encounter | Char | * | Grouping Qualifier | A further categorization of HOCAT values. | Perm |
| HOPRESP | Pre-Specified Healthcare Encounter | Char | (NY) | Variable Qualifier | A value of "Y" indicates that this healthcare encounter event was prespecified on the CRF. Values are null for spontaneously reported events (i.e., those collected as free-text verbatim terms). | Perm |
| HOOCCUR | Healthcare Encounter Occurrence | Char | (NY) | Record Qualifier | Used when the occurrence of specific healthcare encounters is solicited, to indicate whether an encounter occurred. Values are null for spontaneously reported events. | Perm |

### HO Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| HOSTAT | Completion Status | Char | (ND) | Record Qualifier | The status indicates that the prespecified question was not answered. | Perm |
| HOREASND | Reason Healthcare Encounter Not Done | Char |  | Record Qualifier | Describes the reason data for a prespecified event were not collected. Used in conjunction with HOSTAT when value is "NOT DONE". | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the healthcare encounter. Examples: "SCREENING", "TREATMENT", "FOLLOW-UP". | Perm |
| HODTC | Date/Time of Event Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the healthcare encounter. | Perm |
| HOSTDTC | Start Date/Time of Healthcare Encounter | Char | ISO 8601 datetime or interval | Timing | Start date/time of the healthcare encounter (e.g., date of admission). | Exp |

### HO Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| HOENDTC | End Date/Time of Healthcare Encounter | Char | ISO 8601 datetime or interval | Timing | End date/time of the healthcare encounter (e.g., date of discharge). | Perm |
| HODY | Study Day of Event Collection | Num |  | Timing | Study day of event collection relative to the sponsor-defined RFSTDTC. | Perm |
| HOSTDY | Study Day of Start of Encounter | Num |  | Timing | Study day of the start of the healthcare encounter relative to the sponsor-defined RFSTDTC. | Perm |
| HOENDY | Study Day of End of Healthcare Encounter | Num |  | Timing | Study day of the end of the healthcare encounter relative to the sponsor-defined RFSTDTC. | Perm |
| HODUR | Duration of Healthcare Encounter | Char | ISO 8601 duration | Timing | Collected duration of the healthcare encounter. Used only if collected on the CRF and not derived from the start and end date/times. Example: "P1DT2H" (for 1 day, 2 hours). | Perm |

### HO Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| HOSTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the observation as being before or after the sponsor-defined reference time point defined by variable --STTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| HOSTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by STRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |
| HOENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the event as being before or after the reference time point defined by variable HOENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### HO Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| HOENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by HOENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### HO Assumptions

1. The Healthcare Encounters (HO) dataset includes inpatient and outpatient healthcare events (e.g., hospitalizations, nursing home stays, rehabilitation

facility stays, ambulatory surgery).

2. Values of HOTERM typically describe the location or place of the healthcare encounter (e.g., "HOSPITAL" rather than "HOSPITALIZATION").

HOSTDTC should represent the start or admission date and HOENDTC the end or discharge date.

3. Data collected about healthcare encounters may include the reason for the encounter. The following supplemental qualifiers may be appropriate for

representing such data:

a. The supplemental qualifier with QNAM = "HOINDC" would be used to represent the indication/medical condition for the encounter (e.g., stroke). Note that --INDC is an Interventions class variable, so is not a standard variable for HO, which is an Events class domain.

b. The supplemental qualifier with QNAM = "HOREAS" would be used to represent a reason for the encounter other than a medical condition (e.g.,

annual checkup).

4. If collected data includes the name of the provider or the facility where the encounter took place, this may be represented using the supplemental

qualifier with QNAM = "HONAM". Note that --NAM is a Findings class variable, so is not a standard variable for HO, which is an Events class domain.

5. Any identifier variables, timing variables, or Events general observation-class qualifiers may be added to the HO domain, but the following Qualifiers

would generally not be used: ‑‑SER, --ACN, --ACNOTH, --REL, --RELNST, --SCAN, --SCONG, --SDISAB, ‑‑SDTH, --SHOSP, --SLIFE, --SOD, -- SMIE, ‑‑BODSYS, ‑‑LOC, ‑‑SEV, --TOX, --TOXGR, --PATT, --CONTRT.

## Medical History (MH)

*Structure: One record per medical history event per subject, Tabulation.*

An events domain that contains data that includes the subject's prior medical history at the start of the trial.

### MH Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | MH | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| MHSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| MHGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| MHREFID | Reference ID | Char |  | Identifier | Internal or external medical history identifier. | Perm |
| MHSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a Medical History CRF page. | Perm |

### MH Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MHTERM | Reported Term for the Medical History | Char |  | Topic | Verbatim or preprinted CRF term for the medical condition or event. | Req |
| MHMODIFY | Modified Reported Term | Char |  | Synonym Qualifier | If MHTERM is modified to facilitate coding, then MHMODIFY will contain the modified text. | Perm |
| MHDECOD | Dictionary-Derived Term | Char | * | Synonym Qualifier | Dictionary-derived text description of MHTERM or MHMODIFY. Equivalent to the Preferred Term (PT in MedDRA). The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the external codelist element in the Define-XML document. | Perm |
| MHEVDTYP | Medical History Event Date Type | Char | (MHEDTTYP) | Variable Qualifier | Specifies the aspect of the medical condition or event by which MHSTDTC and/or the MHENDTC is defined. Examples: "DIAGNOSIS", "SYMPTOMS", "RELAPSE", "INFECTION". | Perm |
| MHCAT | Category for Medical History | Char | * | Grouping Qualifier | Used to define a category of related records. Examples: "CARDIAC", "GENERAL". | Perm |

### MH Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MHSCAT | Subcategory for Medical History | Char | * | Grouping Qualifier | A further categorization of the condition or event. | Perm |
| MHPRESP | Medical History Event Pre-Specified | Char | (NY) | Variable Qualifier | A value of "Y" indicates that this medical history event was prespecified on the CRF. Values are null for spontaneously reported events (i.e., those collected as free-text verbatim terms). | Perm |
| MHOCCUR | Medical History Occurrence | Char | (NY) | Record Qualifier | Used when the occurrence of specific medical history conditions is solicited, to indicate whether ("Y"/"N") a medical condition (MHTERM) had ever occurred. Values are null for spontaneously reported events. | Perm |
| MHSTAT | Completion Status | Char | (ND) | Record Qualifier | The status indicates that the prespecified question was not asked/answered. | Perm |
| MHREASND | Reason Medical History Not Collected | Char |  | Record Qualifier | Describes the reason why data for a prespecified condition was not collected. Used in conjunction with MHSTAT when value is "NOT DONE". | Perm |

### MH Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MHBODSYS | Body System or Organ Class | Char | * | Record Qualifier | Dictionary-derived. Body system or organ class that is involved in an event or measurement from a standard hierarchy (e.g., MedDRA). When using a multi-axial dictionary such as MedDRA, this should contain the SOC used for the sponsor's analyses and summary tables which may not necessarily be the primary SOC. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the medical history event. | Perm |
| MHDTC | Date/Time of History Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the medical history observation represented in ISO 8601 character format. | Perm |

### MH Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MHSTDTC | Start Date/Time of Medical History Event | Char | ISO 8601 datetime or interval | Timing | Start date/time of the medical history event represented in ISO 8601 character format. | Perm |
| MHENDTC | End Date/Time of Medical History Event | Char | ISO 8601 datetime or interval | Timing | End date/time of the medical history event. | Perm |
| MHDY | Study Day of History Collection | Num |  | Timing | Study day of medical history collection, measured as integer day. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |

### MH Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MHENRF | End Relative to Reference Period | Char | (STENRF) | Timing | Describes the end of the event relative to the sponsor-defined reference period. The sponsor-defined reference period is a continuous period of time defined by a discrete starting point and a discrete ending point (represented by RFSTDTC and RFENDTC in Demographics). Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| MHENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the event as being before or after the reference time point defined by variable MHENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| MHENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the reference point referred to by MHENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

### MH Assumptions

1. Prior treatments, including prior medications and procedures, should be submitted in an appropriate dataset from the Interventions class (e.g.,

Concomitant/Prior Medications (CM) or Procedures (PR)).

2. MH description and coding

a. MHTERM is the topic variable and captures the verbatim term collected for the condition or event or the prespecified term used to collect information about the occurrence of any of a group of conditions or events. MHTERM is a required variable and must have a value.

b. MHMODIFY is a permissible variable and should be included if the sponsor’s procedure permits modification of a verbatim term for coding. The

modified term is listed in MHMODIFY. The variable should be populated as per the sponsor’s procedures; null values are permitted.

d. MHBODSYS is the system organ class (SOC) from the coding dictionary associated with the adverse event by the sponsor. This value may differ

from the primary SOC designated in the coding dictionary's standard hierarchy.

e. If a CRF collects medical history by prespecified body systems and the sponsor also codes reported terms using a standard dictionary, then MHDECOD and MHBODSYS are populated using the standard dictionary. MHCAT and MHSCAT should be used for the prespecified body systems.

3. Additional categorization and grouping

a. MHCAT and MHSCAT may be populated with the sponsor's predefined categorization of medical history events, which are often prespecified on the CRF. Note that even if the sponsor uses the body system terminology from the standard dictionary, MHBODSYS and MHCAT may differ; MHBODSYS is derived from the coding system, whereas MHCAT is effectively assigned when the investigator records a condition under the prespecified category.

i. This categorization should not group all records (within the MH domain) into one generic group such as “Medical History” or “General

Medical History” because this is redundant information with the domain code. If no smaller categorization can be applied, then it is not necessary to include or populate this variable.

ii. Examples of MHCAT could include “General Medical History“ (see above assumption; if “General Medical History” is an MHCAT value,

then there should be other MHCAT values), “Allergy Medical History, “ and “Reproductive Medical History”.

b. MHGRPID may be used to link (or associate) different records together to form a block of related records at the subject level within the MH

domain. It should not be used in place of MHCAT or MHSCAT, which are used to group data across subjects. For example, if a group of syndromes reported for a subject were related to a particular disease, then the MHGRPID variable could be populated with the appropriate text.

4. Prespecified terms; presence or absence of events

a. Information on medical history is generally collected in 2 different ways, either by recording free text or using a prespecified list of terms. The solicitation of information on specific medical history events may affect the frequency at which they are reported; therefore, the fact that a specific medical history event was solicited may be of interest to reviewers. MHPRESP and MHOCCUR are used together to indicate whether the condition in MHTERM was prespecified and whether it occurred, respectively. A value of “Y” in MHPRESP indicates that the term was prespecified.

b. MHOCCUR is used to indicate whether a prespecified medical condition occurred; a value of "Y" indicates that the event occurred and "N"

indicates that it did not.

c. If a medical history event was reported using free text, the values of MHPRESP and MHOCCUR should be null. MHPRESP and MHOCCUR are permissible fields and may be omitted from the dataset if all medical history events were collected as free text.

d. MHSTAT and MHREASND provide information about prespecified medical history questions for which no response was collected. MHSTAT and

MHREASND are permissible fields and may be omitted from the dataset if all medications were collected as free text or if all prespecified conditions had responses in MHOCCUR.

Situation Value of MHPRESP

Value of MHOCCUR

Value of MHSTAT Spontaneously reported event occurred Pre-specified event occurred Y Y Pre-specified event did not occur Y N Pre-specified event has no response Y NOT DONE

e. When medical history events are collected with the recording of free text, a record may be entered into the data management system to indicate “no medical history” for a specific subject or prespecified body system category (e.g., gastrointestinal). For these subjects or categories within subject, do not include a record in the MH dataset to indicate that there were no events.

5. Timing variables

a. Relative timing assessments such as “Ongoing” or "Active" are common in the collection of MH information. MHENRF may be used when this relative timing assessment is coincident with the start of the study reference period for the subject represented in the Demographics (DM) dataset (RFSTDTC). MHENRTPT and MHENTPT may be used when "Ongoing" is relative to another date such as the screening visit date. See the examples in this section and in Section 4.4.7, Use of Relative Timing Variables.

b. Additional timing variables (e.g., MHSTRF) may be used when appropriate.

6. MH event date type

a. MHEVDTYP is a domain-specific variable that can be used to indicate the aspect of the event that is represented in the event start and/or end date/times (MHSTDTC and/or MHENDTC). If a start date and/or end date is collected without further specification of what constitutes the start or end of the event, then MHEVDTYP is not needed. However, when data collection specifies how the start or end date is to be reported, MHEVDTYP can be used to provide this information. For example, when collecting the date of diagnosis, it would be used to populate MHSTDTC; MHEVDTYP would be populated with "DIAGNOSIS". If MHEVDTYP is not needed for any collected data, it need not be included in the dataset. If MHEVDTYP is included in the dataset, it should be populated only when the data collection specifies the aspect of the event that is to be used to populate the start and/or end date; otherwise, it should be null.

b. When data collected about an event includes 2 different dates that could be considered the start or end of an event, then an MH record will be

created for each. For example, if data collection included both a date of onset of symptoms and a date of diagnosis, there would be 2 records for the event, one with MHSTDTC the date of onset of symptoms and MHEVDTYP = "SYMPTOMS" and a second with MHSTDTC the date of diagnosis and MHENDTYP = "DIAGNOSIS". In such a case, it is recommended that the 2 records be linked by means such as a common value of MHSPID or MHGRPID.

7. Any identifiers, timing variables, or Events general observation-class qualifiers may be added to the MH domain, but the following Qualifiers would

generally not be used: --SER, --ACN, --ACNOTH, --REL, --RELNST, --OUT, --SCAN, --SCONG, --SDISAB, ‑‑SDTH, --SHOSP, --SLIFE, --SOD, -- SMIE.

## Protocol Deviations (DV)

*Structure: One record per protocol deviation per subject, Tabulation.*

An events domain that contains protocol violations and deviations during the course of the study.

### DV Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | DV | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| DVSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| DVREFID | Reference ID | Char |  | Identifier | Internal or external identifier. | Perm |
| DVSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a CRF page. | Perm |

### DV Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DVTERM | Protocol Deviation Term | Char |  | Topic | Verbatim name of the protocol deviation criterion. Example: "IVRS PROCESS DEVIATION - NO DOSE CALL PERFORMED". DVTERM values will map to the controlled terminology in DVDECOD (e.g., "TREATMENT DEVIATION"). | Req |
| DVDECOD | Protocol Deviation Coded Term | Char | * | Synonym Qualifier | Controlled terminology for the name of the protocol deviation. Examples: "SUBJECT NOT WITHDRAWN AS PER PROTOCOL", "SELECTION CRITERIA NOT MET", "EXCLUDED CONCOMITANT MEDICATION", "TREATMENT DEVIATION". | Perm |
| DVCAT | Category for Protocol Deviation | Char | * | Grouping Qualifier | Category of the protocol deviation criterion. | Perm |
| DVSCAT | Subcategory for Protocol Deviation | Char | * | Grouping Qualifier | A further categorization of the protocol deviation. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the deviation. Examples: "TREATMENT", "SCREENING", "FOLLOW-UP". | Perm |

### DV Assumptions

1. The DV domain is an Events model for collected protocol deviations and not for derived protocol deviations that are more likely to be part of analysis.

Events typically include what the event was, captured in --TERM (the topic variable), and when it happened (captured in its start and/or end dates). The intent of the domain model is to capture protocol deviations that occurred during the course of the study (see ICH E3, Section 10.2[1]). Usually these are deviations that occur after the subject has been randomized or received the first treatment.

2. This domain should not be used to collect entry-criteria information. Violated inclusion/exclusion criteria are stored in IE. The Deviations domain is for

more general deviation data. A protocol may indicate that violating an inclusion/exclusion criterion during the course of the study (after first dose) is a protocol violation. In this case, this information would go into DV.

3. Any identifier variables, timing variables, or Events general observation-class qualifiers may be added to the DV domain, but the following qualifiers

would generally not be used: --PRESP, --OCCUR, --STAT, --REASND, --BODSYS, --LOC, --SEV, --SER, --ACN, ‑‑ACNOTH, --REL, --RELNST, -- PATT, --OUT, --SCAN, --SCONG, --SDISAB, --SDTH, --SHOSP, --SLIFE, --SOD, --SMIE, --CONTRT, --TOXGR.

## Product Accountability (DA)

*Structure: One record per product accountability finding per subject, Tabulation.*

A findings domain that contains the accountability of study products, such as information on the receipt, dispensing, return, and packaging.

### DA Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study within the submission. | Req |
| DOMAIN | Domain Abbreviation | Char | DA | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| DASEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| DAGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| DAREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier such as a code from the product packaging (e.g., bottle label, package label, kit label). | Perm |

### DA Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DASPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Examples: Line number on the Product Accountability CRF page, a code from the product packaging (e.g., bottle label, package label, kit label). | Perm |
| DALNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| DALNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |

### DA Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DATESTCD | Short Name of Accountability Assessment | Char | (DATESTCD) | Topic | Short character value for DATEST used as a column name when converting a dataset from a vertical format to a horizontal format. The short value can be up to 8 characters and cannot begin with a number or contain characters other than letters, numbers, or underscores. Examples: "DISPAMT", "RETAMT". | Req |
| DATEST | Name of Accountability Assessment | Char | (DATEST) | Synonym Qualifier | Verbatim name corresponding to the topic variable of the test or examination used to obtain the product accountability assessment. The value in DATEST cannot be longer than 40 characters. Examples: "Dispensed Amount", "Returned Amount". | Req |
| DACAT | Category | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. Examples: "STUDY MEDICATION", "RESCUE MEDICATION". | Perm |
| DASCAT | Subcategory | Char | * | Grouping Qualifier | Used to define a further categorization level for a group of related records. | Perm |

### DA Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DAORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the product accountability assessment as originally received or collected. | Exp |
| DAORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for DAORRES. | Perm |
| DASTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all product accountability assessments copied or derived from DAORRES, in a standard format or in standard units. DASTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in DASTRESN. | Exp |
| DASTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from DASTRESC. DASTRESN should store all numeric test results or findings. | Perm |
| DASTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for DASTRESC and DASTRESN. | Perm |

### DA Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DASTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a product accountability assessment was not done. Should be null or have a value of "NOT DONE". | Perm |
| DAREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with DASTAT when value is "NOT DONE". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit, based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm (see Section 7.2.1, Trial Arms). | Perm |

### DA Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| DADTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date and time of the product accountability assessment represented in ISO 8601 character format. | Exp |
| DADY | Study Day of Visit/Collection/Exam | Num |  | Timing | Study day of product accountability assessment, measured in integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### DA Assumptions

1. This domain records the amount of study product transferred to or from the study subject.

a. Transfers of devices are not represented in this domain, but in the Device Tracking and Disposition (DT) domain. See the SDTMIG for Medical Devices (available at https://www.cdisc.org/standards/foundational/medical-devices-sdtmig/).

b. For drugs, transfers are usually recorded using the tests "Dispensed Amount" and "Returned Amount".

c. Test terminology for other products may be different; for example, for nutrition, the tests might be "Prepared Amount" and "Unused Amount".

2. DACAT may be used to differentiate transfers of different groups of products (e.g., rescue medications vs. investigational medications).

3. DAREFID and DASPID are both available for capturing label information.

4. The following qualifiers would not generally be used in DA: --MODIFY, --POS, --BODSYS, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --

STNRC, --NRIND, --RESCAT, --XFN, --NAM, --LOINC, --SPEC, --SPCCND, --METHOD, --BLFL, --FAST, --DRVRL, --TOX, --TOXGR, --SEV.

## Death Details (DD)

*Structure: One record per finding per subject, Tabulation.*

A findings domain that contains the diagnosis of the cause of death for a subject.

The domain is designed to hold supplemental data that are typically collected when a death occurs, such as the official cause of death. It does not replace existing data such as serious adverse event details in AE. Further, it does not introduce a new requirement to collect information that is not already indicated as good clinical practice or defined in regulatory guidelines. Instead, it provides a consistent place within the SDTM to hold information that previously did not have a clearly defined home.

### DD Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | DD | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| DDSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| DDTESTCD | Death Detail Assessment Short Name | Char | (DTHDXCD) | Topic | Short name of the measurement, test, or examination described in DDTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in DDTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). DDTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "PRCDTH", "SECDTH". | Req |

### DD Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DDTEST | Death Detail Assessment Name | Char | (DTHDX) | Synonym Qualifier | Long name for DDTESTCD. The value in DDTEST cannot be longer than 40 characters. Examples: "Primary Cause of Death", "Secondary Cause of Death". | Req |
| DDORRES | Result or Finding as Collected | Char |  | Result Qualifier | Result of the test defined in DDTEST, as originally received or collected. | Exp |
| DDSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result or finding copied or derived from DDORRES in a standard format. | Exp |
| DDRESCAT | Result Category | Char | * | Variable Qualifier | Used to categorize the result of a finding. Examples: "TREATMENT RELATED", "NONTREATMENT RELATED", "UNDETERMINED", "ACCIDENTAL". | Perm |
| DDEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. | Perm |

### DD Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| DDDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of collection of the diagnosis or other death assessment data in ISO 8601 format. This is not necessarily the date of death. | Exp |
| DDDY | Study Day of Collection | Num |  | Timing | Study day of the collection, in integer days. The algorithm for calculations must be relative to the sponsor- defined RFSTDTC variable in the Demographics (DM) domain. | Perm |

### DD Assumptions

1. There may be more than 1 cause of death. If so, these may be separated into primary and secondary causes and/or other appropriate designations. DD

may also include other details about the death, such as where the death occurred and whether it was witnessed.

2. Death details are typically collected on designated CRF pages. The DD domain is not intended to collate data that are collected in standard variables in

other domains, such as AE.AEOUT (Outcome of Adverse Event), AE.AESDTH (Results in Death) or DS.DSTERM (Reported Term for the Disposition Event). Data from other domains that relates to the death can be linked to DD using RELREC.

3. This domain is not intended to include data obtained from autopsy. An autopsy is a procedure from which there will usually be findings. Autopsy

information should be handled as per recommendations in the Procedures (PR) domain.

4. There are separate codelists for DD tests and responses. Associations between the DD tests and response codelists are described in the DD codetable

(available at https://www.cdisc.org/standards/terminology/controlled-terminology).

5. Any identifiers, timing variables, or findings general observation-class qualifiers may be added to the DD domain, but the following qualifiers would

not generally be used: --MODIFY, --POS, --BODSYS, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --STNRC, --NRIND, --NAM, --LOINC, -- SPEC, --SPCCND, --LOBXFL, --BLFL, --FAST, --DRVFL, --TOX, --TOXGR, --SEV.

## ECG Test Results (EG)

*Structure: One record per ECG observation per replicate per time point or one record per ECG observation.*

A findings domain that contains ECG data, including position of the subject, method of evaluation, all cycle measurements and all findings from the ECG including an overall interpretation if collected or derived.

### EG Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | EG | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | Sponsor-defined identifier for a device. | Perm |
| EGSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| EGGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| EGREFID | ECG Reference ID | Char |  | Identifier | Internal or external ECG identifier. Example: "334PT89". | Perm |

### EG Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be printed on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on the ECG page. | Perm |
| EGBEATNO | ECG Beat Number | Num |  | Identifier | A sequence number that identifies the beat within an ECG. | Perm |

### EG Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGTESTCD | ECG Test or Examination Short Name | Char | (EGTESTCD)(HETESTCD) | Topic | Short name of the measurement, test, or examination described in EGTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in EGTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). EGTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "PRAG", "QRSAG". Test codes are in 2 separate codelists, 1 for tests based on regular 10-second ECGs (EGTESTCD) and one 1 tests based on Holter monitoring (HETESTCD). | Req |

### EG Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGTEST | ECG Test or Examination Name | Char | (EGTEST)(HETEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in EGTEST cannot be longer than 40 characters. Examples: "PR Interval, Aggregate", "QRS Duration, Aggregate". Test names are in 2 separate codelists, 1 for tests based on regular 10-second ECGs (EGTEST) and 1 for tests based on Holter monitoring (HETEST). | Req |
| EGCAT | Category for ECG | Char | * | Grouping Qualifier | Used to categorize ECG observations across subjects. Examples: "MEASUREMENT", "FINDING", "INTERVAL". | Perm |
| EGSCAT | Subcategory for ECG | Char | * | Grouping Qualifier | A further categorization of the ECG. | Perm |
| EGPOS | ECG Position of Subject | Char | (POSITION) | Record Qualifier | Position of the subject during a measurement or examination. Examples: "SUPINE", "STANDING", "SITTING". | Perm |

### EG Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the ECG measurement or finding as originally received or collected. Examples of expected values are "62" or "0.151" when the result is an interval or measurement, or "ATRIAL FIBRILLATION" or "QT PROLONGATION" when the result is a finding. | Exp |
| EGORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for EGORRES. Examples: "sec", "msec". | Perm |

### EG Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGSTRESC | Character Result/Finding in Std Format | Char | (EGSTRESC)(HESTRESC)(NORMABNM) | Result Qualifier | Contains the result value for all findings copied or derived from EGORRES, in a standard format or standard units. EGSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in EGSTRESN. For example, if a test has results of 62 beats/min, then EGORRES = "62", EGORRESU = "beats/min", EGSTRESC = "62", EGSTRESN = 62, and EGSTRESU = "beats/min" . For other examples, see Original and Standardized Results. Additional examples of result data: "SINUS BRADYCARDIA", "ATRIAL FLUTTER", "ATRIAL FIBRILLATION". Test results are in 3 separate codelists: EGSTRESC for abnormal test results based on regular 10-second ECGs; HESTRESC for abnormal test results based on Holter monitoring, and NORMABNM for generic test results and/or responses to EGTEST = "Interpretation". | Exp |

### EG Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from EGSTRESC. EGSTRESN should store all numeric test results or findings. | Perm |
| EGSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for EGSTRESC and EGSTRESN. | Perm |
| EGSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate an ECG was not done, or an ECG measurement was not taken. Should be null if a result exists in EGORRES. | Perm |
| EGREASND | Reason ECG Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED". Used in conjunction with EGSTAT when value is "NOT DONE". | Perm |
| EGXFN | ECG External File Path | Char |  | Record Qualifier | File name and path for the external ECG waveform file. | Perm |

### EG Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the laboratory or vendor providing the test results. | Perm |
| EGMETHOD | Method of Test or Examination | Char | (EGMETHOD) | Record Qualifier | Method of the ECG test. Example: "12-LEAD STANDARD". | Perm |
| EGLEAD | Lead Location Used for Measurement | Char | (EGLEAD) | Record Qualifier | The lead used for the measurement. Examples: "LEAD 1", "LEAD 2", "LEAD rV2", "LEAD V1". | Perm |
| EGLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| EGBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that EGBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |

### EG Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records, or that do not come from the CRF, or are not as originally collected or received are examples of records that would be derived for the submission datasets. If EGDRVFL="Y", then EGORRES could be null, with EGSTRESC and EGSTRESN (if the result is numeric) having the derived value. | Perm |
| EGEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Should be null for records that contain collected or derived data. Examples: "INVESTIGATOR", "ADJUDICATION COMMITTEE", "VENDOR". | Perm |
| EGEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in EGEVAL. Examples: "RADIOLOGIST 1" or "RADIOLOGIST 2". | Perm |

### EG Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGCLSIG | Clinically Significant, Collected | Char | (NY) | Record Qualifier | Used to indicate whether a collected observation is clinically significant based on judgment. | Perm |
| EGREPNUM | Repetition Number | Num |  | Record Qualifier | The incidence number of a test that is repeated within a given timeframe for the same test. The level of granularity can vary (e.g., within a time point, within a visit). Examples: multiple measurements of blood pressure, multiple analyses of a sample. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### EG Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| EGDTC | Date/Time of ECG | Char | ISO 8601 datetime or interval | Timing | Date/Time of ECG. | Exp |
| EGDY | Study Day of ECG | Num |  | Timing | Study day of the ECG, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |
| EGTPT | Planned Time Point Name | Char |  | Timing | Text description of time when measurement should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See EGTPTNUM and EGTPTREF. Examples: "Start", "5 min post". | Perm |

### EG Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EGTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of EGTPT to aid in sorting. | Perm |
| EGELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a fixed time point reference (EGTPTREF). Not a clock time or a date time variable. Represented as an ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by EGTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by EGTPTREF. | Perm |
| EGTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by EGELTM, EGTPTNUM, and EGTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| EGRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by EGTPTREF. | Perm |

### EG Assumptions

1. EGREFID is intended to store an identifier (e.g., UUID) for the associated ECG tracing. EGXFN is intended to store the name of and path to the

electrocardiogram (ECG) waveform file when it is submitted.

2. There are separate codelists for tests and results based on regular 10-second ECGs and for tests and results based on Holter monitoring.

a. Associations between some ECG abnormality tests and response codelists are described in the ECG codetable (available at https://www.cdisc.org/standards/terminology/controlled-terminology).

3. For non-individual ECG beat data and for aggregate ECG parameter results (e.g., "QT interval", "RR", "PR", "QRS"), EGREFID is populated for all

unique ECGs, so that submitted SDTM data can be matched to the actual ECGs stored in the ECG warehouse. Therefore, this variable is expected for these types of records.

4. For individual-beat parameter results, waveform data will not be stored in the warehouse, so there will be no associated identifier for these beats.

5. The method for QT interval correction is specified in the test name by controlled terminology: EGTESTCD = "QTCFAG" and EGTEST = "QTcF

Interval, Aggregate" is used for Fridericia's formula; EGTESTCD = "QTCBAG" and EGTEST = "QTcB Interval, Aggregate", is used for Bazett's formula.

6. EGBEATNO is used to differentiate between beats in beat-to-beat records.

7. EGREPNUM is used to differentiate between multiple repetitions of a test within a given time frame.

8. EGNRIND can be added to indicate where a result falls with respect to reference range defined by EGORNRLO and EGORNRHI. Examples: "HIGH",

"LOW". Clinical significance would be represented as described in Section 4.5.5, Clinical Significance for Findings Observation Class Data, in EGCLSIG (see also EG Example 1).

9. When "QTcF Interval, Aggregate" or "QTcB Interval, Aggregate" is derived by the sponsor, the derived flag (EGDRVFL) is set to "Y". However, when

the "QTcF Interval, Aggregate" or "QTcB Interval, Aggregate" is received from a central provider or vendor, the value would go into EGORRES and EGDRVFL would be null (see Section 4.1.8.1, Origin Metadata for Variables).

10. If this domain is used in conjunction with the ECG QT Correction Model Data (QT) domain:

a. For each QT correction method used in the study, values of EGTESTCD and EGTEST are assigned at the study level.

## Inclusion/Exclusion Criteria Not Met (IE)

*Structure: One record per inclusion/exclusion criterion not met per subject, Tabulation.*

A findings domain that contains those criteria that cause the subject to be in violation of the inclusion/exclusion criteria.

### IE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | IE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| IESEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| IESPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Inclusion or exclusion criteria number from CRF. | Perm |

### IE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| IETESTCD | Inclusion/Exclusion Criterion Short Name | Char | * | Topic | Short name of the criterion described in IETEST. The value in IETESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). IETESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "IN01", "EX01". | Req |
| IETEST | Inclusion/Exclusion Criterion | Char |  | Synonym Qualifier | Verbatim description of the inclusion or exclusion criterion that was the exception for the subject within the study. IETEST cannot be longer than 200 characters. | Req |
| IECAT | Inclusion/Exclusion Category | Char | (IECAT) | Grouping Qualifier | Used to define a category of related records across subjects. | Req |
| IESCAT | Inclusion/Exclusion Subcategory | Char | * | Grouping Qualifier | A further categorization of the exception criterion. Can be used to distinguish criteria for a sub-study or for to categorize as a major or minor exceptions. Examples: "MAJOR", "MINOR". | Perm |

### IE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| IEORRES | I/E Criterion Original Result | Char | (NY) | Result Qualifier | Original response to inclusion/exclusion criterion question, i.e., whether the inclusion or exclusion criterion was met. | Req |
| IESTRESC | I/E Criterion Result in Std Format | Char | (NY) | Result Qualifier | Response to inclusion/exclusion criterion result, in standard format. | Req |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the observation date/time of the inclusion/exclusion finding. | Perm |

### IE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| IEDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the inclusion/exclusion criterion represented in ISO 8601 character format. | Perm |
| IEDY | Study Day of Collection | Num |  | Timing | Study day of collection of the inclusion/exclusion exceptions, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |

### IE Assumptions

1. The intent of the IE domain model is to collect responses to only those criteria that the subject did not meet, and not the responses to all criteria. For the

complete list of inclusion/exclusion criteria, see Section 7.4.1, Trial Inclusion/Exclusion Criteria.

2. This domain should be used to document the exceptions to inclusion or exclusion criteria at the time that eligibility for study entry is determined (e.g., at

the end of a run-in period or immediately before randomization). This domain should not be used to collect protocol deviations/violations incurred during the course of the study, typically after randomization or start of study medication. See Section 6.2.7, Protocol Deviations, for the model that is used to submit protocol deviations/violations.

3. IETEST is to be used only for the verbatim description of the inclusion or exclusion criteria. If the text is no more than 200 characters, it goes in

IETEST; if the text is more than 200 characters, put meaningful text in IETEST and describe the full text in the study metadata. See Section 4.5.3.1, Test Name (--TEST) Greater than 40 Characters, for further information.

4. The following qualifiers would generally not be used in IE: --MODIFY, --POS, --BODSYS, --ORRESU, --ORNRLO, --ORNRHI, --STRESN, --

STRESU, --STNRLO, --STNRHI, --STNRC, --NRIND, --RESCAT, --XFN, --NAM, --LOINC, --SPEC, --SPCCND, --LOC, --METHOD, --BLFL, -- LOBXFL, --FAST, --DRVFL, --TOX, --TOXGR, --SEV, --STAT.

## Biospecimen Findings (BS)

*Structure: One record per measurement per biospecimen identifier per subject, Tabulation.*

A findings domain that contains data related to biospecimen characteristics.

### BS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| --STAT | Completion Status | Char | * | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| --REASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with --STAT when value is "NOT DONE". | Perm |
| --NAM | Laboratory/Vendor Name | Char | * | Record Qualifier | Name or identifier of the vendor (e.g., laboratory) that provided the test results. | Perm |
| --SPEC | Specimen Material Type | Char | * | Record Qualifier | Defines the type of specimen used for a measurement. Subject to domain-specific test code controlled terminology. | Perm |
| --METHOD | Method of Test or Examination | Char | * | Record Qualifier | Method of the test or examination. Subject to domain-specific test code controlled terminology. | Perm |

### BS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| --LOBXFL | Last Observation Before Exposure Flag | Char | * | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| --LLOQ | Lower Limit of Quantitation | Num |  | Variable Qualifier | Indicates the lower limit of quantitation for an assay. Units will be those used for --STRESU. | Perm |
| --ULOQ | Upper Limit of Quantitation | Num |  | Variable Qualifier | Indicates the upper limit of quantitation for an assay. Units will be those used for --STRESU. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### BS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| --DTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Perm |
| --DY | Study Day of Collection | Num |  | Timing | Study day of the collection, in integer days. The algorithm for calculations must be relative to the sponsor- defined RFSTDTC variable in the Demographics (DM) domain. | Perm |
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | BS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | Sponsor-defined identifier for a device. | Perm |
| BSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |

### BS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BSGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| BSREFID | Reference ID | Char |  | Identifier | Internal or external identifier such as lab specimen ID. | Exp |
| BSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| BSTESTCD | Biospecimen Test Short Name | Char | (BSTESTCD) | Topic | Short character value for BSTEST used as a column name when converting a dataset from a vertical format to a horizontal format. The short value can be up to 8 characters. Examples: VOLUME, RIN. | Req |
| BSTEST | Biospecimen Test Name | Char | (BSTEST) | Synonym Qualifier | Long name for BSTESTCD. Examples: Volume, RNA Integrity Number. | Req |
| BSCAT | Category for Biospecimen Test | Char |  | Grouping Qualifier | Used to define a category of topic-variable values. Example: MEASUREMENT, QUALITY. | Exp |
| BSSCAT | Subcategory for Biospecimen Test | Char |  | Grouping Qualifier | Used to define a further categorization of BSCAT values. | Perm |

### BS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BSORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| BSORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for BSORRES. Examples: mg, mL. | Exp |
| BSSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from BSORRES in a standard format or standard units. BSSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in BSSTRESN. | Exp |
| BSSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from BSSTRESC. BSSTRESN should store all numeric test results or findings. | Exp |
| BSSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for BSSTRESC and BSSTRESN. | Exp |

### BS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a test was not done, or was attempted but did not generate a result. Should be null or have a value of NOT DONE. | Perm |
| BSREASND | Reason Test Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with BSSTAT when value is NOT DONE. | Perm |
| BSNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor (e.g., laboratory) that provided the test results. | Perm |
| BSSPEC | Specimen Type | Char | (SPECTYPE)(GENSMP) | Record Qualifier | Defines the type of specimen used for a measurement. Examples: SERUM, PLASMA, URINE, SOFT TISSUE. | Perm |

### BS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BSANTREG | Anatomical Region of Specimen | Char | * | Variable Qualifier | Defines the specific anatomical or biological region of a tissue, organ specimen or the region from which the specimen is obtained, as defined in the protocol, such as a section or part of what is described in the BSSPEC variable. Examples: CORTEX, MEDULLA, MUCOSA. | Perm |
| BSSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Defines the condition of the specimen. Examples: HEMOLYZED, ICTERIC, LIPEMIC. | Perm |
| BSMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: SPECTROPHOTOMETRY, ELECTROPHORESIS. | Perm |
| BSBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. | Perm |

### BS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| BSDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date and time of specimen collection. | Exp |
| BSDY | Study Day of Specimen Collection | Num |  | Timing | Study day of specimen collection relative to the sponsor-defined RFSTDTC. | Perm |
| BSTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See BSTPTNUM and BSTPTREF. | Perm |
| BSTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of BSTPT used in sorting. | Perm |

### BS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| BSELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Elapsed time relative to a planned fixed reference (BSTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date time variable, but an interval, represented as ISO duration. | Perm |
| BSTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by BSELTM, BSTPTNUM, and BSTPT. Examples: PREVIOUS DOSE, PREVIOUS MEAL. | Perm |
| BSRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by BSTPTREF. | Perm |

### BS Assumptions

1. The BS domain is used to store findings related to specimen handling and specimen characteristics such as type, amount, or size. BS is not restricted to

PGx-related specimens.

2. For biospecimens of genetic material, BSSPEC values are drawn from the GENSMP (C111114) codelist.

3. Non-genetic BSSPEC values are drawn from the SPEC (C77529) codelist, which is part the SEND terminology listing. BSANTREG is used to further

define BSSPEC when it is desirable to identify a specific region within an organ.

4. To adapt BS for use with the SDTMIG, use the SPECTYPE (C78734) codelist in BSSPEC, add --LOC, --LAT, --DIR, and --PORTOT as applicable,

and remove BSANTREG. Values that would otherwise have gone in BSANTREG may be placed in a supplemental qualifier that is almost identical to that variable, but which further qualifies BSLOC instead of BSSPEC.

5. The following variables generally would not be used in BS: --POS, --ORNLO, --ORNHI, --STRNLO, --STNRHI, --STNRC, --NRIND, --LEAD, --

CSTATE, --ACPTFL, --FAST, --TOX, --TOXGR, --SEV, --DTHREL.

## Cell Phenotype Findings (CP)

*Structure: One record per test per specimen per timepoint per visit per subject.*

A findings domain that contains data related to the characterization of cell phenotype, lineage, and function based on expression of specific markers in single cell or particle suspensions.

The CP domain is modeled for use with disseminated tissue specimens (e.g., blood and other body fluids, bone marrow aspirates) and cell suspensions, and is not currently modeled for evaluations of solid tissue specimens. The domain is intended to support tests associated with a cell phenotyping component based on the use of markers and is not intended for tests that are not associated with marker-based phenotyping, which are more appropriate to include in another domain (e.g., Immunogenicity Specimen Assessments (IS), Laboratory Test Results (LB), Microscopic Findings (MI)). The CP domain is not intended to supplant use of the LB domain for routine lab hematology (e.g., blood cell differentials), nor is it intended for findings originating from microscopic assessment of cells, including those employing immunohistochemical (IHC) techniques.

The modeled use cases include measurement of

• cell populations identified, classified, and/or otherwise characterized based on the differential expression of phenotypic and/or cell state/function markers, as determined for both normal and abnormal cell populations;

• the level of marker expression;

• substances interacting with (e.g., binding to) a marker which is a target of interest (not limited to a pharmacologic target); and

• other cell properties based on characterization of expression marker(s) and/or substances that interact with the marker(s).

To provide the flexibility needed to report cell marker expression data, which can range widely in complexity, several new SDTM variables have been created. Most of the new variables are permissible, and are available as needed to fully define a test and/or to prevent ambiguity that could lead to misunderstanding or difficulty in interpreting the data. New variables include --SBMRKS (Sublineage Marker String), -- CELSTA (Cell State), --CSMRKS (Cell State Marker String), --TSTCND (Test Condition), --CNDAGT (Test Condition Agent), --BNDAGT (Binding Agent), --ABCLID (Antibody Clone Identifier), --MRKSTR (Marker String), --GATE (Gate Name), --GATEDEF (Gate Definition), --SPTSTD (Sponsor Test Description), --TSTPNL (Test Panel), --RESSCL (Result Scale), and --RESTYP (Result Type). Definitions and appropriate use of these variables are provided in the Specification and Assumptions sections of this guidance and are illustrated in the examples for selected use cases.

Data submitters should work closely with laboratory data providers, analysts, and data receivers/users to determine the appropriate set of permissible variables to include in a dataset (i.e., the variables needed to fully document tests and associated findings for a particular use case).

Used in accordance with this guidance, the complete marker sting information provided in the --MRKSTR variable reflects the operational (i.e., laboratoryspecific) definition of the test measurement. Together with the gating information provided in the --GATE and --GATEDEF variables, --MRKSTR values help to ensure that proper groupings and comparisons are made across tests by preserving nuanced details that may affect the interpretation of test results. To facilitate these objectives and to enable accurate cross-study comparisons and data-mining efforts, it is recommended that --MRKSTR values conform as closely as possible to marker string formatting principles presented in the CP Assumptions section.

### CP Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | CP | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| CPSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| CPGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| CPREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier. | Perm |
| CPSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on the lab page. | Perm |

### CP Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| CPLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| CPTESTCD | Test or Examination Short Name | Char | (CPTESTCD) | Topic | Short name of the measurement, test, or examination described in CPTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in CPTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). CPTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "MONO", "MNS". | Req |

### CP Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPTEST | Name of Measurement, Test or Examination | Char | (CPTEST) | Synonym Qualifier | Long name for CPTESTCD. For cell phenotyping, the name (often abbreviated) of the cell population, as it is generally accepted by the scientific community, is populated (rather than a colloquial designation based on a primary marker, e.g., TLym Help rather than CD4). When the test is for a sublineage which can only be identified by specifying additional markers (i.e., has not been given a name) or which is further restricted to a subpopulation based on a particular cell state (e.g., activated, proliferating, apoptotic), the Sublineage Marker String (CPSBMRKS), Cell State (CPCELSTA), and Cell State Marker String (CPCSMRKS) variables are additionally populated and the value in CPTEST is suffixed with "Sub" to denote that it is a subset of the population identified in CPTEST (e.g., Monocytes Sub). The value in CPTEST cannot be longer than 40 characters. | Req |

### CP Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPSBMRKS | Sublineage Marker String | Char |  | Variable Qualifier | Used to further subset the cell population identified in CPTEST based on the use of additional marker(s) that define a sublineage. The value in CPSBMRKS is used in combination with values in CPTEST and CPCELSTA to fully describe the cell population being measured. As such, it is an essential component of the full test name. For example, three unnamed sublineages of monocytes have been identified as: CCR2+CD16-, CCR2- CD16+, and CCR2+CD16+. Whereas the entire monocyte cell population can be defined as CD14+ cells, the additional CCR2 and CD16 markers are used to differentiate one sublineage from another. As none of these sublineages have been given names, they are only known by the CCR2 and CD16 marker combinations. By associating the CPTEST value of "Monocytes Sub" with, for example, a value of "CCR2+CD16-" in CPSBMRKS, the full test is defined to be the CCR2+CD16- monocyte subpopulation. | Perm |

### CP Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPCELSTA | Cell State | Char | (CELSTATE) | Variable Qualifier | A textual description of a subset of the cell population identified in CPTEST based on a particular functional and/or biological state (e.g., "ACTIVATED", "PROLIFERATING", "SENESCENT"). When populated, the values in CPCELSTA and CPSMRKS, in combination with the values in CPTEST and CPSBMRKS, fully describe the cell population being measured. | Perm |

### CP Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPCSMRKS | Cell State Marker String | Char |  | Variable Qualifier | Identifies the marker(s) or indicator(s) used to define the cell state (i.e., the value in CPCELSTA). For example, when Ki67 expression is used to determine that a cell population is in a proliferating state (i.e., CPCELSTA value="PROLIFERATING"), the value "Ki67+" in CPCSMRKS indicates that positive expression of Ki67 was used to define the population as proliferating. Similarly, a value of "Ki67-" in CPCSMRKS would indicate that lack of expression of Ki67 defined the "NON-PROLIFERATING" cell state in CPCELSTA. The CPCSMRKS value is useful for quickly determining which marker(s) were used to classify (i.e., operationally define) a cell population based on a functional/biological state. | Perm |

### CP Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPTSTCND | Test Condition | Char | (TESTCOND) | Variable Qualifier | Identifies any planned condition imposed by the assay system on the specimen at the time the test is performed. --TSTCND is generally used to distinguish between two or more records where the same assay is performed under varying (as opposed to fixed) conditions, usually for the purpose of making a comparison. For example, when the same assay (identified in --TEST) is performed under stimulated and non-stimulated conditions, the --TSTCND variable is used distinguish between the records. | Perm |
| CPCNDAGT | Test Condition Agent | Char |  | Record Qualifier | The textual description of the agent, if applicable, used to impose the condition identified in CPTSTCND. For example, records might be produced for the same assay run under stimulating (CPTSTCND value = "STIMULATED") conditions produced by different stimulating agents (e.g., phorbol myristate acetate, concanavalin A, PHA-P, TNF-alpha, Ionomycin, candida antigen). | Perm |

### CP Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPBDAGNT | Binding Agent | Char |  | Record Qualifier | The textual description of the agent that is binding to the entity in the CPTEST variable. The CPBDAGNT variable is used to indicate that there is a binding relationship between the entities in the CPTEST and CPBDAGNT variables, regardless of direction. The binding agent may be, but is not limited to, a test article; a portion of a test article; a substance related to a test article; an endogenous molecule; an allergen; an infectious agent; or a reagent (e.g., primary antibody) that confers the binding specificity for the measurement defined in CPTEST when it is needed to uniquely identify the test. | Perm |
| CPABCLID | Antibody Clone Identifier | Char |  | Record Qualifier | Identifies the antibody clone (e.g., supplier-provided catalog name) used to confer specificity for the binding agent specified in CPBDAGNT. | Perm |

### CP Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPMRKSTR | Marker String | Char |  | Record Qualifier | The text string identifying the full set of markers/indicators used by the laboratory to operationally define the complete test based on the combination of CPTEST, CPSBMRKS, and CPCELSTA. Because laboratories often use different markers/indicators to identify a cell population, the relationship between a named cell population in CPTEST (as combined with CPSBMRKS and CPCELSTA values) and the set of markers used to identify that population is many-to-one. To ensure nuances important for accurately interpreting the data are accounted for and which arise from the use of different sets of markers, it is necessary to operationally define the test in terms of the complete set of markers/indicators used to perform that test. | Exp |

### CP Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPGATE | Gate | Char |  | Record Qualifier | The sponsor-defined name assigned to a gate. Gates are electronic (i.e., a device setting or software- defined) boundaries set by a user to virtually parse a specimen into discrete populations based on a set of defined characteristics (e.g., presence, absence, or intensity of expression of various markers; physical size; internal complexity or granularity). Gates are used to constrain data collection or analysis to a specific cell population or region of interest within the specimen. | Perm |

### CP Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPGATDEF | Gate Definition | Char |  | Record Qualifier | The text string identifying the set of parameters and the order in which they are applied to define the gating strategy. In practice, a series of 2-dimensional sub-gates based on different cell characteristics (i.e., markers/indicators/physical properties) are most often combined until the cell population of interest is sufficiently resolved (i.e., electronically isolated) from other cell populations contained within the specimen. For complex analyses, differences in gating strategies can produce subtle differences in results obtained for a test. To ensure nuances important for accurately interpreting the data are accounted for and which arise from the use of different gating strategies, it is often necessary to qualify the test in terms of the gating strategy. For some purposes, however, and at the discretion of the sponsor, only the ultimate or penultimate gate is identified. When specifying the gating strategy in CPGATDEF, each sub- gate should be listed in the order it was applied and separated from the next sub-gate using the pipe/vertical line ("\|") character. | Perm |

### CP Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPSPTSTD | Sponsor Test Description | Char |  | Record Qualifier | Sponsor's description of a test. The variable is intended to contain highly structured test description metadata used by a sponsor to unambiguously define (label) a test. Such values generally reside in a sponsor/laboratory test metadata repository. CPSPTSTD is not intended for unstructured (spontaneous) free text. An example of appropriate usage is when it is necessary to include identifying information for a target cell population on which a test is conducted when the target population is not part of the test name, e.g., tests for quantitative expression of a particular marker on a specific cell population. | Perm |
| CPCAT | Category | Char | (CPCAT) | Grouping Qualifier | Used to define a category of topic-variable values across subjects. Examples: "IMMUNOPHENOTYPING", "CELL FUNCTION", "TARGET ENGAGEMENT". | Perm |
| CPSCAT | Subcategory | Char |  | Grouping Qualifier | A further categorization of CPCAT. | Perm |

### CP Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPTSTPNL | Test Panel | Char |  | Grouping Qualifier | Sponsor-defined textual description used to group tests run together as part of a test panel. Can be used with --GRPID to ensure that relationships between associated tests are accurately identified. | Perm |
| CPORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| CPORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for CPORRES. Examples: "10^6/L", "%", "MESF". | Perm |
| CPRESSCL | Result Scale | Char | (RSLSCLRS) | Record Qualifier | Classifies the scale of the original result value with respect to whether the result is quantitative, ordinal, nominal, or narrative. | Perm |
| CPRESTYP | Result Type | Char | (RESTYPRS) | Record Qualifier | Classifies the kind of result (i.e., property type) originally reported for the test. Examples: "NUMBER CONCENTRATION", "NUMBER FRACTION", "RATIO". | Perm |

### CP Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPCOLSRT | Collected Summary Result Type | Char | (COLSTYP) | Record Qualifier | Used to indicate the type of collected summary result. This includes source summary results collected on a CRF or provided by an external vendor (e.g., central lab). If the summary result is derived using individual source data records, this summary result should be represented in ADaM. If a sponsor has both a collected summary result and a derived summary result, the collected summary result should be represented in SDTM and the derived summary result should be represented in ADaM. | Perm |
| CPORNRLO | Reference Range Lower Limit in Orig Unit | Char |  | Variable Qualifier | Lower end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Perm |
| CPORNRHI | Reference Range Upper Limit in Orig Unit | Char |  | Variable Qualifier | Upper end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Perm |

### CP Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPSTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from CPORRES in a standard format or in standard units. CPSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in CPSTRESN. | Exp |
| CPSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from CPSTRESC. CPSTRESN should store all numeric test results or findings. | Perm |
| CPSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for CPSTRESC or CPSTRESN. | Perm |
| CPSTNRLO | Reference Range Lower Limit-Std Units | Num |  | Variable Qualifier | Lower end of reference range for continuous measurements for CPSTRESC/CPSTRESN in standardized units. Should be populated only for continuous results. | Perm |

### CP Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPSTNRHI | Reference Range Upper Limit-Std Units | Num |  | Variable Qualifier | Upper end of reference range for continuous measurements in standardized units. Should be populated only for continuous results. | Perm |
| CPNRIND | Reference Range Indicator | Char | (NRIND) | Variable Qualifier | Indicates where the value falls with respect to reference range defined by CPORNRLO and CPORNRHI, CPSTNRLO and CPSTNRHI, or by CPSTNRC. Examples: "NORMAL", "ABNORMAL", "HIGH", "LOW". Sponsors should specify in the study metadata (Comments column in the Define-XML document) whether CPNRIND refers to the original or standard reference ranges and results. CPNRIND should not be used to indicate clinical significance. | Perm |
| CPSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that the test was not performed or that it was attempted but did not generate a result. Should be null if a result exists in CPORRES. | Perm |

### CP Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a test was not performed, e.g., "BROKEN EQUIPMENT", "SUBJECT REFUSED", "SPECIMEN LOST". Used in conjunction with CPSTAT when value is "NOT DONE". | Perm |
| CPNAM | Vendor Name | Char |  | Record Qualifier | The name or identifier of the laboratory that performed the test. | Perm |
| CPLOINC | LOINC Code | Char | LOINC | Synonym Qualifier | Code for the test from the LOINC code system. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the Define-XML external codelist attributes. | Perm |
| CPSPEC | Specimen Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. Examples: "BLOOD", "BONE MARROW". | Perm |
| CPSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | The physical state or quality of a specimen for an assessment. Example: "CLOTTED". | Perm |

### CP Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Example: "FLOW CYTOMETRY". | Perm |
| CPANMETH | Analysis Method | Char |  | Record Qualifier | Analysis method applied to obtain a summarized result. Analysis method describes the method of secondary processing applied to a complex observation result. | Perm |
| CPLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| CPBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. The value should be "Y" or null. | Perm |

### CP Variables (part 19)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records, or do not come from the CRF, or are not as originally received or collected are examples of records that might be derived for the submission datasets. If CPDRVFL = "Y", then CPORRES may be null, with CPSTRESC and (if numeric) CPSTRESN having the derived value. | Perm |
| CPCLSIG | Clinically Significant, Collected | Char | (NY) | Record Qualifier | Used to indicate whether a collected observation is clinically significant based on judgement. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |

### CP Variables (part 20)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| CPDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of specimen collection represented in ISO 8601 character format. | Exp |
| CPDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Study day of specimen collection, measured in integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC value in Demographics. | Perm |

### CP Variables (part 21)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a specimen is to be taken, as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point (i.e., to the value in CPTPTREF). Example: "1 hour post". | Perm |
| CPTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of CPTPT to aid in sorting. When CPTPT is represented as an elapsed time relative to a fixed reference point (i.e., to the value in CPTPTREF), the values in CPTPTNUM should be assigned in ascending order relative to the value in CPTPTREF. For example, records for time points where CPTPT = "5 minutes post", 1 hour post", and "4 hours post" could be represented in CPTPTNUM as "1", "2", and "3", which maintains the order between CPTPT and CPTPTNUM with respect to the fixed time point reference in CPTPTREF. | Perm |

### CP Variables (part 22)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CPELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to the planned fixed reference value in CPTPTREF, represented in ISO 8601 duration format. Examples: "-PT15M" to represent 15 minutes prior to the reference time point indicated by CPTPTREF, "T8H" to represent 8 hours after the reference time point represented by CPTPTREF. | Perm |
| CPTPTREF | Time Point Reference | Char |  | Timing | Descriptive name of the fixed reference point referred to by CPTPT, CPTPTNUM, and CPELTM. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| CPRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by CPTPTREF. | Perm |

### CP Assumptions

1. The Cell Phenotype domain captures cell phenotyping and related data based on cell expression markers

and other indicators (e.g., stains/dyes) in disseminated tissue specimens and cell suspensions.

2. The CP domain is only used for tests which include a phenotyping component that relies on using cell

markers to identify a specific population of cells (e.g., quantitative cell phenotyping), or on which the test is conducted (e.g., quantitative single marker expression, target/receptor occupancy). For example, a test which measures gamma-interferon expression in helper T lymphocytes defined as the CD45+CD3+CD4+CD8- population is an appropriate test for including in CP, whereas a test which measures gamma interferon secretion in an undefined "PBMC" (peripheral blood mononuclear cell) population is not appropriate.

3. A value which is calculated and reported by a lab according to its procedures is considered collected rather

than derived; the Derived Flag (CPDRVFL) should be null for these results.

4. CPCELSTA is used in conjunction with CPSCMRKS. When CPCELSTA is populated, CPSCMRKS must

also be populated. Conversely, when CPSCMRKS is populated, CPCELSTA must be populated.

5. The combination of values in CPTEST, CPSBMRKS, CPCELSTA, and CPCSMRKS are used to uniquely

identify a test. When 1 or more of the variables CPSBMRKS, CPCELSTA, or CPCSMRKS are populated, the Test Name (CPTEST) must be populated with the test name variant containing the "Sub" suffix to indicate that the finding/result pertains to a subpopulation of the cell type named in CPTEST.

6. Populating the CPTEST and CPMRKSTR variables: The general structure of CPTEST depends on the use

case (e.g., immunophenotyping, quantitative marker expression, target/receptor occupancy), which is generally conveyed by the CPCAT and/or CPSCAT value(s). Currently, CP supports the following use cases for which guidance on CPTEST and CPMRKSTR values are given:

a. Immunophenotyping

i. CPTEST is populated with the name of the cell type being measured, not with the set of markers

used to define the cell type.

ii. It is expected that CPMRKSTR is populated, and that it contains the entire set of markers used to

define the test, including those that are also present in CPSBMRKS and/or CPCSMRKS.

iii. Marker strings follow, as closely as possible, formatting recommendations presented in

assumption 8.

b. Quantitative single-marker expression

i. CPTEST begins with the identity of the marker (e.g., CD99), followed by the word "Expression"

(e.g., "CD99 Expression").

ii. It is expected that CPMRKSTR is populated, and that it starts by identifying the marker being

quantified (e.g. "CD99"). This is followed by a delimiter (described below) and then the entire marker string used to define the cell population on which the marker is measured, including the marker being quantified, since it also defines the cell population.

iii. The general form of the delimiter used to separate the marker being quantified from the cell

population on which it is measured is "<space>xxxx<space>", where "xxxx" represents a character string used as delimiting text. It is recommended that the delimiting text is the abbreviation for the unit of measure used to report the level of expression of the quantified marker (e.g., "MESF", "MdFI"). An example which follows this guidance is: CPTEST = "CD99 Expression" and CPMRKSTR = "CD99 MESF CD45+CD3-CD19+CD99+", where "MESF" is the text delimiter and is followed by the entire marker string defining the cell population on which CD99 was measured, which includes the CD99 marker itself.

iv. Marker strings follow, as closely as possible, formatting recommendations presented in

assumption 8.

c. Other use cases (e.g., target/receptor occupancy), refer to the examples section and to published Controlled Terminology supporting CP. In the case of target/receptor occupancy a more generalized test value is populated into CPTEST (e.g., "Total Bound") and the identity of the target/receptor is

7. Specifying viability:

a. Because the majority of cell phenotyping tests of interest are for viable cells, the word "Viable" is not generally included in the test name (CPTEST) and usually does not need to be explicitly stated in CPCELSTA. Because populating CPCELSTA and CSMRKS with viability information necessitates appending the "Sub" suffix to the value in CPTEST (assumption 5), it is recommended that CPCELSTA and CPCSMRKS generally not be used unless a selective viability stain was included in the test in order to differentiate the record for viable cells from record(s) for cells in a different vital state. For example, when viable cells are being compared to apoptotic and/or non-viable cells, it is necessary to differentiate those records using CPCELSTA and CPCSMRKS. In such cases where CPCELSTA and CPCSMRKS are populated, the "Sub" suffix is appended to the value in CPTEST (assumption 5).

b. Viability marker(s) used to define a test are included in the full marker string in CPMRKSTR

regardless of whether the viability status is stated explicitly in CPCELSTA. Moreover, if viability is explicitly stated in CPGATE, marker(s) used to designate viability are included in CPGATDEF. For example, if the value in CPGATE is "Lymphocytes, Viable" and 7AAD- was used to define the viable state, 7AAD- is included in CPGATDEF, in addition to being included in the complete marker string in CPMRKSTR.

8. Recommended formatting of marker string variables CPMRKSTR, CPSBMRKS, and CPCSMRKS: The

marker string variables provide critical information for defining a test. Although there are no current plans to control their values through CDISC Controlled Terminology codelists, adherence to the following formatting guidelines helps to preclude ambiguities that can lead to uncertainty in uniquely understanding a test and its associated result.

a. Marker strings do not contain delimiting characters (e.g., ",", space, "/", "|") to separate individual markers within the string, nor do they contain punctuation (e.g., hyphens) within individual markers, as these can be confused with symbols used to designate levels of expression and/or make it difficult to distinguish between the individual markers that comprise the string. For example, although the scientific literature often uses "HLA-DR", this is represented in CP marker strings as "HLADR".

b. Forward slash "/" is only used to separate the portion of the marker string defining a numerator from

the portion defining a denominator.

c. When referring to a marker using the cluster of differentiation (CD) designation, "CD" should be included as part of the marker reference. For example, a marker string for helper T lymphocytes comprising CD45, CD3, CD4, and CD8 markers would be "CD45+CD3+CD4+CD8-" (rather than "45+3+4+8-").

d. The order of markers within a string is consistent across similar tests, generally proceeding in the order

that defines the cell hierarchy from highest to lowest, followed by additional non-lineage-defining markers, and ending with cell state and viability markers. This order maintains alignment with how a test is identified using the ordered combination of CPTEST, CPSMRKS, and CPCELSTA. For example, a test for proliferating viable activated central memory helper T-lymphocytes would be operationally defined in CPMRKSTR as similar to "CD45+CD3+CD19-CD4+CD8-CD197+CD45RACD278+Ki67+7AAD-", where the order of markers in the string is "CD45" (leukocyte), "CD3+CD19- (T lymphocyte), "CD4+CD8-" (helper), "CD197+CD45RA-" (central memory), "CD278+ (activated), Ki67+ (proliferating), 7AAD- (viable). Corresponding to this marker-based definition of the test, and using the appropriate Controlled Terminology terms, CPTEST is "TLym Help Cen Mem Sub", CPCELSTA is "ACTIVATED; PROLIFERATING", and CPCSMRKS is "CD278+Ki67+". If the sponsor also chose to include the viability status as a cell state in addition to the activation and proliferative states, CPCELSTA would be similar to "ACTIVATED; PROLIFERATING; VIABLE" and the corresponding CPCSMRKS value would be "CD278+Ki67+7AAD-". In this example, the named cell population in CPTEST has not been further divided into an unnamed sublineage based on additional sublineage markers; therefore, CPSBMRKS is null.

f. Indicating the expression level of individual markers included in a marker string: A variety of formats are used in the scientific literature for indicating the level of expression of a marker on or within a cell. For example, after identifying a marker such as CD4, its level of expression might be represented as 1 of the following:

i. neg, min, or - to denote the absence or minimal expression (e.g., CD4neg, CD4min, CD4-)

ii. pos or + to denote that the marker is expressed (e.g., CD4pos, CD4+)

iii. high, hi, or ++ to denote that the marker is expressed at a very high level relative to simply being

"positive" (e.g., CD4high, CD4hi, CD4++)

iv. other formats (e.g., -/low, -/lo, low, lo, mid, -/+, +++)

g. Because categories for expression levels are subjective in the sense that they are relative to one

another, various formats often overlap, which can create ambiguities. Some degree of consistency in formats used to represent relative expression levels is warranted to mitigate ambiguity, at least to the extent that relative expression levels used to define cell lineages/sublineages are similar across studies and laboratories in order to enable comparisons. Five designations are recommended for use in SDTM datasets:

i. "-" (the marker is not expressed; at times, the use of "-lo" may be justified to indicate that the

marker is either not expressed or is present in a negligible amount)

ii. "lo" (the marker is expressed at a low level)

iii. "mid" (the marker is expressed somewhere between a low and "normal" positive level for that cell

type)

iv. "+" (the marker is expressed at a normal positive level for that cell type)

v. "hi" (the marker is expressed at a distinctly higher level than in cells that are "+", such that they

are distinguishable from the "+" population and define their own subpopulation)

vi. Although these designations are expected to be useful in the majority of cases, it is recognized

that designations not listed here may be more appropriate in some cases. The data provider must determine the best way to designate an expression level suited to the purpose of the test, while striving to mitigate ambiguities resulting from lack of consistency of use.

h. Explicitly indicating the cellular sublocation for a marker: In most cases, the location of a marker on or

within a cell is not necessary; however, there are situations in which a marker can be expressed in more than a single cellular compartment and there is a need for the test to distinguish between marker expression in one compartment versus another. To accommodate this, using a lowercase letter in front of the marker is recommended. The cell sublocations are usually related to the cell surface (plasma membrane), cytoplasm, and nucleus. Use m, c, or n in front of the marker to denote "membrane", "cytoplasm", and "nucleus", respectively. An example of a marker often associated with a need to indicate cell location is CD152 (CTLA4), where cytoplasmic expression may define a test to distinguish it from whole cell expression. In this case, "cCD152" is used to denote that it is the cytoplasmic expression of CD152 that is measured for the test.

## Genomics Findings (GF)

*Structure: One record per finding per observation per biospecimen per subject, Tabulation.*

A findings domain that contains data related to the structure, function, evolution, mapping, and editing of subject and non-host organism genomic material of interest. This domain includes but is not limited to assessments and results for genetic variation and transcription, and summary measures derived from these assessments. The GF domain is used for findings from characteristics assessed from nucleic acids and may include subsequent inferences and/or predictions about related proteins/amino acids.

### GF Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | GF | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | Sponsor-defined identifier for a device. | Perm |
| NHOID | Non-Host Organism Identifier | Char |  | Identifier | Sponsor-defined identifier for a non-host organism which should only be used when the organism is the subject of the TEST. This variable should be populated with an intuitive name based on the identity of the non-host organism as reported by a lab (e.g., "A/California/7/2009 (H1N1)"). It is not to be used as a qualifier of the result in the record on which it appears. | Perm |

### GF Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| GFGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. | Perm |
| GFREFID | Reference ID | Char |  | Identifier | A unique identifier for the assayed genetic specimen. | Exp |
| GFSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| GFLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| GFLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |

### GF Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFTESTCD | Short Name of Genomic Measurement | Char | (GFTESTCD) | Topic | Short name of the measurement, test, or examination described in GFTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in GFTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). GFTESTCD cannot contain characters other than letters, numbers, or underscores. | Req |
| GFTEST | Name of Genomic Measurement | Char | (GFTEST) | Synonym Qualifier | Long name for GFTESTCD. The value in GFTEST cannot be longer than 40 characters. | Req |
| GFTSTDTL | Measurement, Test, or Examination Detail | Char | (GFTSDTL) | Variable Qualifier | Description of a reportable qualifying the assessment in GFTESTCD and GFTEST. | Perm |
| GFCAT | Category for Genomic Finding | Char |  | Grouping Qualifier | Used to define a category of topic-variable values. | Perm |

### GF Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFSCAT | Subcategory for Genomic Finding | Char |  | Grouping Qualifier | Used to define a further categorization of GFCAT values. | Perm |
| GFORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| GFORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for GFORRES. | Perm |
| GFORREF | Reference Result in Original Units | Char |  | Variable Qualifier | Reference value for the result or finding as originally received or collected. GFORREF uses the same units as GFORRES, if applicable. | Perm |
| GFSTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from GFORRES, in a standard format or in standard units. GFSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in GFSTRESN. | Exp |

### GF Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from GFSTRESC. GFSTRESN should store all numeric test results or findings. | Perm |
| GFSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for GFSTRESC, GFSTRESN, GFSTREFC, and GFSTREFN. | Perm |
| GFSTREFC | Reference Result in Standard Format | Char |  | Variable Qualifier | Reference value for the result or finding copied or derived from GFORREF in a standard format. | Perm |
| GFSTREFN | Numeric Reference Result in Std Units | Num |  | Variable Qualifier | Reference value for continuous or numeric results or findings in standard format or in standard units. GFSTREFN uses the same units as GFSTRESN, if applicable. | Perm |
| GFRESCAT | Result Category | Char |  | Variable Qualifier | Used to categorize the result of a finding. | Perm |
| GFINHERT | Inheritability | Char | (INHERTGF) | Variable Qualifier | Identifies whether the variation can be passed to the next generation. | Perm |

### GF Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFGENREF | Genome Reference | Char |  | Variable Qualifier | An identifier for the genome reference used to generate the reported result. For example, Genome Reference Consortium Human Build 38 patch release 13 may be represented as "GRCh38.p13". | Perm |
| GFCHROM | Chromosome Identifier | Char |  | Variable Qualifier | The designation (name or number) of the chromosome or contig on which the variant or other feature appears (e.g., "17"; "X"). | Perm |
| GFSYM | Genomic Symbol | Char | * | Variable Qualifier | A published symbol for the portion of the genome serving as a locus for the experiment/test. | Perm |
| GFSYMTYP | Genomic Symbol Type | Char | (SYMTYPGF) | Variable Qualifier | A description of the type of genomic entity that is represented by the published symbol in GFSYM. | Perm |
| GFGENLOC | Genetic Location | Char |  | Variable Qualifier | Specifies the location within a sequence for the observed value in GFORRES. | Perm |

### GF Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFGENSR | Genetic Sub-Region | Char |  | Variable Qualifier | The portion of the locus in which the variation was found. Examples: "Exon 15", "Kinase domain". | Perm |
| GFSEQID | Sequence Identifier | Char |  | Variable Qualifier | A unique identifier for the sequence used as the reference to identify the genetic variation in the result. Examples: "NM 001234", "ENSG00000182533", "ENST00000343849.2". | Perm |
| GFPVRID | Published Variant Identifier | Char |  | Variable Qualifier | _ A unique identifier for the variation that has been publicly characterized in an external database. Examples: "rs2231142", "COSM41596". | Perm |
| GFCOPYID | Copy Identifier | Char |  | Variable Qualifier | An arbitrary identifier used to differentiate between copies of a genetic target of interest present on homologous chromosomes. | Perm |
| GFSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |

### GF Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFREASND | Reason Test Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with GFSTAT when value is "NOT DONE". | Perm |
| GFXFN | External File Path | Char |  | Record Qualifier | The filename and/or path to external data not stored in the same format and possibly not the same location as the other data for a study. | Perm |
| GFNAM | Laboratory/Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor that provided the test result. When more than 1 vendor is involved in the generation of the result, additional vendors should be represented as supplemental qualifiers. | Perm |
| GFSPEC | Specimen Material Type | Char | (GENSMP) | Record Qualifier | Identifies the type of genetic material used for the measurement. | Perm |
| GFMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | The test method by which the examination is performed by the wet lab in order to yield the result reported in the dataset. | Exp |

### GF Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFRUNID | Run ID | Char |  | Record Qualifier | A unique identifier for a particular run of a test performed by the wet lab on a particular batch of samples. This identifier can be used to distinguish between records for the same test performed at different times. | Perm |
| GFANMETH | Analysis Method | Char | (GFANMET) | Record Qualifier | The method of secondary processing performed by the dry lab to yield the result reported in the dataset. | Perm |
| GFBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. | Perm |
| GFDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| GFLLOQ | Lower Limit of Quantitation | Num |  | Variable Qualifier | Indicates the lower limit of quantitation for an assay. Units will be those used for GFSTRESU. | Perm |

### GF Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFREPNUM | Repetition Number | Num |  | Record Qualifier | The instance number of a test that is repeated within a given timeframe for the same test performed by the wet lab. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| GFDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date and time of specimen collection. | Exp |
| GFDY | Study Day of Specimen Collection | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### GF Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See GFTPTNUM and GFTPTREF. | Perm |
| GFTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of GFTPT used in sorting. | Perm |
| GFELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Elapsed time relative to a planned fixed reference (GFTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date time variable, but an interval, represented as ISO duration. | Perm |
| GFTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by GFELTM, GFTPTNUM, and GFTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |

### GF Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| GFRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by GFTPTREF. | Perm |

### GF Assumptions

1. The Genomics Findings domain is used to represent findings related to the structure, function, evolution, mapping, and editing of subject and non-host

organism genomic material of interest. This domain includes but is not limited to assessments and results for genetic variation and transcription, and summary measures derived from these assessments. The GF domain is used for findings from characteristics assessed from nucleic acids and may include subsequent inferences and/or predictions about related proteins/amino acids. However, direct assessments of proteins (e.g., assessments of amino acids) are out of scope for this domain.

2. Regarding genetic testing on non-host organisms (including but not limited to bacteria, viruses, and parasites), the following additional assumptions

apply:

a. Tests that give genetic results (e.g., expressed in terms of genetic variation, specific sequence information) on non-host organisms that have been identified in subject samples should be represented in GF. To distinguish these findings from subject genetic data, the variable NHOID must be populated to identify the non-host organism as the focus of the record (see Section 9.2, Non-host Organism Identifiers, assumption 2 for more information).

b. If the purpose of the test is to detect or determine the identity of a viable, non-host organism or infectious agent in a subject sample, data should be

represented in the Microbiology Specimen (MB) domain.

c. Tests that are used to determine the resistance/susceptibility of a non-host organism to a drug on a genetic basis should be represented in the Microbiology Susceptibility (MS) domain.

## Immunogenicity Specimen Assessments (IS)

*Structure: One record per test per visit per subject, Tabulation.*

A findings domain for assessments of antigen induced humoral or cell-mediated immune response in the subject.

### IS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | IS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| NHOID | Non-host Organism ID | Char |  | Identifier | Sponsor-defined identifier for a non-host organism which should only be used when the organism is the subject of the TEST. This variable should be populated with an intuitive name based on the identity of the non-host organism as reported by a lab (e.g., "A/California/7/2009 (H1N1)"). It is not to be used as a qualifier of the result in the record on which it appears. | Perm |

### IS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| ISGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| ISREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier. Example: "458975-01". | Perm |
| ISSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| ISTESTCD | Immunogenicity Test/Exam Short Name | Char | (ISTESTCD) | Topic | Short name of the measurement, test, or examination described in ISTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in ISTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). ISTESTCD cannot contain characters other than letters, numbers, or underscores. | Req |

### IS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISTEST | Immunogenicity Test or Examination Name | Char | (ISTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in ISTEST cannot be longer than 40 characters. Example: "Immunoglobulin E". | Req |
| ISTSTCND | Test Condition | Char | (TESTCOND) | Variable Qualifier | Identifies any planned condition imposed by the assay system on the specimen at the time the test is performed. | Perm |
| ISCNDAGT | Test Condition Agent | Char |  | Record Qualifier | The textual description of the agent used to impose a test condition. Examples are different stimulating agents used in immunoassays such as those in the Interferon Gamma Response assay (e.g., Mycobacterium tuberculosis ESAT-6, CFP-10, TB 7.7, Mitogen). | Perm |

### IS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISBDAGNT | Binding Agent | Char | (MICROORG)(ISBDAGT) | Variable Qualifier | Text description of the agent that is binding to the entity in the ISTEST variable. ISBDAGNT is used to indicate that there is a binding relationship between the entities in the ISTEST and ISBDAGNT variables, regardless of direction. ISBDAGNT is not a method qualifier. It should only be used when the actual interest of the measurement is the binding interaction between the 2 entities in ISTEST and ISBDAGNT. In other words, the combination of ISTEST and ISBDAGNT should describe the entity or the analyte being measured, without the need for additional variables. The binding agent may be (but is not limited to) a test article, a portion of the test article, a related compound, an endogenous molecule, an allergen, or an infectious agent. | Perm |

### IS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISTSTOPO | Test Operational Objective | Char | (TSTOPOBJ) | Variable Qualifier | Text description of the high-level purpose of the test at the operational level. If populated, valid values are "SCREEN", "CONFIRM", and "QUANTIFY". | Perm |
| ISMSCBCE | Molecule Secreted by Cells | Char |  | Variable Qualifier | Text description of the entity secreted by the cells represented in ISTEST. The combination of ISTEST and ISMSCBCE should describe the entity or the analyte being measured, without the need for additional variables. | Perm |
| ISTSTDTL | Test Detail | Char |  | Variable Qualifier | Further description of ISTESTCD and ISTEST. | Perm |
| ISCAT | Category for Immunogenicity Test | Char | * | Grouping Qualifier | Used to define a category of topic-variable values across subjects. Example: "SEROLOGY". | Perm |
| ISSCAT | Subcategory for Immunogenicity Test | Char | * | Grouping Qualifier | A further categorization of ISCAT. | Perm |
| ISORRES | Results or Findings in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |

### IS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for ISORRES. Examples: "Index Value", "gpELISA", "unit/mL". | Exp |
| ISORNRLO | Reference Range Lower Limit in Orig Unit | Char |  | Variable Qualifier | Lower end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Exp |
| ISORNRHI | Reference Range Upper Limit in Orig Unit | Char |  | Variable Qualifier | Upper end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Exp |
| ISSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from ISORRES, in a standard format or in standard units. ISSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in ISSTRESN. | Exp |

### IS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISSTRESN | Numeric Results/Findings in Std. Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from ISSTRESC. ISSTRESN should store all numeric test results or findings. | Exp |
| ISSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for ISSTRESC and ISSTRESN. Examples: "Index Value", "gpELISA", "unit/mL". | Exp |
| ISSTNRLO | Reference Range Lower Limit-Std Units | Num |  | Variable Qualifier | Lower end of reference range for continuous measurements for ISSTRESC/ISSTRESN in standardized units. Should be populated only for continuous results. | Exp |
| ISSTNRHI | Reference Range Upper Limit-Std Units | Num |  | Variable Qualifier | Upper end of reference range for continuous measurements in standardized units. Should be populated only for continuous results. | Exp |
| ISSTNRC | Reference Range for Char Rslt-Std Units | Char |  | Variable Qualifier | For normal range values that are character in ordinal scale or if categorical ranges were supplied. Examples: "-1 to +1", "NEGATIVE TO TRACE". | Perm |

### IS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISNRIND | Reference Range Indicator | Char | (NRIND) | Variable Qualifier | Indicates where the value falls with respect to reference range defined by ISORNRLO and ISORNRHI, ISSTNRLO and ISSTNRHI, or by ISSTNRC. Examples: "NORMAL", "ABNORMAL", "HIGH", "LOW". Sponsors should specify in the study metadata (Comments column in the Define-XML document) whether ISNRIND refers to the original or standard reference ranges and results. Should not be used to indicate clinical significance. | Exp |
| ISSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate a test was not done. Should be null if a result exists in ISORRES. | Perm |
| ISREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Used in conjunction with ISSTAT when value is "NOT DONE". | Perm |
| ISNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the laboratory or vendor who provided the test results. | Perm |

### IS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISSPEC | Specimen Type | Char | (SPECTYPE) | Record Qualifier | Defines the types of specimen used for a measurement. Example: "SERUM". | Perm |
| ISSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Free or standardized text describing the condition of the specimen. Examples: "HEMOLYZED", "ICTERIC", "LIPEMIC". | Perm |
| ISSPCUFL | Specimen Usability for the Test | Char | (NY) | Record Qualifier | Describes the usability of the specimen for the test. The value will be "N" if the specimen is not usable, and null if the specimen is usable. | Perm |
| ISMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "ELISA", "ELISPOT". | Perm |
| ISLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |

### IS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that ISBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| ISDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Examples of records that might be derived for the submission datasets include those that represent the average of other records, do not come from the CRF, or are not as originally received or collected. If ISDRVFL="Y", then ISORRES may be null, with ISSTRESC and (if numeric) ISSTRESN having the derived value. | Perm |
| ISLLOQ | Lower Limit of Quantitation | Num |  | Variable Qualifier | Indicates the lower limit of quantitation for an assay. Units will be those used for ISSTRESU. | Exp |

### IS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| ISDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |
| ISENDTC | End Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | End date/time of the observation. | Perm |

### IS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to sponsor-defined RFSTDTC in Demographics. | Perm |
| ISENDY | Study Day of End of Specimen Collection | Num |  | Timing | Actual study day of end of observation expressed in integer days relative to the sponsor- defined RFSTDTC in Demographics. | Perm |
| ISTPT | Planned Time Point Name | Char |  | Timing | Text description of time when specimen should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See ISTPTNUM and ISTPTREF. Examples: "Start", "5 min post". | Perm |
| ISTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of ISTPT to aid in sorting. | Perm |

### IS Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| ISELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (ISTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable. Represented as ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by ISTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by ISTPTREF. | Perm |
| ISTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by ISELTM, ISTPTNUM, and ISTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| ISRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, ISTPTREF. | Perm |

### IS Assumptions

1. The Immunogenicity Specimen Assessments (IS) domain holds assessments that describe whether a therapy (e.g., biologic, drug, vaccine)

provoked/caused/induced an immune response in a subject. The response can be either positive or negative. For example, a vaccine is expected to induce a beneficial immune response, whereas a cellular therapy (e.g., erythropoiesis-stimulating agents) may cause an adverse immune response.

2. The IS domain also holds assessments that describe whether an allergen, microorganism, or endogenous molecule provoked/caused/induced an immune

response in a subject, such as a subject's antibody reaction (autoantibodies) against auto/self-antigens for autoimmune studies or antibody production in response to allergens in allergy trials. Expected outputs can be positive or negative, present or absent for the antibody of interest, as well as quantification of the antibody. Assessments pertaining to antibodies produced in response to microbial infection will also be represented in the IS domain.

(HLA) proteins) will also be represented in the IS domain.

4. Certain types of cellular immune responses will also be modeled in IS using non-flow cytometry techniques (see example 6). Flow cytometry data

should be modeled in the Cell Phenotype Findings (CP) domain, section 6.3.5.3.

5. An exception is made to the class of antigen/antibody (Ag/Ab) combination assays. Microbial antigen/antibody (Ag/Ab) combination tests should be

represented in the Microbiology Specimen (MB) domain. An example is fourth-generation HIV Ag/Ab combination tests, which are commonly seen as HIV identification or detection assays rather than tests that provide additional details on and characterization of a subject’s immunological responses. The outputs of these assays can be expected as reactive, non-reactive, or indeterminate. Whereas some tests generate separate outputs for antigen and antibody, others just indicate “reactive” when either or both are detected. Output is generally based on relative light units, where a result of "reactive" typically requires the signal to cutoff ratio to be greater than 1.

6. Measurements of cytokines, chemokines, and complement proteins should be represented in the Laboratory Test Results (LB) domain.

7. The IS domain variable ISBDAGNT (Binding Agent) is currently supported by 2 Controlled Terminology codelists: Microorganism (MICROORG) and

Binding Agent for Immunogenicity Tests (ISBDAGT). Controlled Terminology Rules for Immunogenicity Tests describes how and when to use each codelist (see https://www.cdisc.org/standards/terminology/controlled-terminology).

a. For antidrug antibody (ADA) tests, the ISBDAGNT variable is used to represent the free-text description of the name/identity of the therapy the antidrug antibody targets. CDISC does not control study therapy names (e.g., drugs, biologics). For ADA tests as a part of regulatory agency submissions, the proprietary binding study therapy name(s) should be considered as extended values of the ISBDAGT codelist when represented in Define-XML.

b. For mixed-allergens panel tests, submission values represented in the ISBDAGNT variable should follow this format: “XXX, Multiple” (e.g., Dairy

Mix Antigens, Multiple; Animal Mix Antigens, Multiple; use the plural form for the word “antigen” if needed). Should the sponsor wish to specify the individual antigens in a mixed antigens panel (e.g., ISBDAGNT = “Animal Mix Antigens, Multiple”), put the names of the specific antigens in Suppqual (e.g., Cat, Dog, Cow, Horse; see example 11).

8. The IS domain variable ISTSTOPO (Test Operational Objective) is supported by a nonextensible Controlled Terminology codelist containing the values

SCREEN, CONFIRM, and QUANTIFY.

9. For vaccine studies, in order to distinguish collected data between study vaccine-induced immunogenicity and immunogenicity findings unrelated to the

study vaccine (i.e., immunity as a result of natural infection or previous vaccination), the following ISCAT and ISSCAT values are recommended (see example 5):

a. For immunological data pertaining to the study vaccine, ISCAT = STUDY VACCINE-RELATED IMMUNOGENICITY.

b. For immunological data collected during the vaccine trial but which are not assessments about the study vaccine, ISCAT = NON-STUDY-

RELATED IMMUNOGENICITY.

c. For assessments measuring the induced-antibody response, ISSCAT = HUMORAL IMMUNITY.

d. For assessments measuring the induced-cellular response, ISSCAT = CELLULAR IMMUNITY.

10. Any Identifier variables, Timing variables, or Findings general observation class qualifiers may be added to the IS domain.

## Laboratory Test Results (LB)

*Structure: One record per lab test per time point per visit per subject, Tabulation.*

A findings domain that contains laboratory test data such as hematology, clinical chemistry and urinalysis. This domain does not include microbiology or pharmacokinetic data, which are stored in separate domains.

### LB Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | LB | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| LBSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| LBGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| LBREFID | Specimen ID | Char |  | Identifier | Internal or external specimen identifier. Example: specimen ID. | Perm |
| LBSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on the Lab page. | Perm |

### LB Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBTESTCD | Lab Test or Examination Short Name | Char | (LBTESTCD) | Topic | Short name of the measurement, test, or examination described in LBTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in LBTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). LBTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "ALT", "LDH". | Req |
| LBTEST | Lab Test or Examination Name | Char | (LBTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. Note: Any test normally performed by a clinical laboratory is considered a lab test. The value in LBTEST cannot be longer than 40 characters. Examples: "Alanine Aminotransferase", "Lactate Dehydrogenase". | Req |

### LB Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBTSTCND | Test Condition | Char | (TESTCOND) | Variable Qualifier | Identifies any planned condition imposed by the assay system on the specimen at the time the test is performed. | Perm |

### LB Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBBDAGNT | Binding Agent | Char |  | Variable Qualifier | The textual description of the agent that is binding to the entity in the LBTEST variable. The LBBDAGNT variable is used to indicate that there is a binding relationship between the entities in the LBTEST and LBBDAGNT variables, regardless of direction. LBBDAGNT is not a method qualifier. It should only be used when the actual interest of the measurement is the binding interaction between the 2 entities in LBTEST and LBBDAGNT. In other words, the combination of LBTEST and LBBDAGNT should describe the thing, the entity, or the analyte being measured, without the need for additional variables. The binding agent may be (but is not limited to) a test article, a portion of the test article, a related compound, or an endogenous molecule. | Perm |

### LB Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBTSTOPO | Test Operational Objective | Char | (TSTOPOBJ) | Variable Qualifier | Text description of the high-level purpose of the test at the operational level. | Perm |
| LBCAT | Category for Lab Test | Char | * | Grouping Qualifier | Used to define a category of related records across subjects. Examples: "HEMATOLOGY", "URINALYSIS", "CHEMISTRY". | Exp |
| LBSCAT | Subcategory for Lab Test | Char | * | Grouping Qualifier | A further categorization of a test category. Examples: "DIFFERENTIAL", "COAGULATION", "LIVER FUNCTION", "ELECTROLYTES". | Perm |
| LBORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| LBORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for LBORRES. Example: "g/L". | Exp |
| LBRESSCL | Result Scale | Char | (RSLSCLRS) | Record Qualifier | Classifies the scale of the original result value; for example, whether the result is ordinal, nominal, quantitative, or narrative. | Perm |

### LB Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBRESTYP | Result Type | Char | (RESTYPRS) | Record Qualifier | Classifies the kind of result (i.e., property type) originally reported for the test. Examples include substance concentration, proportion, mass rate, and arbitrary concentration. | Perm |
| LBCOLSRT | Collected Summary Result Type | Char | (COLSTYP) | Record Qualifier | Used to indicate the type of collected summary result. This includes source summary results collected on a CRF or provided by an external vendor (e.g., central lab). If the summary result is derived by the sponsor using individual source data records from SDTM, the derived summary result is represented in ADaM. If the summary result is produced and reported by the lab, the collected summary result is represented in SDTM. | Perm |
| LBORNRLO | Reference Range Lower Limit in Orig Unit | Char |  | Variable Qualifier | Lower end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Exp |

### LB Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBORNRHI | Reference Range Upper Limit in Orig Unit | Char |  | Variable Qualifier | Upper end of reference range for continuous measurement in original units. Should be populated only for continuous results. | Exp |
| LBLLOD | Lower Limit of Detection | Char |  | Variable Qualifier | The lowest threshold (as originally received or collected) for reliably detecting the presence or absence of substance measured by a specific test. The value for the field will be as described in documentation from the instrument or lab vendor. | Perm |

### LB Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBSTRESC | Character Result/Finding in Std Format | Char | (LBSTRESC) | Result Qualifier | Contains the result value for all findings, copied or derived from LBORRES in a standard format or standard units. LBSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in LBSTRESN. For example, if a test has results "NONE", "NEG", and "NEGATIVE" in LBORRES and these results effectively have the same meaning, they could be represented in standard format in LBSTRESC as "NEGATIVE". For other examples, see Original and Standardized Results. | Exp |
| LBSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from LBSTRESC. LBSTRESN should store all numeric test results or findings. | Exp |
| LBSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for LBSTRESC or LBSTRESN. | Exp |

### LB Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBSTNRLO | Reference Range Lower Limit-Std Units | Num |  | Variable Qualifier | Lower end of reference range for continuous measurements for LBSTRESC/LBSTRESN in standardized units. Should be populated only for continuous results. | Exp |
| LBSTNRHI | Reference Range Upper Limit-Std Units | Num |  | Variable Qualifier | Upper end of reference range for continuous measurements in standardized units. Should be populated only for continuous results. | Exp |
| LBSTNRC | Reference Range for Char Rslt-Std Units | Char |  | Variable Qualifier | For normal range values that are character in ordinal scale or if categorical ranges were supplied. Examples: "-1 to +1", "NEGATIVE TO TRACE". | Perm |

### LB Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBNRIND | Reference Range Indicator | Char | (NRIND) | Variable Qualifier | Indicates where the value falls with respect to reference range defined by LBORNRLO and LBORNRHI, LBSTNRLO and LBSTNRHI, or by LBSTNRC. Examples: "NORMAL", "ABNORMAL", "HIGH", "LOW". Sponsors should specify in the study metadata (Comments column in the Define-XML document) whether LBNRIND refers to the original or standard reference ranges and results. LBNRIND is not used to indicate clinical significance. | Exp |
| LBSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate exam not done. Should be null if a result exists in LBORRES. | Perm |
| LBREASND | Reason Test Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED", or "SPECIMEN LOST". Used in conjunction with LBSTAT when value is "NOT DONE". | Perm |
| LBNAM | Vendor Name | Char |  | Record Qualifier | The name or identifier of the laboratory that performed the test. | Perm |

### LB Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBLOINC | LOINC Code | Char | LOINC | Synonym Qualifier | Code for the lab test from the LOINC code system. The sponsor is expected to provide the dictionary name and version used to map the terms utilizing the Define-XML external codelist attributes. | Perm |
| LBSPEC | Specimen Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. Examples: "SERUM", "PLASMA", "URINE". | Perm |
| LBSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | The physical state or quality of a sample for an assessment. Examples: "HEMOLYZED", "ICTERIC", "LIPEMIC". | Perm |
| LBSPCUFL | Specimen Usability for the Test | Char | (NY) | Record Qualifier | Describes the usability of the specimen for the test. The value will be "N" if the specimen is not usable, and null if the specimen is usable. | Perm |
| LBMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "EIA" (enzyme immunoassay), "ELECTROPHORESIS", "DIPSTICK". | Perm |

### LB Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBANMETH | Analysis Method | Char | (LBANMET) | Record Qualifier | Analysis method applied to obtain a summarized result. Analysis method describes the method of secondary processing applied to a complex observation result (e.g., a calculation used to measure eGFR). | Perm |
| LBTMTHSN | Test Method Sensitivity | Char | (TSTMTHSN) | Record Qualifier | The sensitivity of the test methodology with respect to observation, detection, or quantification. | Perm |
| LBLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| LBBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that LBBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| LBFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. Examples: "Y", "N". | Perm |

### LB Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records, or do not come from the CRF, or are not as originally received or collected are examples of records that might be derived for the submission datasets. If LBDRVFL="Y", then LBORRES may be null, with LBSTRESC and (if numeric) LBSTRESN having the derived value. | Perm |
| LBTOX | Toxicity | Char | * | Variable Qualifier | Description of toxicity quantified by LBTOXGR. The sponsor is expected to provide the name of the scale and version used to map the terms, utilizing the external codelist element in the Define-XML document. | Perm |

### LB Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBTOXGR | Standard Toxicity Grade | Char | * | Record Qualifier | Records toxicity grade value using a standard toxicity scale (e.g., the NCI CTCAE). If value is from a numeric scale, represent only the number (e.g., "2" not "Grade 2"). The sponsor is expected to provide the name of the scale and version used to map the terms, utilizing the external codelist element in the Define-XML document. | Perm |
| LBCLSIG | Clinically Significant, Collected | Char | (NY) | Record Qualifier | Used to indicate whether a collected observation is clinically significant based on judgment. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### LB Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| LBDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of specimen collection represented in ISO 8601 character format. | Exp |
| LBENDTC | End Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | End date/time of specimen collection represented in ISO 8601 character format. | Perm |
| LBDY | Study Day of Specimen Collection | Num |  | Timing | Study day of specimen collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |

### LB Variables (part 16)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBENDY | Study Day of End of Observation | Num |  | Timing | Actual study day of end of observation expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| LBTPT | Planned Time Point Name | Char |  | Timing | Text description of time when specimen should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See LBTPTNUM and LBTPTREF. Examples: "Start", "5 min post". | Perm |
| LBTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of LBTPT to aid in sorting. | Perm |

### LB Variables (part 17)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (LBTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable. Represented as ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by LBTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by LBTPTREF. | Perm |
| LBTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by LBELTM, LBTPTNUM, and LBTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| LBRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, LBTPTREF. | Perm |

### LB Variables (part 18)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| LBPTFL | Point in Time Flag | Char | (NY) | Timing | An indication that the specimen was collected at a single point in time. The value is "Y" or null. The intent of this variable in the LB domain is to aid mapping to LOINC codes in the dataset, when LOINC part "Time Aspect" = "Pt". | Perm |
| LBPDUR | Planned Duration | Char | ISO 8601 duration | Timing | Planned duration of specimen collection. If LBPTFL is "Y" then LBPDUR is null. | Perm |

### LB Assumptions

1. This domain captures laboratory data collected on the CRF or received from a central provider or vendor.

2. For lab tests that do not have continuous numeric results (e.g., urine protein as measured by dipstick, descriptive tests such as urine color), LBSTNRC

could be populated either with normal range values that are a range of character values for an ordinal scale (e.g., “NEGATIVE to TRACE") or a delimited set of values that are considered to be normal (e.g., “YELLOW”, “AMBER”). LBORNRLO, LBORNRHI, LBSTNRLO, and LBSTNRHI should be null for these types of tests.

3. LBNRIND can be added to indicate where a result falls with respect to reference range defined by LBORNRLO and LBORNRHI. Examples: "HIGH",

"LOW". If toxicity grading is available, values would be represented in the variables LBTOX and LBTOXGR. Clinical significance would be represented as described in Section 4.5.5, Clinical Significance for Findings Observation Class Data, in LBCLSIG (see also LB Example 1).

4. For lab tests where the specimen is collected over time (e.g., 24-hour urine collection), the start date/time of the collection goes into LBDTC and the end

date/time of collection goes into LBENDTC. See Section 4.4.8, Date and Time Reported in a Domain Based on Findings.

5. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the LB domain, but the following qualifiers would

not generally be used: --BODSYS, --SEV.

6. A value derived by a central lab according to its procedures is considered collected rather than derived. See Section 4.1.8.1, Origin Metadata for

Variables.

7. The variable LBORRESU uses the UNIT codelist. This means that sponsors should be submitting a term from the CDISC Submission Value column in

the published Controlled Terminology List that is maintained for CDISC by NCI EVS. When sponsors have units that are not in this column, they should first check to see if their unit is mathematically synonymous with an existing/published unit from the UNIT codelist and submit their lab values using the published CDISC submission value. Example: "g/L" and "mg/mL" are mathematically synonymous, but only "g/L" is the submission value in

## Microbiology Specimen (MB)

*Structure: One record per microbiology specimen finding per time point per visit per subject.*

A findings domain that represents non-host organisms identified including bacteria, viruses, parasites, protozoa and fungi.

### MB Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | MB | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| FOCID | Focus of Study-Specific Interest | Char |  | Identifier | Identification of a focus of study-specific interest on or within a subject or specimen as called out in the protocol for which a measurement, test, or examination was performed. The value in this variable should have inherent semantic meaning. | Perm |
| MBSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number. | Req |
| MBGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |

### MB Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier (e.g., sample ID for a subject sample from which a microbial culture was generated). | Perm |
| MBSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. | Perm |
| MBLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. For example, it may be used to link genetic findings (in the PF domain) about a microbe to the original culture of that microbe (in MB), or to susceptibility records (in MS) if needed. | Perm |
| MBLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |

### MB Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBTESTCD | Microbiology Test or Finding Short Name | Char | (MBTESTCD) | Topic | Short name of the measurement, test, or finding described in MBTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in MBTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). MBTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "MCORGIDN" for Microbial Organism Identification "GMNCOC" for Gram Negative Cocci. | Req |
| MBTEST | Microbiology Test or Finding Name | Char | (MBTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in MBTEST cannot be longer than 40 characters. Examples: "Microbial Organism Identification", "Gram Negative Cocci", "HIV-1 RNA". | Req |

### MB Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBTSTDTL | Measurement, Test or Examination Detail | Char | (MBFTSDTL) | Variable Qualifier | Further description of MBTESTCD and MBTEST. Example: "VIRAL LOAD" when MBTESTCD represents viral genetic material, such as "HCRNA", "QUANTIFICATION" when MBTESTCD represents any organism being quantified. | Perm |
| MBCAT | Category | Char | * | Grouping Qualifier | Used to define a category of related records. | Perm |
| MBSCAT | Subcategory | Char | * | Grouping Qualifier | Used to define a further categorization of MBCAT values. | Perm |
| MBORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the microbiology measurement or finding as originally received or collected. Examples for "GRAM STAIN" findings: "+3 MODERATE", "+2 FEW", "<10". Examples for "CULTURE PLATE" findings: "KLEBSIELLA PNEUMONIAE", "STREPTOCOCCUS PNEUMONIAE". | Exp |
| MBORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original unit for MBORRES. Example: "mcg/mL". | Perm |

### MB Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBSTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from MBORRES, in a standard format or standard units. MBSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in MBSTRESN. For example, if a test has results "+3 MODERATE", "MOD", and "MODERATE" in MBORRES and these results effectively have the same meaning, they could be represented in standard format in MBSTRESC as "MODERATE". | Exp |
| MBSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from MBSTRESC. MBSTRESN should store all numeric test results or findings. | Perm |
| MBSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for MBSTRESC and MBSTRESN. | Perm |

### MB Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBRESCAT | Result Category | Char |  | Variable Qualifier | Used to categorize the result of a finding in a standard format. | Perm |
| MBSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or that a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| MBREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with MBSTAT when value is NOT DONE. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED". | Perm |
| MBNAM | Laboratory/Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor (e.g., laboratory) that provided the test results. | Perm |
| MBLOINC | LOINC Code | Char |  | Synonym Qualifier | Logical Observation Identifiers Names and Codes (LOINC) code for the topic variable (e.g., lab test). | Perm |

### MB Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBSPEC | Specimen Material Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. Examples: "SPUTUM", "BLOOD", "PUS". | Perm |
| MBSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Free or standardized text describing the condition of the specimen. Example: "CONTAMINATED". | Perm |
| MBLOC | Specimen Collection Location | Char | (LOC) | Record Qualifier | Anatomical location relevant to the collection of the measurement. | Perm |
| MBLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for specimen collection location further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| MBDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for specimen collection location further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| MBMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "GRAM STAIN", "MICROBIAL CULTURE, LIQUID", "QUANTITATIVE REVERSE TRANSCRIPTASE POLYMERASE CHAIN REACTION". | Exp |

### MB Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| MBBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that MBBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| MBFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. Valid values include "Y", "N", "U", or null if not relevant. | Perm |
| MBDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |

### MB Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element which the specimen collection occurred. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the specimen was collected. | Perm |
| MBDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of specimen collection. | Exp |
| MBDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Study day of the specimen collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |

### MB Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBTPT | Planned Time Point Name | Char |  | Timing | Text description of time when specimen should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See MBTPTNUM and MBTPTREF. Examples: "Start", "5 min post". | Perm |
| MBTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of MBTPT used in sorting. | Perm |
| MBELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (MBTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date time variable. Represented as an ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by MBTPTREF, or "PT8H" to represent the period of 8 hours after the reference point indicated by MBTPTREF. | Perm |

### MB Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MBTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by MBELTM, MBTPTNUM, and MBTPT. Example: "PREVIOUS DOSE". | Perm |
| MBRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point, MBTPTREF. | Perm |

### MB Assumptions

1. Representation of findings in the Microbiology Specimen domain should be handled as follows:

a. In cases of tests that target an organism, group of organisms, or antigen for identification, MBTEST equals the name of the organism/antigen targeted by the identification assay, and

i. MBTSTDTL should be “DETECTION”.

ii. The result should generally be "PRESENT"/"ABSENT", "POSITIVE"/"NEGATIVE", or "INDETERMINATE". However, there may be cases

where a test differentiates between 2 or more similar organisms, in which case it would be appropriate for the result to be the name of the organism detected. For example, a test may look for influenza A or influenza B antigen. In this case, MBTEST would be "Influenza A/B Antigen"; the result could be "INFLUENZA A ANTIGEN", "INFLUENZA B ANTIGEN", or "INFLUENZA A/B ANTIGEN".

b. For non-targeted identification of organisms (i.e., tests that have the ability to identify a range of organisms without specifically targeting any), the

value for MBTESTCD/MBTEST should be "MCORGIDN"/"Microbial Organism Identification", and the result should be the name of the organism or group of organisms found to be present (e.g., "INFLUENZA A VIRUS SUBTYPE H1N1"; "CLONORCHIS SINENSIS"). In this scenario MBORRES is populated with values from the Microorganism Codelist (C85491).

c. Culture characteristics covers concepts such as growth/no growth, colony quantification measures, colony color, colony morphology, and so on. Note that this does not include drug susceptibility testing, which is represented in the Microbiology Susceptibility (MS) domain.

i. MBTESTCD/MBTEST should be the name of the organism or group of organisms being characterized.

ii. MBTSTDTL should be the name of the characteristic being described (e.g., “COLONY COUNT", "VIRAL LOAD").

iii. MBGRPID should be used to group characteristic records with the identification record of the organism to which the characteristics apply.

iv. CDISC Controlled Terminology Rules for Microbiology (MB/MS) domains are available at

https://www.cdisc.org/standards/terminology/controlled-terminology.

2. MBDTC represents the date the specimen was collected.

## Microbiology Susceptibility (MS)

*Structure: One record per microbiology susceptibility test (or other organism-related finding) per.*

A findings domain that represents drug susceptibility testing results only. This includes phenotypic testing (where drug is added directly to a culture of organisms) and genotypic tests that provide results in terms of susceptible or resistant. Drug susceptibility testing may occur on a wide variety of non-host organisms, including bacteria, viruses, fungi, protozoa and parasites.

### MS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | MS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| NHOID | Non-host Organism ID | Char |  | Identifier | Sponsor-defined identifier for a non-host organism which should only be used when the organism is the subject of the TEST. This variable should be populated with an intuitive name based on the identity of the non-host organism as reported by a lab (e.g., "A/California/7/2009 (H1N1)"). It is not to be used as a qualifier of the result in the record on which it appears. | Perm |

### MS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject (or within a parameter, in the case of the Trial Summary domain). May be any valid number (including decimals) and does not have to start at 1. | Req |
| MSGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. In SDTMIG v3.2 this was an Expected variable. In this version, the core designation has been changed to Permissible. | Perm |
| MSREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier (e.g., an identifier for the culture/isolate being tested for susceptibility). | Perm |
| MSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. | Perm |

### MS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. For example, it may be used to link genetic findings (in the PF domain) about a microbe to the original culture of that microbe (in MB), or to susceptibility records (in MS) if needed. | Perm |
| MSTESTCD | Short Name of Assessment | Char | (MSTESTCD) | Topic | Short character value for MSTEST used as a column name when converting a dataset from a vertical format to a horizontal format. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in MSTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). MSTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "MIC" for Minimum Inhibitory Concentration; "MICROSUS" for Microbial Susceptibility. | Req |

### MS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSTEST | Name of Assessment | Char | (MSTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in MSTEST cannot be longer than 40 characters. Examples: "Minimum Inhibitory Concentration", "Microbial Susceptibility". | Req |
| MSAGENT | Agent Name | Char |  | Variable Qualifier | The name of the agent for which resistance is tested. The agent specified may be based on genetic markers or direct phenotypic drug sensitivity testing. Examples: "Penicillin", name of study drug. | Exp |
| MSCONC | Agent Concentration | Num |  | Variable Qualifier | Numeric concentration of agent listed in MSAGENT. | Perm |
| MSCONCU | Agent Concentration Units | Char | (UNIT) | Variable Qualifier | Units for value of the agent concentration listed in MSCONC. Example: "mg/L". | Perm |
| MSTSTDTL | Measurement, Test or Examination Detail | Char |  | Variable Qualifier | Further description of MSTESTCD and MSTEST. | Perm |
| MSCAT | Category | Char | * | Grouping Qualifier | Used to define a category of MSTEST values. | Perm |

### MS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSSCAT | Subcategory | Char | * | Grouping Qualifier | Used to define a further categorization of MSCAT values. | Perm |
| MSORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| MSORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for MSORRES. Examples: "ug/mL". | Perm |
| MSSTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from MSORRES in a standard format or in standard units. MSSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in MSSTRESN. For example, if various tests have results "NONE", "NEG", and "NEGATIVE" in MSORRES and these results effectively have the same meaning, they could be represented in standard format in MSSTRESC as "NEGATIVE". | Exp |

### MS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from MSSTRESC. MSSTRESN should store all numeric test results or findings. | Perm |
| MSSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for MSSTRESC and MSSTRESN. Example: "mol/L". | Perm |
| MSNRIND | Normal/Reference Range Indicator | Char | (NRIND) | Variable Qualifier | Used to indicate the value is outside the normal range or reference range. May be defined by MSORNRLO and MSORNRHI or other objective criteria. Examples: "Y", "N", "HIGH", "LOW", "NORMAL". "ABNORMAL". | Perm |

### MS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSRESCAT | Result Category | Char | (MSRESCAT) | Variable Qualifier | Used to categorize the result of a finding. In SDTMIG v3.2, MSRESCAT was used to categorize a numeric susceptibility result represented in MSORRES as either "SUSCEPTIBLE", "INTERMEDIATE", or "RESISTANT". However, results from some susceptibility tests may report only a categorical result and not a numeric result. Thus, in order for susceptibility results to be represented consistently, MSRESCAT should no longer be used for this purpose. In this version, the core designation has been changed from Expected to Permissible. | Perm |
| MSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |

### MS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with MSSTAT when value is "NOT DONE". | Perm |
| MSXFN | External File Path | Char |  | Record Qualifier | Filename for an external file. | Perm |
| MSNAM | Laboratory/Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor (e.g., laboratory) that provided the test results. | Perm |
| MSLOINC | LOINC Code | Char |  | Synonym Qualifier | Logical Observation Identifiers Names and Codes (LOINC) code for the topic variable such as a lab test. | Perm |
| MSSPEC | Specimen Material Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. Example: "SPUTUM". | Perm |
| MSSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Defines the condition of the specimen. Example: "CLOUDY". | Perm |
| MSLOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. | Perm |

### MS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| MSDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| MSMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "EPSILOMETER", "MACRO BROTH DILUTION". | Perm |
| MSANMETH | Analysis Method | Char |  | Record Qualifier | Analysis method applied to obtain a summarized result. Analysis method describes the method of secondary processing applied to a complex observation result (e.g., an image or a genetic sequence). | Perm |
| MSLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |

### MS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that MSBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| MSFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. Valid values include "Y", "N", "U", or null if not relevant. | Perm |
| MSDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| MSEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "MICROSCOPIST". | Perm |

### MS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in MSEVAL. Examples: "RADIOLOGIST1" or "RADIOLOGIST2". | Perm |
| MSACPTFL | Accepted Record Flag | Char | (NY) | Record Qualifier | In cases where more than 1 assessor provides an evaluation of a result or response, this flag identifies the record that is considered, by an independent assessor, to be the accepted evaluation. Expected to be "Y" or null. | Perm |
| MSLLOQ | Lower Limit of Quantitation | Num |  | Variable Qualifier | Indicates the lower limit of quantitation for an assay. Units will be those used for MSSTRESU. | Perm |
| MSULOQ | Upper Limit of Quantitation | Num |  | Variable Qualifier | Indicates the upper limit of quantitation for an assay. Units will be those used for MSSTRESU. | Perm |

### MS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSREPNUM | Repetition Number | Num |  | Record Qualifier | The incidence number of a test that is repeated within a given timeframe for the same test. The level of granularity can vary (e.g., within a time point, within a visit). Examples: multiple measurements of blood pressure, multiple analyses of a sample. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the specimen was collected. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the specimen was collected. | Perm |

### MS Variables (part 13)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Perm |
| MSDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| MSDUR | Duration | Char | ISO 8601 duration | Timing | Collected duration of an event, intervention, or finding. Used only if collected on the CRF and not derived. | Perm |
| MSTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point (e.g., time of last dose). See MSTPTNUM and MSTPTREF. | Perm |
| MSTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |

### MS Variables (part 14)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (MSTPTREF; e.g., previous dose, previous meal). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| MSTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by MSELTM, MSTPTNUM, and MSTPT. Example: "PREVIOUS DOSE". | Perm |
| MSRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by MSTPTREF. | Perm |
| MSEVLINT | Evaluation Interval | Char | ISO 8601 duration or interval | Timing | Duration of interval associated with an observation such as a finding MSTESTCD. Example: "-P2M" to represent a period of the past 2 months before the assessment. | Perm |

### MS Variables (part 15)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MSEVINTX | Evaluation Interval Text | Char |  | Timing | Evaluation interval associated with an observation, where the interval is not able to be represented in ISO 8601 format. Examples: "LIFETIME", "LAST NIGHT", "RECENTLY", "OVER THE LAST FEW WEEKS". | Perm |

### MS Assumptions

1. Microbiology Susceptibility testing includes testing of the following types:

a. Phenotypic drug susceptibility testing (qualitative), which may involve determining susceptibility/resistance (qualitative) at a predefined concentration of drug, or determining a specific dose (quantitative) at which a drug inhibits organism growth or some other process associated with virulence.

i. For studies using qualitative testing methods, MSAGENT, MSCONC, and MSCONCU are used to represent the predefined drug,

concentration, and units, respectively. Results are represented with values such as “SUSCEPTIBLE” or “RESISTANT”.

ii. For studies using quantitative testing methods, MSAGENT is used to represent the drug being tested; MSCONC and MSCONCU are not used.

The concentration at which growth is inhibited is the result in these cases (MSORRES, MSSTRESC/MSSTRESN), with units being represented in MSORRESU/MSSTRESU.

b. Genetic tests that provide results in terms of susceptible/resistant only (e.g., nucleic acid amplification tests (NAAT)). Genotypic tests that

provide results in terms of specific changes to nucleotides, codons, or amino acids of genes/gene products associated with resistance should be represented in the Genomic Findings (GF) domain, as that domain structure contains the variables necessary to accommodate data of this type. If a test provides both mutation data and susceptibility data, the mutation results should be represented in GF and the susceptibility information should be represented in MS. In these cases, the GF records should be linked via RELREC to susceptibility records in MS.

genotypic test. MSCONC and MSCONCU are null in these records.

c. CDISC Controlled Terminology Rules for Microbiology (MB/MS) domains are available at https://www.cdisc.org/standards/terminology/controlled-terminology.

2. MSDTC represents the date the specimen was collected.

3. If the specimen was cultured, the start and end date of culture are represented in the Biospecimen Events (BE) domain in BESTDTC and BEENDTC,

respectively. --REFID represents the sample ID as originally assigned in the BE domain. See BE domain assumptions in the SDTMIG v3.4, Section 6.2.2, for guidelines on assigning --REFID values to samples and subsamples.

a. Culture dates can be connected to the MS record via MSREFID and BEREFID.

b. If the same sample is associated with many biospecimen events and tests, users may need to make use of additional linking variables such as --

LNKID.

4. NHOID is a sponsor-defined, intuitive name of the non-host organism being tested. It should only populated with values representing what is known

about the identity of the organism before the results of the test are determined. It should therefore never be used as a qualifier of result.

5. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the MS domain, but the following variables would

not generally be used: --MODIFY, --BODSYS, --TOX, --TOXGR --SEV.

6.3.5.7.3 Microbiology Specimen/Microbiology Susceptibility Examples

Example 1

In this example, both a central and a local lab (MBNAM) independently identified Enterococcus faecalis (MBORRES) in a fluid specimen (MBSPEC) taken from the skin (MBLOC) of a subject at visit 1. The method used by both labs was a solid microbial culture (MBMETHOD). Because the culture was not targeted to encourage the growth of a specific organism, MBTESTCD/MBTEST = "MCORGIDN"/"Microbial Organism Identification" and MBORRES represents the name of the organism identified.

mb.xpt

Row STUDYID DOMAIN USUBJID MBSEQ MBREFID MBLNKID MBTESTCD MBTEST MBORRES MBSTRESC MBNAM MBSPEC MBLOC MBMETHOD VISITNUM VISIT MBDTC 1 ABC MB ABC-001002

1 SPEC01 1 MCORGIDN Microbial

Organism Identification

ENTEROCOCCUS FAECALIS

ENTEROCOCCUS FAECALIS

CENTRAL LAB ABC

FLUID SKIN MICROBIAL CULTURE, SOLID

1 VISIT 1

2005-0721T08:00

2 ABC MB ABC-001002

2 SPEC01 2 MCORGIDN Microbial

Organism Identification

ENTEROCOCCUS FAECALIS

ENTEROCOCCUS FAECALIS

LOCAL LAB XYZ

FLUID SKIN MICROBIAL CULTURE, SOLID

1 VISIT 1

2005-0721T08:00

After E. faecalis was identified in the subject sample, drug susceptibility testing was performed at each of the labs using both the sponsor's investigational drug and amoxicillin. Because an identified organism is the subject of the test, the NHOID variable is populated with "ENTEROCOCCUS FAECALIS". Between the 2 labs (MSNAM), a total of 3 susceptibility testing methods were used: epsilometer, disk diffusion, and macro broth dilution (MSMETHOD). Epsilometer and disk diffusion both use agar diffusion methods, in which an agar plate is inoculated with the microorganism of interest and either a strip (epsilometer) or discs (disk diffusion) containing various concentrations of the drug are placed on the agar plate. The epsilometer test method provides both a minimum inhibitory concentration (MSTESTCD = "MIC"), the lowest concentration of a drug that inhibits the growth of a microorganism, and a qualitative interpretation (MSTESTCD = "MICROSUS") such as susceptible, intermediate, or resistant. The disk diffusion test method provides the diameter of the zone of inhibition

The third method, macro broth dilution, was used to test the specimen at a predefined drug concentration of each of the drugs. When the drug and amount are a predefined part of the test, the variable MSAGENT is populated with the name of the drug being used in the susceptibility test. The variables MSCONC and MSCONCU represent the concentration and units of the drug being used.

Rows 1-4: Show the minimum inhibitory concentration and the interpretation result reported from Central Lab ABC from a sample that was tested for susceptibility to the sponsor drug and amoxicillin, using an epsilometer test method.

Rows 5-6: Show that Local Lab XYZ found that the sample was susceptible to the sponsor drug at a concentration of 0.5 ug/dL and resistant to amoxicillin at a concentration of 0.5 ug/dL.

Rows 7-10: Show the diameter of the zone of inhibition and the interpretation result reported from Local Lab XYZ from a sample that was tested for susceptibility to the sponsor drug and amoxicillin using a disk

diffusion test method.

ms.xpt

Row STUDYID DOMAIN USUBJID NHOID MSGRPID MSSEQ MSREFID MSLNKGRP MSTESTCD MSTEST MSAGENT MSCONC MSCONCU MSORRES MSORRESU MSSTRESC MSSTRESN MSSTRESU MSNAM MSMETHOD MSDTC 1 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

1 1 SPEC01 1 MIC Minimum Inhibitory Concentration

Sponsor Drug

0.25 ug/dL 0.25 0.25 ug/dL CENTRAL LAB ABC

EPSILOMETER 2005-0619T08:00 2 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

1 2 SPEC01 1 MICROSUS Microbial Susceptibility

Sponsor Drug

SUSCEPTIBLE SUSCEPTIBLE CENTRAL LAB ABC

EPSILOMETER 2005-0619T08:00 3 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

2 3 SPEC01 1 MIC Minimum Inhibitory Concentration

Amoxicillin 1 ug/dL 1 1 ug/dL CENTRAL LAB ABC

EPSILOMETER 2005-0619T08:00 4 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

2 4 SPEC01 1 MICROSUS Microbial Susceptibility

Amoxicillin RESISTANT RESISTANT CENTRAL LAB ABC

EPSILOMETER 2005-0619T08:00 5 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

5 SPEC01 2 MICROSUS Microbial Susceptibility

Sponsor Drug

0.5 ug/dL SUSCEPTIBLE SUSCEPTIBLE LOCAL LAB XYZ

MACRO BROTH DILUTION

2005-0619T08:00 6 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

6 SPEC01 2 MICROSUS Microbial Susceptibility

Amoxicillin 0.5 ug/dL RESISTANT RESISTANT LOCAL LAB XYZ

MACRO BROTH DILUTION

2005-0619T08:00 7 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

3 7 SPEC01 2 DIAZOINH Diameter of the Zone of Inhibition

Sponsor Drug

23 mm 23 23 mm LOCAL LAB XYZ

DISK DIFFUSION 2005-0626T08:00 8 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

3 8 SPEC01 2 MICROSUS Microbial Susceptibility

Sponsor Drug

SUSCEPTIBLE SUSCEPTIBLE LOCAL LAB XYZ

DISK DIFFUSION 2005-0626T08:00 9 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

4 9 SPEC01 2 DIAZOINH Diameter of the Zone of Inhibition

Amoxicillin 25 mm 25 mm LOCAL LAB XYZ

DISK DIFFUSION 2005-0626T08:00 10 ABC MS ABC-001002

ENTEROCOCCUS FAECALIS

4 10 SPEC01 2 MICROSUS Microbial Susceptibility

Amoxicillin RESISTANT RESISTANT LOCAL LAB XYZ

DISK DIFFUSION 2005-0626T08:00

Although not expected, the sponsor decided to connect the identification records in MB to the records in MS using the variables MBLNKID and MSLNKGRP.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC MB MBLNKID ONE A 2 ABC MS MSLNKGRP MANY A

Example 2

In this example, a sputum sample, collected from the subject at 3 visits over the course of 15 days, was tested for the presence of infectious organisms. The 2 organisms identified were also tested for susceptibility to both penicillin and the sponsor's study drug (MSAGENT). The example shows that the 2 infecting organisms were cleared over the course of the 3 visits.

Specimen collection was represented in the Biospecimen Events (BE) domain. be.xpt

Row STUDYID DOMAIN USUBJID BESEQ BEREFID BETERM BEDTC 1 ABC BE ABC-001-001 1 SP01 Collecting 2005-06-19T08:00 2 ABC BE ABC-001-001 2 SP02 Collecting 2005-06-26T08:00 3 ABC BE ABC-001-001 3 SP03 Collecting 2005-07-06T08:00

Rows 1-3: Show that all 3 samples (IDVARVAL where IDVAR="BEREFID") were sputum, as indicated by QVAL where QNAM="BESPEC" and QLABEL="Specimen Type".

Rows 4-6: Show that all 3 sputum samples were collected via expectoration, as indicated by QVAL where QNAM="Specimen Collection Method". QVAL is populated using the CDISC Controlled Terminology codelist, "Specimen Collection Method".

suppbe.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC BE ABC-01-101 BEREFID SP01 BESPEC Specimen Type SPUTUM CRF 2 ABC BE ABC-01-101 BEREFID SP02 BESPEC Specimen Type SPUTUM CRF 3 ABC BE ABC-01-101 BEREFID SP03 BESPEC Specimen Type SPUTUM CRF 4 ABC BE ABC-01-101 BEREFID SP01 BECLMETH Specimen Collection Method EXPECTORATION CRF 5 ABC BE ABC-01-101 BEREFID SP02 BECLMETH Specimen Collection Method EXPECTORATION CRF 6 ABC BE ABC-01-101 BEREFID SP03 BECLMETH Specimen Collection Method EXPECTORATION CRF

Rows 1-2: Show that a gram stain was used on a subject sputum sample to identify the presence of gram negative cocci (row 1) and to quantify the bacteria (row 2). MBORRES in row 2 represents an ordinal result (MBRSLSCL = "Ord"), such as from a published quantification scale. This value decodes to "FEW" as shown in MBSTRESC. The quantification scale used is represented as Supplemental Qualifiers of MB.

Rows 3-4: Show that the same gram-stained sample was used to identify and quantify the presence of gram negative rods.

Rows 5-6: Show that microbial culture of the same sample was used at the same visit to identify the presence of two organisms, "STREPTOCOCCUS PNEUMONIAE" and "KLEBSIELLA PNEUMONIAE" (MBORRES).

Row 7: Shows that microbial culture of a subsequent sample at a later visit indicated only the presence of "KLEBSIELLA PNEUMONIAE" (MBORRES).

Row 8: Shows that microbial culture of a third subject sample at the third visit indicated "NO GROWTH" (MBORRES) of any organisms.

mb.xpt

Row STUDYID DOMAIN USUBJID MBSEQ MBREFID MBTESTCD MBTEST MBTSTDTL MBORRES MBRSLSCL MBSTRESC MBLOC MBMETHOD VISITNUM VISIT MBDTC 1 ABC MB ABC-001001

1 SP01 GMNCOC Gram Negative Cocci DETECTION PRESENT Ord PRESENT LUNG GRAM STAIN 1 VISIT 1

2005-0619T08:00 2 ABC MB ABC-001001

2 SP01 GMNCOC Gram Negative Cocci CELL COUNT

2+ Ord FEW LUNG GRAM STAIN 1 VISIT 1

2005-0619T08:00 3 ABC MB ABC-001001

3 SP01 GMNROD Gram Negative Rods DETECTION PRESENT Ord PRESENT LUNG GRAM STAIN 1 VISIT 1

2005-0619T08:00 4 ABC MB ABC-001001

4 SP01 GMNROD Gram Negative Rods CELL COUNT

2+ Ord FEW LUNG GRAM STAIN 1 VISIT 1

2005-0619T08:00 5 ABC MB ABC-001001

5 SP01 MCORGIDN Microbial Organism

Identification

STREPTOCOCCUS PNEUMONIAE

Nom STREPTOCOCCUS PNEUMONIAE

LUNG MICROBIAL CULTURE, SOLID

1 VISIT 1

2005-0619T08:00 6 ABC MB ABC-001001

6 SP01 MCORGIDN Microbial Organism

Identification

KLEBSIELLA PNEUMONIAE Nom KLEBSIELLA PNEUMONIAE LUNG MICROBIAL CULTURE, SOLID

1 VISIT 1

2005-0619T08:00 7 ABC MB ABC-001001

7 SP02 MCORGIDN Microbial Organism

Identification

KLEBSIELLA PNEUMONIAE Nom KLEBSIELLA PNEUMONIAE LUNG MICROBIAL CULTURE, SOLID

2 VISIT 2

2005-0626T08:00 8 ABC MB ABC-001001

8 SP03 MCORGIDN Microbial Organism

Identification

NO GROWTH Nom NO GROWTH LUNG MICROBIAL CULTURE, SOLID

3 VISIT 3

2005-0706T08:00 suppmb.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC MB ABC-01-101 MBTSTDTL CELL COUNT MBQSCAL Quantification Scale CDC semi-quantitative score for gram staining CRF

Rows 3-4: Show that penicillin was tested against the same organism from the same sample and was found to have a minimum inhibitory concentration of 0.023 mg/L (row 3). This led to the conclusion that "STREPTOCOCCUS PNEUMONIAE" is resistant to penicillin (row 4).

Rows 5-8: Similar to rows 1-4, the sponsor drug (rows 5-6) and penicillin (rows 7-8) were tested against " KLEBSIELLA PNEUMONIAE" from an additional sample from the same subject at a later time point. Results from these tests indicated that the organism was susceptible to sponsor drug, yet had intermediate resistance to penicillin.

Rows 9-10: A test against "KLEBSIELLA PNEUMONIAE" from an additional sample at a later time point showed little change in the minimum inhibitory concentration of penicillin, and that the organism was still

classified as having intermediate resistance to this drug.

ms.xpt

Row STUDYID DOMAIN USUBJID NHOID MSSEQ MSREFID MSGRPID MSTESTCD MSTEST MSAGENT MSORRES MSORRESU MSSTRESC MSSTRESN MSSTRESU MSMETHOD MSDTC 1 ABC MS ABC-001001

STREPTOCOCCUS PNEUMONIAE

1 SP01 1 MIC Minimum Inhibitory Concentration

Sponsor Drug

0.004 mg/L 0.004 0.004 mg/L EPSILOMETER 2005-06-

19T08:00 2 ABC MS ABC-001001

STREPTOCOCCUS PNEUMONIAE

2 SP01 1 MICROSUS Microbial Susceptibility Sponsor Drug

SUSCEPTIBLE SUSCEPTIBLE EPSILOMETER 2005-06-

19T08:00 3 ABC MS ABC-001001

STREPTOCOCCUS PNEUMONIAE

3 SP01 2 MIC Minimum Inhibitory Concentration

Penicillin 0.023 mg/L 0.023 0.023 mg/L EPSILOMETER 2005-06-

19T08:00 4 ABC MS ABC-001001

STREPTOCOCCUS PNEUMONIAE

4 SP01 2 MICROSUS Microbial Susceptibility Penicillin RESISTANT RESISTANT EPSILOMETER 2005-06-

19T08:00 5 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 5 SP02 3 MIC Minimum Inhibitory Concentration

Sponsor Drug

0.125 mg/L 0.125 0.125 mg/L EPSILOMETER 2005-06-

26T08:00 6 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 6 SP02 3 MICROSUS Microbial Susceptibility Sponsor Drug

SUSCEPTIBLE SUSCEPTIBLE EPSILOMETER 2005-06-

26T08:00 7 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 7 SP02 4 MIC Minimum Inhibitory Concentration

Penicillin 0.023 mg/L 0.023 0.023 mg/L EPSILOMETER 2005-06-

26T08:00 8 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 8 SP02 4 MICROSUS Microbial Susceptibility Penicillin INTERMEDIATE INTERMEDIATE EPSILOMETER 2005-06-

26T08:00 9 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 9 SP03 5 MIC Minimum Inhibitory Concentration

Penicillin 0.026 mg/L 0.026 0.026 mg/L EPSILOMETER 2005-07-

06T08:00 10 ABC MS ABC-001001

KLEBSIELLA PNEUMONIAE 10 SP03 5 MICROSUS Microbial Susceptibility Penicillin INTERMEDIATE INTERMEDIATE EPSILOMETER 2005-07-

06T08:00

Example 3

This example shows the microorganisms detected from a gastric aspirate specimen from a child with suspected tuberculosis (TB). In this example, gastric lavage is only performed once. Three records in the MB domain store detection records for 2 levels of detection: acid-fast bacilli, and Mycobacterium tuberculosis (Mtb). Characteristics from a culture on solid media that support the presumptive detection of Mtb are also represented in MB. The susceptibility results from both the nucleic acid amplification test (NAAT) and the solid culture are represented in the MS domain.

Specimen processing events included sample collection, preparation, and culturing; these events are represented in the BE domain. For TB studies, each sample needs a separate identifier to link it to further actions or characteristics of the sample. Therefore, each aliquot is assigned a unique BEREFID value that can be traced to the BEREFID value assigned to the collected "parent" sample. BEREFID is also used to connect the BE and Biospecimen Findings (BS) domains (via BSREFID), as well as any results obtained from the sample that are in the MB or MS domains (via MBREFID and MSREFID). If the same sample is used in many tests, the use of --REFID may result in a potentially undesirable many-to-many merge; users may need to make use of additional linking variables such as --LNKID and --LNKGRP. Information about the BE and BS domains including the specification tables, assumptions, and examples can be found in the Sections 6.2.2 and 6.3.5.2 of this document.

In the BE, BS, MB, and MS domains, --DTC represents the date of sample collection. --LNKID and --LNKGRP are used to link culture start and stop dates (BE) with culture results (MB and MS).

Row 1: Shows the event of specimen collection. This is the genesis of the sample identified by BEREFID="100"; therefore, BEDTC and BESTDTC are the same. The specimen collection setting, collection method, and specimen type are represented using supplemental qualifiers. Even though the variable Specimen Type is available for use in Findings domains, it is not available for use in Events domains and thus it is represented as supplemental qualifier.

Rows 7-9: Show that 3 of the aliquots (100.3, 100.4, and 100.5) were cultured for detection (row 7) and tested for drug susceptibility (rows 8 and 9). The inoculation and read dates of a culture should be represented in BESTDTC and BEENDTC, respectively. These dates can be linked to the culture results in MB and MS using BELNKID, MBLNKGRP, and MSLNKID.

Row 10: Shows that sample 100.1 was concentrated.

be.xpt

Row STUDYID DOMAIN USUBJID BESEQ BEREFID BELNKID BETERM BECAT BEDTC BESTDTC BEENDTC 1 ABC BE ABC-01-101 1 100 Collecting COLLECTION 2011-01-17T06:00 2011-01-17T06:00 2 ABC BE ABC-01-101 2 100.1 Aliquoting PREPARATION 2011-01-17T06:00 2011-01-17T09:00 3 ABC BE ABC-01-101 3 100.2 Aliquoting PREPARATION 2011-01-17T06:00 2011-01-17T09:00 4 ABC BE ABC-01-101 4 100.3 Aliquoting PREPARATION 2011-01-17T06:00 2011-01-17T09:00 5 ABC BE ABC-01-101 5 100.4 Aliquoting PREPARATION 2011-01-17T06:00 2011-01-17T09:00 6 ABC BE ABC-01-101 6 100.5 Aliquoting PREPARATION 2011-01-17T06:00 2011-01-17T09:00 7 ABC BE ABC-01-101 7 100.3 1 Culturing CULTURE 2011-01-17T06:00 2011-01-17T09:30 2011-02-02T09:00 8 ABC BE ABC-01-101 8 100.4 2 Culturing CULTURE 2011-01-17T06:00 2011-02-02T10:00 2011-02-21T09:00 9 ABC BE ABC-01-101 9 100.5 3 Culturing CULTURE 2011-01-17T06:00 2011-02-02T10:00 2011-02-22T09:00 10 ABC BE ABC-01-101 10 100.1 Concentrating PREPARATION 2011-01-17T06:00 2011-01-17T09:15 suppbe.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC BE ABC-01-101 BEREFID 100 BECLSET Specimen Collection Setting HOSPITAL CRF 2 ABC BE ABC-01-101 BEREFID 100 BECLMETH Specimen Collection Method GASTRIC LAVAGE CRF 3 ABC BE ABC-01-101 BEREFID 100 BESPEC Specimen Type LAVAGE FLUID CRF 4 ABC BE ABC-01-101 BEREFID 100.1 BESPEC Specimen Type LAVAGE FLUID CRF 5 ABC BE ABC-01-101 BEREFID 100.2 BESPEC Specimen Type LAVAGE FLUID CRF 6 ABC BE ABC-01-101 BEREFID 100.3 BESPEC Specimen Type LAVAGE FLUID CRF 7 ABC BE ABC-01-101 BEREFID 100.4 BESPEC Specimen Type LAVAGE FLUID CRF 8 ABC BE ABC-01-101 BEREFID 100.5 BESPEC Specimen Type LAVAGE FLUID CRF

Findings data captured about the specimen during collection, preparation, and handling are represented in the BS domain.

Row 1: Shows the total volume of lavage fluid collected during the gastric lavage by using the same values for BSREFID and BEREFID. This is the parent (collected) sample from which further aliquots were generated.

Rows 2-6: Show the volume of each aliquot created.

bs.xpt

Row STUDYID DOMAIN USUBJID BSSEQ BSREFID BSTESTCD BSTEST BSORRES BSORRESU BSSTRESC BSSTRESN BSSTRESU BSSPEC BSLOC BSDTC 1 ABC BS ABC-01-101 1 100 VOLUME Volume 20 mL 20 20 mL LAVAGE FLUID STOMACH 2011-01-17T06:00 2 ABC BS ABC-01-101 2 100.1 VOLUME Volume 4 mL 4 4 mL LAVAGE FLUID STOMACH 2011-01-17T06:00 3 ABC BS ABC-01-101 3 100.2 VOLUME Volume 4 mL 4 4 mL LAVAGE FLUID STOMACH 2011-01-17T06:00 4 ABC BS ABC-01-101 4 100.3 VOLUME Volume 4 mL 4 4 mL LAVAGE FLUID STOMACH 2011-01-17T06:00 5 ABC BS ABC-01-101 5 100.4 VOLUME Volume 4 mL 4 4 mL LAVAGE FLUID STOMACH 2011-01-17T06:00 6 ABC BS ABC-01-101 6 100.5 VOLUME Volume 4 mL 4 4 mL LAVAGE FLUID STOMACH 2011-01-17T06:00

Row 1: Shows the original collected (parent) sample. The PARENT variable is left blank to indicate that this is the highest level sample.

Rows 2-6: Show the relationship of each aliquot in the BE domain to the parent sample. PARENT is populated with the REFID value of the parent sample, indicating that the sample with REFID="100" is the parent of these samples. LEVEL="2" indicates that these aliquots are subsamples of the original (LEVEL="1") sample.

relspec.xpt

Row STUDYID USUBJID REFID SPEC PARENT LEVEL 1 ABC ABC-01-101 100 LAVAGE FLUID 1 2 ABC ABC-01-101 100.1 LAVAGE FLUID 100 2 3 ABC ABC-01-101 100.2 LAVAGE FLUID 100 2 4 ABC ABC-01-101 100.3 LAVAGE FLUID 100 2 5 ABC ABC-01-101 100.4 LAVAGE FLUID 100 2 6 ABC ABC-01-101 100.5 LAVAGE FLUID 100 2

Results from detection tests performed on samples are represented in the MB domain. The sputum sample was aliquoted 5 times. Three of these aliquots underwent detection testing using 3 separate tests: 1 for acid-fast bacillus (AFB), 1 for M. tuberculosis complex, and 1 for M. tuberculosis. MBTESTCD/MBTEST represents the organism being investigated, MBMETHOD represents the testing method, and MBREFID represents which aliquot was tested. The variable MBTSTDTL is used to provide further description of the test performed in producing the MB result. In addition to detection, MBTSTDTL can be used to represent specific attributes (e.g., quantifiable and semi-quantifiable results of the culture) as well as qualitative details about the culture (e.g., colony color, morphology).

Row 1: Shows a test targeting the presence or absence of AFB using a stain. The MBSPCCND shows that the sample used in the test was concentrated. MBGRPID can be used to connect the detection record with the corresponding AFB quantification results shown in row 2.

Row 2: Shows a categorical result for an AFB test using a stain. MBORRES contains a result based on a CDC AFB quantification scale. The name of the scale used is represented as a supplemental qualifier. MBREFID indicates which aliquot the procedure was performed upon and MBGRPID is used to connect the AFB quantification record to the detection record in row 1.

Row 3: Shows a test targeting the presence or absence of M. tuberculosis complex using a genotyping method. Details about the assay can be found in the Device Identifiers (DI) domain. The value in SPDEVID links the genotype result to the assay information in the DI domain. The microbial detection certainty is represented as a supplemental qualifier. Because genotyping was used, the detection is considered to be definitive.

Row 4: Shows a test targeting the presence or absence of M. tuberculosis performed on a solid culture. The medium type and microbial detection certainty are represented as supplemental qualifier. Because genotyping was not used, the detection is considered to be presumptive. The culture start and stop dates are represented in BE and are connected to the culture results via BELNKID and MBLNKGRP. MBGRPID is used to connect the detection record in MB with the corresponding culture characteristics shown in rows 5-7.

Row 5: Shows a colony-forming unit (CFU) count from a solid culture. The MBORRES value represents the actual colony count from this plate. However, the sample that was spread on this plate represented a 100-fold dilution from the original subject sample. This information is represented in the Dilution Factor supplemental qualifier (MBDILFCT), whose value = 10^-2 (1/100th). In order to enable more straightforward pooling of CFU data, a simple integer result (14700) is used in MBSTRESC/N, and MBSTRESU="CFU/mL". The medium type for the solid culture is also represented as a supplemental qualifier.

mb.xpt

Row STUDYID DOMAIN USUBJID SPDEVID MBSEQ MBGRPID MBLNKGRP MBREFID MBTESTCD MBTEST MBTSTDTL MBORRES MBORRESU MBRSLSCL MBSTRESC MBSTRESN MBSTRESU MBLOC MBSPCCND MBMETHOD VISITNUM VISIT MBDTC 1 ABC MB ABC-01101

1 1 100.1 AFB Acid-Fast Bacilli DETECTION PRESENT Ord PRESENT STOMACH CONCENTRATED ZIEHL NEELSEN ACID

FAST STAIN

1 WEEK 1

2011-0117T06:00 2 ABC MB ABC-01101

2 1 100.1 AFB Acid-Fast Bacilli CELL COUNT 3+ Ord 3+ STOMACH CONCENTRATED ZIEHL NEELSEN ACID

FAST STAIN

1 WEEK 1

2011-0117T06:00 3 ABC MB ABC-01101

ABC765 3 100.2 MTBCMPLX Mycobacterium

Tuberculosis Complex

DETECTION PRESENT Ord PRESENT STOMACH NUCLEIC ACID AMPLIFICATION TEST

1 WEEK 1

2011-0117T06:00 4 ABC MB ABC-01101

4 2 1 100.3 MTB Mycobacterium tuberculosis

DETECTION PRESENT Ord PRESENT STOMACH MICROBIAL CULTURE, SOLID

1 WEEK 1

2011-0117T06:00 5 ABC MB ABC-01101

5 2 1 100.3 MTB Mycobacterium tuberculosis

COLONY COUNT

147 CFU Qn 14700 14700 CFU/mL STOMACH MICROBIAL CULTURE, SOLID

1 WEEK 1

2011-0117T06:00 6 ABC MB ABC-01101

6 2 1 100.3 MTB Mycobacterium tuberculosis

COLONY COUNT

2+ Ord 2+ STOMACH MICROBIAL CULTURE, SOLID

1 WEEK 1

2011-0117T06:00 suppmb.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC MB ABC-01-101 MBSEQ 2 MBQSCAL Quantification Scale Smear Quantification: Centers for Disease Control Method for Carbol Fuchsin Staining (1000X) Collected 2 ABC MB ABC-01-101 MBSEQ 3 MBMICERT Microbial Identification Certainty DEFINITIVE Collected 3 ABC MB ABC-01-101 MBSEQ 4 MBMICERT Microbial Identification Certainty PRESUMPTIVE Collected 4 ABC MB ABC-01-101 MBREFID 100.3 MBMEDTYP Medium Type MIDDLEBROOK 7H10 AGAR Collected 7 ABC MB ABC-01-101 MBSEQ 6 MBQSCAL Quantification Scale Solid Media Result: Centers for Disease Control (CDC) Quantification Scale Collected 8 ABC MB ABC-01-101 MBSEQ 5 MBDILFCT Dilution Factor 10^-2 Collected

Results from drug susceptibility tests performed on samples are represented in the MS domain. This includes all phenotypic tests (where the drug is added directly to the culture medium) and genotypic tests (when the result is given as susceptible or resistant). Genotypic tests that give results of specific genetic polymorphisms should be represented in the Pharmacogenomics/Genetics Findings (PF) domain, even though such results may be categorized as susceptible or resistant. In this example, the variable NHOID (Non-host Organism Identifier) is populated with the name of the organism that is the subject of the test.

Rows 1-2: Show phenotypic testing results on 2 separate culture plates: 1 with medium containing rifampicin (row 1) and 1 with medium containing isoniazid (row 2). MSAGENT is populated with the name of the drug being used in the susceptibility test. The variables MSCONC and MSCONCU represent the concentration and units of the drug being used. The culture start and stop dates are represented in BE and can be linked to MS by BELNKID and MSLNKID.

Rows 3-4: Show genotypic susceptibility testing results on the same aliquot from a NAAT that looks for mutations that confer resistance to 2 drugs. MSAGENT should be populated with the name of the drug whose action is affected by the mutation being tested for. However, because the drug is not used in the test, MSCONC and MSCONU should be null. These results are represented in MS because the only result given is in terms of resistant/susceptible; no genetic results are reported.

ms.xpt

Row STUDYID DOMAIN USUBJID SPDEVID NHOID MSSEQ MSREFID MSLNKID MSTESTCD MSTEST MSAGENT MSCONC MSCONCU MSORRES MSSTRESC MSSPEC MSLOC MSMETHOD MSDTC 1 ABC MS ABC-01101

MYCOBACTERIUM TUBERCULOSIS

1 100.4 2 MICROSUS Microbial

Susceptibility

Rifampicin 1 ug/mL RESISTANT RESISTANT LAVAGE FLUID

STOMACH ANTIBIOTIC AGAR

SCREEN

2011-0117T06:00 2 ABC MS ABC-01101

MYCOBACTERIUM TUBERCULOSIS

2 100.5 3 MICROSUS Microbial

Susceptibility

Isoniazid 0.2 ug/mL SUSCEPTIBLE SUSCEPTIBLE LAVAGE

FLUID

STOMACH ANTIBIOTIC AGAR

SCREEN

2011-0117T06:00 3 ABC MS ABC-01101

ABC765 MYCOBACTERIUM TUBERCULOSIS

3 100.2 MICROSUS Microbial

Susceptibility

Rifampicin RESISTANT RESISTANT LAVAGE FLUID

STOMACH NUCLEIC ACID

AMPLIFICATION TEST

2011-0117T06:00 4 ABC MS ABC-01101

ABC765 MYCOBACTERIUM TUBERCULOSIS

4 100.2 MICROSUS Microbial

Susceptibility

Isoniazid SUSCEPTIBLE SUSCEPTIBLE LAVAGE

FLUID

STOMACH NUCLEIC ACID

AMPLIFICATION TEST

2011-0117T06:00 suppms.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC MS ABC-01-101 MBREFID 100.4 MSMEDTYPE Medium Type LOWENSTEIN-JENSEN Collected 2 ABC MS ABC-01-101 MBREFID 100.5 MSMEDTYPE Medium Type LOWENSTEIN-JENSEN Collected

di.xpt

Row STUDYID DOMAIN SPDEVID DISEQ DIPARMCD DIPARM DIVAL 1 ABC DI ABC765 1 DEVTYPE Device Type NUCLEIC ACID AMPLIFICATION TEST 2 ABC DI ABC765 2 TRADENAM Trade Name HAIN GENOTYPE MTBDRplus

The RELREC table shows how culture start and end dates from BE were linked to the culture results in MB and MS using --LNKID and --LNKGRP. It also shows how the detection record (MB) was linked to the susceptibility results (MS) from the NAAT, using --REFID.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC BE BELNKID ONE A 2 ABC MB MBLNKGRP MANY A 3 ABC BE BELNKID ONE B 4 ABC MS MSLNKID ONE B 5 ABC MB MBREFID ONE C 6 ABC MS MSREFID MANY C

Example 4

When a culture has become contaminated, the sponsor may choose to report results despite the contamination. This example below how to flag results using a supplemental qualifier to indicate that the results are coming from a contaminated culture. This example also illustrates how to use Timing variables to represent an 8-hour pooled overnight sputum sample collection when the start and end times are collected. MBDTC is used to represent the start date/time of the overnight sputum collection and MBENDTC is used to represent the end date/time.

Row 1: Shows a test targeting the presence or absence of M. tuberculosis from a solid culture that has been contaminated (see SUPPMB).

Row 2: Shows the number of colony-forming units from the contaminated solid culture (see SUPPMB).

mb.xpt

Row STUDYID DOMAIN USUBJID MBSEQ MBREFID MBGPRID MBTESTCD MBTEST MBTSTDTL MBORRES MBORRESU MBRSLSCL MBSTRESC MBTRESN MBSTRESU MBSPEC MBLOC MBMETHOD VISITNUM VISIT MBDTC MBENDTC 1 ABC MB ABC-01601

1 600 1 MTB Mycobacterium tuberculosis

DETECTION PRESENT Ord PRESENT SPUTUM LUNG MICROBIAL CULTURE, SOLID

5 WEEK 5

2011-0301T22:00

2011-0302T06:00

2 ABC MB ABC-01601

2 600 1 MTB Mycobacterium tuberculosis

COLONY COUNT

87 CFU/mL Qn 87 87 CFU/mL SPUTUM LUNG MICROBIAL CULTURE, SOLID

5 WEEK 5

2011-0301T22:00

2011-0302T06:00

The culture-contamination indicator flag is shown in SUPPMB.

suppmb.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG 1 ABC MB ABC-01-601 MBSEQ 1 MBCNMIND Culture Contamination Indicator Y Collected 2 ABC MB ABC-01-601 MBSEQ 2 MBCNMIND Culture Contamination Indicator Y Collected

6.3.5.8 Microscopic Findings (MI)

MI – Description/Overview

A findings domain that contains histopathology findings and microscopic evaluations.

The MI dataset provides a record for each microscopic finding observed. There may be multiple microscopic tests on a subject or specimen.

## Microscopic Findings (MI)

*Structure: One record per finding per specimen per subject, Tabulation.*

A findings domain that contains histopathology findings and microscopic evaluations.

The MI dataset provides a record for each microscopic finding observed. There may be multiple microscopic tests on a subject or specimen.

### MI Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | MI | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| MISEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| MIGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. This is not the treatment group number. | Perm |
| MIREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier. Example: specimen barcode number. | Perm |
| MISPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be printed on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: line number from the MI Findings page. | Perm |

### MI Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MITESTCD | Microscopic Examination Short Name | Char | (MITSCD) | Topic | Short name of the measurement, test, or examination described in MITEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in MITESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). MITESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "HER2", "BRCA1", "TTF1". | Req |
| MITEST | Microscopic Examination Name | Char | (MITS) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in MITEST cannot be longer than 40 characters. Examples: "Human Epidermal Growth Factor Receptor 2", "Breast Cancer Susceptibility Gene 1", "Thyroid Transcription Factor 1". | Req |

### MI Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MITSTDTL | Microscopic Examination Detail | Char | (MIFTSDTL) | Record Qualifier | Further description of the test performed in producing the MI result. This would be used to represent specific attributes, such as intensity score or percentage of cells displaying presence of the biomarker or compound. | Perm |
| MICAT | Category for Microscopic Finding | Char | * | Grouping Qualifier | Used to define a category of related records. | Perm |
| MISCAT | Subcategory for Microscopic Finding | Char | * | Grouping Qualifier | Used to define a further categorization of MICAT. | Perm |
| MIORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the histopathology measurement or finding as originally received or collected. | Exp |
| MIORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original unit for MIORRES. | Perm |

### MI Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MISTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from MIORRES in a standard format or standard units. MISTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in MISTRESN. | Exp |
| MISTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from MISTRESC. MISTRESN should store all numeric test results or findings. | Perm |
| MISTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for MISTRESC and MISTRESN. | Perm |
| MIRESCAT | Result Category | Char | * | Variable Qualifier | Used to categorize the result of a finding. Examples: "MALIGNANT" or "BENIGN" for tumor findings. | Perm |

### MI Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MISTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate examination not done or result is missing. Should be null if a result exists in MIORRES or have a value of "NOT DONE" when MIORRES = "NULL". | Perm |
| MIREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with MISTAT when value is NOT DONE. Examples: "SAMPLE AUTOLYZED", "SPECIMEN LOST". | Perm |
| MINAM | Laboratory/Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor (e.g., laboratory) that provided the test results. | Perm |
| MISPEC | Specimen Material Type | Char | (SPECTYPE) | Record Qualifier | Subject of the observation. Defines the type of specimen used for a measurement. Examples: "TISSUE", "BLOOD", "BONE MARROW". | Req |
| MISPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Free or standardized text describing the condition of the specimen. Example: "AUTOLYZED". | Exp |

### MI Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MILOC | Specimen Collection Location | Char | (LOC) | Record Qualifier | Location relevant to the collection of the specimen. Examples: "LUNG", "KNEE JOINT", "ARM", "THIGH". | Perm |
| MILAT | Specimen Laterality within Subject | Char | (LAT) | Variable Qualifier | Qualifier for laterality of the location of the specimen in MILOC. Examples: "LEFT", "RIGHT", "BILATERAL". | Perm |
| MIDIR | Specimen Directionality within Subject | Char | (DIR) | Variable Qualifier | Qualifier for directionality of the location of the specimen in MILOC. Examples: "DORSAL", "PROXIMAL". | Perm |
| MIMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. This could include the technique or type of staining used for the slides. Examples: "IHC", "Crystal violet", "Safranin", "Trypan blue", or "Propidium iodide". | Perm |
| MILOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |

### MI Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MIBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. The value should be "Y" or null. Note that MIBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| MIEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Example: "PATHOLOGIST", "PEER REVIEW", "SPONSOR PATHOLOGIST". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |

### MI Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the specimen was collected. | Perm |
| MIDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of specimen collection, in ISO 8601 format. | Exp |
| MIDY | Study Day of Specimen Collection | Num |  | Timing | Study day of specimen collection, in integer days. The algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in the Demographics (DM) domain. | Perm |

### MI Assumptions

1. This domain holds findings resulting from the microscopic examination of tissue samples. These examinations are performed on a specimen, usually

one that has been prepared with some type of stain. Some examinations of cells in fluid specimens (e.g., blood, urine) are classified as lab tests and should be stored in the Laboratory Test Results (LB) domain. Biomarkers assessed by histologic or histopathological examination (by employing cytochemical/immunocytochemical stains) are stored in the MI domain.

2. When biomarker results are represented in MI, MITESTCD reflects the biomarker of interest (e.g., "BRCA1", "HER2", "TTF1"), and MITSTDTL

further qualifies the record. MITSTDTL is used to represent details descriptive of staining results (e.g., "H SCORE TOTAL SCORE", "STAINING INTENSITY", "PERCENT POSITIVE CELL").

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the MI domain, but the following qualifiers would

generally not be used: --POS, --MODIFY, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --STNRC, --NRIND, --LEAD, --CSTATE, --BLFL, -- FAST, --DRVFL, --LLOQ, --ULOQ.

## Pharmacokinetics Concentrations (PC)

*Structure: One record per sample characteristic or time-point concentration per reference time point or per.*

A findings domain that contains concentrations of drugs or metabolites in fluids or tissues as a function of time.

### PC Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | PC | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| PCSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| PCGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain to support relationships within the domain and between domains. | Perm |
| PCREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier. | Perm |
| PCSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. | Perm |

### PC Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCTESTCD | Pharmacokinetic Test Short Name | Char |  | Topic | Short name of the analyte or specimen characteristic. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in PCTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). PCTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "ASA", "VOL", "SPG". | Req |
| PCTEST | Pharmacokinetic Test Name | Char |  | Synonym Qualifier | Name of the analyte or specimen characteristic. Note any test normally performed by a clinical laboratory is considered a lab test. The value in PCTEST cannot be longer than 40 characters. Examples: "Acetylsalicylic Acid", "Volume", "Specific Gravity". | Req |
| PCCAT | Test Category | Char | * | Grouping Qualifier | Used to define a category of related records. Examples: "ANALYTE", "SPECIMEN PROPERTY". | Perm |

### PC Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCSCAT | Test Subcategory | Char | * | Grouping Qualifier | A further categorization of a test category. | Perm |
| PCORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| PCORRESU | Original Units | Char | (PKUNIT) | Variable Qualifier | Original units in which the data were collected. The unit for PCORRES. Example: "mg/L". | Exp |
| PCSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from PCORRES in a standard format or standard units. PCSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in PCSTRESN. For example, if a test has results "NONE", "NEG", and "NEGATIVE" in PCORRES, and these results effectively have the same meaning, they could be represented in standard format in PCSTRESC as "NEGATIVE". For other examples, see general assumptions. | Exp |

### PC Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from PCSTRESC. PCSTRESN should store all numeric test results or findings. | Exp |
| PCSTRESU | Standard Units | Char | (PKUNIT) | Variable Qualifier | Standardized unit used for PCSTRESC and PCSTRESN. | Exp |
| PCSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate a result was not obtained. Should be null if a result exists in PCORRES. | Perm |
| PCREASND | Reason Test Not Done | Char |  | Record Qualifier | Describes why a result was not obtained, such as "SPECIMEN LOST". Used in conjunction with PCSTAT when value is "NOT DONE". | Perm |
| PCNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the laboratory or vendor who provides the test results. | Exp |
| PCSPEC | Specimen Material Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. Examples: "SERUM", "PLASMA", "URINE". | Exp |

### PC Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCSPCCND | Specimen Condition | Char | (SPECCOND) | Record Qualifier | Free or standardized text describing the condition of the specimen. Examples: "HEMOLYZED", "ICTERIC", "LIPEMIC". | Perm |
| PCMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "HPLC/MS", "ELISA". This should contain sufficient information and granularity to allow differentiation of various methods that might have been used within a study. | Perm |
| PCFAST | Fasting Status | Char | (NY) | Record Qualifier | Indicator used to identify fasting status. | Perm |
| PCDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records, which do not come from the CRF, are examples of records that would be derived for the submission datasets. If PCDRVFL = "Y", then PCORRES may be null with PCSTRESC, and PCSTRESN (if the result is numeric) having the derived value. | Perm |

### PC Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCLLOQ | Lower Limit of Quantitation | Num |  | Variable Qualifier | Indicates the lower limit of quantitation for an assay. Units should be those used in PCSTRESU. | Exp |
| PCULOQ | Upper Limit of Quantitation | Num |  | Variable Qualifier | Indicates the upper limit of quantitation for an assay. Units should be those used in PCSTRESU. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |

### PC Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| PCDTC | Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of specimen collection represented in ISO 8601 character format. If there is no end time, then this will be the collection time. | Exp |
| PCENDTC | End Date/Time of Specimen Collection | Char | ISO 8601 datetime or interval | Timing | End date/time of specimen collection represented in ISO 8601 character format. If there is no end time, the collection time should be stored in PCDTC, and PCENDTC should be null. | Perm |
| PCDY | Actual Study Day of Specimen Collection | Num |  | Timing | Study day of specimen collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### PC Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCENDY | Study Day of End of Observation | Num |  | Timing | Actual study day of end of observation expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| PCTPT | Planned Time Point Name | Char |  | Timing | Text description of time when specimen should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See PCTPTNUM and PCTPTREF. Examples: "Start", "5 min post". | Perm |
| PCTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of PCTPT to aid in sorting. | Perm |
| PCELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (PCTPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date time variable. | Perm |

### PC Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PCTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point used as a basis for PCTPT, PCTPTNUM, and PCELTM. Example: "MOST RECENT DOSE". | Perm |
| PCRFTDTC | Date/Time of Reference Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point described by PCTPTREF. | Perm |
| PCEVLINT | Evaluation Interval | Char | ISO 8601 duration or interval | Timing | Evaluation Interval associated with a PCTEST record represented in ISO 8601 character format. Example: "-PT2H" to represent an evaluation interval of 2 hours prior to a PCTPT. | Perm |

### PC Assumptions

1. This domain can be used to represent specimen properties (e.g., volume, pH) in addition to drug and metabolite concentration measurements.

2. CDISC Controlled Terminology Rules for Pharmacokinetics are available at https://www.cdisc.org/standards/terminology/controlled-terminology.

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the PC domain, but the following Qualifiers would

not generally be used: --BODSYS, --SEV.

## Pharmacokinetics Parameters (PP)

*Structure: One record per PK parameter per time-concentration profile per modeling method per subject, Tabulation.*

A findings domain that contains pharmacokinetic parameters derived from pharmacokinetic concentration-time (PC) data.

### PP Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | PP | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| PPSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| PPGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain to support relationships within the domain and between domains. | Perm |

### PP Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PPTESTCD | Parameter Short Name | Char | (PKPARMCD) | Topic | Short name of the pharmacokinetic parameter. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in PPTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). PPTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "AUCALL", "TMAX", "CMAX". | Req |
| PPTEST | Parameter Name | Char | (PKPARM) | Synonym Qualifier | Name of the pharmacokinetic parameter. The value in PPTEST cannot be longer than 40 characters. Examples: "AUC All", "Time of CMAX", "Max Conc". | Req |
| PPCAT | Parameter Category | Char | * | Grouping Qualifier | Used to define a category of related records. For PP, this should be the name of the analyte in PCTEST whose profile the parameter is associated with. | Exp |

### PP Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PPSCAT | Parameter Subcategory | Char | * | Grouping Qualifier | Categorization of the model type used to calculate the PK parameters. Examples: "COMPARTMENTAL", "NON-COMPARTMENTAL". | Perm |
| PPORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| PPORRESU | Original Units | Char | (PKUNIT) (PKUWG) (PKUWKG) (PKUDMG) (PKUDUG) | Variable Qualifier | Original units in which the data were collected. The unit for PPORRES. Example: "ng/L". See PP Assumption 3. | Exp |
| PPSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from PPORRES in a standard format or standard units. PPSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in PPSTRESN. | Exp |

### PP Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PPSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from PPSTRESC. PPSTRESN should store all numeric test results or findings. | Exp |
| PPSTRESU | Standard Units | Char | (PKUNIT) (PKUWG) (PKUWKG) (PKUDMG) (PKUDUG) | Variable Qualifier | Standardized unit used for PPSTRESC and PPSTRESN. See PP Assumption 3. | Exp |
| PPSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a parameter was not calculated. Should be null if a result exists in PPORRES. | Perm |
| PPREASND | Reason Parameter Not Calculated | Char |  | Record Qualifier | Describes why a parameter was not calculated, such as "INSUFFICIENT DATA". Used in conjunction with PPSTAT when value is "NOT DONE". | Perm |

### PP Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PPSPEC | Specimen Material Type | Char | (SPECTYPE) | Record Qualifier | Defines the type of specimen used for a measurement. If multiple specimen types are used for a calculation (e.g., serum and urine for renal clearance), then this field should be left blank. Examples: "SERUM", "PLASMA", "URINE". | Exp |
| PPANMETH | Analysis Method | Char | (PKANMET) | Record Qualifier | Analysis method applied to obtain a summarized result. Analysis method describes the method of secondary processing applied to a complex observation result. Example: A named formula used to calculate AUC, such as "LIN-LOG TRAPEZOIDAL METHOD". Sponsor-defined formulas can also be represented by this variable. Example: Calculating ratio AUCs where the PPANMETH may be "DRUG METABOLITE 1 TO DRUG PARENT" or "DRUG METABOLITE 2 TO METABOLITE 1". | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |

### PP Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the observation, or the date/time of collection if start date/time is not collected. | Perm |
| PPDTC | Date/Time of Parameter Calculations | Char | ISO 8601 datetime or interval | Timing | Nominal date/time of parameter calculations. | Perm |
| PPDY | Study Day of Parameter Calculations | Num |  | Timing | Study day of the collection, in integer days. The algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in the Demographics (DM) domain. | Perm |
| PPTPTREF | Time Point Reference | Char |  | Timing | The description of a time point that acts as a fixed reference for a series of planned time points. | Perm |
| PPRFTDTC | Date/Time of Reference Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point from the PC records used to calculate a parameter record. The values in PPRFTDTC should be the same as that in PCRFTDTC for related records. | Exp |

### PP Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PPSTINT | Planned Start of Assessment Interval | Char | ISO 8601 duration | Timing | The start of a planned evaluation or assessment interval relative to the time point reference. | Perm |
| PPENINT | Planned End of Assessment Interval | Char | ISO 8601 duration | Timing | The end of a planned evaluation or assessment interval relative to the time point reference. | Perm |

### PP Assumptions

1. Pharmacokinetics Parameters is a derived dataset, and may be produced from an analysis dataset with a different structure. As a result, some sponsors may need to normalize their analysis dataset in order for

it to fit into the SDTM-based PP domain.

2. Information pertaining to all parameters (e.g., number of exponents, model weighting) should be submitted in the SUPPPP dataset.

3. There are separate codelists used for PPORRESU/PPSTRESU where the choice depends on whether the value of the pharmacokinetic parameter is normalized.

a. Codelist “PKUNIT” is used for non-normalized parameters.

b. Codelists “PKUDMG” and “PKUDUG” are used when parameters are normalized by dose amount in milligrams or micrograms, respectively.

c. Codelists “PKUWG” and “PKUWKG” are used when parameters are normalized by weight in grams or kilograms, respectively.

## Cardiovascular System Findings (CV)

*Structure: One record per finding or result per time point per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the cardiovascular system, including the heart, blood vessels and lymphatic vessels.

### CV Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | -- | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| --SEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject (or within a parameter, in the case of the Trial Summary domain). May be any valid number (including decimals) and does not have to start at 1. | Req |
| --TESTCD | Short Name of Measurement, Test or Exam | Char | * | Topic | Short character value for --TEST used as a column name when converting a dataset from a vertical format to a horizontal format. The short value can be up to 8 characters. Subject to Domain-specific test code controlled terminology. | Req |

### CV Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| --TEST | Name of Measurement, Test or Examination | Char | * | Synonym Qualifier | Long name for --TESTCD. Subject to Domain-specific test code controlled terminology. | Req |
| --ORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| --STRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from --ORRES in a standard format or in standard units. --STRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in --STRESN. For example, if various tests have results "NONE", "NEG", and "NEGATIVE" in --ORRES, and these results effectively have the same meaning, they could be represented in standard format in --STRESC as "NEGATIVE". | Exp |

### CV Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| --LOBXFL | Last Observation Before Exposure Flag | Char |  | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| --DTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |
| --DY | Study Day of Collection | Num |  | Timing | Study day of the collection, in integer days. The algorithm for calculations must be relative to the sponsor- defined RFSTDTC variable in the Demographics (DM) domain. | Exp |
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | CV | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |

### CV Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| CVGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| CVREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier. | Perm |
| CVSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. Example: a preprinted line identifier on a CRF. | Perm |
| CVLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| CVLNKGRP | Link Group | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |

### CV Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVTESTCD | Short Name of Cardiovascular Test | Char | (CVTESTCD) | Topic | Short name of the measurement, test, or examination described in CVTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in CVTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" would not be valid). CVTESTCD cannot contain characters other than letters, numbers, or underscores. | Req |
| CVTEST | Name of Cardiovascular Test | Char | (CVTEST) | Synonym Qualifier | Long name For CVTESTCD. The value in CVTEST cannot be longer than 40 characters. | Req |
| CVCAT | Category for Cardiovascular Test | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. | Perm |
| CVSCAT | Subcategory for Cardiovascular Test | Char | * | Grouping Qualifier | Used to define a further categorization of CVCAT values. | Perm |

### CV Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVPOS | Position of Subject During Observation | Char | (POSITION) | Record Qualifier | Position of the subject during a measurement or examination. Examples: "SUPINE", "STANDING", "SITTING". | Perm |
| CVORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| CVORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. Unit for CVORRES. | Perm |

### CV Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVSTRESC | Character Result/Finding in Std Format | Char | * | Result Qualifier | Contains the result value for all findings, copied or derived, from CVORRES in a standard format or in standard units. CVSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in CVSTRESN. For example, if various tests have results "NONE", "NEG", and "NEGATIVE" in CVORRES and these results effectively have the same meaning, they could be represented in standard format in CVSTRESC as "NEGATIVE". | Exp |
| CVSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from CVSTRESC. CVSTRESN should store all numeric test results or findings. | Perm |
| CVSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for CVSTRESC and CVSTRESN. | Perm |

### CV Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| CVREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed (e.g., "BROKEN EQUIPMENT", "SUBJECT REFUSED"). Used in conjunction with CVSTAT when value is "NOT DONE". | Perm |
| CVLOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Examples: "HEART", "LEFT VENTRICLE". | Perm |
| CVLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL", "UNILATERAL". | Perm |
| CVDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |

### CV Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method used to create the result. | Perm |
| CVLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| CVBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that CVBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| CVDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (i.e., a record that represents the average of other records, such as a computed baseline). Should be "Y" or null. | Perm |

### CV Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", " INDEPENDENT ASSESSOR", "RADIOLOGIST". | Perm |
| CVEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in CVEVAL. Examples: "RADIOLOGIST1" or "RADIOLOGIST2". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |

### CV Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| CVDTC | Date/Time of Test | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |
| CVDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| CVTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken, as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See CVTPTNUM and CVTPTREF. | Perm |
| CVTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |

### CV Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| CVELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (CVTPTREF). Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| CVTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by CVELTM, CVTPTNUM, and CVTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| CVRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by CVTPTREF. | Perm |

### CV Assumptions

1. The Cardiovascular System Findings domain is used to represent results and findings of cardiovascular diagnostic procedures. Information about the

conduct of the procedure(s), if collected, is submitted in the Procedures (PR) domain.

2. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the CV domain, but the following qualifiers would

generally not be used: --MODIFY, --BODSYS, --FAST, --ORNRLO, --ORNRHI, --TNRLO, --STNRHI, and --LOINC.

## Musculoskeletal System Findings (MK)

*Structure: One record per assessment per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the system of muscles, tendons, ligaments, bones, joints, and associated tissues.

### MK Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | MK | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| MKSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject (or within a parameter, in the case of the Trial Summary domain). May be any valid number (including decimals) and does not have to start at 1. | Req |
| MKGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. | Perm |
| MKREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier such as lab specimen ID or a medical image. | Perm |

### MK Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. Example: Preprinted line identifier on a Concomitant Medications page. | Perm |
| MKLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| MKLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| MKTESTCD | Short Name of Musculoskeletal Test | Char | (MUSCTSCD) | Topic | Short character value for MKTEST used as a column name when converting a dataset from a vertical format to a horizontal format. The value in MKTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). MKTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "TNDRIND", "SWLLIND", "SGJSNSCR". | Req |

### MK Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKTEST | Name of Musculoskeletal Test | Char | (MUSCTS) | Synonym Qualifier | Long name For MKTESTCD. Examples: "Tenderness Indicator", "Swollen Indicator", "Sharp/Genant JSN Score". | Req |
| MKCAT | Category for Musculoskeletal Test | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. Examples: "SWOLLEN/TENDER JOINT ASSESSMENT". | Perm |
| MKSCAT | Subcategory for Musculoskeletal Test | Char | * | Grouping Qualifier | Used to define a further categorization of MKCAT values. | Perm |
| MKPOS | Position of Subject | Char | (POSITION) | Record Qualifier | Position of the subject during a measurement or examination. Examples: "SUPINE", "STANDING", "SITTING". | Perm |
| MKORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| MKORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for MKORRES. | Perm |

### MK Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from MKORRES in a standard format or in standard units. MKSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in MKSTRESN. For example, if various tests have results "NONE", "NEG", and "NEGATIVE" in MKORRES and these results effectively have the same meaning, they could be represented in standard format in MKSTRESC as "NEGATIVE". | Exp |
| MKSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from MKSTRESC. MKSTRESN should store all numeric test results or findings. | Perm |
| MKSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for MKSTRESC and MKSTRESN. | Perm |

### MK Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or that a test was attempted but did not generate a result. Should be null if a result exists in MKORRES. | Perm |
| MKREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with MKSTAT when value is "NOT DONE". | Perm |
| MKLOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Examples: "INTERPHALANGEAL JOINT 1", "SHOULDER JOINT". | Exp |
| MKLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| MKDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |

### MK Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "X-RAY", "MRI", "CT SCAN". | Perm |
| MKLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| MKBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that MKBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| MKDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |

### MK Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "RADIOLOGIST". | Perm |
| MKEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in MKEVAL. Examples: "RADIOLOGIST1" or "RADIOLOGIST2". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |

### MK Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| MKDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |
| MKDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| MKTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See MKTPTNUM and MKTPTREF. | Perm |
| MKTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |

### MK Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| MKELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned Elapsed time relative to a planned fixed reference (MKTPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| MKTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by MKELTM, MKTPTNUM, and MKTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| MKRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by MKTPTREF. | Perm |

### MK Assumptions

1. The Musculoskeletal System Findings domain should not be used for oncology data related to the musculoskeletal system (e.g., bone lesions). Such data

should be placed in the appropriate oncology domains: Tumor/Lesion Identification (TU), Tumor/Lesion Results (TR), and/or Disease Response and Clinical Classification (RS).

2. Musculoskeletal assessment examples that may have results represented in the MK domain include the following: morphology/physiology observations

(e.g., swollen/tender joint count, limb movement, strength/grip measurements).

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the MK domain, but the following qualifiers would

generally not be used: --MODIFY, --BODSYS, --LOINC, --TOX, --TOXGR, --FAST, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --ORREF, -- STREFC, --STREFN.

## Nervous System Findings (NV)

*Structure: One record per finding per location per time point per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the nervous system, including the brain, spinal cord, the cranial and spinal nerves, autonomic ganglia and plexuses.

### NV Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | NV | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| FOCID | Focus of Study-Specific Interest | Char |  | Identifier | Identification of a focus of study-specific interest on or within a subject or specimen as called out in the protocol for which a measurement, test, or examination was performed, such as a drug application site (e.g., "Injection site 1", "Biopsy site 1", "Treated site 1") or a more specific focus (e.g., "OD" (right eye), "Upper left quadrant of the back"). The value in this variable should have inherent semantic meaning. | Perm |
| NVSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |

### NV Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| NVREFID | Reference ID | Char |  | Identifier | Internal or external procedure identifier. | Perm |
| NVSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number from the Procedure or Test page. | Perm |
| NVLNKID | Link ID | Char |  | Identifier | Identifier used to link a procedure to the assessment results over the course of the study. | Perm |
| NVLNKGRP | Link Group | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |

### NV Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVTESTCD | Short Name of Nervous System Test | Char | (NVTESTCD) | Topic | Short name of the measurement, test, or examination described in NVTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in NVTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). NVTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "SUVR", "N75LAT", "P100LAT","N145LAT". | Req |
| NVTEST | Name of Nervous System Test | Char | (NVTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in NVTEST cannot be longer than 40 characters. Examples: "Standard Uptake Value Ratio", "N75 Latency", "P100 Latency", "N145 Latency". | Req |
| NVCAT | Category for Nervous System Test | Char |  | Grouping Qualifier | Used to define a category of topic-variable values. Example: "VISUAL EVOKED POTENTIAL". | Perm |

### NV Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVSCAT | Subcategory for Nervous System Test | Char |  | Grouping Qualifier | Used to define a further categorization of NVCAT values. | Perm |
| NVORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the procedure measurement or finding as originally received or collected. | Exp |
| NVORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for NVORRES. | Perm |
| NVSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from NVORRES, in a standard format or standard units. NVSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in NVSTRESN. | Exp |

### NV Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from NVSTRESC. NVSTRESN should store all numeric test results or findings. | Perm |
| NVSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for NVSTRESC or NVSTRESN. | Perm |
| NVSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate a test was not done, or a measurement was not taken. Should be null if a result exists in NVORRES. | Perm |
| NVREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED". Used in conjunction with NVSTAT when value is "NOT DONE". | Perm |
| NVLOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Examples: "BRAIN", "EYE", "PRECUNEUS", "CINGULATE CORTEX". | Perm |

### NV Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| NVDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| NVMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "EEG", "PET/CT SCAN ", "FDGPET". | Perm |
| NVLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| NVBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that NVBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |

### NV Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| NVEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "RADIOLOGIST". | Perm |
| NVEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in NVEVAL. Examples: "RADIOLOGIST 1", "RADIOLOGIST 2". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |

### NV Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| NVDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date of procedure or test. | Exp |
| NVDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Study day of the procedure or test, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### NV Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVTPT | Planned Time Point Name | Char |  | Timing | Text description of time when measurement should be taken. This may be represented as an elapsed time relative to a fixed reference point (e.g., "TIME OF LAST DOSE"). See NVTPTNUM and NVTPTREF. Examples: "START", "5 MIN POST". | Perm |
| NVTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of NVTPT to aid in sorting. | Perm |
| NVELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a fixed time point reference (NVTPTREF). Not a clock time or a date time variable. Represented as an ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by NVTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by NVTPTREF. | Perm |

### NV Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| NVTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by NVELTM, NVTPTNUM, and NVTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| NVRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by --TPTREF in ISO 8601 character format. | Perm |

### NV Assumptions

1. Methods of assessment for nervous system findings may include nerve conduction studies, electroencephalogram (EEG), electromyography (EMG), and imaging.

2. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the NV domain, but the following qualifiers would not generally be used: --MODIFY, --BODSYS, --

LOINC, --TOX, --TOXGR.

## Ophthalmic Examinations (OE)

*Structure: One record per ophthalmic finding per method per location, per time point per visit per.*

A findings domain that contains tests that measure a person's ocular health and visual status, to detect abnormalities in the components of the visual system, and to determine how well the person can see.

### OE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | OE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| FOCID | Focus of Study-Specific Interest | Char | (OEFOCUS) | Identifier | Identification of a focus of study-specific interest on or within a subject or specimen as called out in the protocol for which a measurement, test, or examination was performed. | Perm |
| OESEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| OEGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |

### OE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OELNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| OELNKGRP | Link Group | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| OETESTCD | Short Name of Ophthalmic Test or Exam | Char | (OETESTCD) | Topic | Short character value for OETEST used as a column name when converting a dataset from a vertical format to a horizontal format. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in OETESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). OETESTCD cannot contain characters other than letters, numbers, or underscores. Example: "NUMLCOR". | Req |

### OE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OETEST | Name of Ophthalmic Test or Exam | Char | (OETEST) | Synonym Qualifier | Long name for the test or examination used to obtain the measurement or finding. The value in OETEST cannot be longer than 40 characters. Example: "Number of Letters Correct" for OETESTCD = "NUMLCOR". | Req |
| OETSTDTL | Ophthalmic Test or Exam Detail | Char | * | Variable Qualifier | Further description of OETESTCD and OETEST. | Perm |
| OECAT | Category for Ophthalmic Test or Exam | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. Examples: "VISUAL ACUITY", "CONTRAST SENSITIVITY", "OCULAR COMFORT". | Perm |
| OESCAT | Subcategory for Ophthalmic Test or Exam | Char | * | Grouping Qualifier | Used to define a further categorization of OECAT values. Example: "HIGH CONTRAST" or "LOW CONTRAST" when OECAT is "VISUAL ACUITY". | Perm |
| OEORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. Examples: "120", "<1, NORMAL", "RED SPOT VISIBLE". | Exp |

### OE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original unit for OEORRES. Examples: "mm", "um". | Exp |
| OEORNRLO | Normal Range Lower Limit-Original Units | Char |  | Variable Qualifier | Lower end of normal range or reference range for results stored in OEORRES. | Perm |
| OEORNRHI | Normal Range Upper Limit-Original Units | Char |  | Variable Qualifier | Upper end of normal range or reference range for results stored in OEORRES. | Perm |
| OESTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from OEORRES, in a standard format or in standard units. OESTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in OESTRESN. | Exp |

### OE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OESTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from OESTRESC. OESTRESN should store all numeric test results or findings. | Exp |
| OESTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for OESTRESC and OESTRESN. Examples: "mm", "um". | Exp |
| OESTNRLO | Normal Range Lower Limit-Standard Units | Num |  | Variable Qualifier | Lower end of normal range or reference range for standardized results (e.g., OESTRESC, OESTRESN) represented in standardized units (OESTRESU). | Perm |
| OESTNRHI | Normal Range Upper Limit-Standard Units | Num |  | Variable Qualifier | Upper end of normal range or reference range for standardized results (e.g., OESTRESC, OESTRESN) represented in standardized units (OESTRESU). | Perm |
| OESTNRC | Normal Range for Character Results | Char |  | Variable Qualifier | Normal range or reference range for results stored in OESTRESC that are character in ordinal or categorical scale. Example: "Negative to Trace". | Perm |

### OE Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OENRIND | Normal/Reference Range Indicator | Char | (NRIND) | Variable Qualifier | Used to indicate the value is outside the normal range or reference range. May be defined by OEORNRLO and OEORNRHI or other objective criteria. Examples: "Y", "N"; "HIGH", "LOW"; "NORMAL", "ABNORMAL". | Perm |
| OERESCAT | Result Category | Char |  | Variable Qualifier | Used to categorize the result of a finding or medical status per interpretation of test results. Examples: "POSITIVE", "NEGATIVE". The variable OERESCAT is not meant to replace the use of OENRIND for cases where normal ranges are provided. | Perm |
| OESTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| OEREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with OESTAT when value is "NOT DONE". | Perm |

### OE Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEXFN | External File Path | Char |  | Record Qualifier | Filename for an external file, such as one for a retinal OCT image. | Perm |
| OELOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Examples: "EYE" for a finding record relative to the complete eye, "RETINA" for a measurement or assessment of only the retina. | Exp |
| OELAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Exp |
| OEDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| OEPORTOT | Portion or Totality | Char | (PORTOT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing the distribution (i.e., arrangement of, apportioning of). Examples: "ENTIRE", "SINGLE", "SEGMENT", "MANY". | Perm |

### OE Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Example: "ETDRS EYE CHART" for OETESTCD = "NUMLCOR". The different methods may offer different functionality or granularity, affecting the set of results and associated meaning. | Exp |
| OELOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| OEBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that OEBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| OEDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |

### OE Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "INDEPENDENT ASSESSOR", "INVESTIGATOR". | Perm |
| OEEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in OEEVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". | Perm |
| OEACPTFL | Accepted Record Flag | Char | (NY) | Record Qualifier | In cases where more than one assessor provides an evaluation of a result or response, this flag identifies the record that is considered, by an independent assessor, to be the accepted evaluation. Expected to be "Y" or null. | Perm |

### OE Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEREPNUM | Repetition Number | Num |  | Record Qualifier | The incidence number of a test that is repeated within a given timeframe for the same test. The level of granularity can vary (e.g., within a time point, within a visit). Examples: multiple measurements of blood pressure, multiple analyses of a sample. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |

### OE Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OEDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date/time of the observation. | Exp |
| OEDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of observation/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Exp |
| OETPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point. | Perm |
| OETPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |
| OEELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (OETPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |

### OE Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| OETPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by OETPT, OETPTNUM, and OEELTM. | Perm |
| OERFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, OETPTREF. | Perm |

### OE Assumptions

1. In ophthalmic studies, the eyes are usually sites of treatment. It is appropriate to identify sites using the variable FOCID. When FOCID is used to

identify the eyes, it is recommended that the values "OD" (oculus dexter, right eye), "OS" (oculus sinister, left eye), and "OU" (oculus uterque, both eyes) be used in FOCID. These terms are the exclusively preferred terms used by the ophthalmology community as abbreviations for the expanded Latin terms, and are included in the nonextensible CDISC Ophthalmic Focus of Study Specific Interest (OEFOCUS) codelist.

2. In any study that uses FOCID, FOCID would be included in records in any subject-level domain representing findings, interventions, or events (e.g.,

Adverse Events) related to the eyes. Whether or not FOCID is used in a study, --LOC and --LAT should be populated in records related to the eyes. The value in OELOC may be "EYE" but may also be a part of the eye (e.g., "RETINA", "CORNEA").

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the OE domain, but the following qualifiers would

not generally be used: --MODIFY, --NSPCES, --POS, --BODSYS, --ORREF, --STREFC, --STREFN, --CHRON, --DISTR, --ANTREG, --LEAD, -- FAST, --TOX, --TOXGR, --LLOQ, --ULOQ.

## Reproductive System Findings (RP)

*Structure: One record per finding or result per time point per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the male and female reproductive systems.

### RP Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | RP | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| RPSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject (or within a parameter, in the case of the Trial Summary domain). May be any valid number (including decimals) and does not have to start at 1. | Req |
| RPGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. Also used to link together a block of related records in the Trial Summary dataset. | Perm |

### RP Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier (e.g., lab specimen ID, UUID for an ECG waveform or a medical image). | Perm |
| RPSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. Example: Preprinted line identifier on a CRF. | Perm |
| RPLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| RPLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| RPTESTCD | Short Name of Reproductive Test | Char | (RPTESTCD) | Topic | Short character value for RPTEST used as a column name when converting a dataset from a vertical format to a horizontal format. The short value can be up to 8 characters. Examples: "CHILDPOT", "BCMETHOD", "MENARAGE". | Req |

### RP Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPTEST | Name of Reproductive Test | Char | (RPTEST) | Synonym Qualifier | Long name For RPTESTCD. Examples: "Childbearing Potential", "Birth Control Method", "Menarche Age". | Req |
| RPCAT | Category for Reproductive Test | Char |  | Grouping Qualifier | Used to define a category of topic-variable values. Example: "No use case to date, but values would be relative to reproduction tests grouping". | Perm |
| RPSCAT | Subcategory for Reproductive Test | Char |  | Grouping Qualifier | Used to define a further categorization of RPCAT values. Example: "No use case to date, but values would be relative to reproduction tests grouping". | Perm |
| RPORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. Examples: "120", "<1", "POS". | Exp |
| RPORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for RPORRES. Examples: "in", "LB", "kg/L". | Perm |

### RP Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from RPORRES, in a standard format or in standard units. RPSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in RPSTRESN. For example, if various tests have results "NONE", "NEG", and "NEGATIVE" in RPORRES, and these results effectively have the same meaning, they could be represented in standard format in RPSTRESC as "NEGATIVE". | Exp |
| RPSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from RPSTRESC. RPSTRESN should store all numeric test results or findings. | Perm |
| RPSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for RPSTRESC and RPSTRESN. Example: "mol/L". | Perm |

### RP Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| RPREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with RPSTAT when value is "NOT DONE". | Perm |
| RPLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| RPBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that RPBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |

### RP Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records which represent the average of other records or which do not come from the CRF are examples of records that would be derived for the submission datasets. If RPDRVFL = "Y", then RPORRES may be null, with RPSTRESC and (if numeric) RPSTRESN having the derived value. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |

### RP Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| RPDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |
| RPDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| RPDUR | Duration | Char | ISO 8601 duration | Timing | Collected duration of an event, intervention, or finding represented in ISO 8601 character format. Used only if collected on the CRF and not derived. | Perm |
| RPTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. | Perm |

### RP Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RPTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |
| RPELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time in ISO 8601 character format relative to a planned fixed reference (RPTPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| RPTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by RPELTM, RPTPTNUM, and RPTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| RPRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by RPTPTREF in ISO 8601 character format. | Perm |

### RP Assumptions

1. Reproductive System Findings domain contains information regarding a subject’s reproductive ability and reproductive history (e.g., number of previous pregnancies, number of births, pregnant during the

study).

2. Information on medications related to reproduction (e.g., contraceptives, fertility treatments) should be included in the Concomitant/Prior Medications (CM) domain; see Section 6.1.2.

3. There are separate codelists for RP tests, responses, and units.

## Respiratory System Findings (RE)

*Structure: One record per finding or result per time point per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the respiratory system, including the organs that are involved in breathing such as the nose, throat, larynx, trachea, bronchi and lungs.

### RE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | RE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SPDEVID | Sponsor Device Identifier | Char |  | Identifier | Sponsor-defined identifier for a device. | Perm |
| RESEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| REGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| REREFID | Reference ID | Char |  | Identifier | Optional internal or external procedure identifier. | Perm |

### RE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RESPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. | Perm |
| RELNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| RELNKGRP | Link Group | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| RETESTCD | Short Name of Respiratory Test | Char | (RETESTCD) | Topic | Short name of the measurement, test, or examination. It can be used as a column name when converting a dataset from a vertical format to a horizontal format. The value in RETESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). RETESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "FEV1", "FVC". | Req |

### RE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RETEST | Name of Respiratory Test | Char | (RETEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in RETEST cannot be longer than 40 characters. Examples: "Forced Expiratory Volume in 1 Second", "Forced Vital Capacity". | Req |
| RECAT | Category for Respiratory Test | Char |  | Grouping Qualifier | Used to categorize observations across subjects. | Perm |
| RESCAT | Subcategory for Respiratory Test | Char |  | Grouping Qualifier | A further categorization. | Perm |
| REPOS | Position of Subject During Observation | Char | (POSITION) | Record Qualifier | Position of the subject during a measurement or examination. Examples: "SUPINE", "STANDING", "SITTING". | Perm |
| REORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the procedure measurement or finding as originally received or collected. | Exp |
| REORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for REORRES and REORREF. | Perm |

### RE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| REORREF | Reference Result in Original Units | Char |  | Variable Qualifier | Reference result for continuous measurements in original units. Should be collected only for continuous results. | Perm |
| RESTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from REORRES in a standard format or in standard units. RESTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in RESTRESN. | Exp |
| RESTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from RESTRESC. RESTRESN should store all numeric test results or findings. | Perm |
| RESTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for RESTRESC, RESTRESN and RESTREFN. | Perm |

### RE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RESTREFC | Character Reference Result | Char |  | Variable Qualifier | Reference value for the result or finding copied or derived from --ORREF in a standard format. | Perm |
| RESTREFN | Numeric Reference Result in Std Units | Num |  | Variable Qualifier | Reference result for continuous measurements in standard units. Should be populated only for continuous results. | Perm |
| RESTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a test was not done or a measurement was not taken. Should be null if a result exists in REORRES. | Perm |
| REREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED". Used in conjunction with RESTAT when value is "NOT DONE". | Perm |
| RELOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Examples: "LUNG", "BRONCHUS". | Perm |

### RE Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RELAT | Laterality | Char | (LAT) | Variable Qualifier | Side of the body used to collect measurement. Examples: "RIGHT", "LEFT". | Perm |
| REDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| REMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method used to create the result. | Perm |
| RELOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| REBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be Y or null. Note that REBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |

### RE Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| REDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. Should be "Y" or null. Records that represent the average of other records, or that do not come from the CRF, or are not as originally collected or received are examples of records that would be derived for the submission datasets. If REDRVFL = "Y", then REORRES could be null, with RESTRESC and (if numeric) RESTRESN having the derived value. | Perm |
| REEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "RADIOLOGIST". | Perm |
| REEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in REEVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". | Perm |

### RE Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| REREPNUM | Repetition Number | Num |  | Record Qualifier | The instance number of a test that is repeated within a given time frame for the same test. The level of granularity can vary (e.g., within a time point, within a visit). Example: multiple measurements of pulmonary function. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |

### RE Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| REDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Date/time of procedure or test. | Exp |
| REDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| RETPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point (e.g., "TIME OF LAST DOSE"). See RETPTNUM and RETPTREF. Examples: "START", "5 MINUTES POST". | Perm |
| RETPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of RETPT to aid in sorting. | Perm |

### RE Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| REELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (RETPTREF). Not a clock time or a date/time variable, but an interval, represented as ISO duration. Examples: "-PT15M" to represent 15 minutes prior to the reference time point indicated by RETPTREF, "PT8H" to represent 8 hours after the reference time point represented by RETPTREF. | Perm |
| RETPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by REELTM, RETPTNUM, and RETPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| RERFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by RETPTREF. | Perm |

### RE Assumptions

1. The Respiratory System Findings domain is used to represent the results/findings of respiratory diagnostic procedures (e.g., spirometry). Information

about the conduct of the procedure(s), if collected, should be submitted in the Procedures (PR) domain.

2. Many respiratory assessments require the use of a device. When data about the device used for an assessment or additional information about its use in

the assessment are collected, SPDEVID should be included in the record. See the SDTMIG for Medical Devices (SDTMIG-MD, available at https://www.cdisc.org/standards/foundational/medical-devices-sdtmig/) for further information about SPDEVID and the Device domains.

3. Any Identifier variables, Timing variables, or Findings general observation class qualifiers may be added to the RE domain, but the following qualifiers

would generally not be used: --MODIFY, --BODSYS, and --FAST.

## Urinary System Findings (UR)

*Structure: One record per finding per location per per visit per subject, Tabulation.*

A findings domain that contains physiological and morphological findings related to the urinary tract, including the organs involved in the creation and excretion of urine such as the kidneys, ureters, bladder and urethra.

### UR Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | UR | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| URSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number (including decimals) and does not have to start at 1. | Req |
| URGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| URREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier (e.g., lab specimen ID, universally unique identifier (UUID) for a medical image). | Perm |
| URSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. Example: Preprinted line identifier. | Perm |

### UR Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URLNKID | Link ID | Char |  | Identifier | Identifier used to link related records across domains. This may be a one-to-one or a one-to-many relationship. | Perm |
| URLNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| URTESTCD | Short Name of Urinary Test | Char | (URNSTSCD) | Topic | Short character value for URTEST used as a column name when converting a dataset from a vertical format to a horizontal format. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in URTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). URTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "COUNT", "LENGTH", "RBLDFLW". | Req |

### UR Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URTEST | Name of Urinary Test | Char | (URNSTS) | Synonym Qualifier | Long name For URTESTCD. Examples: "Count", "Length", "Renal Blood Flow". | Req |
| URTSTDTL | Urinary Test Detail | Char | * | Variable Qualifier | Further description of URTESTCD and URTEST. | Perm |
| URCAT | Category for Urinary Test | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. | Perm |
| URSCAT | Subcategory for Urinary Test | Char | * | Grouping Qualifier | Used to define a further categorization of URCAT values. | Perm |
| URORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| URORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for URORRES. | Perm |

### UR Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from URORRES, in a standard format or in standard units. URSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in URSTRESN. | Exp |
| URSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from URSTRESC. URSTRESN should store all numeric test results or findings. | Perm |
| URSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for URSTRESC and URSTRESN. | Perm |
| URRESCAT | Result Category | Char |  | Variable Qualifier | Used to categorize the result of a finding. | Perm |

### UR Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not asked or a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |
| URREASND | Reason Not Done | Char |  | Record Qualifier | Reason not done. Used in conjunction with URSTAT when value is "NOT DONE". | Perm |
| URLOC | Location Used for the Measurement | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. | Perm |
| URLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| URDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality. Examples: "ANTERIOR", "LOWER", "PROXIMAL". | Perm |
| URMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. | Perm |

### UR Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |
| URBLFL | Baseline Flag | Char | (NY) | Record Qualifier | A baseline defined by the sponsor The value should be "Y" or null. Note that URBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| URDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| UREVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "RADIOLOGIST". | Perm |

### UR Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| UREVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in UREVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the observation was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the observation was made. | Perm |
| URDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation. | Exp |

### UR Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |
| URTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point (e.g., time of last dose). See URTPTNUM and URTPTREF. | Perm |
| URTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |
| URELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (URTPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |

### UR Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| URTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by URELTM, URTPTNUM, and URTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| URRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by URTPTREF. | Perm |

### UR Assumptions

1. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the UR domain, but the following qualifiers would

not generally be used: --MODIFY, --BODSYS, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --NRIND, --LOINC, --SPCCND, --FAST, --TOX, -- TOXGR, --SEV, --LLOQ.

## Physical Examination (PE)

*Structure: One record per body system or abnormality per visit per subject, Tabulation.*

A findings domain that contains findings observed during a physical examination where the body is evaluated by inspection, palpation, percussion, and auscultation.

### PE Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | PE | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| PESEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number. | Req |
| PEGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records in a single domain for a subject. | Perm |
| PESPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. Perhaps preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a CRF. | Perm |

### PE Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PETESTCD | Body System Examined Short Name | Char | * | Topic | Short name of a part of the body examined in a physical examination. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in PETESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). PETESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "HEAD", "ENT". If the results of the entire physical examination are represented in one record, value should be "PHYSEXAM". | Req |
| PETEST | Body System Examined | Char | * | Synonym Qualifier | Long name of a part of the body examined in a physical examination. The value in PETEST cannot be longer than 40 characters. Examples: "Head", "Ear/Nose/Throat". If the results of the entire physical examination are represented in one record, value should be "Physical Examination". | Req |

### PE Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PEMODIFY | Modified Reported Term | Char |  | Synonym Qualifier | If the value of PEORRES is modified for coding purposes, then the modified text is placed here. | Perm |
| PECAT | Category for Examination | Char | * | Grouping Qualifier | Used to define a category of topic-variable values. Example: "GENERAL". | Perm |
| PESCAT | Subcategory for Examination | Char | * | Grouping Qualifier | Used to define a further categorization of --CAT values. | Perm |
| PEBODSYS | Body System or Organ Class | Char |  | Record Qualifier | Body system or organ class (e.g., MedDRA SOC) that is involved for a finding from the standard hierarchy for dictionary-coded results. | Perm |

### PE Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PEORRES | Verbatim Examination Finding | Char |  | Result Qualifier | Text description of any abnormal findings. If the examination was completed and there were no abnormal findings, the value should be "NORMAL". If the examination was not performed on a particular body system, or at the subject level, then the value should be null, and "NOT DONE" should appear in PESTAT. | Exp |
| PEORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for PEORRES. | Perm |
| PESTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | If there are findings for a body system, then either the dictionary preferred term (if findings are coded using a dictionary) or PEORRES (if findings are not encoded) should appear here. If PEORRES is null, PESTRESC must be null. | Exp |

### PE Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PESTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate exam not done. Must be null if a result exists in PEORRES/PESTRESC. | Perm |
| PEREASND | Reason Not Examined | Char |  | Record Qualifier | Describes why an examination was not performed or why a body system was not examined. Example: "SUBJECT REFUSED". Used in conjunction with PESTAT when value is "NOT DONE". | Perm |
| PELOC | Location of Physical Exam Finding | Char | (LOC) | Record Qualifier | Anatomical location of the subject relevant to the collection of the measurement. Example: "ARM" for skin rash. | Perm |
| PELAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterallity. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| PEMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of the test or examination. Examples: "PALPATION", "PERCUSSION". | Perm |

### PE Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| PELOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. Should be "Y" or null. | Perm |
| PEBLFL | Baseline Flag | Char | (NY) | Record Qualifier | A baseline defined by the sponsor (could be derived in the same manner as PELOBXFL or ABLFL, but is not required to be). The value should be "Y" or null. Note that PEBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| PEEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Example: "INVESTIGATOR". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |

### PE Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the observation date/time of the physical exam finding. | Perm |
| PEDTC | Date/Time of Examination | Char | ISO 8601 datetime or interval | Timing | Date and time of the physical examination represented in ISO 8601 character format. | Exp |
| PEDY | Study Day of Examination | Num |  | Timing | Study day of physical exam, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### PE Assumptions

1. PE findings reflect the presence or absence of physical signs of disease or abnormality observed during a general physical examination. Multiple body

systems are assessed during a physical examination, often starting at the head and ending at the toes, where the body is evaluated by inspection, palpation (feeling with the hands), percussion (tapping with fingers), and auscultation (listening). The examination often includes macro assessments (e.g., normal/abnormal) of appearance, general health, behavior, and body system review from head to toe.

a. Evaluation of targeted body systems (e.g., cardiovascular, ophthalmic, reproductive) as part of therapeutic specific assessments should be represented in the appropriate body system domain (e.g., CV, OE, RP, respectively).

b. See CDASHIG Section 8.3.11, PE - Physical Examination (available at https://www.cdisc.org/standards/foundational/cdash/), for additional

collection guidance.

2. Abnormalities observed during a physical examination may be encoded. When collected/reported as a PE finding, the verbatim value is represented in

PEORRES and the encoded value in PESTRESC. When collected/reported as medical history or an adverse event, the verbatim value is represented in MHTERM or AETERM and the encoded value is represented in MHDECOD or AEDECOD, respectively.

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the PE domain, but the following qualifiers would

generally not be used: --XFN, --NAM, --LOINC, --FAST, --TOX, --TOXGR.

## Functional Tests (FT)

*Structure: One record per Functional Test finding per time point per visit per subject, Tabulation.*

A findings domain that contains data for named, stand-alone, task-based evaluations designed to provide an assessment of mobility, dexterity, or cognitive ability.

### FT Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | FT | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| FTSEQ | Sequence Number | Num |  | Identifier | Sequence number to ensure uniqueness of records within a dataset for a subject. May be any valid number. | Req |
| FTGRPID | Group ID | Char |  | Identifier | Optional group identifier, used to link together a block of related records within a subject in a domain. | Perm |
| FTREFID | Reference ID | Char |  | Identifier | Optional internal or external identifier. | Perm |
| FTSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on the Test page. | Perm |

### FT Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTTESTCD | Short Name of Test | Char | * | Topic | Short character value for FTTEST, which can be used as a column name when converting a dataset from a vertical format to a horizontal format. The value cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). FTTESTCD cannot contain characters other than letters, numbers, or underscores. Controlled terminology for FTTESTCD is published in separate codelists for each instrument. See https://www.cdisc.org/standards/terminology/controlled-terminology for values for FTTESTCD. Examples: "W250101", "W25F0102". | Req |
| FTTEST | Name of Test | Char | * | Synonym Qualifier | Verbatim name of the question used to obtain the finding. The value in FTTEST cannot be longer than 40 characters. Controlled terminology for FTTEST is published in separate codelists for each instrument. See https://www.cdisc.org/standards/terminology/controlled-terminology for values for FTTEST. Examples: "W2501-25 Foot Walk Time", "W25F-More Than Two Attempts". | Req |

### FT Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTCAT | Category | Char | (FTCAT) | Grouping Qualifier | Used to specify the functional test in which the functional test question identified by FTTEST and FTTESTCD was included. | Req |
| FTSCAT | Subcategory | Char |  | Grouping Qualifier | Used to define a further categorization of FTCAT values. | Perm |
| FTPOS | Position of Subject During Observation | Char | (POSITION) | Record Qualifier | Position of the subject during the test. Examples: "SUPINE", "STANDING", "SITTING". | Perm |
| FTORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the measurement or finding as originally received or collected. | Exp |
| FTORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. Unit for FTORRES. | Perm |

### FT Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTSTRESC | Result or Finding in Standard Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from FTORRES in a standard format or in standard units. FTSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in FTSTRESN. | Exp |
| FTSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from FTSTRESC. FTSTRESN should store all numeric test results or findings. | Perm |
| FTSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for FTSTRESC and FTSTRESN. | Perm |
| FTSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a test was not done, or a test was attempted but did not generate a result. Should be null or have a value of "NOT DONE". | Perm |

### FT Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a test was not done, or a test was attempted but did not generate a result. Used in conjunction with FTSTAT when value is "NOT DONE". | Perm |
| FTXFN | External File Path | Char |  | Record Qualifier | File path to an external file. | Perm |
| FTNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the vendor or laboratory that provided the test results. | Perm |
| FTMETHOD | Method of Test or Examination | Char | (QRSMTHOD) | Record Qualifier | Method of the test or examination. | Perm |
| FTLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Exp |

### FT Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTBLFL | Baseline Flag | Char | (NY) | Record Qualifier | A baseline defined by the sponsor (could be derived in the same manner as FTLOBXFL or ABLFL, but is not required to be). The value should be "Y" or null. Note that FTBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| FTDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |
| FTREPNUM | Repetition Number | Num |  | Record Qualifier | The incidence number of a test that is repeated within a given timeframe for the same test. The level of granularity can vary (e.g., within a time point, within a visit). Examples: multiple measurements of blood pressure, multiple analyses of a sample. | Perm |

### FT Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of VISIT based upon RFSTDTC in Demographics. Should be an integer. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the observation date/time of the functional tests finding. | Perm |
| FTDTC | Date/Time of Test | Char | ISO 8601 datetime or interval | Timing | Collection date and time of functional test. | Exp |
| FTDY | Study Day of Test | Num |  | Timing | Actual study day of test expressed in integer days relative to the sponsor-defined RFSTDTC in Demographics. | Perm |

### FT Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken, as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See FTTPTNUM and FTTPTREF. | Perm |
| FTTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |
| FTELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time relative to a planned fixed reference (FTTPTREF). Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| FTTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by FTELTM, FTTPTNUM, and FTTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |

### FT Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FTRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by FTTPTREF. | Perm |

### FT Assumptions

The following assumptions are unique to the FT domain:

1. A functional test is not a subjective assessment of how the subject generally performs a task, but rather an objective measurement of the performance of

the task by the subject in a specific instance.

2. Functional tests have documented methods for administration and analysis and require a subject to perform specific activities that are evaluated and

recorded. Most often, functional tests are direct quantitative measurements. Examples of functional tests include the Timed 25-Foot Walk, 9-Hole Peg Test, and the Hauser Ambulation Index.

QRS Shared Assumptions

The following assumptions are common to the FT and QS domains as well as the Clinical Classifications use case of the RS domain (not the Disease Response use case of RS):

1. The name of a QRS instrument is described under the variable --CAT in the relevant QRS domain (i.e., FT, QS, RS), and may be either abbreviations or

longer names. For example, "ADAS-COG", "BPI SHORT FORM", and "APACHE II" are all --CATs which are shortened names for the instruments they represent, whereas "4 STAIR ASCEND" is the FTCAT for the instrument of the same name. Sponsors should always reference CDISC Controlled Terminology.

a. The QRS Naming Rules for --CAT, --TEST, and --TESTCD and the list of QRS instruments that have published CDISC Controlled Terminology with NCI/EVS are available at: https://www.cdisc.org/standards/terminology/controlled-terminology.

b. Refer to the following CDISC Controlled Terminology codelists for QRS instrument --CAT terminology:

i. Category of Clinical Classification

ii. Category of Functional Test

iii. Category of Questionnaire

c. QRS --TESTCD/--TEST terminology codelists are listed separately by instrument name.

2. Names of subcategories for groups of items/questions are described under the --SCAT variable.

a. --SCAT values are not included in the CDISC Controlled Terminology system but rather controlled as described in the QRS supplements in which they are used.

3. There are cases where QRS CRFs do not include numeric “standardized responses” assigned to text responses (e.g., mild, moderate, severe being 1, 2,

3). It is clearly in everyone's best interest to include the numeric “standardized responses” in the SDTMIG QRS dataset. This is only done when the numeric “standardized responses” are documented in the QRS CRF instructions, a user manual, a website specific to the QRS instrument, or another reference document that provides a clear explanation and rationale for providing them in the SDTMIG QRS dataset.

4. Sponsors should always consult published QRS supplements for guidance on submitting derived information in a SDTMIG QRS domain. Derived

variable results in QRS are usually considered captured data. If sponsors operationally derive variable results, then the derived records that are submitted in a QRS domain should be flagged by --DRVFL.

a. The following rules apply for “total”-type scores in QRS datasets.

ii. QRS subtotal, total, etc. scores not listed on the CRF but documented in an associated instrument manual or reference paper are considered

captured data and are included in the instrument’s controlled terminology.

iii. QRS subtotal, total, etc. scores not listed on the CRF, but known to be included in eData by sponsors are considered as captured data, are

included in the instrument’s controlled terminology. The QRS instrument’s CT is considered extensible for this case and the subtotal or total score should be requested to be added.

1. Any imputations/calculations done to numeric “standardized responses” to produce the total score via transforming numeric “standardized

responses” in any way would be done as ADaM derivations.

b. The QRS instrument subtotal or total score, which is the sum of the numeric responses for an instrument, is populated in --ORRES, --STRESC, and

--STRESN. It is considered a captured subtotal or total score without any knowledge of the sponsor-data management processes related to the score.

i. If operationally derived by the sponsor, it is the sponsor's responsibility to set the --DRVFL flag based on their eCRF process to derive subtotal

and total scores. An investigator-derived score written on a CRF will be considered a captured score and not flagged. When subtotal and total scores are derived by the sponsor, the derived flag (--DRVFL) is set to "Y". However, when the subtotal and total scores are received from a central provider or vendor, the value would go into --ORRES and --DRVFL would be null (see Section 4.1.8.1, Origin Metadata for Variables).

5. The variable --REPNUM variable is populated when there are multiple repeats of the same question. When records are related to the first trial of the

question, the variable --REPNUM should be set to "1". When records are related to the second trial of the same question, --REPNUM should be set to "2", and so forth.

6. The actual version number of an instrument is represented in the --CAT value as designated by the QRS Terminology Team. If it is determined that this

is not the case for an instrument:

a. Notify the QRS Terminology Team that the instrument has a specific or multiple version numbers. This team will assist in providing an resolution on how the situation will be handled.

b. Consider the use of the --GRPID variable to indicate the instrument's version number prior to a decision by the QRS Terminology Team.

c. The sponsor is expected to provide information about the version used for each QRS instrument in the metadata (using the Comments column in the Define-XML document). This could be provided as value-level metadata for --CAT.

d. The sponsor is expected to provide information about the scoring rules in the metadata.

7. If the variable --TEST is represented with verbatim text >40 characters, represent the abbreviated meaningful text in --TEST within 40 characters and

describe the full text of the item in the study metadata. If the verbatim item response (e.g., --QSORRES) is >200 characters, represent the abbreviated meaningful text in QSORRES within the 200 characters and describe the full text in the study metadata; see Section 4 of the QRS supplement. See Section 4.5.3, Text Strings that Exceed the Maximum Length for General Observation-class Domain Variables, for further information.

a. The instrument’s annotated CRF can also be used as a reference for the full text in both of these situations.

8. --EVAL and --EVALID must not be used to model QRS data in SDTM. These variables have had various interpretations on QRS CRFs and were used

to represent a multitude of evaluator information about QRS instruments. This has made it more difficult for users of SDTM QRS data to interpret this

## Questionnaires (QS)

*Structure: One record per questionnaire per question per time point per visit per subject, Tabulation.*

A findings domain that contains data for named, stand-alone instruments designed to provide an assessment of a concept. Questionnaires have a defined standard structure, format, and content; consist of conceptually related items that are typically scored; and have documented methods for administration and analysis.

### QS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | QS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| QSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| QSGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| QSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Question number on a questionnaire. | Perm |

### QS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSTESTCD | Question Short Name | Char | * | Topic | Topic variable for QS. Short name for the value in QSTEST, which can be used as a column name when converting the dataset from a vertical format to a horizontal format. The value in QSTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). QSTESTCD cannot contain characters other than letters, numbers, or underscores. Controlled terminology for QSTESTCD is published in separate codelists for each questionnaire. See https://www.cdisc.org/standards/semantics/terminology for values for QSTESTCD. Examples: "ADCCMD01", "BPR0103". | Req |
| QSTEST | Question Name | Char | * | Synonym Qualifier | Verbatim name of the question or group of questions used to obtain the measurement or finding. The value in QSTEST cannot be longer than 40 characters. Controlled terminology for QSTEST is published in separate codelists for each questionnaire. See https://www.cdisc.org/standards/semantics/terminology for values for QSTEST. Example: "BPR01 - Emotional Withdrawal". | Req |

### QS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSCAT | Category of Question | Char | (QSCAT) | Grouping Qualifier | Used to specify the questionnaire in which the question identified by QSTEST and QSTESTCD was included. Examples: "ADAS-COG", "MDS-UPDRS". | Req |
| QSSCAT | Subcategory for Question | Char | * | Grouping Qualifier | A further categorization of the questions within the category. Examples: "MENTAL HEALTH" , "DEPRESSION", "WORD RECALL". | Perm |
| QSORRES | Finding in Original Units | Char |  | Result Qualifier | Finding as originally received or collected (e.g., "RARELY", "SOMETIMES"). When sponsors apply codelist to indicate that code values are statistically meaningful standardized scores (which are defined by sponsors or by valid methodologies, e.g., SF36 questionnaires), QSORRES will contain the decode format; QSSTRESC and QSSTRESN may contain the standardized code values or scores. | Exp |
| QSORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for QSORRES, such as minutes or seconds or the units associated with a visual analog scale. | Perm |

### QS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the finding for all questions or subscores copied or derived from QSORRES, in a standard format or standard units. QSSTRESC should store all findings in character format; if findings are numeric, they should also be stored in numeric format in QSSTRESN. If question scores are derived from the original finding, then the standard format is the score. Examples: "0", "1". When sponsors apply codelist to indicate the code values are statistically meaningful standardized scores (which are defined by sponsors or by valid methodologies, e.g., SF36 questionnaires), QSORRES will contain the decode format; QSSTRESC and QSSTRESN may contain the standardized code values or scores. | Exp |
| QSSTRESN | Numeric Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric findings in standard format; copied in numeric format from QSSTRESC. QSSTRESN should store all numeric results or findings. | Perm |

### QS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for QSSTRESC or QSSTRESN. | Perm |
| QSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a question was not done or was not answered. Should be null if a result exists in QSORRES. | Perm |
| QSREASND | Reason Not Performed | Char |  | Record Qualifier | Describes why a question was not answered. Used in conjunction with QSSTAT when value is "NOT DONE". Example: "SUBJECT REFUSED". | Perm |
| QSMETHOD | Method of Test or Examination | Char | (QRSMTHOD) | Record Qualifier | Method of the test or examination. | Perm |
| QSLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. Should be "Y" or null. | Exp |

### QS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that QSBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| QSDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records or questionnaire subscores that do not come from the CRF are examples of records that would be derived for the submission datasets. If QSDRVFL = "Y", then QSORRES may be null with QSSTRESC and (if numeric) QSSTRESN having the derived value. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |

### QS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the observation date/time of the physical exam finding. | Perm |
| QSDTC | Date/Time of Finding | Char | ISO 8601 datetime or interval | Timing | Date of questionnaire. | Exp |
| QSDY | Study Day of Finding | Num |  | Timing | Study day of finding collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### QS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSTPT | Planned Time Point Name | Char |  | Timing | Text description of time when questionnaire should be administered. This may be represented as an elapsed time relative to a fixed reference point (e.g., "TIME OF LAST DOSE"). See QSTPTNUM and QSTPTREF. | Perm |
| QSTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of QSTPT to aid in sorting. | Perm |
| QSELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (QSTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date time variable. Represented as an ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by QSTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by QSTPTREF. | Perm |

### QS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| QSTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by QSELTM, QSTPTNUM, and QSTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| QSRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, QSTPTREF. | Perm |
| QSEVLINT | Evaluation Interval | Char | ISO 8601 duration or interval | Timing | Evaluation interval associated with a QSTEST question represented in ISO 8601 character format. Example: "- P2Y" to represent an interval of 2 years in the question "Have you experienced any episodes in the past 2 years?". | Perm |
| QSEVINTX | Evaluation Interval Text | Char |  | Timing | Evaluation interval associated with an observation, where the interval is not able to be represented in ISO 8601 format. Examples: "LIFETIME", "LAST NIGHT", "RECENTLY", "OVER THE LAST FEW WEEKS". | Perm |

### QS Assumptions

There are no additional QS-specific assumptions; all are included in the QRS Shared Assumptions.

QRS Shared Assumptions

The following assumptions are common to the FT and QS domains as well as the Clinical Classifications use case of the RS domain (not the Disease Response use case of RS):

1. The name of a QRS instrument is described under the variable --CAT in the relevant QRS domain (i.e., FT, QS, RS), and may be either abbreviations or

longer names. For example, "ADAS-COG", "BPI SHORT FORM", and "APACHE II" are all --CATs which are shortened names for the instruments they represent, whereas "4 STAIR ASCEND" is the FTCAT for the instrument of the same name. Sponsors should always reference CDISC Controlled Terminology.

a. The QRS Naming Rules for --CAT, --TEST, and --TESTCD and the list of QRS instruments that have published CDISC Controlled Terminology with NCI/EVS are available at: https://www.cdisc.org/standards/terminology/controlled-terminology.

b. Refer to the following CDISC Controlled Terminology codelists for QRS instrument --CAT terminology:

i. Category of Clinical Classification

ii. Category of Functional Test

iii. Category of Questionnaire

c. QRS --TESTCD/--TEST terminology codelists are listed separately by instrument name.

2. Names of subcategories for groups of items/questions are described under the --SCAT variable.

a. --SCAT values are not included in the CDISC Controlled Terminology system but rather controlled as described in the QRS supplements in which they are used.

3. There are cases where QRS CRFs do not include numeric “standardized responses” assigned to text responses (e.g., mild, moderate, severe being 1, 2,

3). It is clearly in everyone's best interest to include the numeric “standardized responses” in the SDTMIG QRS dataset. This is only done when the numeric “standardized responses” are documented in the QRS CRF instructions, a user manual, a website specific to the QRS instrument, or another reference document that provides a clear explanation and rationale for providing them in the SDTMIG QRS dataset.

variable results in QRS are usually considered captured data. If sponsors operationally derive variable results, then the derived records that are submitted in a QRS domain should be flagged by --DRVFL.

a. The following rules apply for “total”-type scores in QRS datasets.

i. QRS subtotal, total, etc. scores listed on the CRF are considered captured data and are included in the instrument’s controlled terminology.

ii. QRS subtotal, total, etc. scores not listed on the CRF but documented in an associated instrument manual or reference paper are considered

captured data and are included in the instrument’s controlled terminology.

iii. QRS subtotal, total, etc. scores not listed on the CRF, but known to be included in eData by sponsors are considered as captured data, are

included in the instrument’s controlled terminology. The QRS instrument’s CT is considered extensible for this case and the subtotal or total score should be requested to be added.

1. Any imputations/calculations done to numeric “standardized responses” to produce the total score via transforming numeric “standardized

responses” in any way would be done as ADaM derivations.

b. The QRS instrument subtotal or total score, which is the sum of the numeric responses for an instrument, is populated in --ORRES, --STRESC, and

--STRESN. It is considered a captured subtotal or total score without any knowledge of the sponsor-data management processes related to the score.

i. If operationally derived by the sponsor, it is the sponsor's responsibility to set the --DRVFL flag based on their eCRF process to derive subtotal

and total scores. An investigator-derived score written on a CRF will be considered a captured score and not flagged. When subtotal and total scores are derived by the sponsor, the derived flag (--DRVFL) is set to "Y". However, when the subtotal and total scores are received from a central provider or vendor, the value would go into --ORRES and --DRVFL would be null (see Section 4.1.8.1, Origin Metadata for Variables).

5. The variable --REPNUM variable is populated when there are multiple repeats of the same question. When records are related to the first trial of the

question, the variable --REPNUM should be set to "1". When records are related to the second trial of the same question, --REPNUM should be set to "2", and so forth.

6. The actual version number of an instrument is represented in the --CAT value as designated by the QRS Terminology Team. If it is determined that this

is not the case for an instrument:

a. Notify the QRS Terminology Team that the instrument has a specific or multiple version numbers. This team will assist in providing an resolution on how the situation will be handled.

b. Consider the use of the --GRPID variable to indicate the instrument's version number prior to a decision by the QRS Terminology Team.

c. The sponsor is expected to provide information about the version used for each QRS instrument in the metadata (using the Comments column in the Define-XML document). This could be provided as value-level metadata for --CAT.

d. The sponsor is expected to provide information about the scoring rules in the metadata.

7. If the variable --TEST is represented with verbatim text >40 characters, represent the abbreviated meaningful text in --TEST within 40 characters and

describe the full text of the item in the study metadata. If the verbatim item response (e.g., --QSORRES) is >200 characters, represent the abbreviated meaningful text in QSORRES within the 200 characters and describe the full text in the study metadata; see Section 4 of the QRS supplement. See Section 4.5.3, Text Strings that Exceed the Maximum Length for General Observation-class Domain Variables, for further information.

## Disease Response and Clin Classification (RS)

*Structure: One record per response assessment or clinical classification.*

A findings domain for the assessment of disease response to therapy, or clinical classification based on published criteria.

Data in this domain may or may not be collected by means of a standard CRF.

• Clinical classification instruments usually have a standard CRF for data capture, but also may instead be based on an evaluator providing response evaluations based on published criteria.

• Oncology response criteria are evaluated based on published criteria.

• Additional disease classifications or scoring systems (e.g., staging criteria) are based on published criteria.

• There are separate supplements prepared for clinical classification instruments and therapeutic-area disease response criteria use cases.

### RS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | RS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| RSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness within a dataset for a subject. May be any valid number. | Req |
| RSGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. | Perm |
| RSREFID | Reference ID | Char |  | Identifier | Internal or external identifier. | Perm |
| RSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| RSLNKID | Link ID | Char |  | Identifier | An identifier used to link the response assessment to the related measurement record in another domain which was used to determine the response result. LNKID values group records within USUBJID. | Perm |

### RS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSLNKGRP | Link Group ID | Char |  | Identifier | A grouping identifier used to link the response assessment to a group of measurement/assessment records which were used in the assessment of the response. LNKGRP values group records within USUBJID. | Perm |
| RSTESTCD | Assessment Short Name | Char | (ONCRTSCD) | Topic | Short name of the TEST in RSTEST. The value in RSTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). RSTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "TRGRESP", "NTRGRESP", "OVRLRESP", "SYMPTDTR", "CPS0102". There are separate codelists used for RSTESTCD where the choice depends on the value of RSCAT. Codelist "ONCRTSCD" is used for oncology response criteria (when RSCAT is a term in codelist "ONCRSCAT"). Examples: TRGRESP, "NTRGRESP, "OVRLRESP". For Clinical Classifications (when RSCAT is a term in codelist "CCCAT"), QRS Naming Rules apply. These instruments have individual dedicated terminology codelists. | Req |

### RS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSTEST | Assessment Name | Char | (ONCRTS) | Synonym Qualifier | Verbatim name of the response assessment. The value in RSTEST cannot be longer than 40 characters. There are separate codelists used for RSTEST where the choice depends on the value of RSCAT. Codelist "ONCRTS" is used for oncology response criteria (when RSCAT is a term in codelist "ONCRSCAT"). Examples: "Target Response", "Non-target Response", "Overall Response", "Symptomatic Deterioration". For Clinical Classifications (when RSCAT is a term in codelist "CCCAT"), QRS Naming Rules apply. These instruments have individual dedicated terminology codelists. | Req |
| RSCAT | Category for Assessment | Char | (ONCRSCAT)(CCCAT) | Grouping Qualifier | Used to define a category of related records across subjects. Examples: "RECIST 1.1", "CHILD- PUGH CLASSIFICATION". There are separate codelists used for RSCAT where the choice depends on whether the related records are about an oncology response criterion or another clinical classification. RSCAT is required for clinical classifications other than oncology response criteria. | Exp |

### RS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSSCAT | Subcategory | Char |  | Grouping Qualifier | Used to define a further categorization of RSCAT values. | Perm |
| RSORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the response assessment as originally received, collected, or calculated. | Exp |
| RSORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Unit for RSORRES. | Perm |
| RSSTRESC | Character Result/Finding in Std Format | Char | (ONCRSR) | Result Qualifier | Contains the result value for the response assessment, copied, or derived from RSORRES in a standard format or standard units. RSSTRESC should store all results or findings in character format. For Clinical Classifications, this may be a score. | Exp |
| RSSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from -- STRESC. --STRESN should store all numeric test results or findings. For Clinical Classifications, this may be a score. | Perm |

### RS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for RSSTRESC and RSSTRESN. | Perm |
| RSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate the response assessment was not performed. Should be null if a result exists in RSORRES. | Perm |
| RSREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a response assessment was not performed. Examples: "All target tumors not evaluated", "Subject does not have non-target tumors". Used in conjunction with RSSTAT when value is "NOT DONE". | Perm |
| RSNAM | Vendor Name | Char |  | Record Qualifier | The name or identifier of the vendor that performed the response assessment. This column can be left null when the investigator provides the complete set of data in the domain. | Perm |
| RSMETHOD | Method of Test or Examination | Char | (QRSMTHOD) | Record Qualifier | Method of the test or examination. | Perm |

### RS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. When a clinical classification is assessed at multiple times, including baseline, RSLOBXFL should be included in the dataset. | Perm |
| RSBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that --BLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| RSDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record (e.g., a record that represents the average of other records such as a computed baseline). Should be "Y" or null. | Perm |

### RS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR", "RADIOLOGIST". RSEVAL is expected for oncology response criteria. It can be left null when the investigator provides the complete set of data in the domain. However, the column should contain no null values when data from one or more independent assessors is included, meaning that the rows attributed to the investigator should contain a value of "INVESTIGATOR". | Perm |
| RSEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in RSEVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". See assumptions in Section 6.3.9.3.1, Disease Response Use Case. | Perm |

### RS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSACPTFL | Accepted Record Flag | Char | (NY) | Record Qualifier | In cases where more than 1 independent assessor (e.g., "RADIOLOGIST 1", "RADIOLOGIST 2", "ADJUDICATOR") provides an evaluation of response, this flag identifies the record that is considered to be the accepted evaluation. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |

### RS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSDTC | Date/Time of Assessment | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the assessment represented in ISO 8601 character format. | Exp |
| RSDY | Study Day of Assessment | Num |  | Timing | Study day of the assessment, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |
| RSTPT | Planned Time Point Name | Char |  | Timing | Text description of time when a measurement or observation should be taken as defined in the protocol. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See RSTPTNUM and RSTPTREF. | Perm |
| RSTPTNUM | Planned Time Point Number | Num |  | Timing | Numeric version of planned time point used in sorting. | Perm |

### RS Variables (part 10)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time in ISO 8601 character format relative to a planned fixed reference (RSTPTREF; e.g., "PREVIOUS DOSE", "PREVIOUS MEAL"). This variable is useful where there are repetitive measures. Not a clock time or a date/time variable, but an interval, represented as ISO duration. | Perm |
| RSTPTREF | Time Point Reference | Char |  | Timing | Description of the fixed reference point referred to by RSELTM, RSTPTNUM, and RSTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| RSRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time for a fixed reference time point defined by RSTPTREF in ISO 8601 character format. | Perm |

### RS Variables (part 11)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSEVLINT | Evaluation Interval | Char | ISO 8601 duration or interval | Timing | Duration of interval associated with an observation such as a finding RSTESTCD, represented in ISO 8601 character format. Example: "-P2M" to represent a period of the past 2 months as the evaluation interval. | Perm |
| RSEVINTX | Evaluation Interval Text | Char |  | Timing | Evaluation interval associated with an observation, where the interval is not able to be represented in ISO 8601 format. Examples: "LIFETIME", "LAST NIGHT", "RECENTLY", "OVER THE LAST FEW WEEKS". | Perm |
| RSSTRTPT | Start Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the start of the observation as being before or after the sponsor-defined reference time point defined by variable RSSTTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |

### RS Variables (part 12)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| RSSTTPT | Start Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by RSSTRTPT. Examples: "2003-12-15", "VISIT 1". | Perm |
| RSENRTPT | End Relative to Reference Time Point | Char | (STENRF) | Timing | Identifies the end of the observation as being before or after the sponsor-defined reference time point defined by variable RSENTPT. Not all values of the codelist are allowable for this variable. See Section 4.4.7, Use of Relative Timing Variables. | Perm |
| RSENTPT | End Reference Time Point | Char |  | Timing | Description or date/time in ISO 8601 character format of the sponsor-defined reference point referred to by RSENRTPT. Examples: "2003-12-25", "VISIT 2". | Perm |

## Subject Characteristics (SC)

*Structure: One record per characteristic per visit per subject.*

A findings domain that contains subject-related data not collected in other domains.

### SC Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SC | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SCSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| SCGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| SCSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. | Perm |

### SC Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SCTESTCD | Subject Characteristic Short Name | Char | (SCTESTCD) | Topic | Short name of the measurement, test, or examination described in SCTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in SCTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). SCTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "MARISTAT", "NATORIG". | Req |
| SCTEST | Subject Characteristic | Char | (SCTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in SCTEST cannot be longer than 40 characters. Examples: "Marital Status", "National Origin". | Req |
| SCCAT | Category for Subject Characteristic | Char | * | Grouping Qualifier | Used to define a category of related records. | Perm |
| SCSCAT | Subcategory for Subject Characteristic | Char | * | Grouping Qualifier | A further categorization of the subject characteristic. | Perm |

### SC Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SCORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the subject characteristic as originally received or collected. | Exp |
| SCORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original unit in which the data were collected. The unit for SCORRES. | Perm |
| SCSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from SCORRES, in a standard format or standard units. SCSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in SCSTRESN. For example, if a test has results "NONE", "NEG", and "NEGATIVE" in SCORRES, and these results effectively have the same meaning, they could be represented in standard format in SCSTRESC as "NEGATIVE". | Exp |

### SC Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SCSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from SCSTRESC. SCSTRESN should store all numeric test results or findings. | Perm |
| SCSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for SCSTRESC or SCSTRESN. | Perm |
| SCSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that the measurement was not done. Should be null if a result exists in SCORRES. | Perm |
| SCREASND | Reason Not Performed | Char |  | Record Qualifier | Describes why the observation has no result. Example: "Subject refused". Used in conjunction with SCSTAT when value is "NOT DONE". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Perm |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |

### SC Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time at which the assessment was made. | Perm |
| SCDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of the subject characteristic represented in ISO 8601 character format. | Perm |
| SCDY | Study Day of Examination | Num |  | Timing | Study day of collection, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### SC Assumptions

1. The structure of subject characteristics is based on the Findings general observation class and is an extension of the demographics data, including

socioeconomic or other broad characteristics. The structure for demographic data is fixed and includes date of birth, age, sex, race, ethnicity, and country. Subject characteristics may be collected periodically over time. Some examples of subject characteristics include education level, marital status, and national origin.

2. Associations between some subject characteristic tests and response codelists are described in the SC Codetable, available

at https://www.cdisc.org/standards/terminology/controlled-terminology.

3. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the SC domain, but the following qualifiers would

generally not be used in SC: --MODIFY, --POS, --BODSYS, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --STNRC, --NRIND, --RESCAT, -- XFN, --NAM, --LOINC, --SPEC, --SPCCND, --BLFL, --LOBXFL, --FAST, --DRVFL, --TOX, --TOXGR, --SEV.

## Subject Status (SS)

*Structure: One record per status per visit per subject, Tabulation.*

A findings domain that contains the subject's status that is evaluated periodically to determine if it has changed.

### SS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID S | tudy Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN D A | omain bbreviation | Char | SS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| SSGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| SSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number from the Procedure or Test page. | Perm |

### SS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SSTESTCD | Status Short Name | Char | (SSTESTCD) | Topic | Short name of the status assessment described in SSTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in SSTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). SSTESTCD cannot contain characters other than letters, numbers, or underscores. Example: "SURVSTAT". | Req |
| SSTEST | Status Name | Char | (SSTEST) | Synonym Qualifier | Verbatim name of the status assessment used to obtain the finding. The value in SSTEST cannot be longer than 40 characters. Example: "Survival Status". | Req |
| SSCAT | Category for Assessment | Char | * | Grouping Qualifier | Used to categorize observations across subjects. | Perm |
| SSSCAT | Subcategory for Assessment | Char | * | Grouping Qualifier | A further categorization. | Perm |
| SSORRES | Result or Finding Original Result | Char |  | Result Qualifier | Result of the status assessment finding as originally received or collected. | Exp |

### SS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SSSTRESC | Character Result/Finding in Std Format | Char | (SSTATRS) | Result Qualifier | Contains the result value for all findings copied or derived from SSORRES, in a standard format. | Exp |
| SSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate a status assessment was not done. Should be null if a result exists in SSORRES. | Perm |
| SSREASND | Reason Assessment Not Performed | Char |  | Record Qualifier | Describes why an assessment was not performed. Example: "Subject refused". Used in conjunction with SSSTAT when value is "NOT DONE". | Perm |
| SSEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Should be null for records that contain collected or derived data. Examples: "CAREGIVER", "ADJUDICATION COMMITTEE", "FRIEND". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |

### SS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time of the subject status assessment. | Perm |
| SSDTC | Date/Time of Assessment | Char | ISO 8601 datetime or interval | Timing | Date and time of the subject status assessment represented in ISO 8601 character format. | Exp |
| SSDY | Study Day of Assessment | Num |  | Timing | Study day of the subject status assessment, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### SS Assumptions

1. Details about the circumstances of a subject's status are stored in the appropriate separate domain(s), even when collection is triggered by the response

to the status assessment. For example, if a subject's survival status is "DEAD", the date of death must be stored in DM and within a final disposition record in DS. Only the status collection date, the status question, and the status response are stored in SS.

## Tumor/Lesion Identification (TU)

*Structure: One record per identified tumor per subject per assessor, Tabulation.*

A findings domain that represents data that uniquely identifies tumors, lesions, or locations of interest under study.

The TU domain represents data that uniquely identifies tumors, lesions, or locations of interest (e.g., tumors, cardiovascular culprit lesions, organs, bone marrow, other sites of disease such as lymph nodes). Commonly, tumors/lesions/locations of interest are identified by an investigator and/or independent assessor and classified according to the disease assessment criteria. For example, an oncology study using RECIST criteria would identify target, non-target, and new tumors. A record in the TU domain contains the following information:

• a unique tumor ID value

• anatomical location of the tumor

• method used to identify the tumor

• role of the individual identifying the tumor

• timing information.

### TU Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | TU | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| TUSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness within a dataset for a subject. May be any valid number. | Req |
| TUGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. Can be used to group split or merged tumors/lesions which have been identified. | Perm |
| TUREFID | Reference ID | Char |  | Identifier | Internal or external identifier (e.g., medical image ID number). | Perm |
| TUSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |

### TU Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TULNKID | Link ID | Char |  | Identifier | Identifier used to link identified tumor/lesion/location of interest to the assessment results (in TR domain) over the course of the study. | Exp |
| TULNKGRP | Link Group ID | Char |  | Identifier | Identifier used to link related records across domains. This will usually be a many-to-one relationship. | Perm |
| TUTESTCD | Tumor/Lesion ID Short Name | Char | (TUTESTCD) | Topic | Short name of the TEST in TUTEST. TUTESTCD cannot be longer than 8 characters nor can start with a number. TUTESTCD cannot contain characters other than letters, numbers, or underscores. Example: "TUMIDENT". See assumption 3. | Req |
| TUTEST | Tumor/Lesion ID Test Name | Char | (TUTEST) | Synonym Qualifier | Verbatim name of the test for the tumor/lesion identification. The value in TUTEST cannot be longer than 40 characters. Example: "Tumor identification". See assumption 3. | Req |

### TU Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TUORRES | Tumor/Lesion ID Result | Char |  | Result Qualifier | Result of the tumor/lesion identification. The result of tumor/lesion identification is a classification of the identified tumor/lesion. Example: When TUTESTCD = "TUMIDENT", values of TUORRES might be "TARGET", "NON-TARGET", "NEW", or "BENIGN ABNORMALITY". | Exp |
| TUSTRESC | Tumor/Lesion ID Result Std. Format | Char | (TUIDRS) | Result Qualifier | Contains the result value for all findings copied or derived from TUORRES in a standard format. | Exp |
| TUNAM | Laboratory/Vendor Name | Char |  | Record Qualifier | The name or identifier of the vendor that performed the tumor/lesion Identification. This column can be left null when the investigator provides the complete set of data in the domain. | Perm |

### TU Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TULOC | Location of the Tumor/Lesion | Char | (LOC) | Record Qualifier | Used to specify the anatomical location of the identified tumor/lesion (e.g., "LIVER"). Note: When anatomical location is broken down and collected as distinct pieces of data that when combined provide the overall location information (e.g., laterality/directionality/distribution), then additional anatomical location qualifiers should be used. See assumption 3. | Exp |
| TULAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality (e.g., "LEFT", "RIGHT", "BILATERAL"). | Perm |
| TUDIR | Directionality | Char | (DIR) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing directionality (e.g., "UPPER", "INTERIOR"). | Perm |
| TUPORTOT | Portion or Totality | Char | (PORTOT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing the distribution, which means arrangement of, or apportioning of. Examples: "ENTIRE", "SINGLE", "SEGMENT", "MULTIPLE". | Perm |
| TUMETHOD | Method of Identification | Char | (METHOD) | Record Qualifier | Method used to identify the tumor/lesion. Examples: "MRI", "CT SCAN". | Exp |

### TU Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TULOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. Should be "Y" or null. | Exp |
| TUBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that TUBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| TUEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR". This column can be left null when the investigator provides the complete set of data in the domain. However, the column should contain no null values when data from 1 or more independent assessors is included. For example, the rows attributed to the investigator should contain a value of "INVESTIGATOR". | Exp |

### TU Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TUEVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in --EVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". See assumption 9. | Perm |
| TUACPTFL | Accepted Record Flag | Char | (NY) | Record Qualifier | In cases where more than 1 independent assessor (e.g., "RADIOLOGIST 1", "RADIOLOGIST 2", "ADJUDICATION COMMITTEE") provide independent assessments at the same time point, this flag identifies the record that is considered to be the accepted assessment. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. Should be an integer. | Perm |

### TU Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm for the element in which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| TUDTC | Date/Time of Tumor/Lesion Identification | Char | ISO 8601 datetime or interval | Timing | TUDTC variable represents the date of the scan/image/physical exam. TUDTC does not represent the date that the image was read to identify tumors. TUDTC also does not represent the VISIT date. | Exp |
| TUDY | Study Day of Tumor/Lesion Identification | Num |  | Timing | Study day of the scan/image/physical exam, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### TU Assumptions

1. The TU domain should contain only 1 record for each unique tumor/lesion/location of interest identified by an assessor (e.g., investigator, independent

assessor) per medical evaluator. The initial identification of a tumor/lesion/location of interest is done once, usually at baseline (e.g., identification of target and non-target tumors/lesions) or first appearance of new tumor/lesion. The identification information, including the location description, must not be repeated for every visit. A record is required in TU to identify and create the TULNKID when there are associated records in TR with matching TRLNKID. The following are examples of when post-baseline records might be included in the TU domain:

a. A new tumor/lesion may emerge at any time during a study; therefore, a new post-baseline record would represent the identification of the new tumor/lesion.

b. If a tumor/lesion identified at baseline subsequently splits into separate distinct tumors/lesions, then additional post-baseline records can be

included to distinctly identify the split tumors/lesions.

2. TRLNKID is used to relate an identification record in the TU domain to assessment records in the

Tumor/Lesion Results (TR) domain. The organization of data across the TU and TR domains requires a linking mechanism. The TULNKID variable is used to provide a unique code for each identified tumor/lesion. The values of TULNKID are compound values that may carry the following information: an indication of the role (or assessor) providing the data record, when it is someone other than the principal investigator; an indication of whether the data record is for a target or non-target tumor/lesion; a tracking identifier or number; and an indication of whether the tumor/lesion has split (see assumption 3 for details on splitting). A RELREC relationship record can be created to describe the link, probably as a dataset-todataset link.

TUTESTCD/TUTEST values for this domain are published as Controlled Terminology. For some TUTESTCD/TUTEST values, CDISC CT includes codelists for use with TUORRES. The associations between the test values and results are in the Oncology codetable, which, along with the CT Rules for Oncology, is available at https://www.cdisc.org/standards/terminology/controlled-terminology. During the course of a trial, a tumor/lesion might split into one or more distinct tumors/lesions, or 2 or more tumors/lesions might merge to form a single tumor/lesion. The following example shows the preferred approach for representing split lesions in TU. However, the approach depends on how the data for split and merged tumors/lesions are captured. The preferred approach requires the measurements of each distinct tumor/lesion to be captured individually.

Example target tumor T04, identified at the screening visit, splits into 2 at week 16. Two new records are created with TUTEST = "Tumor Split”; TULNKID reflects the split by adding 0.1 and 0.2 to the original TULNKID value.

TULNKID TUTESTCD TUTEST TUORRES VISIT T01 TUMIDENT Tumor Identification TARGET SCREEN T02 TUMIDENT Tumor Identification TARGET SCREEN T03 TUMIDENT Tumor Identification TARGET SCREEN T04 TUMIDENT Tumor Identification TARGET SCREEN NT01 TUMIDENT Tumor Identification NON-TARGET SCREEN NT02 TUMIDENT Tumor Identification NON-TARGET SCREEN T04.1 TUSPLIT Tumor Split TARGET WEEK 16 T04.2 TUSPLIT Tumor Split TARGET WEEK 16 NEW01 TUMIDENT Tumor Identification NEW WEEK 32

If the data collection does not support this approach (i.e., measurements of split tumors/lesions are reported as a summary under the "parent" tumor/lesion), then it may not be possible to include a record in the TU domain. In this situation, the assessments of split and merge tumors/lesions would be represented only in the TR domain.

3. For some response criteria (e.g., Lugano, Kumar IMWG 2016), tumors are assessed by location of interest.

A record is required in TU in order to link the assessments of the particular location of interest in TR.

This example represents tumors assessed by location of interest. In TULNKID = "L01", the spleen is identified as a location of interest using computerized tomography (CT) scan. In TULNKID = "L04", the whole body is identified as a location of interest using positron emission tomography (PET) scan.

TULNKID TUTESTCD TUTEST TUORRES TULOC TUMETHOD L01 TUMIDENT Tumor Identification LOCATION OF INTEREST

SPLEEN CT SCAN

L02 TUMIDENT Tumor Identification LOCATION OF INTEREST

LIVER CT SCAN

L03 TUMIDENT Tumor Identification LOCATION OF INTEREST

BONE MARROW PET SCAN

L04 TUMIDENT Tumor Identification LOCATION OF INTEREST

BODY PET SCAN

4. During the course of a trial, when a new tumor/lesion is identified, information about that new tumor/lesion

may be collected to different levels of detail. For example, if anatomical location of a new tumor/lesion is not collected, TULOC will be blank. All new tumors/lesions are to be represented in TU and TR domains.

extra variables allow for more detailed information to be collected that further clarifies the value of the TULOC variable.

6. In the oncology setting, when a new tumor is identified, a record must be included in both the TU and TR

domains. At a minimum, the TR record would contain TRLNKID = "NEW0" and TRTESTCD = "TUMSTATE" and TRORRES = "PRESENT" for unequivocal new tumors. The TU record may contain different levels of detail depending upon the data collection methods employed. Although it is possible that a sponsor may have a different chosen method, the following are the most common scenarios:

a. The occurrence of a new tumor/lesion is the sole piece of information that a sponsor collects, because this is a sign of disease progression; no further details are required. In such cases, a record would be created where TUTEST = "Tumor Identification" and TUORRES = "NEW", and the identifier, TULNKID, would be populated in order to link to the associated information in the TR domain.

b. The occurrence of a new tumor/lesion and the anatomical location of that newly identified tumor/lesion

are the only collected pieces of information. In this case, it is expected that a record would be created where TUTEST = “Tumor Identification” and TUORRES = "NEW"; the TULOC variable would be populated with the anatomical location information (the additional location variables may be populated depending on the level of detail collected), and the identifier, TULNKID, would be populated in order to link to the associated information in the TR domain.

c. The sponsor records the occurrence of a new tumor/lesion to the same level of detail as target tumors/lesions. For example, with the occurrence of a new tumor/lesion, its anatomical location and its measurement might be recorded. In this case, it is expected that a record would be created where TUTEST = "Tumor Identification" and TUORRES = "NEW". The TULOC variable would be populated with the anatomical location information (the additional location variables may be populated depending on the level of detail collected) and the identifier, TULNKID, would be populated in order to link to the associated information in the TR domain. In this scenario, measurements/assessments would also be recorded in the TR domain.

7. The acceptance flag variable (TUACPTFL) identifies records that have been determined to be the accepted

assessments/measurements by an independent assessor. This flag would be provided by an independent assessor and when multiple evaluators (e.g., "RADIOLOGIST 1", "RADIOLOGIST 2", "ADJUDICATOR") provide assessments or evaluations at the same time point or an overall evaluation. This flag should not be used by a sponsor for any other purpose. It is not expected that the TUACPTFL flag would be populated by the sponsor; instead, that type of record selection should be handled in the analysis dataset (ADaM).

8. The evaluator-specified variable TUEVALID is used in conjunction with TUEVAL to provide additional

detail regarding who is providing tumor identification information (e.g., TUEVAL = "INDEPENDENT ASSESSOR", TUEVALID = "RADIOLOGIST 1"). The TUEVALID variable is subject to controlled terminology. Note: TUEVAL must also be populated when TUEVALID is populated.

9. If indicator questions for specific types of tumor or lesions are collected (e.g., Does the subject have target

tumors? Does the subject have any non-targets? Did the subject have metastatic disease at screening?), then these TUTESTs will be included in TU. If indicator questions are not collected, do not introduce them into TU.

This example shows indicator TUTESTs for a subject with non-target lesions only.

TULNKID TUTESTCD TUTEST TUORRES TULOC TUMETHOD NTIND Non-Target Indicator Y CT SCAN TIND Target Indicator N CT SCAN NT01 TUMIDENT Tumor Identification NON-TARGET LUNG CT SCAN

This example shows indicator TUTESTs for the identification of the sites of metastatic disease sites at baseline.

TULNKID TUTESTCD TUTEST TUORRES TUSTAT TULOC TUMETHOD VISIT METIND Metastatic Tumor Site Indicator

Y LIVER CT SCAN BASELINE

METIND Metastatic Tumor Site Indicator

N BRAIN MRI BASELINE

METIND Metastatic Tumor Site Indicator

NOT DONE PLEURAL CAVITY

BASELINE

10. Disease recurrence can be represented in the TU domain as an identification for the appearance of new

tumors. The TUTEST Disease Recurrence Relative Location is used identify the region or relative location for the disease recurrence. The image identifier is in TUREFID and may match a PRREFID in the Procedures (PR) domain. The PR domain would contain the scans performed per protocol at each assessment; only when new tumors appear would records be included in TU.

This example shows disease recurrence data in an adjuvant breast cancer study where the subject was initially diagnosed with cancer in the left breast only. This example shows a case where disease recurrence was identified in various locations. TUTEST=Disease Recurrence Relative Location is used to identify the reference location of the recurrence (e.g., LOCAL, REGIONAL, DISTANT, LOCOREGIONAL). A local disease recurrence was identified in the left breast, regional disease recurrence was identified in the ipsilateral internal mammary and the ipsilateral infraclavicular nodes, distant disease recurrence was identified in the liver and colon, and contralateral disease recurrence was identified in the right breast.

TUREFID TULNKID TUTESTCD TUTEST TUORRES TULOC TULAT TUMETHOD IMG-00007 LOC01 DRCRLTLC Disease Recurrence Relative Location

LOCAL BREAST LEFT CT SCAN

IMG-00007 REG01 DRCRLTLC Disease Recurrence Relative Location

REGIONAL INTERNAL MAMMARY LYMPH NODE

CT SCAN

IMG-00007 REG02 DRCRLTLC Disease Recurrence Relative Location

REGIONAL INFRACLAVIC ULAR LYMPH NODE

CT SCAN

IMG-00007 DIS01 DRCRLTLC Disease Recurrence Relative Location

DISTANT LIVER CT SCAN

IMG-00007 DIS02 DRCRLTLC Disease Recurrence Relative Location

DISTANT COLON CT SCAN

IMG-00007 CON01 DRCRLTLC Disease Recurrence Relative Location

CONTRALATE RAL

BREAST RIGHT CT SCAN

11. The following proposed supplemental qualifiers would be used for oncology studies to represent

information regarding previous irradiation of a tumor when that information is captured in association with a specific tumor.

QNAM QLABEL Definition TUPREVIR Previously Irradiated Indication of previous irradiation to a tumor TUPREISP

Irradiated then Subsequent Progression Indication of documented progression subsequent to irradiation

12. When additional data are collected about a procedure used for tumor/lesion identification, the data about

the procedure are stored in the PR domain; the link between the tumor/lesion identification and the procedure should be recorded using RELREC.

13. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the TU

domain, but the following qualifiers would not generally be used: --MODIFY, --POS, --BODSYS, -- ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --STNRC, --NRIND, --XFN, --LOINC, --SPEC, -- SPCCND, --FAST, --TOX, --TOXGR, --SEV.

## Tumor/Lesion Results (TR)

*Structure: One record per tumor measurement/assessment per visit per subject per assessor.*

A findings domain that represents quantitative measurements and/or qualitative assessments of the tumors, lesions, or locations of interest identified in the Tumor/Lesion Identification (TU) domain.

The TR domain represents quantitative measurements and/or qualitative assessments of the tumors, lesions, or locations of interest (e.g., tumors, cardiovascular culprit lesions, organs, bone marrow, other sites of disease such as lymph nodes) identified in the Tumor/Lesion Identification (TU) domain. These measurements or qualitative assessments may be recorded at baseline and then at each subsequent assessment to support response evaluations. A typical record in the TR domain contains the following information:

• a unique tumor/lesion/location of interest ID value

• test and result

• method used

• role of the individual making the assessment

• timing information

Clinically accepted evaluation criteria expect that a tumor/lesion/location of interest identified by the ID is the same tumor/lesion/location of interest at each subsequent assessment. The TR domain does not include anatomical location information on each measurement/assessment record, because this would duplicate information represented in TU. The multi-domain approach to representing oncology assessment data was developed largely to reduce duplication of stored information.

### TR Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | TR | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| TRSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness within a dataset for a subject. May be any valid number. | Req |
| TRGRPID | Group ID | Char |  | Identifier | Used to link together a block of related records within a subject in a domain. | Perm |
| TRREFID | Reference ID | Char |  | Identifier | Internal or external identifier. | Perm |
| TRSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |
| TRLNKID | Link ID | Char |  | Identifier | Identifier used to link the assessment result records to the individual tumor/lesion identification record in TU domain. | Exp |

### TR Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRLNKGRP | Link Group | Char |  | Identifier | Used to group and link all of the measurement/assessment records used in the assessment of the response record in the RS domain. | Perm |
| TRTESTCD | Tumor/Lesion Assessment Short Name | Char | (TRTESTCD) | Topic | Short name of the TEST in TRTEST. TRTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "TUMSTATE", "DIAMETER", "LESSCIND", "LESRVIND". See assumption 3. | Req |
| TRTEST | Tumor/Lesion Assessment Test Name | Char | (TRTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in TRTEST cannot be longer than 40 characters. Examples: "Tumor State", "Diameter", "Volume", "Lesion Success Indicator", "Lesion Revascularization Indicator". See assumption 3. | Req |
| TRORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the tumor/lesion measurement/assessment as originally received or collected. | Exp |

### TR Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for TRORRES. Example: "mm". | Exp |
| TRSTRESC | Character Result/Finding in Std Format | Char | (TRPROPRS) | Result Qualifier | Contains the result value for all findings copied or derived from TRORRES, in a standard format or standard units. TRSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in TRSTRESN. | Exp |
| TRSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from TRSTRESC. TRSTRESN should store all numeric test results or findings. | Exp |
| TRSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for TRSTRESN. | Exp |

### TR Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate a scan/image/physical exam was not performed or a tumor/lesion measurement was not taken. Should be null if a result exists in TRORRES. | Perm |
| TRREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a scan/image/physical exam was not performed or a tumor/lesion measurement was not taken. Examples: "SCAN NOT PERFORMED", "NOT ASSESSABLE: IMAGE OBSCURED TUMOR". Used in conjunction with TRSTAT when value is "NOT DONE". | Perm |
| TRNAM | Laboratory/Vendor Name | Char |  | Record Qualifier | The name or identifier of the vendor that performed the tumor/lesion measurement or assessment. This column can be left null when the investigator provides the complete set of data in the domain. | Perm |
| TRMETHOD | Method Used to Identify the Tumor/Lesion | Char | (METHOD) | Record Qualifier | Method used to measure the tumor/lesion/location of interest. Examples: "MRI", "CT SCAN", "PET SCAN", "Coronary angiography". | Exp |

### TR Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. Should be "Y" or null. | Exp |
| TRBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that TRBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| TREVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Examples: "ADJUDICATION COMMITTEE", "INDEPENDENT ASSESSOR". | Exp |
| TREVALID | Evaluator Identifier | Char | (MEDEVAL) | Variable Qualifier | Used to distinguish multiple evaluators with the same role recorded in TREVAL. Examples: "RADIOLOGIST1", "RADIOLOGIST2". See assumption 6. | Perm |

### TR Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRACPTFL | Accepted Record Flag | Char | (NY) | Record Qualifier | In cases where more than 1 independent assessor (e.g., "RADIOLOGIST 1", "RADIOLOGIST 2", "ADJUDICATION COMMITTEE") provide independent assessments at the same time point, this flag identifies the record that is considered to be the accepted assessment. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of a clinical encounter. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Epoch associated with the date/time at which the assessment was made. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the element in the planned sequence of elements for the arm to which the subject was assigned. | Perm |

### TR Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TRDTC | Date/Time of Tumor/Lesion Measurement | Char | ISO 8601 datetime or interval | Timing | The date of the scan/image/physical exam. TRDTC does not represent the date that the image was read to identify tumors/lesions. TRDTC also does not represent the VISIT date. | Exp |
| TRDY | Study Day of Tumor/Lesion Measurement | Num |  | Timing | Study day of the scan/image/physical exam, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |

### TR Assumptions

1. TRLNKID is used to relate records in the TR domain to an identification record in TU domain. The organization of data across the TU and TR domains

requires a RELREC relationship to link the related data rows. A dataset-to-dataset link would be the most appropriate linking mechanism. Utilizing 1 of the existing ID variables is not possible, because --GRPID, --REFID, and --SPID may be used for other purposes, per the SDTM. The --LNKID variable is used for values that support a RELREC dataset-to-dataset relationship and to provide a unique code for each identified tumor/lesion/location of interest.

2. TRLNKGRP is used to relate records in the TR domain to a response assessment record in the RS domain. The organization of data across the TR and

RS domains requires a RELREC relationship to link the related data rows. A dataset-to-dataset link would be the most appropriate linking mechanism. Utilizing 1 of the existing ID variables is not possible because --GRPID, --REFID, and --SPID may be used for other purposes, per the SDTM. The -- LNKGRP variable is used for values that support a RELREC dataset-to-dataset relationship and to provide a unique code for each response and associated tumor/lesion measurements/assessments.

3. TRTESTCD/TRTEST values for this domain are published as Controlled Terminology. For some TRTESTCD/TRTEST values, CDISC CT includes

codelists for use with TRORRES. The associations between the test values and results are in the Oncology codetable, which, along with the Controlled Terminology Rules for Oncology, is available at https://www.cdisc.org/standards/terminology/controlled-terminology. The sponsor should not derive results for any test (e.g., percent change from nadir in sum of diameter) if the result was not collected. Tests would be included in the domain only if those data points have been collected on a CRF, presented by the CRF collection system, or supplied by an external assessor as part of an electronic data transfer. It is not intended that the sponsor would create derived records to supply those values in the TR domain. Derived records/results (outside the CRF) should be provided in the analysis dataset (ADaM).

4. In order to support data value standardization it is sometimes appropriate to standardize an original result value in TRORRES to a standardized result

value in TRSTRESC and TRSTRESN. For example, in the published RECIST criteria, a standardized value of 5 mm is used in the calculation to determine response when a tumor is “too small to measure." The original or collected value "TOO SMALL TO MEASURE" should be represented in the TRORRES variable and the standardized value should be represented in the TRSTRESC and TRSTRESN variables. The information should be represented on a single row of data showing the standardization between the original result, TRORRES, and the standard results, TRSTRESC/TRSTRESN, as follows:

TRLNKID TRTESTCD TRTEST TRORRES TRORRESU TRSTRESC TRSTRESN TRSTRESU T01 DIAMETER Diameter TOO SMALL TO MEASURE

mm 5 5 mm

Note: This is an exception to SDTMIG general variable rule 4.1.5.1, Original and Standardized Results of Findings and Tests Not Done.

independent assessor. This flag would be provided by an independent assessor and when multiple assessors (e.g., "RADIOLOGIST 1", "RADIOLOGIST 2", "ADJUDICATOR") provide assessments or evaluations at the same time point or an overall evaluation. This flag should not be used by a sponsor for any other purpose. It is not expected that the TRACPTFL flag would be populated by the sponsor; instead, that type of record selection should be handled in the analysis dataset (ADaM).

6. The evaluator-specified variable (TREVALID) is used in conjunction with TREVAL to provide additional detail of who is providing measurements or

assessments (e.g., TREVAL = "INDEPENDENT ASSESSOR", TREVALID = "RADIOLOGIST 1"). The TREVALID variable is subject to controlled terminology. Note: TREVAL must also be populated when TREVALID is populated.

7. When additional data are collected about a procedure (e.g., imaging procedure) from which tumor/lesion results are determined, the data about the

procedure is stored in the PR domain and the link between the tumor/lesion results and the procedure should be recorded using RELREC.

8. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the TR domain, but the following qualifiers would

not generally be used: --POS, --BODSYS, --ORNRLO, --ORNRHI, --STNRLO, --STNRHI, --STNRC, --NRIND, --XFN, --LOINC, --SPEC, -- SPCCND, --FAST, --TOX, --TOXGR, --SEV.

6.3.12.3 Tumor Identification/Tumor Results Examples

Example 1

This is an example of using the TU domain to represent non-cancerous lesions identified in the heart.

Subject 40913 had a peripheral vascular intervention (PVI) procedure on February 1, 2007. A target lesion (L01) was identified in the infrarenal aorta within the aorto-iliac vessel (L01-1). During the same PVI procedure, the subject also had a target graft lesion (L01-G) identified in the left femoro-popliteal graft (L01G1). The lesion location was noted within the graft anastomosis proximal, the type was a synthetic graft composed of Gore-Tex, and the anastomosis was in the left popliteal artery.

Rows 1-2: Show the target lesion located in the infrarenal aorta and within the aorta-iliac vessel.

Row 3: Shows the PVI target limb in which the graft lesion is located identified by the investigator.

Rows 4-5: Show the target graft lesion located in the left femoro-popliteal graft and within the femoro-popliteal vessel.

tu.xpt

Row STUDYID DOMAIN USUBJID TUSEQ TULNKID TUTESTCD TUTEST TUORRES TUSTRESC TULOC TULAT TUMETHOD TUEVAL VISITNUM VISIT TUDTC 1 STUDY01 TU 40913 1 L01 LESIDENT Lesion Identification

TARGET TARGET INFRARENAL AORTA

LEFT ANGIOGRAPHY INVESTIGATOR 1 SCREEN 2007-

02-01 2 STUDY01 TU 40913 2 L01-1 VSLIDENT Vessel Lesion Identification

TARGET TARGET AORTO-ILIAC PERIPHERAL ARTERY

LEFT ANGIOGRAPHY INVESTIGATOR 1 SCREEN 2007-

02-01

3 STUDY01 TU 40913 3 L01-2 LMLIDENT Limb Lesion Identification

TARGET TARGET LEG LEFT ANGIOGRAPHY INVESTIGATOR 1 SCREEN 2007-

02-01 4 STUDY01 TU 40913 4 L01-G GRLIDENT Graft Lesion Identification

TARGET TARGET FEMOROPOPLITEAL PERIPHERAL ARTERY

LEFT ANGIOGRAPHY INVESTIGATOR 1 SCREEN 2007-

02-01

5 STUDY01 TU 40913 5 L01-G1 VSLIDENT Vessel Lesion Identification

TARGET TARGET FEMOROPOPLITEAL PERIPHERAL ARTERY

LEFT ANGIOGRAPHY INVESTIGATOR 1 SCREEN 2007-

02-01

supptu.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL 1 STUDY01 TU 40913 TUSEQ 4 TUPAGLL Peripheral Graft Lesion Location GRAFT ANASTOMOSIS PROXIMAL CRF 2 STUDY01 TU 40913 TUSEQ 4 TUPAGA Peripheral Artery Graft Anastomosis LEFT POPLITEAL ARTERY CRF 3 STUDY01 TU 40913 TUSEQ 4 TUOTHLDS Other Lesion Description LESION IS 5MM FROM THE ORIGIN OF THE GRAFT CRF 4 STUDY01 TU 40913 TUSEQ 4 TUPAGT Peripheral Artery Graft Type SYNTHETIC GRAFT CRF 5 STUDY01 TU 40913 TUSEQ 4 TUPAGSM Peripheral Artery Graft Synthetic Material GORE-TEX CRF

Example 2

This is an example of tumors identified and tracked using RECIST 1.1 criteria.

TU shows the target and non-target tumors identified by an investigator at a screening visit and also shows that the investigator determined at the week 6 visit that 1 of the previously identified tumors had split.

Rows 1-6: Show for subject 44444 the target and non-target tumors identified by the investigator at the screening visit.

Rows 7-8: Show the investigator determined that a tumor (TULNKID = "T04" at screening) had split into 2 separate tumors at the week 6 visit. The 2 distinct pieces of the original tumor were then tracked independently from that point in the study forward.

tu.xpt

Row STUDYID DOMAIN USUBJID TUSEQ TUGRPID TULNKID TUTESTCD TUTEST TUORRES TUSTRESC TULOC TULAT TUMETHOD TUEVAL VISITNUM VISIT TUDTC TUDY 1 ABC TU 44444 1 T01 TUMIDENT Tumor Identification TARGET TARGET LIVER CT SCAN INVESTIGATOR 10 SCREEN -3 2 ABC TU 44444 2 T02 TUMIDENT Tumor Identification TARGET TARGET KIDNEY RIGHT CT SCAN INVESTIGATOR 10 SCREEN -3 3 ABC TU 44444 3 T03 TUMIDENT Tumor Identification TARGET TARGET CERVICAL LYMPH NODE LEFT MRI INVESTIGATOR 10 SCREEN -2 4 ABC TU 44444 4 T04 TUMIDENT Tumor Identification TARGET TARGET SKIN OF THE TRUNK PHOTOGRAPHY INVESTIGATOR 10 SCREEN -1 5 ABC TU 44444 5 NT01 TUMIDENT Tumor Identification NON-TARGET NON-TARGET THYROID GLAND RIGHT CT SCAN INVESTIGATOR 10 SCREEN -3 6 ABC TU 44444 6 NT02 TUMIDENT Tumor Identification NON-TARGET NON-TARGET CEREBELLUM RIGHT MRI INVESTIGATOR 10 SCREEN -2 7 ABC TU 44444 7 T04 T04.1 TUSPLIT Tumor Split TARGET TARGET SKIN OF THE TRUNK PHOTOGRAPHY INVESTIGATOR 40 WEEK 6 48 8 ABC TU 44444 8 T04 T04.2 TUSPLIT Tumor Split TARGET TARGET SKIN OF THE TRUNK PHOTOGRAPHY INVESTIGATOR 40 WEEK 6 48

The supplemental qualifier dataset below shows that "T01", "T02", and "T04" were not previously irradiated and "T03" was previously irradiated with subsequent progression after irradiation.

supptu.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL 1 ABC TU 44444 TULNKID T01 TUPREVIR Previously Irradiated N 2 ABC TU 44444 TULNKID T02 TUPREVIR Previously Irradiated N 3 ABC TU 44444 TULNKID T03 TUPREVIR Previously Irradiated Y 4 ABC TU 44444 TULNKID T03 TUPREISP Irradiated then Subsequent Progression Y 5 ABC TU 44444 TULNKID T04 TUPREVIR Previously Irradiated N

TR shows measurements (i.e., short axis) of lymph nodes as well as measurements of other non-lymph node target tumors (i.e., longest diameter). In this example, when TRTEST = "Tumor State" and TRORRES = "ABSENT", it indicates that the target lymph node lesion was no longer pathological (i.e., diameter reduced below 10mm). The overall assessment of lymph nodes is represented with TRTEST = "Lymph Nodes State". A lymph node state of "NON-PATHOLOGICAL" means that all target lymph node lesions have a short axis less than 10mm. A lymph node state of "PATHOLOGICAL" means that at least 1 target lymph node lesion has a short axis greater than or equal to 10mm.

Rows 1-8: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the screening visit.

Rows 9-21: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the week 6 visit.

Rows 22-27: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the week 12 visit.

Row STUDYID DOMAIN USUBJID TRSEQ TRGRPID TRLNKGRP TRLNKID TRTESTCD TRTEST TRORRES TRORRESU TRSTRESC TRSTRESN TRSTRESU TRSTAT TRREASND TRMETHOD TREVAL VISITNUM VISIT TRDTC TRDY 1 ABC TR 44444 1 TARGET A1 T01 DIAMETER Diameter 17 mm 17 17 mm CT SCAN INVESTIGATOR 10 SCREEN 2010-

01-01

2 ABC TR 44444 2 TARGET A1 T02 DIAMETER Diameter 16 mm 16 16 mm CT SCAN INVESTIGATOR 10 SCREEN 2010-

01-01

3 ABC TR 44444 3 TARGET A1 T03 DIAMETER Diameter 15 mm 15 15 mm MRI INVESTIGATOR 10 SCREEN 2010-

01-02

4 ABC TR 44444 4 TARGET A1 T04 DIAMETER Diameter 14 mm 14 14 mm PHOTOGRAPHY INVESTIGATOR 10 SCREEN 2010-

01-03

5 ABC TR 44444 5 TARGET A1 SUMDIAM Sum of Diameter

62 mm 62 62 mm INVESTIGATOR 10 SCREEN

6 ABC TR 44444 6 TARGET A1 SUMNLNLD Sum

Diameters of Non Lymph Node Tumors

47 mm 47 47 mm INVESTIGATOR 10 SCREEN

7 ABC TR 44444 7 NONTARGET

A1 NT01 TUMSTATE Tumor State PRESENT PRESENT CT SCAN INVESTIGATOR 10 SCREEN 2010-

01-01

8 ABC TR 44444 8 NONTARGET

A1 NT02 TUMSTATE Tumor State PRESENT PRESENT MRI INVESTIGATOR 10 SCREEN 2010-

01-02

9 ABC TR 44444 9 TARGET A2 T01 DIAMETER Diameter 0 mm 0 0 mm CT SCAN INVESTIGATOR 40 WEEK 6 201002-18

10 ABC TR 44444 10 TARGET A2 T02 DIAMETER Diameter TOO SMALL TO MEASURE

mm 5 5 mm CT SCAN INVESTIGATOR 40 WEEK 6 201002-18

11 ABC TR 44444 11 TARGET A2 T03 DIAMETER Diameter 12 mm 12 12 mm MRI INVESTIGATOR 40 WEEK 6 201002-19

13 ABC TR 44444 13 TARGET A2 T04.1 DIAMETER Diameter 6 mm 6 6 mm PHOTOGRAPHY INVESTIGATOR 40 WEEK 6 201002-20

14 ABC TR 44444 14 TARGET A2 T04.2 DIAMETER Diameter 7 mm 7 7 mm PHOTOGRAPHY INVESTIGATOR 40 WEEK 6 201002-20

15 ABC TR 44444 15 TARGET A2 SUMDIAM Sum of Diameter

30 mm 30 30 mm INVESTIGATOR 40 WEEK 6

16 ABC TR 44444 16 TARGET A2 SUMNLNLD Sum

Diameters of Non Lymph Node Tumors

18 mm 18 18 mm INVESTIGATOR 40 WEEK 6

17 ABC TR 44444 17 TARGET A2 LNSTATE Lymph Node State

PATHOLOGICAL PATHOLOGICAL INVESTIGATOR 40 WEEK 6

18 ABC TR 44444 18 TARGET A2 ACNSD Absolute Change Nadir in Sum of Diam

-32 mm -32 -32 mm INVESTIGATOR 40 WEEK 6

19 ABC TR 44444 19 TARGET A2 PCBSD Percent Change From Baseline in Sum of Diameter

-52 % -52 -52 % INVESTIGATOR 40 WEEK 6

20 ABC TR 44444 20 TARGET A2 PCNSD Percent Change Nadir in Sum of Diam

-52 % -52 -52 % INVESTIGATOR 40 WEEK 6

21 ABC TR 44444 21 NONTARGET

A2 NT01 TUMSTATE Tumor State PRESENT PRESENT CT SCAN INVESTIGATOR 40 WEEK 6 201002-18

22 ABC TR 44444 22 NONTARGET

A2 NT02 TUMSTATE Tumor State PRESENT PRESENT MRI INVESTIGATOR 40 WEEK 6 201002-19

23 ABC TR 44444 23 TARGET A3 T01 DIAMETER Diameter 0 mm 0 0 mm CT SCAN INVESTIGATOR 60 WEEK 12

201004-02

24 ABC TR 44444 24 TARGET A3 T02 DIAMETER Diameter 6 mm 6 6 mm CT SCAN INVESTIGATOR 60 WEEK 12

201004-02

25 ABC TR 44444 25 TARGET A3 T03 DIAMETER Diameter NOT DONE

SCAN NOT PERFORMED

MRI INVESTIGATOR 60 WEEK 12

26 ABC TR 44444 26 TARGET A3 T04 DIAMETER Diameter NOT DONE

NOT ASSESSABLE:

PHOTOGRAPHY INVESTIGATOR 60 WEEK 12

Row STUDYID DOMAIN USUBJID TRSEQ TRGRPID TRLNKGRP TRLNKID TRTESTCD TRTEST TRORRES TRORRESU TRSTRESC TRSTRESN TRSTRESU TRSTAT TRREASND TRMETHOD TREVAL VISITNUM VISIT TRDTC TRDY POOR IMAGEQUALITY 27 ABC TR 44444 27 NONTARGET

A3 NT01 TUMSTATE Tumor State CT SCAN INVESTIGATOR 60 WEEK 12

201004-02

28 ABC TR 44444 28 NONTARGET

A3 NT02 TUMSTATE Tumor State NOT DONE

SCAN NOT PERFORMED

MRI INVESTIGATOR 60 WEEK 12

The relationship between the TU and TR datasets is represented in RELREC.

relrec.xpt

Row STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELTYPE RELID 1 ABC TU TULNKID ONE 1 2 ABC TR TRLNKID MANY 1

Example 3

This is an example of tumors identified and tracked following RECIST 1.1 criteria, with an additional opinion provided by an independent assessor.

TU shows the target and non-target tumors identified by a radiologist at a screening visit. It also shows that the radiologist identified 2 new tumors: 1 at the week 6 visit and 1 at the week 12 visit.

Rows 1-5: Show the target and non-target tumors identified at screening by the independent assessor, Radiologist 1.

Row 6: Shows that a new tumor was identified at week 6 by the independent assessor, Radiologist 1.

Row 7: Shows that another new tumor was identified at week 12 by the independent assessor, Radiologist 1.

tu.xpt

Row STUDYID DOMAIN USUBJID TUSEQ TULNKID TUTESTCD TUTEST TUORRES TUSTRESC TULOC TULAT TUMETHOD TUNAM TUEVAL TUEVALID VISITNUM VISIT TUDTC TUDY 1 ABC TU 55555 1 R1-T01 TUMIDENT Tumor

Identification

TARGET TARGET CERVICAL LYMPH NODE

LEFT MRI ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-01-

2 ABC TU 55555 2 R1-T02 TUMIDENT Tumor

Identification

TARGET TARGET LIVER CT SCAN ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-01-

3 ABC TU 55555 3 R1-T03 TUMIDENT Tumor

Identification

TARGET TARGET THYROID GLAND RIGHT CT SCAN ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-01-

4 ABC TU 55555 4 R1-NT01 TUMIDENT Tumor

Identification

NONTARGET

NONTARGET

KIDNEY RIGHT CT SCAN ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-01-

5 ABC TU 55555 5 R1-NT02 TUMIDENT Tumor

Identification

NONTARGET

NONTARGET

CEREBELLUM RIGHT MRI ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-01-

6 ABC TU 55555 6 R1NEW01

TUMIDENT Tumor

Identification

NEW NEW LUNG CT SCAN ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 2010-0220

7 ABC TU 55555 7 R1NEW02

TUMIDENT Tumor

Identification

NEW NEW CEREBELLUM LEFT MRI ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

2010-0402

TR shows assessments provided by an independent assessor as opposed to the principal investigator.

Rows 1-7: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the screening visit by the independent assessor, Radiologist 1.

Rows 8-19: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the week 6 visit by the independent assessor, Radiologist 1.

Rows 20-32: Show the measurements of the target tumors and other assessments of the target and non-target tumors at the week 12 visit by the independent assessor, Radiologist 1.

tr.xpt

Row STUDYID DOMAIN USUBJID TRSEQ TRGRPID TRLNKGRP TRLNKID TRTESTCD TRTEST TRORRES TRORRESU TRSTRESC TRSTRESN TRSTRESU TRNAM TRMETHOD TREVAL TREVALID VISITNUM VISIT TRDTC TRDY 1 ABC TR 55555 1 TARGET A1 R1-T01 DIAMETER Diameter 20 mm 20 20 mm ACE IMAGING

MRI INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-

01-02

Row STUDYID DOMAIN USUBJID TRSEQ TRGRPID TRLNKGRP TRLNKID TRTESTCD TRTEST TRORRES TRORRESU TRSTRESC TRSTRESN TRSTRESU TRNAM TRMETHOD TREVAL TREVALID VISITNUM VISIT TRDTC TRDY 2 ABC TR 55555 2 TARGET A1 R1-T02 DIAMETER Diameter 15 mm 15 15 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-

01-01

3 ABC TR 55555 3 TARGET A1 R1-T03 DIAMETER Diameter 15 mm 15 15 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-

01-01

4 ABC TR 55555 4 TARGET A1 SUMDIAM Sum of Diameter

50 mm 50 50 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN

5 ABC TR 55555 5 TARGET A1 SUMNLNLD Sum

Diameters of Non Lymph Node Tumors

30 mm 30 30 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN

6 ABC TR 55555 6 NONTARGET

A1 R1-NT01 TUMSTATE Tumor State PRESENT PRESENT ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-

01-02

7 ABC TR 55555 7 NONTARGET

A1 R1-NT02 TUMSTATE Tumor State PRESENT PRESENT ACE IMAGING

MRI INDEPENDENT ASSESSOR

RADIOLOGIST 1

10 SCREEN 2010-

01-04

8 ABC TR 55555 8 TARGET A2 R1-T01 DIAMETER Diameter 12 mm 12 12 mm ACE IMAGING

MRI INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-18

9 ABC TR 55555 9 TARGET A2 R1-T02 DIAMETER Diameter 0 mm 0 0 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-19

10 ABC TR 55555 10 TARGET A2 R1-T03 DIAMETER Diameter 13 mm 13 13 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-19

11 ABC TR 55555 11 TARGET A2 SUMDIAM Sum of Diameter

25 mm 25 25 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

12 ABC TR 55555 12 TARGET A2 SUMNLNLD Sum

Diameters of Non Lymph Node Tumors

13 mm 13 13 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

13 ABC TR 55555 13 TARGET A2 LNSTATE Lymph Nodes State

PATHOLOGICAL PATHOLOGICAL ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

14 ABC TR 55555 14 TARGET A2 ACNSD Absolute Change From Nadir in Sum of Diameters

-25 mm -25 -25 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

15 ABC TR 55555 15 TARGET A2 PCBSD Percent Change From Baseline in Sum of Diameters

-50 % -60 -50 % ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

16 ABC TR 55555 16 TARGET A2 PCNSD Percent Change From Nadir in Sum of Diameters

-50 % -50 -50 % ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6

17 ABC TR 55555 17 NONTARGET

A2 R1-NT01 TUMSTATE Tumor State ABSENT ABSENT ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-19

18 ABC TR 55555 18 NONTARGET

A2 R1-NT02 TUMSTATE Tumor State ABSENT ABSENT ACE IMAGING

MRI INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-18

19 ABC TR 55555 19 NEW A2 R1NEW01

TUMSTATE Tumor State EQUIVOCAL EQUIVOCAL ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

40 WEEK 6 201002-18

20 ABC TR 55555 20 TARGET A3 R1-T01 DIAMETER Diameter 7 mm 7 7 mm ACE IMAGING

MRI INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

201004-02

21 ABC TR 55555 21 TARGET A3 R1-T02 DIAMETER Diameter 20 mm 20 20 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

201004-02

22 ABC TR 55555 22 TARGET A3 R1-T03 DIAMETER Diameter 10 mm 10 10 mm ACE IMAGING

CT SCAN INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

201004-02

23 ABC TR 55555 23 TARGET A3 SUMDIAM Sum of Diameter

37 mm 37 37 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

24 ABC TR 55555 24 TARGET A3 SUMNLNLD Sum

Diameters of Non Lymph Node Tumors

30 mm 30 30 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

25 ABC TR 55555 25 TARGET A3 LNSTATE Lymph Nodes State

NONPATHOLOGICAL NONPATHOLOGICAL ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

26 ABC TR 55555 26 TARGET A3 ACNSD Absolute Change Nadir

17 mm 17 17 mm ACE IMAGING

INDEPENDENT ASSESSOR

RADIOLOGIST 1

60 WEEK 12

## Vital Signs (VS)

*Structure: One record per vital sign measurement per time point per visit per subject, Tabulation.*

A findings domain that contains measurements including but not limited to blood pressure, temperature, respiration, body surface area, body mass index, height and weight.

### VS Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | VS | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| VSSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| VSGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| VSSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. | Perm |

### VS Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSTESTCD | Vital Signs Test Short Name | Char | (VSTESTCD) | Topic | Short name of the measurement, test, or examination described in VSTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in VSTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). VSTESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "SYSBP", "DIABP", "BMI". | Req |
| VSTEST | Vital Signs Test Name | Char | (VSTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in VSTEST cannot be longer than 40 characters. Examples: "Systolic Blood Pressure", "Diastolic Blood Pressure", "Body Mass Index". | Req |
| VSCAT | Category for Vital Signs | Char | * | Grouping Qualifier | Used to define a category of related records. | Perm |

### VS Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSSCAT | Subcategory for Vital Signs | Char | * | Grouping Qualifier | A further categorization of a measurement or examination. | Perm |
| VSPOS | Vital Signs Position of Subject | Char | (POSITION) | Record Qualifier | Position of the subject during a measurement or examination. Examples: "SUPINE", "STANDING", "SITTING". | Perm |
| VSORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the vital signs measurement as originally received or collected. | Exp |
| VSORRESU | Original Units | Char | (VSRESU) | Variable Qualifier | Original units in which the data were collected. The unit for VSORRES. Examples: "in", "LB", "beats/min". | Exp |

### VS Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from VSORRES in a standard format or standard units. VSSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in VSSTRESN. For example, if a test has results "NONE", "NEG", and "NEGATIVE" in VSORRES, and these results effectively have the same meaning, they could be represented in standard format in VSSTRESC as "NEGATIVE". | Exp |
| VSSTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from VSSTRESC. VSSTRESN should store all numeric test results or findings. | Exp |
| VSSTRESU | Standard Units | Char | (VSRESU) | Variable Qualifier | Standardized unit used for VSSTRESC and VSSTRESN. | Exp |

### VS Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that a vital sign measurement was not done. Should be null if a result exists in VSORRES. | Perm |
| VSREASND | Reason Not Performed | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Examples: "BROKEN EQUIPMENT", "SUBJECT REFUSED". Used in conjunction with VSSTAT when value is "NOT DONE". | Perm |
| VSLOC | Location of Vital Signs Measurement | Char | (LOC) | Record Qualifier | Location relevant to the collection of vital signs measurement. Example: "ARM" for blood pressure. | Perm |
| VSLAT | Laterality | Char | (LAT) | Result Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| VSLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. Should be "Y" or null. | Exp |

### VS Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. Should be "Y" or null. Note that VSBLFL is retained for backward compatibility. The authoritative baseline for statistical analysis is in an ADaM dataset. | Perm |
| VSDRVFL | Derived Flag | Char | (NY) | Record Qualifier | Used to indicate a derived record. The value should be "Y" or null. Records that represent the average of other records or that do not come from the CRF are examples of records that would be derived for the submission datasets. If VSDRVFL = "Y," then VSORRES may be null, with VSSTRESC and (if numeric) VSSTRESN having the derived value. | Perm |
| VSTOX | Toxicity | Char | * | Variable Qualifier | Description of toxicity quantified by VSTOXGR. The sponsor is expected to provide the name of the scale and version used to map the terms, utilizing the external codelist element in the Define-XML document. | Perm |

### VS Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSTOXGR | Standard Toxicity Grade | Char | * | Record Qualifier | Records toxicity grade value using a standard toxicity scale (e.g., NCI CTCAE). If value is from a numeric scale, represent only the number (e.g., "2", not "Grade 2"). The sponsor is expected to provide the name of the scale and version used to map the terms, utilizing the external codelist element in the Define-XML document. | Perm |
| VSCLSIG | Clinically Significant, Collected | Char | (NY) | Record Qualifier | Used to indicate whether a collected observation is clinically significant based on judgment. | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### VS Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the start date/time at which the assessment was made. | Perm |
| VSDTC | Date/Time of Measurements | Char | ISO 8601 datetime or interval | Timing | Date and time of the vital signs assessment represented in ISO 8601 character format. | Exp |
| VSDY | Study Day of Vital Signs | Num |  | Timing | Study day of vital signs measurements, measured as integer days. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. | Perm |
| VSTPT | Planned Time Point Name | Char |  | Timing | Text description of time when measurement should be taken. This may be represented as an elapsed time relative to a fixed reference point (e.g., time of last dose). See VSTPTNUM and VSTPTREF. Examples: "START", "5 MIN POST". | Perm |

### VS Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VSTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of VSTPT to aid in sorting. | Perm |
| VSELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a planned fixed reference (VSTPTREF). This variable is useful where there are repetitive measures. Not a clock time or a date time variable. Represented as an ISO 8601 Duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by VSTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by VSTPTREF. | Perm |
| VSTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by VSELTM, VSTPTNUM, and VSTPT. Examples: "PREVIOUS DOSE", "PREVIOUS MEAL". | Perm |
| VSRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, VSTPTREF. | Perm |

### VS Assumptions

1. In cases where the LOINC dictionary is used for vital sign tests, the permissible variable VSLOINC may be used. Sponsors are expected to provide the dictionary name and version used to map terms using

the external codelist element in the Define-XML document.

2. If a reference range is available for a vital signs test, the variables VSORNRLO, VSORNRHI, VSNRIND from the Findings observation class may be added to the domain. VSORNRLO and VSORNRHI

would represent the reference range, and VSNRIND would be used to indicate where a result falls with respect to the reference range (e.g., "HIGH", "LOW"). If toxicity grading is available, values would be represented in the variables VSTOX and VSTOXGR. Clinical significance would be represented in VSCLSIG, as described in Section 4.5.5, Clinical Significance for Findings Observation Class Data.

3. Associations between some vital sign tests and qualifier codelists are described in the VS codetable, available at https://www.cdisc.org/standards/terminology/controlled-terminology.

4. Any Identifiers, Timing variables, or Findings general observation class qualifiers may be added to the VS domain, but the following qualifiers would not generally be used: --BODSYS, --XFN, --SPEC, --

SPCCND, --FAST.

## Findings About Events or Interventions (FA)

*Structure: One record per finding, per object, per time point, per visit per.*

A findings domain that contains the findings about an event or intervention that cannot be represented within an events or interventions domain record or as a supplemental qualifier.

### FA Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | FA | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| FASEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| FAGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| FASPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined reference number. May be preprinted on the CRF as an explicit line identifier or defined in the sponsor's operational database. Example: Line number on a CRF. | Perm |

### FA Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FATESTCD | Findings About Test Short Name | Char | (FATESTCD) | Topic | Short name of the measurement, test, or examination described in FATEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in FATESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). FATESTCD cannot contain characters other than letters, numbers, or underscores. Examples: "SEV", "OCCUR". Note that controlled terminology is in a FATESTCD general codelist and in several therapeutic area-specific codelists. | Req |
| FATEST | Findings About Test Name | Char | (FATEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in FATEST cannot be longer than 40 characters. Examples: "Severity/Intensity", "Occurrence". Note that controlled terminology is in a FATEST general codelist and in several therapeutic area-specific codelists. | Req |

### FA Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FAOBJ | Object of the Observation | Char |  | Record Qualifier | Used to describe the object or focal point of the findings observation that is represented by --TEST. Examples: the term (e.g., "Acne") describing a clinical sign or symptom that is being measured by a severity test; an event (e.g., "VOMIT, where the volume of vomit is being measured by a VOLUME test). | Req |
| FACAT | Category for Findings About | Char | * | Grouping Qualifier | Used to define a category of related records. Examples: "GERD", "PRE-SPECIFIED AE". | Perm |
| FASCAT | Subcategory for Findings About | Char | * | Grouping Qualifier | A further categorization of FACAT. | Perm |
| FAORRES | Result or Finding in Original Units | Char |  | Result Qualifier | Result of the test as originally received or collected. | Exp |
| FAORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for FAORRES. | Perm |

### FA Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FASTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings, copied or derived from FAORRES in a standard format or standard units. FASTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in FASTRESN. For example, if a test has results "NONE", "NEG", and "NEGATIVE" in FAORRES, and these results effectively have the same meaning; they could be represented in standard format in FASTRESC as "NEGATIVE". | Exp |
| FASTRESN | Numeric Result/Finding in Standard Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from FASTRESC. FASTRESN should store all numeric test results or findings. | Perm |
| FASTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized unit used for FASTRESC and FASTRESN. | Perm |

### FA Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FASTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate that the measurement was not done. Should be null if a result exists in FAORRES. | Perm |
| FAREASND | Reason Not Performed | Char |  | Record Qualifier | Describes why a question was not answered. Example: "Subject refused". Used in conjunction with FASTAT when value is "NOT DONE". | Perm |
| FALOC | Location of the Finding About | Char | (LOC) | Record Qualifier | Used to specify the location of the clinical evaluation. Example: "ARM". | Perm |
| FALAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location or specimen further detailing laterality. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| FALOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally-derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |

### FA Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| FABLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. The value should be "Y" or null. Note that FABLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| FAEVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of the person who provided the evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Should be null for records that contain collected or derived data. Examples: "INVESTIGATOR", "ADJUDICATION COMMITTEE", "VENDOR". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | 1. Clinical encounter number. 2. Numeric version of VISIT, used for sorting. | Exp |
| VISIT | Visit Name | Char |  | Timing | 1. Protocol-defined description of clinical encounter. 2. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |

### FA Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time of the observation. Examples: "SCREENING", "TREATMENT", "FOLLOW-UP". | Perm |
| FADTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of findings assessment represented in ISO 8601 character format. | Exp |
| FADY | Study Day of Collection | Num |  | Timing | 1. Study day of collection, measured as integer days. 2. Algorithm for calculations must be relative to the sponsor-defined RFSTDTC variable in Demographics. This formula should be consistent across the submission. | Perm |

### FA Assumptions

1. The Findings About domain shares all qualities and conventions of findings observations.

2. See Section 6.4.1, When to Use Findings About Events or Interventions; and Section 8.6.3, Guidelines for Differentiating Between Interventions,

Events, Findings, and Findings About Events or Interventions; for guidance on deciding between the use of the FA domain and other SDTM structures.

3. See Section 6.4.2, Naming Findings About Domains, for advice on splitting the FA domain.

4. Some variables in the events and interventions domains (e.g., OCCUR, SEV, TOXGR) represent findings about the whole of the event or intervention.

When FA is used to represent findings about a part of the event or intervention (i.e., the assessment has different timing from the event as a whole), the FATEST and FATESTCD values should be the same as the variable name and variable label in the corresponding event or intervention domain. See Section 6.4.3, Variables Unique to Findings About.

a. Associations between some findings about cardiovascular interventions or events and their response codelists are described in the CV codetable, available at https://www.cdisc.org/standards/terminology/controlled-terminology.

## Skin Response (SR)

*Structure: One record per finding, per object, per time point, per visit per subject, Tabulation.*

A findings about domain for submitting dermal responses to antigens.

### SR Variables (part 1)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| STUDYID | Study Identifier | Char |  | Identifier | Unique identifier for a study. | Req |
| DOMAIN | Domain Abbreviation | Char | SR | Identifier | Two-character abbreviation for the domain. | Req |
| USUBJID | Unique Subject Identifier | Char |  | Identifier | Identifier used to uniquely identify a subject across all studies for all applications or submissions involving the product. | Req |
| SRSEQ | Sequence Number | Num |  | Identifier | Sequence number given to ensure uniqueness of subject records within a domain. May be any valid number. | Req |
| SRGRPID | Group ID | Char |  | Identifier | Used to tie together a block of related records in a single domain for a subject. | Perm |
| SRREFID | Reference ID | Char |  | Identifier | Internal or external specimen identifier. Example: "Specimen ID". | Perm |
| SRSPID | Sponsor-Defined Identifier | Char |  | Identifier | Sponsor-defined identifier. | Perm |

### SR Variables (part 2)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRTESTCD | Skin Response Test or Exam Short Name | Char | (SRTESTCD) | Topic | Short name of the measurement, test, or examination described in SRTEST. It can be used as a column name when converting a dataset from a vertical to a horizontal format. The value in SRTESTCD cannot be longer than 8 characters, nor can it start with a number (e.g., "1TEST" is not valid). SRTESTCD cannot contain characters other than letters, numbers, or underscores. | Req |
| SRTEST | Skin Response Test or Examination Name | Char | (SRTEST) | Synonym Qualifier | Verbatim name of the test or examination used to obtain the measurement or finding. The value in SRTEST cannot be longer than 40 characters. Example: "Wheal Diameter". | Req |

### SR Variables (part 3)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SROBJ | Object of the Observation | Char |  | Record Qualifier | Used to describe the object or focal point of the findings observation that is represented by --TEST. Examples: the dose of the immunogenic material or the allergen associated with the response (e.g., "Johnson Grass IgE 0.15 BAU mL"). | Req |
| SRCAT | Category for Test | Char |  | Grouping Qualifier | Used to define a category of topic-variable values across subjects. | Perm |
| SRSCAT | Subcategory for Test | Char |  | Grouping Qualifier | A further categorization of SRCAT values. | Perm |
| SRORRES | Results or Findings in Original Units | Char |  | Result Qualifier | Results of measurement or finding as originally received or collected. | Exp |
| SRORRESU | Original Units | Char | (UNIT) | Variable Qualifier | Original units in which the data were collected. The unit for SRORRES. Example: "mm". | Exp |

### SR Variables (part 4)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRSTRESC | Character Result/Finding in Std Format | Char |  | Result Qualifier | Contains the result value for all findings copied or derived from SRORRES, in a standard format or in standard units. SRSTRESC should store all results or findings in character format; if results are numeric, they should also be stored in numeric format in SRSTRESN. | Exp |
| SRSTRESN | Numeric Results/Findings in Std. Units | Num |  | Result Qualifier | Used for continuous or numeric results or findings in standard format; copied in numeric format from SRSTRESC. SRSTRESN should store all numeric test results or findings. | Exp |
| SRSTRESU | Standard Units | Char | (UNIT) | Variable Qualifier | Standardized units used for SRSTRESC and SRSTRESN. Example: "mm". | Exp |
| SRSTAT | Completion Status | Char | (ND) | Record Qualifier | Used to indicate exam not done. Should be null if a result exists in SRORRES. | Perm |

### SR Variables (part 5)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRREASND | Reason Not Done | Char |  | Record Qualifier | Describes why a measurement or test was not performed. Used in conjunction with SRSTAT when value is "NOT DONE". | Perm |
| SRNAM | Vendor Name | Char |  | Record Qualifier | Name or identifier of the laboratory or vendor who provided the test results. | Perm |
| SRSPEC | Specimen Type | Char | (SPECTYPE) | Record Qualifier | Defines the types of specimen used for a measurement. Example: "SKIN". | Perm |
| SRLOC | Location Used for Measurement | Char | (LOC) | Record Qualifier | Location relevant to the collection of the measurement. | Perm |
| SRLAT | Laterality | Char | (LAT) | Variable Qualifier | Qualifier for anatomical location further detailing laterality of intervention administration. Examples: "RIGHT", "LEFT", "BILATERAL". | Perm |
| SRMETHOD | Method of Test or Examination | Char | (METHOD) | Record Qualifier | Method of test or examination. Examples: "ELISA", "EIA", "MICRONEUTRALIZATION ASSAY", "PLAQUE REDUCTION NEUTRALIZATION ASSAY". | Perm |

### SR Variables (part 6)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRLOBXFL | Last Observation Before Exposure Flag | Char | (NY) | Record Qualifier | Operationally derived indicator used to identify the last non-missing value prior to RFXSTDTC. The value should be "Y" or null. | Perm |
| SRBLFL | Baseline Flag | Char | (NY) | Record Qualifier | Indicator used to identify a baseline value. The value should be "Y" or null. Note that SRBLFL is retained for backward compatibility. The authoritative baseline flag for statistical analysis is in an ADaM dataset. | Perm |
| SREVAL | Evaluator | Char | (EVAL) | Record Qualifier | Role of person who provided evaluation. Used only for results that are subjective (e.g., assigned by a person or a group). Should be null for records that contain collected or derived data. Examples: "INVESTIGATOR", "ADJUDICATION COMMITTEE", "VENDOR". | Perm |
| VISITNUM | Visit Number | Num |  | Timing | Clinical encounter number. Numeric version of VISIT, used for sorting. | Exp |

### SR Variables (part 7)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| VISIT | Visit Name | Char |  | Timing | Protocol-defined description of clinical encounter. May be used in addition to VISITNUM and/or VISITDY. | Perm |
| VISITDY | Planned Study Day of Visit | Num |  | Timing | Planned study day of the visit based upon RFSTDTC in Demographics. | Perm |
| TAETORD | Planned Order of Element within Arm | Num |  | Timing | Number that gives the planned order of the element within the arm. | Perm |
| EPOCH | Epoch | Char | (EPOCH) | Timing | Epoch associated with the date/time of the observation. Examples: "SCREENING", "TREATMENT", and "FOLLOW-UP". | Perm |
| SRDTC | Date/Time of Collection | Char | ISO 8601 datetime or interval | Timing | Collection date and time of an observation represented in ISO 8601. | Exp |
| SRDY | Study Day of Visit/Collection/Exam | Num |  | Timing | Actual study day of visit/collection/exam expressed in integer days relative to sponsor- defined RFSTDTC in Demographics. | Perm |

### SR Variables (part 8)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRTPT | Planned Time Point Name | Char |  | Timing | Text description of time when measurement should be taken. This may be represented as an elapsed time relative to a fixed reference point, such as time of last dose. See SRTPTNUM and SRTPTREF. Examples: "START", "5 MIN POST". | Perm |
| SRTPTNUM | Planned Time Point Number | Num |  | Timing | Numerical version of SRTPT to aid in sorting. | Perm |
| SRELTM | Planned Elapsed Time from Time Point Ref | Char | ISO 8601 duration | Timing | Planned elapsed time (in ISO 8601) relative to a fixed time point reference (SRTPTREF). Not a clock time or a date time variable. Represented as an ISO 8601 duration. Examples: "-PT15M" to represent the period of 15 minutes prior to the reference point indicated by EGTPTREF, "PT8H" to represent the period of 8 hours after the reference point indicated by SRTPTREF. | Perm |

### SR Variables (part 9)

| Variable | Label | Type | Controlled Terms / Codelist | Role | CDISC Notes | Core |
|---|---|---|---|---|---|---|
| SRTPTREF | Time Point Reference | Char |  | Timing | Name of the fixed reference point referred to by SRELTM, SRTPTNUM, and SRTPT. Example: "INTRADERMAL INJECTION". | Perm |
| SRRFTDTC | Date/Time of Reference Time Point | Char | ISO 8601 datetime or interval | Timing | Date/time of the reference time point, SRTPTREF. | Perm |

### SR Assumptions

1. The Skin Response (SR) domain is used to represent findings about an intervention, but it has its own domain code, SR, rather than the domain code

FA.

2. This domain is intended specifically for tests of the immune response to substances that are intended to provoke such a response (e.g., allergens used in

allergy testing). SR is not intended for other injection-site reactions, including reactogencity events that may follow a vaccine administration.
