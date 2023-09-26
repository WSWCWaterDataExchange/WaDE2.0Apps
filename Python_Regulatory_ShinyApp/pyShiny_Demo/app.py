from pathlib import Path
from shiny import App, ui, render, reactive
from folium import plugins
from shinywidgets import output_widget, register_widget, render_widget
import ipyleaflet as ipyl
from ipyleaflet import Map, Polygon, GeoData, basemaps
import geopandas as gpd
import pandas as pd
import numpy as np

#coordinates to center map on US
center_coords = [39.8282, -98.5795]

#read in data
raw_data = gpd.read_file(Path(__file__).parent / "data/reportingunits_regulatoryoverlays_v2/reportingunits_regulatoryoverlays_v2.shp")
raw_data_pd = pd.DataFrame(raw_data)

#list of unique states, overlays, and water source types
states = raw_data_pd["StateCV"].unique().tolist()
overlays = raw_data_pd["Reportin_3"].unique().tolist()
water_sources = raw_data_pd['WaDENameWS'].unique().tolist()

#dictionary between StateCV and dataframe for the state
states_id_data_dict = {}
for state in states:
    state_data = raw_data[raw_data.StateCV == state]
    states_id_data_dict[state] = state_data

#dictionary between Reportin_3 and dataframe for the state
overlays_data_dict = {}
for overlay in overlays:
    overlay_data = raw_data[raw_data.Reportin_3 == overlay]
    overlays_data_dict[overlay] = overlay_data

#dictionary between unique StateCV and unique Overlay Type
state_overlay_dict = {}
for state in states:
    state_rows = raw_data[raw_data.StateCV == state]
    state_overlays = state_rows['Reportin_3'].unique()
    state_overlay_dict[state] = state_overlays

#dictionary between WaDENameWS and dataframe for the water sources
water_sources_data_dict = {}
for water_source in water_sources:
    water_source_data = raw_data[raw_data.WaDENameWS == water_source]
    water_sources_data_dict[water_source] = water_source_data

# define ui
app_ui = ui.page_fluid(
    ui.row(
       ui.column(
            2,
            ui.img(src="wswclogo.jpg", style="width: 80px; height: auto;")
        ),  # end column
        ui.column(
            10,    
            ui.h4({"style": "text-align: center;"}, "Administrative & Regulatory Overlay Demo"),
            ui.p({"style": "text-align: center; font-size: 12px; margin-bottom:\
            5px;"}, 'A web tool used to visualize regulatory overlays\
            in the Western United States.'),
            ui.p({"style": "text-align: center; font-size: 12px; color: red"}, \
            "DISCLAIMER: This tool is under construction, not for public \
            use, and has not yet been fully approved by our member states.")
        ), #end column
    ), #end row
    ui.row(
        ui.column(
            3,
            ui.div({"style": "text-align: center;"}, "Instructions"),
            ui.div({"style": "text-align: center; font-size: 12px;\
                    margin-bottom: 20px"},\
                   "Use filters to narrow down selection if desired."),
            ui.input_selectize('States', 'Select State', choices = states\
                               , multiple=True),
            ui.input_selectize('WS', 'Select Water Source Type', choices = water_sources, multiple = True),
            ui.input_selectize('RO', 'Select Administrative/Regulatory Overlay', choices = [],\
                               multiple = True)
        ),#end column
        ui.column(
            9,
            output_widget("my_map")
        )#end column
    )#end row
    
) #end page_fluid

# define server
def server(input, output, session):
    #insert map with all boundaries
    my_map = ipyl.Map(basemap=basemaps.Esri.WorldTopoMap, center = center_coords, zoom = 3)
    register_widget("my_map", my_map)
    all_overlays = GeoData(geo_dataframe = raw_data, style = {'weight': .5, 'fillOpacity':0.1},\
                           hover_style = {'fillColor':'red', 'fillOpacity': .5})
    my_map.add_layer(all_overlays)

    #"select regulatory overlay" interaction with "select state"
    @reactive.Effect
    def _():
        selected_state = input.States()
        overlay_type = []
        for state in selected_state:
           if state in state_overlay_dict.keys():
               overlay_type.extend(state_overlay_dict[state])

        ui.update_selectize("RO", choices = overlay_type)

    #"select administrative/regulatory overlay" interaction with boundaries
    @reactive.Effect
    def overlays_by_state():
        overlays_select = input.RO()
        for overlay in overlays_select:
            if overlay in overlays_data_dict.keys():
                overlay_id_data = overlays_data_dict[overlay]
                overlay_boundary = GeoData(geo_dataframe = overlay_id_data, style = {'weight': .5,\
                     'fillOpacity':0.1},
                     hover_style = {'fillColor':'red', 'fillOpacity': .5}     
                     )#end overlay_boundary

                try:
                    my_map.remove_layer(all_overlays)
                except:
                    print("map removed")
                my_map.add_layer(overlay_boundary)

# "select water source" interaction with boundaries  
    @reactive.Effect
    def boundaries_by_watersource():
        selected_states = input.States()
        selected_water_sources = input.WS()
        filtered_data = raw_data[
            (raw_data['StateCV'].isin(selected_states)) &
            (raw_data['WaDENameWS'].isin(selected_water_sources))]
        watersource_boundary = GeoData(geo_dataframe=filtered_data, style={'weight': 0.5,\
            'fillOpacity': 0.1},
            hover_style={'fillColor': 'red', 'fillOpacity': 0.5}
            )#end watersource_boundary
        if selected_water_sources:
            try:
                my_map.remove_layer(all_overlays)
            except:
                print('removed mpa')
            my_map.add_layer(watersource_boundary)
            
#if neither States nor RO are selected, add back the all_overlays layer
        elif not (input.States() or input.RO()):
            try:
                my_map.remove_layer(all_overlays)
            except:
                print('removed map')
            my_map.add_layer(all_overlays)

#define app
www_dir = Path(__file__).parent / "www"
app = App(app_ui, server, static_assets=www_dir) 
