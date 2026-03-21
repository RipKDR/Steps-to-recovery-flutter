class DailyReadingContent {
  final String id;
  final String dateKey;
  final String title;
  final String content;
  final String reflectionPrompt;
  final String source;

  const DailyReadingContent({
    required this.id,
    required this.dateKey,
    required this.title,
    required this.content,
    required this.reflectionPrompt,
    required this.source,
  });
}

class ReadingContent {
  final String id;
  final String title;
  final String? subtitle;
  final String content;
  final String source;
  final String category;
  final bool isCommonlyRead;

  const ReadingContent({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    required this.source,
    required this.category,
    required this.isCommonlyRead,
  });
}

class TimeMilestoneContent {
  final int days;
  final String title;
  final String message;
  final String emoji;

  const TimeMilestoneContent({
    required this.days,
    required this.title,
    required this.message,
    required this.emoji,
  });
}

class ChallengeTemplateContent {
  final String id;
  final String title;
  final String description;
  final String type;
  final int target;
  final int duration;
  final String reward;
  final String difficulty;

  const ChallengeTemplateContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.duration,
    required this.reward,
    required this.difficulty,
  });
}

class CrisisResourceContent {
  final String id;
  final String title;
  final String subtitle;
  final String phone;
  final String color;
  final String emoji;
  final bool isEmergency;

  const CrisisResourceContent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.phone,
    required this.color,
    required this.emoji,
    this.isEmergency = false,
  });
}

