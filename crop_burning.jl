### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 81888440-4d42-11eb-1bf5-0f0108717ed6
using Markdown

# ╔═╡ e986fbd0-4d42-11eb-3342-ff3bb8eff1ad
md"# What is the global warming impact of crop burning?

To clear the fields of the residue from the previous rice crop and make way for the subsequent wheat crop, farmers in north India resort to burning what's left in the field. Called crop-burning, this happens in the months of October and November [1]. Manually clearing the residue, or using machines built for the purpose, may cost more. The machine and its associated manpower being available appear to be other reasons why they may not be adopted **cite**.

I was interested in understanding what the global warming impact of crop burning is. Burning crop contributes to global warming in at least two ways - through the release of greenhouse gases (GHGs) and the obvious one - the heat from the burning the crops themselves. I was interested in the former.

## How are greenhouse gas global warming potential measured?

GHGs like carbon dioxide ($CO_2$) and methane ($CH_4$) have different propensities to cause global warming. Hence global warming potential is measured in CO2eq or, $CO_2$ equivalents. That is, any contribution from say, methane, is understood as the contribution coming from an equivalent amount of $CO_2$.

For example, suppose a process releases 10g of $CO_2$ and 2g of $CH_4$. And suppose that the global warming propensity of $CH_4$ is 3 times that of $CO_2$. Then this process contributes $10 + 2 \times 3 = 16$g CO2eq.

## Which GHGs, and how much?

Before understanding the overall global warming effects, its useful to know which GHGs are released when burning crop residue. According to the meta analysis by Meinrat Andreae [2], we have the following

[1]: <https://doi.org/10.1016/j.aeaoa.2020.100091>
[2]: <https://doi.org/10.5194/acp-19-8523-2019>
"

# ╔═╡ Cell order:
# ╠═81888440-4d42-11eb-1bf5-0f0108717ed6
# ╠═e986fbd0-4d42-11eb-3342-ff3bb8eff1ad
