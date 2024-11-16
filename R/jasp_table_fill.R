
jasp_table_fill <- function(jaspTable, estimate, table_name) {
  esciTable <- estimate[[table_name]]

  for (x in 1:nrow(esciTable)) {
    jaspTable$addRows(
      as.list(esciTable[x, ])
    )
  }

  props <- paste(
    table_name,
    "_properties",
    sep = ""
  )

  if (!is.null(estimate[[props]])) {
    if (!is.null(estimate[[props]]$message_html)) {
      if (trimws(estimate[[props]]$message_html) != "") {
        something <- try(jaspTable$addFootnote(estimate[[props]]$message_html))
      }
    }

  }

  return()
}


jasp_text_fix <- function(options, field_name, default) {
  fixed <- default

  if (!is.null(options[[field_name]])) {
    if (!options[[field_name]] %in% c("auto", "Auto", "AUTO", "")) {
      fixed <- options[[field_name]]
    }
  }

  return(fixed)
}


jasp_numeric_fix <- function(options, field_name, default) {
  fixed <- default

  if (!is.null(options[[field_name]])) {
    if (!options[[field_name]] %in% c("auto", "Auto", "AUTO", "")) {
      try(fixed <- as.numeric(options[[field_name]]))
    }
  }

  return(fixed)
}


jasp_summary_dirty <- function(summary_dirty, jaspResults) {

  if (!summary_dirty) {
    summary_replace <- createJaspHtml(
      '<p style="background-color:#ffc2c2;">For summary data analysis, sample data has been provided.  Enter your own values.</p>',
      title = "Summary data: Replace sample data with your own values."
    )
    summary_replace$dependOn("summary_dirty")
    jaspResults[["summary_replace"]] <- summary_replace
    jaspResults[["summary_replace"]]$position <- -5

  }

}
