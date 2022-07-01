#' Genarates all the cohorts of the LEGEND-hyperetnsion study
#' @export
generateAllCohorts <- function(
  connectionDetails,
  cdmDatabaseSchema,
  cohortDatabaseSchema,
  oracleTempSchema = NULL,
  indicationId = "Hypertension",
  outputFolder
) {
  Legend::createExposureCohorts(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    oracleTempSchema = NULL,
    indicationId = indicationId,
    outputFolder = saveDirectory
  )

  Legend::createOutcomeCohorts(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    oracleTempSchema = NULL,
    indicationId = indicationId,
    outputFolder = saveDirectory
  )

}
