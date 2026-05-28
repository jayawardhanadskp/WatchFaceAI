import 'package:flutter_test/flutter_test.dart';
import 'package:watchface_ai/models/watch_face_config.dart';

void main() {
  group('WatchFaceConfig Tests', () {
    test('should serialize and deserialize correctly', () {
      const config = WatchFaceConfig(
        backgroundColor: '#000000',
        timeColor: '#FFFFFF',
        accentColor: '#FF0000',
        showSteps: true,
        showBattery: false,
        showDate: true,
        fontStyle: 'bold',
        layout: 'sport',
        borderStyle: 'ring',
        clockType: 'analog',
        timeFormat: '12h',
        imagePrompt: 'A futuristic city',
      );

      final json = config.toJson();
      expect(json['backgroundColor'], '#000000');
      expect(json['timeColor'], '#FFFFFF');
      expect(json['accentColor'], '#FF0000');
      expect(json['showSteps'], true);
      expect(json['showBattery'], false);
      expect(json['showDate'], true);
      expect(json['fontStyle'], 'bold');
      expect(json['layout'], 'sport');
      expect(json['borderStyle'], 'ring');
      expect(json['clockType'], 'analog');
      expect(json['timeFormat'], '12h');
      expect(json['imagePrompt'], 'A futuristic city');

      final fromJson = WatchFaceConfig.fromJson(json);
      expect(fromJson.backgroundColor, config.backgroundColor);
      expect(fromJson.timeColor, config.timeColor);
      expect(fromJson.accentColor, config.accentColor);
      expect(fromJson.showSteps, config.showSteps);
      expect(fromJson.showBattery, config.showBattery);
      expect(fromJson.showDate, config.showDate);
      expect(fromJson.fontStyle, config.fontStyle);
      expect(fromJson.layout, config.layout);
      expect(fromJson.borderStyle, config.borderStyle);
      expect(fromJson.clockType, config.clockType);
      expect(fromJson.timeFormat, config.timeFormat);
      expect(fromJson.imagePrompt, config.imagePrompt);
    });

    test('should return default config', () {
      final config = WatchFaceConfig.defaultConfig();
      expect(config.backgroundColor, '#0A0A0F');
      expect(config.timeColor, '#FFFFFF');
      expect(config.accentColor, '#6C63FF');
      expect(config.clockType, 'digital');
    });
  });
}
