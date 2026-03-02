import 'package:url_launcher/url_launcher.dart';

import '../snackbar/app_snackbar.dart';

/// Payment page URL - used for Buy Package, Choose Plan, etc.
const String paymentPageUrl = 'http://neetcounseling.efasttrade.in/services';

/// iOS App Store review–friendly text for purchase flows.
/// Display on locked/purchase pages so users know transactions happen outside the app.
const String iosPurchaseDisclaimer =
    'To access additional premium content, please complete your purchase through our official website.';

/// Opens the payment page in the device's external browser.
/// Use for all buy/subscribe buttons across the app.
Future<bool> launchPaymentPage() => openLinkInBrowser(paymentPageUrl);

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
