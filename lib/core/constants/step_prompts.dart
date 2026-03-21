/// 12-Step Work Prompts
/// Based on traditional AA/NA step work guides
class StepPrompt {
  final int step;
  final String title;
  final String principle;
  final String description;
  final List<String> prompts;
  final List<StepSection> sections;

  const StepPrompt({
    required this.step,
    required this.title,
    required this.principle,
    required this.description,
    required this.prompts,
    required this.sections,
  });
}

class StepSection {
  final String title;
  final List<String> prompts;

  const StepSection({
    required this.title,
    required this.prompts,
  });
}

/// All 12-step prompts organized by step number
class StepPrompts {
  StepPrompts._();

  static const List<StepPrompt> all = [
    step1,
    step2,
    step3,
    step4,
    step5,
    step6,
    step7,
    step8,
    step9,
    step10,
    step11,
    step12,
  ];

  // STEP 1: POWERLESSNESS
  static const step1 = StepPrompt(
    step: 1,
    title: 'Powerlessness',
    principle: 'Honesty',
    description: 'We admitted we were powerless over our addiction—that our lives had become unmanageable.',
    prompts: [
      'What does powerlessness mean to you in the context of your addiction?',
      'When did you first realize you couldn\'t control your use, even when you wanted to?',
      'Describe a time when you promised yourself you wouldn\'t use, but did anyway.',
      'Have you ever tried to control or limit your use? What happened?',
      'What rules did you make for yourself about using? How long did they last?',
      'Describe the mental obsession that precedes your using.',
      'How has addiction affected your ability to make rational decisions?',
      'Have you ever done things while using that you never thought you would do?',
      'What evidence do you have that your willpower alone cannot solve your addiction?',
      'How has denial played a role in your addiction?',
    ],
    sections: [
      StepSection(
        title: 'Understanding Powerlessness',
        prompts: [
          'What does powerlessness mean to you in the context of your addiction?',
          'When did you first realize you couldn\'t control your use?',
          'Describe a time when you promised yourself you wouldn\'t use, but did anyway.',
          'Have you ever tried to control or limit your use? What happened?',
          'What rules did you make for yourself about using? How long did they last?',
        ],
      ),
      StepSection(
        title: 'Physical Consequences',
        prompts: [
          'How has your addiction affected your physical health?',
          'Have you experienced withdrawal symptoms? Describe them.',
          'What physical risks have you taken because of your addiction?',
          'How has your sleep, appetite, or energy been affected?',
        ],
      ),
      StepSection(
        title: 'Unmanageability in Relationships',
        prompts: [
          'How has your addiction affected your relationship with your spouse/partner?',
          'How has your addiction affected your relationships with your children?',
          'How has your addiction affected your relationships with parents and family?',
          'What friendships have you lost or damaged because of your addiction?',
        ],
      ),
      StepSection(
        title: 'Unmanageability in Daily Life',
        prompts: [
          'How has your addiction affected your work or career?',
          'What financial problems have resulted from your addiction?',
          'How has your addiction affected your ability to meet basic responsibilities?',
          'Have you had legal problems related to your addiction?',
        ],
      ),
    ],
  );

  // STEP 2: HOPE
  static const step2 = StepPrompt(
    step: 2,
    title: 'Hope',
    principle: 'Hope',
    description: 'Came to believe that a Power greater than ourselves could restore us to sanity.',
    prompts: [
      'What did "insanity" mean to you in the context of your addiction?',
      'When did you first recognize that your thinking was distorted?',
      'What does a "Power greater than yourself" mean to you?',
      'How has your addiction affected your ability to trust?',
      'What does "restoration to sanity" look like for you?',
      'Describe a time when you felt hopeless about your situation.',
      'What gives you hope now?',
      'How has your understanding of a Higher Power evolved?',
      'What role does faith play in your recovery?',
      'Describe what sanity means in your daily life.',
    ],
    sections: [
      StepSection(
        title: 'Recognizing Insanity',
        prompts: [
          'What did "insanity" mean to you in the context of your addiction?',
          'When did you first recognize that your thinking was distorted?',
          'Describe the repetitive patterns that kept you stuck.',
        ],
      ),
      StepSection(
        title: 'Finding Hope',
        prompts: [
          'What does a "Power greater than yourself" mean to you?',
          'What gives you hope now?',
          'How has your understanding of a Higher Power evolved?',
        ],
      ),
      StepSection(
        title: 'Restoration to Sanity',
        prompts: [
          'What does "restoration to sanity" look like for you?',
          'Describe what sanity means in your daily life.',
          'How do you know when you\'re thinking clearly?',
        ],
      ),
    ],
  );