const Map<String, DailyReadingContent> dailyReadings = {
  '01-01': DailyReadingContent(
    id: '01-01',
    dateKey: '01-01',
    title: 'A New Beginning',
    content:
        'Today marks a fresh start. In recovery, we learn that each day is an opportunity to begin again. The past does not define us. Our actions today do.\n\nWe have been given the gift of a new day, free from the bondage of active addiction. This is not something to take for granted. Many of us never thought we would see this day, yet here we are.\n\nAs we step into this new day, we carry with us the lessons of yesterday but leave behind its burdens. We focus on what we can do today to strengthen our recovery and help others on their journey.',
    reflectionPrompt:
        'What does a fresh start mean to you today? How can you make the most of this new beginning?',
    source: 'jft',
  ),
  '01-02': DailyReadingContent(
    id: '01-02',
    dateKey: '01-02',
    title: 'One Day at a Time',
    content:
        'The slogan "one day at a time" is more than just words. It is a way of life. When we were using, we could not imagine getting through a single day without our drug of choice. Now we know that all we have to do is stay clean for today.\n\nTomorrow will take care of itself. Yesterday is gone. All we have is this present moment, this one day. By breaking our recovery down into manageable pieces, we find that the impossible becomes possible.\n\nWhen life feels overwhelming, we return to this simple truth: just for today, we can do what would be impossible for a lifetime.',
    reflectionPrompt:
        'How does focusing on just today help you in your recovery? What challenges become easier when you think one day at a time?',
    source: 'jft',
  ),
  '01-03': DailyReadingContent(
    id: '01-03',
    dateKey: '01-03',
    title: 'Surrender',
    content:
        'Surrender is not defeat. It is victory. For so long, we fought against the truth of our addiction. We tried to control our using, bargained with ourselves, and made countless promises we could not keep.\n\nTrue surrender came when we finally admitted we were powerless over our addiction. This admission was not weakness; it was the first act of strength in our recovery. By letting go of the illusion of control, we opened ourselves to a new way of living.\n\nToday, we continue to practice surrender. We let go of outcomes, trust in a power greater than ourselves, and accept life on life\'s terms.',
    reflectionPrompt:
        "What does surrender mean to you? Is there something you're still trying to control that you need to let go of?",
    source: 'jft',
  ),
  '01-05': DailyReadingContent(
    id: '01-05',
    dateKey: '01-05',
    title: 'Willingness',
    content:
        'Willingness is the key that unlocks the door to recovery. We do not have to be perfect, we do not have to have all the answers. We just have to be willing.\n\nWilling to try a new way. Willing to ask for help. Willing to believe that recovery is possible. Willing to take suggestions from those who have walked this path before us.\n\nOur willingness does not have to be complete. Even a small amount of willingness, what some call the willingness to be willing, is enough to begin. As we take action, our willingness grows.',
    reflectionPrompt:
        'In what areas of your recovery do you need more willingness? What small step can you take today?',
    source: 'jft',
  ),
  '02-01': DailyReadingContent(
    id: '02-01',
    dateKey: '02-01',
    title: 'Gratitude',
    content:
        'Gratitude transforms our perspective. In active addiction, we focused on what we lacked, what was not fair, what others had that we did not. This thinking fueled our resentments and justified our using.\n\nIn recovery, we learn to focus on what we have rather than what we do not. Even on difficult days, we can find something to be grateful for. Our sobriety, a roof over our heads, another chance at life.\n\nPracticing gratitude does not mean ignoring our problems. It means recognizing that even in the midst of challenges, there is good in our lives. Gratitude opens the door to hope.',
    reflectionPrompt:
        'List three things you are grateful for today. How does focusing on gratitude change your outlook?',
    source: 'jft',
  ),
  '02-02': DailyReadingContent(
    id: '02-02',
    dateKey: '02-02',
    title: 'The Power of Meetings',
    content:
        'Meetings are where we find our people. Others who understand the disease of addiction because they live with it too. In meetings, we do not have to explain or justify ourselves. We belong.\n\nRegular meeting attendance keeps us connected to recovery. It reminds us where we came from, keeps us humble, and shows us where we can go. Even when we do not feel like going, especially when we do not feel like going, meetings are important.\n\nWe get out of meetings what we put into them. When we show up, listen, share honestly, and connect with others, meetings become a lifeline for our recovery.',
    reflectionPrompt:
        'How have meetings helped your recovery? Is there a meeting you could add to your routine?',
    source: 'jft',
  ),
  '03-01': DailyReadingContent(
    id: '03-01',
    dateKey: '03-01',
    title: 'Progress, Not Perfection',
    content:
        'Perfectionism is a trap. In our addiction, we may have used our impossibly high standards as an excuse. If we could not do something perfectly, why bother? This all-or-nothing thinking kept us stuck.\n\nRecovery teaches us that progress is what matters. We will not do everything right. We will make mistakes, have setbacks, and fall short of our ideals. That is okay. What matters is that we keep moving forward.\n\nEvery small step in the right direction is a victory. Every day clean is an achievement. We measure ourselves by how far we have come, not by some impossible standard of perfection.',
    reflectionPrompt:
        'Where in your life are you being too hard on yourself? How can you celebrate your progress today?',
    source: 'jft',
  ),
  '03-15': DailyReadingContent(
    id: '03-15',
    dateKey: '03-15',
    title: 'Dealing with Cravings',
    content:
        'Cravings are a normal part of recovery, especially in early days. When a craving hits, it can feel overwhelming, like we will never be able to resist. But cravings pass.\n\nWe have learned strategies for dealing with cravings: calling our sponsor or another recovering addict, going to a meeting, playing the tape forward, remembering our last days of using. The key is to take action rather than sitting alone with the craving.\n\nEvery craving we survive without using makes us stronger. Each time we get through a craving, we prove to ourselves that we can do this. The cravings will lessen over time.',
    reflectionPrompt:
        "What strategies help you when you experience cravings? Who can you call when you're struggling?",
    source: 'jft',
  ),
  '04-01': DailyReadingContent(
    id: '04-01',
    dateKey: '04-01',
    title: 'Letting Go of the Past',
    content:
        'Our past haunts many of us. The things we did in our addiction, the people we hurt, the opportunities we lost. These memories can weigh heavy on our hearts. Guilt and shame threaten to overwhelm us.\n\nBut recovery offers us freedom from the past. Through the steps, we face what we have done, make amends where possible, and learn to forgive ourselves. We cannot change the past, but we can change how it affects us today.\n\nLetting go does not mean forgetting. It means the past no longer controls us. We carry the lessons forward without carrying the pain.',
    reflectionPrompt:
        'What from your past do you need to let go of? How can working the steps help you find freedom?',
    source: 'jft',
  ),
  '05-01': DailyReadingContent(
    id: '05-01',
    dateKey: '05-01',
    title: 'The Importance of Self-Care',
    content:
        'In our addiction, we neglected ourselves terribly. We did not eat properly, sleep enough, or take care of our physical and mental health. Recovery asks us to change this.\n\nSelf-care is not selfish. It is necessary. We cannot give what we do not have. When we take care of ourselves, we are better able to work our program and help others. HALT reminds us to check if we are Hungry, Angry, Lonely, or Tired.\n\nToday, we commit to treating ourselves with the same care we would give to someone we love. We eat nourishing food, get enough rest, exercise, and tend to our emotional needs.',
    reflectionPrompt:
        'How are you taking care of yourself today? What area of self-care needs more attention?',
    source: 'jft',
  ),
  '06-01': DailyReadingContent(
    id: '06-01',
    dateKey: '06-01',
    title: 'Living in the Present',
    content:
        'Our minds tend to drift to the past or race toward the future. We replay old regrets or worry about what might happen. Meanwhile, we miss the only moment we actually have. Now.\n\nRecovery teaches us to live in the present. When we are fully present, we can respond to life as it happens rather than reacting to fears and memories. We find that the present moment is usually manageable.\n\nToday, we practice presence. We notice when our minds wander and gently bring them back. We engage fully with whatever we are doing. We find peace in the now.',
    reflectionPrompt:
        'Where does your mind tend to wander? How can you practice being more present today?',
    source: 'jft',
  ),
  '07-01': DailyReadingContent(
    id: '07-01',
    dateKey: '07-01',
    title: 'Freedom from Addiction',
    content:
        'Freedom. Real freedom. Was something we lost long ago. We thought we were choosing to use, but our addiction had taken away our power of choice. We were slaves to our disease.\n\nRecovery has given us our freedom back. Today, we can choose how to live. We can choose to go to meetings, work our program, and stay clean. We have options we never had before.\n\nThis freedom is precious and worth protecting. We guard it by continuing to work our program, staying connected to our support network, and never forgetting what it was like before recovery.',
    reflectionPrompt:
        'What does freedom mean to you in recovery? How are you protecting your freedom today?',
    source: 'jft',
  ),
  '08-01': DailyReadingContent(
    id: '08-01',
    dateKey: '08-01',
    title: 'Staying Humble',
    content:
        'Humility is essential to our recovery. It was our pride and ego that convinced us we could control our using, that we were different, that we did not need help. Humility opens us to learning and growth.\n\nStaying humble does not mean thinking poorly of ourselves. It means having an accurate view of who we are. Acknowledging both our strengths and our limitations. It means remaining teachable.\n\nWhen we have been clean for a while, we may be tempted to think we have it figured out. But our disease is patient. Staying humble keeps us vigilant and willing to continue working our program.',
    reflectionPrompt:
        'In what ways do you practice humility in your recovery? Where might pride be creeping in?',
    source: 'jft',
  ),
  '09-01': DailyReadingContent(
    id: '09-01',
    dateKey: '09-01',
    title: 'Back to Basics',
    content:
        'When life gets complicated or recovery feels hard, we go back to basics. The fundamentals that worked in our early days still work now: meetings, working with a sponsor, helping others, and working the steps.\n\nSometimes we try to overcomplicate recovery. We think we need something more advanced, more sophisticated. But the basics are the basics for a reason. They work. When in doubt, we keep it simple.\n\nToday, we recommit to the fundamental practices of our program. We do not neglect the foundations that keep us clean. We remember that a strong recovery is built on simple, consistent actions.',
    reflectionPrompt:
        'Are you practicing the basics of your program? What fundamental practice have you been neglecting?',
    source: 'jft',
  ),
  '10-01': DailyReadingContent(
    id: '10-01',
    dateKey: '10-01',
    title: 'Taking Inventory',
    content:
        'Regular self-examination keeps us honest and helps us grow. The tenth step tells us to continue to take personal inventory and promptly admit when we are wrong. This is not about beating ourselves up. It is about staying clean and growing.\n\nDaily inventory helps us catch problems before they grow. We review our day: Where were we selfish? Dishonest? Afraid? Do we owe anyone an amends? What did we do well? This honest assessment keeps us on track.\n\nWhen we find something that needs attention, we do not delay. We address it promptly. By keeping our side of the street clean, we maintain our peace of mind and our recovery.',
    reflectionPrompt:
        'Take a brief inventory of your day so far. What needs attention? What are you proud of?',
    source: 'jft',
  ),
  '11-01': DailyReadingContent(
    id: '11-01',
    dateKey: '11-01',
    title: 'Counting Our Blessings',
    content:
        'November begins a season of gratitude. As we look back on our journey, we can see countless blessings we might have missed before. Our eyes are open now.\n\nWe are alive. We are clean. We have a chance to live differently. These alone are enormous blessings. But there is more. Fellowship, hope, tools for living, people who care about us. The list goes on.\n\nToday, we take time to count our blessings. Not to ignore our problems, but to remember that even in difficult times, we have much to be grateful for. Gratitude changes our perspective and lifts our spirits.',
    reflectionPrompt: 'Make a gratitude list. What five things are you most grateful for today?',
    source: 'jft',
  ),
  '12-31': DailyReadingContent(
    id: '12-31',
    dateKey: '12-31',
    title: 'Carrying the Message Forward',
    content:
        'As one year ends and another begins, we look forward with hope. We have been given a precious gift. A day, a week, a month, a year, however long we have had clean. We do not take it for granted.\n\nOur job now is to carry the message forward. To be there for the addict who still suffers. To share our experience with those who need to hear it. To live as an example of what recovery makes possible.\n\nThe new year is full of possibility. We do not know what it will bring, but we know we do not have to face it alone. Together, with our program and our fellowship, we can handle whatever comes. Just for today, we are free.',
    reflectionPrompt:
        'What message of hope do you want to carry into the new year? How will you share your recovery with others?',
    source: 'jft',
  ),
};

