/// Career Guidance Models
/// Handles all data structures for career guidance API responses

class CareerGuidanceRequest {
  final String? resumeUrl;
  final String? resumeText;
  final QAResponses qaResponses;

  CareerGuidanceRequest({
    this.resumeUrl,
    this.resumeText,
    required this.qaResponses,
  });

  Map<String, dynamic> toJson() {
    return {
      if (resumeUrl != null) 'resume_url': resumeUrl,
      if (resumeText != null) 'resume_text': resumeText,
      'qa_responses': qaResponses.toJson(),
    };
  }
}

class QAResponses {
  final String interests;
  final String knownSkills;
  final String careerGoal;
  final String projectsDone;
  final String educationBranch;
  final String yearOfStudy;
  final bool hasInternship;
  final String selfWeakness;
  final String? preferredWork;

  QAResponses({
    required this.interests,
    required this.knownSkills,
    required this.careerGoal,
    required this.projectsDone,
    required this.educationBranch,
    required this.yearOfStudy,
    required this.hasInternship,
    required this.selfWeakness,
    this.preferredWork,
  });

  Map<String, dynamic> toJson() {
    return {
      'interests': interests,
      'known_skills': knownSkills,
      'career_goal': careerGoal,
      'projects_done': projectsDone,
      'education_branch': educationBranch,
      'year_of_study': yearOfStudy,
      'has_internship': hasInternship,
      'self_weakness': selfWeakness,
      if (preferredWork != null) 'preferred_work': preferredWork,
    };
  }
}

class CareerGuidanceResponse {
  final String status;
  final StudentProfile studentProfile;
  final Guidance guidance;

  CareerGuidanceResponse({
    required this.status,
    required this.studentProfile,
    required this.guidance,
  });

  factory CareerGuidanceResponse.fromJson(Map<String, dynamic> json) {
    return CareerGuidanceResponse(
      status: json['status'] ?? 'success',
      studentProfile: StudentProfile.fromJson(json['student_profile'] ?? {}),
      guidance: Guidance.fromJson(json['guidance'] ?? {}),
    );
  }
}

class StudentProfile {
  final List<String> skillsDetected;
  final String educationBranch;
  final String educationDegree;
  final double cgpa;
  final bool hasInternship;

  StudentProfile({
    required this.skillsDetected,
    required this.educationBranch,
    required this.educationDegree,
    required this.cgpa,
    required this.hasInternship,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      skillsDetected: List<String>.from(json['skills_detected'] ?? []),
      educationBranch: json['education_branch'] ?? 'Not specified',
      educationDegree: json['education_degree'] ?? 'B.Tech',
      cgpa: (json['cgpa'] ?? 0.0).toDouble(),
      hasInternship: json['has_internship'] ?? false,
    );
  }
}

class Guidance {
  final List<CareerRecommendation> topCareerRecommendations;
  final PrimaryCareer primaryCareer;
  final String summary;

  Guidance({
    required this.topCareerRecommendations,
    required this.primaryCareer,
    required this.summary,
  });

  factory Guidance.fromJson(Map<String, dynamic> json) {
    return Guidance(
      topCareerRecommendations: (json['top_career_recommendations'] as List?)
              ?.map((e) => CareerRecommendation.fromJson(e))
              .toList() ??
          [],
      primaryCareer: PrimaryCareer.fromJson(json['primary_career'] ?? {}),
      summary: json['summary'] ?? '',
    );
  }
}

class CareerRecommendation {
  final String career;
  final double confidencePercent;

  CareerRecommendation({
    required this.career,
    required this.confidencePercent,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      career: json['career'] ?? 'Unknown',
      confidencePercent: (json['confidence_percent'] ?? 0.0).toDouble(),
    );
  }
}

class PrimaryCareer {
  final String name;
  final double confidencePercent;
  final List<String> skillsYouHave;
  final List<String> skillGaps;
  final List<String> goodToHaveSkills;
  final List<String> improvementAreas;
  final List<RecommendedCourse> recommendedCourses;
  final List<RecommendedCourse> bonusCourses;

  PrimaryCareer({
    required this.name,
    required this.confidencePercent,
    required this.skillsYouHave,
    required this.skillGaps,
    required this.goodToHaveSkills,
    required this.improvementAreas,
    required this.recommendedCourses,
    List<RecommendedCourse>? bonusCourses,
  }) : bonusCourses = bonusCourses ?? [];

  // Get all courses combined (required + bonus)
  List<RecommendedCourse> getAllCourses() {
    return <RecommendedCourse>[
      ...?recommendedCourses,
      ...?bonusCourses,
    ].where((course) => course != null).cast<RecommendedCourse>().toList();
  }

  factory PrimaryCareer.fromJson(Map<String, dynamic> json) {
    final recommended = (json['recommended_courses'] as List?)
            ?.map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final bonus = (json['bonus_courses_for_growth'] as List?)
            ?.map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PrimaryCareer(
      name: json['name'] as String? ?? 'Unknown',
      confidencePercent:
          ((json['confidence_percent'] ?? 0.0) as num).toDouble(),
      skillsYouHave: List<String>.from(json['skills_you_have'] as List? ?? []),
      skillGaps: List<String>.from(json['skill_gaps'] as List? ?? []),
      goodToHaveSkills:
          List<String>.from(json['good_to_have_skills'] as List? ?? []),
      improvementAreas:
          List<String>.from(json['improvement_areas'] as List? ?? []),
      recommendedCourses: recommended,
      bonusCourses: bonus,
    );
  }
}

class RecommendedCourse {
  final String skill;
  final String course;
  final String platform;
  final String url;

  RecommendedCourse({
    required this.skill,
    required this.course,
    required this.platform,
    required this.url,
  });

  factory RecommendedCourse.fromJson(Map<String, dynamic> json) {
    return RecommendedCourse(
      skill: json['skill'] ?? 'Unknown',
      course: json['course'] ?? 'Unknown',
      platform: json['platform'] ?? 'Unknown',
      url: json['url'] ?? '#',
    );
  }
}
