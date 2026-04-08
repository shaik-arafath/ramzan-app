class RamadanTipsData {
  static const List<String> tips = [
    // Day 1 – Intention (Niyyah)
    'Day 1 – Intention (Niyyah)\n\nRenew intention before every act.\nExample: Before fasting, say in the heart: "I fast for Allah."',
    // Day 2 – Suhoor
    'Day 2 – Suhoor\n\nThe Prophet ﷺ delayed suhoor.\nPractice: Eat suhoor close to Fajr.',
    // Day 3 – Breaking Fast Quickly
    'Day 3 – Breaking Fast Quickly\n\nBreak fast immediately at Maghrib.\nPractice: Break with one date and water first.',
    // Day 4 – Dua at Iftar
    'Day 4 – Dua at Iftar\n\nDua at the time of breaking fast is accepted.\nPractice: Make personal dua before eating fully.',
    // Day 5 – Gentle Speech
    'Day 5 – Gentle Speech\n\nHe ﷺ avoided arguments while fasting.\nPractice: If angry, say: "I am fasting."',
    // Day 6 – Qur’an Daily
    'Day 6 – Qur’an Daily\n\nHe reviewed the Qur’an every Ramadan with Jibreel.\nPractice: Fix a daily portion to recite.',
    // Day 7 – Charity
    'Day 7 – Charity\n\nHe ﷺ was most generous in Ramadan.\nPractice: Give something in charity daily, even something small.',
    // Day 8 – Smiling
    'Day 8 – Smiling\n\nSmiling is charity.\nPractice: Smile at family despite hunger and tiredness.',
    // Day 9 – Feeding Others
    'Day 9 – Feeding Others\n\nFeeding a fasting person earns the same reward as their fast.\nPractice: Provide iftar for at least one person.',
    // Day 10 – Night Prayer
    'Day 10 – Night Prayer\n\nHe prayed long in the nights of Ramadan.\nPractice: Pray Taraweeh consistently.',
    // Day 11 – Miswak
    'Day 11 – Miswak\n\nHe used miswak frequently.\nPractice: Use miswak before salah.',
    // Day 12 – Gratitude After Eating
    'Day 12 – Gratitude After Eating\n\nHe praised Allah after meals.\nPractice: Say Alhamdulillah sincerely after eating.',
    // Day 13 – Moderation in Food
    'Day 13 – Moderation in Food\n\nHe never overfilled his stomach.\nPractice: Eat lightly at iftar and avoid overeating.',
    // Day 14 – Visiting the Sick
    'Day 14 – Visiting the Sick\n\nHe visited the ill and comforted them.\nPractice: Call or visit a sick person today.',
    // Day 15 – Family Kindness
    'Day 15 – Family Kindness\n\nHe was best in character to his family.\nPractice: Help at home before iftar and be extra kind.',
    // Day 16 – Dhikr in Free Time
    'Day 16 – Dhikr in Free Time\n\nHis tongue was moist with remembrance of Allah.\nPractice: Say SubhanAllah 100 times during free moments.',
    // Day 17 – Forgiveness
    'Day 17 – Forgiveness\n\nHe forgave even those who wronged him.\nPractice: Forgive one person sincerely for Allah’s sake.',
    // Day 18 – Cleanliness
    'Day 18 – Cleanliness\n\nHe loved cleanliness and purity.\nPractice: Keep your prayer area and home clean.',
    // Day 19 – Dua for Others
    'Day 19 – Dua for Others\n\nHe made dua for his companions.\nPractice: Make dua for at least five people by name.',
    // Day 20 – I‘tikaf
    'Day 20 – I‘tikaf\n\nHe performed i‘tikaf in the last ten nights.\nPractice: Spend extra time in the masjid if possible.',
    // Day 21 – Seeking Laylatul Qadr
    'Day 21 – Seeking Laylatul Qadr\n\nHe sought Laylatul Qadr in the odd nights.\nPractice: Increase worship on the 21st night.',
    // Day 22 – Long Sujood
    'Day 22 – Long Sujood\n\nHe made long sujood in prayer.\nPractice: Add personal dua in sujood and lengthen it.',
    // Day 23 – Salawat
    'Day 23 – Salawat\n\nHe encouraged sending blessings upon him.\nPractice: Send 100 salawat upon the Prophet ﷺ.',
    // Day 24 – Control the Gaze
    'Day 24 – Control the Gaze\n\nHe lowered his gaze from what displeases Allah.\nPractice: Avoid harmful media and lower your gaze.',
    // Day 25 – Truthfulness
    'Day 25 – Truthfulness\n\nHe never lied.\nPractice: Remove exaggeration and dishonesty from your speech today.',
    // Day 26 – Patience
    'Day 26 – Patience\n\nRamadan is the month of sabr (patience).\nPractice: Stay calm during hunger, thirst, and delays.',
    // Day 27 – Intense Worship
    'Day 27 – Intense Worship\n\nHe increased effort in the last ten nights.\nPractice: Reduce sleep and increase dua and Qur’an.',
    // Day 28 – Hope in Mercy
    'Day 28 – Hope in Mercy\n\nHe loved optimism and hope in Allah.\nPractice: Ask Allah for Jannah with full certainty.',
    // Day 29 – Consistency After Ramadan
    'Day 29 – Consistency After Ramadan\n\nHe loved consistent deeds, even if small.\nPractice: Choose one good habit from Ramadan to continue after Eid.',
  ];

  static String getTipForDay(int day) {
    if (tips.isEmpty) return '';
    final index = (day - 1).clamp(0, tips.length - 1);
    return tips[index];
  }

  static List<String> getTipsForCarousel() => List.from(tips);
}
