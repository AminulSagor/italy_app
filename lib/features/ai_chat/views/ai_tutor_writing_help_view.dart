import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/ai_chat_controller.dart';
import 'ai_tutor_chat_view.dart';
import 'widgets/ai_tutor_common_widgets.dart';

class AiTutorWritingHelpView extends StatefulWidget {
  const AiTutorWritingHelpView({super.key});

  @override
  State<AiTutorWritingHelpView> createState() =>
      _AiTutorWritingHelpViewState();
}

class _AiTutorWritingHelpViewState extends State<AiTutorWritingHelpView> {
  late final AiChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AiChatController>();
  }

  @override
  void dispose() {
    _controller.resetTextConversation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _controller.handleWritingHelpSystemBack,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F1),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  AiTutorHeader(
                    title: 'gen_italian_writing_help'.tr,
                    onBackTap: _controller.closeWritingHelpPage,
                  ),
                  const Expanded(
                    child: AiTutorChatContent(showWritingHelpStatus: true),
                  ),
                ],
              ),
              Positioned(
                left: 24.w,
                right: 24.w,
                bottom: 22.h,
                child: Obx(() {
                  final bool sending = _controller.isSendingMessage.value;
                  return IgnorePointer(
                    ignoring: sending,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: sending ? .65 : 1,
                      child: AiTutorInputBar(
                        controller: _controller.inputController,
                        inputText: _controller.inputText.value,
                        onChanged: _controller.onInputChanged,
                        onSendTap: _controller.sendTextFromChat,
                        showVoiceAction: false,
                        hint: _controller.writingHelpInputHint,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
