#' Generate a 3D scene with an overlay map.
#'
#' This function is a plugin for the {rayshader} package. It opens an {rgl}
#' window displaying the requested 3D scene or vista. Further processing of the
#' scene can be carried out using a range of {rayshader} functions
#'
#' @param lat numeric vector of degrees latitude (WGS84)
#' @param long numeric vector of degrees longitude (WGS84)
#' @param radius numeric vector - the search radius which will define the
#' bounding box area.
#' @param req_area Default is `NULL`. If desired, you can porvide an {sf} obect
#' or an sf readable file path. If used, lat/long/radius are ignored. Must have
#' a valid CRS.
#' @param dem Default is `NULL`. If desired you can provide your own elevation
#' data here. If used, lat/long/radius are ignored. should be a RasterLayer or
#' SpatRaster object or {raster} readable elevation file path.
#' @param elevation_detail Default is `13`. Integer between (0:14) passed to
#' `elevatr::get_elevation_raster`. determines the resolution of the returned
#' DEM. see details...
#' @param overlay_detail Default is `13`. Integer between (0:20) passed to
#' `maptiles::get_tiles`. Values over 16 are likely to cause issues...
#' @param overlay_alpha Default is `1`. Numeric vector between 0 and 1. Sets the
#' value of the alpha channel of the overlay; 0 is transparent, 1 is solid.
#' This is particualrly useful when working with`rayshader::add_overlay`.
#' @param elevation_src Default is `aws`. passed to `elevatr::get_elev_raster`.
#' A character indicating which API to use. Currently supports "aws", "gl3",
#' "gl1", "alos" or 'srtm15plus' from the OpenTopography API global datasets.
#' This determines the detail of the imagery. see details...
#' @param img_provider Default is 'Esri.WorldImagery'. The name of the tile
#' server provider. See details for other options
#' @param zscale passed to `rayshader::plot_3d`: Default is `2`. The ratio between
#' the x and y spacing (which are assumed to be equal) and the z axis. For
#' example, if the elevation levels are in units of 1 meter and the grid values
#' are separated by 10 meters, 'zscale' would be 10. Adjust the zscale down to
#' exaggerate elevation features. It's very likely you'll need to play with this
#' value...
#' @param cache_dir default is `tempdir()` but you can save your cache locally
#' if desired. if using `tempdir()`, data will be removed when the R session
#' closes.
#' @param fill_holes Default `FALSE`. Fills NA values in DEM. Can be slow in
#' coastal regions, in which case set to FALSE.
#' @param outlier_filter numeric between `(0:1)`. default is NULL. sometimes the
#' returned terrain data has erroneous low values. if this occurs set this value
#' to 0.001 or similar to remove 1\% of the lowest values.
#' @param epsg default is `4326`. This is EPSG value for the input coordinates
#' and is used to define the returned matrix's extent attribute. HERE BE
#' DRAGONS! the use of other crs values is very experimental...
#' @param show_vista default is `TRUE`. If FALSE then no rgl window is opened.
#' Instead, the texture (image array) and elevation matrix are returned in a
#' named list with names: 'texture' and 'dem_matrix'
#' @param api_key default is `NULL`. Only required if requesting thunderforest
#' overlay (see details). You can get an API key here: https://www.thunderforest.com/docs/apikeys/
#' @param ... arguments passed to `rayshader::plot_3d` you'll want use some of
#' these!
#' @return Either:  A matrix with four attributes: 'extent', 'crs' and
#' 'resolution' and 'attribution'. Resolution is provided in m regardless of
#' the requested crs. OR if `show_vista = FALSE` then a list is returned
#' including the named items: 'texture' and 'dem_matrix' which can be used to
#' customising the vista before using `rayshader::plot_3d`.
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
#' "CartoDB.VoyagerOnlyLabels", "Thunderforest.OpenCycleMap",
#' "Thunderforest.Transport", "Thunderforest.TransportDark",
#' "Thunderforest.SpinalMap", "Thunderforest.Landscape",
#' "Thunderforest.Outdoors", "Thunderforest.Pioneer",
#' "Thunderforest.MobileAtlas", "Thunderforest.Neighbourhood","OpenTopoMap",
#' "HikeBike", "Wikimedia".See `maptiles::get_tiles` for more info.
#' @return A elevation matrix including 'extent' and 'crs' attributes.
#' @export
#' @examples
#' .lat <- 57.21956608144513
#' .long <- -6.092690805001252
#'
#' cuillins <- plot_3d_vista(lat = .lat, long = .long)
#' rayshader::render_snapshot(clear=TRUE)

plot_3d_vista <- function(lat, long, radius=7000, req_area=NULL, dem=NULL,
                          elevation_detail=13, overlay_detail=13, overlay_alpha=1,
                          elevation_src='aws', img_provider="Esri.WorldImagery",
                          zscale=2, cache_dir=tempdir(), fill_holes=FALSE,
                          outlier_filter=NULL, epsg=4326, show_vista=TRUE,
                          api_key=NULL, ...){

  # check arguments: For now just returning the finalised cache directory
  checked_args <- arg_checks(cache_dir, img_provider, api_key, req_area, dem,
                          elevation_detail, overlay_detail)

  cache_sub <- checked_args$cache_sub
  elevation_detail <- checked_args$elevation_detail



  # set up initial extent
  if (!is.null(req_area)){
    req_extent <- define_extent_sf(req_area)
  } else if (!is.null(dem)) {
    dem_stuff <- define_extent_dem(dem)
    req_extent <- dem_stuff$dem_extent
    dem <- dem_stuff$dem
  }
  else {
    req_extent <- define_extent(lat=lat, long=long, radius=radius, epsg=epsg)
  }


  # get tiles for map overlay
  map_overlay <- download_overlay(req_extent, overlay_detail, cache_sub,
                                  img_provider, api_key, dem, overlay_alpha)

  # get DEM
  if (is.null(dem)) {
    elevation_ras <- download_elevation(map_overlay$new_bounds, elevation_detail,
                                        elevation_src, cache_sub, outlier_filter,
                                        fill_holes)
  } else {
    elevation_ras <- dem
  }


  # run rayshader function and or return matrix.
  elev_mat <- calling_dr_ray(map_overlay$overlay, elevation_ras, zscale, epsg,
                             img_provider, show_vista, ...)

  # final returns.
  if (isTRUE(show_vista)){
    return(elev_mat)
  } else {
    return(list(texture=map_overlay$overlay, dem_matrix=elev_mat))
  }


}
