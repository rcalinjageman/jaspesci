jasp_meta_mean <- function(jaspResults, dataset = NULL, options, ...) {

  from_raw <- options$switch == "from_raw"

  # Check if ready
  if (from_raw) {
    ready <- options$means != "" &
      options$sds != "" &
      options$ns != ""
  } else {
    ready <- options$ds != "" & options$ns != ""
  }

  if (!ready) return()

  # read dataset
  dataset <- jasp_meta_mean_read_data(dataset, options)

  # myds <- createJaspHtml(printmydf(dataset))
  # jaspResults[["myds"]] <- myds


  # check for errors
  # ns are positive; if from_raw sds should all be positive, too
  .hasErrors(
    dataset = dataset,
    type = c("observations", "variance", "infinity", "negativeValues"),
    all.target = if (from_raw) c(options$sds, options$ns) else c(options$ns),
    observations.amount  = "< 2",
    exitAnalysisIfErrors = TRUE
  )

  has_moderator <- FALSE
  if (options$moderator != "") {
    has_moderator <- TRUE

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
      all.target = c(
        if (from_raw) c(options$means, options$sds) else options$ds,
        options$ns
      ),
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
  args$effect_label <- "My effect"
  if (!self$options$effect_label %in% c("Auto", "auto", "AUTO", "")) args$effect_label <- self$options$effect_label

  args$conf_level <- self$options$conf_level

  if (!(options$reference_mean %in% c("auto", "Auto", "AUTO", ""))) {
    try(args$reference_mean <- as.numeric(options$reference_mean))
    if (is.na(args$reference_mean)) args$reference_mean <- NULL
  }

  if (from_raw) {
    args$means <- self$options$means
    args$sds <- self$options$sds
    args$ns <- self$options$ns
    args$reported_effect_size <- self$options$reported_effect_size
  } else {
    args$ds <- self$options$ds
    args$ns <- self$options$dns
  }

  if (self$options$moderator != "") {
    args$moderator <- self$options$moderator
  }

  if (self$options$labels != "") {
    args$labels <- self$options$labels
  }

  args$random_effects <- self$options$random_effects %in% c("random_effects", "compare")


  estimate <- try(do.call(what = call, args = args))

  if(is.null(estimate)) return()
  if(is(estimate, "try-error")) {
    # To do: pull the error text and return it as a jasp error

    return()

  }

  # properties cleanup - need to move this into esci
  if (!is.null(args$reference_mean) & from_raw) {
    if (options$reported_effect_size == "mean_difference") {
      estimate$properties$effect_size_name_html <- paste(
        estimate$properties$effect_size_name_html,
        " - <i>M</i><sub>Reference</sub>",
        sep = ""
      )
    } else {
    }
  }


  #myds <- createJaspHtml(printmydf(estimate$es_meta))
  # myds <- createJaspHtml(paste(levels(estimate$raw_data$label), collapse = ", "))
  # jaspResults[["myds"]] <- myds


  es_note <- if (options$random_effects == "fixed_effects")
    "Estimate is based on a fixed effect (FE) model"
  else
    "Estimate is based on a random effects (RE) model"

  # Define and fill the raw_data
  if (is.null(jaspResults[["meta_raw_dataTable"]])) {
    jasp_meta_raw_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      levels = nrow(dataset),
      effect_size_title = estimate$properties$effect_size_name_html
    )
    jasp_table_fill(jaspResults[["meta_raw_dataTable"]], estimate$raw_data, NULL)
  }

  # Define and fill the es_meta
  if (is.null(jaspResults[["es_metaTable"]])) {
    row_expect <- if (options$moderator != "") length(levels(dataset[[options$moderator]])) else 1

    jasp_es_meta_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      levels = row_expect,
      effect_size_title = estimate$properties$effect_size_name_html
    )
    jasp_table_fill(jaspResults[["es_metaTable"]], estimate$es_meta, es_note)
  }


  # Define and fill the es_heterogeneityTable table
  if (is.null(jaspResults[["es_heterogeneityTable"]])) {
    my_levels <- if (has_moderator) length(levels(dataset[[options$moderator]])) else 0

    jasp_es_heterogeneity_data_prep(
      jaspResults,
      options = options,
      ready = ready,
      levels = my_levels
    )
    jasp_table_fill(
      jaspResults[["es_heterogeneityTable"]],
      estimate$es_heterogeneity,
      message = estimate$es_heterogeneity_properties$message_html
    )
  }


  if (has_moderator & is.null(jaspResults[["es_meta_differenceTable"]])) {
    jasp_es_meta_difference_prep(
      jaspResults,
      options = options,
      ready = ready,
      effect_size_title = estimate$properties$effect_size_name_html
    )
    jasp_table_fill(
      jaspResults[["es_meta_differenceTable"]],
      estimate$es_meta_difference,
      message = es_note
    )
  }

  return()




  # Now prep and fill the plot
  x <- 0
  for (my_variable in options$outcome_variable) {
    x <- x + 1

    if (is.null(jaspResults[[my_variable]])) {
      jasp_plot_m_prep(jaspResults, options, my_variable, if (x == 1) TRUE else FALSE)

      effect_size = options$effect_size
      if (effect_size == "mean_difference") effect_size <- "mean"
      if (effect_size == "median_difference") effect_size <- "median"

      args <- list()
      args$estimate <- estimate[[my_variable]]
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
      args$columns.as.numeric = c(options$ds, options$ns)
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


jasp_meta_decorate <- function(myplot, options) {

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
