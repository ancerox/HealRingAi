import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';
import 'package:health_ring_ai/features/onboarding/presentation/screens/connect_ring_page.dart';
import 'package:health_ring_ai/features/onboarding/presentation/widgets/form_container_widget.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen>
    with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  bool isCentimeters = false;
  int selectedHeight = 60; // Default height in inches
  String? selectedSex; // Add this line to track selected sex
  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 12);
  int? lastPrintedIndex;

  final List<String> questions = [
    'What is your name?',
    'What is your sex?',
    'When were you born?',
    'What is your height?',
    'What is your weight?',
  ];

  late List<AnimationController> _progressAnimationControllers;
  late List<Animation<double>> _progressAnimations;

  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _formatHeight(int value) {
    if (isCentimeters) {
      return '$value cm';
    } else {
      int feet = value ~/ 12;
      int inches = value % 12;
      return '$feet\'$inches"';
    }
  }

  List<int> _getHeightRange() {
    if (isCentimeters) {
      return List.generate(121, (index) => index + 120); // 120-240 cm
    } else {
      return List.generate(49, (index) => index + 48); // 4'0" - 8'0"
    }
  }

  void nextQuestion() async {
    FocusScope.of(context).unfocus();

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        HapticFeedback.lightImpact();
      });
      _progressAnimationControllers[currentQuestionIndex].forward();
    }

    if (currentQuestionIndex == 4 && _weightController.text.isNotEmpty) {
      final prefs = context.read<PreferencesRepository>();

      // Save all user data to preferences
      await prefs.setFirstLaunch(false);
      await prefs.setUserConnected(true);

      // Save individual values
      await prefs.setUserName(_nameController.text);
      await prefs.setUserSex(selectedSex ?? '');
      await prefs.setUserBirthDate(
          '${_dayController.text}/${_monthController.text}/${_yearController.text}');
      await prefs.setUserHeight(selectedHeight);
      await prefs.setUserWeight(_weightController.text);
      await prefs.setUsesMetricSystem(isCentimeters);

      // Set random emoji index between 1 and 40
      final random = Random();
      await prefs.setUserEmojiIndex(random.nextInt(16) + 1);

      context.pushReplacement('/checking_vitals');
    }
  }

  Widget _buildQuestionWidget(int index) {
    switch (index) {
      case 0:
        return TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          cursorColor: CustomTheme.primaryDefault,
          style: const TextStyle(color: Colors.white),
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Name',
            labelStyle:
                const TextStyle(color: Color.fromARGB(255, 110, 110, 110)),
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 62, 62, 62),
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 126, 126, 126),
                width: 2,
              ),
            ),
          ),
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FormContainer(
              text: 'Female',
              isSelected: selectedSex == 'Female',
              onTap: () {
                setState(() {
                  selectedSex = 'Female';
                });
              },
            ),
            const SizedBox(height: 20),
            FormContainer(
              text: 'Male',
              isSelected: selectedSex == 'Male',
              onTap: () {
                setState(() {
                  selectedSex = 'Male';
                });
              },
            ),
          ],
        );
      case 2:
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _dayController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: CustomTheme.primaryDefault,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Day',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: CustomTheme.formBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xffAEAEB2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: CustomTheme.primaryDefault,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Month',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: CustomTheme.formBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xffAEAEB2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                cursorColor: CustomTheme.primaryDefault,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Year',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: CustomTheme.formBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xffAEAEB2),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          isCentimeters = false;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Feet and inches',
                            style: TextStyle(
                              color:
                                  !isCentimeters ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: !isCentimeters
                                ? CustomTheme.primaryDefault
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          isCentimeters = true;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Centimeters',
                            style: TextStyle(
                              color: isCentimeters ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: isCentimeters
                                ? CustomTheme.primaryDefault
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Center(
              child: SizedBox(
                height: 300,
                width: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 62, 62, 62),
                          width: 2, // Increased border width from 1 to 2
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedHeight = _getHeightRange()[index];
                          HapticFeedback.lightImpact();
                        });
                      },
                      controller: _scrollController,
                      itemExtent: 40,
                      perspective: 0.005,
                      diameterRatio: 1.2,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _getHeightRange().length,
                        builder: (context, index) {
                          final isSelected =
                              index == _scrollController.selectedItem;
                          return Center(
                            child: Text(
                              _formatHeight(_getHeightRange()[index]),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                fontSize: isSelected ? 24 : 20,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          isCentimeters = false;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kg',
                            style: TextStyle(
                              color:
                                  !isCentimeters ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: !isCentimeters
                                ? CustomTheme.primaryDefault
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          isCentimeters = true;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lb',
                            style: TextStyle(
                              color: isCentimeters ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            color: isCentimeters
                                ? CustomTheme.primaryDefault
                                : Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              cursorColor: CustomTheme.primaryDefault,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle:
                    const TextStyle(color: Color.fromARGB(255, 110, 110, 110)),
                filled: true,
                fillColor: Colors.transparent,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 62, 62, 62),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 126, 126, 126),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    _progressAnimationControllers = List.generate(
      questions.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _progressAnimations = _progressAnimationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the first progress bar
    _progressAnimationControllers[0].forward();

    // Mark user as connected when they reach this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PreferencesRepository>().setUserConnected(true);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _weightController.dispose();
    for (var controller in _progressAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.black,
      body: Stack(
        children: [
          const GradientBackground(),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image(
                          image:
                              AssetImage('assets/images/onboarding_image.jpg'),
                          width: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment(0, 0.35),
                        ),
                      ),

                      // Progress bar
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        height: 4,
                        child: Row(
                          children: List.generate(
                            questions.length,
                            (index) => Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                    right:
                                        index < questions.length - 1 ? 8 : 2),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: AnimatedBuilder(
                                    animation: _progressAnimations[index],
                                    builder: (context, child) {
                                      return LinearProgressIndicator(
                                        value: index < currentQuestionIndex
                                            ? 1.0
                                            : index == currentQuestionIndex
                                                ? _progressAnimations[index]
                                                    .value
                                                : 0.0,
                                        backgroundColor: Colors.grey[800],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                CustomTheme.successColor),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Question
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          questions[currentQuestionIndex],
                          style: CustomTheme.headerNormal,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Question-specific widget
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: currentQuestionIndex == 3 ? 0 : 20),
                        child: _buildQuestionWidget(currentQuestionIndex),
                      ),

                      // Add padding at bottom to ensure content is not hidden behind button
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Next button at bottom
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: (currentQuestionIndex == 0 &&
                              _nameController.text.isEmpty) ||
                          (currentQuestionIndex == 1 && selectedSex == null) ||
                          (currentQuestionIndex == 2 &&
                              (_dayController.text.isEmpty ||
                                  _monthController.text.isEmpty ||
                                  _yearController.text.isEmpty)) ||
                          (currentQuestionIndex == 3 &&
                              selectedHeight == null) ||
                          (currentQuestionIndex == 4 &&
                              _weightController.text.isEmpty)
                      ? null
                      : nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryDefault,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    disabledBackgroundColor:
                        CustomTheme.primaryDefault.withOpacity(0.5),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
