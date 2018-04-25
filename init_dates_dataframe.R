init_dates_dataframe <- function( yrstart, yrend, startmoy=1, startdoy=1, freq="days", endmoy=12, enddom=31, noleap=FALSE ){

  require(dplyr)
  require(lubridate)

  if (freq=="days"){

    startdate <- ymd( paste0( as.character(yrstart), "-", sprintf( "%02d", startmoy), "-01" ) ) + days( startdoy - 1 )
    enddate   <- ymd( as.Date( paste0( as.character(yrend), "-", sprintf( "%02d", endmoy  ), "-", sprintf( "%02d", enddom  ) ) ) )
    dates     <- seq( from = startdate, to = enddate, by = freq )

    ddf <-  tibble( date=dates ) %>% 
            mutate( ndayyear = ifelse( leap_year( date ), 366, 365 ) ) %>%
            mutate( year_dec = year(date) + ( yday(date) - 1 ) / ndayyear,
                    doy = yday(date) ) %>% 
            select( -ndayyear )

    if (noleap){

      ddf <- ddf %>% filter( !( month(date)==2 & mday(date)==29) )

    }

  } else {

    print( "init_dates_dataframe() only implemented for daily timesteps")

  }

  return( ddf )

}