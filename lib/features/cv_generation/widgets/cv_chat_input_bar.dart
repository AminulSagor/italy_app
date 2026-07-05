import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../core/themes/app_colors.dart';
import '../models/cv_assistant_models.dart';

class CvChatInputBar extends StatelessWidget {
  const CvChatInputBar({
    required this.controller,
    required this.currentQuestion,
    required this.isSending,
    required this.isUploading,
    required this.onAttach,
    required this.onSend,
    super.key,
  });

  final TextEditingController controller;
  final CvAssistantQuestionModel? currentQuestion;

  final bool isSending;
  final bool isUploading;

  final VoidCallback onAttach;
  final VoidCallback onSend;

  bool get _isMultiline {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    return type == 'long_text' || type == 'list';
  }

  TextInputType get _keyboardType {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    switch (type) {
      case 'email':
        return TextInputType.emailAddress;

      case 'phone':
        return TextInputType.phone;

      case 'url':
        return TextInputType.url;

      case 'long_text':
      case 'list':
        return TextInputType.multiline;

      case 'choice':
      case 'text':
      default:
        return TextInputType.text;
    }
  }

  TextInputAction get _inputAction {
    return _isMultiline
        ? TextInputAction.newline
        : TextInputAction.send;
  }

  TextCapitalization get _capitalization {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    switch (type) {
      case 'email':
      case 'url':
        return TextCapitalization.none;

      default:
        return TextCapitalization.sentences;
    }
  }

  bool get _enableSuggestions {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    return type != 'email' && type != 'url';
  }

  bool get _autocorrect {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    return type != 'email' &&
        type != 'url' &&
        type != 'phone';
  }

  String get _hintText {
    final String type =
        currentQuestion?.type.trim().toLowerCase() ??
            'text';

    switch (type) {
      case 'email':
        return 'cv_chat_input_email_hint'.tr;

      case 'phone':
        return 'cv_chat_input_phone_hint'.tr;

      case 'url':
        return 'cv_chat_input_url_hint'.tr;

      case 'list':
        return 'cv_chat_input_list_hint'.tr;

      case 'choice':
        return 'cv_chat_input_choice_hint'.tr;

      case 'long_text':
        return 'cv_chat_input_long_text_hint'.tr;

      case 'text':
      default:
      return 'cv_chat_input_default_hint'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy =
        isSending || isUploading;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          14.w,
          8.h,
          14.w,
          10.h,
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 45.h,
                  maxHeight:
                  _isMultiline ? 104.h : 52.h,
                ),
                child: TextField(
                  controller: controller,
                  enabled: !isBusy,
                  keyboardType: _keyboardType,
                  textInputAction: _inputAction,
                  textCapitalization:
                  _capitalization,
                  autocorrect: _autocorrect,
                  enableSuggestions:
                  _enableSuggestions,
                  minLines: 1,
                  maxLines:
                  _isMultiline ? 4 : 1,
                  expands: false,
                  scrollPhysics:
                  const ClampingScrollPhysics(),
                  scrollPadding: EdgeInsets.only(
                    bottom:
                    MediaQuery.viewInsetsOf(
                      context,
                    ).bottom +
                        24.h,
                  ),
                  onSubmitted: (_) {
                    if (!isBusy &&
                        !_isMultiline) {
                      onSend();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _hintText,
                    filled: true,
                    fillColor:
                    AppColors.chatInputBg,
                    isDense: true,
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 17.w,
                      vertical: 12.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        24.r,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        24.r,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        24.r,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                    disabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        24.r,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: 9.w),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                isBusy ? null : onSend,
                borderRadius:
                BorderRadius.circular(24.r),
                child: AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  width: 45.w,
                  height: 45.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isBusy
                        ? AppColors.primaryGreen
                        .withValues(
                      alpha: 0.55,
                    )
                        : AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child:
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}