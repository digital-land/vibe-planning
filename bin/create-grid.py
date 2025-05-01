#! /usr/bin/env python3

from os.path import dirname, basename
import geopandas as gpd
from shapely.geometry import box
import numpy as np
import argparse
from pyproj import CRS, Transformer
import math


def find_suitable_utm_zone(lon, lat):
    """Find the most suitable UTM zone for a given location"""
    utm_zone = int(math.floor((lon + 180) / 6) + 1)
    epsg = 32600 + utm_zone
    if lat < 0:  # Southern hemisphere
        epsg += 100
    return f"EPSG:{epsg}"

def create_grid_from_boundary(boundary_file, cell_width_meters, cell_height_meters, coverage_polygon_files):
    """
    Create a grid of rectangular cells within a boundary polygon
    
    Parameters:
    - boundary_file: Path to polygon file defining the boundary
    - cell_width_meters: Width of each cell in meters
    - cell_height_meters: Height of each cell in meters
    - min_coverage_pct: Minimum percentage of cell that must be within boundary to be included
    - coverage_polygon_files: Optional list of files with polygons to calculate coverage for
    
    Returns:
    - GeoDataFrame containing grid cells as Polygon geometries
    """

    # Load the boundary file
    boundary_gdf = gpd.read_file(boundary_file)
    
    # Ensure the boundary is a single polygon
    if len(boundary_gdf) > 1:
        boundary_gdf = boundary_gdf.dissolve()
    
    # Get boundary in WGS84
    if boundary_gdf.crs is None:
        boundary_gdf.crs = "EPSG:4326"
    elif boundary_gdf.crs != "EPSG:4326":
        boundary_gdf = boundary_gdf.to_crs("EPSG:4326")
    
    # Find centroid of the boundary
    centroid = boundary_gdf.unary_union.centroid
    center_lon, center_lat = centroid.x, centroid.y
    
    # Find suitable UTM zone for the area
    utm_crs = find_suitable_utm_zone(center_lon, center_lat)
    
    # Convert boundary to UTM for meter-based operations
    boundary_utm = boundary_gdf.to_crs(utm_crs)
    
    # Get UTM bounds of the boundary
    minx, miny, maxx, maxy = boundary_utm.total_bounds
    
    # Calculate number of cells in each direction
    cols = int(np.ceil((maxx - minx) / cell_width_meters))
    rows = int(np.ceil((maxy - miny) / cell_height_meters))
    
    # Create empty lists to store data
    geometries = []
    ids = []
    row_indices = []
    col_indices = []
    
    # Generate grid cells in UTM
    cell_id = 0
    for i in range(cols):
        for j in range(rows):
            # Calculate cell bounds in UTM
            x_min = minx + i * cell_width_meters
            y_min = miny + j * cell_height_meters
            x_max = min(x_min + cell_width_meters, maxx)
            y_max = min(y_min + cell_height_meters, maxy)
            
            # Create cell polygon in UTM
            cell = box(x_min, y_min, x_max, y_max)
            
            # Store cell data
            geometries.append(cell)
            ids.append(cell_id)
            row_indices.append(j)
            col_indices.append(i)
            
            cell_id += 1

    # Create GeoDataFrame with UTM CRS
    data = {
        'id': ids,
    }
    
    grid_gdf = gpd.GeoDataFrame(data, geometry=geometries, crs=utm_crs)

    # Get the boundary polygon
    boundary_polygon = boundary_utm.geometry.unary_union

    grid_gdf['clipped_geometry'] = grid_gdf.geometry.intersection(boundary_polygon)
    grid_gdf = grid_gdf[~grid_gdf['clipped_geometry'].is_empty].copy()
    grid_gdf['geometry'] = grid_gdf['clipped_geometry']
    grid_gdf = grid_gdf.drop(columns=['clipped_geometry'])
        
    # Reset index and re-number IDs after filtering
    grid_gdf = grid_gdf.reset_index(drop=True)
    grid_gdf['id'] = range(len(grid_gdf))
    
    names = []
    for coverage_polygon_file in coverage_polygon_files:
        print("coverage_polygon_file")
        name = basename(dirname(coverage_polygon_file))
        names.append(name)
        print(names)

        # Load the coverage polygons
        coverage_gdf = gpd.read_file(coverage_polygon_file)
        
        # Convert to UTM
        if coverage_gdf.crs != utm_crs:
            coverage_gdf = coverage_gdf.to_crs(utm_crs)
        
        # Dissolve polygons if there are multiple features
        if len(coverage_gdf) > 1:
            coverage_gdf = coverage_gdf.dissolve()
        
        # Get the coverage polygon geometry
        coverage_polygon = coverage_gdf.geometry.unary_union
        
        # Calculate intersection with coverage polygons and its area
        grid_gdf['coverage_intersection'] = grid_gdf.geometry.intersection(coverage_polygon)
        grid_gdf[name] = grid_gdf['coverage_intersection'].area
        
        # Clean up intermediate columns
        grid_gdf = grid_gdf.drop(columns=['coverage_intersection'])
    
    # Convert back to WGS84 (EPSG:4326) for GeoJSON output
    grid_gdf_wgs84 = grid_gdf.to_crs("EPSG:4326")
    
    # Transfer the coverages
    for name in names:
        if name in grid_gdf.columns:
            grid_gdf_wgs84[name] = grid_gdf[name]

    return grid_gdf_wgs84

def main():
    parser = argparse.ArgumentParser(description='Generate a grid within a boundary polygon with cell size in meters')
    parser.add_argument('--boundary', type=str, required=True, help='Path to boundary polygon file')
    parser.add_argument('--cell_width', type=float, required=True, help='Cell width in meters')
    parser.add_argument('--cell_height', type=float, required=True, help='Cell height in meters')
    parser.add_argument('--coverage_file', type=str, help='Optional file with polygons to calculate coverage for', action='append', nargs='+')
    parser.add_argument('--output', type=str, default='grid_boundary.geojson', help='Output GeoJSON file')
    
    args = parser.parse_args()

    print(args.coverage_file)
    
    # Create grid within boundary with cell dimensions in meters
    grid_gdf = create_grid_from_boundary(
        args.boundary, 
        args.cell_width, 
        args.cell_height,
        args.coverage_file[0]
    )
    
    # Save to GeoJSON
    grid_gdf.geometry = grid_gdf.geometry.set_precision(grid_size=0.000001)
    grid_gdf.to_file(args.output, driver='GeoJSON')
    print(f"Grid saved to {args.output}")

if __name__ == "__main__":
    main()
