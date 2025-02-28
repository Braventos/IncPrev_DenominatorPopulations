#Output
output_folder <- here(results_output)
if (!dir.exists(output_folder)) {
  dir.create(output_folder)
}


#Run other functions
source(here("R", "Utils.R"))

#Create denominator
cdm <- generateDenominatorCohortSet(cdm=cdm,
                                    name = "denominator",
                                    cohortDateRange = as.Date(c("2019-01-01", "2019-12-31")),
                                    ageGroup = list(c(0, 150)),
                                    sex = "Both",
                                    daysPriorObservation = prior_obs,
                                    requirementInteractions = FALSE)


# Characterisation of pop. excluded (ref: denominator with daysPriorObservation=0)
noObs_id <- settings(cdm$denominator)%>%
  filter(days_prior_observation=="0")%>%
  select(cohort_definition_id)%>%
  pull()

patientsCharacteristics<-list()   

for (i in prior_obs){
  id <- settings(cdm$denominator)%>%
    filter(days_prior_observation==i)%>%
    select(cohort_definition_id)%>%
    pull()
 
  if (id == noObs_id) {  #Patients included when priorObs=0
    patients <-cdm$denominator %>%
      filter(cohort_definition_id==noObs_id) 
  }else{  #Patients excluded when priorObs!=0 (comparator pop priorObs=0)
    patients <-cdm$denominator %>%
      filter(cohort_definition_id==noObs_id)  %>%
      anti_join(cdm$denominator %>%
                  filter(cohort_definition_id==id), by = "subject_id")
  }
 
  ###Add this if rows >1
  n <- patients%>%tally()%>%pull()
  if(n >0){
  patientsCharacteristics[[paste0(i,"_days")]] <-patients%>%
    summariseCharacteristics(
      tableIntersectCount = list(
          "Conditions during prior history" = list(
             tableName = "condition_occurrence",
            window = c(-Inf, -1)
          ),
        "Drug exposures during prior history" = list(
          tableName = "drug_exposure",
          window = c(-Inf, -1)
        ),
        "Visits during prior history" = list(
          tableName = "visit_occurrence",
          window = c(-Inf, -1)
        ),
        "Procedures during prior history" = list(
          tableName = "procedure_occurrence",
          window = c(-Inf, -1)
        )
      ) 
    ) %>%
  mutate(group_level= case_when(id == noObs_id ~ paste0(i, "d prior observation"),
                              id != noObs_id ~ paste0(i, "d prior observation")))
  }
}

results <-bind_rows(patientsCharacteristics)
table <-tableCharacteristics(results)

dbDisconnect(db)

##Export
write.csv(table, file = here(output_folder, paste0("Characteristics_Patients_", cdmName(cdm), ".csv")))
toPlot <- c("Conditions during prior history", "Drug exposures during prior history", 
            "Visits during prior history", "Procedures during prior history")
walk(toPlot, ~ plot_priorRecords(data = results, variable = .x))
