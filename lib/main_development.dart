import 'package:app_yummy_log_clinicians/core/observability/launch_clinician_app.dart';
import 'package:feature_contract/app_build_flavor.dart';

Future<void> main() async {
  await launchClinicianApp(AppBuildFlavor.development);
}
