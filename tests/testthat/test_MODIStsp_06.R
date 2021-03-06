### Test 6: test of http download and mosaicing of MODIS tiles               ####
#   This test downloads four MCD LAI products (MCD15A2H) from http and mosaics
#   them and crop to the output extent (Minorca island).
#   After reprojection in geographic coordinates, output files are exported
#   as GeoTiff (scaling output values) and vrt time series are created.

context("MODIStsp Test 6: http download on \"combined\" datasets and mosaicing of MODIS tiles") #nolint
testthat::test_that(
  "Tests on MODIStsp", {
    skip_on_cran()
    # skip_on_travis()

    MODIStsp(test = 6)
    out_files_dat <- list.files(
      file.path(tempdir(), "MODIStsp/LAI_8Days_500m_v6"),
      pattern = "\\.tif$", recursive = TRUE, full.names = TRUE)
    file_sizes_dat <- file.info(out_files_dat)$size
    expect_equal(file_sizes_dat, c(1633, 1611))
    means <- unlist(
      lapply(out_files_dat,
             FUN = function(x) {
               mean(raster::getValues(raster::raster(x)), na.rm = T)
             })
    )
    expect_equal(means, c(14.9886548, 14.9802337), tolerance = 0.001, scale = 1)
    r <- raster::raster(out_files_dat[1])
    expect_equal(
      sp::proj4string(r),
      "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
    )
    expect_equal(raster::res(r), c(0.01, 0.01), tolerance = 0.001, scale = 1)
    # re-run with same parameterization. Since Reprocess = "No", the
    # auto-skipping of already processed dates kicks-in in this case, leading
    # the process to be very quick (Only MODIStso_vrt_create needs to run. )
    context("MODIStsp Test 6: No Reprocessing works as expected")
    t1 <- Sys.time()
    MODIStsp(test = 6)
    tt <- Sys.time() - t1
    expect_true(tt < 5)
    unlink(file_sizes_dat)
  }
)
