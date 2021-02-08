# values: https://github.com/krose/boliga/blob/master/R/boliga_clean_address.R
# library(devtools)
# library(boliga)
# if(!require(boliga)){
#     install_github("krose/boliga")
# }


library(tidyverse)



extract_infor_visBolig_boliga <- function(url = "https://www.boliga.dk/bolig/1700612/granparken_57_2800_kongens_lyngby"){
    
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
    Grundstoerrelse <- str_extract(page_character, pattern = "Grundstørrelse: [0-9]+") #115523
    # str_locate_all(page_character, pattern = "Grundstørrelse: [0-9]+")
    # --
    # -- get Kaelderstoerrelse --
    Kaeldertoerrelse <- str_extract(page_character, pattern = "Kælderstørrelse: [0-9]+") #120147
    # str_locate_all(page_character, pattern = "Kælderstørrelse: [0-9]+")
    # --
    # -- get antal vaerelser --
    AntalVaerelser <- str_extract(page_character, pattern = "[0-9]+ værelser") # 116183
    # str_locate_all(page_character, pattern = "[0-9]+ værelser")
    # -- --
    # --
    # - put into a data frame -
    
    entry <- data.frame(Title = str_remove(str_remove(Title, pattern = 'property=\"og:title\" content=\"'), pattern = ' til salg\"'),
                        Byggear = str_extract(Byggear, "[0-9]+"),
                        Pris = str_extract(str_remove_all(Pris, "\\."), "[0-9]+"),
                        Ejerudgift = str_extract(str_remove_all(Ejerudgift, "\\."), "[0-9]+"),
                        Energimaerke = str_extract(Energim, "[A-F]$"),
                        Bolig_m2 = str_extract(Boligstoerrelse, "[0-9]+"),
                        Grund_m2 = str_extract(Grundstoerrelse, "[0-9]+"),
                        Kaelder_m2 = str_extract(Kaeldertoerrelse, "[0-9]+"),
                        AntalVaerelser = str_extract(AntalVaerelser, "[0-9]+"))
    # --
    entry
}

# - learn how to work with get_xml using xml2 package -
Nodes <- xml2::as_list(get_xml)
class(Nodes) # list
class(Nodes$html) # list
class(Nodes$html$head)
length(Nodes$html$head)

xml2::xml_document(get_xml)
all_nodes <- xml2::xml_contents(get_xml)
all_children <- xml2::xml_children(get_xml) 
identical(all_nodes, all_children) # TRUE
all_children_of_nodes <- xml2::xml_children(all_nodes) 
xml2::xml_ns(get_xml)
xml2::write_xml(all_children_of_nodes[[1]], file = file.path("~/Downloads", "Testi.xml"))
xml2::xml_attrs(get_xml, ns = character())


rvest::html_nodes(get_xml, all_nodes[[2]])

orderDoc <-  xml2::xml2_example("order-doc.xml")
