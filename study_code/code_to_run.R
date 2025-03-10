# renv::activate() 
# renv::restore()

library(omopgenerics)
library(CDMConnector)
library(IncidencePrevalence)
library(PatientProfiles)
library(CohortCharacteristics)
library(CohortConstructor)
library(OmopSketch)
library(dplyr)
library(here)
library(stringr)
library(DBI)
library(RPostgres)
library(odbc)
library(purrr)
library(here)

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

# create the cdm object ----
cdm <- cdmFromCon(
  con = db,
  cdmSchema = cdm_database_schema,
  writeSchema = results_database_schema,
  cdmName = database_name
)

# run code ----
min_cell_count <- 5
source(here("run_study.R"))
