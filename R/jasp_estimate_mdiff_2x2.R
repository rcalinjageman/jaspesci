jasp_estimate_mdiff_2x2 <- function(jaspResults, dataset = NULL, options, ...) {

  self <- list()
  self$options <- options

  # Handles ------------------------------------
  from_raw <- options$switch == "from_raw"
  mixed <- (self$options$design == "mixed")
  effect_size <- self$options$effect_size
  assume_equal_variance <- self$options$assume_equal_variance
  is_mean <- if (options$effect_size == "mean_difference") TRUE else FALSE
  tbl_overview <- "overview"


  evaluate_h <- options$evaluate_hypotheses
  is_interval <- if (options$null_boundary > 0) TRUE else FALSE
  neg_errors <- FALSE

  # --------------------- ready ---------------------
  ready <- FALSE

  if (mixed) {
    ready <- (options$outcome_variable_level1 != "") & (options$outcome_variable_level2 != "")
  } else {
    if (from_raw) {
      ready <- (options$grouping_variable_A != "") & (options$grouping_variable_B != "") & (options$outcome_variable != "")
    } else {
      # need any checks for summary data?
      ready <- TRUE
      options$effect_size <- "mean_difference"
    }
  }


  # -- read data and set errors ---------------------------------
  if (mixed) {
    if (ready) {
      # read dataset
      dataset <- jasp_estimate_mdiff_2x2_mixed_read_data(dataset, options)

      # need to add error checks

    }

  } else {
    if (from_raw) {
      if (ready) {
        # read dataset
        dataset <- jasp_estimate_mdiff_2x2_between_read_data(dataset, options)

        # need to add error checks
      }
    } else {
      if (ready) {
        # summary data, so no need to read data
        # add error checks?
      }
    }
  }


  # run analysis ------------------------------

  if (ready) {
    # Run the analysis
    args <- list()

    if (mixed) {
      call <- esci::estimate_mdiff_2x2_mixed
      args$data <- dataset
      args$conf_level <- self$options$conf_level
      args$grouping_variable <- self$options$grouping_variable
      args$outcome_variable_level1 <- self$options$outcome_variable_level1
      args$outcome_variable_level2 <- self$options$outcome_variable_level2
      args$outcome_variable_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "My outcome variable"
      )
      args$repeated_measures_name <- jasp_text_fix(
        options,
        "repeated_measures_name",
        "Time"
      )
    } else {

      if (from_raw) {
        call <- esci::estimate_mdiff_2x2_between
        args$data <- dataset
        args$assume_equal_variance <- self$options$assume_equal_variance
        args$conf_level <- self$options$conf_level
        args$grouping_variable_A <- self$options$grouping_variable_A
        args$grouping_variable_B <- self$options$grouping_variable_B
        args$outcome_variable <- self$options$outcome_variable

      } else {
        call <- esci::estimate_mdiff_2x2_between

        args$assume_equal_variance <- self$options$assume_equal_variance
        args$conf_level <- self$options$conf_level

        args$means <- c(
          options$A1B1_mean,
          options$A1B2_mean,
          options$A2B1_mean,
          options$A2B2_mean
        )

        args$sds <- c(
          options$A1B1_sd,
          options$A1B2_sd,
          options$A2B1_sd,
          options$A2B2_sd
        )

        args$ns <- c(
          options$A1B1_n,
          options$A1B2_n,
          options$A2B1_n,
          options$A2B2_n
        )

        args$grouping_variable_A_levels <- c(
          jasp_text_fix(options, "A1_label", "A1 level"),
          jasp_text_fix(options, "A2_label", "A2 level")
        )

        args$grouping_variable_B_levels <- c(
          jasp_text_fix(options, "B1_label", "B1 level"),
          jasp_text_fix(options, "B2_label", "B2 level")
        )

        args$grouping_variable_A_name <- jasp_text_fix(
          options,
          "A_label",
          "Variable A"
        )

        args$grouping_variable_B_name <- jasp_text_fix(
          options,
          "B_label",
          "Variable B"
        )

        args$outcome_variable_name <- jasp_text_fix(
          options,
          "outcome_variable_name_bs",
          "My outcome variable"
        )

      }

    }

    # debugtext <- createJaspHtml(text = paste(names(args), args, collapse = "<BR>"))
    # debugtext$dependOn(jasp_mdiff_table_depends_on())
    # jaspResults[["debugtext"]] <- debugtext

    estimate <- try(do.call(what = call, args = args))

    # debugtext <- createJaspHtml(text = paste(estimate, collapse = "<BR>"))
    # debugtext$dependOn(jasp_mdiff_table_depends_on())
    # jaspResults[["debugtextestimate"]] <- debugtext



    # --- fix stuff ----------------------------------
    # Fixed that should be incorporated into esci
    # Add in MoE
    estimate$es_mean_difference$moe <- (estimate$es_mean_difference$UL - estimate$es_mean_difference$LL)/2
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2
    estimate$overview$s_pooled <- estimate$es_smd$denominator[[1]]
    estimate$es_mean_difference$s_component <- estimate$es_smd$denominator[[1]]

    estimate$es_mean_difference$effect_type <- paste(
      "<b>",
      estimate$es_mean_difference$effect_type,
      "</b>"
    )

    estimate$es_mean_difference$effects_complex[c(3, 6, 9, 12, 15)] <- paste(
      "<b>",
      estimate$es_mean_difference$effects_complex[c(3, 6, 9, 12, 15)],
      "</b>"
    )

    if (!is.null(estimate$es_median_difference)) {
      estimate$es_median_difference$effect_type <- paste(
        "<b>",
        estimate$es_median_difference$effect_type,
        "</b>"
      )

      estimate$es_median_difference$effects_complex[c(3, 6, 9, 12, 15)] <- paste(
        "<b>",
        estimate$es_median_difference$effects_complex[c(3, 6, 9, 12, 15)],
        "</b>"
      )

    }

    if (effect_size == "mean_difference" & !mixed) {
      mysep <- if (is.null(estimate$overview_properties$message_html)) NULL else "<BR>"
      if (!is.null(tbl_overview) & !is.null(assume_equal_variance)) {
        if (assume_equal_variance) {
          estimate$overview_properties$message_html <- paste(
            estimate$overview_properties$message_html,
            mysep,
            "Variances are assumed equal, so <i>s</i><sub>p</sub> was used to calculate each CI."
          )
        } else {
          estimate$overview_properties$message_html <- paste(
            estimate$overview_properties$message_html,
            mysep,
            "Variances are not assumed equal, and so the CI was calculated separately for each mean."
          )
        }
      }
    }


    # --- hypothesis eval -----------------------------
    if(evaluate_h & is.null(jaspResults[["heTable"]])) {

      effect_size = self$options$effect_size
      if (effect_size == "mean_difference") effect_size <- "mean"
      if (effect_size == "median_difference") effect_size <- "median"

      rope_upper <- self$options$null_boundary
      rope_units <- "raw"
      try(rope_units <- self$options$rope_units)

      estimate$point_null <- NULL
      estimate$interval_null <- NULL

      for (myestimate in estimate) {
        if(is(myestimate, "esci_estimate")) {

          test_results <- test_mdiff(
            myestimate,
            effect_size = effect_size,
            rope = c(rope_upper * -1, rope_upper),
            rope_units = rope_units,
            output_html = TRUE
          )

          estimate$point_null <- rbind(
            estimate$point_null,
            test_results$point_null
          )

          estimate$interval_null <- rbind(
            estimate$interval_null,
            test_results$interval_null
          )

        }
      }


      if (!is.null(estimate$point_null)) {
        estimate$point_null$conclusion[[5]] <- gsub(
          pattern = "diff",
          replacement = "diffdiff",
          x = estimate$point_null$conclusion[[5]]
        )
      }
      if (!is.null(estimate$interval_null)) {
        estimate$interval_null$conclusion[[5]] <- gsub(
          pattern = "diff",
          replacement = "diffdiff",
          x = estimate$interval_null$conclusion[[5]]
        )
      }

      estimate$point_null$effect_type <- estimate$es_smd$effect_type
      estimate$point_null$effects_complex <- estimate$es_smd$effects_complex
      estimate$interval_null$effect_type <- estimate$es_smd$effect_type
      estimate$interval_null$effects_complex <- estimate$es_smd$effects_complex

    }

  }

  # ------------ outputs ---------------------------------

  # Overview
  if (is.null(jaspResults[["overviewTable"]])) {
    jasp_overview_complex_prep(
      jaspResults,
      options,
      ready
    )

    if (ready) {
      jasp_table_fill(
        jaspResults[["overviewTable"]],
        estimate,
        "overview"
      )
    }
  }

  # Define and fill out the m_diff table (mean or median)
  if (is.null(jaspResults[["es_m_differenceTable"]])) {

    jasp_es_m_difference_prep(
      jaspResults,
      options,
      ready,
      estimate
    )

    to_fill <- if (is_mean) "es_mean_difference" else "es_median_difference"

    if (ready) jasp_table_fill(
      jaspResults[["es_m_differenceTable"]],
      estimate,
      to_fill
    )

  }

  return()

  # Define and fill the smd table
  if (is_mean & is.null(jaspResults[["smdTable"]]) ) {
    jasp_smd_prep(
      jaspResults,
      options,
      ready,
      estimate,
      one_group = FALSE
    )

    if (ready) jasp_table_fill(
      jaspResults[["smdTable"]],
      estimate,
      "es_smd"
    )

  }

  # Define and fill out the m_diff table (mean or median)
  if (options$show_ratio & from_raw & is.null(jaspResults[["es_m_ratioTable"]])) {
    if (isa(neg_errors, "logical")) {
      jasp_es_m_ratio_prep(
        jaspResults,
        options,
        ready,
        estimate,
        mylevels
      )

      to_fill <- if (is_mean) "es_mean_ratio" else "es_median_ratio"

      if (ready) jasp_table_fill(
        jaspResults[["es_m_ratioTable"]],
        estimate,
        to_fill
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

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )

  }


  # Now prep and fill the plot
  x <- 0
  for (my_variable in options$outcome_variable) {
    x <- x + 1
    my_variable <- options$outcome_variable[[x]]


    if (is.null(jaspResults[[my_variable]])) {
      jasp_plot_m_prep(
        jaspResults,
        options,
        ready,
        my_variable = my_variable,
        add_citation = if (x == 1) TRUE else FALSE
      )

      if (ready) {
        effect_size = options$effect_size
        if (effect_size == "mean_difference") effect_size <- "mean"
        if (effect_size == "median_difference") effect_size <- "median"

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

        if (evaluate_h) {
          args$rope <- c(
            options$null_value - options$null_boundary,
            options$null_value + options$null_boundary
          )
        }

         myplot <- do.call(
          what = esci::plot_mdiff,
          args = args
        )

        #apply aesthetics
        myplot <- jasp_plot_mdiff_decorate(myplot, options)

        jaspResults[[my_variable]]$plotObject <- myplot


      }  # end plot creation


    } # end check if plot is null
  } # end loop through outcome variables

  return()
}



jasp_estimate_mdiff_2x2_between_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = options$outcome_variable,
        columns.as.factor = c(options$grouping_variable_A, options$grouping_variable_B)
      )
    )
}



jasp_estimate_mdiff_2x2_mixed_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(
      .readDataSetToEnd(
        columns.as.numeric = c(options$outcome_variable_level1, options$outcome_variable_level2),
        columns.as.factor = c(options$grouping_variable)
      )
    )
}
