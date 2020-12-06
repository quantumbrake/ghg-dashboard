### A Pluto.jl notebook ###
# v0.12.16

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ d516ddd2-373a-11eb-2e23-cfa3567381c8
using CSV, DataFrames, DataFramesMeta

# ╔═╡ 8f54975e-373c-11eb-3f81-7d8be17f01ba
using StatsPlots, Plots, PlutoUI

# ╔═╡ f67f3c42-373c-11eb-37ba-119e403e6e4b
md"# Emissions data from OWID"

# ╔═╡ 385376ae-373d-11eb-3427-fd6fb257d0b8
begin
	CO₂_data_raw = DataFrame(CSV.File("data/owid-co2-data.csv"))
	CO₂_data = dropmissing(
		CO₂_data_raw, ["iso_code", "country", "year"], disallowmissing=true
	)
end

# ╔═╡ 6ff22702-3746-11eb-2133-6370939e4d6b
begin
	energy_data_raw = DataFrame(CSV.File("data/owid-energy-data.csv"))
	energy_data = dropmissing(
		energy_data_raw, ["iso_code", "country", "year"], disallowmissing=true
	)
end

# ╔═╡ 96d01516-3749-11eb-2dfe-81ba346f3778
# TODO: Replace the missing data with 0 if you're taking cumulative estimates
begin
	CO₂_data_group = groupby(CO₂_data, :country)
	CO₂_data_agg = dropmissing(combine(CO₂_data_group, :co2 => sum))
	CO₂_data_agg_sorted = sort(CO₂_data_agg, [:co2_sum], rev=true)
	first(CO₂_data_agg_sorted, 10)
end

# ╔═╡ ef61af46-3746-11eb-1e2d-1b3f94c6e0c8
begin
	function get_top_countries(
			data::DataFrame, column::Symbol, num::Integer
			)
		data_group = groupby(data, :country)
		sum_column = Symbol(join([string(column), "sum"], "_"))
		data_agg = dropmissing(
			combine(data_group, column => sum => sum_column)
		)
		data_agg_sorted = sort(data_agg, [sum_column], rev=true)
		return first(data_agg_sorted, num)[!, :country]
	end
end

# ╔═╡ d4eee370-375a-11eb-3391-cd8c47b437f2
begin
	function filter_by_year(year::Integer, left::Integer, right::Integer)::Bool
		er
	end
end

# ╔═╡ 8e835056-375a-11eb-2674-15573baf6f61
md"Select number of top countries to be displayed:"

# ╔═╡ 16acef5c-3752-11eb-3d0d-675c451bffb7
@bind num_countries Slider(1:50, show_value=true)

# ╔═╡ a0d000b0-375a-11eb-15cf-eb2bab323520
md"Select the year range:"

# ╔═╡ 569d1190-375a-11eb-3a84-211e63e24ecf
@bind year_range RangeSlider(1980:1:2016, show_value=true)

# ╔═╡ 88789de4-3753-11eb-14bf-6f717989d803
begin
	top_countries = get_top_countries(CO₂_data, :co2, num_countries)
	CO₂_data_plot = filter(
		[:country, :year] => (c, y) -> (c ∈ top_countries) && (y ∈ year_range),
		CO₂_data
	)
end

# ╔═╡ 9d18e522-373c-11eb-2556-e9b2dcc51fe8
@df CO₂_data_plot plot(:year, :co2, group=:country)

# ╔═╡ Cell order:
# ╟─f67f3c42-373c-11eb-37ba-119e403e6e4b
# ╠═d516ddd2-373a-11eb-2e23-cfa3567381c8
# ╠═385376ae-373d-11eb-3427-fd6fb257d0b8
# ╠═6ff22702-3746-11eb-2133-6370939e4d6b
# ╠═8f54975e-373c-11eb-3f81-7d8be17f01ba
# ╠═96d01516-3749-11eb-2dfe-81ba346f3778
# ╠═ef61af46-3746-11eb-1e2d-1b3f94c6e0c8
# ╠═d4eee370-375a-11eb-3391-cd8c47b437f2
# ╟─8e835056-375a-11eb-2674-15573baf6f61
# ╟─16acef5c-3752-11eb-3d0d-675c451bffb7
# ╟─a0d000b0-375a-11eb-15cf-eb2bab323520
# ╠═569d1190-375a-11eb-3a84-211e63e24ecf
# ╠═88789de4-3753-11eb-14bf-6f717989d803
# ╠═9d18e522-373c-11eb-2556-e9b2dcc51fe8
