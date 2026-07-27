import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/native_bottom_inset.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../controllers/cv_chat_controller.dart';
import '../models/cv_assistant_models.dart';
import '../widgets/cv_attachment_sheet.dart';
import '../widgets/cv_chat_action_bar.dart';
import '../widgets/cv_chat_input_bar.dart';
import '../widgets/cv_chat_message_bubble.dart';
import '../widgets/cv_photo_decision_card.dart';
import '../widgets/cv_selected_template_banner.dart';

import '../widgets/cv_thinking_bubble.dart';
import '../widgets/cv_validation_panel.dart';

class CvChatView extends GetView<CvChatController> {
  const CvChatView({
    required this.controllerTag,
    super.key,
  });

  final String controllerTag;

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'cv_chat_assistant_title'.tr,
        onBackTap: Get.back,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Obx(
              () {
                final CvAssistantSessionModel session =
                    controller.session.value;

                final bool hasBottomCards =
                    controller.hasPendingSuggestion ||
                        controller.hasUnresolvedPhotoDecision ||
                        controller.isValidationPanelVisible.value;

                return Column(
              children: <Widget>[
                if (controller.selectedTemplate != null)
                  CvSelectedTemplateBanner(
                    template:
                    controller.selectedTemplate!,
                  ),

                if (session.isEditSession)
                  _EditModeBanner(
                    editMode: session.editMode!,
                  )
                else
                  _ConversationModeSelector(
                    selectedMode:
                    session.conversationMode,
                    isLoading:
                    controller.isSwitchingMode.value,
                    onSelected:
                    controller.switchConversationMode,
                  ),

                _BackendProgressIndicator(
                  progress: session.progress,
                  status: session.status,
                ),

                Expanded(
                  child: _buildConversation(),
                ),

// Hide the large cards while the keyboard is open.
// This prevents the main Column from overflowing.
                if (hasBottomCards)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                        MediaQuery.sizeOf(context).height * 0.38,
                      ),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[


                            if (controller.hasUnresolvedPhotoDecision)
                              CvPhotoDecisionCard(
                                isBusy:
                                controller.isSending.value ||
                                    controller.isUploading.value,
                                onUploadPhoto:
                                controller.pickProfilePhoto,
                                onContinueWithoutPhoto:
                                controller.continueWithoutPhoto,
                              ),

                            if (controller
                                .isValidationPanelVisible.value)
                              CvValidationPanel(
                                generationBlockers:
                                session.generationBlockers,
                                missingRequiredFields:
                                session.missingRequiredFields,
                                missingTemplateSections:
                                session.missingTemplateSections,
                                unresolvedOptionalSections:
                                session.unresolvedOptionalSections,
                                pendingSuggestionCount:
                                session.pendingSuggestions.length,
                                photoDecision:
                                session.photoDecision,
                                qualityIssues:
                                session.qualityIssues,
                                onClose:
                                controller.hideGenerationBlockers,
                              ),


                          ],
                        ),
                      ),
                    ),

                CvChatActionBar(
                  isGenerating:
                  controller.isGenerating.value,
                  isBusy:
                  controller.isBusy,
                  status:
                  session.status,
                  backendCanGenerate:
                  session.canGenerate,
                  validationComplete:
                  session.validationComplete,
                  qualityCheckPassed:
                  session.qualityCheckPassed,
                  hasCurrentQuestion:
                  session.currentQuestion != null,
                  hasGenerationBlockers:
                  session.generationBlockers.isNotEmpty,
                  onGenerate:
                  controller.generateNow,
                ),

                NativeBottomInset(
                  child: CvChatInputBar(
                    controller: controller.messageController,
                    currentQuestion: controller.currentQuestion,
                    isSending: controller.isSending.value,
                    isUploading: controller.isUploading.value,
                    onAttach: () {
                      _showAttachmentSheet(context);
                    },
                    onSend: controller.sendMessage,
                  ),
                ),


              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversation() {
    final List<CvAssistantMessageModel> messages =
        controller.messages;

    final bool showThinking =
        controller.isAssistantThinking.value;

    if (messages.isEmpty && !showThinking) {
      return const _EmptyConversation();
    }

    return ListView.builder(
      controller: controller.scrollController,
      keyboardDismissBehavior:
      ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        14.h,
      ),
      itemCount:
      messages.length + (showThinking ? 1 : 0),
      itemBuilder: (
          BuildContext context,
          int index,
          ) {
        if (showThinking &&
            index == messages.length) {
          return  CvThinkingBubble(
            message:
            'cv_chat_reviewing_information'.tr,
          );
        }

        final CvAssistantMessageModel message =
        messages[index];

        return CvChatMessageBubble(
          message: message,
          onRetry: controller.isMessageFailed(message)
              ? () {
            controller.retryFailedMessage(
              message.id,
            );
          }
              : null,
        );
      },
    );
  }

  void _showAttachmentSheet(
      BuildContext context,
      ) {
    if (controller.isBusy) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      builder: (BuildContext context) {
        return CvAttachmentSheet(
          onProfilePhoto:
          controller.pickProfilePhoto,
          onReferenceImages:
          controller.pickReferenceImages,
        );
      },
    );
  }
}

