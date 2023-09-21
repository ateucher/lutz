#' Create a list of Time Zones
#'
#' Output a list of time zone names, with daylight savings time and utc offset
#'
#' @return A data.frame of all time zones on your system. Columns:
#'   - tz_name: the name of the time zone
#'   - zone: time zone
#'   - is_dst: is the time zone in daylight savings time
#'   - utc_offset_h: offset from UTC (in hours)
#' @export
tz_list <- function() {
  big_list <- lapply(lutz_env$olson_names, safe_get_tz_info,
                     yr = format(Sys.Date(), "%Y"))

  big_list <- tz_compact(big_list)

  ret <- do.call("rbind", c(big_list,
                     make.row.names = FALSE,
                     stringsAsFactors = FALSE))

  ret[!is.na(ret$utc_offset_h), , drop = FALSE]
}

#' Find the offset from UTC at a particular date/time in a particular time zone
#'
#' @param dt `Date`, `POSIXt` or date-like character string
#' @param tz A time zone name from [base::OlsonNames()]. Not required if `dt`
#' is a `POSIXt` object with a time zone component.
#'
#' @return a one-row data frame with details of the time zone
#' @export
#'
#' @examples
#' tz_offset("2018-06-12", "America/Moncton")
tz_offset <- function(dt, tz = "") {

  if (!is.character(dt) && !lubridate::is.instant(dt)) {
    stop("dt must be of type POSIXct/lt, Date, or a character", call. = FALSE)
  }

  if (nzchar(tz)) {
    # if tz is supplied, check it is valid
    check_tz(tz)
    # warning if different supplied tz from that in dt
    if (lubridate::is.POSIXt(dt) && nzchar(lubridate::tz(dt)) && tz != lubridate::tz(dt)) {
      warning("tz supplied is different from that in 'dt'. Overwriting with tz.",
              call. = FALSE)
    }
  } else { # if tz not supplied
    # if dt not a POSIXt, bail
    if (is.character(dt) || lubridate::is.Date(dt)) {
      stop("If dt is a character or a Date, you must supply a time zone",
           call. = FALSE)
    } else {
      # if it is a datetime object, extract the time zone attribute
      tz <- lubridate::tz(dt)
      # make sure it's not empty
      if (tz == "") {
        tz <- Sys.timezone()
        warning("You supplied an object of class ", class(dt)[1],
        " that does not have a time zone attribute, and did not specify one in",
        "the 'tz' argument. Defaulting to current (", Sys.timezone(), ").",
             call. = FALSE)
      }
    }
  }

  dt <- lubridate::force_tz(as.POSIXlt(dt), tz)

  # Extract components / attributes of time zone
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


#' Plot a time zone
#'
#' Make a circular plot of a time zone, visualizing the UTC offset over the
#' course of the year, including Daylight Savings times
#'
#' @param tz a valid time zone name. See [OlsonNames()]
#'
#' @return a `ggplot2` object
#' @export
#'
#' @examples
#' tz_plot("America/Vancouver")
tz_plot <- function(tz) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 rquired") #nocov
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
                       ggplot2::aes(x = !!ggplot2::sym("date_time"), y = 1,
                                    colour = !!ggplot2::sym("tz_lab"))) +
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
                         ggplot2::aes(x = !!ggplot2::sym("tz_breaks"), y = 0.85,
                                      label = format(!!ggplot2::sym("tz_breaks"), "%b %d")),
                         hjust = "inward")
  }
  p
}

check_tz <- function(tz) {
  if (!tz %in% lutz_env$olson_names) {
    stop(tz, " is not a valid time zone. See ?OlsonNames",
         call. = FALSE)
  }
}

safe_get_tz_info <- function(tz, yr) {
  dates <- seq(as.Date(paste0(yr,"-01-01"), format = "%Y-%m-%d"),
               as.Date(paste0(yr,"-12-31"), format = "%Y-%m-%d"),
               by = "1 day")
  offs <- try(tz_offset(dates, tz), silent = TRUE)

  if (inherits(offs, "try-error")) return(NULL)

  unique(offs[, setdiff(names(offs), "date_time")])
}
