jasp_pdiff_table_depends_on <- function() {
  return(
    c(
      "outcome_variable",
      "grouping_variable",
      "conf_level",
      "show_details",
      "reference_p",
      "switch",
      "cases",
      "not_cases",
      "comparison_cases",
      "comparison_not_cases",
      "reference_cases",
      "reference_not_cases",
      "case_label",
      "not_case_label",
      "outcome_variable_name",
      "grouping_variable_name",
      "grouping_variable_level1",
      "grouping_variable_level2",
      "count_NA",
      "reference_measure",
      "comparison_measure",
      "comparison_measure_name",
      "reference_measure_name",
      "cases_consistent",
      "cases_inconsistent",
      "not_cases_inconsistent",
      "not_cases_consistent"
    )
  )
}

# Prep an overview table
jasp_poverview_prep <- function(jaspResults, options, ready, estimate = NULL, levels = 1) {

  # Handles
  from_raw <- FALSE
  if (!is.null(options$switch)) {
    from_raw <- options$switch == "from_raw"
  }

  # Title
  overviewTable <- createJaspTable(title = "Overview")

  # Depends on
  overviewTable$dependOn(
    jasp_pdiff_table_depends_on()
  )

  if (levels > 1) {
    overviewTable$addColumnInfo(
      name = "grouping_variable_name",
      title = "Grouping variable",
      type = "string",
      combine = TRUE
    )

    overviewTable$addColumnInfo(
      name = "grouping_variable_level",
      title = options$grouping_variable,
      type = "string",
      combine = TRUE
    )
  }


  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )

  # Columns
  overviewTable$addColumnInfo(
    name = "outcome_variable_level",
    title = "Level",
    type = "string",
    combine = TRUE
  )

  overviewTable$addColumnInfo(
    name = "cases",
    title = "Cases",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "n",
    title = if (levels > 1) "<i>n</i>" else "<i>N</i>",
    type = "integer"
  )

  overviewTable$addColumnInfo(
    name = "P",
    title = "<i>P</i>",
    type = "number"
  )

  overviewTable$addColumnInfo(
    name = "P_LL",
    title = "LL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )
  overviewTable$addColumnInfo(
    name = "P_UL",
    title = "UL",
    type = "number",
    overtitle = paste0(100 * options$conf_level, "% CI")
  )

  if (options$show_details) {

    overviewTable$addColumnInfo(
      name = "P_SE",
      title = "<i>SE</i><sub>Proportion</sub>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "P_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )


  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable) * 2)
    } else {
      overviewTable$setExpectedSize(2)
    }
  }

  jaspResults[["overviewTable"]] <- overviewTable


  return()

}


# Prep a pdiff table
jasp_es_proportion_difference_prep <- function(jaspResults, options, ready) {
  # Handles
  from_raw <- options$switch == "from_raw"

  overviewTable <- createJaspTable(title = "Proportion Difference")

  overviewTable$dependOn(
    c(
      jasp_pdiff_table_depends_on()
    )
  )

  overviewTable$addColumnInfo(
    name = "outcome_variable_name",
    title = "Outcome variable",
    type = "string",
    combine = TRUE
  )


  # effect_title <- if (ready) options$grouping_variable else "Effect"

  effect_title <- paste(
    if (!ready) "" else if (from_raw) options$grouping_variable else jasp_text_fix(options, "grouping_variable_name", "Grouping variable"),
    "Effect",
    "</BR>"
  )

  overviewTable$addColumnInfo(
    name = "effect_plus",
    title = effect_title,
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = "<i>P</i>",
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


  if (options$show_details) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

    overviewTable$addColumnInfo(
      name = "effect_size_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )
  }

  overviewTable$showSpecifiedColumnsOnly <- TRUE

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(length(options$outcome_variable) * 2)
    } else {
      overviewTable$setExpectedSize(2)
    }
  }

  jaspResults[["es_proportion_difference"]] <- overviewTable



  return()

}



