import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../data/prayer_timings_data.dart';

class SunnahLessonsScreen extends StatefulWidget {
  const SunnahLessonsScreen({super.key});

  @override
  State<SunnahLessonsScreen> createState() => _SunnahLessonsScreenState();
}

class _SunnahLessonsScreenState extends State<SunnahLessonsScreen> {
  late final int _day;

  @override
  void initState() {
    super.initState();
    final today = PrayerTimingsData.getTodayRamadanDay();
    _day = today?.day ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final index = (_day - 1).clamp(0, _sunnahLessons.length - 1);
    final lesson = _sunnahLessons[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunnah Lessons'),
        backgroundColor: AppColors.primaryGreen,
      ),
      backgroundColor: AppColors.skyDark,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day $_day',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  lesson,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.4,
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

// Day-wise Sunnah lessons content (same as provided Ramadan tips text)
const List<String> _sunnahLessons = [
  'Day 1 – Intention (Niyyah)\n\nRenew intention before every act.\nExample: Before fasting, say in heart: “I fast for Allah.”',
  'Day 2 – Suhoor\n\nThe Prophet ﷺ delayed suhoor.\nPractice: Eat suhoor close to Fajr.',
  'Day 3 – Breaking Fast Quickly\n\nBreak fast immediately at Maghrib.\nPractice: One date and water first.',
  'Day 4 – Dua at Iftar\n\nDua at time of breaking fast is accepted.\nPractice: Make personal dua before eating fully.',
  'Day 5 – Gentle Speech\n\nHe ﷺ avoided arguments while fasting.\nPractice: If angry, say “I am fasting.”',
  'Day 6 – Qur’an Daily\n\nHe reviewed Qur’an every Ramadan with Jibreel.\nPractice: Fix daily portion.',
  'Day 7 – Charity\n\nHe ﷺ was most generous in Ramadan.\nPractice: Give something daily, even small.',
  'Day 8 – Smiling\n\nSmiling is charity.\nPractice: Smile at family despite hunger.',
  'Day 9 – Feeding Others\n\nReward equals fasting person’s reward.\nPractice: Provide iftar for one person.',
  'Day 10 – Night Prayer\n\nHe prayed long in Ramadan nights.\nPractice: Pray Taraweeh consistently.',
  'Day 11 – Miswak\n\nHe used miswak frequently.\nPractice: Use before salah.',
  'Day 12 – Gratitude After Eating\n\nHe praised Allah after meals.\nPractice: Say Alhamdulillah sincerely.',
  'Day 13 – Moderation in Food\n\nHe never overfilled stomach.\nPractice: Eat light at iftar.',
  'Day 14 – Visiting the Sick\n\nHe visited the ill.\nPractice: Call or visit a sick person.',
  'Day 15 – Family Kindness\n\nBest to family.\nPractice: Help at home before iftar.',
  'Day 16 – Dhikr in Free Time\n\nTongue moist with remembrance.\nPractice: 100 SubhanAllah daily.',
  'Day 17 – Forgiveness\n\nHe forgave even enemies.\nPractice: Forgive one person sincerely.',
  'Day 18 – Cleanliness\n\nHe loved cleanliness.\nPractice: Keep prayer area clean.',
  'Day 19 – Dua for Others\n\nHe made dua for companions.\nPractice: Make dua for 5 people by name.',
  'Day 20 – I‘tikaf\n\nHe performed i‘tikaf in last ten nights.\nPractice: Spend extra masjid time.',
  'Day 21 – Seeking Laylatul Qadr\n\nHe searched in odd nights.\nPractice: Increase worship on 21st night.',
  'Day 22 – Long Sujood\n\nHe made long sujood in prayer.\nPractice: Add personal dua in sujood.',
  'Day 23 – Salawat\n\nHe encouraged sending blessings on him.\nPractice: 100 salawat daily.',
  'Day 24 – Control the Gaze\n\nHe lowered his gaze.\nPractice: Avoid harmful media.',
  'Day 25 – Truthfulness\n\nHe never lied.\nPractice: No exaggeration in speech.',
  'Day 26 – Patience\n\nRamadan is month of sabr.\nPractice: Stay calm during hunger.',
  'Day 27 – Intense Worship\n\nHe increased effort in last ten nights.\nPractice: Reduce sleep, increase dua.',
  'Day 28 – Hope in Mercy\n\nHe loved optimism.\nPractice: Ask Allah for Jannah with certainty.',
  'Day 29 – Consistency After Ramadan\n\nHe loved consistent deeds.\nPractice: Plan one habit to continue after Eid.',
];