const List<ReadingContent> commonReadings = [
  ReadingContent(
    id: 'how-it-works',
    title: 'How It Works',
    content:
        'If you want what we have to offer, and are willing to make the effort to get it, then you are ready to take certain steps. The Twelve Steps are a practical path to recovery and a way of living that helps us stay clean one day at a time.',
    source: 'adapted',
    category: 'opening',
    isCommonlyRead: true,
  ),
  ReadingContent(
    id: 'just-for-today',
    title: 'Just for Today',
    content:
        'Just for today my thoughts will be on my recovery, living and enjoying life without the use of drugs. Just for today I will have a program. I will try to follow it to the best of my ability.',
    source: 'na',
    category: 'closing',
    isCommonlyRead: true,
  ),
  ReadingContent(
    id: 'sponsorship',
    title: 'What Is Sponsorship?',
    content:
        'A sponsor is a member of the fellowship who is further along in recovery and shares experience with a newer member to help guide them through the program. A sponsor can help you work the steps and stay accountable.',
    source: 'common recovery principles',
    category: 'informational',
    isCommonlyRead: false,
  ),
  ReadingContent(
    id: 'meetings-work',
    title: 'How Meetings Work',
    content:
        'Meetings are the foundation of the 12-step program. They provide a safe space where we can share our experience, strength, and hope with others. You do not have to share if you do not want to. Listening is enough.',
    source: 'common recovery principles',
    category: 'informational',
    isCommonlyRead: false,
  ),
];

