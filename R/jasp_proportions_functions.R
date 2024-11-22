jasp_test_pdiff <- function(options, estimate) {
  self <- list()
  self$options <- options

  evaluate_h <- self$options$evaluate_hypotheses

    # Test results
    rope_upper <- self$options$null_boundary

    mytest <- esci::test_pdiff(
      estimate,
      rope = c(rope_upper * -1, rope_upper),
      output_html = FALSE
    )

    mytest$interval_null$rope_compare <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$interval_null$rope_compare)
    mytest$point_null$CI_compare <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$point_null$CI_compare)
    mytest$point_null$null_decision <- gsub("H_0", "<i>H</i><sub>0</sub>", mytest$point_null$null_decision)
    mytest$point_null$conclusion <- gsub("_diff", "<sub>diff</sub>", mytest$point_null$conclusion)
    mytest$interval_null$conclusion <- gsub("_diff", "<sub>diff</sub>", mytest$interval_null$conclusion)


    if (rope_upper > 0) {
      mytest$to_fill <- jasp_peffect_html(mytest$interval_null)
    } else {
      mytest$to_fill <- jasp_peffect_html(mytest$point_null)
    }

  return(mytest)

}



jasp_peffect_html <- function(tfix) {

  if (is.null(tfix)) return(NULL)
  if (nrow(tfix) == 0) return(tfix)

  tfix$case_label <- gsub("P_", "<i>P</i><sub>", tfix$case_label)

  tfix$effect_plus <- paste(
    tfix$case_label,
    "</sub>: ",
    tfix$effect,
    sep = ""
  )

  return(tfix)

}



jasp_plot_pdiff_decorate <- function(myplot, options) {
  self <- list()
  self$options <- options

  # handles
  from_raw <- (self$options$switch == "from_raw")
  divider <- 4
  interval_null <- (self$options$null_boundary > 0)
  htest <- FALSE
  try(htest <- self$options$evaluate_hypotheses, silent = TRUE)


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


  if (self$options$evaluate_hypotheses) {
    myplot$layers[["null_line"]]$aes_params$colour <- self$options$null_color
    if ((self$options$null_boundary != 0)) {
      try(myplot$layers[["null_interval"]]$aes_params$fill <- self$options$null_color)
      try(myplot$layers[["ta_CI"]]$aes_params$size <- as.numeric(self$options$size_summary_difference)/divider+1)
      try(myplot$layers[["ta_CI"]]$aes_params$alpha <- 1 - as.numeric(self$options$alpha_summary_difference))
      try(myplot$layers[["ta_CI"]]$aes_params$colour <- self$options$color_summary_difference)
      try(myplot$layers[["ta_CI"]]$aes_params$linetype <- self$options$linetype_summary_difference)
    }
  }

  shape_summary_unused <- "circle"
  color_summary_unused <- "black"
  fill_summary_unused <- "black"
  size_summary_unused <- 1
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
  #
  #
  try(shape_summary_unused <- self$options$shape_summary_unused, silent = TRUE)
  try(color_summary_unused <- self$options$color_summary_unused, silent = TRUE)
  try(fill_summary_unused <- self$options$fill_summary_unused, silent = TRUE)
  try(size_summary_unused <- as.integer(self$options$size_summary_unused), silent = TRUE)
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
  #
  #
  # Aesthetics
  myplot <- myplot + ggplot2::scale_shape_manual(
    values = c(
      "Reference_summary" = self$options$shape_summary_reference,
      "Comparison_summary" = self$options$shape_summary_comparison,
      "Difference_summary" = self$options$shape_summary_difference,
      "Unused_summary" = shape_summary_unused
    )
  )
  #
  myplot <- myplot + ggplot2::scale_color_manual(
    values = c(
      "Reference_summary" = self$options$color_summary_reference,
      "Comparison_summary" = self$options$color_summary_comparison,
      "Difference_summary" = self$options$color_summary_difference,
      "Unused_summary" = color_summary_unused
    ),
    aesthetics = c("color", "point_color")
  )
  #
  myplot <- myplot + ggplot2::scale_fill_manual(
    values = c(
      "Reference_summary" = self$options$fill_summary_reference,
      "Comparison_summary" = self$options$fill_summary_comparison,
      "Difference_summary" = self$options$fill_summary_difference,
      "Unused_summary" = fill_summary_unused
    ),
    aesthetics = c("fill", "point_fill")
  )
  #
  divider <- 4
  #
  myplot <- myplot + ggplot2::discrete_scale(
    c("size", "point_size"),
    "point_size_d",
    function(n) return(c(
      "Reference_summary" = as.integer(self$options$size_summary_reference)/divider,
      "Comparison_summary" = as.integer(self$options$size_summary_comparison)/divider,
      "Difference_summary" = as.integer(self$options$size_summary_difference)/divider,
      "Unused_summary" = size_summary_unused/divider
    ))
  )
  #
  myplot <- myplot + ggplot2::discrete_scale(
    c("alpha", "point_alpha"),
    "point_alpha_d",
    function(n) return(c(
      "Reference_summary" = 1- as.numeric(self$options$alpha_summary_reference),
      "Comparison_summary" = 1 - as.numeric(self$options$alpha_summary_comparison),
      "Difference_summary" = 1 - as.numeric(self$options$alpha_summary_difference),
      "Unused_summary" = 1 - alpha_summary_unused
    ))
  )
  #
  # Error bars
  myplot <- myplot + ggplot2::scale_linetype_manual(
    values = c(
      "Reference_summary" = linetype_summary_reference,
      "Comparison_summary" = self$options$linetype_summary_comparison,
      "Difference_summary" = self$options$linetype_summary_difference,
      "Unused_summary" = linetype_summary_unused
    )
  )


  return(myplot)
}


