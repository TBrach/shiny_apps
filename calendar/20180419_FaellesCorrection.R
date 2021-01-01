# Correction of Faelles.rds 20180419
# to reduce the color levels, and get rid of Danish letters in factors that are used in plots, such as color

Faelles <- readRDS(file = file.path("/Users/jvb740/Downloads", "Faelles.rds"))

Faelles$Color <- as.character(Faelles$Color)
Faelles$Name <- as.character(Faelles$Name)
Faelles$Name[grepl("vsuge_Th", Faelles$Name)] <- "stoevsuge_Th"
Faelles$Name[grepl("vsuge_Ib", Faelles$Name)] <- "stoevsuge_Th"
# Faelles$Name[grepl("vsuge", Faelles$Color)]
Faelles$Color[grepl("vsuge", Faelles$Color)] <- "Done_stoevsuge"
Faelles$Color[grepl("activity", Faelles$Color)] <- "Faelles"
Faelles$Color[Faelles$Color == "other"] <- "Other"
# unique(Faelles$Color)
Faelles$Color <- factor(Faelles$Color, levels = c("Faelles", "Iben", "Thorsten", "Other", "Done_kat", "Done_stoevsuge", "Done_other", "background"), ordered = TRUE)

Faelles$Name[is.na(Faelles$Color)] <- "imagine"
Faelles$Color[is.na(Faelles$Color)] <- "Other"

Faelles$Color[Faelles$Color == "Done_other"] <- "Other"

saveRDS(Faelles, file = file.path("/Users/jvb740/Downloads", "Faelles.rds"))
