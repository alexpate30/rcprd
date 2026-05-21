# Details-on-algorithms-for-extracting-specific-variables

``` r

library(rcprd)
```

## Introduction

**rcprd** contains a number of functions which extract specific
variables, namely:

- BMI: `extract_BMI`
- Cholesterol/high-density lipoprotein (HDL) ratio:
  `extract_cholhdl_ratio`
- Diabetes status: `extract_diabetes`
- Smoking status: `extract_smoking`

The algorithms underpinning the extraction of these variables are given
in section 2. A summary of the unit measurements recorded for these
variables is given in section 3.

## Algorithms for variable extraction

### BMI (`extract_BMI`)

Extraction of BMI requires the user to specify three codelists. One for
BMI scores (`codelist_bmi`), one for height measurements
(`codelist_height`) and one for weight measurements (`codelist_weight`).
All the BMI, height and weight measurements for each patient in the
cohort of interest are then extracted. The algorithm is as follows:

- Extract the most recent BMI, height and weight measurements (within
  the specified time period) according to the user inputted code lists.
  Observation dates identified using variable *obsdate*.
  - The measurements must be non-missing
  - The BMI measurements must be within the user-defined valid range.
- Rescale height scores to metres. When numunitid is not
  $`\in \{173, 432, 3202\}`$, which correspond to metres, the
  measurement is assumed to be centimetres, and the height measurement
  is divided by 100 (see section 3).
- Rescale weight scores to kg. When numunitid is
  $`\in \{1691, 2318, 2997, 6265\}`$, which correspond to stone, the
  measurement is converted to kg. All other measurements are assumed to
  be kg (see section 3).
- Merge height and weight measurements.
  - Calculate BMI for every pair of height and weight measurements using
    $`\frac{weight}{height^{2}}`$.
  - Remove BMI scores that are outside the specified range.
  - Assign observation date to be the height or weight measurement which
    occurred first.
- Merge the directly recorded BMI scores, with the BMI scores calculated
  from height and weight.
- Take the most recent BMI score within the specified time period,
  whether it was a directly recorded BMI score, or calculated from
  height and weight. If both are recorded on the same date, the directly
  recorded BMI score takes preference.

### Cholesterol/HDL ratio (`extract_cholhdl_ratio`)

Extraction of cholesterol/HDL ratio requires the user to specify three
codelists. One for cholesterol/HDL ratio measurements
(`codelist_ratio`), one for total cholesterol measurements
(`codelist_chol`) and one for HDL measurements (`codelist_hdl`). All the
cholesterol/HDL, total cholesterol and cholesterol/HDL measurements for
each patient in the cohort of interest are then extracted. The algorithm
is as follows:

- Extract the most recent cholesterol/HDL, total cholesterol and
  cholesterol/HDL measurements (within the specified time period)
  according to the user inputted code lists. Observation dates
  identified using variable *obsdate*.
  - The measurements must be non-missing
  - The cholesterol/HDL ratio measurements must be within the
    user-defined valid range.
- All measurements are assumed to be in the correct unit of measurement
  (see section 3).
- Merge total cholesterol and HDL measurements.
  - Calculate cholesterol/HDL for every pair of total cholesterol and
    HDL measurements using $`\frac{total cholesterol}{HDL}`$.
  - Remove cholesterol/HDL scores that are outside the specified range.
  - Assign observation date to be the total cholesterol or HDL
    measurement which occurred first.
- Merge the directly recorded cholesterol/HDL scores, with the
  cholesterol/HDL scores calculated from total cholesterol and HDL.
- Take the most recent cholesterol/HDL score within the specified time
  period, whether it was a directly recorded cholesterol/HDL score, or
  calculated from total cholesterol and HDL. If both are recorded on the
  same date, the directly recorded cholesterol/HDL score takes
  preference.

### Diabetes status (`extract_diabetes`)

Extraction of diabetes status requires the user to specify two
codelists. One for type 1 diabetes (`codelist_type1`), and another for
type 2 diabetes (`codelist_type2`). The reason this variable is not
treated as a `history of` type variable and extracted using `extract_ho`
is because often individuals will have a generic code such as *diabetes
mellitus*, which would be used to identify type 2 diabetes, but will
also have a specific code such as *type 1 diabetes mellitus*. This
algorithm treats the two as mutually exclusive, and assigns individuals
with a code for both type 1 and type 2 diabetes, as having type 1
diabetes. The algorithm is as follows:

- Extract type 1 diabetes and type 2 diabetes observations that occurred
  prior to the index date. Observation dates identified using variable
  *obsdate*.
