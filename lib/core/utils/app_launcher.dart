import 'package:url_launcher/url_launcher.dart';

abstract final class AppLauncher {
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  }

  static Future<void> call(String phoneUri) async {
    final uri = Uri.parse(phoneUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
