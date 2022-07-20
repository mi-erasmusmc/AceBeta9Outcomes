library(AceBeta9Outcomes)
# readr::read_csv("https://raw.githubusercontent.com/OHDSI/Legend/master/inst/settings/OutcomesOfInterest.csv") %>% filter(indicationId == "Hypertension") %>%
#   rename(c("outcome" = "cohortId", "outcome_name" = "name")) %>%
#   select(outcome, outcome_name) %>%
#   filter(outcome %in% c(2, 52, 18, 41, 32, 9, 28, 39, 54, 55, 11, 12)) %>%
#   arrange(outcome) %>%
#   mutate(stratification_outcome = as.numeric(outcome %in% c(2, 52, 18))) %>%
#   readr::write_csv("inst/settings/map_outcomes.csv")

options(
  andromedaTempFolder = "tmp"
)


database <- "truven_ccae"
databaseVersion <- "v2008"
databaseName <- "ccae"
cdmDatabaseSchema <- paste("cdm", database, databaseVersion, sep = "_")
scratchSchema <- Sys.getenv("SCRATCH_SCHEMA")
analysisId <- paste("ccae_analysis")
outcomeDatabaseSchema <- "scratch_arekkas"
resultsDatabaseSchema <- "scratch_arekkas"
exposureDatabaseSchema <- "scratch_arekkas"
cohortDatabaseSchema <- "scratch_arekkas"

server <- file.path(
  Sys.getenv("OHDA_URL"),
  database
)
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = 'redshift',
  server = server,
  port = 5439,
  user = Sys.getenv("OHDA_USER"),
  password = Sys.getenv("OHDA_PASSWORD"),
  extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory",
  pathToDriver = Sys.getenv("REDSHIFT_DRIVER")
)

databaseSettings <- RiskStratifiedEstimation::createDatabaseSettings(
  databaseName = databaseName,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cohortDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  exposureDatabaseSchema = exposureDatabaseSchema,
  outcomeDatabaseSchema = outcomeDatabaseSchema,
  cohortTable = "legend_hypertension_exp_cohort",
  outcomeTable = "legend_hypertension_out_cohort",
  exposureTable = "legend_hypertension_exp_cohort",
  mergedCohortTable = "legend_hypertension_merged"
)

execute(
  analysisId = analysisId,
  connectionDetails = connectionDetails,
  databaseSettings = databaseSettings,
  treatmentCohortId = 15,
  comparatorCohortId = 1,
  negativeControlThreads = 2,
  fitOutcomeModelsThreads = 4,
  createPsThreads = 2
)
