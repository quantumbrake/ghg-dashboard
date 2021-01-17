### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 81888440-4d42-11eb-1bf5-0f0108717ed6
using Markdown

# ╔═╡ ee1dacd0-52e6-11eb-3486-0bb6ee49c951
using StatsPlots

# ╔═╡ e4abc46e-52e6-11eb-19e0-19a94e1257c6
using Random, Distributions

# ╔═╡ 8aa500ee-52e5-11eb-034e-15d346c9433e
begin
	co2_mean = 1420 # g/kg residue
	co2_std = 240
	ch4_mean = 5.5
	ch4_std = 5.7
	n2o_mean = 0.09
	n2o_std = 0.04;
	ch4_co2_eq_lower = 25; ch4_co2_eq_upper = 28;
	n2o_co2_eq_lower = 265; n2o_co2_eq_upper = 298;
	
	Random.seed!(123)
	n_samples = 100;
	
	co2_amt = rand(truncated(Normal(co2_mean, co2_std), 0, co2_mean * 3), n_samples);
	
	ch4_amt = rand(truncated(Normal(ch4_mean, ch4_std), 0, ch4_mean * 3), n_samples);
	ch4_co2eq_factor = rand(Uniform(ch4_co2_eq_lower, ch4_co2_eq_upper), n_samples);
	ch4_co2eq = ch4_amt .* ch4_co2eq_factor;
	
	n2o_amt = rand(truncated(Normal(n2o_mean, n2o_std), 0, n2o_mean * 3), n_samples);
	n2o_co2eq_factor = rand(Uniform(n2o_co2_eq_lower, n2o_co2_eq_upper), n_samples);
	n2o_co2eq = n2o_amt .* n2o_co2eq_factor;
	
	co2eq = co2_amt + ch4_co2eq + n2o_co2eq
	
	residue_amt = 14; # units of million tonnes
	residue_amt_3_lower = 15; residue_amt_3_upper = 22.5;
	residue_amt_3 = rand(Uniform(residue_amt_3_lower, residue_amt_3_upper), n_samples);
	residue_amt_2 = 23;
	
	total_co2 = co2_amt .* residue_amt / 1e3 # units of g/kg * million tonnes / 1000 = million g = Gg
	total_co2eq = co2eq .* residue_amt / 1e3
	total_co2_2 = co2_amt .* residue_amt_2 / 1e3
	total_co2eq_2 = co2eq .* residue_amt_2 / 1e3
	total_co2_3 = co2_amt .* residue_amt_3 / 1e3
	total_co2eq_3 = co2eq .* residue_amt_3 / 1e3
end;

# ╔═╡ e986fbd0-4d42-11eb-3342-ff3bb8eff1ad
md"# What is the global warming impact of crop burning?

To clear the fields of the residue from the previous rice crop and make way for the subsequent wheat crop, farmers in north India resort to burning what's left in the field. Called crop-burning, this happens in the months of October and November [1]. Manually clearing the residue, or using machines built for the purpose, may cost more. The machine and its associated manpower being available appear to be other reasons why they may not be adopted **cite**.

I was interested in understanding what the global warming impact of crop burning is. Burning crop contributes to global warming in at least two ways - through the release of greenhouse gases (GHGs) and the obvious one - the heat from the burning the crops themselves. I was interested in the former.

## How are greenhouse gas global warming potential measured?

GHGs like carbon dioxide ($CO_2$) and methane ($CH_4$) have different propensities to cause global warming. Hence global warming potential is measured in CO2eq or, $CO_2$ equivalents. That is, any contribution from say, methane, is understood as the contribution coming from an equivalent amount of $CO_2$.

For example, suppose a process releases 10g of $CO_2$ and 2g of $CH_4$. And suppose that the global warming propensity of $CH_4$ is 3 times that of $CO_2$. Then this process contributes $10 + 2 \times 3 = 16$g CO2eq.

## Which GHGs, and how much?

Before understanding the overall global warming effects, its useful to know which GHGs are released when burning crop residue. Here I looked at carbon dioxide, methane and nitrous oxide ($N_2O$). While the latter two are addressed in the analysis by the FAO [3], $CO_2$ was not.

To understand how much of each of these gases are produced per kg of crop residue, I looked at the meta analysis by Meinrat Andreae [2] and found the following

Gas | Mean emission (g/kg residue) | Standard deviation emission (g/kg residue) | Number of samples on which esitmate is based
---|---|---|---
$CO_2$ | $(co2_mean) | $(co2_std) | 25
$CH_4$ | $(ch4_mean) | $(ch4_std) | 17
$N_2O$ | $(n2o_mean) | $(n2o_std) | 5

And we also have the CO2eq data for the two gases from the following sources

Gas | CO2eq (g $CO_2$ / g gas) | Source
---|---|---
$CH_4$ | $(ch4_co2_eq_upper) | [4]
$N_2O$ | $(n2o_co2_eq_lower) | \"
$CH_4$ | $(ch4_co2_eq_lower) | [5]
$N_2O$ | $(n2o_co2_eq_upper) | \"

### Global warming impact per kg of residue

The numbers above are sufficient to understand the global warming impact of burning 1kg of crop residue. I assume a normal distribution for the gas amounts (since we have mean and std) and a uniform distribution for the CO2eq factors (since we two values from literature). While these distributions may not stand up to peer review, they are a good first step in my opinion.

