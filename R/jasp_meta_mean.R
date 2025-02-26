jasp_meta_mean <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  has_moderator <- options$moderator != ""

  # Check if ready
  if (from_raw) {
    ready <- options$means != "" &
      options$sds != "" &
      options$ns != ""
  } else {
    ready <- options$means != "" & options$ns != ""
  }


  if (ready) {

    # read dataset
    dataset <- jasp_meta_mean_read_data(dataset, options)


    # check for errors
    # ns are positive; if from_raw sds should all be positive, too
    .hasErrors(
      dataset = dataset,
      type = c("observations", "variance", "infinity", "negativeValues"),
      all.target = if (from_raw) c(options$sds, options$ns) else c(options$ns),
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
        all.target = if (from_raw) c(options$means, options$sds)
          else c(options$means, options$ns)
        ,
        observations.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )

    }


    # Run the analysis
    self <- list()
    self$options <- options

    args <- list()

    call <- if (from_raw) esci::meta_mean else esci::meta_d1

    args$data <- dataset
    args$effect_label <- jasp_text_fix(options, "effect_label", "My effect")
    args$conf_level <- self$options$conf_level

    has_reference <- FALSE
    if (from_raw) {
      args$means <- self$options$means
      args$sds <- self$options$sds
      args$ns <- self$options$ns
      args$reported_effect_size <- self$options$reported_effect_size

      if (!(options$reference_mean %in% c("auto", "Auto", "AUTO", ""))) {
        try(args$reference_mean <- as.numeric(options$reference_mean))
        if (is.na(args$reference_mean)) {
          args$reference_mean <- NULL
        } else {
          has_refernece <- TRUE
        }
      }
    } else {
      args$ds <- self$options$means
      args$ns <- self$options$ns
    }

    if (self$options$moderator != "") {
      args$moderator <- self$options$moderator
    }

    if (self$options$labels != "") {
      args$labels <- self$options$labels
    }

    args$random_effects <- self$options$random_effects %in% c("random_effects", "compare")

    estimate <- try(do.call(what = call, args = args))

    # properties cleanup - need to move this into esci
    if (!is.null(args$reference_mean) & from_raw) {
      if (options$reported_effect_size == "mean_difference") {
        estimate$properties$effect_size_name_html <- paste(
          estimate$properties$effect_size_name_html,
          " - <i>M</i><sub>Reference</sub>",
          sep = ""
        )
        estimate$properties$effect_size_name_ggplot <- paste(
          estimate$properties$effect_size_name_ggplot,
          " - <i>M</i><sub>Reference</sub>",
          sep = ""
        )

      } else {
      }
    }

    # Seems to be some encoding issue with presenting factors in JASP
    estimate$raw_data$label <- as.character(estimate$raw_data$label)
    if (has_moderator) estimate$raw_data$moderator <- as.character(estimate$raw_data$moderator)

    # Fix notes, also need to move to within esci
    estimate <- jasp_meta_notes(options, estimate, args$reference_mean)



  } else {
    estimate <- NULL
  }

  # Define and fill the raw_data
  if (is.null(jaspResults[["meta_raw_dataTable"]])) {
    jasp_meta_raw_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      estimate = estimate
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
        if (has_reference) "<i>M</i> - <i>M</i><sub>Reference</sub>" else estimate$properties$effect_size_name_ggplot,
        ": ",
        estimate$es_meta$effect_label[[1]],
        sep = ""
      )


      # passing such a strange variety of objects to this function; needs revision
      es_meta_difference <- if (has_moderator) estimate$es_meta_difference else NULL


      myplot <- jasp_forest_plot_decorate(myplot, options, xlab_replace, has_moderator, es_meta_difference)

      jaspResults[["forest_plot"]]$plotObject <- myplot
      jaspResults[["forest_plot"]]$position <- 50

    }
  }


  return()

}



