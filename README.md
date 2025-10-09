# Physical Inactivity and Adult Obesity in U.S. Counties  
**Author:** Abhiram Bhokre  
**Date:** October 2025  

## Project Overview

This project investigates whether county-level **physical inactivity** is associated with **adult obesity** across U.S. counties using data from the **2023 County Health Rankings & Roadmaps (CHR&R)** dataset.  

A **simple linear regression (SLR)** model was fitted with:
- **Dependent variable:** Adult obesity rate (% of adults with BMI ≥ 30)
- **Independent variable:** Physical inactivity rate (% of adults reporting no leisure-time physical activity)

The project quantifies the relationship between inactivity and obesity, checks model assumptions, and evaluates robustness using heteroskedasticity-consistent (HC1) standard errors.  

This paper and accompanying code were submitted as part of the **Regression Theory (Math 261A)** course at **San José State University**.

---

## Repository Structure

```text
Math_261A_Paper_1/
├── Analysis/
│   ├── data_preprocessor.R
│   ├── lr_model.R                     
├── data/
│   ├── 2023 County Health Rankings Data - v2.xlsx
│   ├── county_health_clean.csv                     
│   └── county_health_model.csv                     
│   ├── county_ols_coefficients.csv                 
│   └── county_ols_glance.csv 
│   └── county_predictions.csv
├── fig/
│   └── county_scatter.png
├── paper/
│   ├── paper.qmd      
│   └── paper.pdf
│   ├── paper.tex      
│   └── references.bib 
└── README.md                   # Project documentation (this file)
```
---

## Data Source

**Dataset:** County Health Rankings & Roadmaps (CHR&R) 2023  
**Publisher:** University of Wisconsin Population Health Institute  
**License:** [Open Data Commons Attribution License (ODC-By 1.0)](https://opendatacommons.org/licenses/by/1-0/)  
**Access Link:** [https://www.countyhealthrankings.org/](https://www.countyhealthrankings.org/)  

Each row in the dataset represents a **U.S. county**, including indicators on health outcomes and behaviors.  
For this analysis, only *adult obesity (%)* and *physical inactivity (%)* were used.

---

## Statistical Methods

The fitted model used for this analysis is a **Simple Linear Regression (SLR)** defined as:

```math
\text{Obesity}_i = \beta_0 + \beta_1\,\text{Inactivity}_i + \varepsilon_i
```
where:

Obesityᵢ — Percentage of adults with BMI ≥ 30 in county i

Inactivityᵢ — Percentage of adults reporting no leisure-time physical activity

β₀ (Intercept) — Expected obesity percentage when inactivity is zero

β₁ (Slope) — Change in obesity (percentage points) per one–percentage–point increase in inactivity

εᵢ — Random error term capturing unobserved influences

---

## Use of LLMs

This project made limited use of **Large Language Models (LLMs)** to assist with:
- Initial brainstorming for research on project topic/dataset 
- Formatting the README, Quarto syntax, and LaTeX equations  

All analysis, code execution, interpretation, and writing decisions were independently verified by the author.

---

##  License

This project is distributed under the terms of the **MIT License**.  
You are free to use, modify, and distribute the materials provided that proper attribution is given.

- **Dataset License:** [Open Data Commons Attribution License (ODC-By 1.0)](https://opendatacommons.org/licenses/by/1-0/)  
- **Software License:** [MIT License](https://opensource.org/licenses/MIT)

---

## Acknowledgments

Special thanks to:
- **Professor Dr. Peter A. Gao**, San José State University — for guidance on statistical modeling and reproducibility standards.  
- **R Core Team (2024)** — for providing the open-source software environment used in this analysis.  
- **County Health Rankings & Roadmaps (2023)** — for making publicly available the dataset that forms the foundation of this study.

---



