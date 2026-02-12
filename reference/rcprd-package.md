# rcprd: Extraction and Management of Clinical Practice Research Datalink Data

Simplify the process of extracting and processing Clinical Practice
Research Datalink (CPRD) data in order to build datasets ready for
statistical analysis. This process is difficult in 'R', as the raw data
is very large and cannot be read into the R workspace. 'rcprd' utilises
'RSQLite' to create 'SQLite' databases which are stored on the hard
disk. These are then queried to extract the required information for a
cohort of interest, and create datasets ready for statistical analysis.
The processes follow closely that from the 'rEHR' package, see Springate
et al., (2017)
[doi:10.1371/journal.pone.0171784](https://doi.org/10.1371/journal.pone.0171784)
.

## See also

Useful links:

- <https://alexpate30.github.io/rcprd/>

## Author

**Maintainer**: Alexander Pate <alexander.pate@manchester.ac.uk>
([ORCID](https://orcid.org/0000-0002-0849-3458)) \[copyright holder\]