- Assign diabetes status.
  - If an individual has a code for both type 1 and type 2 diabetes,
    assign diabetes type 1.

### Smoking status (`extract_smoking`)

Extraction of smoking status requires the user to specify five
codelists. One for non-smoker (`codelist_non`), one for ex-smoker
(`codelist_ex`), one for light smoker (`codelist_light`), one for
moderate smoker (`codelist.moderate`) and one for heavy smoker
(`codelist_heavy`). For records identified using the light, moderate or
heavy smoker code lists, the *value* variable, which represents number
of cigarettes smoker per day, is used to modify the outputted smoking
status variable. This is to maximise the number of observations that are
defined in the same way (\< 10 day is light, 10 - 19 a day is moderate,
\> 19 is heavy). The *value* variable for observations recorded as
ex-smoker are often denoting the number of cigarettes per day the
individual used to smoke, therefore this data is not used to alter the
smoking status. If an individuals most recent record is a non-smoker,
but an individual has previous records which indicate a history of
smoking, the smoking status is altered from non-smoker to ex-smoker. The
algorithm is as follows:

- Extract the 100 most recent non, ex, light, moderate and heavy smoker
  observations according to the user inputted code lists. Observation
  dates identified using variable *obsdate*.
- If the *value* variable is non-missing for an observation identified
  using the light, moderate or heavy smoker code lists, re-define this
  to represent smoking status based on the following definition:
  - 1 - 9 per day = light smoker.
  - 10 - 19 per day = moderate smoker.
  - 19 - 100 per day = heavy smoker.
  - More than 100 per day, remove observation.
- Define smoking status to be the most recent observation.
- If there are multiple on the same date, use the most severe smoking
  status.
- If the most recent observation is non-smoker, but there are codes for
  ex, light, moderate or heavy smoker prior to this, change to
  ex-smoker.

## Summary of units of measurement for test data

In this section we report the different units of measurement that the
test data for the above variables may be recorded in. The unit of
measurement is denoted with the *numunitid* variable in the observation
file, which has a corresponding lookup file in the CPRD data. We queried
the observation data for a large cohort of individuals aged 18 - 85
between 2005 - 2020 using the code lists provided within
*inst/codelists* directory of **rcprd**.

``` r

list.files(system.file("codelists", package = "rcprd"))
#> [1] "edh_bmi_medcodeid.csv"           "edh_chol_medcodeid.csv"         
#> [3] "edh_cholhdl_ratio_medcodeid.csv" "edh_hdl_medcodeid.csv"          
#> [5] "edh_sbp_medcodeid.csv"           "height_medcodeid.csv"           
#> [7] "weight_medcodeid.csv"
```

The test data was searched separately using each code list, and the
resulting unit measurements that were recorded in more than 0.01% of the
query are presented. The results of this were fed into the programs for
deriving each of those variables (see section 2). When defining a
variable, the aim is to convert all measurements to be on the scame
scale/unit of measurement. For example, height measurements in metres
should be converted to the same scale as those recorded in centimeters.
However, for some records, the unit of measurement might be something
odd, or missing, meaning it is unclear how to convert onto the desired
scale. For observations with such unit measurements, we do not exclude
these observations, as they may be correct measurements with a
mis-recorded unit measurement. Instead, when extracting variables, and
converting relevant unit measurements, we define a minimum and maximum
value, and exclude observations that do not fit into this range. As will
be seen below, the proportion of observations with unclear unit
measurement is small (with the exception of cholesterol/hdl ratio, which
is a special case).

| numunitid |        n | Description     |  prop |
|----------:|---------:|:----------------|------:|
|         1 |    48205 | %               |  0.13 |
|        65 |   844505 | 1/1             |  2.33 |
|       153 |     7336 | IU              |  0.02 |
|       154 |    23230 | iu/L            |  0.06 |
|       202 |     9942 | ml/min          |  0.03 |
|       205 |     7642 | ml/min/1.73m\*2 |  0.02 |
|       218 |   211622 | mmol/L          |  0.58 |
|       219 |   601677 | mmol/mmol       |  1.66 |
|       223 |   168329 | mol/mol         |  0.46 |
|       260 |  4530479 | ratio           | 12.49 |
|       276 |    21232 | u/L             |  0.06 |
|       288 |    24538 | units           |  0.07 |
|       292 |   124251 | Unk UoM         |  0.34 |
|       329 |    13390 | fraction        |  0.04 |
|       405 |   154075 | UNKNOWN UNITS   |  0.42 |
|       421 |   716349 | .               |  1.97 |
|       923 |     8978 | Unknown         |  0.02 |
|       986 |    15603 | Not given       |  0.04 |
|      1047 |    21281 | \-              |  0.06 |
|      1621 |     5681 | (knk u)         |  0.02 |
|      2084 |     6504 | nil             |  0.02 |
|      2287 |     6367 | UNKNOWN UN      |  0.02 |
|      3028 |    11284 | total ratio     |  0.03 |
|        NA | 28643841 | NA              | 78.95 |

