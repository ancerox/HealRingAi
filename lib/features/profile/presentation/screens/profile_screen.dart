import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_ring_ai/core/data/preferences.dart';
import 'package:health_ring_ai/core/themes/theme_data.dart';

class RandomAnimalAvatar extends StatelessWidget {
  final List<String> animals = [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🐙',
  ];

  RandomAnimalAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesRepository>();

    return FutureBuilder<int>(
      future: prefs.userEmojiIndex,
      builder: (context, snapshot) {
        final emojiIndex = snapshot.hasData ? snapshot.data! : 0;
        return CircleAvatar(
          radius: 65,
          backgroundColor: const Color(0xffBBF5EF),
          child: Center(
            child: Text(
              animals[emojiIndex % animals.length],
              style: const TextStyle(fontSize: 60),
            ),
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(5, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final prefs = context.read<PreferencesRepository>();
    await prefs.setUserName(controllers[0].text);
    await prefs.setUserSex(controllers[1].text);
    await prefs.setUserBirthDate(controllers[2].text);
    await prefs.setUserHeight(int.tryParse(controllers[3].text) ?? 0);
    await prefs.setUserWeight(controllers[4].text);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesRepository>();
    final List<Map<String, dynamic>> profileItems = [
      {
        'label': 'Name',
        'future': prefs.userName,
        'formatter': (value) => value.isNotEmpty ? value : 'No name set'
      },
      {
        'label': 'Sex',
        'future': prefs.userSex,
        'formatter': (value) => value.isNotEmpty ? value : 'Not specified'
      },
      {
        'label': 'Birth Date',
        'future': prefs.userBirthDate,
        'formatter': (value) => value.isNotEmpty ? value : 'Not set'
      },
      {
        'label': 'Height',
        'future': prefs.userHeight,
        'formatter': (value) => _formatHeight(value, context)
      },
      {
        'label': 'Weight',
        'future': prefs.userWeight,
        'formatter': (value) => _formatWeight(value, context)
      },
    ];

    return Scaffold(
      backgroundColor: CustomTheme.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Center(
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Health Details',
                            style: CustomTheme.headerLarge,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (isEditing) {
                            await _saveChanges();
                          }
                          setState(() {
                            isEditing = !isEditing;
                          });
                        },
                        child: Text(
                          isEditing ? 'Done' : 'Edit',
                          style: const TextStyle(
                            fontSize: 17,
                            color: CustomTheme.primaryDefault,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RandomAnimalAvatar(),
                  const SizedBox(height: 20),
                  Container(
                    height: 2,
                    color: const Color(0xffAEAEB2).withOpacity(0.5),
                  ),
                  FutureBuilder(
                    future: Future.wait([
                      prefs.userName,
                      prefs.userSex,
                      prefs.userBirthDate,
                      prefs.userHeight,
                      prefs.userWeight,
                      prefs.usesMetricSystem,
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }

                      // Initialize controllers with current values
                      for (var i = 0; i < controllers.length; i++) {
                        controllers[i].text = snapshot.data![i].toString();
                      }

                      return Column(
                        children: List.generate(
                          profileItems.length,
                          (index) => Column(
                            children: [
                              _buildProfileItem(
                                profileItems[index]['label'],
                                profileItems[index]
                                    ['formatter'](snapshot.data![index]),
                                isEditing,
                                controllers[index],
                              ),
                              if (index != profileItems.length - 1)
                                Container(
                                  height: 2,
                                  color:
                                      const Color(0xffAEAEB2).withOpacity(0.5),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, bool isEditing,
      TextEditingController controller) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: CustomTheme.textNormal),
            isEditing
                ? SizedBox(
                    width: 100,
                    child: TextField(
                      controller: controller,
                      style: CustomTheme.textSmall.copyWith(fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  )
                : Text(value,
                    style: CustomTheme.textSmall.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _formatHeight(int height, BuildContext context) {
    final prefs = context.read<PreferencesRepository>();
    final usesMetric = prefs.usesMetricSystem;

    if (usesMetric == 'true') {
      return '$height cm';
    } else {
      final feet = height ~/ 12;
      final inches = height % 12;
      return "$feet'$inches\"";
    }
  }

  String _formatWeight(String weight, BuildContext context) {
    final prefs = context.read<PreferencesRepository>();
    final usesMetric = prefs.usesMetricSystem;

    return weight.isNotEmpty
        ? '$weight ${usesMetric == 'true' ? 'kg' : 'lbs'}'
        : 'Not set';
  }
}
