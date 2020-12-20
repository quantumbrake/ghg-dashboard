### A Pluto.jl notebook ###
# v0.12.17

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

# ╔═╡ c913950e-3779-11eb-1393-652a38b36358
plotly()

# ╔═╡ 853d9f60-3778-11eb-1d55-1f68e90890ef
md"### Load worldwide CO$_2$ emissions data"

# ╔═╡ 385376ae-373d-11eb-3427-fd6fb257d0b8
begin
	CO₂_data_raw = DataFrame(CSV.File("data/owid-co2-data.csv"))
	CO₂_data = dropmissing(
		CO₂_data_raw, ["iso_code", "country", "year"], disallowmissing=true
	)
end

# ╔═╡ b42444aa-3778-11eb-04fa-2d0226b97ab4
md"### Load worldwide energy data"

# ╔═╡ 6ff22702-3746-11eb-2133-6370939e4d6b
begin
	energy_data_raw = DataFrame(CSV.File("data/owid-energy-data.csv"))
	energy_data = dropmissing(
		energy_data_raw, ["iso_code", "country", "year"], disallowmissing=true
	)
end

# ╔═╡ 6a3245c6-3779-11eb-31eb-816c86417336
md""" Function to get top `num` countries based on `column` """

# ╔═╡ ef61af46-3746-11eb-1e2d-1b3f94c6e0c8
begin
	function get_top_countries(
			data::DataFrame,
			column::Symbol,
			num::Integer,
			years::Array,
			world::Bool
			)::Array
		if world
			data_filtered = filter(
				[:country, :year] => (c, y) -> (y ∈ years) && (c != "World"), data
			)
		else
			data_filtered = filter(:year => y -> y ∈ years, data)
		end
		data_group = groupby(data_filtered, :country)
		sum_column = Symbol(join([string(column), "sum"], "_"))
		data_agg = dropmissing(
			combine(data_group, column => sum => sum_column)
		)
		data_agg_sorted = sort(data_agg, [sum_column], rev=true)
		return first(data_agg_sorted, num)[!, :country]
	end
end

# ╔═╡ 8e835056-375a-11eb-2674-15573baf6f61
md"Select number of top countries to be displayed:"

# ╔═╡ 16acef5c-3752-11eb-3d0d-675c451bffb7
@bind num_countries Slider(1:50, show_value=true)

# ╔═╡ 6149a41c-37cf-11eb-1d25-97447c40d902
md"Hide world entry"

# ╔═╡ 67bc0948-37cf-11eb-078d-45a5c22f5cb1
@bind world_flag CheckBox()

# ╔═╡ a0d000b0-375a-11eb-15cf-eb2bab323520
md"Select the year range:"

# ╔═╡ 569d1190-375a-11eb-3a84-211e63e24ecf
@bind year_range RangeSlider(1949:1:2018, show_value=true)

# ╔═╡ 88789de4-3753-11eb-14bf-6f717989d803
begin
	top_countries = get_top_countries(
		CO₂_data, :co2, num_countries, year_range, world_flag
	)
	CO₂_data_plot = filter(
		[:country, :year] => (c, y) -> (c ∈ top_countries) && (y ∈ year_range),
		CO₂_data
	)
end

# ╔═╡ 9d18e522-373c-11eb-2556-e9b2dcc51fe8
@df CO₂_data_plot plot(
	:year,
	:co2,
	group=:country,
	title="Wordlwide CO₂ emissions",
	w=3,
	legend=:topleft,
	xlabel="Years",
	ylabel="CO₂ emissions",
)

# ╔═╡ 5ce275fe-37e6-11eb-0e9f-87ae89d8f47e
begin
	function get_yearly_breakdown(
			data::DataFrame,
			components::Array{Symbol,1},
			)::DataFrame
		data_filter = dropmissing(data, components, disallowmissing=true)
		data_filter_grp = groupby(data_filter, :year)
		data_filter_elem = combine(data_filter_grp, components .=> sum)
		return data_filter_elem
	end
end

# ╔═╡ 2028a704-37e7-11eb-2551-6d344c9c4058
begin
	components = [:cement_co2, :coal_co2, :flaring_co2, :gas_co2, :oil_co2]
	sum_components = map(x -> Symbol(join([string(x), "sum"], "_")), components)
	CO₂_data_plot_elem = get_yearly_breakdown(CO₂_data_plot, components)
end

