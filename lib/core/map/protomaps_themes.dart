/// Protomaps basemap theme data for use with vector_tile_renderer ThemeReader.
///
/// These themes match the Protomaps v4 tile schema with layers:
///   earth, landuse, landcover, water, roads, buildings,
///   boundaries, places, pois, natural, transit

// ignore_for_file: prefer_single_quotes

/// Light theme colors inspired by Protomaps "light" flavor.
Map<String, dynamic> protomapsLightThemeData() => {
      "version": 8,
      "name": "Protomaps Light",
      "sources": {
        "protomaps": {"type": "vector", "maxzoom": 14}
      },
      "layers": [
        // ── Background ──
        {
          "id": "background",
          "type": "background",
          "paint": {"background-color": "#f0f0f0"}
        },
        // ── Earth (land mass) ──
        {
          "id": "earth",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "earth",
          "paint": {"fill-color": "#e8e4df"}
        },
        // ── Landcover ──
        {
          "id": "landcover-grass",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "grass"],
            ["==", "kind", "grassland"],
            ["==", "kind", "meadow"]
          ],
          "paint": {"fill-color": "#d0e8c8", "fill-opacity": 0.6}
        },
        {
          "id": "landcover-forest",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "forest"],
            ["==", "kind", "wood"]
          ],
          "paint": {"fill-color": "#b8d8a8", "fill-opacity": 0.5}
        },
        {
          "id": "landcover-sand",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "sand"],
            ["==", "kind", "beach"]
          ],
          "paint": {"fill-color": "#f5e8c8", "fill-opacity": 0.5}
        },
        // ── Landuse ──
        {
          "id": "landuse-park",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "park"],
            ["==", "kind", "nature_reserve"],
            ["==", "kind", "garden"]
          ],
          "paint": {"fill-color": "#d0e8c8", "fill-opacity": 0.5}
        },
        {
          "id": "landuse-hospital",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": ["==", "kind", "hospital"],
          "paint": {"fill-color": "#f8d8d8", "fill-opacity": 0.4}
        },
        {
          "id": "landuse-school",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "school"],
            ["==", "kind", "university"],
            ["==", "kind", "college"]
          ],
          "paint": {"fill-color": "#f0e8d8", "fill-opacity": 0.4}
        },
        {
          "id": "landuse-industrial",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "industrial"],
            ["==", "kind", "railway"]
          ],
          "paint": {"fill-color": "#e0dcd8", "fill-opacity": 0.4}
        },
        {
          "id": "landuse-residential",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": ["==", "kind", "residential"],
          "paint": {"fill-color": "#e8e4e0", "fill-opacity": 0.3}
        },
        // ── Natural ──
        {
          "id": "natural-wood",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "natural",
          "filter": ["==", "kind", "wood"],
          "paint": {"fill-color": "#b8d8a8", "fill-opacity": 0.5}
        },
        // ── Water ──
        {
          "id": "water",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "water",
          "paint": {"fill-color": "#a0c8f0"}
        },
        // ── Buildings ──
        {
          "id": "buildings",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "buildings",
          "minzoom": 13,
          "paint": {
            "fill-color": "#d8d4d0",
            "fill-opacity": {
              "stops": [
                [13, 0.3],
                [16, 0.6]
              ]
            }
          }
        },
        // ── Roads ──
        {
          "id": "roads-highway-casing",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "highway"],
          "paint": {
            "line-color": "#e0a060",
            "line-width": {
              "stops": [
                [5, 1.5],
                [10, 4],
                [14, 8],
                [18, 20]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-highway",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "highway"],
          "paint": {
            "line-color": "#f0c870",
            "line-width": {
              "stops": [
                [5, 1],
                [10, 3],
                [14, 6],
                [18, 16]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-major-casing",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": [
            "any",
            ["==", "kind", "major_road"],
            ["==", "kind", "trunk"]
          ],
          "paint": {
            "line-color": "#d0ccc8",
            "line-width": {
              "stops": [
                [8, 0.8],
                [12, 3],
                [16, 8]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-major",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": [
            "any",
            ["==", "kind", "major_road"],
            ["==", "kind", "trunk"]
          ],
          "paint": {
            "line-color": "#ffffff",
            "line-width": {
              "stops": [
                [8, 0.5],
                [12, 2],
                [16, 6]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-medium",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "medium_road"],
          "minzoom": 9,
          "paint": {
            "line-color": "#ffffff",
            "line-width": {
              "stops": [
                [9, 0.5],
                [14, 3],
                [18, 6]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-minor",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "minor_road"],
          "minzoom": 12,
          "paint": {
            "line-color": "#ffffff",
            "line-width": {
              "stops": [
                [12, 0.5],
                [16, 3],
                [18, 5]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-path",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "path"],
          "minzoom": 14,
          "paint": {
            "line-color": "#d0ccc8",
            "line-width": 1,
            "line-dasharray": [2, 2]
          }
        },
        // ── Transit ──
        {
          "id": "transit-rail",
          "type": "line",
          "source": "protomaps",
          "source-layer": "transit",
          "filter": ["==", "kind", "rail"],
          "minzoom": 11,
          "paint": {
            "line-color": "#c0b8b0",
            "line-width": 1,
            "line-dasharray": [4, 3]
          }
        },
        // ── Boundaries ──
        {
          "id": "boundaries-country",
          "type": "line",
          "source": "protomaps",
          "source-layer": "boundaries",
          "filter": ["==", "kind", "country"],
          "paint": {
            "line-color": "#a0a0a0",
            "line-width": {
              "stops": [
                [1, 0.5],
                [6, 1.5],
                [10, 2]
              ]
            },
            "line-dasharray": [3, 2]
          }
        },
        {
          "id": "boundaries-region",
          "type": "line",
          "source": "protomaps",
          "source-layer": "boundaries",
          "filter": ["==", "kind", "region"],
          "minzoom": 4,
          "paint": {
            "line-color": "#c0c0c0",
            "line-width": {
              "stops": [
                [4, 0.3],
                [8, 0.8]
              ]
            },
            "line-dasharray": [2, 2]
          }
        },
        // ── Place labels ──
        {
          "id": "places-country",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "country"],
          "maxzoom": 7,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [2, 10],
                [6, 16]
              ]
            },
            "text-transform": "uppercase",
            "text-letter-spacing": 0.1
          },
          "paint": {
            "text-color": "#505050",
            "text-halo-color": "#ffffff",
            "text-halo-width": 2
          }
        },
        {
          "id": "places-region",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "region"],
          "minzoom": 5,
          "maxzoom": 9,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [5, 9],
                [8, 13]
              ]
            },
            "text-transform": "uppercase",
            "text-letter-spacing": 0.08
          },
          "paint": {
            "text-color": "#707070",
            "text-halo-color": "#ffffff",
            "text-halo-width": 1.5
          }
        },
        {
          "id": "places-city",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "city"],
          "minzoom": 4,
          "maxzoom": 14,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [4, 10],
                [8, 14],
                [12, 18]
              ]
            }
          },
          "paint": {
            "text-color": "#404040",
            "text-halo-color": "#ffffff",
            "text-halo-width": 2
          }
        },
        {
          "id": "places-town",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "town"],
          "minzoom": 8,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [8, 10],
                [14, 16]
              ]
            }
          },
          "paint": {
            "text-color": "#505050",
            "text-halo-color": "#ffffff",
            "text-halo-width": 1.5
          }
        },
        {
          "id": "places-village",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": [
            "any",
            ["==", "kind", "village"],
            ["==", "kind", "suburb"],
            ["==", "kind", "neighbourhood"]
          ],
          "minzoom": 11,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [11, 9],
                [16, 14]
              ]
            }
          },
          "paint": {
            "text-color": "#606060",
            "text-halo-color": "#ffffff",
            "text-halo-width": 1
          }
        },
      ]
    };

