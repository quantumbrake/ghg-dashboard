### A Pluto.jl notebook ###
# v0.12.20

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

# ╔═╡ 49f027da-5dce-11eb-3fff-0fd590112019
using Distributions, Random

# ╔═╡ 3b2050da-52c1-11eb-3b89-1d5b6eb2cf40
using PlutoUI, Printf

# ╔═╡ 0442fbb8-52c0-11eb-06ea-01e68e330d5d
md"""
# Dashboard
"""

# ╔═╡ 5fbcb6e6-52ca-11eb-3e8c-1bb7495dc15d
md"""## Add emissions """

# ╔═╡ ec388b4a-52ca-11eb-097d-6760de18dd0e
md"""---"""

# ╔═╡ 672fef94-6351-11eb-0af1-652d5992e129
Random.seed!(1234);

# ╔═╡ 49571046-68c2-11eb-071e-2709f8e40e48
struct Person
	vehicles::Array{String,1}
	foods::Array{String,1}
	streams::Array{String,1}
	country::String
	purchases::Array{String,1}
end

# ╔═╡ 521ebdb6-68c5-11eb-3bb2-8926b33ec780
person_1 = Person(
	["car", "motorbike", "bus"],
	["potatoes", "rice", "milk"],
	["ultraHDVideo"],
	"usa",
	["jeans", "shirt", "shoes"]
)

# ╔═╡ 16fb0470-6351-11eb-104f-9de78182499d
md"""
Random transport
"""

# ╔═╡ eeee2d84-6352-11eb-3b69-0b3a53840e97
md"""
Random food
"""

# ╔═╡ 2b33df02-6353-11eb-07bf-c5a64c6c68d9
md"""
Random Streaming
"""

# ╔═╡ c4403112-6353-11eb-09ff-5b78fe6d4581
md"""
Random Electricity
"""

# ╔═╡ f106a442-6353-11eb-26fb-2fdc38c0bf80
md"""
Random Purchases
"""

# ╔═╡ bcb6b95e-6356-11eb-1662-397a7be9c496
md"""
Random result
"""

# ╔═╡ 5552f080-5dce-11eb-013e-6f856304cdcf
# Source: https://ars.els-cdn.com/content/image/1-s2.0-S0959378020307883-mmc1.pdf
# Electricity -
# Food - Grain, vegetable, fruit, dairy, beef, pork, poultry, other meat, fish, alcohol, other beverage, confectionery, restaurant, other food
# Income: bottom, low, middle, high, top

# ╔═╡ c065c808-5dd2-11eb-10d6-576b82dc5ce0
# Source: http://css.umich.edu/factsheets/carbon-footprint-factsheet
# US
# Different food distribution
# Electricity

# ╔═╡ 78d20618-5dd3-11eb-03f4-b9a0e5f50e9a
# Source: https://www.pnas.org/content/117/32/19122
# Has energy use data

# ╔═╡ 054ae36c-52cb-11eb-25aa-31355bbed6de
md"""# Sources """

# ╔═╡ b4a152f0-4d4f-11eb-106b-b58e9f1495a9
import JSON

# ╔═╡ cedb71ac-52b9-11eb-19e7-9f433ffb4f14
function read_json(file::String)::Dict
	data = Dict
	open(file, "r") do io
		raw_string = read(io, String)
		data = JSON.parse(raw_string)
	end
	return data
end

# ╔═╡ 227d45a0-4d45-11eb-0cca-af99bc390097
function kwatts_to_joules(x::Float64)::Float64
		x * 3.6 * (10 ^ 6);
end

# ╔═╡ b2b598f8-4d3f-11eb-310d-7740ecc9d222
md"""
## Electricity

Unit: $kgCO_2eq/J$

Unit of data: $kgCO_2eq/kWh$

Conversion factor: $(x / 3.6) * 10^{-6}$

**Sources**:
- https://github.com/carbonalyser/Carbonalyser
- https://www.electricitymap.org - 28th of April 2020
"""

# ╔═╡ 0fcd983e-52b7-11eb-2c1f-13d00c8b4c43
begin
	pw_to_pj(x::Float64)::Float64 = (x / 3.6) * (10 ^ (-6))
	electricity_data_pw = read_json("data/carbon_footprint/electricity.json")
	values_pj = map(x -> pw_to_pj(x), values(electricity_data_pw))
	electricity_data = Dict(zip(keys(electricity_data_pw), values_pj))
end

