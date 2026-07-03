import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/simple_appbar.dart';
import '../controllers/cv_chat_controller.dart';
import '../models/cv_assistant_models.dart';
import '../widgets/cv_attachment_preview.dart';
import '../widgets/cv_attachment_sheet.dart';
import '../widgets/cv_chat_action_bar.dart';
import '../widgets/cv_chat_input_bar.dart';
import '../widgets/cv_chat_message_bubble.dart';
import '../widgets/cv_selected_template_banner.dart';

class CvChatView extends GetView<CvChatController> {
  const CvChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: SimpleAppbar(
        title: 'CV Assistant',
        onBackTap: Get.back,
      ),
      body: SafeArea(
        top: false,
        child: Obx(
              () => Column(
            children: <Widget>[
              if (controller.selectedTemplate != null)
                CvSelectedTemplateBanner(
                  template: controller.selectedTemplate!,
                ),

              _ConversationModeSelector(
                selectedMode:
                controller.session.value.conversationMode,
                isLoading:
                controller.isSwitchingMode.value,
                onSelected:
                controller.switchConversationMode,
              ),

              _ProgressIndicator(
                progress:
                controller.session.value.progress,
              ),

              Expanded(
                child: controller.messages.isEmpty
                    ? const _EmptyConversation()
                    : ListView.builder(
                  controller:
                  controller.scrollController,
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior
                      .onDrag,
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    16.h,
                    16.w,
                    14.h,
                  ),
                  itemCount:
                  controller.messages.length,
                  itemBuilder: (
                      BuildContext context,
                      int index,
                      ) {
                    return CvChatMessageBubble(
                      message:
                      controller.messages[index],
                    );
                  },
                ),
              ),

              CvAttachmentPreview(
                profilePhoto:
                controller.localProfilePhoto.value,
                hasUploadedProfilePhoto:
                controller.hasProfilePhoto,
                referenceImages:
                controller.localReferenceImages,
                referenceImageCount:
                controller.referenceImageCount,
              ),

              CvChatActionBar(
                isSkipping:
                controller.isSkipping.value,
                isGenerating:
                controller.isGenerating.value,
                onSkip:
                controller.skipCurrentQuestion,
                onGenerate:
                controller.generateNow,
              ),

              CvChatInputBar(
                controller:
                controller.messageController,
                isSending:
                controller.isSending.value,
                isUploading:
                controller.isUploading.value,
                onAttach: () {
                  _showAttachmentSheet(context);
                },
                onSend:
                controller.sendMessage,
              ),
            ],
          ),
        ),
      ),
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
              label: 'One by One',
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
              label: 'All at Once',
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
                color: Colors.black.withValues(
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

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.progress,
  });

  final int progress;

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
      child: Row(
        children: <Widget>[
          Expanded(
            child: LinearProgressIndicator(
              value: safeProgress / 100,
              minHeight: 7.h,
              borderRadius:
              BorderRadius.circular(10.r),
              backgroundColor:
              const Color(0xFFE1E4E0),
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '$safeProgress%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color:
              AppColors.homeSecondaryText,
            ),
          ),
        ],
      ),
    );
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
              'Starting CV Assistant',
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
              'The assistant will ask for the information needed to create your CV.',
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