# ╔═╡ 7d098220-3cc8-11eb-15e6-17fb1cdcda65
filter([:cement_co2, :coal_co2, :flaring_co2, :gas_co2, :oil_co2, :year] => (x1, x2, x3, x4, x5, y) -> length(collect(skipmissing([x1, x2, x3, x4, x5]))) < 5 && (y ∈ range(2010, step=1, stop=2018)), CO₂_data_plot)[!, [:cement_co2, :coal_co2, :flaring_co2, :gas_co2, :oil_co2, :year, :country]]

# ╔═╡ 76cd7458-37d9-11eb-3c2e-a1eafddc3b0f
groupedbar(
	CO₂_data_plot_elem.year,
	convert(Matrix, CO₂_data_plot_elem[!, sum_components]),
	bar_position=:stack
)

# ╔═╡ 823b1bf6-37ed-11eb-1afc-e1ebd30026aa
begin
	function get_fraction(data::DataFrame, year::Integer, components::Array{Symbol,1})::DataFrame
		data_year = select(
			filter(row -> row.year == year, CO₂_data_plot_elem), 
			sum_components
		)
		data_wsum = transform(data_year, AsTable(:) => ByRow(sum) => :total_sum)
		data_frac =select(
		mapcols(
			x -> x./data_wsum.total_sum,
			data_wsum
		), components
	)
	end
end

# ╔═╡ 7f2d987c-37e4-11eb-1001-c5e2585b915d
md"Select year for breakdown"

# ╔═╡ 6ca43120-37e4-11eb-1e3a-61cbdf7734aa
@bind year_select Slider(year_range[1]:1:year_range[end], show_value=true)

# ╔═╡ f221acdc-37ed-11eb-3d9c-3373ff76bad3
CO₂_data_plot_elem_year_frac = get_fraction(CO₂_data_plot_elem, year_select, sum_components)

# ╔═╡ cb13cdc8-37e3-11eb-1a35-3bddfae314df
pie(
	names(CO₂_data_plot_elem_year_frac),
	convert(Array, CO₂_data_plot_elem_year_frac[1, :]),
)

# ╔═╡ c672e488-3807-11eb-0bcc-7d2b8b71b238


# ╔═╡ Cell order:
# ╟─f67f3c42-373c-11eb-37ba-119e403e6e4b
# ╠═d516ddd2-373a-11eb-2e23-cfa3567381c8
# ╠═8f54975e-373c-11eb-3f81-7d8be17f01ba
# ╠═c913950e-3779-11eb-1393-652a38b36358
# ╟─853d9f60-3778-11eb-1d55-1f68e90890ef
# ╠═385376ae-373d-11eb-3427-fd6fb257d0b8
# ╟─b42444aa-3778-11eb-04fa-2d0226b97ab4
# ╠═6ff22702-3746-11eb-2133-6370939e4d6b
# ╟─6a3245c6-3779-11eb-31eb-816c86417336
# ╟─ef61af46-3746-11eb-1e2d-1b3f94c6e0c8
# ╠═88789de4-3753-11eb-14bf-6f717989d803
# ╟─8e835056-375a-11eb-2674-15573baf6f61
# ╟─16acef5c-3752-11eb-3d0d-675c451bffb7
# ╟─6149a41c-37cf-11eb-1d25-97447c40d902
# ╟─67bc0948-37cf-11eb-078d-45a5c22f5cb1
# ╟─a0d000b0-375a-11eb-15cf-eb2bab323520
# ╟─569d1190-375a-11eb-3a84-211e63e24ecf
# ╠═9d18e522-373c-11eb-2556-e9b2dcc51fe8
# ╟─5ce275fe-37e6-11eb-0e9f-87ae89d8f47e
# ╠═2028a704-37e7-11eb-2551-6d344c9c4058
# ╠═7d098220-3cc8-11eb-15e6-17fb1cdcda65
# ╠═76cd7458-37d9-11eb-3c2e-a1eafddc3b0f
# ╠═823b1bf6-37ed-11eb-1afc-e1ebd30026aa
# ╟─7f2d987c-37e4-11eb-1001-c5e2585b915d
# ╟─6ca43120-37e4-11eb-1e3a-61cbdf7734aa
# ╠═f221acdc-37ed-11eb-3d9c-3373ff76bad3
# ╠═cb13cdc8-37e3-11eb-1a35-3bddfae314df
# ╠═c672e488-3807-11eb-0bcc-7d2b8b71b238
