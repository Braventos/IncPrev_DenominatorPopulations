renv::activate() 
renv::restore()
.rs.restartR()

library(dplyr)
library(CDMConnector)
library(IncidencePrevalence)
library(ggplot2)
library(tidyr)
library(CodelistGenerator)
library(PatientProfiles)
library(CohortCharacteristics)
library(DrugUtilisation)
library(here)
library(stringr)
library(readr)
library(DBI)
library(RPostgres)
library(duckdb)
# Connection details
database_name <- "..."
server_dbi <- Sys.getenv("...")
user <- Sys.getenv("...")
password <- Sys.getenv("...")
port <- Sys.getenv("...")
host <- Sys.getenv("...")

db <- dbConnect(
  RPostgres::Postgres(),
  dbname = server_dbi,
  port = port,
  host = host,
  user = user,
  password = password
)

cdm_database_schema <- "..."
results_database_schema <- "..."

# CDM object
cdm <- cdmFromCon(
  con = db,
  cdmSchema = cdm_database_schema,
  writeSchema = c("schema" = results_database_schema),
  cdmName = database_name
)



# Eunomia
#con <- dbConnect(duckdb(), dbdir = eunomiaDir())
#cdm <- cdmFromCon(
#  con = con, cdmSchem = "main", writeSchema = "main", cdmName = "Eunomia")


# output folder
results_output<- paste0("Results_", cdmName(cdm))

# Prior observation to explore (in years)
prior_years <- c(seq(1,5,1))

# Execute code
source(here("RunStudy.R"))

print(paste0("Thanks for running the analysis. Results should be available in the folder: ", results_output))
