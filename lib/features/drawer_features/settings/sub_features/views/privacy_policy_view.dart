import 'package:flutter/material.dart';

import '../../models/privacy_policy_content.dart';
import '../../widgets/legal_document_view.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      document: PrivacyPolicyContent.document,
      icon: Icons.policy_outlined,
    );
  }
}
