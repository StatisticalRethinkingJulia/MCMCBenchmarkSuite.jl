using CmdStan, Distributions, Random

Random.seed!(103)
n_subj = 100
n_obs = 100
μs = rand(Normal(0, 1), n_subj)
data = map(μ->rand(Normal(μ, 1), n_obs), μs)
data = reduce(hcat, data)'

ProjDir = @__DIR__
cd(ProjDir)

CmdStanGaussian = "
data {
  int<lower=0> n_subj;
  int<lower=0> n_obs;
  matrix[n_subj,n_obs] y;
}
parameters {
  real mumu;
  real<lower=0> musigma;
  real<lower=0> sigma;
  vector[n_subj] mus;
}
model {
  mumu ~ normal(0, 1);
  musigma ~ gamma(1, 1);
  mus ~ normal(mumu, musigma);
  sigma ~ gamma(1, 1);
  for(i in 1:n_subj){
    y[i,:] ~ normal(mus[i], sigma);
  }
}
"

CmdStanConfig = Stanmodel(
  name = "CmdStanGaussian", model=CmdStanGaussian, nchains=4, output_format=:mcmcchains,
  Sample(
    num_samples=1000, num_warmup=1000, adapt=CmdStan.Adapt(delta=0.65),
    save_warmup=false
  )
)

observations = Dict("n_obs"=>n_obs, "n_subj"=>n_subj, "y"=>data)

@elapsed rc, samples, cnames = stan(CmdStanConfig, observations, ProjDir, CmdStanDir=CMDSTAN_HOME)
