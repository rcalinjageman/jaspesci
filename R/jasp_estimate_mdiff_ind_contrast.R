jasp_estimate_mdiff_ind_contrast <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles --------------------------------------------------------
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses
  is_interval <- if (options$null_boundary > 0) TRUE else FALSE
  level_errors <- FALSE
  is_mean <- !from_raw | (options$effect_size == "mean_difference")
  ov_name <- NULL


  # Check readiness ------------------------------------------
  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0) & (options$grouping_variable != "")
  } else {
    ready <- (options$means != "") & (options$sds != "") & (options$ns != "") & (options$grouping_variable_levels != "")
    # Over-ride effect size if summary data is being analyzed
    if (ready) options$effect_size <- "mean_difference"
  }


  # read dataset --------------------------------------------
  if (ready & !from_raw) {
    dataset <- jasp_estimate_mdiff_ind_contrast_summary_read_data(dataset, options)
    level_source <- options$grouping_variable_levels
    valid_levels <- dataset[which(!is.na(dataset[, level_source])) , level_source]
  }

  if (from_raw & ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_ind_contrast_raw_read_data(dataset, options)
    level_source <- options$grouping_variable
    valid_levels <- levels(as.factor(dataset[, level_source]))

    # check for errors
    # At least 2 levels in grouping variable
    .hasErrors(
      dataset = dataset,
      type = "factorLevels",
      factorLevels.target  = options$grouping_variable,
      factorLevels.amount  = "< 2",
      exitAnalysisIfErrors = TRUE
    )

    # at least 2 observations in each level of each outcome variable
    .hasErrors(
      dataset = dataset,
      type = c("observations", "variance", "infinity"),
      all.grouping = options$grouping_variable,
      all.target = options$grouping_variable,
      observations.amount  = "< 3",
      exitAnalysisIfErrors = TRUE
    )
  }

  # Check contrast --------------------------------------------------
  clabels <- options$comparison_labels
  rlabels <- options$reference_labels
  contrast <- NULL

  if (ready) {
    reference_result <- jamovi_check_contrast(
      labels = rlabels,
      valid_levels = valid_levels,
      level_source = level_source,
      group_type = "Reference",
    )

    if (!is.null(reference_result$error_string)) {
      r_error <- createJaspHtml(
        reference_result$error_string
      )
      r_error$dependOn(c("grouping_variable", "grouping_variable_levels", "reference_labels", "comparison_labels"))
      jaspResults[["reference_error"]] <- r_error
      jaspResults[["reference_error"]]$position <- -10
    } else {
      jaspResults[["reference_error"]] <- NULL
    }

    # Same, but with comparison labels
    comparison_result <- jamovi_check_contrast(
      labels = clabels,
      valid_levels = valid_levels,
      level_source = level_source,
      group_type = "Comparison",
      sequential = !is.null(reference_result$error_string)
    )


    if (!is.null(comparison_result$error_string)) {
      c_error <- createJaspHtml(
        comparison_result$error_string
      )
      c_error$dependOn(c("grouping_variable", "grouping_variable_levels", "reference_labels", "comparison_labels"))
      jaspResults[["comparison_error"]] <- c_error
      jaspResults[["comparison_error"]]$position <- -5
    } else {
      jaspResults[["comparison_error"]] <- NULL
    }

    overlap <- reference_result$label %in% comparison_result$label

    if (length(reference_result$label[overlap]) != 0) {
      o_error <- createJaspHtml(
        paste(
          "<b>Error</b>: Reference and comparison subsets must be distinct, but ",
          paste(reference_result$label[overlap], collapse = ", "),
          "has been entered in both."
        )
      )
      o_error$dependOn(c("grouping_variable", "grouping_variable_levels", "reference_labels", "comparison_labels"))
      jaspResults[["o_error"]] <- o_error
      jaspResults[["o_error"]]$position <- 0
    } else {
      jaspResults[["o_error"]] <- NULL
    }

    if (clabels != "" & rlabels != "" & is.null(jaspResults[["reference_error"]]) & is.null(jaspResults[["comparison_error"]]) & is.null(jaspResults[["o_error"]])  ) {
          contrast <- jamovi_create_contrast(reference_result$label, comparison_result$label)
    }

  }

  # debugtext <- createJaspHtml(text = paste(names(contrast), contrast, collapse = "<BR>"), title = "Contrast")
  # debugtext$dependOn(c("grouping_variable", "grouping_variable_levels", "comparison_labels", "reference_labels"))
  # jaspResults[["contrasttext"]] <- debugtext


  # Run the analysis --------------------------------------------------------
  if (ready) {
    # Run the analysis
    args <- list()
    self <- list()
    self$options <- options

    call <- esci::estimate_mdiff_ind_contrast

    args$conf_level <- self$options$conf_level
    args$assume_equal_variance <- self$options$assume_equal_variance
    args$contrast <- contrast

    if (from_raw) {
      args$data <- dataset
      args$outcome_variable <- unname(self$options$outcome_variable)
      args$grouping_variable <- unname(self$options$grouping_variable)
      args$grouping_variable_name <- unname(self$options$grouping_variable)
      args$switch_comparison_order <- self$options$switch_comparison_order
      args$save_raw_data <- TRUE
    } else {
      group_labels <- dataset[, self$options$grouping_variable_levels]
      valid_rows <- which(!is.na(group_labels))

      if(length(valid_rows) != length(group_labels)) {
        msg <- glue::glue("
There are {length(group_labels) - length(valid_rows)} empty values
in {self$options$grouping_variable_levels}.  Rows with empty group labels have been
**dropped** from the analysis
                    ")

        blank_error <- createJaspHtml(
          msg,
          title = "Empty group label rows"
        )
        blank_error$dependOn(c("grouping_variable_levels"))
        jaspResults[["blank_error"]] <- blank_error

      }


      args$means <- dataset[valid_rows, self$options$means]
      args$sds <- dataset[valid_rows, self$options$sds]
      args$ns <- dataset[valid_rows, self$options$ns]
      args$grouping_variable_levels <- as.character(group_labels[valid_rows])

      args$outcome_variable_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )

      args$grouping_variable_name <- jasp_text_fix(
        options,
        "grouping_variable_name",
        "Grouping variable"
      )
    }

    estimate <- try(do.call(what = call, args = args))


    # Add in MoE
    estimate$overview_adjusted <- estimate$overview
    estimate$es_mean_difference_adjusted <- estimate$es_mean_difference

    if (!is.null(contrast)) {
       estimate$es_mean_difference_adjusted$moe <- (estimate$es_mean_difference_adjusted$UL - estimate$es_mean_difference_adjusted$LL)/2
    }
     estimate$overview_adjusted$moe <- (estimate$overview_adjusted$mean_UL - estimate$overview_adjusted$mean_LL)/2


    estimate_big <- estimate
    estimate$raw_data <- NULL
    if (from_raw) {
      for (myvariable in options$outcome_variable) {
        estimate[[myvariable]] <- NULL
      }
      ov_name <- options$outcome_variable
    } else {

      ov_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )
      estimate[[ov_name]] <- estimate
    }


    if(evaluate_h & is.null(jaspResults[["heTable"]]) & !is.null(contrast)) {
      mytest <- jasp_test_mdiff(
        options,
        estimate
      )
    } else {
      mytest <- NULL
    }

  } else {
    estimate <- NULL
    estimate_big <- NULL
  }


  # Overview
  if (is.null(jaspResults[["overviewTable"]])) {
    jasp_overview_prep(
      jaspResults,
      options,
      ready,
      if (ready) estimate else NULL,
      level = 2
    )

    jaspResults[["overviewTable"]]$position <- 1

    if (ready) {
      jasp_table_fill(
        jaspResults[["overviewTable"]],
        estimate,
        "overview_adjusted"
      )
    }
  }


  # Define and fill out the m_diff table (mean or median)
  if (is.null(jaspResults[["es_m_differenceTable"]])) {

    jasp_es_m_difference_prep(
      jaspResults,
      options,
      ready,
      if (ready) estimate else NULL
    )

    jaspResults[["es_m_differenceTable"]]$position <- 10

    to_fill <- if (is_mean) "es_mean_difference_adjusted" else "es_median_difference"

    if (ready & !is.null(contrast)) {
        jasp_table_fill(
          jaspResults[["es_m_differenceTable"]],
          estimate,
          to_fill
        )
    }

  }

  # Define and fill the smd table
  if (is_mean & is.null(jaspResults[["smdTable"]]) ) {
    jasp_smd_prep(
      jaspResults,
      options,
      ready,
      if (ready) estimate else NULL,
      one_group = FALSE
    )

    jaspResults[["smdTable"]]$position <- 20

    if (ready & !is.null(contrast)) {
      jasp_table_fill(
        jaspResults[["smdTable"]],
        estimate,
        "es_smd"
      )
    }

  }
  # Hypothesis evaluation table and smd table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest
    )

    jaspResults[["heTable"]]$position <- 30

    if (ready & !is.null(contrast)) {
      jasp_table_fill(
        jaspResults[["heTable"]],
        mytest,
        "to_fill"
      )
    }
  }

  # Now prep and fill the plot ----------------------------------
  x <- 0
  for (my_variable in ov_name) {
    x <- x + 1

    if (is.null(jaspResults[[my_variable]])) {
      jasp_plot_m_prep(
        jaspResults,
        options,
        ready,
        my_variable = my_variable,
        add_citation = if (x == 1) TRUE else FALSE
      )

      jaspResults[[my_variable]]$position <- 40+x

      if (ready) {
        effect_size = options$effect_size
        if (effect_size == "median_difference") effect_size <- "median"
        if (effect_size == "mean_difference" | !from_raw) effect_size <- "mean"

        args <- list()
        if (from_raw) {
          if (length(options$outcome_variable) == 1) {
            args$estimate <- estimate_big
          } else {
            args$estimate <- estimate_big[[my_variable]]
          }
        } else {
          args$estimate <- estimate[[my_variable]]
        }
        args$effect_size <- effect_size
        args$data_layout <- options$data_layout
        args$data_spread <- options$data_spread
        args$error_layout <- options$error_layout
        args$error_scale <- options$error_scale
        args$error_nudge <- options$error_nudge

        args$difference_axis_units <- self$options$difference_axis_units

        difference_axis_breaks <- NULL
        if (!(options$difference_axis_breaks %in% c("auto", "Auto", "AUTO", ""))) {
          try(difference_axis_breaks <- as.numeric(options$difference_axis_breaks))
          if (is.na(difference_axis_breaks)) difference_axis_breaks <- NULL
        }

        args$difference_axis_breaks <- difference_axis_breaks
        args$difference_axis_space <- 0.5
        args$simple_contrast_labels <- self$options$simple_contrast_labels

        ylim <- c(NA, NA)

        if (!(options$ymin %in% c("auto", "Auto", "AUTO", ""))) {
          try(ylim[[1]] <- as.numeric(options$ymin))
        }

        if (!(options$ymax %in% c("auto", "Auto", "AUTO", ""))) {
          try(ylim[[2]] <- as.numeric(options$ymax))
        }

        ybreaks <- NULL
        if (!(options$ybreaks %in% c("auto", "Auto", "AUTO", ""))) {
          try(ybreaks <- as.numeric(options$ybreaks))
          if (is.na(ybreaks)) ybreaks <- NULL
        }

        args$ylim <- ylim
        args$ybreaks <- ybreaks
        args$difference_axis_breaks <- self$options$difference_axis_breaks
        args$difference_axis_units <- self$options$difference_axis_units
        args$difference_axis_space <- 0.5
        args$simple_contrast_labels <- self$options$simple_contrast_labels

        if (evaluate_h & !is.null(contrast)) {
          args$rope <- c(
            options$null_value - options$null_boundary,
            options$null_value + options$null_boundary
          )

          args$rope_units <- "raw"
          try(args$rope_units <- self$options$rope_units, silent = TRUE)
        }

         myplot <- do.call(
          what = esci::plot_mdiff,
          args = args
        )

        # #apply aesthetics
        myplot <- jasp_plot_mdiff_decorate(myplot, options, has_contrast = !is.null(contrast))

        jaspResults[[my_variable]]$plotObject <- myplot


      }  # end plot creation


    } # end check if plot is null
  } # end loop through outcome variables

  return()
}



jasp_estimate_mdiff_ind_contrast_raw_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = options$outcome_variable,
        columns.as.factor = options$grouping_variable
      )
    )
}



jasp_estimate_mdiff_ind_contrast_summary_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = c(options$means, options$sds, options$ns),
        columns.as.factor = options$grouping_variable_levels
      )
    )
}