# ╔═╡ d150a918-6353-11eb-305b-2f50dadaeaed
begin
	electricity_place = rand(keys(electricity_data))
	electricity_amounts = floor.(Int, rand(Uniform(1, 1000)))
end

# ╔═╡ 1fc15990-4d41-11eb-0f5f-c309cf01fdfa
md"""
## Food

Unit: $kgCO_2eq$

**Sources**:
- http://www.greeneatz.com/foods-carbon-footprint.html
- https://www.bilans-ges.ademe.fr
"""

# ╔═╡ 329e738a-52ba-11eb-22dd-fbfe2de89bb1
food_data = read_json("data/carbon_footprint/food.json")

# ╔═╡ f40c4d82-6352-11eb-3954-3dd3fcc0d776
begin
	n_food_types = rand((1, 2, 3, 4, 5))
	food_types = rand(keys(food_data), n_food_types)
	food_amounts = floor.(Int, rand(Uniform(20, 500), n_food_types))
end

# ╔═╡ fb596dc6-4d41-11eb-1dbd-6707e4fa7778
md"""
## Internet

Unit: $kgCO_2eq$

**Sources**:
- https://theshiftproject.org/wp-content/uploads/2019/03/Lean-ICT-Report_The-Shift-Project_2019.pdf
- https://github.com/carbonalyser/
- https://www.carbonbrief.org/factcheck-what-is-the-carbon-footprint-of-streaming-video-on-netflix
"""

# ╔═╡ 83af9228-6353-11eb-0e5b-4550ac55ca4f
streaming_data = Dict(["HDVideo" => "Video HD",
			"fullHDVideo" => "Video - FullHD/1080p",
			"ultraHDVideo" => "Video - UltraHD/4K",
			"audioMP3" => "Audio - MP3"])

# ╔═╡ 545a4586-6353-11eb-20f8-b5de7cf57054
begin
	n_stream_types = rand((1, 2, 3, 4))
	stream_types = rand(keys(streaming_data), n_stream_types)
	stream_amounts = floor.(Int, rand(Uniform(15, 600), n_stream_types))
end

# ╔═╡ cfd60bf8-4d43-11eb-00b7-bd162061b954
begin
	function internet_carbonimpact(
			duration::Float64,
			data_weight::Float64,
			electricity_intensity::Float64
		)::Float64
		factor = Dict(
			"datacenter" => kwatts_to_joules(0.007 * (10 ^ (-9))) / 8,
			"network" => kwatts_to_joules(0.058 * (10 ^ (-9))) / 8,
			"device" => kwatts_to_joules(0.055 / (60 * 60))
		)
		ghg_datacenter = data_weight * get(factor, "datacenter", 0.0) * electricity_data["world"]
		ghg_network = data_weight * get(factor, "network", 0.0) * electricity_data["world"]
		ghg_device = duration * get(factor, "device", 0.0) * electricity_intensity
		total = ghg_datacenter + ghg_network + ghg_device
		return total
	end
end

# ╔═╡ cccb00f0-4d46-11eb-027b-ab6e07ce3ce5
md"""
## Purchases

Unit: $kgCO_2eq$ per product

**Sources Clothing**:
- https://www.ademe.fr/sites/default/files/assets/documents/poids_carbone-biens-equipement-201809-rapport.pdf

**Sources Tech**:
- https://www.apple.com/lae/environment/pdf/products/iphone/iPhone_11_Pro_PER_sept2019.pdf
- https://www.apple.com/lae/environment/pdf/products/ipad/iPad_PER_sept2019.pdf
- https://www.apple.com/lae/environment/pdf/products/desktops/21.5-inch_iMac_with_Retina4KDisplay_PER_Mar2019.pdf
- https://www.apple.com/lae/environment/pdf/products/notebooks/13-inch_MacBookPro_PER_June2019.pdf
- https://www.bilans-ges.ademe.fr/fr/basecarbone/donnees-consulter/liste-element?recherche=T%C3%A9l%C3%A9vision

**Sources Transport**:
-   https://www.lowcvp.org.uk/assets/workingdocuments/MC-P-11-15a%20Lifecycle%20emissions%20report.pdf
"""

# ╔═╡ 42eb4b3e-52ba-11eb-2178-11e1d2a887af
purchase_data = read_json("data/carbon_footprint/purchase.json")

