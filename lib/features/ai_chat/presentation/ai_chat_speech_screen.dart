import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/bloc/ai_chat_bloc.dart';
import 'package:health_ring_ai/features/ai_chat/presentation/widgets/gradiant_boder_box.dart';

class AiChatSpeechScreen extends StatefulWidget {
  const AiChatSpeechScreen({super.key});

  @override
  State<AiChatSpeechScreen> createState() => _AiChatSpeechScreenState();
}

class _AiChatSpeechScreenState extends State<AiChatSpeechScreen> {
  Timer? _textChangeTimer;
  String _lastText = '';
  bool _isTextChanging = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    context.read<AiChatBloc>().add(const StopListeningSpeach());
    print("TESTWINSTON");
    super.deactivate();
  }

  @override
  void dispose() {
    _textChangeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTextChange(String currentText) {
    if (currentText != _lastText) {
      _isTextChanging = true;
      _lastText = currentText;
      _textChangeTimer?.cancel();
      _textChangeTimer = Timer(const Duration(milliseconds: 200), () {
        setState(() {
          _isTextChanging = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiChatBloc, AiChatState>(
      buildWhen: (previous, current) {
        return true;
      }, // Listen to all state changes
      builder: (context, state) {
        print('Current state: $state'); // Debug print

        if (state is AiChatTextUpdated || state is AiChatListeningStarted) {
          _handleTextChange(state.text);

          return Scaffold(
            // appBar: AppBar(
            //   backgroundColor: Colors.transparent,
            //   leading: const Icon(
            //     Icons.arrow_back_ios,
            //     color: Colors.white,
            //   ),
            // ),
            backgroundColor: CustomTheme.black,
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          context.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 300,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _isTextChanging
                              ? 210 +
                                  (state.text.length * 2)
                                      .clamp(50, 80)
                                      .toDouble()
                              : 210,
                          height: _isTextChanging
                              ? 210 +
                                  (state.text.length * 2)
                                      .clamp(50, 80)
                                      .toDouble()
                              : 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/ai_image.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 275,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: state.text.length > 20
                            ? ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  final double fadePosition =
                                      (state.text.length / 500).clamp(0.0, 0.3);
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.white,
                                    ],
                                    stops: [fadePosition, fadePosition + 0.6],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  state.text,
                                  style: CustomTheme.textSmallBold.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                state.text,
                                style: CustomTheme.textSmallBold.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    // Wrap the GradientBorderBox with the animated ripple.
                    const Spacer(),
                    Text(
                      'Listenin...',
                      style: CustomTheme.headerXLarge.copyWith(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    AnimatedWaterRipple(
                      // Use the same width/height as GradientBorderBox.
                      borderRadius: 15,
                      width: 80,
                      height: 66,
                      child: GradientBorderBox(
                        borderRadius: 24,
                        paddingValue: 1,
                        height: 66,
                        width: 80,
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
                          child: SvgPicture.asset(
                            'assets/svg/microphone_filled.svg',
                            height: 40,
                            width: 40,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          backgroundColor: CustomTheme.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      },
    );
  }
}

class AnimatedWaterRipple extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double width;
  final double height;

  const AnimatedWaterRipple({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 15.0,
  });

  @override
  State<AnimatedWaterRipple> createState() => _AnimatedWaterRippleState();
}

class _AnimatedWaterRippleState extends State<AnimatedWaterRipple>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _echoController;

  @override
  void initState() {
    super.initState();

    // Main ripple animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    // Secondary echo animation
    _echoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start echo animation after a short delay
    Future.delayed(const Duration(milliseconds: 900), () {
      _echoController.repeat();
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _echoController.dispose();
    super.dispose();
  }

  // Calculate fade effect for smooth transitions
  double _calculateFade(double progress) {
    return progress < 0.7 ? 1.0 : 1.0 - (progress - 0.7) / 0.3;
  }

  // Build ripple effect container
  Widget _buildRippleEffect(AnimationController controller, double widthScale,
      double heightScale, double scaleFactor) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final progress = controller.value;
        final fade = _calculateFade(progress);
        final scale = 0.9 + progress * scaleFactor;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.width * widthScale,
            height: widget.height * heightScale,
            decoration: BoxDecoration(
              color: CustomTheme.primaryDefault.withOpacity(0.1 * fade),
              border: Border.all(
                color: Colors.white.withOpacity(fade),
                width: 0.15,
              ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main ripple effect
          _buildRippleEffect(_rippleController, 0.9, 1.1, 1.0),
          // Secondary echo effect
          _buildRippleEffect(_echoController, 0.8, 1.0, 0.8),
          // Child widget
          widget.child,
        ],
      ),
    );
  }
}