Unit measurements for cholesterol/high-density lipoprotein ratio
{.table}

The most common is ‘NA’ (78.95%). The second most common is ‘ratio’
(12.49%) then 1/1 (2.33%). The confusion about unit of measurement is
likely due to the fact that this ratio has no unit of measurement,
because total cholesterol and high-density lipoprotein have the same
unit of measurement. All measurements are therefore assumed to be in the
same unit of measurement (ratio).

| numunitid |        n | Description |  prop |
|----------:|---------:|:------------|------:|
|       180 |    30975 | mg/100 ml   |  0.06 |
|       218 | 49074320 | mmol/L      | 94.21 |
|      1155 |    10073 | (Unknown)   |  0.02 |
|        NA |  2953718 | NA          |  5.67 |

Unit measurements for total cholesterol {.table}

The majority of unit measurements are mmol/L (96.35%) or NA (3.54%). All
observations are therefore assumed to be recorded in mmol/L.

| numunitid |        n | Description |  prop |
|----------:|---------:|:------------|------:|
|       218 | 41235955 | mmol/L      | 96.35 |
|       260 |    19373 | ratio       |  0.05 |
|       893 |    13292 | (Measured)  |  0.03 |
|        NA |  1514635 | NA          |  3.54 |

Unit measurements for high-density lipoprotein {.table}

The majority of unit measurements are mmol/L (94.21%) or NA (5.67%). All
observations are therefore assumed to be recorded in mmol/L.

| numunitid |        n | Description     |  prop |
|----------:|---------:|:----------------|------:|
|         1 |    69943 | %               |  0.08 |
|       108 |   264672 | Body Mass Index |  0.32 |
|       157 | 32886546 | kg/m2           | 39.58 |
|       288 |   107275 | units           |  0.13 |
|       359 |   105462 | Kg/m?           |  0.13 |
|       568 |   175241 | BMI             |  0.21 |
|       657 |  1048230 | Kg/mÂ²          |  1.26 |
|       822 |    32524 | 18.5-24.9       |  0.04 |
|       907 |    33118 | kg/m^2          |  0.04 |
|      1309 |    57259 | K/M2            |  0.07 |
|        NA | 48260808 | NA              | 58.08 |

Unit measurements for body mass index {.table}

The majority of unit measurements are kg/m2 (39.58%), kg/mA2 (1.26%) or
NA (58.08%). All observations are therefore assumed to be recorded in
kg/m2.

| numunitid |        n | Description    |  prop |
|----------:|---------:|:---------------|------:|
|       156 | 92811964 | kg             | 98.67 |
|       827 |    42435 | Kgs            |  0.05 |
|      6265 |    16655 | decimal stones |  0.02 |
|        NA |  1166808 | NA             |  1.24 |

Unit measurements for weight {.table}

The majority of unit measurements are kg (98.67%) or NA (1.24%). Most
observations are therefore assumed to be recorded in kg, however we also
know from that for numunitid $`\in {1691, 2318, 2997 or 6265}`$, this
refers to stone. Observations with these units of measurements are
therefore converted to kg.

| numunitid |        n | Description |  prop |
|----------:|---------:|:------------|------:|
|       122 | 54580324 | cm          | 96.82 |
|       173 |   957467 | m           |  1.70 |
|       408 |    51347 | cms         |  0.09 |
|       432 |    10404 | metres      |  0.02 |
|        NA |   772699 | NA          |  1.37 |

Unit measurements for height {.table}

The majority of unit measurements are cm (96.82%), m (1.7%), metres
(0.02%) or NA (.37%). All observations with numunit not corresponding to
metres, will be assumed to be in centimetres, and converted to metres to
enable estimation of BMI.

| numunitid |         n | Description |  prop |
|----------:|----------:|:------------|------:|
|       210 | 124843322 | mm Hg       | 62.15 |
|       212 |   1535545 | mm/Hg       |  0.76 |
|       215 |   3530255 | mm\[Hg\]    |  1.76 |
|       216 |  70398638 | mmHg        | 35.05 |
|      1207 |    197946 | Systolic    |  0.10 |
|        NA |    320463 | NA          |  0.16 |

Unit measurements for systolic blood pressure {.table}

While there is not a unique algorithm for SBP, we still present the
results from the database query for this variable. All measurement are
in mm/Hg.
