jasp_estimate_mdiff_one <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0)
  } else {

    jasp_summary_dirty(options$summary_dirty, jaspResults)

    # Determine if summary data is ready
    ready <- !is.null(options$n) & !is.null(options$sd) & !is.null(options$m)
    if (ready) ready <- ready & options$n > 0 & options$sd > 0

    # Note we override effect size if working with summary data
    options$effect_size <- "mean"
  }


  # check for errors
  if (from_raw & ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_one_read_data(dataset, options)

    for (variable in options$outcome_variable) {
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = variable,
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }
  }

  # Run the analysis
  if (ready) {
    null_value <- 0
    if (options$evaluate_hypotheses) null_value <- options$null_value

    if (from_raw) {
      estimate <- esci::estimate_mdiff_one(
        data = dataset,
        outcome_variable = options$outcome_variable,
        reference_mean = null_value,
        conf_level = options$conf_level,
        save_raw_data = TRUE
      )

    } else {

      outcome_variable_name <- "Outcome variable"
      if (!is.null(options$outcome_variable_name)) {
        if (!(options$outcome_variable_name %in% c("auto", "Auto", "AUTO", ""))) {
          outcome_variable_name <- options$outcome_variable_name
        }
      }

      estimate <- esci::estimate_mdiff_one(
        comparison_mean = options$mean,
        comparison_sd = options$sd,
        comparison_n = options$n,
        outcome_variable_name = outcome_variable_name,
        reference_mean = null_value,
        conf_level = options$conf_level
      )

    }


    # Some results tweaks - future updates to esci will do these calcs within esci rather than here
    alpha <- 1 - as.numeric(options$conf_level)
    estimate$overview$t_multiplier <- stats::qt(1-alpha/2, estimate$overview$df)
    estimate$overview$s_component <- estimate$overview$sd
    estimate$overview$n_component <- 1/sqrt(estimate$overview$n)
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2

    estimate$es_smd$reference_value <- null_value
    estimate$es_smd$mean <- estimate$es_smd$numerator + null_value


    estimate_big <- estimate
    estimate$raw_data <- NULL
    if (from_raw) {
      for (myvariable in options$outcome_variable) {
        estimate[[myvariable]] <- NULL
      }
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
      level = 1
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


  # Smd table
  if(evaluate_h & options$effect_size == "mean" & is.null(jaspResults[["smdTable"]])) {
    jasp_smd_prep(
      jaspResults,
      options,
      ready,
      estimate
    )

    jaspResults[["smdTable"]]$position <- 10

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

    jaspResults[["heTable"]]$position <- 20

    if (ready) {
      jasp_table_fill(
        jaspResults[["heTable"]],
        mytest,
        "to_fill"
      )
    }

  }

  # Figure
  cposition <- 30
  if (is.null(jaspResults[["mdiffPlot"]])) {
    jasp_plot_m_prep(
      jaspResults,
      options,
      ready,
      add_citation = TRUE
    )

    jaspResults[["mdiffPlot"]]$position <- cposition
    cposition <- cposition + 1

    if (ready) {
      args <- list()
      if (from_raw) {
        args$estimate <- estimate_big
      } else {
        args$estimate <- estimate
      }
      args$effect_size <- options$effect_size
      args$data_layout <- options$data_layout
      args$data_spread <- options$data_spread
      args$error_layout <- options$error_layout
      args$error_scale <- options$error_scale
      args$error_nudge <- options$error_nudge
      if (evaluate_h) {
        args$rope <- c(
          options$null_value - options$null_boundary,
          options$null_value + options$null_boundary
        )
      }

      myplot <- do.call(
        what = esci::plot_magnitude,
        args = args
      )

      myplot <- jasp_plot_magnitude_decorate(myplot, options)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot

    }
  }


  return()
}



jasp_estimate_mdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$outcome_variable))
}


# Prep a magnitude plot



# Apply all plot customizations
jasp_plot_magnitude_decorate <- function(myplot, options) {

  # Divider used for CI linewidth
  divider <- 1
  if (options$effect_size == "median") divider <- 4

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

  limits <- c(NA, NA)

  if (!(options$ymin %in% c("auto", "Auto", "AUTO", ""))) {
    try(limits[[1]] <- as.numeric(options$ymin))
  }

  if (!(options$ymax %in% c("auto", "Auto", "AUTO", ""))) {
    try(limits[[2]] <- as.numeric(options$ymax))
  }

  ybreaks <- NULL
  if (!(options$ybreaks %in% c("auto", "Auto", "AUTO", ""))) {
    try(ybreaks <- as.numeric(options$ybreaks))
    if (is.na(ybreaks)) ybreaks <- NULL
  }


  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = limits,
    n.breaks = ybreaks
  )


  # Aesthetics -------------------

  # Raw and summary marker - Shape
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "raw" = options$shape_raw,
      "summary" = options$shape_summary
    )
  )

  # Raw and summary marker - Outline
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "raw" = options$color_raw,
      "summary" = options$color_summary
    ),
    aesthetics = c("color", "point_color")
  )

  # Raw and summary marker - Fill
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "raw" = options$fill_raw,
      "summary" = options$fill_summary
    ),
    aesthetics = c("fill", "point_fill")
  )

  # Raw and summary marker - Size
  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "raw" = as.numeric(options$size_raw),
      "summary" = as.numeric(options$size_summary)/divider
    ))
  )

  # Raw and summary marker - Alpha
  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "raw" = 1 - options$alpha_raw,
      "summary" = 1 - options$alpha_summary
    ))
  )

  # CI - linetype
  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "summary" = options$linetype_summary
    )
  )

  # CI - color
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "summary" = options$color_interval
    ),
    aesthetics = "interval_color"
  )

  # CI - alpha
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_alpha",
    "interval_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_interval
    ))
  )

  # CI - line thickness
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_size",
    "interval_size_d",
    function(n) return(c(
      "summary" = as.numeric(options$size_interval)/divider
    ))
  )

  # Error distribution fill
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "summary" = options$fill_error
    ),
    aesthetics = "slab_fill"
  )

  # Error distribution alpha
  myplot <- myplot + ggplot2::discrete_scale(
    "slab_alpha",
    "slab_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_error
    ))
  )

  # Hypothesis evaluation aesthetics
  evaluate_hypotheses <- options$evaluate_hypotheses
  interval_null <- options$null_boundary > 0

  if (evaluate_hypotheses ) {
    # Null line color
    myplot$layers[["null_line"]]$aes_params$colour <- options$null_color

    if (interval_null) {
      try(myplot$layers[["null_interval"]]$aes_params$fill <- options$null_color)
      try(myplot$layers[["ta_CI"]]$aes_params$size <- options$size_interval/divider+1)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <- 1 - options$alpha_interval)
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_interval)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)

      if (options$effect_size == "median") {
        try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_summary)
        try(myplot$layers[["ta_CI"]]$aes_params$size <- options$size_summary/divider*2)
        try(myplot$layers[["ta_CI"]]$aes_params$alpha <- 1 - options$alpha_summary)
        try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)
      }

    }
  }



  return(myplot)
}


