import 'package:url_launcher/url_launcher.dart';

import '../snackbar/app_snackbar.dart';

/// Opens [url] in the device's external browser.
/// Returns true if launched, false otherwise. Shows snackbar on failure.
Future<bool> openLinkInBrowser(String? url) async {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return false;
  Uri? uri;
  try {
    uri = Uri.parse(trimmed);
    if (!uri.hasScheme) uri = Uri.parse('https://$trimmed');
  } catch (_) {
    AppSnackbar.warning('Invalid link', 'Could not open the link.');
    return false;
  }
  try {
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return true;
    }
  } catch (e) {
    AppSnackbar.error('Could not open link', e.toString());
    return false;
  }
  AppSnackbar.warning('Could not open link', 'Please try again.');
  return false;
}