const List<TimeMilestoneContent> timeMilestones = [
  TimeMilestoneContent(days: 1, title: '1 Day', message: 'Your first day. Every journey begins with a single step.', emoji: '🌱'),
  TimeMilestoneContent(days: 7, title: '1 Week', message: 'A full week. Your body and mind are already healing.', emoji: '⭐'),
  TimeMilestoneContent(days: 30, title: '1 Month', message: 'One month. This is a major achievement. Be proud.', emoji: '🏆'),
  TimeMilestoneContent(days: 90, title: '90 Days', message: 'The big 90. A cornerstone of recovery.', emoji: '🎉'),
  TimeMilestoneContent(days: 180, title: '6 Months', message: 'Half a year. Your dedication is inspiring.', emoji: '🌈'),
  TimeMilestoneContent(days: 365, title: '1 Year', message: 'One full year of choosing yourself.', emoji: '🎊'),
  TimeMilestoneContent(days: 730, title: '2 Years', message: 'Two years. You have proven anything is possible.', emoji: '👑'),
  TimeMilestoneContent(days: 1825, title: '5 Years', message: 'Five years. A true testament to your strength.', emoji: '🌠'),
];

const List<ChallengeTemplateContent> challengeTemplates = [
  ChallengeTemplateContent(
    id: 'tmpl_7_journal',
    title: '7-Day Journal Streak',
    description: 'Write a journal entry every day for one week. Build the habit of reflection.',
    type: 'journal',
    target: 7,
    duration: 7,
    reward: 'journal_starter',
    difficulty: 'easy',
  ),
  ChallengeTemplateContent(
    id: 'tmpl_14_checkin',
    title: '14-Day Check-In Streak',
    description: 'Complete your daily check-in for two straight weeks.',
    type: 'checkin',
    target: 14,
    duration: 14,
    reward: 'checkin_champion',
    difficulty: 'medium',
  ),
  ChallengeTemplateContent(
    id: 'tmpl_7_gratitude',
    title: 'Daily Gratitude Week',
    description: 'Record three things you are grateful for every day this week.',
    type: 'gratitude',
    target: 7,
    duration: 7,
    reward: 'gratitude_guru',
    difficulty: 'easy',
  ),
  ChallengeTemplateContent(
    id: 'tmpl_step_sprint',
    title: 'Step Work Sprint',
    description: 'Answer 5 step-work questions in 7 days. Make real progress on your steps.',
    type: 'step',
    target: 5,
    duration: 7,
    reward: 'step_sprinter',
    difficulty: 'medium',
  ),
  ChallengeTemplateContent(
    id: 'tmpl_30_morning',
    title: 'Morning Intention Month',
    description: 'Set a morning intention every day for 30 days. Start each day with purpose.',
    type: 'checkin',
    target: 30,
    duration: 30,
    reward: 'morning_master',
    difficulty: 'medium',
  ),
];

