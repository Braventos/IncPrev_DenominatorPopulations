# Read medication concept sets

# Medications
medications_codelist <- CodelistGenerator::codesFromConceptSet(
  path = here("1_InstantiateCohorts", "Cohorts", "MedicationsConceptSet"),
  cdm = cdm
)
cdm <- DrugUtilisation::generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "medications",
  conceptSet = medications_codelist
)

# Conditions
conditions_cohort_set <- readCohortSet(
  path = here("1_InstantiateCohorts", "Cohorts", "Comorbidities")
)

# cdm <- generateCohortSet(
#   cdm = cdm,
#   cohortSet = conditions_cohort_set,
#  name = "conditions",
#   computeAttrition = TRUE,
#   overwrite = TRUE
# )

