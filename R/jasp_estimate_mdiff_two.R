jasp_estimate_mdiff_two <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses
  is_interval <- if (options$null_boundary > 0) TRUE else FALSE
  neg_errors <- FALSE


  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0) & (options$grouping_variable != "")
  } else {
    # Need any summary data checks?  Maybe not
    ready <- TRUE
    # Over-ride effect size if summary data is being analyzed
    options$effect_size <- "mean_difference"
    # Also over-ride request to show ratio
    options$show_ratio <- FALSE
  }

  is_mean <- if (options$effect_size == "mean_difference") TRUE else FALSE


  if (from_raw & ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_two_read_data(dataset, options)


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


    # More than 2 levels in grouping variable
    levels <- levels(dataset[[options$grouping_variable]])

    level_errors <- .hasErrors(
      dataset = dataset,
      type = "factorLevels",
      factorLevels.target  = options$grouping_variable,
      factorLevels.amount  = "> 2",
      exitAnalysisIfErrors = FALSE
    )

    if (isa(level_errors, "list")) {
      error_explain <- paste(
        "The grouping variable (",
        options$grouping_variable,
        ") had ",
        length(levels),
        " levels.  Only the first 2 levels were used for effect-size calculations.",
        sep = ""
      )

      lerror_text <- createJaspHtml(
        paste(
          level_errors,
          error_explain,
          sep = "<BR>"
        ),
        title = "Warning!"
      )
      # To do: why does depenOn throw an error?
      lerror_text$dependOn(c("outcome_variable", "grouping_variable"))
      jaspResults[["level_errors"]] <- lerror_text
    }


    # If show_ratio, no negative values

    if (options$show_ratio) {
      neg_errors <- .hasErrors(
        dataset = dataset,
        type = c("negativeValues"),
        all.target = options$outcome_variable,
        exitAnalysisIfErrors = FALSE
      )

      if (isa(neg_errors, "list")) {
        error_text <- createJaspHtml(
          paste(
            neg_errors,
            "The ratio between group effect size is appropriate only for true ratio scales where values < 0 are impossible.  One or more of your outcome variables includes at least one negative value, so the requested ratio effect size is not reported.",
            sep = "<BR>"
          ),
          title = "Warning!"
        )
        error_text$dependOn(c("outcome_variable", "grouping_variable", "show_ratio"))
        jaspResults[["neg_errors"]] <- error_text
      }
    }

  }


  if (ready) {
    # Run the analysis
    args <- list()
    self <- list()
    self$options <- options

    call <- esci::estimate_mdiff_two
    args$conf_level <- self$options$conf_level
    args$assume_equal_variance <- self$options$assume_equal_variance

    if (from_raw) {
      args$data <- dataset
      args$outcome_variable <- unname(self$options$outcome_variable)
      args$grouping_variable <- unname(self$options$grouping_variable)
      args$grouping_variable_name <- unname(self$options$grouping_variable)
      args$switch_comparison_order <- self$options$switch_comparison_order
      args$save_raw_data <- TRUE
    } else {

      args$reference_mean <- self$options$reference_mean
      args$reference_sd <- self$options$reference_sd
      args$reference_n <- self$options$reference_n
      args$comparison_mean <- options$comparison_mean
      args$comparison_sd <- self$options$comparison_sd
      args$comparison_n <- self$options$comparison_n

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

      args$grouping_variable_levels <- c(
        jasp_text_fix(
          options,
          "reference_level_name",
          "Reference group"
        ),
        jasp_text_fix(
          options,
          "comparison_level_name",
          "Comparison group"
        )
      )

    }

    estimate <- try(do.call(what = call, args = args))


    # Some results tweaks - future updates to esci will do these calcs within esci rather than here
    # Add in MoE
    estimate$es_mean_difference$moe <- (estimate$es_mean_difference$UL - estimate$es_mean_difference$LL)/2
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2

    # Add calculation details
    alpha <- 1 - self$options$conf_level
    estimate$es_mean_difference$t_multiplier <- stats::qt(1-alpha/2, estimate$es_mean_difference$df)

    # Fix sp and other calculation components
    for (x in 1:nrow(estimate$es_smd)) {
      estimate$overview[estimate$overview$outcome_variable_name == estimate$es_smd$outcome_variable_name[[x]], "s_pooled"] <- estimate$es_smd$denominator[[x]]
      estimate$es_mean_difference$s_component[c(x*3-2, x*3-1, x*3-0)] <- estimate$es_smd$denominator[[x]]
    }
    estimate$es_mean_difference$n_component <- estimate$es_mean_difference$SE / estimate$es_mean_difference$s_component


    estimate_big <- estimate
    estimate$raw_data <- NULL
    if (from_raw) {
      for (myvariable in options$outcome_variable) {
        estimate[[myvariable]] <- NULL
      }
    } else {

      ov_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )

      estimate[[ov_name]] <- estimate
      options$outcome_variable <- ov_name
    }


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
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
      estimate,
      level = length(levels)
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
        levels
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
    my_variable <- options$outcome_variable[[1]]


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



