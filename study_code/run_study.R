
# analysis settings -----
prior_obs <- c(0, 30, 90, 180, 
               365, 730, 1095)
age_groups <- list(c(0, 150),
                   c(0, 9),
                   c(10, 19),
                   c(20, 39),
                   c(49, 69),
                   c(70, 100))
sex <- c("Both", "Male", "Female")
study_periods <- c("2017", "2019", "2021")

# analysis -----
results <- list()

cli::cli_inform("Getting cdm snapshot")
results[["snapshot"]] <- summariseOmopSnapshot(cdm = cdm)

# loop through age groups and sexes 
# within each first create a denominator cohort with zero days required
# then for each prior obs required, create that cohort
# and compare those included vs not included when time required is added
# with characteristics at time of 

for(j in seq_along(age_groups)){
for(k in seq_along(sex)) {
for(z in seq_along(study_periods)) {

working_age_group <- age_groups[j]
working_sex <- sex[k]
working_period <- paste0(study_periods[z], "-01-01")

cli::cli_inform("Running analysis for age group: {working_age_group}, sex: {working_sex}, study_period: {working_period}")

# reference denominator - zero days prior obs requirement
cli::cli_inform("- Getting reference denominator cohort (zero day requirement)")
cdm <- generateDenominatorCohortSet(cdm=cdm,
                                    name = "denominator_0_days",
                                    cohortDateRange = as.Date(c(working_period, working_period)),
                                    ageGroup = working_age_group,
                                    sex = working_sex,
                                    daysPriorObservation = 0)
for(i in seq_along(prior_obs)){
working_prior_obs_req <- prior_obs[i]
included_name <- paste0("included - ", 
                        working_prior_obs_req, 
                        " days required; age ",
                        working_age_group[[1]][1], 
                        " to ",
                        working_age_group[[1]][2],
                        "; sex ",
                        working_sex,
                        "; year ",
                        working_period
                        )
excluded_name <- paste0("excluded - ", 
                        working_prior_obs_req, 
                        " days required; age ",
                        working_age_group[[1]][1], 
                        " to ",
                        working_age_group[[1]][2],
                        "; sex ",
                        working_sex,
                        "; year ",
                        working_period
)

cli::cli_inform("- Getting cohort with {working_prior_obs_req} days prior observation")
cdm <- generateDenominatorCohortSet(cdm=cdm,
                                    name = "denominator_days_required",
                                    cohortDateRange = as.Date(c(working_period, working_period)),
                                    ageGroup = working_age_group,
                                    sex = working_sex,
                                    daysPriorObservation = working_prior_obs_req)

# the people that included in when days required were applied 
# note time is relative to denominator entry when 0 days were required
cli::cli_inform("- Getting characteristics of those included")
chars_included <- cdm$denominator_0_days |> 
  requireCohortIntersect(targetCohortTable = "denominator_days_required",
                         window = c(-Inf, Inf),
                         intersections = c(1, Inf), 
                         name = "denominator_with_days") |>
  summariseCharacteristics(tableIntersectCount = list(
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
                           )  
results[[paste0("included_", i, "_", j, "_", k, "_", z)]] <- chars_included |> 
  mutate(group_level = included_name)

if(working_prior_obs_req != 0){
cli::cli_inform("- Getting characteristics of those excluded")
# the people that were not included in when days required were applied  
# note time is relative to denominator entry when 0 days were required
chars_excluded <- cdm$denominator_0_days |> 
  requireCohortIntersect(targetCohortTable = "denominator_days_required",
                         window = c(-Inf, Inf),
                         intersections = 0, 
                         name = "denominator_with_days") |>
  summariseCharacteristics(tableIntersectCount = list(
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
                           ))   
results[[paste0("excluded_", i, "_", j, "_", k, "_", z)]] <- chars_excluded |> 
  mutate(group_level = excluded_name)
}}}}}

results <- bind(results)

# export results
exportSummarisedResult(results, 
                       minCellCount = min_cell_count,
                       fileName = "results_{cdm_name}_{date}.csv",
                       path = here::here("results"))

print(paste0("Thanks for running the analysis. Results should be available in the results folder"))

