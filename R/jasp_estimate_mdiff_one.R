jasp_estimate_mdiff_one <- function(jaspResults, dataset = NULL, options, ...) {


  ready <- (length(options$outcome_variable) > 0)

  if (ready) {
    # read dataset
    dataset <- jasp_estimate_mdiff_one_read_data(dataset, options)

    # check for errors
    for (variable in options$outcome_variable) {
      .hasErrors(
        dataset = dataset,
        type = "observations",
        observations.target = variable,
        observations.amount  = "< 3",
        exitAnalysisIfErrors = TRUE
      )

    }


    # Run the analysis
    my_reference_mean <- 0
    if (options$hypothesis_evaluation) my_reference_mean <- options$reference_mean

    estimate <- esci::estimate_mdiff_one(
      data = dataset,
      outcome_variable = encodeColNames(options$outcome_variable),
      reference_mean = my_reference_mean,
      conf_level = options$conf_level,
      save_raw_data = TRUE
    )

   # Some results tweaks
    alpha <- 1 - as.numeric(options$conf_level)
    estimate$overview$t_multiplier <- stats::qt(1-alpha/2, estimate$overview$df)
    estimate$overview$s_component <- estimate$overview$sd
    estimate$overview$n_component <- 1/sqrt(estimate$overview$n)
    estimate$overview$moe <- (estimate$overview$mean_UL - estimate$overview$mean_LL)/2


    # Define and fill tables
    if (is.null(jaspResults[["overviewTable"]])) {
      jasp_overview_prep(jaspResults, dataset, options, ready)
      jasp_table_fill(jaspResults[["overviewTable"]], estimate$overview)

    }

    hypothesis_evaluation <- options$hypothesis_evaluation
    interval_null <- options$rope > 0


    if (hypothesis_evaluation) {
      # SMD
      estimate$es_smd$reference_value <- options$reference_mean
      estimate$es_smd$mean <- estimate$es_smd$numerator + options$reference_mean

      if (options$effect_size == "mean" & is.null(jaspResults[["smdTable"]]) ) {
        jasp_smd_prep(jaspResults, dataset, options, ready)
        jasp_table_fill(jaspResults[["smdTable"]], estimate$es_smd)
      } # else {
        # jaspResults[["smdTable"]] <- NULL
      # }


      # Hypothesis evaluation
      my_rope <- c(-1 * options$rope, options$rope)

      test_results <- esci::test_mdiff(
        estimate,
        effect_size = options$effect_size,
        rope = my_rope,
        rope_units = "raw",
        output_html = TRUE
      )

      if (is.null(jaspResults[["heTable"]]) ) {
        if (options$rope == 0) {
          jasp_he_point_prep(jaspResults, dataset, options, ready)
        } else {
          jasp_he_interval_prep(jaspResults, dataset, options, ready)
        }

        to_fill <- test_results$point_null
        if (options$rope >0) to_fill <- test_results$interval_null

        jasp_table_fill(jaspResults[["heTable"]], to_fill)
      }

    } # else {
      # jaspResults[["smdTable"]] <- NULL
      # jaspResults[["heTable"]] <- NULL
    # }


    if (is.null(jaspResults[["mdiffPlot"]])) {
      jasp_plot_magnitude_prep(jaspResults, options)

      args <- list()
      args$estimate <- estimate
      args$effect_size <- options$effect_size
      args$data_layout <- options$data_layout
      args$data_spread <- options$data_spread
      args$error_layout <- options$error_layout
      args$error_scale <- options$error_scale
      args$error_nudge <- options$error_nudge
      if (hypothesis_evaluation) {
        args$rope <- c(
          options$reference_mean - options$rope,
          options$reference_mean + options$rope
        )
      }

      myplot <- do.call(
        what = esci::plot_magnitude,
        args = args
      )

      myplot <- jasp_plot_magnitude_decorate(myplot, options)

      jaspResults[["mdiffPlot"]]$plotObject <- myplot


    }


  }  # end of ready

  return()
}



jasp_estimate_mdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.numeric = options$outcome_variable))
}


