# - set defaults for directory choice (only to document where the sample_list was if user doesn't want to type) -
shinyDirChoose(input, 'dir', roots = c(home = '~', studies = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics"))
# --

# - - 
observe({
  if (!is.null(input$dir)) {
    dir_path <- parseDirPath(c(home = '~', studies = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics"), input$dir)
    # clean from ansi due to color coding in terminal 
    dir_path <- cli::ansi_strip(dir_path)
    rv$dir_path <- dir_path
    output$selected_dir <- renderPrint({dir_path})
  } else {
    dir_path <- NULL
    rv$dir_path <- dir_path
  }
})
# --