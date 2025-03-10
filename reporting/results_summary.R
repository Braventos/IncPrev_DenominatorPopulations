
library(omopgenerics)
library(ggplot2)
library(CohortCharacteristics)
library(here)
library(stringr)
library(dplyr)
library(tidyr)

results <- importSummarisedResult(here("data"))


chars_tbl <- tableCharacteristics(results |>
                       filter(str_detect(group_level,
                                         "age 0 to 150; sex Both")) |>
                       filter(str_detect(group_level,
                                           "30 days",
                                         negate = TRUE)) |>
                         filter(str_detect(group_level,
                                           "90 days",
                                           negate = TRUE)) |>
                         filter(str_detect(group_level,
                                           "180 days",
                                           negate = TRUE))
                       )

chars_tbl
# gt::gtsave(chars_tbl, "tab_1.docx")

# plot counts of included
plot_data <- results |>
  filter(variable_name %in% c("Number subjects", "number subjects")) |>
  tidy() |>
  filter(stringr::str_detect(cohort_name, "included")) |>
  mutate(days_required = as.numeric(stringr::str_extract(cohort_name, "\\d+"))) |>
  tidyr::separate(col = "cohort_name",
                  into = c("name", "age_group", "sex"), sep = ";")
# add proportional change
plot_data <- plot_data |>
  left_join(plot_data |>
  filter(days_required == 0)|>
    select(!"days_required")|>
    select(!"name") |>
  rename("start_count" = "count"))
plot_data <- plot_data |>
  mutate(change_prop = ((start_count - count)/  start_count) *100)

plot_data |>
  ggplot() +
  geom_point(aes(days_required, count)) +
  geom_line(aes(days_required, count)) +
  facet_grid(sex ~ age_group) +
  theme_bw()+
  ylim(0, NA) +
  xlab("Number of days of prior observation required") +
  ylab("Number included")


plot_data |>
  ggplot() +
  geom_point(aes(days_required, change_prop)) +
  geom_line(aes(days_required, change_prop)) +
  facet_grid(sex ~ age_group) +
  theme_bw()+
  ylim(0, NA) +
  xlab("Number of days of prior observation required") +
  ylab("Percentage dropped")


