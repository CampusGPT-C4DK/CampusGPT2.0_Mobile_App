import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                  _buildTabButton('Resume', 0),
                  const SizedBox(width: AppSpacing.md),
                  _buildTabButton('Jobs', 1),
                  const SizedBox(width: AppSpacing.md),
                  _buildTabButton('Interview', 2),
                  const SizedBox(width: AppSpacing.md),
                  _buildTabButton('Guide', 3),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResumeTab(context),
                _buildJobsTab(context),
                _buildInterviewTab(context),
                _buildGuideTab(context),
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

  Widget _buildResumeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Resume Builder'),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureCard(
            context,
            icon: Icons.description_rounded,
            title: 'Create New Resume',
            description: 'Build a professional resume with templates',
            onTap: () => _showNotImplemented(context, 'Resume Builder'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.edit_rounded,
            title: 'Edit Resume',
            description: 'Update your existing resume',
            onTap: () => _showNotImplemented(context, 'Resume Editor'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.download_rounded,
            title: 'Download Resume',
            description: 'Export as PDF or Word document',
            onTap: () => _showNotImplemented(context, 'Download Resume'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.check_circle_rounded,
            title: 'Resume Review',
            description: 'Get AI feedback on your resume',
            onTap: () => _showNotImplemented(context, 'Resume Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Job Search'),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureCard(
            context,
            icon: Icons.search_rounded,
            title: 'Search Jobs',
            description: 'Find jobs matching your profile',
            onTap: () => _showNotImplemented(context, 'Job Search'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.bookmark_rounded,
            title: 'Saved Jobs',
            description: 'View your bookmarked job listings',
            onTap: () => _showNotImplemented(context, 'Saved Jobs'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.trending_up_rounded,
            title: 'Job Recommendations',
            description: 'Get personalized job suggestions',
            onTap: () => _showNotImplemented(context, 'Job Recommendations'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.send_rounded,
            title: 'Apply to Jobs',
            description: 'Track your job applications',
            onTap: () => _showNotImplemented(context, 'Job Applications'),
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Interview Preparation'),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureCard(
            context,
            icon: Icons.school_rounded,
            title: 'Interview Questions',
            description: 'Practice common interview questions',
            onTap: () => _showNotImplemented(context, 'Interview Questions'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.videocam_rounded,
            title: 'Mock Interviews',
            description: 'Simulate real interview experience',
            onTap: () => _showNotImplemented(context, 'Mock Interviews'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.tips_and_updates_rounded,
            title: 'Interview Tips',
            description: 'Learn interview best practices',
            onTap: () => _showNotImplemented(context, 'Interview Tips'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.assignment_rounded,
            title: 'Technical Skills',
            description: 'Improve coding and technical skills',
            onTap: () => _showNotImplemented(context, 'Technical Skills'),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Career Guidance'),
          const SizedBox(height: AppSpacing.lg),
          _buildFeatureCard(
            context,
            icon: Icons.map_rounded,
            title: 'Career Roadmap',
            description: 'Explore different career paths',
            onTap: () => _showNotImplemented(context, 'Career Roadmap'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.school_rounded,
            title: 'Learning Resources',
            description: 'Access courses and tutorials',
            onTap: () => _showNotImplemented(context, 'Learning Resources'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.people_rounded,
            title: 'Mentorship',
            description: 'Connect with mentors and professionals',
            onTap: () => _showNotImplemented(context, 'Mentorship'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFeatureCard(
            context,
            icon: Icons.article_rounded,
            title: 'Career Articles',
            description: 'Read articles on career development',
            onTap: () => _showNotImplemented(context, 'Career Articles'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return AnimatedAppear(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return AnimatedAppear(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gradient,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMedium,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon! 🚀'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