"

# ╔═╡ 0ebca100-52ea-11eb-0575-35a5a3185264
begin
	# gr(size=(2500,3000))
	density([log10.(co2_amt), log10.(ch4_amt), log10.(n2o_amt)], 
		label=["Carbon Dioxide" "Methane" "Nitrous Oxide"], width=2,
	xlabel="Log10(Emission) (g/kg residue)", ylabel="Probability density",
	title="Distribution of GHG emission/kg residue burnt", legend=:topleft)
end

# ╔═╡ f4406d20-586b-11eb-0d35-51da6f73592e
md"Since the X axis is on the log scale, we observe that $CO_2$ emission is $\approx$2 orders of magnitude greater than $CH_4$ emission, which is an order greater than $N_2O$ emission. While these are simply the amounts, the impact on global warming is better reflected by the chart below."

# ╔═╡ 84569b40-586d-11eb-2e39-8bda6366221b
begin
	# gr(size=(2500,3000))
	boxplot([log10.(co2_amt), log10.(ch4_co2eq), log10.(n2o_co2eq), log10.(co2eq)], width=2,
	xlabel="Gases", ylabel="Log10(CO2eq) (g/kg residue)",
	title="Distribution of Emission gCO2eq/kg residue burnt", legend=false,
	xticks=([1 2 3 4], ["Carbon Dioxide" "Methane" "Nitrous Oxide" "Total"]))
end

# ╔═╡ 925ff0a0-586e-11eb-24c5-3be428cb076f
md"

So it does appear that the impact of methane and nitrous oxide is higher than surmised purely based on their amounts. However it is only a fraction of the impact of $CO_2$ alone, based on the chosen data.

## Overall impact on global warming

To understand the overall impact of crop burning on global warming, I found estimates for the amount of agricultural residue that was burned in 2016.

Case | Amount of residue (million tonnes)/ year | Source
---|---|---
1 | $(residue_amt) | [2]
2 | $(residue_amt_2) | [3]
3 | $(residue_amt_3_lower) - $(residue_amt_3_upper) | [6]

Computing the impact of these residue amounts is simply multiplying one or more of these residue amounts with the emission per kg from the previous section. This gives

"

# ╔═╡ 82c338c0-5867-11eb-02f4-4d0f92a4081d
begin
	# gr(size=(2500,3000))
	boxplot([total_co2, total_co2eq, total_co2_2, total_co2eq_2, total_co2_3, total_co2eq_3], width=2,
	xlabel="Cases", ylabel="CO2eq (Gg or million kg)",
	title="Distribution of gCO2eq from crop residue burning", legend=false,
	xticks=([1 2 3 4 5 6], ["1 - CO2 only", "1 - Total","2 - CO2 only", "2 - Total","3 - CO2 only", "3 - Total"]))
end

# ╔═╡ 7f753680-5878-11eb-3c3c-d772aa51e7e7
md"I trust the estimate of of case number 1 most, since the authors of that publication follow a first principled approach to estimate the amount of residue, and use many data sources to avoid underestimations. For example, they fill in the gaps from satellite data with surveys."

# ╔═╡ daa76dd2-52eb-11eb-2492-b596bf1b7de3


# ╔═╡ f06dec20-52eb-11eb-18c9-71d5cfb5b910


# ╔═╡ 701820f0-52e5-11eb-1cff-195defc1e22a
md"

## Links

[1]: <https://doi.org/10.1016/j.aeaoa.2020.100091>

[2]: <https://doi.org/10.5194/acp-19-8523-2019>

[3]: <http://www.fao.org/faostat/en/#data/GB/metadata>

[4]: <https://cdiac.ess-dive.lbl.gov/pns/current_ghg.html>

[5]: <https://climatechangeconnection.org/emissions/co2-equivalents/>

[6]: <https://doi.org/10.1038/s41598-019-52799-x>"

# ╔═╡ 8685b4b0-52e5-11eb-1414-bfb2439d473c


# ╔═╡ 77ed9760-52e5-11eb-3534-d512d858bd9d


# ╔═╡ Cell order:
# ╠═81888440-4d42-11eb-1bf5-0f0108717ed6
# ╠═ee1dacd0-52e6-11eb-3486-0bb6ee49c951
# ╠═e4abc46e-52e6-11eb-19e0-19a94e1257c6
# ╟─e986fbd0-4d42-11eb-3342-ff3bb8eff1ad
# ╠═8aa500ee-52e5-11eb-034e-15d346c9433e
# ╟─0ebca100-52ea-11eb-0575-35a5a3185264
# ╟─f4406d20-586b-11eb-0d35-51da6f73592e
# ╠═84569b40-586d-11eb-2e39-8bda6366221b
# ╟─925ff0a0-586e-11eb-24c5-3be428cb076f
# ╟─82c338c0-5867-11eb-02f4-4d0f92a4081d
# ╟─7f753680-5878-11eb-3c3c-d772aa51e7e7
# ╟─daa76dd2-52eb-11eb-2492-b596bf1b7de3
# ╟─f06dec20-52eb-11eb-18c9-71d5cfb5b910
# ╠═701820f0-52e5-11eb-1cff-195defc1e22a
# ╟─8685b4b0-52e5-11eb-1414-bfb2439d473c
# ╟─77ed9760-52e5-11eb-3534-d512d858bd9d
