import 'arcgis_key.dart';

class ArcgisConfig {
  static const String apiKey = arcgisApiKey;

  static const String satelliteUrl =
      'https://static-map-tiles-api.arcgis.com/arcgis/rest/services/'
      'static-basemap-tiles-service/v1/arcgis/imagery/labels/'
      'static/tile/{z}/{y}/{x}?token=$apiKey';
}
