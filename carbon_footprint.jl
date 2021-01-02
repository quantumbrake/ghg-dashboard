### A Pluto.jl notebook ###
# v0.12.17

using Markdown
using InteractiveUtils

# ╔═╡ 227d45a0-4d45-11eb-0cca-af99bc390097
to_joules(x::Float64)::Float64 = x * 3.6 * (10 ^ 6);

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

# ╔═╡ 1fc15990-4d41-11eb-0f5f-c309cf01fdfa
md"""
## Food

Unit: $kgCO_2eq$

**Sources**:
- http://www.greeneatz.com/foods-carbon-footprint.html
- https://www.bilans-ges.ademe.fr
"""

# ╔═╡ fb596dc6-4d41-11eb-1dbd-6707e4fa7778
md"""
## Internet

Unit: $kgCO_2eq$

```ts
const toJoules = (x: number) => x * 3.6 * Math.pow(10, 6);

/* 0.007 & 0.058 in kWh/GB - divide by 8 to get bits */
const FactorDataCenter = toJoules(0.007 * Math.pow(10, -9)) / 8;
const FactorNetwork = toJoules(0.058 * Math.pow(10, -9)) / 8;
/* 0.055 in kWh/hr */
const FactorDevice = toJoules(0.055 / (60 * 60));

/*
    duration : Seconds
    dataWeight : Bits
    carbonElectricityIntensity : kgCO₂eq/J
*/
const getInternetUsageCarbonImpact = (
  duration: number,
  dataWeight: number,
  carbonElectricityIntensity: ElectricityType,
): number => {
  /* GHG : greenhouse gas */
  const GHGdataCenter = dataWeight * FactorDataCenter * electricity.world;

  const GHGnetwork = dataWeight * FactorNetwork * electricity.world;

  const GHGdevice = duration * FactorDevice * electricity[carbonElectricityIntensity];

  /* kgCO₂eq */
  return GHGdataCenter + GHGnetwork + GHGdevice;
};
```

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
			"datacenter" => toJoules(0.007 * (10 ^ (-9))) / 8,
			"network" => toJoules(0.058 * (10 ^ (-9))) / 8,
			"device" => toJoules(0.055 / (60 * 60))
		)
		ghg_datacenter = data_weight * get(factor, "datacenter", 0.0) * EW
		ghg_network = data_weight * get(factor, "network", 0.0) * EW
		ghg_device = duration * get(factor, "device", 0.0) * electricity_intensity
		total = ghg_datacenter + ghg_network + ghg_device
		return total
	end
end

# ╔═╡ cccb00f0-4d46-11eb-027b-ab6e07ce3ce5
md"""
## Purchases

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

# ╔═╡ e8574808-4d49-11eb-3515-2d66aadee9f2
md"""
## Streaming

Unit: $bit/s$

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
		data_weight = factor(stream_type)
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

# ╔═╡ b4a152f0-4d4f-11eb-106b-b58e9f1495a9
# Next load the json files
# Use https://github.com/JuliaIO/JSON.jl

# ╔═╡ Cell order:
# ╠═227d45a0-4d45-11eb-0cca-af99bc390097
# ╟─b2b598f8-4d3f-11eb-310d-7740ecc9d222
# ╟─1fc15990-4d41-11eb-0f5f-c309cf01fdfa
# ╟─fb596dc6-4d41-11eb-1dbd-6707e4fa7778
# ╠═cfd60bf8-4d43-11eb-00b7-bd162061b954
# ╟─cccb00f0-4d46-11eb-027b-ab6e07ce3ce5
# ╟─e8574808-4d49-11eb-3515-2d66aadee9f2
# ╟─5e3ae372-4d4a-11eb-3e76-e7b1545f3759
# ╟─cd98af32-4d4b-11eb-2ffb-edbe9a3c069b
# ╠═b4a152f0-4d4f-11eb-106b-b58e9f1495a9
