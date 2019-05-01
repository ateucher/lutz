tz_list <- function() {
  yr <- format(Sys.Date(), "%Y")
  big_list <- lapply(lutz_env$olson_names, function(tz) {
    dates <- seq(as.Date(paste0(yr,"-01-01"), format = "%Y-%m-%d"),
                 as.Date(paste0(yr,"-12-31"), format = "%Y-%m-%d"),
                 by = "1 day")
    offs <- tz_offset(dates, tz)
    unique(offs[, setdiff(names(offs), "date_time")])
  })

  do.call("rbind", c(big_list,
                     make.row.names = FALSE,
                     stringsAsFactors = FALSE))
}

tz_offset <- function(dt, tz = "") {

  if (!is.character(dt) && !lubridate::is.instant(dt)) {
    stop("dt must be of type POSIXct/lt, Date, or a character", call. = FALSE)
  }

  if (nzchar(tz)) {
    # if tz is supplied, check it is valid
    check_tz(tz)
    # warning if different supplied tz from that in dt
    if (lubridate::is.POSIXt(dt) && tz != lubridate::tz(dt)) {
      warning("tz supplied is different from that in 'dt'. Overwriting with tz.",
              call. = FALSE)
    }
  } else { # if tz not supplied
    # if dt not a POSIXt, bail
    if (is.character(dt) || lubridate::is.Date(dt)) {
      stop("If dt is a character or a Date, you must supply a timezone",
           call. = FALSE)
    } else {
      # if it is a datetime object, extract the timezone attribute
      tz <- lubridate::tz(dt)
      # make sure it's not empty
      if (tz == "") {
        stop("You supplied an object of class ", class(dt)[1], " that does not have a
         timezone attribute, and did not specify one in the 'tz' argument",
             call. = FALSE)
      }
    }
  }

  dt <- lubridate::force_tz(as.POSIXlt(dt), tz)

  # Extract components / attributes of timezone
  utc_offset <- dt$gmtoff
  zone <- dt$zone
  is_dst <- lubridate::dst(dt)
  utc_offset[is.null(utc_offset)] <- 0L
  zone[is.null(zone)] <- NA_character_

  data.frame(tz_name = tz,
             date_time = as.POSIXct(dt),
             zone,
             is_dst = is_dst,
             utc_offset_h = utc_offset / 3600,
             stringsAsFactors = FALSE,
             row.names = NULL)
}
#
# get_tz_list()
#
# get_tz_offset("2018-06-12", "America/Moncton")


plot_tz <- function(tz) {
  if (!requireNamespace("ggplot2")) {
    stop("ggplot2 rquired")
  }

  check_tz(tz)

  yr <- format(Sys.Date(), "%Y")
  date_seq <- seq(as.Date(paste0(yr, "-01-01")),
                  as.Date(paste0(yr, "-12-31")),
                  by = "1 day")
  tz_data <- tz_offset(date_seq, tz)

  tz_data$date_time <- as.Date(tz_data$date_time)
  tz_data$tz_lab <- paste0(tz_data$zone, " (",
                           ifelse(sign(tz_data$utc_offset_h) == 1, "+", ""),
                           tz_data$utc_offset_h, "h)")

  # Find where the offset changes
  break_indices <- cumsum(rle(tz_data$utc_offset_h[order(tz_data$date_time)])$lengths)
  break_indices <- break_indices[-length(break_indices)] + 1

  label_df <- data.frame(tz_breaks = tz_data$date_time[break_indices])

  p <- ggplot2::ggplot(tz_data,
                       ggplot2::aes(x = date_time, y = 1, colour = tz_lab)) +
    ggplot2::geom_point(size = 5) +
    ggplot2::coord_polar() +
    ggplot2::scale_y_continuous(breaks = c(0,1), limits = c(0,1.1)) +
    ggplot2::scale_x_date(date_breaks = "1 month",
                          date_labels = "%b %d") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.ticks = ggplot2::element_blank(),
                   axis.title = ggplot2::element_blank(),
                   axis.text.y = ggplot2::element_blank(),
                   axis.text.x = ggplot2::element_text(),
                   panel.grid.major.y = ggplot2::element_blank(),
                   legend.position = "top") +
    ggplot2::labs(title = paste(tz_data$tz_name[1], "Time Zone"),
                  colour = "Zone (UTC offset)")

  if (length(break_indices)) {
    p <- p +
      ggplot2::geom_text(data = label_df, inherit.aes = FALSE,
                         ggplot2::aes(x = tz_breaks, y = 0.85,
                                      label = format(tz_breaks, "%b %d")),
                         hjust = "inward")
  }
  p
}

check_tz <- function(tz) {
  if (!tz %in% lutz_env$olson_names) {
    stop(tz, " is not a valid timezone. See ?OlsonNames",
         call. = FALSE)
  }
}
