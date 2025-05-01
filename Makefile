REGION=E12000003
CACHE_DIR=var/cache/

GRIDS=\
	grid/E60000070.geojson

all:: 	$(GRIDS)

grid/E60000070.geojson: $(CACHE_DIR)E60000070.geojson $(CACHE_DIR)green-belt/E60000070.geojson bin/create-grid.py
	@mkdir -p $(dir $@)
	bin/create-grid.py \
		--cell_width 100 --cell_height 100 \
		--boundary var/cache/E60000070.geojson \
		--coverage_file var/cache/green-belt/E60000070.geojson \
		--output $@ \


$(CACHE_DIR)E60000070.geojson: 
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/curie/statistical-geography:E60000070.geojson' > $@

$(CACHE_DIR)green-belt/E60000070.geojson: 
	@mkdir -p $(dir $@)
	curl -qfs 'https://www.planning.data.gov.uk/entity.geojson?dataset=green-belt&geometry_curie=statistical-geography:E60000070' > $@

$(CACHE_DIR)region.geojson: 
	@mkdir -p $(CACHE_DIR)
	curl -qLfs 'https://www.planning.data.gov.uk/curie/statistical-geography:$(REGION).geojson' > $@

init::
	pip3 install -r requirements.txt
