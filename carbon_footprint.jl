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

# ╔═╡ 3b2050da-52c1-11eb-3b89-1d5b6eb2cf40
using PlutoUI, Printf

# ╔═╡ 0442fbb8-52c0-11eb-06ea-01e68e330d5d
md"""
# Dashboard
"""

# ╔═╡ 5fbcb6e6-52ca-11eb-3e8c-1bb7495dc15d
md"""## Add emission """

# ╔═╡ ec388b4a-52ca-11eb-097d-6760de18dd0e
md"""---"""

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

# ╔═╡ fb596dc6-4d41-11eb-1dbd-6707e4fa7778
md"""
## Internet

Unit: $kgCO_2eq$

**Sources**:
- https://theshiftproject.org/wp-content/uploads/2019/03/Lean-ICT-Report_The-Shift-Project_2019.pdf
- https://github.com/carbonalyser/
- https://www.carbonbrief.org/factcheck-what-is-the-carbon-footprint-of-streaming-video-on-netflix
"""

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
"""

# ╔═╡ 14743ea4-52c1-11eb-0cb4-8d3523a8f5ef
md"""---"""

# ╔═╡ 9388aa8a-52c9-11eb-0dd8-3184bcfb93b2
begin
	transport_emissions = transport_data[transport_select] * transport_distance * 1000
	food_emissions = food_data[food_select] * food_amount;
	streaming_emissions = streaming_carbonimpact(streaming_select,streaming_amount * 60.0,electricity_data["world"]);
	electricity_emissions = electricity_data_pw[electricity_select] * electricity_amount;
	total_emissions = (transport_emissions + food_emissions + streaming_emissions + electricity_emissions);
end;

# ╔═╡ 0a38c120-52c6-11eb-2ec5-e7780b3e11ec
md"""
## Emissions calculation

1. Transport emissions = $(@sprintf("%.3f", transport_emissions)) kgCO2eq

2. Food emissions = $(@sprintf("%.3f", food_emissions)) kgCO2eq

3. Streaming emissions = $(@sprintf("%.3f", streaming_emissions * 1000)) gCO2eq

4. Electricity emissions = $(@sprintf("%.3f", electricity_emissions)) kgCO2eq

**Total emissions** = $(@sprintf("%.3f", total_emissions)) kgCO2eq

"""

# ╔═╡ Cell order:
# ╟─0442fbb8-52c0-11eb-06ea-01e68e330d5d
# ╟─5fbcb6e6-52ca-11eb-3e8c-1bb7495dc15d
# ╟─1b612ec2-52c1-11eb-22aa-3b406bd64623
# ╟─0a38c120-52c6-11eb-2ec5-e7780b3e11ec
# ╟─ec388b4a-52ca-11eb-097d-6760de18dd0e
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
# ╟─cfd60bf8-4d43-11eb-00b7-bd162061b954
# ╟─cccb00f0-4d46-11eb-027b-ab6e07ce3ce5
# ╟─42eb4b3e-52ba-11eb-2178-11e1d2a887af
# ╟─e8574808-4d49-11eb-3515-2d66aadee9f2
# ╟─5e3ae372-4d4a-11eb-3e76-e7b1545f3759
# ╟─cd98af32-4d4b-11eb-2ffb-edbe9a3c069b
# ╟─04b51758-52b7-11eb-10f9-f5be66cf0dec
# ╟─14743ea4-52c1-11eb-0cb4-8d3523a8f5ef
# ╟─9388aa8a-52c9-11eb-0dd8-3184bcfb93b2
