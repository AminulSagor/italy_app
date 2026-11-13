/// App-side advertising switch.
///
/// The full advertising implementation remains in source control and the
/// backend configuration is left untouched. Re-enable this only in a build
/// that is intended to request and display mobile ads.
abstract final class MobileAdvertisingPolicy {
  static const bool enabled = false;
}
