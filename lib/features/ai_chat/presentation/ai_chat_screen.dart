import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/widgets/gradiant_boder_box.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'bloc/ai_chat_bloc.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isKeyboardVisible = false;
  late stt.SpeechToText _speech;

  late final TextEditingController _textEditingController;
  late AnimationController _typewriterController;
  late Timer _typewriterTimer;
  String _displayName = '';
  String _displaygreding = '';
  int _currentIndex = 0;
  final List<String> _messages = [];
  bool isTexting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _speech = stt.SpeechToText();
    _textEditingController = TextEditingController();

    _startTypewriterAnimation();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    _typewriterTimer.cancel();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final view = View.of(context);
    final viewInsets = view.viewInsets;
    final viewPadding = view.padding;

    final keyboardVisible = (viewInsets.bottom - viewPadding.bottom) > 0.1;

    if (_isKeyboardVisible != keyboardVisible) {
      setState(() {
        _isKeyboardVisible = keyboardVisible;
      });
    }
  }

  void _toggleListening() {
    final currentState = context.read<AiChatBloc>().state;
    context.read<AiChatBloc>().add(ListenSpeach(
          currentState is AiChatListeningStarted,
        ));
  }

  void _startTypewriterAnimation() async {
    final prefs = context.read<PreferencesRepository>();

    final name = await prefs.userName;

    final text = "Hello ${name[0].toUpperCase()}${name.substring(1)}";
    const greeting = "how can I help with your\nhealth today?";
    const duration = Duration(milliseconds: 90);

    _typewriterTimer = Timer.periodic(duration, (timer) {
      if (_currentIndex < text.length) {
        setState(() {
          _displayName = text.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else if (_currentIndex < text.length + greeting.length) {
        setState(() {
          _displaygreding =
              greeting.substring(0, _currentIndex - text.length + 1);
          _currentIndex++;
        });
      } else {
        _typewriterTimer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiChatBloc, AiChatState>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        if (state is AiChatListeningStarted) {
          context.pushNamed("AiChatSpeechScreen");
        }

        if (state is AiMessageRecieved) {
          // Check if the message is new before adding
          final newMessage = "AI_RESPONSE: ${state.message}";
          setState(() {
            _messages.add(newMessage);
          });
          // if (_messages.isEmpty || _messages.last != newMessage) {}
        }
      },
      child: Scaffold(
        backgroundColor: CustomTheme.black,
        body: SafeArea(
          child: Stack(
            children: [
              if (_messages.isEmpty)
                const Positioned(
                  top: -100, // Move image higher by using negative top value
                  child: Image(
                    image: AssetImage('assets/png/ai_waves.png'),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Header
                  _messages.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24)
                              .copyWith(top: 20),
                          child: Text(
                            _displayName,
                            style:
                                CustomTheme.headerLarge.copyWith(fontSize: 24),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 10),
                  _messages.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _displaygreding,
                            style: CustomTheme.textNormal.copyWith(
                                color: CustomTheme.textColorSecondary),
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: BlocBuilder<AiChatBloc, AiChatState>(
                      builder: (context, state) {
                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 8),
                          itemCount: _messages.length +
                              (state is AiMessageLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (state is AiMessageLoading && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: ChatBubble(
                                  key: ValueKey('ai_loading'),
                                  message: "AI_RESPONSE: ...",
                                  shouldAnimate: false,
                                ),
                              );
                            }

                            final adjustedIndex =
                                state is AiMessageLoading ? index - 1 : index;
                            final message =
                                _messages.reversed.toList()[adjustedIndex];
                            final isLatestAIMessage = adjustedIndex == 0 &&
                                message.startsWith("AI_RESPONSE: ");

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: ChatBubble(
                                key: ValueKey(message),
                                message: message,
                                shouldAnimate: isLatestAIMessage,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: _isKeyboardVisible && _messages.isEmpty,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          "How's my blood oxygen level?",
                          "Compare my health today vs. last week",
                          "How was my sleep last night?",
                          "Is my heart rate normal?"
                        ].map((title) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _easyQuestion(
                              title: title,
                              onTap: () => _sendMessage(message: title),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !_isKeyboardVisible && _messages.isEmpty,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        "How's my blood oxygen level?",
                        "Compare my health today vs. last week",
                        "How was my sleep last night?",
                        "Is my heart rate normal?"
                      ]
                          .map((title) => _easyQuestion(
                                title: title,
                                onTap: () => _sendMessage(message: title),
                              ))
                          .toList(),
                    ),
                  ),

                  ///
                  /// The gradient border box (text field)
                  ///
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GradientBorderBox(
                      height: _isKeyboardVisible ? 85 : null,
                      paddingValue: 3,
                      child: Center(
                        child: AnimatedPadding(
                          padding: EdgeInsets.only(
                              bottom: _isKeyboardVisible ? 20 : 0),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Row(
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(left: 15),
                                  width: MediaQuery.of(context).size.width *
                                      0.7, // Fixed width
                                  child: TextFormField(
                                    onChanged: (String value) {
                                      setState(() {
                                        isTexting = value.isNotEmpty;
                                      });
                                    },
                                    style: CustomTheme.textNormal,
                                    controller: _textEditingController,
                                    decoration: InputDecoration(
                                      hintText: "Ask me anything",
                                      hintStyle: CustomTheme.textNormal
                                          .copyWith(
                                              color: _isKeyboardVisible
                                                  ? const Color(0xff999999)
                                                  : null),
                                      border: InputBorder.none,
                                    ),
                                    cursorColor: CustomTheme.primaryDefault,
                                  )),
                              const Spacer(),
                              GestureDetector(
                                onTap: isTexting
                                    ? () {
                                        _sendMessage(
                                            message:
                                                _textEditingController.text);
                                      }
                                    : () {
// _toggleListening
                                      },
                                child: GradientBorderBox(
                                  paddingValue: 1,
                                  height: 37,
                                  width: 37,
                                  gradientOpacity: 1.0,
                                  BordergradientColors: const [
                                    Color(0xffFFFFFF),
                                    Color(0xff999999)
                                  ],
                                  gradientColors: const [
                                    CustomTheme.primaryDefault,
                                    Color(0xFFBEEEE6),
                                  ],
                                  child: Center(
                                    child: isTexting
                                        ? const Icon(Icons.send)
                                        : SvgPicture.asset(
                                            'assets/svg/microphone.svg',
                                            height: 24,
                                            width: 24,
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage({required message}) {
    // final message = _textEditingController.text;
    setState(() {
      _messages.add(message);
    });

    // Add bloc event dispatch
    context.read<AiChatBloc>().add(SendMessageToAI(message: message));
    isTexting = false;
    _textEditingController.clear();
  }

  ///
  /// The same gradient border box as before
  ///
}

///
/// A single metric card
///
Widget _easyQuestion({
  required String title,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: () {
      onTap?.call();
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur effect
        child: Container(
          width: 169,
          height: 145,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.03),
                Colors.white.withOpacity(0.10),
              ],
              stops: const [0, 100],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: CustomPaint(
            painter: GradientPainter(padding: -10, widthPadding: -16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Example icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CustomTheme.primaryDefault,
                        Color(0xFFBEEEE6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/star.svg',
                      height: 20,
                    ),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: CustomTheme.textSmall
                      .copyWith(color: CustomTheme.textColorSecondary),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

///
/// Custom painter for the border gradient
///
class GradientPainter extends CustomPainter {
  final double padding; // Padding for the height
  final double widthPadding; // New parameter for padding the width

  GradientPainter({
    this.padding = 0,
    this.widthPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Reduce width and height by the respective padding values
    final double paddedWidth = size.width - widthPadding * 2;
    final double paddedHeight = size.height - padding * 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.025) // Black with 2.5% opacity
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // Blur radius

    final startShadow = Offset(widthPadding, padding);
    final endShadow =
        Offset(paddedWidth + widthPadding, paddedHeight + padding);
    final rectShadow = Rect.fromPoints(startShadow, endShadow);
    final rRectShadow = RRect.fromRectAndRadius(
      rectShadow.shift(const Offset(0, 4)), // Offset Y by 4 => shadow effect
      const Radius.circular(20),
    );

    // Draw the shadow
    canvas.drawRRect(rRectShadow, shadowPaint);

    // Create the gradient for the stroke
    final gradient = LinearGradient(
      colors: [
        Colors.white,
        const Color(0xff111919).withOpacity(0.7),
        const Color(0xff111919),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final start = Offset(widthPadding, padding);
    final end = Offset(paddedWidth + widthPadding, paddedHeight + padding);
    final rect = Rect.fromPoints(start, end);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(20));

    final paint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);

    // Draw the gradient stroke
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatBubble extends StatefulWidget {
  final String message;
  final bool shouldAnimate;

  const ChatBubble({
    super.key,
    required this.message,
    this.shouldAnimate = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with AutomaticKeepAliveClientMixin {
  Timer? _typewriterTimer;
  int _currentIndex = 0;
  String _displayText = '';
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    final bool isAiMessage = widget.message.startsWith("AI_RESPONSE: ");
    if (isAiMessage && widget.shouldAnimate) {
      _startTypewriterAnimation();
    } else {
      _displayText = isAiMessage
          ? widget.message.replaceFirst("AI_RESPONSE: ", "")
          : widget.message;
      _animationCompleted = true;
    }
  }

  @override
  void didUpdateWidget(covariant ChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _currentIndex = 0;
      _displayText = '';
      _animationCompleted = false;
      final bool isAiMessage = widget.message.startsWith("AI_RESPONSE: ");
      if (isAiMessage && widget.shouldAnimate) {
        _startTypewriterAnimation();
      } else {
        _displayText = isAiMessage
            ? widget.message.replaceFirst("AI_RESPONSE: ", "")
            : widget.message;
        _animationCompleted = true;
      }
    }
  }

  void _startTypewriterAnimation() {
    final fullMessage = widget.message.replaceFirst("AI_RESPONSE: ", "");
    const duration = Duration(milliseconds: 30);

    _typewriterTimer = Timer.periodic(duration, (timer) {
      if (_currentIndex < fullMessage.length) {
        setState(() {
          _displayText = fullMessage.substring(0, _currentIndex + 1);
          _currentIndex++;
        });
      } else {
        _typewriterTimer?.cancel();
        _animationCompleted = true;
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure state is preserved when offscreen.
    super.build(context);

    final bool isMe = !widget.message.startsWith("AI_RESPONSE: ");
    final String message = isMe ? widget.message : _displayText;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMe
              ? MediaQuery.of(context).size.width * 0.7
              : MediaQuery.of(context).size.width,
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        decoration: isMe
            ? BoxDecoration(
                color: CustomTheme.primaryDefault.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                ),
                border: Border.all(
                  color: CustomTheme.primaryDefault.withOpacity(0.3),
                ),
              )
            : null,
        child: Text(
          message,
          textAlign: isMe ? null : TextAlign.left,
          style: CustomTheme.textNormal.copyWith(
            color: isMe ? CustomTheme.primaryDefault : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