  // STEP 3: SURRENDER
  static const step3 = StepPrompt(
    step: 3,
    title: 'Surrender',
    principle: 'Faith',
    description: 'Made a decision to turn our will and our lives over to the care of God as we understood Him.',
    prompts: [
      'What does "turning your will over" mean to you?',
      'Describe your relationship with control before recovery.',
      'What does surrender mean in the context of recovery?',
      'How do you understand "God as we understood Him"?',
      'What fears come up when you think about surrender?',
      'What does it mean to turn your life over to a Higher Power?',
      'How has trying to control everything worked out for you?',
      'What would it look like to let go of control?',
      'Describe a time when you felt cared for by a Higher Power.',
      'What does faith mean to you in recovery?',
    ],
    sections: [
      StepSection(
        title: 'Understanding Surrender',
        prompts: [
          'What does "turning your will over" mean to you?',
          'Describe your relationship with control before recovery.',
          'What does surrender mean in the context of recovery?',
        ],
      ),
      StepSection(
        title: 'Letting Go',
        prompts: [
          'What fears come up when you think about surrender?',
          'How has trying to control everything worked out for you?',
          'What would it look like to let go of control?',
        ],
      ),
      StepSection(
        title: 'Faith in Action',
        prompts: [
          'How do you understand "God as we understood Him"?',
          'Describe a time when you felt cared for by a Higher Power.',
          'What does faith mean to you in recovery?',
        ],
      ),
    ],
  );

  // STEP 4: MORAL INVENTORY
  static const step4 = StepPrompt(
    step: 4,
    title: 'Moral Inventory',
    principle: 'Courage',
    description: 'Made a searching and fearless moral inventory of ourselves.',
    prompts: [
      'What does "searching and fearless" mean to you?',
      'List your resentments and why you resent each person/institution.',
      'How have you been selfish in each situation?',
      'Where have you been dishonest?',
      'What are you afraid of? List your fears.',
      'How have your fears affected your behavior?',
      'List the sexual conduct that has bothered you.',
      'What character defects do you see in yourself?',
      'What are your strengths and positive qualities?',
      'How has keeping this inventory been helpful?',
    ],
    sections: [
      StepSection(
        title: 'Resentment Inventory',
        prompts: [
          'List your resentments and why you resent each person/institution.',
          'How have you been selfish in each resentment situation?',
          'Where were you dishonest in each situation?',
          'What part did you play in each situation?',
        ],
      ),
      StepSection(
        title: 'Fear Inventory',
        prompts: [
          'What are you afraid of? List your fears.',
          'How have your fears affected your behavior?',
          'Where have you been selfish due to fear?',
          'What relationships have been damaged by fear?',
        ],
      ),
      StepSection(
        title: 'Sexual Conduct Inventory',
        prompts: [
          'List the sexual conduct that has bothered you.',
          'Who was hurt by your actions?',
          'What character defects were involved?',
          'What would you do differently now?',
        ],
      ),
      StepSection(
        title: 'Character Assets',
        prompts: [
          'What are your strengths and positive qualities?',
          'What good things have you done for others?',
          'What are you proud of in your life?',
          'How can you use your strengths in recovery?',
        ],
      ),
    ],
  );

  // STEP 5: CONFESSION
  static const step5 = StepPrompt(
    step: 5,
    title: 'Confession',
    principle: 'Integrity',
    description: 'Admitted to God, to ourselves, and to another human being the exact nature of our wrongs.',
    prompts: [
      'What was it like to share your Fourth Step inventory?',
      'Who did you choose to share with and why?',
      'What fears did you have before sharing?',
      'How did you feel after sharing?',
      'What does "the exact nature of our wrongs" mean?',
      'How has confession affected your relationship with yourself?',
      'What did you learn about yourself through this process?',
      'How has sharing affected your shame?',
      'What does integrity mean to you now?',
      'Describe any relief or changes you\'ve experienced.',
    ],
    sections: [
      StepSection(
        title: 'Preparing to Share',
        prompts: [
          'Who did you choose to share with and why?',
          'What fears did you have before sharing?',
          'How did you prepare for this conversation?',
        ],
      ),
      StepSection(
        title: 'The Sharing Experience',
        prompts: [
          'What was it like to share your Fourth Step inventory?',
          'What was the most difficult part to share?',
          'How did the other person respond?',
        ],
      ),
      StepSection(
        title: 'Aftermath',
        prompts: [
          'How did you feel after sharing?',
          'What does integrity mean to you now?',
          'Describe any relief or changes you\'ve experienced.',
        ],
      ),
    ],
  );

