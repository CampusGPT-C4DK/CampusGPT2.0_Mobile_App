import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';
import '../models/career_guidance_model.dart';
import '../providers/providers.dart';
import '../widgets/animated_appear.dart';

class CareerPathScreen extends ConsumerStatefulWidget {
  const CareerPathScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CareerPathScreen> createState() => _CareerPathScreenState();
}

class _CareerPathScreenState extends ConsumerState<CareerPathScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // Form state
  late TextEditingController _interestsController;
  late TextEditingController _knownSkillsController;
  late TextEditingController _careerGoalController;
  late TextEditingController _projectsDoneController;
  late TextEditingController _educationBranchController;
  late TextEditingController _yearOfStudyController;
  late TextEditingController _selfWeaknessController;
  bool _hasInternship = false;
  String? _selectedResumeFilePath;
  String? _selectedResumeFileName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });

    _interestsController = TextEditingController();
    _knownSkillsController = TextEditingController();
    _careerGoalController = TextEditingController();
    _projectsDoneController = TextEditingController();
    _educationBranchController = TextEditingController();
    _yearOfStudyController = TextEditingController();
    _selfWeaknessController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interestsController.dispose();
    _knownSkillsController.dispose();
    _careerGoalController.dispose();
    _projectsDoneController.dispose();
    _educationBranchController.dispose();
    _yearOfStudyController.dispose();
    _selfWeaknessController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(WidgetRef ref) async {
    // Only require resume file
    if (_selectedResumeFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your resume to get AI guidance.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(careerGuidanceLoadingProvider.notifier).state = true;
    try {
      final qaResponses = QAResponses(
        interests: _interestsController.text,
        knownSkills: _knownSkillsController.text,
        careerGoal: _careerGoalController.text,
        projectsDone: _projectsDoneController.text,
        educationBranch: _educationBranchController.text,
        yearOfStudy: _yearOfStudyController.text,
        hasInternship: _hasInternship,
        selfWeakness: _selfWeaknessController.text,
      );

      final service = ref.read(careerGuidanceServiceProvider);
      final response = await service.generateCareerGuidance(
        resumeFilePath: _selectedResumeFilePath,
        qaResponses: qaResponses,
      );

      ref.read(careerGuidanceResultProvider.notifier).setResult(response);
      if (mounted) _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      ref.read(careerGuidanceLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['txt', 'pdf', 'doc', 'docx']);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedResumeFilePath = result.files.first.path;
          _selectedResumeFileName = result.files.first.name;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark, // Clean light background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textDark),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                border: const Border(
                    bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
            ),
          ),
        ),
        title: const Text('Career Path',
            style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
      ),
      body: Stack(fit: StackFit.expand, children: [
        Positioned(
          top: -50,
          left: -150,
          child: _buildGlowBlob(AppColors.primary, 400),
        ),
        Positioned(
          bottom: 0,
          right: -100,
          child: _buildGlowBlob(AppColors.primaryLight, 400),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
        SafeArea(
          child: Column(
            children: [
              // Sleek Custom Tab Bar
              Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabButton('📝 Form', 0),
                      const SizedBox(width: AppSpacing.md),
                      _buildTabButton('🎯 Results', 1),
                      const SizedBox(width: AppSpacing.md),
                      _buildTabButton('🏆 Resources', 2),
                    ],
                  ),
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGuidanceTab(ref),
                    _buildResultsTab(ref),
                    _buildResourcesTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildGlowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isActive ? Colors.transparent : AppColors.border),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [
                  BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isActive ? Colors.white : AppColors.textMedium,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  Widget _buildGuidanceTab(WidgetRef ref) {
    final isLoading = ref.watch(careerGuidanceLoadingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resume Upload Section
          AnimatedAppear(
              child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Upload Resume (Required)',
                            style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                            'Let CampusGPT analyze your resume for better results.',
                            style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13,
                                height: 1.4)),
                        const SizedBox(height: AppSpacing.md),
                        InkWell(
                          onTap: _pickResumeFile,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                    color: AppColors.primaryLight,
                                    width: 1.5,
                                    style: BorderStyle.solid),
                              ),
                              child: Column(children: [
                                Icon(Icons.upload_file_rounded,
                                    color: AppColors.primary, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedResumeFileName ??
                                      'Tap to select a document (.pdf, .doc)',
                                  style: TextStyle(
                                      color: _selectedResumeFileName != null
                                          ? AppColors.primaryDark
                                          : AppColors.textMedium,
                                      fontWeight: FontWeight.w600),
                                ),
                              ])),
                        )
                      ]))),
          const SizedBox(height: AppSpacing.xl),

          _buildInputField(
              label: 'Your Interests',
              hint: 'e.g., AI, Web Dev',
              controller: _interestsController,
              icon: Icons.favorite_rounded),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
              label: 'Known Skills',
              hint: 'e.g., Python, C++',
              controller: _knownSkillsController,
              icon: Icons.psychology_rounded),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
              label: 'Career Goal',
              hint: 'e.g., Data Scientist',
              controller: _careerGoalController,
              icon: Icons.flag_rounded),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
              label: 'Projects Done',
              hint: 'Describe projects',
              controller: _projectsDoneController,
              icon: Icons.work_rounded,
              maxLines: 3),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
              label: 'Education',
              hint: 'e.g., CS',
              controller: _educationBranchController,
              icon: Icons.school_rounded),
          const SizedBox(height: AppSpacing.lg),
          _buildInputField(
              label: 'Year',
              hint: 'e.g., 3rd',
              controller: _yearOfStudyController,
              icon: Icons.calendar_today_rounded),
          const SizedBox(height: AppSpacing.xl),
          Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.business_center_rounded,
                        color: AppColors.primary)),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                    child: Text('Internship Experience',
                        style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold))),
                Switch(
                    value: _hasInternship,
                    onChanged: (v) => setState(() => _hasInternship = v),
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryLight.withOpacity(0.5)),
              ])),
          const SizedBox(height: AppSpacing.xxxl),

          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5))
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : () => _submitForm(ref),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl))),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Get AI Guidance',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildInputField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      required IconData icon,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textDark, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2))
          ]),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: EdgeInsets.only(
                        bottom: maxLines > 1 ? (maxLines - 1) * 18.0 : 0),
                    decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(icon, color: AppColors.primary, size: 20)),
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textLight),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsTab(WidgetRef ref) {
    final resultAsync = ref.watch(careerGuidanceResultProvider);

    if (resultAsync == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  size: 60, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 24),
            const Text('No guidance yet',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text('Fill the form to unleash your potential.',
                style: TextStyle(
                    color: AppColors.textMedium, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    // Modern Light Cards implementation for comprehensive results...
    final primary = resultAsync.guidance.primaryCareer;

    return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(children: [
          AnimatedAppear(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 20,
                      offset: Offset(0, 8))
                ],
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.rocket_launch_rounded,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Text('Primary Career Match',
                            style: TextStyle(
                                color: AppColors.textMedium,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(primary.name,
                        style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${primary.confidencePercent}% Match',
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    Text(resultAsync.guidance.summary,
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500)),
                  ]),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Top Recommendations (Alternative careers)
          if (resultAsync.guidance.topCareerRecommendations.isNotEmpty)
            AnimatedAppear(
                delay: const Duration(milliseconds: 100),
                child: _buildSectionCard(
                    title: 'Other Strong Matches',
                    icon: Icons.lightbulb_rounded,
                    iconColor: AppColors.warning,
                    child: Column(
                        children: resultAsync.guidance.topCareerRecommendations
                            .map((career) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(children: [
                                  Expanded(
                                      child: Text(career.career,
                                          style: const TextStyle(
                                              color: AppColors.textDark,
                                              fontWeight: FontWeight.w600))),
                                  Text('${career.confidencePercent}%',
                                      style: const TextStyle(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold)),
                                ])))
                            .toList()))),

          const SizedBox(height: AppSpacing.lg),

          // All Skills Detected from Resume
          if (resultAsync.studentProfile.skillsDetected.isNotEmpty)
            AnimatedAppear(
                delay: const Duration(milliseconds: 150),
                child: _buildSectionCard(
                    title: 'All Skills from Your Resume',
                    icon: Icons.verified_rounded,
                    iconColor: const Color(0xFF6366F1),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${resultAsync.studentProfile.skillsDetected.length} skills detected',
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          _buildPillList(
                              resultAsync.studentProfile.skillsDetected,
                              const Color(0xFF6366F1)),
                        ]))),

          const SizedBox(height: AppSpacing.lg),

          AnimatedAppear(
              delay: const Duration(milliseconds: 200),
              child: _buildSectionCard(
                  title: 'Skills Analysis',
                  icon: Icons.analytics_rounded,
                  iconColor: AppColors.info,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (primary.skillsYouHave.isNotEmpty) ...[
                          const Text('Skills You Already Have:',
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildPillList(
                              primary.skillsYouHave, AppColors.success),
                          const SizedBox(height: 16),
                        ],
                        if (primary.skillGaps.isNotEmpty) ...[
                          const Text('Skill Gaps to Address:',
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildPillList(primary.skillGaps, AppColors.error),
                          const SizedBox(height: 16),
                        ],
                        if (primary.goodToHaveSkills.isNotEmpty) ...[
                          const Text('Good to Have Skills:',
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildPillList(
                              primary.goodToHaveSkills, AppColors.info),
                          const SizedBox(height: 16),
                        ],
                        if (primary.improvementAreas.isNotEmpty) ...[
                          const Text('Key Improvement Areas:',
                              style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildPillList(
                              primary.improvementAreas, AppColors.warning),
                        ]
                      ]))),

          const SizedBox(height: AppSpacing.lg),

          if (primary.recommendedCourses.isNotEmpty)
            AnimatedAppear(
                delay: const Duration(milliseconds: 300),
                child: _buildSectionCard(
                    title: 'Suggested Courses',
                    icon: Icons.school_rounded,
                    iconColor: AppColors.primary,
                    child: Column(
                        children: primary.recommendedCourses
                            .map((c) => _buildCourseItem(c, isBonus: false))
                            .toList()))),

          if (primary.recommendedCourses.isNotEmpty)
            const SizedBox(height: AppSpacing.lg),

          if (primary.bonusCourses.isNotEmpty)
            AnimatedAppear(
                delay: const Duration(milliseconds: 400),
                child: _buildSectionCard(
                    title: 'Courses for Growth',
                    icon: Icons.star_rounded,
                    iconColor: AppColors.warning,
                    child: Column(
                        children: primary.bonusCourses
                            .map((c) => _buildCourseItem(c, isBonus: true))
                            .toList()))),

          const SizedBox(height: 100),
        ]));
  }

  // Helper to get platform-specific colors and icons
  Map<String, dynamic> _getPlatformStyle(String platform) {
    final platformLower = platform.toLowerCase();
    if (platformLower.contains('coursera')) {
      return {
        'color': const Color(0xFF0056D2),
        'icon': Icons.play_circle_filled,
        'bg': const Color(0xFF0056D2).withOpacity(0.1)
      };
    } else if (platformLower.contains('udemy')) {
      return {
        'color': const Color(0xFFA435F0),
        'icon': Icons.video_library,
        'bg': const Color(0xFFA435F0).withOpacity(0.1)
      };
    } else if (platformLower.contains('edx')) {
      return {
        'color': const Color(0xFF051C3D),
        'icon': Icons.book,
        'bg': const Color(0xFF051C3D).withOpacity(0.1)
      };
    } else if (platformLower.contains('linkedin')) {
      return {
        'color': const Color(0xFF0077B5),
        'icon': Icons.people,
        'bg': const Color(0xFF0077B5).withOpacity(0.1)
      };
    } else if (platformLower.contains('youtube')) {
      return {
        'color': const Color(0xFFFF0000),
        'icon': Icons.play_arrow,
        'bg': const Color(0xFFFF0000).withOpacity(0.1)
      };
    } else {
      return {
        'color': AppColors.primary,
        'icon': Icons.book_outlined,
        'bg': AppColors.primary.withOpacity(0.1)
      };
    }
  }

  Widget _buildCourseItem(RecommendedCourse course, {required bool isBonus}) {
    final platformStyle = _getPlatformStyle(course.platform);
    return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 4))
          ],
        ),
        child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await _openCourseUrl(course.url, course.course);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Platform icon with platform color
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: platformStyle['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        platformStyle['icon'] as IconData,
                        color: platformStyle['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Course details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.course,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: platformStyle['bg'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  course.platform,
                                  style: TextStyle(
                                    color: platformStyle['color'] as Color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Gap: ${course.skill}',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Open button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  // Helper method to open course URL safely
  Future<void> _openCourseUrl(String url, String courseName) async {
    url = url.trim();

    if (url.isEmpty || url == '#') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course link not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Normalize URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);
    try {
      final canLaunch = await canLaunchUrl(uri);
      print('🔗 Course URL: $url | Can launch: $canLaunch');

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ Opened: $courseName');
      } else {
        // Fallback: try with different mode
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          print('✅ Opened (platformDefault): $courseName');
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open link'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening course: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required Color iconColor,
      required Widget child}) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5)),
          ]),
          const SizedBox(height: 16),
          child,
        ]));
  }

  Widget _buildPillList(List<String> items, Color color) {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((e) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(e,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ))
            .toList());
  }

  Widget _buildResourcesTab(BuildContext context) {
    return const Center(
        child: Text("Resources Tab",
            style: TextStyle(
                color: AppColors.textMedium, fontWeight: FontWeight.w500)));
  }
}
