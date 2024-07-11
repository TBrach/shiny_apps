# benchling_sample_list shiny app

- version: 1.0.0 (2024-05-07)

- **NB: see also CHANGELOG**

## Description of app

- It's a shiny app for making benchling_sample_list_studyname.xlsx files following the conventions in SOP-023.
- How it works (*developer note: most of the descriptions below take place in part02_create_bsl_excel_button.R*):
    - 1.) User chooses the client provided sample list
    - 2.) User sets parameters for reading the excel file correctly:
        - Some parameters are just for recording, such as: "directory of the folder with the sample list". **Please fill this out carefully so the science lead knows exactly what sample list was loaded!** There is unfortunately no smarter way to record the folder on shinyapps.io than requesting user textInput here.
        - sheet, skip, and range are used in cm.read_excel, i.e., in readxl::read_excel: NB, range takes precedence over skip.
    - **Important: The app will only work with the user provided Sample name column and Comment name column**, all other columns in the sample list are ignored, specifically: `from_client <- from_client %>% dplyr::select(sample_name = all_of(sample_name_column), comment_client = any_of(comment_column))`
    - 3.) Create benchling_sample_list:
        - if **CM barcode provided** is ticked: Quote SOP-023: CM provided barcodes must be the sample code. --> App checks if sample name column entries all start with study name underscore, otherwise app complains! sample name is subsequently set to whatever follows study name underscore (`from_client$sample_name <- str_remove(from_client$sample_name, paste0(study_id, "_"))`)
        - The app checks if sample names are unique and complains if not. **It provides non-unique sample names in a table that the user can save in in 4.) to present the list to the client**.
        - The app produces (only in background) a tidy sample name: `sample_name_tidy = clean_string(sample_name)`, and checks again uniqueness
        - The app also generates `sample_name_shortened` from `sample_name_tidy` if possible. This is done by removing uniform positions (i.e., positions that are equal across all samples) by default from the right unless user ticks: `Shorten sample name from left instead of right` --> `sample_code_shortened`
        - Only if the user ticks `Use shortened sample names in sample code` this will be the case, otherwise `sample_name_tidy` is used for the sample code (NB: SOP-023: The sample name can be adapted for the sample code)
        - The final `benchling_sample_list` includes: "sample_code", "sample_name", "comment_client", "sample_code_shortened". "sample_code_shortened" is done by default as it could be used for providers such as Novogene. It is basically a suggestion of a shortened sample code that could be requested by a provider. All user inputs are also saved in separate columns to document how the benchling_sample_list was generated (**AGAIN, therefore it's important to fill out the field "directory of the folder with the sample list" correctly**).
    - 4.) Just use the save button to save `benchling_sample_list_study name.xlsx` on your computer, ideally, directly in `lab/benchling_sample_list`
        
        


