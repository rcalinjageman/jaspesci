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
    ready <- (options$outcome_variable_level1 != "") & (options$outcome_variable_level2 != "") & (options$grouping_variable != "")
  } else {
    if (from_raw) {
      ready <- (options$grouping_variable_A != "") & (options$grouping_variable_B != "") & (options$outcome_variable != "")
    } else {
      jasp_summary_dirty(options$summary_dirty, jaspResults)

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

          test_results <- esci::test_mdiff(
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

      estimate$to_fill <- if (rope_upper > 0) estimate$interval_null else estimate$point_null

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

    jaspResults[["overviewTable"]]$position <- 1

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
      if (ready) estimate else NULL
    )

    jaspResults[["es_m_differenceTable"]]$position <- 10

    to_fill <- if (is_mean) "es_mean_difference" else "es_median_difference"

    if (ready) jasp_table_fill(
      jaspResults[["es_m_differenceTable"]],
      estimate,
      to_fill
    )

  }

  # Define and fill the smd table
  if (is_mean & !mixed & is.null(jaspResults[["smdTable"]]) ) {
    jasp_smd_prep(
      jaspResults,
      options,
      ready,
      if (ready) estimate else NULL,
      one_group = FALSE
    )

    jaspResults[["smdTable"]]$position <- 20

    if (ready) jasp_table_fill(
      jaspResults[["smdTable"]],
      estimate,
      "es_smd"
    )

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

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      estimate,
      "to_fill"
    )

  }

  # Now prep and fill the plots

  plot_names <- c(
    "main_effect_A",
    "main_effect_B",
    "interaction"
  )

  x <- 0
  for (this_plot in plot_names) {
    x <- x + 1

    gvA <- if (!ready) "Variable A" else estimate$properties$grouping_variable_A_name

    gvB <- if (!ready) "Variable B" else estimate$properties$grouping_variable_B_name


    which_title <- switch(
      this_plot,
      "main_effect_A" = paste("Main Effect of", gvA),
      "main_effect_B" = paste("Main Effect of", gvB),
      "interaction" = paste("Interaction of", gvA, "and", gvB)
    )


    if (is.null(jaspResults[[this_plot]])) {
      jasp_plot_m_prep(
        jaspResults,
        options,
        ready,
        my_variable = this_plot,
        add_citation = if (x == 1) TRUE else FALSE,
        my_title = which_title
      )

      jaspResults[[this_plot]]$position <- 40 + x

      if (ready) {

        effect_size <- "mean"
        if (from_raw & !mixed & options$effect_size == "median_difference") effect_size <- "median"

        args <- list()
        args$estimate <- estimate[[this_plot]]
        args$effect_size <- effect_size
        args$data_layout <- options$data_layout
        args$data_spread <- options$data_spread
        args$error_layout <- options$error_layout
        args$error_scale <- options$error_scale
        args$error_nudge <- options$error_nudge

        args$difference_axis_units <- self$options$difference_axis_units

        args$difference_axis_breaks <- jasp_numeric_fix(options, "difference_axis_breaks", 5)
        if (args$difference_axis_breaks < 2) args$difference_axis_breaks <- 2
        if (args$difference_axis_breaks > 50) args$difference_axies_breaks <- 50

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

        if (evaluate_h) {
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

        #apply aesthetics
        myplot <- jasp_plot_mdiff_decorate(myplot, options)

         mylabs <- paste(
           estimate$overview$grouping_variable_B_level,
           " - ",
           estimate$overview$grouping_variable_A_level,
           sep = ""
         )


         if (this_plot != "interaction") {
           mylabs <- c(
             mylabs,
             paste(" \n", myplot$scales$scales[[2]]$labels[5:7],  sep = "")
           )
         } else {
           mylabs <- c(
             mylabs,
             "Difference of\ndifferences"
             #myplot$scales$scales[[2]]$labels[5:5]
           )

           if (!is.null(myplot$layers["simple_effect_points"])) {
             try(myplot$layers[["simple_effect_points"]]$aes_params$fill <- "white")
             try(myplot$layers[["simple_effect_points"]]$aes_params$shape <- 23)
             try(myplot$layers[["simple_effect_points"]]$aes_params$size <- as.numeric(options$size_summary_reference) +1 )
           }
           if (!is.null(myplot$layers$simple_effect_lines)) {
             try(myplot$layers$simple_effect_lines$aes_params$size <- as.numeric(options$size_interval_reference))
           }
         }

         myplot$scales$scales[[2]]$labels <- mylabs
         myplot <- myplot + ggplot2::guides(x = ggh4x::guide_axis_nested(delim = " - "))

        jaspResults[[this_plot]]$plotObject <- myplot


      }  # end plot creation


    } # end check if plot is null
  } # end loop through outcome variables


  if (options$show_interaction_plot & is.null(jaspResults[["interaction_plot"]])) {

    mdiffPlot <- createJaspPlot(
      title = "Figure Emphasizing Interaction",
      width = options$width,
      height = options$height
    )

    mdiffPlot$dependOn(
      c(
        jasp_mdiff_table_depends_on(),
        jasp_plot_depend_on(),
        "show_CI",
        "show_interaction_plot"
      )
    )

    jaspResults[["interaction_plot"]] <- mdiffPlot

    jaspResults[["interaction_plot"]]$position <- 50

      if (ready) {

        self <- list()
        self$options <- options

        effect_size <- "mean"
        if (from_raw & !mixed & options$effect_size == "median_difference") effect_size <- "median"

        myplot <- esci::plot_interaction(
          estimate,
          effect_size = effect_size,
          show_CI = options$show_CI,
          line_count = 125,
          line_alpha = 0.03
        )

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

        myplot <- myplot + ggplot2::scale_y_continuous(
          limits = ylim,
          n.breaks = ybreaks
        )

        myplot <- myplot + ggplot2::theme(
          axis.text.y = ggtext::element_markdown(size = options$axis.text.y),
          axis.title.y = ggtext::element_markdown(size = options$axis.title.y),
          axis.text.x = ggtext::element_markdown(size = options$axis.text.x),
          axis.title.x = ggtext::element_markdown(size = options$axis.title.x),
          legend.title = ggtext::element_markdown(size = options$axis.title.x),
          legend.text = ggtext::element_markdown(size = options$axis.text.x)
        )

        # Aesthetics
        myplot <- myplot + ggplot2::scale_shape_manual(
          values = c(
            self$options$shape_summary_reference,
            self$options$shape_summary_comparison
          )
        )

        myplot <- myplot + ggplot2::scale_color_manual(
          values = c(
            self$options$color_summary_reference,
            self$options$color_summary_comparison
          )
        )

        myplot <- myplot + ggplot2::scale_fill_manual(
          values = c(
            self$options$fill_summary_reference,
            self$options$fill_summary_comparison
          )
        )

        myplot <- myplot + ggplot2::scale_size_manual(
          values = c(
            as.integer(self$options$size_summary_reference),
            as.integer(self$options$size_summary_comparison)
          )
        )

        myplot <- myplot + ggplot2::scale_alpha_manual(
          values = c(
            1 - as.numeric(self$options$alpha_summary_reference),
            1 - as.numeric(self$options$alpha_summary_comparison)
          )
        )

        myplot <- myplot + ggplot2::scale_linetype_manual(
          values = c(
            self$options$linetype_summary_reference,
            self$options$linetype_summary_comparison
          )
        )

        # Axis options
        if (!(options$ylab %in% c("auto", "Auto", "AUTO", ""))) {
          myplot <- myplot + ggplot2::ylab(options$ylab)
        }

        if (!(options$xlab %in% c("auto", "Auto", "AUTO", ""))) {
          myplot <- myplot + ggplot2::xlab(options$xlab)
        }


        myplot$layers[["simple_effect_lines"]]$aes_params$linewidth <- as.numeric(self$options$size_interval_reference)/3

        jaspResults[["interaction_plot"]]$plotObject <- myplot

      }

    }

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