# ╔═╡ f7a05460-6353-11eb-3b57-1de112c66e4a
begin
	n_purchase_types = rand((1, 2, 3, 4, 5))
	purchase_types = rand(keys(purchase_data), n_purchase_types)
	purchase_amounts = floor.(Int, rand(Uniform(1, 5), n_purchase_types))
end

# ╔═╡ e8574808-4d49-11eb-3515-2d66aadee9f2
md"""
## Streaming

Unit: $bit/s$ -> $kgCO_2eq$

**Sources**:
- HD / 720p : 1.21 GB
- Full HD / 1080p : 7.02 GB
- Ultra HD / 2160p : 35.73 Gb
- MP3 song at 192 kbps : 3.8 MB
"""

# ╔═╡ 5e3ae372-4d4a-11eb-3e76-e7b1545f3759
begin
	function streaming_carbonimpact(
			stream_type::String,
			duration::Float64,
			electricity_intensity::Float64
		)::Float64
		factor = Dict(
			"HDVideo" => (1.21 * (10 ^ 9) * 8) / ((2 * 60 + 22) * 60),
			"fullHDVideo" => (7.02* (10 ^ 9) * 8) / ((2 * 60 + 22) * 60),
			"ultraHDVideo" => (35.73 * (10 ^ 9) * 8) / ((2 * 60 + 22) * 60),
			"audioMP3" => (3.8 * (10 ^ 6) * 8) / 154
		)
		data_weight = get(factor, stream_type, 0.0)
		total_carbonimpact = internet_carbonimpact(
			duration,
			data_weight,
			electricity_intensity
		)
		return total_carbonimpact
	end
end

# ╔═╡ cd98af32-4d4b-11eb-2ffb-edbe9a3c069b
md"""
## Transport

Unit: $kgCO_2eq/m$

**Sources**:
- https://static.ducky.eco/calculator_documentation.pdf
"""

# ╔═╡ 04b51758-52b7-11eb-10f9-f5be66cf0dec
transport_data = read_json("data/carbon_footprint/transport.json")

# ╔═╡ 1b612ec2-52c1-11eb-22aa-3b406bd64623
md"""
Transport type
$(@bind transport_select Select([k => k for (k, v) in transport_data]))

Transport distance in km
$(@bind transport_distance Slider(2:1000, default=10, show_value=true))

Food type
$(@bind food_select Select([k => k for (k, v) in food_data]))

Food amount in grams
$(@bind food_amount Slider(20:500, default=10, show_value=true))

Streaming type
$(@bind streaming_select Select(["HDVideo" => "Video HD",
			"fullHDVideo" => "Video - FullHD/1080p",
			"ultraHDVideo" => "Video - UltraHD/4K",
			"audioMP3" => "Audio - MP3"]))

Duration in minutes
$(@bind streaming_amount Slider(15:600, default=60, show_value=true))

Electricty location
$(@bind electricity_select Select([k => k for (k, v) in electricity_data]))

Electricity amount in kWh
$(@bind electricity_amount Slider(1:1000, default=10, show_value=true))

Recent purchases
$(@bind purchase_select MultiSelect([k => k for (k, v) in purchase_data]))
"""

# ╔═╡ f5225d7a-5846-11eb-1497-c5d439899e6b
begin
	function emission_calculator(
			transport_select::String,
			transport_distance::Integer,
			food_select::String,
			food_amount::Integer,
			streaming_select::String,
			streaming_amount::Integer,
			electricity_select::String,
			electricity_amount::Integer,
			purchase_select::Array,
	)::Dict
		transport_emissions = transport_data[transport_select] * transport_distance * 1000
		food_emissions = food_data[food_select] * food_amount / 1000
		streaming_emissions = streaming_carbonimpact(streaming_select,streaming_amount * 60.0,electricity_data["world"])
		electricity_emissions = electricity_data_pw[electricity_select] * electricity_amount
		if isempty(purchase_select)
			purchase_emissions = 0.0
		else
			purchase_emissions = sum([purchase_data[purchase] for purchase in purchase_select])
		end
		total_emissions = (transport_emissions + food_emissions + streaming_emissions + electricity_emissions + purchase_emissions)
		data = Dict(
			"transport" => transport_emissions,
			"food" => food_emissions,
			"streaming" => streaming_emissions,
			"electricity" => electricity_emissions,
			"purchase" => purchase_emissions,
			"total" => total_emissions,
			)
		return data
	end
end