jasp_overview_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Overview")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "extraDetails", "effect_size", "calculationComponents"))


  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )


  if (options$effect_size == "mean") {
    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )


    overviewTable$addColumnInfo(
      name = "mean_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "mean_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )

    if (options$extraDetails) {

      overviewTable$addColumnInfo(
        name = "moe",
        title = "<i>MoE</i>",
        type = "number"
      )

      overviewTable$addColumnInfo(
        name = "mean_SE",
        title = "<i>SE</i><sub>Mean</sub>",
        type = "number"
      )

    }

    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

  }


  if (options$effect_size == "median") {
    overviewTable$addColumnInfo(
      name = "median",
      title = "<i>Mdn</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "median_LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )
    overviewTable$addColumnInfo(
      name = "median_UL",
      title = "UL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
    )


    if (options$extraDetails) {
      overviewTable$addColumnInfo(
        name = "median_SE",
        title = "<i>SE</i><sub>Median</sub>",
        type = "number"
      )
    }

    overviewTable$addColumnInfo(
      name = "mean",
      title = "<i>M</i>",
      type = "number"
    )
  }

  overviewTable$addColumnInfo(
    name = "sd",
    title = "<i>s</i>",
    type = "number"
  )

  if (options$extraDetails) {
    overviewTable$addColumnInfo(
      name = "min",
      title = "Minimum",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "max",
      title = "Maximum",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "q1",
      title = "25th",
      type = "number",
      overtitle = "Percentile"
    )

    overviewTable$addColumnInfo(
      name = "q3",
      title = "75th",
      type = "number",
      overtitle = "Percentile"
    )

  }


  overviewTable$addColumnInfo(
    name = "n",
    title = "<i>N</i>",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "missing",
    title = "Missing",
    type = "integer"
  )


  if (options$calculationComponents & options$effect_size == "mean") {
    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = "integer"
    )

    overviewTable$addColumnInfo(
      name = "t_multiplier",
      title = "<i>t</i>",
      type = "number",
      overtitle = "Calculation component"
    )

    overviewTable$addColumnInfo(
      name = "s_component",
      title = "Variability",
      type = "number",
      overtitle = "Calculation component"
    )

    overviewTable$addColumnInfo(
      name = "n_component",
      title = "Sample size",
      type = "number",
      overtitle = "Calculation component"
    )

  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}



jasp_smd_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Standardized Mean Difference")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "extraDetails", "reference_mean", "hypothesis_evaluation"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "mean",
    title = "<i>M</i>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "reference_value",
    title = "Reference value",
    type = "number"
  )

  overviewTable$addColumnInfo(
      name = "numerator",
      title = "<i>M</i> - Reference",
      type = "number",
      overtitle = "Numerator"
  )

  overviewTable$addColumnInfo(
    name = "denominator",
    title = "<i>s</i>",
    type = "number",
    overtitle = "Standardizer"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = "<i>d</i><sub>1</i>",
    type = "number"
  )

  overviewTable$addColumnInfo(
      name = "LL",
      title = "LL",
      type = "number",
      overtitle = paste0(100 * options$conf_level, "% CI")
  )

  overviewTable$addColumnInfo(
    name = "UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  overviewTable$addColumnInfo(
    name = "d_biased",
    title = "<i>d</i><sub>1.biased</i>",
    type = "number"
  )

  if (options$extraDetails) {

      overviewTable$addColumnInfo(
        name = "SE",
        title = "<i>SE</i>",
        type = "number"
      )

      overviewTable$addColumnInfo(
        name = "df",
        title = "<i>df</i>",
        type = "integer"
      )

  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["smdTable"]] <- overviewTable

  return()

}


jasp_he_point_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "hypothesis_evaluation"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "null_words",
    title = "<i>H</i><sub>0</sub>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "CI",
    title = "CI",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "CI_compare",
    title = "Compare CI with <i>H</i><sub>0</sub>",
    type = "string"
  )

  if (options$effect_size == "mean") {
    overviewTable$addColumnInfo(
      name = "t",
      title = "<i>t</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "df",
      title = "<i>df</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "p",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )

  } else {
    overviewTable$addColumnInfo(
      name = "p_result",
      title = "<i>p</i>, two tailed",
      type = "pvalue"
    )
  }

  overviewTable$addColumnInfo(
    name = "null_decision",
    title = "<i>H</i><sub>0</sub> decision",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "conclusion",
    title = "Conclusion",
    type = "string"
  )



  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["heTable"]] <- overviewTable

  return()

}


jasp_he_interval_prep <- function(jaspResults, dataset, options, ready) {
  overviewTable <- createJaspTable(title = "Hypothesis Evaluation")

  overviewTable$dependOn(c("outcome_variable", "conf_level", "effect_size", "reference_mean", "rope", "hypothesis_evaluation"))


  overviewTable$addColumnInfo(
    name = "effect",
    title = "Effect",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "rope",
    title = "<i>H</i><sub>0</sub>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "CI",
    title = "CI",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "rope_compare",
    title = "Compare CI with <i>H</i><sub>0</sub>",
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "p_result",
    title = "<i>p</i>, two tailed",
    type = "pvalue"
  )

  overviewTable$addColumnInfo(
    name = "conclusion",
    title = "Conclusion",
    type = "string"
  )



  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready)
    overviewTable$setExpectedSize(length(options$outcome_variable))

  jaspResults[["heTable"]] <- overviewTable

  return()

}



