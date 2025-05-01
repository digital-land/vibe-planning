CACHE_DIR=var/cache/

.PRECIOUS: $(CACHE_DIR)

REGION=E12000003

# In and around Leeds, for now ..
GRIDS=\
	grid/E60000070.geojson\
	grid/E60000071.geojson\
	grid/E60000072.geojson\
	grid/E60000056.geojson\
	grid/E60000064.geojson\
	grid/E60000065.geojson\
	grid/E60000068.geojson\
	grid/E60000052.geojson\
	grid/E60000336.geojson



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

var/region.json:
	curl -qLfs 'https://www.planning.data.gov.uk/entity.json?dataset=local-planning-authority&field=name&field=reference&field=end-date&limit=100&geometry_curie=statistical-geography:$(REGION)' > $@


init::
	pip3 install -r requirements.txt

clean::
	rm -rf var 

clobber::
	rm -rf grid
