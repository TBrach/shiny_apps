# File to generate the default tables that will be used in the lab

library(tidyverse)
library(lubridate)


# Decide what choices you want a default list for =====
sample_type <- c("feces", "feces in buffer", "skin swab", "saliva", "saliva in buffer")
# provided <- c("sample", "extracted DNA")
data_type <- c("shotgun", "16S")
sequencing_provider <- c("Dante", "Novogene", "MiSeq-DK")

choice_combi_df <- expand.grid(sample_type = sample_type,
                               # provided = provided,
                               data_type = data_type,
                               sequencing_provider = sequencing_provider) %>% as_tibble()


choice_combi_df$sequencing_provider[choice_combi_df$data_type == "16S"] <- "MiSeq-DK"
choice_combi_df <- choice_combi_df %>% dplyr::distinct()
choice_combi_df <- choice_combi_df %>% dplyr::filter(! (data_type == "shotgun" & str_detect(sequencing_provider, "MiSeq"))) %>% dplyr::distinct()

choice_combi_df <- choice_combi_df %>% dplyr::mutate(name = paste(sample_type, data_type, sequencing_provider, sep = "_"))


# Manually generate lab plan default list ======

default_lab_plans <- list()


current_protocols <- list.files("~/Downloads/01 Laboratory/", pattern = ".doc|.pdf")
current_protocols <- str_remove(current_protocols, ".docx|.pdf")

protocol_lu <- tibble(Protocol = sort(unique(current_protocols)))

# - all shotgun Dante plans -
default_lab_plans[["feces_shotgun_Dante"]] <- tibble::tribble(
  ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "", "", "",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "DNA quantification &")], "", "", "",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Library preparation")], "", "", "",
  protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Dante, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["feces in buffer_shotgun_Dante"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "use 250 µl of buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "DNA quantification &")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Library preparation")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Dante, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["skin swab_shotgun_Dante"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "DNA quantification &")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Library preparation")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Dante, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["saliva_shotgun_Dante"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "use 250 µl saliva or buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "DNA quantification &")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Library preparation")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Dante, X Gb/sample", "", "yyyy-mm-dd",
)

# default_lab_plans[["extracted DNA_shotgun_Dante"]] <- tibble::tribble(
#     ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
#     protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "DNA quantification &")], "", "", "",
#     protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Library preparation")], "", "", "",
#     protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Dante, X Gb/sample", "", "yyyy-mm-dd",
# )
# --


# - all shotgun Novogene plans -
default_lab_plans[["feces_shotgun_Novogene"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Novogene, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["feces in buffer_shotgun_Novogene"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "use 250 µl of buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Novogene, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["skin swab_shotgun_Novogene"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Novogene, X Gb/sample", "", "yyyy-mm-dd",
)

default_lab_plans[["saliva_shotgun_Novogene"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "use 250 µl saliva or buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Send for analysis")], "Novogene, X Gb/sample", "", "yyyy-mm-dd",
)
# --


# - all 16S plans -
default_lab_plans[["feces_16S_MiSeq-DK"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, " PCR$")], "HF V3-V4, Primers: V3-V4_F1 and V3-V4_R1", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Indexing")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Gel")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Pooling")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Bead")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Qubit")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq library")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq sequencing")], "2x300 bp", "", "",
)

default_lab_plans[["feces in buffer_16S_MiSeq-DK"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading$")], "use 250 µl of buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Stool extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, " PCR$")], "HF V3-V4, Primers: V3-V4_F1 and V3-V4_R1", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Indexing")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Gel")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Pooling")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Bead")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Qubit")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq library")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq sequencing")], "2x300 bp", "", "",
)


default_lab_plans[["skin swab_16S_MiSeq-DK"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, " PCR low")], "V3-V4 low, Primers: V3V4-skin F and V3V4-skin R", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Indexing")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Gel")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Pooling")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Bead")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Qubit")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq library")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq sequencing")], "2x300 bp", "", "",
)


default_lab_plans[["saliva_16S_MiSeq-DK"]] <- tibble::tribble(
    ~"Protocol", ~"Comments", ~"Responsible", ~"Deadline",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Receiving")],"","","",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Loading low")], "use 250 µl saliva or buffer", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Soil extraction$")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, " PCR low")], "V3-V4 low, Primers: V3-V4_F1 and V3-V4_R1", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Indexing")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Gel")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Pooling")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Bead")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "Qubit")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq library")], "", "", "",
    protocol_lu$Protocol[str_detect(protocol_lu$Protocol, "MiSeq sequencing")], "2x300 bp", "", "",
)

# --



# Link options to default lab plans ======
if (!all(names(default_lab_plans) %in% choice_combi_df$name)){stop("all names of default_lab_plans must be in choice_combi_df$name")}
# NB: VERY DANGEROUSLY MANUAL :)
choice_combi_df <- choice_combi_df %>% dplyr::mutate(protocol_name = name)
choice_combi_df$protocol_name[!choice_combi_df$protocol_name %in% names(default_lab_plans)] <- NA
choice_combi_df$protocol_name[is.na(choice_combi_df$protocol_name)] <- choice_combi_df$protocol_name[which(is.na(choice_combi_df$protocol_name)) -1]

if (!all(choice_combi_df$protocol_name %in% names(default_lab_plans))){stop("all protocol_names need to be in default_lab_plans otherwise it will crash")}


# Save to use later in app ======
out_list <- list(`choice_combi_df` = choice_combi_df, `default_lab_plans` = default_lab_plans)
saveRDS(out_list, "~/shiny_apps/lab_plan/input_at_start/lab_plan_app_inputs.rds") 
