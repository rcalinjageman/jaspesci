
jasp_table_fill <- function(jaspTable, esciTable, message = NULL) {


  for (x in 1:nrow(esciTable)) {
    jaspTable$addRows(
      as.list(esciTable[x, ])
    )
  }


  if (!is.null(message)) {
      if (trimws(message) != "") {
        something <- try(jaspTable$addFootnote(message))
      }
  }

  return()
}
