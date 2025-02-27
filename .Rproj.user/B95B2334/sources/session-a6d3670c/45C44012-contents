
plot_priorRecords <- function(data, variable) {
  data |> 
    filter(variable_name == variable) |> 
    plotCharacteristics(
      plotType = "boxplot",
      colour = "cohort_name",
      facet = c("cdm_name")
    ) +
    scale_x_discrete(limits = rev(sort(unique(data %>%
                                                filter(variable_name == variable) %>%
                                                select(group_level) %>%
                                                distinct() %>%
                                                pull())))) +
    coord_flip() +
    theme(legend.position = "none") +
    ggtitle(variable)
  
  ggsave(filename= paste0( str_replace_all(variable, " ", "_"), "_", cdmName(cdm), ".jpeg"), path= here(output_folder))
}
