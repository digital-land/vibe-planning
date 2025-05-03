CACHE_DIR=var/cache/

.PRECIOUS:

REGION=E12000003

# In and around Leeds, for now ..
GRIDS=\
	grid/E60000070.geojson\
	grid/E60000071.geojson\
	grid/E60000072.geojson\
	grid/E60000056.geojson\
	grid/E60000064.geojson\
	grid/E60000065.geojson\
	grid/E60000068.geojson

# Just Kirklees for now ..
GRIDS=\
	grid/E60000070.geojson

BOUNDARIES=$(patsubst grid/%,boundary/%,$(GRIDS))


all:: 	$(GRIDS) $(BOUNDARIES)

# brutally remove all spaces to reduce size
grid/%.geojson: var/grid/$(notdir %).geojson
	@mkdir -p $(dir $@)
	sed -e 's/ //g' < var/$@ > $@


var/grid/%.geojson:	\
	$(CACHE_DIR)statistical-geography/$(notdir %).geojson \
	$(CACHE_DIR)built-up-area/$(notdir %).geojson \
	$(CACHE_DIR)green-belt/$(notdir %).geojson \
	bin/create-grid.py 
	@mkdir -p $(dir $@)
	bin/create-grid.py \
		--cell_width 100 --cell_height 100 \
		--boundary var/cache/statistical-geography/$(notdir $@) \
		--coverage_file var/cache/green-belt/$(notdir $@) \
		       var/cache/built-up-area/$(notdir $@) \
		--output $@ \

boundary/%: $(CACHE_DIR)statistical-geography/%
	@mkdir -p $(dir $@)
	cp $< $@

# download LPA and other boundaries
$(CACHE_DIR)statistical-geography/%.geojson: 
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/curie/statistical-geography:$(@F)' > $@

# download coverage file within the LPA boundary
$(CACHE_DIR)green-belt/%.geojson:
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/entity.geojson?dataset=green-belt&geometry_curie=statistical-geography:$(basename $(@F))' > $@

$(CACHE_DIR)built-up-area/%.geojson:
	@mkdir -p $(dir $@)
	curl -qLfs 'https://www.planning.data.gov.uk/entity.geojson?dataset=built-up-area&limit=500&geometry_curie=statistical-geography:$(basename $(@F))' > $@

var/region.json:
	curl -qLfs 'https://www.planning.data.gov.uk/entity.json?dataset=local-planning-authority&field=name&field=reference&field=end-date&limit=100&geometry_curie=statistical-geography:$(REGION)' > $@


tidy:
	tidy -qmi -w 0 index.html

init::
	pip3 install -r requirements.txt

clean::
	rm -rf var 

clobber::
	rm -rf grid boundary
