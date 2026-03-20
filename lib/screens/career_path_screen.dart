import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
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

    // Initialize controllers
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
    // Validate form
    if (_interestsController.text.isEmpty ||
        _knownSkillsController.text.isEmpty ||
        _careerGoalController.text.isEmpty ||
        _projectsDoneController.text.isEmpty ||
        _educationBranchController.text.isEmpty ||
        _yearOfStudyController.text.isEmpty ||
        _selfWeaknessController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Set loading state
    ref.read(careerGuidanceLoadingProvider.notifier).state = true;

    try {
      // Create QA responses
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

      // Call service
      final service = ref.read(careerGuidanceServiceProvider);
      final response = await service.generateCareerGuidance(
        resumeFilePath: _selectedResumeFilePath,
        qaResponses: qaResponses,
      );

      // Store result
      ref.read(careerGuidanceResultProvider.notifier).setResult(response);

      // Show success and navigate to results
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Career guidance generated successfully!')),
        );
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      print('❌ Error: $e');
    } finally {
      ref.read(careerGuidanceLoadingProvider.notifier).state = false;
    }
  }

  void _resetForm() {
    _interestsController.clear();
    _knownSkillsController.clear();
    _careerGoalController.clear();
    _projectsDoneController.clear();
    _educationBranchController.clear();
    _yearOfStudyController.clear();
    _selfWeaknessController.clear();
    _hasInternship = false;
    _selectedResumeFilePath = null;
    _selectedResumeFileName = null;
    setState(() {});
  }

  Future<void> _pickResumeFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
        withData: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedResumeFilePath = file.path;
          _selectedResumeFileName = file.name;
        });
        print('📄 Selected resume: $_selectedResumeFileName');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resume selected: $_selectedResumeFileName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        title: const Text('Career Path'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton('📋 Guidance', 0),
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
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border:
              isActive ? null : Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isActive ? Colors.white : AppColors.textDark,
                fontWeight: FontWeight.bold,
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
          _buildSectionTitle('Career Guidance Form', '📝'),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fill in your details to get personalized career recommendations',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMedium),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Form Fields
          _buildInputField(
            label: 'Your Interests',
            hint: 'e.g., Machine Learning, Web Development',
            controller: _interestsController,
            icon: Icons.favorite_border_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Known Skills',
            hint: 'e.g., Python, JavaScript, SQL',
            controller: _knownSkillsController,
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Career Goal',
            hint: 'e.g., Become a Data Scientist',
            controller: _careerGoalController,
            icon: Icons.flag_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Projects Done',
            hint: 'Describe your notable projects',
            controller: _projectsDoneController,
            icon: Icons.work_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Education Branch',
            hint: 'e.g., Computer Science, Engineering',
            controller: _educationBranchController,
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Year of Study',
            hint: 'e.g., 3rd Year, Junior',
            controller: _yearOfStudyController,
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Resume File Picker (Optional)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.attach_file_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Resume (Optional)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_selectedResumeFileName != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppColors.success),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  _selectedResumeFileName!,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedResumeFilePath = null;
                              _selectedResumeFileName = null;
                            });
                          },
                          child: Icon(Icons.close_rounded,
                              color: AppColors.error, size: 20),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickResumeFile,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Select Resume from Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Supported: .txt, .pdf, .doc, .docx',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textMedium),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Internship Toggle
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.business_rounded, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Have internship experience?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                Switch(
                  value: _hasInternship,
                  onChanged: (value) {
                    setState(() => _hasInternship = value);
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildInputField(
            label: 'Your Weakness',
            hint: 'Areas you want to improve in',
            controller: _selfWeaknessController,
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _resetForm(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.bgDark,
                    foregroundColor: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _submitForm(ref),
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.rocket_launch_rounded),
                  label: Text(isLoading ? 'Generating...' : 'Get Guidance'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildResultsTab(WidgetRef ref) {
    final resultAsync = ref.watch(careerGuidanceResultProvider);

    if (resultAsync == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: AppColors.textLight),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No guidance yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Fill the form to get your career guidance',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMedium),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionTitle('Your Career Guidance', '🎯'),
          const SizedBox(height: AppSpacing.xl),

          // Student Profile Card
          _buildStudentProfileCard(resultAsync.studentProfile),
          const SizedBox(height: AppSpacing.xl),

          // Top Recommendations
          _buildTopRecommendationsCard(resultAsync.guidance),
          const SizedBox(height: AppSpacing.xl),

          // Primary Career Details
          _buildPrimaryCareersCard(resultAsync.guidance.primaryCareer),
          const SizedBox(height: AppSpacing.xl),

          // Summary
          _buildSummaryCard(resultAsync.guidance.summary),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildResourcesTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Learning Resources', '🏆'),
          const SizedBox(height: AppSpacing.lg),
          _buildResourceCard(
            icon: Icons.school_rounded,
            title: 'Online Courses',
            description: 'Access Udemy, Coursera, and other platforms',
            color: const Color(0xFF667eea),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          _buildResourceCard(
            icon: Icons.people_rounded,
            title: 'Mentorship',
            description: 'Connect with industry professionals',
            color: const Color(0xFF2563EB),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          _buildResourceCard(
            icon: Icons.trending_up_rounded,
            title: 'Career Articles',
            description: 'Read curated articles on career development',
            color: const Color(0xFF10B981),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          _buildResourceCard(
            icon: Icons.code_rounded,
            title: 'Coding Practice',
            description: 'Improve your technical skills',
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.bgDark,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return AnimatedAppear(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(StudentProfile profile) {
    return AnimatedAppear(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C51BF), Color(0xFF5A67D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Profile Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProfileField('Degree', profile.educationDegree),
                _buildProfileField('Branch', profile.educationBranch),
                _buildProfileField('CGPA', profile.cgpa.toString()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProfileField(
                    'Internship', profile.hasInternship ? 'Yes ✓' : 'No'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Skills Detected',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: profile.skillsDetected
                  .map(
                    (skill) => Chip(
                      label: Text(
                        skill,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: const Color(0xFF2D3748).withOpacity(0.7),
                      side: const BorderSide(
                        color: Colors.white54,
                        width: 1.5,
                      ),
                      elevation: 2,
                      shadowColor: Colors.black26,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRecommendationsCard(Guidance guidance) {
    return AnimatedAppear(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Career Recommendations',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...guidance.topCareerRecommendations.asMap().entries.map((entry) {
              final index = entry.key;
              final rec = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index < guidance.topCareerRecommendations.length - 1
                        ? AppSpacing.md
                        : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              rec.career,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Text(
                          '${rec.confidencePercent.toStringAsFixed(1)}%',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: rec.confidencePercent / 100,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          rec.confidencePercent > 70
                              ? AppColors.success
                              : rec.confidencePercent > 40
                                  ? AppColors.warning
                                  : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCareersCard(PrimaryCareer career) {
    return AnimatedAppear(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Career Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Primary Career Path',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        '${career.confidencePercent.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  career.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Skills You Have
          _buildSkillsSection(
            'Skills You Have ✓',
            career.skillsYouHave,
            Colors.green[50]!,
            AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Skill Gaps
          _buildSkillsSection(
            'Skill Gaps to Fill',
            career.skillGaps,
            Colors.red[50]!,
            AppColors.error,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Good to Have Skills
          _buildSkillsSection(
            'Good to Have Skills',
            career.goodToHaveSkills,
            Colors.blue[50]!,
            AppColors.info,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Improvement Areas
          _buildSkillsSection(
            'Improvement Areas',
            career.improvementAreas,
            Colors.orange[50]!,
            AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recommended Courses (all courses including bonus)
          if (career.getAllCourses().isNotEmpty) ...[
            _buildCoursesSection(career.getAllCourses()),
            const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillsSection(
      String title, List<String> skills, Color bgColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (skills.isEmpty)
            Text(
              'No items',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMedium),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: accentColor.withOpacity(0.5)),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCoursesSection(List<RecommendedCourse> courses) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Courses',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...courses.asMap().entries.map((entry) {
            final course = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: entry.key < courses.length - 1 ? AppSpacing.md : 0),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.skill,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.textMedium,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                course.course,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            course.platform,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final Uri courseUri = Uri.parse(course.url);

                            // Directly try to open with in-app webview
                            // (works on all devices without needing external browser)
                            bool launched = await launchUrl(
                              courseUri,
                              mode: LaunchMode.inAppWebView,
                            );

                            if (!launched) {
                              // If in-app webview fails, try external app
                              if (await canLaunchUrl(courseUri)) {
                                await launchUrl(
                                  courseUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                // Last resort: show URL to user
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                            'Unable to open link automatically'),
                                        const SizedBox(height: 8),
                                        SelectableText(
                                          course.url,
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 8),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening course: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('View Course'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String summary) {
    return AnimatedAppear(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedAppear(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMedium),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
