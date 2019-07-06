//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  // sample size
  int<lower=0> N;
  // renponse variable
  int Y[N];
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real beta;
  // https://ito-hi.blog.so-net.ne.jp/2012-09-03
  // individual difference
  vector[N] r;
  real<lower=0> sigma;
}

transformed parameters {
  vector[N] logistic_q;
  logistic_q = inv_logit(beta + r);
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  Y ~ binomial(8, logistic_q); // 二項分布
  beta ~ normal(0, 100); // 無情報事前分布
  r ~ normal(0, sigma); // 階層事前分布
  sigma ~ uniform(0, 1.0e+4); // 無情報事前分布
}
