import 'package:flutter/material.dart';
import 'package:bank_sha/utils/app_config.dart';

class EnvironmentSwitcherWidget extends StatefulWidget {
  const EnvironmentSwitcherWidget({super.key});

  @override
  State<EnvironmentSwitcherWidget> createState() =>
      _EnvironmentSwitcherWidgetState();
}

class _EnvironmentSwitcherWidgetState extends State<EnvironmentSwitcherWidget> {
  String currentUrl = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  void _loadCurrentUrl() {
    setState(() {
      currentUrl = AppConfig.apiBaseUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment Configuration',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Current API URL: $currentUrl',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _switchEnvironment(AppConfig.PRODUCTION_API_URL),
                  child: const Text('Production'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _switchEnvironment(AppConfig.STAGING_API_URL),
                  child: const Text('Staging'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _switchEnvironment(AppConfig.DEVELOPMENT_API_URL),
                  child: const Text('Development'),
                ),
                ElevatedButton(
                  onPressed: _resetToDefault,
                  child: const Text('Reset'),
                ),
              ],
            ),
            if (AppConfig.isUsingCustomApiUrl)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Using custom API URL',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchEnvironment(String url) async {
    await AppConfig.setApiBaseUrl(url);
    _loadCurrentUrl();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to: $url'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    await AppConfig.resetApiBaseUrl();
    _loadCurrentUrl();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset to default environment'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
