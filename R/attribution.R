# Attribution

attribution <- function(mt_prov){
  paste(paste(
    'Elevation data sources: 3DEP, SRTM, and GMTED2010 content courtesy',
    'of the U.S. Geological Survey and ETOPO1 content courtesy of U.S. National',
    'Oceanic and Atmospheric Administration - via the {elevatr} package', sep=" "),
    paste('Overlay datasources:', maptiles::get_credit(mt_prov),
          "- via the {maptiles} package", sep=" "), sep='; ')
}

