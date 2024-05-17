
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
