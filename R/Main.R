#' @importFrom magrittr %>%
#' @export
execute <- function(
    connectionDetails,
    analysisId,
    databaseSettings,
    treatmentCohortId = 15,
    comparatorCohortId = 1,
    oracleTempSchema = NULL,
    balanceThreads = 1,
    negativeControlThreads = 1,
    fitOutcomeModelsThreads = 1,
    createPsThreads = 1,
    saveDirectory = "results"
) {

  outcomeIdsPath <- system.file(
    "settings",
    "map_outcomes.csv",
    package = "AceBeta9Outcomes"
  )

  mapOutcomes <- read.csv(outcomeIdsPath) %>%
    dplyr::arrange(dplyr::desc(stratification_outcome))

  outcomeIds <- mapOutcomes %>%
    dplyr::pull(outcome)

  negativeControlOutcomes <- read.csv(
    system.file(
      "settings",
      "negative_controls.csv",
      package = "AceBeta9Outcomes"
    )
  )

  excludedCovariateConceptIds <- read.csv(
    system.file(
      "settings",
      "excluded_covariate_concept_ids.csv",
      package = "AceBeta9Outcomes"
    )
  ) %>%
    dplyr::pull(conceptId)

  analysisSettings <- RiskStratifiedEstimation::createAnalysisSettings(
    analysisId = analysisId,
    databaseName = databaseSettings$databaseName,
    treatmentCohortId = treatmentCohortId,
    comparatorCohortId = comparatorCohortId,
    outcomeIds = outcomeIds,
    analysisMatrix = matrix(c(rep(rep(1, 12), 3), rep(rep(0, 12), 9)), ncol = 12),
    mapTreatments = read.csv(
      system.file(
        "settings",
        "map_treatments.csv",
        package = "AceBeta9Outcomes"
      )
    ),
    mapOutcomes = mapOutcomes,
    negativeControlOutcomes = negativeControlOutcomes %>% dplyr::pull(cohortId),
    balanceThreads = balanceThreads,
    negativeControlThreads = negativeControlThreads,
    verbosity = "INFO",
    saveDirectory = saveDirectory
  )

  getDataSettings <- RiskStratifiedEstimation::createGetDataSettings(
    getPlpDataSettings = RiskStratifiedEstimation::createGetPlpDataArgs(
      washoutPeriod = 365
    ),
    getCmDataSettings = RiskStratifiedEstimation::createGetCmDataArgs(
      washoutPeriod = 365
    )
  )

  covariateSettings <-
    RiskStratifiedEstimation::createGetCovariateSettings(
      covariateSettingsCm =
        FeatureExtraction::createCovariateSettings(
          useDemographicsGender           = TRUE,
          useDemographicsAge              = TRUE,
          useConditionOccurrenceLongTerm  = TRUE,
          useConditionOccurrenceShortTerm = TRUE,
          useDrugExposureLongTerm         = TRUE,
          useDrugExposureShortTerm        = TRUE,
          useDrugEraLongTerm              = TRUE,
          useDrugEraShortTerm             = TRUE,
          useCharlsonIndex                = TRUE,
          addDescendantsToExclude         = TRUE,
          addDescendantsToInclude         = TRUE,
          excludedCovariateConceptIds     = excludedCovariateConceptIds
        ),
      covariateSettingsPlp =
        FeatureExtraction::createCovariateSettings(
          useDemographicsGender           = TRUE,
          useDemographicsAge              = TRUE,
          useConditionOccurrenceLongTerm  = TRUE,
          useConditionOccurrenceShortTerm = TRUE,
          useDrugExposureLongTerm         = TRUE,
          useDrugExposureShortTerm        = TRUE,
          useDrugEraLongTerm              = TRUE,
          useDrugEraShortTerm             = TRUE,
          useCharlsonIndex                = TRUE,
          addDescendantsToExclude         = TRUE,
          excludedCovariateConceptIds     = excludedCovariateConceptIds
        )
    )

  populationSettings <- 	RiskStratifiedEstimation::createPopulationSettings(
    populationPlpSettings = PatientLevelPrediction::createStudyPopulationSettings(
      riskWindowStart                = 1,
      riskWindowEnd                  = 730,
      minTimeAtRisk                  = 729,
      removeSubjectsWithPriorOutcome = TRUE,
      includeAllOutcomes             = TRUE
    ),
    populationCmSettings = CohortMethod::createCreateStudyPopulationArgs(
      removeDuplicateSubjects = "keep first",
      riskWindowStart         = 1,
      riskWindowEnd           = 730
    )
  )

  runSettings <- RiskStratifiedEstimation::createRunSettings(
    runPlpSettings = RiskStratifiedEstimation::createRunPlpSettingsArgs(
      analyses = list(
        RiskStratifiedEstimation::createRunPlpAnalysesArgs(
          outcomeId = 2,
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression(),
          matchingSettings = RiskStratifiedEstimation::createMatchOnPsArgs(
            maxRatio = 1
          ),
          executeSettings = PatientLevelPrediction::createDefaultExecuteSettings(),
          timepoint = 730
        ),
        RiskStratifiedEstimation::createRunPlpAnalysesArgs(
          outcomeId = 18,
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression(),
          matchingSettings = RiskStratifiedEstimation::createMatchOnPsArgs(
            maxRatio = 1
          ),
          executeSettings = PatientLevelPrediction::createDefaultExecuteSettings(),
          timepoint = 730
        ),
        RiskStratifiedEstimation::createRunPlpAnalysesArgs(
          outcomeId = 52,
          modelSettings = PatientLevelPrediction::setLassoLogisticRegression(),
          matchingSettings = RiskStratifiedEstimation::createMatchOnPsArgs(
            maxRatio = 1
          ),
          executeSettings = PatientLevelPrediction::createDefaultExecuteSettings(),
          timepoint = 730
        )
      )
    ),
    runCmSettings = RiskStratifiedEstimation::createRunCmSettingsArgs(
      analyses = list(
        RiskStratifiedEstimation::createRunCmAnalysesArgs(
          label = "stratify_by_ps",
          riskStratificationMethod = "equal",
          riskStratificationThresholds = 4
        )
      ),
      psSettings = RiskStratifiedEstimation::createCreatePsArgs(
        control = Cyclops::createControl(
          threads       = -1,
          maxIterations = 5e3
        ),
        prior = Cyclops::createPrior(
          priorType = "laplace"
        )
      ),
      fitOutcomeModelsThreads = fitOutcomeModelsThreads,
      balanceThreads = balanceThreads,
      negativeControlThreads = negativeControlThreads,
      createPsThreads = createPsThreads
    )
  )

  cdmDatabaseSchema <- databaseSettings$cdmDatabaseSchema
  cohortDatabaseSchema <- databaseSettings$cohortDatabaseSchema
  outputFolder <- analysisSettings$saveDirectory

  # generateAllCohorts(
  #   connectionDetails = connectionDetails,
  #   cdmDatabaseSchema = cdmDatabaseSchema,
  #   cohortDatabaseSchema = cohortDatabaseSchema,
  #   oracleTempSchema = oracleTempSchema,
  #   indicationId = "Hypertension",
  #   outputFolder = outputFolder
  # )

  RiskStratifiedEstimation::runRiskStratifiedEstimation(
    connectionDetails = connectionDetails,
    analysisSettings = analysisSettings,
    databaseSettings = databaseSettings,
    getDataSettings = getDataSettings,
    covariateSettings = covariateSettings,
    populationSettings = populationSettings,
    runSettings = runSettings
  )


  return(NULL)
}
