init_dates_dataframe <- function( yrstart, yrend, startmoy=1, startdoy=1, freq="days", endmoy=12, enddom=31, noleap=FALSE ){

  require(dplyr)

  if (freq=="days"){

    if (noleap){

      ndaymonth <- c(31,28,31,30,31,30,31,31,30,31,30,31)
      ndayyear <- sum(ndaymonth) 
      nmonth   <- length(ndaymonth)
      nyrs    <- length( yrstart:yrend )
      dm   <- rep( NA, sum(ndaymonth)*length(yrstart:yrend) )
      jdx <- 0
      for (yr in yrstart:yrend ){
        for (imoy in 1:nmonth){
          for (idm in 1:ndaymonth[imoy]){
            jdx <- jdx + 1 
            dm[jdx]   <- idm
          }
        }
      }
      ddf <-  tibble( 
                      doy=rep( seq(ndayyear), nyrs ), 
                      moy=rep( rep( seq(nmonth), times=ndaymonth ), times=nyrs ),
                      dom=dm,
                      year=rep( yrstart:yrend, each=ndayyear )
                      ) %>% 
              mutate( year_dec = year + ( doy - 1 ) / 365,
                      date = as.POSIXct( as.Date( paste0( as.character(year), "-", sprintf( "%02d", moy), "-", sprintf( "%02d", dom) ) ) ) )

    } else {

      startdate <- ymd( paste0( as.character(yrstart), "-", sprintf( "%02d", startmoy), "-01" ) ) + days( startdoy - 1 )
      enddate   <- ymd( as.Date( paste0( as.character(yrend  ), "-", sprintf( "%02d", endmoy  ), "-", sprintf( "%02d", enddom  ) ) ) )
      dates     <- seq( from = startdate, to = enddate, by = freq )

      ddf <-  tibble( date=dates ) %>% 
              mutate( ndayyear = ifelse( (year(date) %% 4) == 0, 366, 365  ) ) %>%
              mutate( year_dec = year(date) + ( yday(date) - 1 ) / ndayyear,
                      doy = yday(date) ) %>% 
              select( -ndayyear )

    }

  } else {

    print( "init_dates_dataframe() only implemented for daily timesteps")

  }

  return( ddf )

}