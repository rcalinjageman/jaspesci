jasp_meta_pdiff_two <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  has_moderator <- options$moderator != ""

  # Check if ready
  ready <- options$reference_cases != "" & options$reference_ns != "" & options$comparison_cases != "" & options$comparison_ns != ""


  if (ready) {

    # read dataset
    dataset <- jasp_meta_pdiff_two_read_data(dataset, options)


    # check for errors
    # cases and ns are positive;
    .hasErrors(
      dataset = dataset,
      type = c("observations", "variance", "infinity", "negativeValues"),
      all.target = c(options$ns, options$cases),
      observations.amount  = "< 2",
      exitAnalysisIfErrors = TRUE
    )

    if (options$moderator != "") {

      # At least 2 levels in grouping variable
      .hasErrors(
        dataset = dataset,
        type = "factorLevels",
        factorLevels.target  = options$moderator,
        factorLevels.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )

      # at least 2 observations in each level of the moderator
      .hasErrors(
        dataset = dataset,
        type = c("observations", "variance", "infinity"),
        all.grouping = options$moderator,
        all.target = c(options$cases, options$ns),
        observations.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )

    }


    # Run the analysis
    self <- list()
    self$options <- options

    args <- list()

    call <- esci::meta_pdiff_two

    args$data <- dataset
    args$effect_label <- jasp_text_fix(options, "effect_label", "My effect")
    args$conf_level <- self$options$conf_level
    args$reference_cases <- self$options$reference_cases
    args$reference_ns <- self$options$reference_ns
    args$comparison_cases <- self$options$comparison_cases
    args$comparison_ns <- self$options$comparison_ns

    args$reported_effect_size <- self$options$reported_effect_size
    args$random_effects <- self$options$random_effects %in% c("random_effects", "compare")


    if (self$options$moderator != "") {
      args$moderator <- self$options$moderator
    }

    if (self$options$labels != "") {
      args$labels <- self$options$labels
    }


    # debugtext <- createJaspHtml(text = paste(dataset, collapse = "<BR>"))
    # debugtext$dependOn(jasp_meta_table_depends_on())
    # jaspResults[["debugtext"]] <- debugtext

    estimate <- try(do.call(what = call, args = args))
    if(is(estimate, "try-error")) stop(estimate[1])

    # add pref and pcomp to raw data, should be moved to esci
    estimate$raw_data$reference_P <- estimate$raw_data$reference_cases / estimate$raw_data$reference_N
    estimate$raw_data$comparison_P <- estimate$raw_data$comparison_cases / estimate$raw_data$comparison_N


    # Seems to be some encoding issue with presenting factors in JASP
    estimate$raw_data$label <- as.character(estimate$raw_data$label)
    if (has_moderator) estimate$raw_data$moderator <- as.character(estimate$raw_data$moderator)

    # Fix notes, also need to move to within esci
    estimate <- jasp_meta_notes(options, estimate, NULL, jaspResults)



  } else {
    estimate <- NULL
  }

  # Define and fill the raw_data
  if (is.null(jaspResults[["meta_raw_dataTable"]])) {
    jasp_meta_raw_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      estimate = estimate,
      effect_size = "pdiff"
    )

    if (ready) jasp_table_fill(
      jaspResults[["meta_raw_dataTable"]],
      estimate,
      "raw_data"
    )

  }


  # Define and fill the es_meta
  if (is.null(jaspResults[["es_metaTable"]])) {

    jasp_es_meta_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      estimate = estimate
    )
    if (ready) jasp_table_fill(
      jaspResults[["es_metaTable"]],
      estimate,
      "es_meta"
    )
  }



  # Define and fill the es_heterogeneityTable table
  if (is.null(jaspResults[["es_heterogeneityTable"]])) {
    if (ready) {
      my_levels <- nrow(estimate$es_heterogeneity)
    } else {
      my_levels <- 0
    }

    jasp_es_heterogeneity_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      levels = my_levels
    )
    if (ready) jasp_table_fill(
      jaspResults[["es_heterogeneityTable"]],
      estimate,
      "es_heterogeneity"
    )
  }


  # Define and fill the meta_difference table if there is a moderator
  if (has_moderator & is.null(jaspResults[["es_meta_differenceTable"]])) {
    jasp_es_meta_difference_prep(
      jaspResults,
      options = options,
      ready = ready,
      estimate = estimate
    )
    if (ready) jasp_table_fill(
      jaspResults[["es_meta_differenceTable"]],
      estimate,
      "es_meta_difference"
    )
  }


  # Now the forest plot
  if (is.null(jaspResults[["forest_plot"]])) {
    # Define the plot
    jasp_forest_plot_prep(jaspResults, options)


    if (ready) {
      # Create the plot
      meta_diamond_height <- options$meta_diamond_height
      explain_DR <- options$random_effects == "compare"
      include_PIs <- options$include_PIs & options$random_effects == "random_effects"

      myplot <- esci::plot_meta(
        estimate,
        mark_zero = options$mark_zero,
        include_PIs = include_PIs,
        report_CIs = options$report_CIs,
        meta_diamond_height = meta_diamond_height,
        explain_DR = explain_DR
      )

      # Apply aesthetics to the plot
      xlab_replace <- paste(
        estimate$properties$effect_size_name_ggplot,
        ": ",
        estimate$es_meta$effect_label[[1]],
        sep = ""
      )


      # passing such a strange variety of objects to this function; needs revision
      es_meta_difference <- if (has_moderator) estimate$es_meta_difference else NULL


      myplot <- jasp_forest_plot_decorate(myplot, options, xlab_replace, has_moderator, es_meta_difference)

      jaspResults[["forest_plot"]]$plotObject <- myplot

    }
  }


  return()

}



jasp_meta_pdiff_two_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else {

    args <- list()
    args$columns.as.numeric = c(
      options$reference_cases,
      options$reference_ns,
      options$comparison_cases,
      options$comparison_ns
    )

    args$columns.as.factor <- NULL

    args$columns.as.factor <- c(
      if (options$labels != "") options$labels else NULL,
      if (options$moderator != "") options$moderator else NULL
    )

    return (
      do.call(
        what = .readDataSetToEnd,
        args = args
      )
    )
  }
}
