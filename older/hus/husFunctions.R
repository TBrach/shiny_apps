# Set the colors!:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
tol15rainbow=c("#114477", "#4477AA", "#77AADD", "#117755", "#44AA88", "#99CCBB", "#777711", "#AAAA44", "#DDDD77", "#771111", "#AA4444", "#DD7777", "#771144", "#AA4477", "#DD77AA") # ref: https://tradeblotter.wordpress.com/2013/02/28/the-paul-tol-21-color-salute/
QuantColors15 <- tol15rainbow[c(1, 12, 4, 7, 13, 2, 11, 5, 8, 14, 3, 10, 6, 9, 15)]

# colorLevels <- c("Other", "Amning", "Affoering", "Deep", "Work", "Learn_Create", "Sport_Motion", "Meditation", "Braintable", "Gefuehlsschule", "Social", "Household", "diary")
# colorValues <- c(Other = cbPalette[1], Amning = "#dccaec", Affoering = "#FDE725FF", Deep = "red", Work = "#440154FF", Learn_Create = "#5DC863FF",
#                  Sport_Motion = "#7F00FF", Meditation = QuantColors15[4], Braintable = "#0f4c81", Gefuehlsschule = "#FDE725FF", 
#                  Social = "#FF7F50", Household = "#21908CFF", diary = "#9FDA3AFF")


# - make a ggplot version of pal -
pal_ggplot <- function(col){
        col <- unname(col) # the naming could cause trouble if NA somehow
        n <- length(col)
        df <- data.frame(xstart = 0:(n-1)/n, xend = 1:n/n, ystart = 0, yend = 1, Fill = sprintf(fmt = "%.5d", 1:n)) # you only end in ordering issues if you want to see more than 10000 colors:)
        Tr <- ggplot(df)
        Tr <- Tr +
                geom_rect(aes(xmin = xstart, xmax = xend, ymin = ystart, ymax = yend, fill = Fill)) +
                scale_fill_manual(values = col) + 
                theme_minimal() +
                theme(legend.position = "none",
                      axis.text = element_blank(),
                      panel.grid = element_blank()) 
        Tr
        
}
# --

show.CM.colors <- function(palette = CM.col$cmcol1, angle = 0) {
        if(is.null(names(palette))) {
                names(palette) <- palette
                labs <- seq_along(palette)
        } else {
                labs <- names(palette)
        }
        data.frame(x = seq_along(palette), col = names(palette), y = 1, lab = labs) %>%
                ggplot(aes(x = x, y = y, fill = col, label = lab)) +
                geom_col() +
                geom_text(y = 0.5, color = "white", fontface = "bold", angle = angle) +
                scale_fill_manual(values = palette) +
                theme_nothing()
}



extract_info_visBolig_boliga <- function(url){
        # url should be a character vector
        # url <- "https://www.boliga.dk/bolig/1700612/granparken_57_2800_kongens_lyngby"
        
        # - get page as character vector -
        get_req <- httr::GET(url)
        page_character <- httr::content(get_req, as = "text", encoding = "UTF-8")
        # boliga_html <- xml2::read_html(get_content)
        # # - could you write it? -
        # xml2::write_xml(boliga_html, file = file.path("~/Downloads", "Testi.xml"), options = "format", encoding = "UTF-8")
        # # --
        # boliga_html %>% rvest::html_node("title") %>% rvest::html_text()
        # boliga_html %>% rvest::html_node("app-property-label _nghost-sc237=")
        # --
        # - extract the info you want -
        # page_character is usually very big,therefore
        # Head <- str_sub(page_character, 1, 1000)
        # -- get Energimaerke --
        Energim <- str_extract(page_character, pattern = "Energimærke: [A-F]{1}") #118644 str_locate_all(page_character, "Energimærke:")
        # --
        # -- get pris --
        Pris <- str_extract(page_character, pattern = "Udbudspris: [0-9.]+? kr")
        # str_locate_all(page_character, pattern = "Udbudspris: [0-9.]+? kr") #190176 weird
        # -- --
        # -- get ejerudgift --
        Ejerudgift <- str_extract(page_character, pattern = "Ejerudgift: [0-9.]+? kr") #119464
        # str_locate(page_character, pattern = "Ejerudgift: [0-9.]*? kr")
        # -- --
        # -- get byggeår --
        Byggear <- str_extract(page_character, pattern = "Byggeår: [0-9]{4}") #117989
        # str_extract_all(page_character, pattern = "Byggeår: [0-9]{4}")
        # str_locate_all(page_character, pattern = "Byggeår: [0-9]{4}")
        # -- --
        # -- get title (adresse, type) --
        Title <- str_extract(page_character, pattern = 'property="og\\:title" content="(.*?)"')
        # -- --
        # -- get Boligstoerrelse --
        Boligstoerrelse <- str_extract(page_character, pattern = "Boligstørrelse: [0-9]+") #114849
        # str_locate_all(page_character, pattern = "Boligstørrelse: [0-9]+")
        # --
        # -- get Boligstoerrelse --
        Grundstoerrelse <- str_extract(page_character, pattern = "Grundstørrelse: [0-9.]+") #115523
        # str_locate_all(page_character, pattern = "Grundstørrelse: [0-9]+")
        # --
        # -- get Kaelderstoerrelse --
        Kaeldertoerrelse <- str_extract(page_character, pattern = "Kælderstørrelse: [0-9.]+") #120147
        # str_locate_all(page_character, pattern = "Kælderstørrelse: [0-9]+")
        # --
        # -- get antal vaerelser --
        AntalVaerelser <- str_extract(page_character, pattern = "[0-9]+ værelser") # 116183
        # str_locate_all(page_character, pattern = "[0-9]+ værelser")
        # -- --
        # --
        Comment <- ""
        # - the thing with the link copied from ibenerary -
        Title = str_remove(str_remove(Title, pattern = 'property=\"og:title\" content=\"'), pattern = ' til salg\"')
        Link <- paste0("<a href='", url, "' target='_blank'>", Title, "</a>")
                # Ref <- as.character(tags$a(href = Link, target = Name)) # alternative via tags, but needed to be corrected
        # --
        # - put into a data frame -
        
        entry <- data.frame(Title = Title,
                            Byggear = str_extract(Byggear, "[0-9]+"),
                            Pris = str_extract(str_remove_all(Pris, "\\."), "[0-9]+"),
                            Ejerudgift = str_extract(str_remove_all(Ejerudgift, "\\."), "[0-9]+"),
                            Energimaerke = str_extract(Energim, "[A-F]$"),
                            Bolig_m2 = str_extract(Boligstoerrelse, "[0-9]+"),
                            Grund_m2 = str_extract(str_remove_all(Grundstoerrelse, "\\."), "[0-9]+"),
                            Kaelder_m2 = str_extract(str_remove_all(Kaeldertoerrelse, "\\."), "[0-9]+"),
                            AntalVaerelser = str_extract(AntalVaerelser, "[0-9]+"),
                            Comment = Comment,
                            Link = Link)
        entry$PrisPerm2 <- as.character(round(as.numeric(entry$Pris)/as.numeric(entry$Bolig_m2),0))
        # --
        dplyr::select(entry, Title:Pris, Bolig_m2, PrisPerm2, Grund_m2, Energimaerke, everything())
}