jasp_meta_mean_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else {

    from_raw <- options$switch == "from_raw"

    args <- list()
    if (from_raw) {
      args$columns.as.numeric = c(options$means, options$sds, options$ns)
    } else {
      args$columns.as.numeric = c(options$means, options$ns)
    }

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


jasp_forest_plot_decorate <- function(myplot, options, xlab_replace = "My Effect", has_moderator = FALSE, es_meta_difference = NULL) {

  # make compatible with jamovi code
  self <- list()
  self$options <- options

  myplot <- myplot + ggplot2::scale_size_continuous(
    range = c(
      as.numeric(self$options$size_base),
      as.numeric(self$options$size_base) * as.numeric(self$options$size_multiplier)
    )
  )

  if (!is.null(myplot$layers$raw_Reference_point)) {
    myplot$layers$raw_Reference_point$aes_params$shape <- self$options$shape_raw_reference
    myplot$layers$raw_Reference_point$aes_params$colour <- self$options$color_raw_reference
    myplot$layers$raw_Reference_point$aes_params$fill <- self$options$fill_raw_reference
    myplot$layers$raw_Reference_point$aes_params$alpha <- 1 - as.numeric(self$options$alpha_raw_reference)

    myplot$layers$raw_Reference_error$aes_params$colour <- self$options$color_interval_reference
    myplot$layers$raw_Reference_error$aes_params$size <- as.numeric(self$options$size_interval_reference)
    myplot$layers$raw_Reference_error$aes_params$alpha <- 1 - as.numeric(self$options$alpha_interval_reference)
    myplot$layers$raw_Reference_error$aes_params$linetype <- self$options$linetype_raw_reference
  }
  if (!is.null(myplot$layers$raw_Comparison_point)){
    myplot$layers$raw_Comparison_point$aes_params$shape <- self$options$shape_raw_comparison
    myplot$layers$raw_Comparison_point$aes_params$colour <- self$options$color_raw_comparison
    myplot$layers$raw_Comparison_point$aes_params$fill <- self$options$fill_raw_comparison
    myplot$layers$raw_Comparison_point$aes_params$alpha <- 1 - as.numeric(self$options$alpha_raw_comparison)

    myplot$layers$raw_Comparison_error$aes_params$colour <- self$options$color_interval_comparison
    myplot$layers$raw_Comparison_error$aes_params$size <- as.numeric(self$options$size_interval_comparison)
    myplot$layers$raw_Comparison_error$aes_params$alpha <- 1 - as.numeric(self$options$alpha_interval_comparison)
    myplot$layers$raw_Comparison_error$aes_params$linetype <- self$options$linetype_raw_comparison
  }
  if (!is.null(myplot$layers$raw_Unused_point)) {
    myplot$layers$raw_Unused_point$aes_params$shape <- self$options$shape_raw_unused
    myplot$layers$raw_Unused_point$aes_params$colour <- self$options$color_raw_unused
    myplot$layers$raw_Unused_point$aes_params$fill <- self$options$fill_raw_unused
    myplot$layers$raw_Unused_point$aes_params$alpha <- 1 - as.numeric(self$options$alpha_raw_unused)

    myplot$layers$raw_Unused_error$aes_params$colour <- self$options$color_interval_unused
    myplot$layers$raw_Unused_error$aes_params$size <- as.numeric(self$options$size_interval_unused)
    myplot$layers$raw_Unused_error$aes_params$alpha <- 1 - as.numeric(self$options$alpha_interval_unused)
    myplot$layers$raw_Unused_error$aes_params$linetype <- self$options$linetype_raw_unused
  }

  if (!is.null(myplot$layers$group_Overall_diamond)) {
    myplot$layers$group_Overall_diamond$aes_params$colour <- self$options$color_summary_overall
    myplot$layers$group_Overall_diamond$aes_params$fill <- self$options$fill_summary_overall
    myplot$layers$group_Overall_diamond$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_overall)
  }

  if (!is.null(myplot$layers$group_Comparison_diamond)) {
    myplot$layers$group_Comparison_diamond$aes_params$colour <- self$options$color_summary_comparison
    myplot$layers$group_Comparison_diamond$aes_params$fill <- self$options$fill_summary_comparison
    myplot$layers$group_Comparison_diamond$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_comparison)
  }

  if (!is.null(myplot$layers$group_Reference_diamond)) {
    myplot$layers$group_Reference_diamond$aes_params$colour <- self$options$color_summary_reference
    myplot$layers$group_Reference_diamond$aes_params$fill <- self$options$fill_summary_reference
    myplot$layers$group_Reference_diamond$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_reference)
  }

  if (!is.null(myplot$layers$group_Difference_diamond)) {
    myplot$layers$group_Difference_diamond$aes_params$shape <- self$options$shape_summary_difference
    myplot$layers$group_Difference_diamond$aes_params$colour <- self$options$color_summary_difference
    myplot$layers$group_Difference_diamond$aes_params$fill <- self$options$fill_summary_difference
    myplot$layers$group_Difference_diamond$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_difference)
  }

  if (!is.null(myplot$layers$group_Difference_line)) {
    myplot$layers$group_Difference_line$aes_params$colour <- self$options$color_interval_difference
    myplot$layers$group_Difference_line$aes_params$size <-  as.numeric(self$options$size_interval_difference)
    myplot$layers$group_Difference_line$aes_params$alpha <- 1 - as.numeric(self$options$alpha_interval_difference)
    myplot$layers$group_Difference_line$aes_params$linetype <- self$options$linetype_summary_difference
  }

  if (!is.null(myplot$layers$group_Unused_diamond)) {
    myplot$layers$group_Unused_diamond$aes_params$colour <- self$options$color_summary_unused
    myplot$layers$group_Unused_diamond$aes_params$fill <- self$options$fill_summary_unused
    myplot$layers$group_Unused_diamond$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_unused)
  }

  if (!is.null(myplot$layers$group_Overall_PI)) {
    myplot$layers$group_Overall_PI$aes_params$colour <- self$options$color_summary_overall
    #myplot$layers$group_Overall_PI$aes_params$alpha <- as.numeric(self$options$alpha_summary_overall)
    myplot$layers$group_Overall_PI$aes_params$size <- as.numeric(self$options$size_interval_comparison) + 1
  }

  if (!is.null(myplot$layers$group_Comparison_PI)) {
    myplot$layers$group_Comparison_PI$aes_params$colour <- self$options$color_summary_comparison
    #myplot$layers$group_Comparison_PI$aes_params$alpha <- as.numeric(self$options$alpha_summary_comparison)
    myplot$layers$group_Comparison_PI$aes_params$size <- as.numeric(self$options$size_interval_comparison) + 1
  }

  if (!is.null(myplot$layers$group_Reference_PI)) {
    myplot$layers$group_Reference_PI$aes_params$colour <- self$options$color_summary_reference
    #myplot$layers$group_Reference_PI$aes_params$alpha <- as.numeric(self$options$alpha_summary_reference)
    myplot$layers$group_Reference_PI$aes_params$size <- as.numeric(self$options$size_interval_reference) + 1
  }

  if (!is.null(myplot$layers$group_Unused_PI)) {
    myplot$layers$group_Unused_P$aes_params$colour <- self$options$color_summary_unused
    #myplot$layers$group_Unused_PI$aes_params$alpha <- as.numeric(self$options$alpha_summary_unused)
    myplot$layers$group_Unused_PI$aes_params$size <- as.numeric(self$options$size_interval_unused) + 1
  }


  # Basic graph options --------------------
  # Axis font sizes
  axis.text.y <- self$options$axis.text.y
  axis.text.x <- self$options$axis.text.x
  axis.title.x <- self$options$axis.title.x

  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = axis.text.y),
    axis.text.x = ggtext::element_markdown(size = axis.text.x),
    axis.title.x = ggtext::element_markdown(size = axis.title.x)
  )


  xlim <- c(NA, NA)

  if (!(options$xmin %in% c("auto", "Auto", "AUTO", ""))) {
    try(xlim[[1]] <- as.numeric(options$xmin))
  }

  if (!(options$xmax %in% c("auto", "Auto", "AUTO", ""))) {
    try(xlim[[2]] <- as.numeric(options$xmax))
  }

  xbreaks <- NULL
  if (!(options$xbreaks %in% c("auto", "Auto", "AUTO", ""))) {
    try(xbreaks <- as.numeric(options$xbreaks))
    if (is.na(xbreaks)) xbreaks <- NULL
  }


  if (!(options$xlab %in% c("auto", "Auto", "AUTO", ""))) {
    xlab_replace <- options$xlab
  }


  # Apply axis labels and scales
  myplot <- myplot + ggplot2::scale_x_continuous(
    name = xlab_replace,
    limits = xlim,
    n.breaks = xbreaks,
    position = "top"
  )

  if (has_moderator) {
    dlab <- "Difference axis"
    if (!(options$dlab %in% c("auto", "Auto", "AUTO", ""))) {
      dlab <- options$dlab
    }


    dlim <- c(NA, NA)

    if (!(options$dmin %in% c("auto", "Auto", "AUTO", ""))) {
      try(dlim[[1]] <- as.numeric(options$dmin))
    }

    if (!(options$xmax %in% c("auto", "Auto", "AUTO", ""))) {
      try(dlim[[2]] <- as.numeric(options$dmax))
    }

    dbreaks <- NULL
    if (!(options$dbreaks %in% c("auto", "Auto", "AUTO", ""))) {
      try(dbreaks <- as.numeric(options$dbreaks))
      if (is.na(dbreaks)) dbreaks <- NULL
    }

    myplot <- esci::esci_plot_difference_axis_x(
      myplot,
      es_meta_difference,
      dlim = dlim,
      d_n.breaks = dbreaks,
      d_lab = dlab
    )
  }



  return(myplot)
}


printmydf <- function(mydf) {

  if (is.null(mydf)) return()

  if (nrow(mydf) <1) return()

  printed <- paste(colnames(mydf), collapse = ",     ")

  for (x in 1:nrow(mydf)) {
    next_row <- paste(mydf[x, ], collapse = ",    ")

    printed <- paste(
      printed,
      next_row,
      sep = "<BR>"
    )
  }

  return(printed)
}
