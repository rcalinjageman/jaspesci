jasp_estimate_pdiff_one <- function(jaspResults, dataset = NULL, options, ...) {

  # Handles
  from_raw <- options$switch == "from_raw"
  evaluate_h <- options$evaluate_hypotheses

  ready <- FALSE
  if (from_raw) {
    ready <- (length(options$outcome_variable) > 0)
  } else {
    jasp_summary_dirty(options$summary_dirty, jaspResults)

    # Determine if summary data is ready
    ready <- !is.null(options$cases) & !is.null(options$not_cases)
    if (ready) ready <- ready & options$cases >= 0 & options$not_cases >= 0 & ((options$cases + options$not_cases) > 0)

  }


  # check for errors
  if (from_raw & ready) {
    # read dataset
    dataset <- jasp_estimate_pdiff_one_read_data(dataset, options)

    for (variable in options$outcome_variable) {

      # At least 2 levels in outcome variable
      .hasErrors(
        dataset = dataset,
        type = "factorLevels",
        factorLevels.target  = options$outcome_variable,
        factorLevels.amount  = "< 2",
        exitAnalysisIfErrors = TRUE
      )


    }
  }

  # Run the analysis
  if (ready) {
    call <- esci::estimate_pdiff_one
    args <- list()

    null_value <- 0
    if (options$evaluate_hypotheses) null_value <- options$null_value
    if (is.null(null_value)) null_value <- 0

    args$conf_level <- options$conf_level
    args$reference_p <- null_value
    args$count_NA <- options$count_NA

    if (from_raw) {
      args$data <- dataset
      args$outcome_variable <- options$outcome_variable
    } else {
      outcome_variable_name <- "Outcome variable"
      if (!is.null(options$outcome_variable_name)) {
        if (!(options$outcome_variable_name %in% c("auto", "Auto", "AUTO", ""))) {
          outcome_variable_name <- options$outcome_variable_name
        }
      }
      args$comparison_cases <- options$cases
      args$comparison_n <- options$cases + options$not_cases
      args$case_label <- jasp_text_fix(
        options,
        "case_label",
        "Affected"
      )
      args$outcome_variable_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )
    }

  # debugtext <- createJaspHtml(text = paste(names(args), args, collapse = "<BR>"))
  # debugtext$dependOn(c("outcome_variable", "count_NA"))
  # jaspResults[["debugtext"]] <- debugtext

    estimate <- try(do.call(what = call, args = args))

    # debugtext <- createJaspHtml(text = paste(names(estimate), estimate, collapse = "<BR>"))
    # debugtext$dependOn(c("outcome_variable", "count_NA"))
    # jaspResults[["estimatetext"]] <- debugtext

    if (!from_raw) {
      ov_name <- jasp_text_fix(
        options,
        "outcome_variable_name",
        "Outcome variable"
      )

      estimate[[ov_name]] <- estimate
      options$outcome_variable <- ov_name
    } else {
      if (length(options$outcome_variable) == 1) {
        estimate[[options$outcome_variable[[1]]]] <- estimate
      }
    }


    if(evaluate_h & is.null(jaspResults[["heTable"]])) {
      options$effect_size <- "pdiff"
      mytest <- jasp_test_pdiff(
        options,
        estimate
      )
    }
  }


  # Overview
  if (is.null(jaspResults[["overviewTable"]])) {
    jasp_poverview_prep(
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


  # Hypothesis evaluation table and pdiff table
  if(evaluate_h & is.null(jaspResults[["heTable"]])) {
    jasp_he_prep(
      jaspResults,
      options,
      ready,
      mytest
    )

    jaspResults[["heTable"]]$position <- 10

    if (ready) jasp_table_fill(
      jaspResults[["heTable"]],
      mytest,
      "to_fill"
    )
  }


  # Figure
  # Now prep and fill the plot
  for (my_variable in options$outcome_variable) {

    # debugtext <- createJaspHtml(text = paste(my_variable, " - </BR>"))
    # debugtext$dependOn(c("outcome_variable", "count_NA"))
    # jaspResults[[paste(my_variable, "debugtext", sep = "")]] <- debugtext


    if (is.null(jaspResults[[my_variable]])) {
      jasp_plot_m_prep(
        jaspResults,
        options,
        ready,
        my_variable = my_variable,
        add_citation = FALSE
      )

      if (ready) {
        args <- list()
        args$estimate <- estimate[[my_variable]]
        args$plot_possible <- options$plot_possible


        if (evaluate_h) {
          args$rope <- c(
            options$null_value - options$null_boundary,
            options$null_value + options$null_boundary
          )
        }

        myplot <- do.call(
          what = esci::plot_proportion,
          args = args
        )

        myplot <- jasp_plot_proportion_decorate(myplot, options)

        jaspResults[[my_variable]]$plotObject <- myplot
        jaspResults[[my_variable]]$position <- 20

      }  # end plot creation


    } # end check if plot is null
  } # end loop through outcome variables


  return()
}



jasp_estimate_pdiff_one_read_data <- function(dataset, options) {
  if (!is.null(dataset))
    return(dataset)
  else
    return(.readDataSetToEnd(columns.as.factor = options$outcome_variable))
}



jasp_plot_proportion_decorate <- function(myplot, options) {

  self <- list()
  self$options <- options

  # Basic plot
  divider <- 4


  # Basic graph options --------------------
  # Axis font sizes
  myplot <- myplot + ggplot2::theme(
    axis.text.y = ggtext::element_markdown(size = self$options$axis.text.y),
    axis.title.y = ggtext::element_markdown(size = self$options$axis.title.y),
    axis.text.x = ggtext::element_markdown(size = self$options$axis.text.x),
    axis.title.x = ggtext::element_markdown(size = self$options$axis.title.x)
  )


  if (!(self$options$xlab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::xlab(self$options$xlab)
  }
  if (!(self$options$ylab %in% c("auto", "Auto", "AUTO", ""))) {
    myplot <- myplot + ggplot2::ylab(self$options$ylab)
  }


  ylim <- c(0, 1)

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


  # Axis breaks
  myplot <- myplot + ggplot2::scale_y_continuous(
    limits = ylim,
    n.breaks = ybreaks,
  )

  #aesthetics
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "summary" = self$options$shape_summary
    )
  )


  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "summary" = self$options$color_summary
    ),
    aesthetics = c("color", "point_color")
  )


  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "summary" = self$options$fill_summary
    ),
    aesthetics = c("fill", "point_fill")
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "summary" = as.numeric(self$options$size_summary)/divider
    ))
  )

  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "summary" = 1 - as.numeric(self$options$alpha_summary)
    ))
  )

  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "summary" = self$options$linetype_summary
    )
  )


  if (self$options$evaluate_hypotheses) {
    myplot$layers[["null_line"]]$aes_params$colour <- self$options$null_color
    if ((self$options$null_boundary != 0)) {
        try(myplot$layers[["null_interval"]]$aes_params$fill <- self$options$null_color)
        try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(self$options$size_summary)/divider+1)
        try(myplot$layers[["ta_CI"]]$aes_params$alpha <- as.numeric(self$options$alpha_summary))
        try(myplot$layers[["ta_CI"]]$aes_params$colour <- self$options$color_summary)
        try(myplot$layers[["ta_CI"]]$aes_params$linetype <- self$options$linetype_summary)
    }
  }


  return(myplot)

}
