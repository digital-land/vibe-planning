CACHE_DIR=var/cache/

.PRECIOUS: $(CACHE_DIR)

REGION=E12000003

# Yorkshire and Humberside
GRIDS=\
	grid/E60000070.geojson

all:: 	$(GRIDS)

# brutally remove all spaces to reduce size
grid/%.geojson: var/grid/$(notdir %).geojson
	@mkdir -p $(dir $@)
	sed -e 's/ //g' < var/$@ > $@


var/grid/%.geojson:	$(CACHE_DIR)statistical-geography/$(notdir %).geojson $(CACHE_DIR)green-belt/$(notdir %).geojson bin/create-grid.py
	@mkdir -p $(dir $@)
	bin/create-grid.py \
		--cell_width 100 --cell_height 100 \
		--boundary var/cache/statistical-geography/$(notdir $@) \
		--coverage_file var/cache/green-belt/$(notdir $@) \
		--output $@ \


# download LPA and other boundaries
$(CACHE_DIR)statistical-geography/%.geojson: 
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/curie/statistical-geography:$(@F)' > $@

# download green-belt within the LPA boundary
$(CACHE_DIR)green-belt/%.geojson:
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/entity.geojson?dataset=green-belt&geometry_curie=statistical-geography:$(basename $(@F))' > $@

init::
	pip3 install -r requirements.txt

clean::
	rm -rf var 

clobber::
	rm -rf grid
