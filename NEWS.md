# bugfix for extract_smoking

There was a bug in the extract_smoking function where smoking records AFTER the index
date were being returned. This has been fixed, however, if you have
uesd the extract_smoking function prior to 27/06/2025, you will need to re-run this.
Fix will be pushed to CRAN in the near future.

# rcprd 0.0.1

* Created NEWS.md file.

# rcprd 0.0.0.9000

* Preparing for CRAN submission.
