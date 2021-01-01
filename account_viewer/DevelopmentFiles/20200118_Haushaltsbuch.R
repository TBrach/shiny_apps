functionpath <- "~/Shinyappsio/AccountViewer_Combined"
source(file.path(functionpath, "accountViewerFunctions.R"))
datapath <- "~/Shinyappsio/AccountViewer_Combined/account_list"
filename <- "account_list.rds"
account_list <- readRDS(file.path(datapath, filename))
datapath <- "~/Shinyappsio/AccountViewer_Combined/Haushaltsbuch"
accountFile <- "HB_patternTocategory.csv"
df <- read.csv(file = file.path(datapath, accountFile), header = TRUE, stringsAsFactors = FALSE, sep = ";")
df[] <- lapply(df[], str_trim)
df <- unique(df)
#account_list <- rv$account_list
account_colors <- c(cbPalette[2], QuantColors15[6:10])
names(account_colors) <- c("Total", setdiff(names(account_list), "Total"))
# - I left restric accounts out-
# - keep only entries within user defined start and end date -
endDate <- "20200120"
startDate <- "20190826"
endDate <- lubridate::parse_date_time(endDate, orders = "ymd", tz = "CET")
startDate <- lubridate::parse_date_time(startDate, orders = "ymd", tz = "CET")
account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate, Date <= endDate)})
remainingEntries <- lapply(account_list2, nrow)
account_list2 <- account_list2[remainingEntries > 0]
# --
# - put all remaining account entries in one df -
account_df <- do.call("rbind", account_list2) %>% arrange(Date)
# --
# - make a 1 category to PatternList -
categories <- sort(unique(df$category))
names(categories) <- categories
catPatternList <- lapply(categories, function(category){
    data.frame(pattern = paste(df$pattern[df$category == category], collapse = "|"), category = category, stringsAsFactors = FALSE)
})
# --
# - list account entries for each category and make plot_df -
account_list_patterns <- lapply(catPatternList, function(cp){
    out_df <- account_df[str_detect(string = account_df$Text, pattern = cp$pattern), ]
    if (nrow(out_df) > 0){
        out_df$category <- cp$category
    }
    out_df
})
plot_df <- do.call("rbind", account_list_patterns)
plot_df <- dplyr::select(plot_df, Date, Amount, Currency:category) %>% arrange(Date)

# - for second plot -
plot_df2 <- plot_df
# --

plot_df <- group_by(plot_df, category, Account) %>% dplyr::summarize(Amount = sum(Amount), Currency = Currency[1])
# --
# - plot barplot -
Tr <- ggplot(plot_df, aes(x = category, y = Amount))
Tr <- Tr +
    geom_bar(aes(fill = Account), stat = "identity") +
    scale_fill_manual("", values = account_colors) +
    theme_bw(10) +
    xlab("") +
    ylab(paste0("Amount [", sort(unique(plot_df$Currency)), "]")) +
    ggtitle(paste0("From ", startDate, " to ", endDate)) +
    theme(legend.position = "bottom")
# --



#lubridate::wday(plot_df2$Date, label = TRUE)
#strftime(plot_df2$Date, format = "%V", tz = "CET")
plot_df2$Month <- lubridate::month(plot_df2$Date, label = TRUE, abbr = TRUE)
plot_df2$Year <- lubridate::year(plot_df2$Date)
#plot_df2$Week <- strftime(plot_df2$Date, format = "%V", tz = "CET")
#plot_df2$Week <- sprintf(fmt = "%0.2d", plot_df2$Week)

plot_df2$Month_Year <- apply(plot_df2[c("Month", "Year")], 1, paste, collapse=" ")
plot_df2$Month_Year <- factor(plot_df2$Month_Year, levels = paste(levels(plot_df2$Month), rep(sort(unique(plot_df2$Year)), each = length(levels(plot_df2$Month)))))


plot_df2 <- group_by(plot_df2, category, Account, Month_Year) %>% dplyr::summarize(Amount = sum(Amount), Currency = Currency[1])

# - plot barplot -
Tr1 <- ggplot(plot_df2, aes(x = Month_Year, y = Amount))
Tr1 <- Tr1 +
    geom_bar(aes(fill = Account), stat = "identity") +
    facet_grid(category ~ ., scales = "free_y") +
    scale_fill_manual("", values = account_colors) +
    theme_bw(10) +
    xlab("") +
    ylab(paste0("Amount [", sort(unique(plot_df$Currency)), "]")) +
    theme(legend.position = "bottom")
# --



