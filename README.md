# MKstat [<img src="man/figures/MKstat.png" align="right" width=160 height=160 alt=""/>](https://makaho.sk8.inrae.fr/)

<!-- badges: start -->
[![R-CMD-check](https://github.com/super-lou/MKstat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/super-lou/MKstat/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-green)](https://lifecycle.r-lib.org/articles/stages.html)
![](https://img.shields.io/github/last-commit/super-lou/Mkstat)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](code_of_conduct.md) 
<!-- badges: end -->

**MKstat** is a **R package** which its main objective is to provide an efficient and simple solution to **analyze the stationarity** of time series.

This project was carried out for National Research Institute for Agriculture, Food and the Environment (Institut National de Recherche pour l’Agriculture, l’Alimentation et l’Environnement, [INRAE](https://agriculture.gouv.fr/inrae-linstitut-national-de-recherche-pour-lagriculture-lalimentation-et-lenvironnement) in french).


## Installation

For latest development version

``` r
remotes::install_github('super-lou/MKstat')
```


## Documentation

### Extraction process

Based on [dplyr](https://dplyr.tidyverse.org/), **input data** format is a `tibble` of at least a column of **date**, a column of **numeric value** and a **character** column for names of time series in order to identify them. Thus it is possible to have a `tibble` with multiple time series which can be grouped by their names.

For example, we can use the following `tibble` : 

``` r
library(dplyr)

# Date
Start = as.Date("1972-01-01")
End = as.Date("2020-12-31")
Date = seq.Date(Start, End, by="day")

# Value to analyse
set.seed(100)
X = seq(1, length(Date))/1e4 + runif(length(Date), -100, 100)
X[as.Date("2000-03-01") <= Date & Date <= as.Date("2000-09-30")] = NA

# Creation of tibble
data = tibble(Date=Date, ID="serie A", X=X)
```

The process of **variable extraction** (for example the yearly mean of time series) is realised with the `extraction_process()` function.
Minimum arguments are :
* Input `data` described above
* The function `funct` (for example `mean`) you want to use. Arguments of the chosen function can be passed to this extraction process and the function can be previously defined.

Optional arguments are :
* `period` A vector of two date to restrict the period of analysis
* `timeStep` A character chain which can be `"year"` for yearly extraction and `"year-month"` for monthly extraction along years
* `samplePeriod` A vector of two character chains to precise the sampling of the extraction (for example, in a yearly extraction, `c("05-01", "11-30")` will use only the data from the 1st of may to the 30th of november). It can also just be a simple character chain (as `"02-01"` in a yearly extraction) to start the sampling the 1st of february and to end it the 31th of january (hence it is similar to `c("02-01", "01-31")`).

In this way ...
``` r
dataEx = extraction_process(data=data,
                            samplePeriod=c("05-01",
                                           "11-30"),
                            funct=max,
                            na.rm=TRUE,
                            period=c(as.Date("1990-01-01"),
                                     as.Date("2020-12-31")),
                            timeStep="year")
```

will perform a yearly extraction of the maximum value between may and november, from the 1th march of 1990 to the 31th october of 2020, ignoring `NA` values.

The output is also a `tibble` with a column of **date**, of **character** for the name of time series and a **numerical** column with the extracted variable from the time series.

```
> dataEx
# A tibble: 31 × 4
   ID      Date           X NA_pct
   <chr>   <date>     <dbl>  <dbl>
 1 serie A 1990-05-01 100.       0
 2 serie A 1991-05-01 101.       0
 3 serie A 1992-05-01 100.       0
 4 serie A 1993-05-01  99.9      0
 5 serie A 1994-05-01  99.0      0
 6 serie A 1995-05-01 100.       0
 7 serie A 1996-05-01 100.       0
 8 serie A 1997-05-01 101.       0
 9 serie A 1998-05-01  99.6      0
10 serie A 1999-05-01 101.       0
# … with 21 more rows
# ℹ Use `print(n = ...)` to see more rows
```

### Trend analyse
The stationarity analyse is computed with the `trend_analyse()` function on the extracted data `dataEx`. The **statistical test** used here is the **Mann-Kendall test**[^mann][^kendall].

Hence, the following expression ...

``` r
trendEx = trend_analyse(data=dataEx)
```

produces the result below ...

```
# A tibble: 1 × 4
  ID           p  stat      a
  <chr>    <dbl> <dbl>  <dbl>
1 serie A 0.0958  1.67 0.0260
```

It is a `tibble` which precises by line the name of the time serie the **p value**, the **stat value** and `a` the **Theil-Sen's slope**[^theil][^sen].

Finaly, as the **p value** is below 0.1, the previous time serie shows an **increasing linear trend** which can be represented by the equation `Y = 0.0260*X + b` with a **type I error** of 10 % or a **trust** of 90 %. 


## FAQ

*I have a question.*

-   **Solution**: Search existing issue list and if no one has a similar question create a new issue.

*I found a bug.*

-   **Good Solution**: Search existing issue list and if no one has reported it create a new issue.
-   **Better Solution**: Along with issue submission provide a minimal reproducible example of the bug.
-   **Best Solution**: Fix the issue and submit a pull request. This is the fastest way to get a bug fixed.


## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[^mann]: [Mann, H. B. (1945). Nonparametric tests against trend. Econometrica: Journal of the econometric society, 245-259.](https://www.jstor.org/stable/1907187)
[^kendall]: [Kendall, M.G. (1975) Rank Correlation Methods. 4th Edition, Charles Grifin, London.](https://www.scirp.org/reference/ReferencesPapers.aspx?ReferenceID=2223266)
[^theil]: [Theil, H. (1950). A rank-invariant method of linear and polynomial regression analysis. Indagationes mathematicae, 12(85), 173.](https://ir.cwi.nl/pub/8270/8270D.pdf)
[^sen]: [Sen, P. K. (1968). Estimates of the regression coefficient based on Kendall's tau. Journal of the American statistical association, 63(324), 1379-1389.](https://www.tandfonline.com/doi/abs/10.1080/01621459.1968.10480934)
