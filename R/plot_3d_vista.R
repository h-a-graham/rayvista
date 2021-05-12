#' Generate a 3D scene with an overlay map.
#'
#' This function is a plugin for the {rayshader} package. It opens an {rgl}
#' window displaying the requested 3D scene or vista. further processing of the
#' scene can be carried out using a range of {rayshaer} functions
#'
#' @param lat numeric vector of degrees latitude (WGS84)
#' @param long numeric vecotr of deegrees longitude (WGS84)
#' @param radius numeric vector - the search radius which will define the
#' bounding box area.
#' @param elevation_detail integer between (0:14) passed to
#' `elevatr::get_elevation_raster`. determines the resolution of the returned
#' DEM. see details...
#' @param overlay_detail integer between (0:20) passed to `maptiles::get_tiles`
#' This determines the detail of the imagery. see details...
#' @param img_provider the name of the tile server provider
#' e.g ('Esri.WorldImagery', 'OpenStreetMap). See details
#' @param zscale passed to `rayshader::plot_3d`: Default '1'. The ratio between
#' the x and y spacing (which are assumed to be equal) and the z axis. For
#' example, if the elevation levels are in units of 1 meter and the grid values
#' are separated by 10 meters, 'zscale' would be 10. Adjust the zscale down to
#' exaggerate elevation features. It's very likely you'll need to play with this
#' value...
#' @param cache_dir default is `tempdir()` but you can save your cache locally
#' if desired. if using `tempdir()`, data will be removed when the R session
#' closes.
#' @param outlier_filter numeric between (0:1). default is NULL. sometimes the
#' returned terrain data has erroneous low values. if this occurs set this value
#' to 0.001 or similar to remove 1% of the lowest values.
#' @param ... arguments passed to `rayshader::plot_3d` you'll want use some of
#' these!
#' @details
#' elevation_detail: For details on zoom and resolution see the documentation
#' from Mapzen at https://github.com/tilezen/joerd/blob/master/docs/data-sources.md#what-is-the-ground-resolution.
#'
#' overlay_detail: Zoom levels are described on the OpenStreetMap wiki:
#' https://wiki.openstreetmap.org/wiki/Zoom_levels. Beware go to high and your
#' RAM will get eaten up...
#'
#'img_provider:
#' "OpenStreetMap.MapnikBW", "OpenStreetMap", "OpenStreetMap.DE",
#' "OpenStreetMap.France", "OpenStreetMap.HOT", #' "Stamen.Toner",
#' "Stamen.TonerBackground", "Stamen.TonerHybrid", "Stamen.TonerLines",
#' "Stamen.TonerLabels", "Stamen.TonerLite", "Stamen.Watercolor",
#' "Stamen.Terrain", "Stamen.TerrainBackground", "Stamen.TerrainLabels",
#' "Esri.WorldStreetMap", "Esri.DeLorme", "Esri.WorldTopoMap",
#' "Esri.WorldImagery", "Esri.WorldTerrain", "Esri.WorldShadedRelief",
#' "Esri.OceanBasemap", "Esri.NatGeoWorldMap", "Esri.WorldGrayCanvas",
#' "CartoDB.Positron", "CartoDB.PositronNoLabels", "CartoDB.PositronOnlyLabels",
#' "CartoDB.DarkMatter", "CartoDB.DarkMatterNoLabels",
#' "CartoDB.DarkMatterOnlyLabels", "CartoDB.Voyager", "CartoDB.VoyagerNoLabels",
#' "CartoDB.VoyagerOnlyLabels", "OpenTopoMap","HikeBike", "Wikimedia"
#' see `maptiles::get_tiles` for more info. Thunderforst maps not currently
#' supported.
#'
#' @export
#' @examples
#' .lat <- 57.21956608144513
#' .long <- -6.092690805001252
#'
#' cuillins <- plot_3d_vista(lat = .lat, long = .long)
#' rayshader::render_snapshot(clear=TRUE)

plot_3d_vista <- function(lat, long, radius=7000, elevation_detail=13,
                         overlay_detail=14, img_provider ="Esri.WorldImagery",
                         zscale=2, cache_dir=tempdir(),
                         outlier_filter=NULL, ...){

  #set up cache folder
  cache_sub <- file.path(cache_dir, 'rayvista_cache')
  if (!dir.exists(cache_sub)) dir.create(cache_sub)

  req_extent <- define_extent(lat=lat, long=long, radius=radius)

  map_overlay <- download_overlay(req_extent, overlay_detail, cache_sub,
                                  img_provider)

  elevation_ras <- download_elevation(map_overlay$new_bounds, elevation_detail,
                                      cache_sub, outlier_filter)

  elev_mat <- calling_dr_ray(map_overlay$overlay, elevation_ras, zscale, ...)

  return(elev_mat)

}
