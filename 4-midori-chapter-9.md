Generalized Linear Model 4
================
Takeshi Kishiyama
2019/07/05 11:09

# はじめに

``` r
# 余白があるのでシードを与える
# 乱数なんかを固定できる
set.seed(1)
```

## 緑本9章

  - **GLMのベイズモデル化(個体差なし)**
  - GLMのベイズモデル化(個体差あり)

## データ取得

``` r
d <- read.csv("http://hosho.ees.hokudai.ac.jp/~kubo/stat/iwanamibook/fig/poisson/data3a.csv")
summary(d)
```

    ##        y               x          f     
    ##  Min.   : 2.00   Min.   : 7.190   C:50  
    ##  1st Qu.: 6.00   1st Qu.: 9.428   T:50  
    ##  Median : 8.00   Median :10.155         
    ##  Mean   : 7.83   Mean   :10.089         
    ##  3rd Qu.:10.00   3rd Qu.:10.685         
    ##  Max.   :15.00   Max.   :12.400

## 視覚化

``` r
plot(y~x, data=d)
```

<img src="4-midori-chapter-9_files/figure-gfm/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

## モデルの作成

まず、紙にモデルを描く。 ポアソン分布の求めたいパラメターを露光する。 求めたいパラメターは \(\beta_1\) と \(\beta_2\)
がある。 個体差は考慮しないので、まずはこれだけ。

  - \(\lambda_i = exp(\beta_1 + \beta_2 x_i)\)
  - \(y_i \sim Pois(\lambda_i)\)

## Stan ファイルの作成

``` r
model.chapter.9 <- "model/4-midori-chapter-9-1.stan"
```

## モデルフィッティング

``` r
data <- list(N = nrow(d),
             X = d$x,
             Y = d$y)
fit <- stan(file=model.chapter.9, data=data, seed=1234)
save.image(file="output/practice-4-3.RData")
model.summary <- summary(fit)$summary[c("b1","b2"),]
```

## モデルフィッティング

``` r
model.summary
```

    ##          mean     se_mean         sd        2.5%        25%       50%
    ## b1 1.28943970 0.015971643 0.35096900 0.614841650 1.05019350 1.2845769
    ## b2 0.07575315 0.001557589 0.03440564 0.005627412 0.05238158 0.0763089
    ##         75%     97.5%    n_eff     Rhat
    ## b1 1.523394 2.0058332 482.8790 1.001257
    ## b2 0.099909 0.1420775 487.9253 1.001239

## Visualize

``` r
load("output/practice-4-3.RData")

write.table(data.frame(summary(fit)$summary),
  file='output/fit-summary.txt', sep='\t', quote=FALSE, col.names=NA)

pdf.output <- "output/fit-traceplot.pdf"
ggmcmc(ggs(fit, inc_warmup=TRUE, stan_include_auxiliar=TRUE),
  file=pdf.output, plot='traceplot')
```

    ## Plotting traceplots

    ## Time taken to generate the report: 31 seconds.

## Bayesian confidence interval

``` r
ms <- rstan::extract(fit)
head(ms$b1)
```

    ## [1] 1.2642382 1.0366118 1.2978947 0.7955363 1.3135095 1.1367329

``` r
# bayesian confidence interval (for parameter)
hist(ms$b1)
```

<img src="4-midori-chapter-9_files/figure-gfm/unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

``` r
# 95% Bayesian confidence interval
quantile(ms$b1, probs=c(0.025, 0.975))
```

    ##      2.5%     97.5% 
    ## 0.6148416 2.0058332

``` r
d_mcmc <- data.frame(b1=ms$b1, b2=ms$b2)
plot(d_mcmc)
```

<img src="4-midori-chapter-9_files/figure-gfm/unnamed-chunk-10-1.png" style="display: block; margin: auto;" />

## Bayesian prediction interval

``` r
N_mcmc <- length(ms$lp__)
# random sampling in the case of x==10
y_10_lambda <- exp(ms$b1 + ms$b2 * 10)
y_10_pred <- rpois(n=N_mcmc, y_10_lambda)
pred <- data.frame(y_10_lambda = y_10_lambda,
                   y_10_pred   = y_10_pred)
d_mcmc <- cbind(d_mcmc, pred)
# predictive distribution (of new data)
hist(d_mcmc$y_10_pred)
```

<img src="4-midori-chapter-9_files/figure-gfm/unnamed-chunk-11-1.png" style="display: block; margin: auto;" />
