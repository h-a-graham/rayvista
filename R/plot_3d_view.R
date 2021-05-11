

#' @export
plot_3d_view <- function(lat, long, radius=10000, elevation_detail=14,
                         overlay_detail=14, zscale=15,
                         img_provider ="Esri.WorldImagery",
                         cache_dir=tempdir(), ...){

  #set up cache folder
  cache_sub <- file.path(cache_dir, 'rayvista_cache')
  if (!dir.exists(cache_sub)) dir.create(cache_sub)

  req_extent <- define_extent(lat=lat, long=long, radius=radius)

  map_overlay <- download_overlay(req_extent, overlay_detail, cache_sub,
                                  img_provider)

  elevation_ras <- download_elevation(map_overlay$new_bounds, elevation_detail, cache_sub)

  calling_dr_ray(map_overlay$overlay, elevation_ras, zscale, ...)

}