const List<CrisisResourceContent> crisisResources = [
  CrisisResourceContent(
    id: 'emergency-us',
    title: 'Emergency Services',
    subtitle: '911 - Life-threatening emergency',
    phone: '911',
    color: '#ef4444',
    emoji: '🆘',
    isEmergency: true,
  ),
  CrisisResourceContent(
    id: 'suicide-prevention-us',
    title: '988 Suicide & Crisis Lifeline',
    subtitle: '988 - 24/7 crisis support',
    phone: '988',
    color: '#3b82f6',
    emoji: '📞',
  ),
  CrisisResourceContent(
    id: 'samhsa-us',
    title: 'SAMHSA National Helpline',
    subtitle: '1-800-662-4357 - treatment referral',
    phone: '1-800-662-4357',
    color: '#6366f1',
    emoji: '💬',
  ),
];

const List<String> copingStrategies = [
  'Call your sponsor or a trusted person in recovery.',
  'Attend a meeting right now if you can.',
  'Check HALT: hungry, angry, lonely, or tired.',
  'Play the tape forward and remember where using leads.',
  'Change your environment and go somewhere safe.',
  'Breathe slowly and focus on the next right action.',
];

DailyReadingContent readingForDate(DateTime date) {
  final dateKey =
      '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return dailyReadings[dateKey] ?? _defaultReadingForDate(dateKey);
}

List<DailyReadingContent> recentDailyReadings({int limit = 8}) {
  final readings = dailyReadings.values.toList()
    ..sort((a, b) => a.dateKey.compareTo(b.dateKey));
  return readings.length <= limit ? readings : readings.sublist(readings.length - limit);
}

ReadingContent? commonReadingById(String id) {
  for (final reading in commonReadings) {
    if (reading.id == id) {
      return reading;
    }
  }
  return null;
}

TimeMilestoneContent? nextMilestoneForDays(int daysSober) {
  for (final milestone in timeMilestones) {
    if (milestone.days > daysSober) {
      return milestone;
    }
  }
  return null;
}

List<TimeMilestoneContent> achievedMilestonesForDays(int daysSober) {
  return timeMilestones.where((milestone) => milestone.days <= daysSober).toList();
}

DailyReadingContent _defaultReadingForDate(String dateKey) {
  final defaults = [
    (
      'Just for Today',
      'Just for today, I will try to live through this day only, and not tackle my whole life problems at once. I can do something for today that would appall me if I felt I had to keep it up for a lifetime.\n\nJust for today, I will be happy. Most folks are as happy as they make up their minds to be.',
      'What can you focus on just for today? How can you live in this moment?',
    ),
    (
      'Keep Coming Back',
      'The doors of recovery are always open. No matter how many times we have tried and failed, no matter how far we have fallen, we can always come back.\n\nThere is no shame in struggling. Recovery is hard. What matters is that we keep trying, keep coming back, keep showing up.',
      'What keeps you coming back? How has persistence paid off in your recovery?',
    ),
    (
      'Easy Does It',
      'In our addiction, we often lived in extremes. All or nothing. Fast and reckless. Recovery asks us to slow down, to take it easy, to be gentle with ourselves and others.\n\nEasy does it reminds us not to take on too much too fast. We do not have to solve all our problems today.',
      'Where in your life do you need to take it easier? How can you be more gentle with yourself today?',
    ),
    (
      'First Things First',
      'Our priorities in addiction were completely distorted. Using came first, before family, work, health, everything. Recovery asks us to rearrange our priorities.\n\nFirst things first means putting our recovery at the top of the list. Everything else depends on staying clean.',
      'Are your priorities in order? What might be crowding out your recovery?',
    ),
  ];

  final dayNum = int.tryParse(dateKey.split('-').last) ?? 1;
  final selected = defaults[(dayNum - 1) % defaults.length];
  return DailyReadingContent(
    id: dateKey,
    dateKey: dateKey,
    title: selected.$1,
    content: selected.$2,
    reflectionPrompt: selected.$3,
    source: 'jft',
  );
}
