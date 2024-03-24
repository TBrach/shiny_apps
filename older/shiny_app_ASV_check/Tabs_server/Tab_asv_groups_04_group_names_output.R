# - output infoText -
output$asv_group_names <- renderText({
        if (is.null(rv$group_list)){
          "no asv groups"
        } else {
          paste(names(rv$group_list), collapse = ", ")
        }
})

output$found_asv_group_names <- renderText({
  if (is.null(rv$hit_group_list)){
    NULL
  } else {
    paste(names(rv$hit_group_list), collapse = ", ")
  }
})

# output$infoText2 <- renderText({
#   rv$infoText
# })
# --