  // STEP 6: READINESS
  static const step6 = StepPrompt(
    step: 6,
    title: 'Readiness',
    principle: 'Willingness',
    description: 'Were entirely ready to have God remove all these defects of character.',
    prompts: [
      'What character defects are you ready to let go of?',
      'Which defects are you still attached to?',
      'What does "entirely ready" mean to you?',
      'How have these defects protected you in the past?',
      'Why are you ready to let them go now?',
      'What would life be like without these defects?',
      'What fears come up about changing?',
      'How ready are you on a scale of 1-10?',
      'What would help you become more ready?',
      'Describe what willingness feels like.',
    ],
    sections: [
      StepSection(
        title: 'Identifying Defects',
        prompts: [
          'What character defects are you ready to let go of?',
          'Which defects are you still attached to?',
          'How have these defects shown up in your life?',
        ],
      ),
      StepSection(
        title: 'Developing Readiness',
        prompts: [
          'What does "entirely ready" mean to you?',
          'How ready are you on a scale of 1-10?',
          'What would help you become more ready?',
        ],
      ),
      StepSection(
        title: 'Envisioning Change',
        prompts: [
          'What would life be like without these defects?',
          'Why are you ready to let them go now?',
          'Describe what willingness feels like.',
        ],
      ),
    ],
  );

  // STEP 7: HUMILITY
  static const step7 = StepPrompt(
    step: 7,
    title: 'Humility',
    principle: 'Humility',
    description: 'Humbly asked Him to remove our shortcomings.',
    prompts: [
      'What does humility mean to you?',
      'How is humility different from humiliation?',
      'How have you asked for your shortcomings to be removed?',
      'What role does prayer play in your recovery?',
      'Describe your relationship with your Higher Power.',
      'What does "ask Him to remove" mean in practice?',
      'How do you practice humility in daily life?',
      'What has changed since working Step 7?',
      'How does humility help in recovery?',
      'Describe a time when you felt truly humble.',
    ],
    sections: [
      StepSection(
        title: 'Understanding Humility',
        prompts: [
          'What does humility mean to you?',
          'How is humility different from humiliation?',
          'How does humility help in recovery?',
        ],
      ),
      StepSection(
        title: 'Asking for Help',
        prompts: [
          'How have you asked for your shortcomings to be removed?',
          'What role does prayer play in your recovery?',
          'What does "ask Him to remove" mean in practice?',
        ],
      ),
      StepSection(
        title: 'Living Humbly',
        prompts: [
          'How do you practice humility in daily life?',
          'What has changed since working Step 7?',
          'Describe a time when you felt truly humble.',
        ],
      ),
    ],
  );

  // STEP 8: AMENDS LIST
  static const step8 = StepPrompt(
    step: 8,
    title: 'Amends List',
    principle: 'Justice',
    description: 'Made a list of all persons we had harmed, and became willing to make amends to them all.',
    prompts: [
      'List all the people you have harmed.',
      'How did you harm each person?',
      'What makes someone worthy of an amends?',
      'Are there people you\'re reluctant to make amends to?',
      'What does "willing to make amends" mean?',
      'How do you feel about making amends?',
      'Who on your list seems impossible?',
      'What would willingness look like for each person?',
      'How has making this list affected you?',
      'Describe what justice means in this context.',
    ],
    sections: [
      StepSection(
        title: 'Creating the List',
        prompts: [
          'List all the people you have harmed.',
          'How did you harm each person?',
          'What makes someone worthy of an amends?',
        ],
      ),
      StepSection(
        title: 'Developing Willingness',
        prompts: [
          'Are there people you\'re reluctant to make amends to?',
          'What does "willing to make amends" mean?',
          'What would willingness look like for each person?',
        ],
      ),
      StepSection(
        title: 'Preparing for Action',
        prompts: [
          'How do you feel about making amends?',
          'Who on your list seems impossible?',
          'How has making this list affected you?',
        ],
      ),
    ],
  );

  // STEP 9: MAKING AMENDS
  static const step9 = StepPrompt(
    step: 9,
    title: 'Making Amends',
    principle: 'Justice',
    description: 'Made direct amends to such people wherever possible, except when to do so would injure them or others.',
    prompts: [
      'What amends have you made so far?',
      'How did you approach each amends?',
      'What was the response?',
      'How did making amends affect you?',
      'Are there amends that would cause harm?',
      'What does "direct amends" mean?',
      'How do you make a living amends?',
      'What amends are you still preparing to make?',
      'Describe a difficult amends experience.',
      'What have you learned from making amends?',
    ],
    sections: [
      StepSection(
        title: 'Preparing to Make Amends',
        prompts: [
          'What does "direct amends" mean?',
          'How will you approach each person?',
          'What outcome are you hoping for?',
        ],
      ),
      StepSection(
        title: 'Making Amends',
        prompts: [
          'What amends have you made so far?',
          'How did you approach each amends?',
          'What was the response?',
        ],
      ),
      StepSection(
        title: 'Living Amends',
        prompts: [
          'How do you make a living amends?',
          'What amends are you still preparing to make?',
          'What have you learned from making amends?',
        ],
      ),
    ],
  );

