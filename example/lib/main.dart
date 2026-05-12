import 'package:flutter/material.dart';
import 'package:pickafeature/pickafeature.dart';

// Replace with your real API key from https://pickafeature.com/settings
// (Settings → API Keys section in your dashboard)
const String kPickAFeatureApiKey = 'YOUR_API_KEY_HERE';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PickAFeature.initialize(
    config: PickAFeatureConfig(
      apiKey: kPickAFeatureApiKey,
    ),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pick a feature — example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature requests')),
      body: PickAFeatureScreen(
        config: PickAFeatureConfig(
          apiKey: kPickAFeatureApiKey,
          customTitle: 'What should we build next?',
          customSubtitle: 'Suggest, vote, comment',
          showEmailField: true,
        ),
      ),
    );
  }
}
