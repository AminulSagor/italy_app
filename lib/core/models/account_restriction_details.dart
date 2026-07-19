class AccountRestrictionDetails {
  const AccountRestrictionDetails({
    required this.reason,
    this.effectiveAt,
    this.caseNumber,
  });

  static const String accountBannedCode = 'ACCOUNT_BANNED';

  static const AccountRestrictionDetails fallback = AccountRestrictionDetails(
    reason: 'This account has been permanently restricted by the administration.',
  );

  final String reason;
  final DateTime? effectiveAt;
  final String? caseNumber;

  static AccountRestrictionDetails? tryFromResponseData(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final Map<String, dynamic> response = Map<String, dynamic>.from(data);
    final String code = response['code']?.toString().trim() ?? '';

    if (code != accountBannedCode) {
      return null;
    }

    final dynamic rawDetails = response['details'];
    final Map<String, dynamic> details = rawDetails is Map
        ? Map<String, dynamic>.from(rawDetails)
        : <String, dynamic>{};

    final String responseMessage =
        response['message']?.toString().trim() ?? '';
    final String reason = details['reason']?.toString().trim() ?? '';
    final String effectiveAtValue =
        details['effectiveAt']?.toString().trim() ?? '';
    final String caseNumberValue =
        details['caseNumber']?.toString().trim() ?? '';

    return AccountRestrictionDetails(
      reason: reason.isNotEmpty
          ? reason
          : responseMessage.isNotEmpty
          ? responseMessage
          : fallback.reason,
      effectiveAt: effectiveAtValue.isEmpty
          ? null
          : DateTime.tryParse(effectiveAtValue),
      caseNumber: caseNumberValue.isEmpty ? null : caseNumberValue,
    );
  }
}