  // STEP 10: DAILY INVENTORY
  static const step10 = StepPrompt(
    step: 10,
    title: 'Daily Inventory',
    principle: 'Perseverance',
    description: 'Continued to take personal inventory and when we were wrong promptly admitted it.',
    prompts: [
      'What went well today?',
      'What am I grateful for today?',
      'Where was I resentful today?',
      'Where was I selfish today?',
      'Where was I dishonest today?',
      'Where was I afraid today?',
      'Did I harm anyone today? How?',
      'Was I kind and loving today?',
      'Do I owe anyone an apology from today?',
      'What could I have done better today?',
      'What do I need to do differently tomorrow?',
      'How did I practice the principles of recovery today?',
    ],
    sections: [
      StepSection(
        title: 'Daily Self-Examination',
        prompts: [
          'What went well today?',
          'What am I grateful for today?',
          'Where was I resentful today?',
          'Where was I selfish today?',
          'Where was I dishonest today?',
          'Where was I afraid today?',
          'Did I harm anyone today? How?',
          'Was I kind and loving today?',
        ],
      ),
      StepSection(
        title: 'Promptly Admitting Wrong',
        prompts: [
          'Do I owe anyone an apology or amends from today?',
          'What does "promptly admitted it" mean to you?',
          'Why is it important not to let wrongs accumulate?',
        ],
      ),
      StepSection(
        title: 'Maintaining Recovery',
        prompts: [
          'What could I have done better today?',
          'What do I need to do differently tomorrow?',
          'How did I practice the principles of recovery today?',
        ],
      ),
    ],
  );

  // STEP 11: SPIRITUAL GROWTH
  static const step11 = StepPrompt(
    step: 11,
    title: 'Spiritual Growth',
    principle: 'Spiritual Awareness',
    description: 'Sought through prayer and meditation to improve our conscious contact with God as we understood Him.',
    prompts: [
      'What is your current prayer practice?',
      'What does prayer mean to you?',
      'What is your current meditation practice?',
      'What does meditation mean to you?',
      'What does "conscious contact" mean to you?',
      'How do you seek guidance in daily life?',
      'How do you incorporate spirituality into your routine?',
      'What obstacles prevent regular practice?',
      'How does your spiritual practice support recovery?',
      'What would you like to improve?',
    ],
    sections: [
      StepSection(
        title: 'Prayer Practice',
        prompts: [
          'What is your current prayer practice?',
          'What does prayer mean to you?',
          'How do you pray?',
        ],
      ),
      StepSection(
        title: 'Meditation Practice',
        prompts: [
          'What is your current meditation practice?',
          'What does meditation mean to you?',
          'What benefits have you noticed?',
        ],
      ),
      StepSection(
        title: 'Conscious Contact',
        prompts: [
          'What does "conscious contact" mean to you?',
          'How do you seek guidance in daily life?',
          'How does your spiritual practice support recovery?',
        ],
      ),
    ],
  );

  // STEP 12: SERVICE
  static const step12 = StepPrompt(
    step: 12,
    title: 'Service',
    principle: 'Service',
    description: 'Having had a spiritual awakening as the result of these Steps, we tried to carry this message to others.',
    prompts: [
      'What does a spiritual awakening mean to you?',
      'How has your life changed from working the steps?',
      'How do you carry the message to others?',
      'Have you sponsored others or helped newcomers?',
      'What service commitments do you have?',
      'How does helping others help your recovery?',
      'What does "practice these principles in all our affairs" mean?',
      'How do you practice honesty in daily life?',
      'How is your home life different now?',
      'How is your work life different now?',
      'What does recovery mean to you today?',
    ],
    sections: [
      StepSection(
        title: 'Spiritual Awakening',
        prompts: [
          'What does a spiritual awakening mean to you?',
          'How has your life changed from working the steps?',
          'What was your spiritual condition when you started?',
        ],
      ),
      StepSection(
        title: 'Carrying the Message',
        prompts: [
          'How do you carry the message to others?',
          'Have you sponsored others or helped newcomers?',
          'What service commitments do you have?',
        ],
      ),
      StepSection(
        title: 'Living Recovery',
        prompts: [
          'How is your home life different now?',
          'How is your work life different now?',
          'What does recovery mean to you today?',
        ],
      ),
    ],
  );

  /// Get prompts for a specific step
  static StepPrompt? getStep(int stepNumber) {
    if (stepNumber < 1 || stepNumber > 12) return null;
    return all[stepNumber - 1];
  }

  /// Get total number of questions for a step
  static int getStepQuestionCount(int stepNumber) {
    final step = getStep(stepNumber);
    return step?.prompts.length ?? 0;
  }

  /// Get total questions across all steps
  static int getTotalQuestionCount() {
    return all.fold<int>(0, (sum, step) => sum + step.prompts.length);
  }

  /// Check if a step number is valid
  static bool isValidStepNumber(int step) {
    return step >= 1 && step <= 12;
  }
}
