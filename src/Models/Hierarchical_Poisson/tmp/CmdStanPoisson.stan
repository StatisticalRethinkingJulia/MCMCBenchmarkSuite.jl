data {
  int N;
  int y[N];
  int Ns;
  int idx[N];
  real x[N];
}
parameters {
  real a0;
  vector[Ns] a0s;
  real a1;
  real<lower=0> a0_sig;
}
model {
  vector[N] mu;
  a0 ~ normal(0, 10);
  a1 ~ normal(0, 1);
  a0_sig ~ cauchy(0, 1);
  a0s ~ normal(0, a0_sig);
  for(i in 1:N) mu[i] = exp(a0 + a0s[idx[i]] + a1 * x[i]);
  y ~ poisson(mu);
}
