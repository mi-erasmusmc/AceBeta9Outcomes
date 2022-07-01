# A standardized framework for risk-based assessment of treatment effect heterogeneity in observational healthcare databases

## Requirements

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel).
- R version 4.0.2
- On Windows: [RTools](https://cran.r-project.org/bin/windows/Rtools/)
- [Java](https://www.java.com/en/)

## How to run

1. Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) on setting up your R environment.
2. Clone the repository.
3. Open the package in RStudio and install all dependencies with:

```r
install.packages("renv")
renv::activate()
renv::restore()
```
4. Build the package in RStudio selecting `Build > Install and restart`. This will install the `AceBeta9Outcomes` package
5. Once installed you need to define your connection details to the database and the database settings:
```r
library(AceBeta9Outcomes)

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = "some.server.com/ohdsi",
  user = "username",
  password = "password"
)

databaseSettings <- RiskStratifiedEstimation::createDatabaseSettings(
  databaseName = "mdcd",
  cdmDatabaseSchema = "cdm_mdcd",
  cohortDatabaseSchema = "scratch",
  outcomeDatabaseSchema = "scratch",
  resultsDatabaseSchema = "scratch",
  exposureDatabaseSchema = "scratch",
  cohortTable = "legend_hypertension_exp_cohort",
  outcomeTable = "legend_hypertension_out_cohort",
  exposureTable = "legend_hypertension_exp_cohort",
  mergedCohortTable = "legend_hypertension_merged"
)
```
6. Finally, execute the analysis for a single database with:
```r
execute(
  connectionDetails = connectionDetails,
  analysisId = "mdcd_analysis",
  databaseSettings = databaseSettings
)
```

Following these instructions will run the analysis on one database (mdcd) and
will store the results inside the directory named `results`. To generate
results on other databases we need to redefine the `connectionDetails` and the
`databaseSettings` and rerun the `execute(...)` function.

## License

`AceBeta9Outcomes` is licensed under the Apache License 2.0.
