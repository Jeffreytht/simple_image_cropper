import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'package:simple_image_cropper/test.dart';

void main() {
  testWidgets('Test dragging and cropping', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(MyApp());

    expect(find.byType(Demo), findsOneWidget);
    expect(find.byIcon(Icons.crop), findsOneWidget);

    final DemoState state = tester.state(find.byType(Demo));
    expect(state.cropKey, isNotNull);

    final GlobalKey cropKey = state.cropKey;
    expect(find.byKey(cropKey), findsOneWidget);

    final SimpleImageCropper cropper = tester.widget(find.byKey(cropKey));
    expect(cropper, isNotNull);

    final SimpleImageCropperState cropperState =
        tester.state(find.byKey(cropKey));

    expect(cropperState, isNotNull);
  });
}