# ╔═╡ 8aa42c6e-6354-11eb-3c43-cb16327595c2
begin
	function emission_calculator(
			transport_select::Array{String,1},
			transport_distance::Array{Int64,1},
			food_select::Array{String,1},
			food_amount::Array{Int64,1},
			streaming_select::Array{String,1},
			streaming_amount::Array{Int64,1},
			electricity_select::String,
			electricity_amount::Int64,
			purchase_select::Array{String, 1},
			purchase_amount::Array{Int64, 1},
	)::Dict
		transport_emissions = 0
		for (i, j) in zip(transport_select, transport_distance)
			transport_emissions += transport_data[i] * j * 1000
		end
		food_emissions = 0
		for (i, j) in zip(food_select, food_amount)
			food_emissions += food_data[i] * j / 1000
		end
		streaming_emissions = 0
		for (i, j) in zip(streaming_select, streaming_amount)
			streaming_emissions += streaming_carbonimpact(i, j * 60.0,electricity_data["world"])
		end
		electricity_emissions = electricity_data_pw[electricity_select] * electricity_amount
		purchase_emissions = 0.0
		for (i, j) in zip(purchase_select, purchase_amount)
			purchase_emissions += purchase_data[i] * j
		end
		total_emissions = (transport_emissions + food_emissions + streaming_emissions + electricity_emissions + purchase_emissions)
		data = Dict(
			"transport" => transport_emissions,
			"food" => food_emissions,
			"streaming" => streaming_emissions,
			"electricity" => electricity_emissions,
			"purchase" => purchase_emissions,
			"total" => total_emissions,
			)
		return data
	end
end

# ╔═╡ 9388aa8a-52c9-11eb-0dd8-3184bcfb93b2
begin
	emissions_data = emission_calculator(
			transport_select,
			transport_distance,
			food_select,
			food_amount,
			streaming_select,
			streaming_amount,
			electricity_select,
			electricity_amount,
			purchase_select,
	)
	transport_emissions = emissions_data["transport"]
	food_emissions =  emissions_data["food"]
	streaming_emissions =  emissions_data["streaming"]
	electricity_emissions =  emissions_data["electricity"]
	purchase_emissions = emissions_data["purchase"]
	total_emissions = emissions_data["total"]
	"Emissions calculation code"
end

# ╔═╡ 0a38c120-52c6-11eb-2ec5-e7780b3e11ec
md"""
## Emissions calculation

1. Transport emissions = $(@sprintf("%.3f", transport_emissions)) kgCO2eq

2. Food emissions = $(@sprintf("%.3f", food_emissions)) kgCO2eq

3. Streaming emissions = $(@sprintf("%.3f", streaming_emissions * 1000)) gCO2eq

4. Electricity emissions = $(@sprintf("%.3f", electricity_emissions)) kgCO2eq

5. Purchase emissions = $(@sprintf("%.3f", purchase_emissions)) kgCO2eq

**Total emissions** = $(@sprintf("%.3f", total_emissions)) kgCO2eq

"""

# ╔═╡ 2c63765e-68c3-11eb-317c-d1603846ca9c
begin
    function daily_emissions(person::Person)::Dict
        transport_distances = floor.(
			Int,
			rand(
				truncated(Normal(100, 50), 0, 1000),
				length(person.vehicles)
			)
		)
        food_amounts = floor.(
			Int,
			rand(
				truncated(Normal(200, 50), 0, 500),
				length(person.foods)
			)
		)
        stream_amounts = floor.(
			Int,
			rand(
				truncated(Normal(200, 50), 0, 600),
				length(person.streams)
			)
		)
        electricity_amounts = floor.(
			Int,
			rand(truncated(Normal(100, 20), 0, 1000))
		)
        purchase_amounts = floor.(
			Int,
			rand(
				Poisson(0.01),
				length(person.purchases)
			)
		)
		result = emission_calculator(
		person.vehicles,
		transport_distances,
		person.foods,
		food_amounts,
		person.streams,
		stream_amounts,
		person.country,
		electricity_amounts,
		person.purchases,
		purchase_amounts,
		)
		return result
    end
end

# ╔═╡ 4a052eb0-68cc-11eb-3cac-b74bcc789672
daily_emissions(person_1)

# ╔═╡ 594ab8f4-6347-11eb-3eb9-eb1cced757d4
begin
	n_transport_vehicles = rand((1, 2, 3))
	transport_vehicles = rand(keys(transport_data), n_transport_vehicles)
	transport_distances = floor.(Int, rand(Uniform(2, 1000), n_transport_vehicles))
