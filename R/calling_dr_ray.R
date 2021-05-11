calling_dr_ray <- function(overlay, elevation, z_sale, ...){

  elmat = rayshader::raster_to_matrix(elevation)

  # NOTE WILL NEE TO INCLUDE ARGS TO ESTIMATE Z SCALE AND ALLOW CUTOMS ADJUSTMENT...
  rayshader::plot_3d(overlay, elmat, zscale=z_sale, ...)

  Sys.sleep(0.2)
}
