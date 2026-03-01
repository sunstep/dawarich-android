import 'package:dawarich/core/map/protomaps_themes.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

/// Provides pre-configured vector tile layers for the Protomaps-based map.
final class VectorMapConfig {
  VectorMapConfig._();

  static const _tileUrl =
      'https://tyles.dwri.xyz/planet/{z}/{x}/{y}.mvt';

  /// The source ID must match the one used in the theme JSON.
  static const _sourceId = 'protomaps';

  static const _maxZoom = 14;

  static TileProviders tileProviders() {
    return TileProviders({
      _sourceId: NetworkVectorTileProvider(
        urlTemplate: _tileUrl,
        maximumZoom: _maxZoom,
      ),
    });
  }

  static Theme lightTheme() =>
      ThemeReader().read(protomapsLightThemeData());

  static Theme darkTheme() =>
      ThemeReader().read(protomapsDarkThemeData());
}