class _EditModeBanner extends StatelessWidget {
  const _EditModeBanner({
    required this.editMode,
  });

  final CvAssistantEditMode editMode;

  @override
  Widget build(BuildContext context) {
    final bool factsOnly =
        editMode == CvAssistantEditMode.factsOnly;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        4.h,
      ),
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(
            alpha: 0.25,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(12.r),
            ),
            child: Icon(
              factsOnly
                  ? Icons.edit_note_rounded
                  : Icons.auto_fix_high_rounded,
              size: 21.w,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  editMode.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color:
                    AppColors.homePrimaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  factsOnly
                      ? 'cv_chat_edit_facts_description'.tr
                      : 'cv_chat_edit_design_description'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    color:
                    AppColors.homeSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationModeSelector
    extends StatelessWidget {
  const _ConversationModeSelector({
    required this.selectedMode,
    required this.isLoading,
    required this.onSelected,
  });

  final CvAssistantConversationMode selectedMode;
  final bool isLoading;

  final ValueChanged<CvAssistantConversationMode>
  onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        4.h,
      ),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE7EAE6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ModeButton(
              label: 'cv_chat_mode_one_by_one'.tr,
              icon:
              Icons.format_list_numbered_rounded,
              selected:
              selectedMode ==
                  CvAssistantConversationMode
                      .oneByOne,
              isLoading:
              isLoading &&
                  selectedMode ==
                      CvAssistantConversationMode
                          .oneByOne,
              isDisabled: isLoading,
              onTap: () {
                onSelected(
                  CvAssistantConversationMode
                      .oneByOne,
                );
              },
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: _ModeButton(
              label: 'cv_chat_mode_all_at_once'.tr,
              icon: Icons.list_alt_rounded,
              selected:
              selectedMode ==
                  CvAssistantConversationMode
                      .allAtOnce,
              isLoading:
              isLoading &&
                  selectedMode ==
                      CvAssistantConversationMode
                          .allAtOnce,
              isDisabled: isLoading,
              onTap: () {
                onSelected(
                  CvAssistantConversationMode
                      .allAtOnce,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? Colors.white
          : Colors.transparent,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 180),
          height: 44.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
          ),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(13.r),
            boxShadow: selected
                ? <BoxShadow>[
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: isLoading
              ? SizedBox(
            width: 18.w,
            height: 18.w,
            child:
            const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 18.w,
                color: selected
                    ? AppColors.primaryGreen
                    : AppColors
                    .homeSecondaryText,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: selected
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: selected
                        ? AppColors.primaryGreen
                        : AppColors
                        .homeSecondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendProgressIndicator
    extends StatelessWidget {
  const _BackendProgressIndicator({
    required this.progress,
    required this.status,
  });

  final int progress;
  final CvAssistantSessionStatus status;

  @override
  Widget build(BuildContext context) {
    final int safeProgress =
    progress.clamp(0, 100);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        7.h,
        16.w,
        9.h,
      ),
      color: AppColors.homeBackground,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                _statusLabel(status),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
              const Spacer(),
              Text(
                '$safeProgress%',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color:
                  AppColors.homeSecondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          LinearProgressIndicator(
            value: safeProgress / 100,
            minHeight: 7.h,
            borderRadius:
            BorderRadius.circular(10.r),
            backgroundColor:
            const Color(0xFFE1E4E0),
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  String _statusLabel(
      CvAssistantSessionStatus status,
      ) {
    switch (status) {
      case CvAssistantSessionStatus.active:
        return 'cv_chat_status_collecting'.tr;

      case CvAssistantSessionStatus.readyToGenerate:
        return 'cv_chat_status_ready'.tr;

      case CvAssistantSessionStatus.generating:
        return 'cv_chat_status_generating'.tr;

      case CvAssistantSessionStatus.completed:
        return 'cv_chat_status_completed'.tr;

      case CvAssistantSessionStatus.cancelled:
        return 'cv_chat_status_cancelled'.tr;
    }
  }
}




class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64.w,
              height: 64.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7E4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 30.w,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'cv_chat_starting_assistant'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color:
                AppColors.homePrimaryText,
              ),
            ),
            SizedBox(height: 7.h),
            Text(
              'cv_chat_starting_description'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.45,
                color:
                AppColors.homeSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}