import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/native_bottom_inset.dart';
import '../controllers/ai_content_report_controller.dart';
import '../models/ai_content_report_model.dart';

Future<void> showAiContentReportBottomSheet({
  required BuildContext context,
  required AiContentReportSource source,
}) async {
  final AiContentReportController controller = AiContentReportController(
    source: source,
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return NativeBottomInset(
        additionalBottom: 20,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'ai_report_title'.tr,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('ai_report_description'.tr),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<AiReportIssue>(
                    value: controller.selectedIssue.value,
                    decoration: InputDecoration(
                      labelText: 'ai_report_issue_required'.tr,
                      border: const OutlineInputBorder(),
                    ),
                    items: AiReportIssue.values
                        .map(
                          (AiReportIssue issue) =>
                              DropdownMenuItem<AiReportIssue>(
                                value: issue,
                                child: Text(issue.translationKey.tr),
                              ),
                        )
                        .toList(),
                    onChanged: controller.isSubmitting.value
                        ? null
                        : (AiReportIssue? value) {
                            controller.selectedIssue.value = value;
                          },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: controller.detailsController,
                    enabled: !controller.isSubmitting.value,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: 'ai_report_details_optional'.tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.selectScreenshot,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(
                      controller.screenshot.value == null
                          ? 'ai_report_add_screenshot'.tr
                          : 'ai_report_change_screenshot'.tr,
                    ),
                  ),

                  if (controller.screenshot.value != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('ai_report_screenshot_selected'.tr),
                        ),
                        IconButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.removeScreenshot,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text('cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : () async {
                                  final bool submitted = await controller
                                      .submit();

                                  if (submitted && context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text('ai_report_submit'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  controller.dispose();
}