end

# ╔═╡ 3ce4671c-6356-11eb-14bd-ddf8e43bc8de
result = emission_calculator(
		transport_vehicles,
		transport_distances,
		food_types,
		food_amounts,
		stream_types,
		stream_amounts,
		electricity_place,
		electricity_amounts,
		purchase_types,
		purchase_amounts,
)

# ╔═╡ 14743ea4-52c1-11eb-0cb4-8d3523a8f5ef
md"""---"""

# ╔═╡ Cell order:
# ╟─0442fbb8-52c0-11eb-06ea-01e68e330d5d
# ╟─5fbcb6e6-52ca-11eb-3e8c-1bb7495dc15d
# ╠═1b612ec2-52c1-11eb-22aa-3b406bd64623
# ╟─f5225d7a-5846-11eb-1497-c5d439899e6b
# ╟─8aa42c6e-6354-11eb-3c43-cb16327595c2
# ╟─9388aa8a-52c9-11eb-0dd8-3184bcfb93b2
# ╟─0a38c120-52c6-11eb-2ec5-e7780b3e11ec
# ╟─ec388b4a-52ca-11eb-097d-6760de18dd0e
# ╠═49f027da-5dce-11eb-3fff-0fd590112019
# ╠═672fef94-6351-11eb-0af1-652d5992e129
# ╠═49571046-68c2-11eb-071e-2709f8e40e48
# ╠═2c63765e-68c3-11eb-317c-d1603846ca9c
# ╠═521ebdb6-68c5-11eb-3bb2-8926b33ec780
# ╠═4a052eb0-68cc-11eb-3cac-b74bcc789672
# ╟─16fb0470-6351-11eb-104f-9de78182499d
# ╠═594ab8f4-6347-11eb-3eb9-eb1cced757d4
# ╟─eeee2d84-6352-11eb-3b69-0b3a53840e97
# ╟─f40c4d82-6352-11eb-3954-3dd3fcc0d776
# ╟─2b33df02-6353-11eb-07bf-c5a64c6c68d9
# ╟─545a4586-6353-11eb-20f8-b5de7cf57054
# ╟─c4403112-6353-11eb-09ff-5b78fe6d4581
# ╟─d150a918-6353-11eb-305b-2f50dadaeaed
# ╟─f106a442-6353-11eb-26fb-2fdc38c0bf80
# ╠═f7a05460-6353-11eb-3b57-1de112c66e4a
# ╟─bcb6b95e-6356-11eb-1662-397a7be9c496
# ╠═3ce4671c-6356-11eb-14bd-ddf8e43bc8de
# ╠═5552f080-5dce-11eb-013e-6f856304cdcf
# ╠═c065c808-5dd2-11eb-10d6-576b82dc5ce0
# ╠═78d20618-5dd3-11eb-03f4-b9a0e5f50e9a
# ╟─054ae36c-52cb-11eb-25aa-31355bbed6de
# ╠═3b2050da-52c1-11eb-3b89-1d5b6eb2cf40
# ╠═b4a152f0-4d4f-11eb-106b-b58e9f1495a9
# ╟─cedb71ac-52b9-11eb-19e7-9f433ffb4f14
# ╟─227d45a0-4d45-11eb-0cca-af99bc390097
# ╟─b2b598f8-4d3f-11eb-310d-7740ecc9d222
# ╟─0fcd983e-52b7-11eb-2c1f-13d00c8b4c43
# ╟─1fc15990-4d41-11eb-0f5f-c309cf01fdfa
# ╟─329e738a-52ba-11eb-22dd-fbfe2de89bb1
# ╟─fb596dc6-4d41-11eb-1dbd-6707e4fa7778
# ╟─83af9228-6353-11eb-0e5b-4550ac55ca4f
# ╟─cfd60bf8-4d43-11eb-00b7-bd162061b954
# ╟─cccb00f0-4d46-11eb-027b-ab6e07ce3ce5
# ╟─42eb4b3e-52ba-11eb-2178-11e1d2a887af
# ╟─e8574808-4d49-11eb-3515-2d66aadee9f2
# ╟─5e3ae372-4d4a-11eb-3e76-e7b1545f3759
# ╟─cd98af32-4d4b-11eb-2ffb-edbe9a3c069b
# ╟─04b51758-52b7-11eb-10f9-f5be66cf0dec
# ╟─14743ea4-52c1-11eb-0cb4-8d3523a8f5ef