/// Dark theme colors inspired by Protomaps "dark" flavor.
Map<String, dynamic> protomapsDarkThemeData() => {
      "version": 8,
      "name": "Protomaps Dark",
      "sources": {
        "protomaps": {"type": "vector", "maxzoom": 14}
      },
      "layers": [
        // ── Background ──
        {
          "id": "background",
          "type": "background",
          "paint": {"background-color": "#1a1a2e"}
        },
        // ── Earth ──
        {
          "id": "earth",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "earth",
          "paint": {"fill-color": "#222236"}
        },
        // ── Landcover ──
        {
          "id": "landcover-grass",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "grass"],
            ["==", "kind", "grassland"],
            ["==", "kind", "meadow"]
          ],
          "paint": {"fill-color": "#1e3020", "fill-opacity": 0.5}
        },
        {
          "id": "landcover-forest",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "forest"],
            ["==", "kind", "wood"]
          ],
          "paint": {"fill-color": "#1a2e1a", "fill-opacity": 0.5}
        },
        {
          "id": "landcover-sand",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landcover",
          "filter": [
            "any",
            ["==", "kind", "sand"],
            ["==", "kind", "beach"]
          ],
          "paint": {"fill-color": "#302818", "fill-opacity": 0.4}
        },
        // ── Landuse ──
        {
          "id": "landuse-park",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "park"],
            ["==", "kind", "nature_reserve"],
            ["==", "kind", "garden"]
          ],
          "paint": {"fill-color": "#1e3020", "fill-opacity": 0.4}
        },
        {
          "id": "landuse-hospital",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": ["==", "kind", "hospital"],
          "paint": {"fill-color": "#301818", "fill-opacity": 0.3}
        },
        {
          "id": "landuse-school",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "school"],
            ["==", "kind", "university"],
            ["==", "kind", "college"]
          ],
          "paint": {"fill-color": "#282018", "fill-opacity": 0.3}
        },
        {
          "id": "landuse-industrial",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "landuse",
          "filter": [
            "any",
            ["==", "kind", "industrial"],
            ["==", "kind", "railway"]
          ],
          "paint": {"fill-color": "#1e1e28", "fill-opacity": 0.3}
        },
        // ── Natural ──
        {
          "id": "natural-wood",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "natural",
          "filter": ["==", "kind", "wood"],
          "paint": {"fill-color": "#1a2e1a", "fill-opacity": 0.4}
        },
        // ── Water ──
        {
          "id": "water",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "water",
          "paint": {"fill-color": "#182848"}
        },
        // ── Buildings ──
        {
          "id": "buildings",
          "type": "fill",
          "source": "protomaps",
          "source-layer": "buildings",
          "minzoom": 13,
          "paint": {
            "fill-color": "#2a2a3e",
            "fill-opacity": {
              "stops": [
                [13, 0.3],
                [16, 0.6]
              ]
            }
          }
        },
        // ── Roads ──
        {
          "id": "roads-highway-casing",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "highway"],
          "paint": {
            "line-color": "#6a4820",
            "line-width": {
              "stops": [
                [5, 1.5],
                [10, 4],
                [14, 8],
                [18, 20]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-highway",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "highway"],
          "paint": {
            "line-color": "#806030",
            "line-width": {
              "stops": [
                [5, 1],
                [10, 3],
                [14, 6],
                [18, 16]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-major",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": [
            "any",
            ["==", "kind", "major_road"],
            ["==", "kind", "trunk"]
          ],
          "paint": {
            "line-color": "#383848",
            "line-width": {
              "stops": [
                [8, 0.5],
                [12, 2],
                [16, 6]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-medium",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "medium_road"],
          "minzoom": 9,
          "paint": {
            "line-color": "#303040",
            "line-width": {
              "stops": [
                [9, 0.5],
                [14, 3],
                [18, 6]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-minor",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "minor_road"],
          "minzoom": 12,
          "paint": {
            "line-color": "#282838",
            "line-width": {
              "stops": [
                [12, 0.5],
                [16, 3],
                [18, 5]
              ]
            }
          },
          "layout": {"line-cap": "round", "line-join": "round"}
        },
        {
          "id": "roads-path",
          "type": "line",
          "source": "protomaps",
          "source-layer": "roads",
          "filter": ["==", "kind", "path"],
          "minzoom": 14,
          "paint": {
            "line-color": "#303040",
            "line-width": 1,
            "line-dasharray": [2, 2]
          }
        },
        // ── Transit ──
        {
          "id": "transit-rail",
          "type": "line",
          "source": "protomaps",
          "source-layer": "transit",
          "filter": ["==", "kind", "rail"],
          "minzoom": 11,
          "paint": {
            "line-color": "#383848",
            "line-width": 1,
            "line-dasharray": [4, 3]
          }
        },
        // ── Boundaries ──
        {
          "id": "boundaries-country",
          "type": "line",
          "source": "protomaps",
          "source-layer": "boundaries",
          "filter": ["==", "kind", "country"],
          "paint": {
            "line-color": "#505060",
            "line-width": {
              "stops": [
                [1, 0.5],
                [6, 1.5],
                [10, 2]
              ]
            },
            "line-dasharray": [3, 2]
          }
        },
        {
          "id": "boundaries-region",
          "type": "line",
          "source": "protomaps",
          "source-layer": "boundaries",
          "filter": ["==", "kind", "region"],
          "minzoom": 4,
          "paint": {
            "line-color": "#404050",
            "line-width": {
              "stops": [
                [4, 0.3],
                [8, 0.8]
              ]
            },
            "line-dasharray": [2, 2]
          }
        },
        // ── Place labels ──
        {
          "id": "places-country",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "country"],
          "maxzoom": 7,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [2, 10],
                [6, 16]
              ]
            },
            "text-transform": "uppercase",
            "text-letter-spacing": 0.1
          },
          "paint": {
            "text-color": "#b0b0c0",
            "text-halo-color": "#1a1a2e",
            "text-halo-width": 2
          }
        },
        {
          "id": "places-region",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "region"],
          "minzoom": 5,
          "maxzoom": 9,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [5, 9],
                [8, 13]
              ]
            },
            "text-transform": "uppercase",
            "text-letter-spacing": 0.08
          },
          "paint": {
            "text-color": "#9090a0",
            "text-halo-color": "#1a1a2e",
            "text-halo-width": 1.5
          }
        },
        {
          "id": "places-city",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "city"],
          "minzoom": 4,
          "maxzoom": 14,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [4, 10],
                [8, 14],
                [12, 18]
              ]
            }
          },
          "paint": {
            "text-color": "#c0c0d0",
            "text-halo-color": "#1a1a2e",
            "text-halo-width": 2
          }
        },
        {
          "id": "places-town",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": ["==", "kind", "town"],
          "minzoom": 8,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [8, 10],
                [14, 16]
              ]
            }
          },
          "paint": {
            "text-color": "#a0a0b0",
            "text-halo-color": "#1a1a2e",
            "text-halo-width": 1.5
          }
        },
        {
          "id": "places-village",
          "type": "symbol",
          "source": "protomaps",
          "source-layer": "places",
          "filter": [
            "any",
            ["==", "kind", "village"],
            ["==", "kind", "suburb"],
            ["==", "kind", "neighbourhood"]
          ],
          "minzoom": 11,
          "layout": {
            "text-field": "{name}",
            "text-size": {
              "stops": [
                [11, 9],
                [16, 14]
              ]
            }
          },
          "paint": {
            "text-color": "#808090",
            "text-halo-color": "#1a1a2e",
            "text-halo-width": 1
          }
        },
      ]
    };