jasp_plot_magnitude_prep <- function(jaspResults, options) {
  mdiffPlot <- createJaspPlot(
    title = "Estimation Figure",
    width = options$width,
    height = options$height
  )

  mdiffPlot$dependOn(
    c(
      "outcome_variable",
      "conf_level",
      "effect_size",
      "reference_mean",
      "rope",
      "hypothesis_evaluation",
      "width",
      "height",
      "data_layout",
      "data_spread",
      "error_layout",
      "error_scale",
      "error_nudge",
      "ylab",
      "xlab",
      "axis.text.y",
      "axis.title.y",
      "axis.text.x",
      "axis.title.x",
      "ymin",
      "ymax",
      "n.breaks",
      "shape_summary",
      "size_summary",
      "color_summary",
      "fill_summary",
      "alpha_summary",
      "linetype_summary",
      "size_interval",
      "color_interval",
      "alpha_interval",
      "fill_error",
      "alpha_error",
      "shape_raw",
      "size_raw",
      "color_raw",
      "fill_raw",
      "alpha_raw",
      "null_color"
    )
  )

  jaspResults[["mdiffPlot"]] <- mdiffPlot

  return()

}



jasp_plot_magnitude_decorate <- function(myplot, options) {

  divider <- 1
  if (options$effect_size == "median") divider <- 4


  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = options$axis.text.y),
    axis.title.y = ggtext::element_markdown(size = options$axis.title.y),
    axis.text.x = ggtext::element_markdown(size = options$axis.text.x),
    axis.title.x = ggtext::element_markdown(size = options$axis.title.x)
  )

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

  n.breaks <- NULL
  if (!(options$n.breaks %in% c("auto", "Auto", "AUTO", ""))) {
    try(n.breaks <- as.numeric(options$n.breaks))
    if (is.na(n.breaks)) n.breaks <- NULL
  }


  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = limits,
    n.breaks = n.breaks
  )


  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "raw" = options$shape_raw,
      "summary" = options$shape_summary
    )
  )

  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "raw" = options$color_raw,
      "summary" = options$color_summary
    ),
    aesthetics = c("color", "point_color")
  )

  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "raw" = options$fill_raw,
      "summary" = options$fill_summary
    ),
    aesthetics = c("fill", "point_fill")
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "raw" = as.numeric(options$size_raw),
      "summary" = as.numeric(options$size_summary)/divider
    ))
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "raw" = 1 - options$alpha_raw,
      "summary" = 1 - options$alpha_summary
    ))
  )


  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "summary" = options$linetype_summary
    )
  )

  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "summary" = options$color_interval
    ),
    aesthetics = "interval_color"
  )

  myplot <- myplot + ggplot2::discrete_scale(
    "interval_alpha",
    "interval_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_interval
    ))
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "interval_size",
    "interval_size_d",
    function(n) return(c(
      "summary" = as.numeric(options$size_interval)/divider
    ))
  )

  # Slab
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "summary" = options$fill_error
    ),
    aesthetics = "slab_fill"
  )
  myplot <- myplot + ggplot2::discrete_scale(
    "slab_alpha",
    "slab_alpha_d",
    function(n) return(c(
      "summary" = 1 - options$alpha_error
    ))
  )


  hypothesis_evaluation <- options$hypothesis_evaluation
  interval_null <- options$rope > 0

  if (hypothesis_evaluation ) {
    myplot$layers[["null_line"]]$aes_params$colour <- options$null_color
    if (interval_null) {
      try(myplot$layers[["null_interval"]]$aes_params$fill <- options$null_color)
      try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(options$size_interval)/divider+1)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(options$alpha_interval))
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_interval)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)

      if (options$effect_size == "median") {
        try(myplot$layers[["ta_CI"]]$aes_params$colour <- options$color_summary)
        try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(options$size_summary)/divider*2)
        try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(options$alpha_summary))
        try(myplot$layers[["ta_CI"]]$aes_params$linetype <- options$linetype_summary)
      }

    }
  }



  return(myplot)
}


jasp_table_fill <- function(overviewTable, overview) {


  for (x in 1:nrow(overview)) {
      overviewTable$addRows(
        as.list(overview[x, ])
      )
  }

  return()
}

