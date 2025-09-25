pkgs <- c("readxl","dplyr","janitor","stringr","readr")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

dir.create("data", recursive = TRUE, showWarnings = FALSE)
xlsx_path <- "data/2023 County Health Rankings Data - v2.xlsx"
sheet_use <- "Ranked Measure Data"

stopifnot(file.exists(xlsx_path))

d0 <- readxl::read_excel(xlsx_path, sheet = sheet_use, guess_max = 200000)
d  <- janitor::clean_names(d0)
nms <- names(d)

cand_ob <- nms[grepl("obes", nms, ignore.case = TRUE)]
cand_in <- nms[grepl("inactiv|no[_ ]*leisure", nms, ignore.case = TRUE)]
prefer_val <- function(v){
  keep <- grepl("percent|pct|value$", v, ignore.case = TRUE) &
    !grepl("rank|z|score|stderr|se|ci|lower|upper|num|denom", v, ignore.case = TRUE)
  if (any(keep)) v[keep] else v
}
cand_ob <- prefer_val(cand_ob)
cand_in <- prefer_val(cand_in)

ob_col <- if ("adult_obesity"       %in% nms) "adult_obesity"       else cand_ob[1]
in_col <- if ("physical_inactivity" %in% nms) "physical_inactivity" else cand_in[1]
if (is.na(ob_col) || is.na(in_col)) stop("Pick columns manually from names(d).")

pick_col <- function(nms, candidates){ hit <- intersect(candidates, nms); if (length(hit)) hit[1] else NA_character_ }
fips_col   <- pick_col(nms, c("fips","county_fips","fips_code","county_fips_code"))
state_col  <- pick_col(nms, c("state","state_name","state_abbr","stateabbr"))
county_col <- pick_col(nms, c("county","county_name"))
year_col   <- pick_col(nms, c("year","yr"))

to_pct <- function(x){
  v <- readr::parse_number(as.character(x))
  if (all(is.na(v))) return(v)
  if (suppressWarnings(max(v, na.rm = TRUE)) <= 1.5) v <- v*100
  v
}

clean <- d |>
  dplyr::transmute(
    fips   = if (!is.na(fips_col))   .data[[fips_col]]   else NA,
    state  = if (!is.na(state_col))  .data[[state_col]]  else NA,
    county = if (!is.na(county_col)) .data[[county_col]] else NA,
    year   = if (!is.na(year_col))   .data[[year_col]]   else 2023,
    obesity_pct    = to_pct(.data[[ob_col]]),
    inactivity_pct = to_pct(.data[[in_col]])
  ) |>
  dplyr::filter(dplyr::between(obesity_pct, 0, 100),
                dplyr::between(inactivity_pct, 0, 100))

readr::write_csv(clean, "data/county_health_clean.csv")

model <- clean |>
  dplyr::select(obesity_pct, inactivity_pct) |>
  dplyr::filter(is.finite(obesity_pct), is.finite(inactivity_pct))

readr::write_csv(model, "data/county_health_model.csv")

message("Rows (clean): ", nrow(clean), " | Rows (model): ", nrow(model))
message("Using columns -> obesity: ", ob_col, " | inactivity: ", in_col)