Generalized Linear Model 5
================
Takeshi Kishiyama
2019/07/06 15:10

# はじめに

``` r
# 余白があるのでシードを与える
# 乱数なんかを固定できる
set.seed(1)
```

## 緑本10章

  - GLMのベイズモデル化(個体差なし)
  - **GLMのベイズモデル化(個体差あり)**

## データ取得

``` r
d <- read.csv("http://hosho.ees.hokudai.ac.jp/~kubo/stat/iwanamibook/fig/hbm/data7a.csv")
d["M"] <- 8
summary(d)
```

    ##        id               y              M    
    ##  Min.   :  1.00   Min.   :0.00   Min.   :8  
    ##  1st Qu.: 25.75   1st Qu.:1.00   1st Qu.:8  
    ##  Median : 50.50   Median :4.00   Median :8  
    ##  Mean   : 50.50   Mean   :4.03   Mean   :8  
    ##  3rd Qu.: 75.25   3rd Qu.:7.00   3rd Qu.:8  
    ##  Max.   :100.00   Max.   :8.00   Max.   :8

## 視覚化

``` r
hist(d$y)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

## モデルの作成

まず、紙にモデルを描く。 ポアソン分布の求めたいパラメターを露光する。 求めたいパラメターは \(\beta\) と \(r[i]\) がある。

  - \(q_i = inv_logit(\beta + r_i)\)
  - \(Y_i \sim binomial(M_i, q_i)\)
  - \(r_i = normal(0 + \sigma)\)

## Stan ファイルの作成

``` r
model.chapter.10 <- "model/5-midori-chapter-10-1.stan"
```

## モデルフィッティング

``` r
data <- list(N = nrow(d),
             Y = d$y)
fit <- stan(file=model.chapter.10, data=data, seed=1234)
save.image(file="output/practice-10-1.RData")
model.summary <- summary(fit)$summary
model.summary[c('beta','sigma'),]
```

    ##             mean    se_mean        sd       2.5%        25%        50%
    ## beta  0.01904102 0.01295299 0.3352248 -0.6380377 -0.2038073 0.02271887
    ## sigma 3.04783196 0.01283494 0.3712588  2.4131460  2.7819901 3.02198884
    ##            75%     97.5%    n_eff     Rhat
    ## beta  0.242857 0.6778084 669.7803 1.005604
    ## sigma 3.276799 3.8576961 836.6920 1.002356

``` r
rs.mean <- model.summary[paste0(paste0('r[',1:100),']'),"mean"]
```

## モデルフィッティング

randoms

``` r
hist(rs.mean)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

## Visualize

``` r
write.table(data.frame(summary(fit)$summary),
  file='output/fit-summary-10-2.txt', sep='\t', quote=FALSE, col.names=NA)

pdf.output <- "output/fit-traceplot-2.pdf"
ggmcmc(ggs(fit, inc_warmup=TRUE, stan_include_auxiliar=TRUE),
  file=pdf.output, plot='traceplot')
```

    ## Plotting traceplots

    ## Time taken to generate the report: 72 seconds.

## Bayesian confidence interval

``` r
ms <- rstan::extract(fit)
# bayesian confidence interval (for parameter)
hist(ms$b)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

``` r
# s
hist(ms$sigma)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

``` r
# 95% Bayesian confidence interval
quantile(ms$b, probs=c(0.025, 0.975))
```

    ##       2.5%      97.5% 
    ## -0.6380377  0.6778084

``` r
# 95% Bayesian confidence interval
quantile(ms$sigma, probs=c(0.025, 0.975))
```

    ##     2.5%    97.5% 
    ## 2.413146 3.857696

``` r
d_mcmc <- data.frame(b=ms$b)
plot(d_mcmc)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-12-1.png" style="display: block; margin: auto;" />

## Bayesian prediction interval

``` r
N_mcmc <- length(ms$lp__)
z <- ms$b + rnorm(n=N_mcmc, sd = ms$sigma)
q <- 1/(1+exp(-z))
y_pred <- rbinom(n=N_mcmc, size=8, prob=q)

pred <- data.frame(q = q,
                   y_pred   = y_pred)
d_mcmc <- cbind(d_mcmc, pred)
head(d_mcmc)
```

    ##              b          q y_pred
    ## 1 -0.028598210 0.15978632      0
    ## 2 -0.514500971 0.52104088      6
    ## 3  0.437027710 0.07583033      1
    ## 4 -0.007460165 0.99101588      8
    ## 5  0.243652127 0.79970495      6
    ## 6  0.111414001 0.06904847      0

``` r
# predictive distribution (of new data)
hist(d_mcmc$y_pred)
```

<img src="5-midori-chapter-10_files/figure-gfm/unnamed-chunk-13-1.png" style="display: block; margin: auto;" />
