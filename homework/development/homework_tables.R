library(tidyverse)
library(lubridate)


to_do_df <- tibble::tribble(
  ~"area",        ~"item",             ~"frequency",                     ~"done",
  "bathroom",     "clean sink",       lubridate::days(10),                ymd("20240213"),    
  "bathroom",     "clean bathtub",    lubridate::days(10),                ymd("20240213"), 
  "bathroom",     "clean toilet",     lubridate::days(10),                ymd("20240213"), 
  "bryggers",     "piyao",            lubridate::days(4),                 ymd("20240217"), 
  "bryggers",     "clean sink",       lubridate::weeks(4),                ymd("20240208"),
  "kitchen",      "clean fridge",     lubridate::weeks(8),                ymd("20240107"), 
  "kitchen",      "decalcify coffee machine", lubridate::weeks(12),       ymd("20240107"),
  "kitchen",      "clean oven",       lubridate::weeks(20),               ymd("20240107"),
  "kitchen",      "clean afloeb",     lubridate::weeks(52),               ymd("20231107"),
  "kitchen",      "clean sink",       lubridate::days(7),                 ymd("20240218"),
  "living room",  "mop floor",        lubridate::days(14),                ymd("20240203"),
  "living room",  "vacuum floor",        lubridate::days(7),                ymd("20240218"),
  "living room",  "clean windows",    lubridate::weeks(20),                ymd("20240106"),
  "bedroom",      "vacuum floor",        lubridate::days(14),                ymd("20240217"),
  "bedroom",      "mop floor",        lubridate::days(21),                ymd("20240218"),
  "bedroom",      "change bed covers",        lubridate::weeks(3),                ymd("20240128"),
  "bedroom",      "clean windows",        lubridate::weeks(20),                ymd("20240106"),
  "bedroom",      "charge whale",     lubridate::days(5),                 ymd("20240218")
)

to_do_df <- to_do_df %>% dplyr::mutate(due = done + frequency,
                                       `to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)


history_df <- to_do_df %>% dplyr::select(area, item, done)
history_df$done_by <- "Thorsten"

history_df <- history_df %>% dplyr::arrange(desc(done))


out_list <- list(`to_do_df` = to_do_df, `history_df` = history_df)
saveRDS(out_list, "~/shiny_apps/homework/homework.rds") 
