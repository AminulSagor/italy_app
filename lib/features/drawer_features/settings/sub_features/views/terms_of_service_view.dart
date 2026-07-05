import 'package:flutter/material.dart';

import '../../models/terms_of_service_content.dart';
import '../../widgets/legal_document_view.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentView(
      document: TermsOfServiceContent.document,
      icon: Icons.description_outlined,
    );
  }
}
