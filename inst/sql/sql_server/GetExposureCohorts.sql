{DEFAULT @cohort_database_schema = 'scratch.dbo' }
{DEFAULT @paired_cohort_table = 'cohort' }
{DEFAULT @target_id = 1}
{DEFAULT @comparator_id = 2}

SELECT row_id,
CASE
WHEN e1.cohort_definition_id = @target_id
THEN 1
ELSE 0
END AS treatment,
e1.subject_id,
e1.cohort_start_date,
DATEDIFF(DAY, observation_period_start_date, e1.cohort_start_date) AS days_from_obs_start,
DATEDIFF(DAY, e1.cohort_start_date, e1.cohort_end_date) AS days_to_cohort_end,
DATEDIFF(DAY, e1.cohort_start_date, observation_period_end_date) AS days_to_obs_end
FROM @cohort_database_schema.@paired_cohort_table e1
INNER JOIN #exposure_cohorts e2
ON e1.subject_id = e2.subject_id
AND e1.cohort_start_date = e2.cohort_start_date
AND e1.cohort_end_date = e2.cohort_end_date
INNER JOIN @cdm_database_schema.observation_period op
ON op.person_id = e1.subject_id
AND op.observation_period_start_date <= e1.cohort_start_date
AND op.observation_period_end_date >= e1.cohort_start_date
WHERE e1.target_id = @target_id
AND e1.comparator_id = @comparator_id
ORDER BY e1.subject_id:
