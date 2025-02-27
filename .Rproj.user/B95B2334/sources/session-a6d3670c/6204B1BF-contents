# Read medication concept sets

# Medications
medications_codelist <- CodelistGenerator::codesFromConceptSet(
  path = here("1_InstantiateConcepts", "Concepts", "MedicationsConceptSet"),
  cdm = cdm
)
cdm <- DrugUtilisation::generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "medications",
  conceptSet = medications_codelist
)

# Conditions
conditions_concepts <- readCohortSet(
  path = here("1_InstantiateConcepts", "Concepts", "Comorbidities")
)

codes <- codesFromConceptSet(path=here("1_InstantiateConcepts", "Concepts", "Comorbidities"), 
                             cdm, 
                             type = c("codelist"))


codes_list <- newCodelist(codes)

cdm$conditions <- cdm |> 
  conceptCohort(conceptSet = codes_list, 
                exit = "event_start_date", 
                name = "conditions")