jasp_es_proportion_prep <- function(jaspResults, options, ready, table_name, table_title, effect_label = "<i>P</i>", show_outcome_variable = TRUE) {
  # Handles
  from_raw <- options$switch == "from_raw"


  overviewTable <- createJaspTable(title = table_title)

  overviewTable$dependOn(
    c(
      jasp_pdiff_table_depends_on(),
      if (table_name == "es_phi") "show_phi" else NULL,
      if (table_name == "es_odds_ratio") "show_ratio" else NULL
    )
  )

  if (table_name != "es_phi" & show_outcome_variable) {
    overviewTable$addColumnInfo(
      name = "outcome_variable_name",
      title = "Outcome variable",
      type = "string",
      combine = TRUE
    )

  }


  effect_title <- paste(
    if (from_raw) options$grouping_variable else options$grouping_variable_name,
    "Effect",
    "</BR>"
  )

  overviewTable$addColumnInfo(
    name = if (table_name != "es_phi") "effect_plus" else "effect",
    title = effect_title,
    type = "string"
  )

  overviewTable$addColumnInfo(
    name = "effect_size",
    title = effect_label,
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


  if (options$show_details & table_name %in% c("es_proportion_difference", "es_phi")) {
    overviewTable$addColumnInfo(
      name = "SE",
      title = "<i>SE</i>",
      type = "number"
    )

  }

  if (options$show_details & table_name == "es_proportion_difference") {

    overviewTable$addColumnInfo(
      name = "effect_size_adjusted",
      title = "<i>P</i><sub>adjusted</sub>",
      type = "number"
    )
  }


  overviewTable$showSpecifiedColumnsOnly <- TRUE

  multiplier <- 1
  if (table_name == "es_proportion_difference") multiplier <- 3
  oc_multiplier <- 1
  if (table_name == "es_proportion_difference") oc_mutiplier <- length(options$outcome_variable)

  if (ready) {
    if (from_raw) {
      overviewTable$setExpectedSize(1 * oc_multiplier * multiplier)
    } else {
      overviewTable$setExpectedSize(1 * multiplier)
    }
  }

  jaspResults[[table_name]] <- overviewTable



  return()

}


jamovi_contingency_table <- function(self, estimate, jaspResults) {
  # Handles
  from_raw <- FALSE
  if (!is.null(self$options$switch)) {
    from_raw <- self$options$switch == "from_raw"
  }


  # Create a contingency table for Chi Square

  # Setup based on options for chi_table_option
  print_observed <- switch(
    self$options$chi_table_option,
    "observed" = TRUE,
    "expected" = FALSE,
    "both" = TRUE
  )

  print_expected <- switch(
    self$options$chi_table_option,
    "observed" = FALSE,
    "expected" = TRUE,
    "both" = TRUE
  )

  buffer <- if (print_observed & print_expected) " " else NULL

  observed_prefix <- if (print_observed) NULL else NULL
  observed_suffix <- if (print_observed) NULL else NULL
  expected_prefix <- if (print_expected) "(<i>" else NULL
  expected_suffix <- if (print_expected) "</i>)" else NULL
  total_prefix <- "<b>"
  total_suffix <- "</b>"

  # Handle on the table and the observed and expected tables
  tbl <- createJaspTable(title = "Chi-Square Analysis")

  tbl$dependOn(
    c(
      jasp_pdiff_table_depends_on(),
      "show_chi_square",
      "chi_table_option"
    )
  )

  observed <- estimate$properties$chi_square$observed
  expected <- estimate$properties$chi_square$expected

  cdims <- dim(observed)
  crows <- cdims[[1]]
  ccolumns <- cdims[[2]]

  ovl_name <- if (from_raw) jasp_text_fix(self$options, "outcome_variable", "Outcome variable") else jasp_text_fix(self$options, "outcome_variable_name", "Outcome variable")

  tbl$addColumnInfo(
    name = "outcome_variable_level",
    title = ovl_name,
    type = "string"
  )


  # First, create a column for each level of the grouping variable
  for(x in 1:ccolumns) {
    tbl$addColumnInfo(
      name = colnames(observed)[[x]],
      title = colnames(observed)[[x]],
      type = "string",
      overtitle = estimate$properties$grouping_variable_name
    )
  }

  # Add an extra column for totals
  tbl$addColumnInfo(
    name = "esci_Totals",
    title = "Total",
    type = "string"
  )

  # Now set each row
  for(x in 1:crows) {

    observed_values <- if (print_observed) format(observed[x, ], digits = 1) else NULL
    expected_values <- if (print_expected) format(expected[x, ], digits = 2) else NULL

    cell_values <- paste(
      "",
      observed_prefix,
      observed_values,
      observed_suffix,
      buffer,
      expected_prefix,
      expected_values,
      expected_suffix,
      "",
      sep = ""
    )

    cell_values <- c(
      row.names(observed)[[x]],
      cell_values,
      paste(
        total_prefix,
        sum(observed[x, ]),
        total_suffix,
        sep = ""
      )
    )

    names(cell_values) <- c(
      "outcome_variable_level",
      colnames(observed),
      "esci_Totals"
    )

    tbl$addRows(
      as.list(cell_values)
    )
  }

  # Add begin and ending group formats for main cells to mark totals
  # tbl$addFormat(rowNo = 1, col = 1, jmvcore::Cell.BEGIN_GROUP)
  # tbl$addFormat(rowNo = x-1, col = 1, jmvcore::Cell.END_GROUP)
  # tbl$addFormat(rowNo = x, col = 1, jmvcore::Cell.BEGIN_GROUP)


  # Add the totals row
  total_values <- colSums(observed)
  total_values <- c(
    "Total",
    paste(
      total_prefix,
      total_values,
      total_suffix,
      sep = ""
    ),
    paste(
      total_prefix,
      sum(observed),
      total_suffix
    )
  )

  names(total_values) <- c(
    "outcome_variable_level",
    colnames(observed),
    "esci_Totals"
  )


  tbl$addRows(
    as.list(total_values)
  )

  # Set a note with the chi square results
  mynote <- glue::glue(
    "&#120536;<sup>2</sup>({format(estimate$properties$chi_square$parameter, digits = 2)}) = {format(estimate$properties$chi_square$statistic, digits = 2)}, <i>p</i> = {esci_pvalr(estimate$properties$chi_square$p.value)}.  Continuity correction has *not* been applied."
  )

  tbl$addFootnote(mynote)

  # Finally, rename title for outcome variable
  # tbl$getColumn("outcome_variable_level")$setTitle(estimate$properties$outcome_variable_name)

  jaspResults[["chi_square"]] <- tbl


  return(TRUE)

}




esci_pvalr <- function(pvals, sig.limit = .001, digits = 3, html = FALSE) {

  roundr <- function(x, digits = 1) {
    res <- sprintf(paste0('%.', digits, 'f'), x)
    zzz <- paste0('0.', paste(rep('0', digits), collapse = ''))
    res[res == paste0('-', zzz)] <- zzz
    res
  }

  sapply(pvals, function(x, sig.limit) {
    if (x < sig.limit)
      if (html)
        return(sprintf('&lt; %s', format(sig.limit))) else
          return(sprintf('< %s', format(sig.limit)))
    if (x > .1)
      return(roundr(x, digits = 2)) else
        return(roundr(x, digits = digits))
  }, sig.limit = sig.limit)
}
