define_extent <- function(lat, long, radius, epsg){
  extent_sf <- sf::st_sfc(sf::st_point(c(long, lat))) %>%
    sf::st_set_crs(epsg) %>%
    sf::st_transform(3857) %>%
    sf::st_buffer(radius)%>%
    sf::st_bbox()%>%
    sf::st_as_sfc()%>%
    sf::st_sf()

  return(extent_sf)
}