jasp_estimate_mdiff_two_read_data <- function(dataset, options) {
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


jasp_plot_mdiff_decorate <- function(myplot, options) {

  # make compatible with jamovi code
  self <- list()
  self$options <- options

  effect_size <- "mean"
  from_raw <- TRUE  # (self$options$switch == "from_raw")
  plot_median <- FALSE
  if (from_raw) {
    try(plot_median <- (self$options$effect_size == "median_difference"), silent = TRUE)
  }
  if (from_raw & plot_median) effect_size <- "median"

  divider <- 1
  if (effect_size == "median") divider <- 4

  interval_null <- FALSE
  htest <- FALSE
  try(htest <- self$options$evaluate_hypotheses, silent = TRUE)


  if (htest) {
    myplot$layers[["null_line"]]$aes_params$colour <- self$options$null_color
    if (interval_null) {
      try(myplot$layers[["null_interval"]]$aes_params$fill <- self$options$null_color, silent = TRUE)

      try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(self$options$size_interval_difference)/divider+1, silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(self$options$alpha_interval_difference), silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- self$options$color_interval_difference, silent = TRUE)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- self$options$self$options$linetype_summary_difference, silent = TRUE)

      if (plot_median) {
        try(myplot$layers[["ta_CI"]]$aes_params$colour <- self$options$color_summary_difference, silent = TRUE)
        try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(self$options$size_summarydifference)/divider*1.3, silent = TRUE)
        try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(self$options$alpha_summary_difference), silent = TRUE)
        try(myplot$layers[["ta_CI"]]$aes_params$linetype <- self$options$self$options$linetype_summary_difference, silent = TRUE)
      }

    }
  }

  # Basic graph options --------------------
  # Font sizes
  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = options$axis.text.y),
    axis.title.y = ggtext::element_markdown(size = options$axis.title.y),
    axis.text.x = ggtext::element_markdown(size = options$axis.text.x),
    axis.title.x = ggtext::element_markdown(size = options$axis.title.x)
  )

  # Axis options
  if (!(options$ylab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::ylab(options$ylab)
  }

  if (!(options$xlab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::xlab(options$xlab)
  }


  shape_raw_reference <- "circle"
  color_raw_reference <- "black"
  fill_raw_reference <- "black"
  size_raw_reference <- 1
  alpha_raw_reference <- 1

  shape_raw_difference <- "circle"
  color_raw_difference <- "black"
  fill_raw_difference <- "black"
  size_raw_difference <- 1
  alpha_raw_difference <- 1

  shape_raw_unused <- "circle"
  shape_summary_unused <- "circle"
  color_raw_unused <- "black"
  color_summary_unused <- "black"
  fill_raw_unused <- "black"
  fill_summary_unused <- "black"
  size_raw_unused <- 1
  size_summary_unused <- 1
  alpha_raw_unused <- 1
  alpha_summary_unused <- 1
  alpha_error_reference <- 1
  linetype_summary_unused <- "solid"
  linetype_summary_reference <- "solid"
  color_interval_unused <- "black"
  color_interval_reference <- "black"
  alpha_interval_unused <- 1
  alpha_interval_reference <- 1
  size_interval_unused <- 1
  size_interval_reference <- 1
  fill_error_unused <- "black"
  fill_error_reference <- "black"
  alpha_error_unused <- 1

  try(shape_raw_difference <- self$options$shape_raw_difference, silent = TRUE)
  try(color_raw_difference <- self$options$color_raw_difference, silent = TRUE)
  try(fill_raw_difference <- self$options$fill_raw_difference, silent = TRUE)
  try(size_raw_difference <- as.integer(self$options$size_raw_difference), silent = TRUE)
  try(alpha_raw_difference <- as.numeric(self$options$alpha_raw_difference), silent = TRUE)

  try(shape_raw_reference <- self$options$shape_raw_reference, silent = TRUE)
  try(color_raw_reference <- self$options$color_raw_reference, silent = TRUE)
  try(fill_raw_reference <- self$options$fill_raw_reference, silent = TRUE)
  try(size_raw_reference <- as.integer(self$options$size_raw_reference), silent = TRUE)
  try(alpha_raw_reference <- as.numeric(self$options$alpha_raw_reference), silent = TRUE)

  try(shape_raw_unused <- self$options$shape_raw_unused, silent = TRUE)
  try(shape_summary_unused <- self$options$shape_summary_unused, silent = TRUE)
  try(color_raw_unused <- self$options$color_raw_unused, silent = TRUE)
  try(color_summary_unused <- self$options$color_summary_unused, silent = TRUE)
  try(fill_raw_unused <- self$options$fill_raw_unused, silent = TRUE)
  try(fill_summary_unused <- self$options$fill_summary_unused, silent = TRUE)
  try(size_raw_unused <- as.integer(self$options$size_raw_reference), silent = TRUE)
  try(size_summary_unused <- as.integer(self$options$size_summary_unused), silent = TRUE)
  try(alpha_raw_unused <- as.numeric(self$options$alpha_raw_unused), silent = TRUE)
  try(alpha_summary_unused <- as.numeric(self$options$alpha_summary_unused), silent = TRUE)
  try(linetype_summary_unused <- self$options$linetype_summary_unused, silent = TRUE)
  try(linetype_summary_reference <- self$options$linetype_summary_reference, silent = TRUE)
  try(color_interval_unused <- self$options$color_interval_unused, silent = TRUE)
  try(color_interval_reference <- self$options$color_interval_reference, silent = TRUE)
  try(alpha_interval_unusued <- as.numeric(self$options$alpha_interval_unused), silent = TRUE)
  try(alpha_interval_reference <- as.numeric(self$options$alpha_interval_reference), silent = TRUE)
  try(size_interval_unused <- as.integer(self$options$size_interval_unused), silent = TRUE)
  try(size_interval_reference <- as.integer(self$options$size_interval_reference), silent = TRUE)
  try(fill_error_unused <- self$options$fill_error_unused, silent = TRUE)
  try(fill_error_reference <- self$options$fill_error_reference, silent = TRUE)
  try(alpha_error_reference <- self$options$alpha_error_reference, silent = TRUE)
  try(alpha_error_unused <- as.numeric(self$options$alpha_error_unused), silent = TRUE)


  # Aesthetics
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "Reference_raw" = shape_raw_reference,
      "Comparison_raw" = self$options$shape_raw_comparison,
      "Difference_raw" = shape_raw_difference,
      "Unused_raw" = shape_raw_unused,
      "Reference_summary" = self$options$shape_summary_reference,
      "Comparison_summary" = self$options$shape_summary_comparison,
      "Difference_summary" = self$options$shape_summary_difference,
      "Unused_summary" = shape_summary_unused
    )
  )

  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "Reference_raw" = color_raw_reference,
      "Comparison_raw" = self$options$color_raw_comparison,
      "Difference_raw" = color_raw_difference,
      "Unused_raw" = color_raw_unused,
      "Reference_summary" = self$options$color_summary_reference,
      "Comparison_summary" = self$options$color_summary_comparison,
      "Difference_summary" = self$options$color_summary_difference,
      "Unused_summary" = color_summary_unused
    ),
    aesthetics = c("color", "point_color")
  )

  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "Reference_raw" = fill_raw_reference,
      "Comparison_raw" = self$options$fill_raw_comparison,
      "Difference_raw" = fill_raw_difference,
      "Unused_raw" = fill_raw_unused,
      "Reference_summary" = self$options$fill_summary_reference,
      "Comparison_summary" = self$options$fill_summary_comparison,
      "Difference_summary" = self$options$fill_summary_difference,
      "Unused_summary" = fill_summary_unused
    ),
    aesthetics = c("fill", "point_fill")
  )

  divider <- 1
  if (effect_size == "median") divider <- 4

  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "Reference_raw" = size_raw_reference,
      "Comparison_raw" = as.integer(self$options$size_raw_comparison),
      "Difference_raw" = size_raw_difference,
      "Unused_raw" = size_raw_unused,
      "Reference_summary" = as.integer(self$options$size_summary_reference)/divider,
      "Comparison_summary" = as.integer(self$options$size_summary_comparison)/divider,
      "Difference_summary" = as.integer(self$options$size_summary_difference)/divider,
      "Unused_summary" = size_summary_unused/divider
    ))
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "Reference_raw" = 1 - alpha_raw_reference,
      "Comparison_raw" = 1 - as.numeric(self$options$alpha_raw_comparison),
      "Difference_raw" = 1 - alpha_raw_difference,
      "Unused_raw" = 1 - alpha_raw_unused,
      "Reference_summary" = 1 - as.numeric(self$options$alpha_summary_reference),
      "Comparison_summary" = 1 - as.numeric(self$options$alpha_summary_comparison),
      "Difference_summary" = 1 - as.numeric(self$options$alpha_summary_difference),
      "Unused_summary" = 1 - alpha_summary_unused
    ))
  )

  # Error bars
  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "Reference_summary" = linetype_summary_reference,
      "Comparison_summary" = self$options$linetype_summary_comparison,
      "Difference_summary" = self$options$linetype_summary_difference,
      "Unused_summary" = linetype_summary_unused
    )
  )
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "Reference_summary" = color_interval_reference,
      "Comparison_summary" = self$options$color_interval_comparison,
      "Difference_summary" = self$options$color_interval_difference,
      "Unused_summary" = color_interval_unused
    ),
    aesthetics = "interval_color"
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_alpha",
    "interval_alpha_d",
    function(n) return(c(
      "Reference_summary" = 1 - as.numeric(alpha_interval_reference),
      "Comparison_summary" = 1 - as.numeric(self$options$alpha_interval_comparison),
      "Difference_summary" = 1 - as.numeric(self$options$alpha_interval_difference),
      "Unused_summary" = 1 - alpha_interval_unused
    ))
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_size",
    "interval_size_d",
    function(n) return(c(
      "Reference_summary" = as.integer(size_interval_reference),
      "Comparison_summary" = as.integer(self$options$size_interval_comparison),
      "Difference_summary" = as.integer(self$options$size_interval_difference),
      "Unused_summary" = size_interval_unused
    ))
  )

  # Slab
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "Reference_summary" = fill_error_reference,
      "Comparison_summary" = self$options$fill_error_comparison,
      "Difference_summary" = self$options$fill_error_difference,
      "Unused_summary" = fill_error_unused
    ),
    aesthetics = "slab_fill"
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "slab_alpha",
    "slab_alpha_d",
    function(n) return(c(
      "Reference_summary" = 1 - as.numeric(alpha_error_reference),
      "Comparison_summary" = 1 - as.numeric(self$options$alpha_error_comparison),
      "Difference_summary" = 1 - as.numeric(self$options$alpha_error_difference),
      "Unused_summary" = 1 - alpha_error_unused
    ))
  )


  return(myplot)
}
