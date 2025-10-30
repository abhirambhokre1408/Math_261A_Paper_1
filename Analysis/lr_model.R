pkgs <- c("readr","dplyr","ggplot2","broom")
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

robust_ok <- TRUE
tryCatch({
  if (!"sandwich" %in% rownames(installed.packages())) install.packages("sandwich", repos="https://cloud.r-project.org")
  if (!"lmtest"   %in% rownames(installed.packages())) install.packages("lmtest",   repos="https://cloud.r-project.org")
  library(sandwich); library(lmtest)
}, error=function(e){ robust_ok <<- FALSE })

dir.create("fig", recursive = TRUE, showWarnings = FALSE)
dir.create("data", recursive = TRUE, showWarnings = FALSE)

d <- readr::read_csv("data/county_health_model.csv", show_col_types = FALSE)

m <- lm(obesity_pct ~ inactivity_pct, data = d)
ols_tidy   <- broom::tidy(m, conf.int = TRUE)
ols_glance <- broom::glance(m)
readr::write_csv(ols_tidy,   "data/county_ols_coefficients.csv")
readr::write_csv(ols_glance, "data/county_ols_glance.csv")
print(ols_tidy); print(ols_glance)

if (robust_ok) {
  cat("\n--- Robust SEs (HC1) ---\n")
  print(lmtest::coeftest(m, vcov = sandwich::vcovHC(m, type="HC1")))
}
xg <- tibble::tibble(
  inactivity_pct = seq(floor(min(d$inactivity_pct, na.rm=TRUE)),
                       ceiling(max(d$inactivity_pct, na.rm=TRUE)),
                       by = 0.1)
)
p_conf <- predict(m, newdata = xg, se.fit = TRUE, interval = "confidence")
ci <- cbind(xg, as.data.frame(p_conf$fit)); ci$se_fit <- as.numeric(p_conf$se.fit)
p_pred <- predict(m, newdata = xg, interval = "prediction")
pi <- as.data.frame(p_pred); names(pi) <- paste0(names(pi), "_pi")
pred <- dplyr::bind_cols(ci, pi)
readr::write_csv(pred, "data/county_predictions.csv")
p <- ggplot(d, aes(inactivity_pct, obesity_pct)) +
  geom_point(alpha = 0.25, size = 1) +
  geom_smooth(method = "lm", se = TRUE, color = "blue") +
  labs(
    title = "Adult Obesity (%) vs Physical Inactivity (%) — U.S. Counties (2023)",
    x = "Physical inactivity (%)", y = "Adult obesity (%)"
  ) +
  theme_minimal(base_size = 12)
ggsave("fig/county_scatter.png", p, width = 7, height = 5, dpi = 300)

diag <- broom::augment(m)  # adds .fitted, .resid, .hat, .cooksd (if available)
diag$cooks <- cooks.distance(m)
p_res <- ggplot(diag, aes(x = .fitted, y = .resid)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    title = "Residuals vs Fitted — Adult Obesity ~ Physical Inactivity",
    x = "Fitted values (Predicted Adult Obesity, %)",
    y = "Residuals"
  ) +
  theme_minimal(base_size = 12)

ggsave("fig/residuals_vs_fitted.png", p_res, width = 7, height = 5, dpi = 300)
cook_threshold <- 4 / nrow(diag)  # common rule-of-thumb threshold
p_cook <- ggplot(diag, aes(x = seq_along(cooks), y = cooks)) +
  geom_col(alpha = 0.8) +
  geom_hline(yintercept = cook_threshold, linetype = "dashed", color = "gray40") +
  labs(
    title = "Cook's Distance — Assessing Influential Observations",
    x = "Observation index (county)",
    y = "Cook's Distance"
  ) +
  theme_minimal(base_size = 12)

ggsave("fig/cooks_distance.png", p_cook, width = 7, height = 5, dpi = 300)


