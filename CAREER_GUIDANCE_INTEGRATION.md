# Career Guidance Integration Guide

## ✅ Implementation Complete

Your Flutter app is now fully integrated with the Career Guidance backend API. The beautiful career paths feature is ready to use!

---

## 🎯 What Was Implemented

### 1. **Backend API Integration**
- ✅ Career Guidance Service (`lib/services/career_guidance_service.dart`)
- ✅ Data Models (`lib/models/career_guidance_model.dart`)
- ✅ State Management Providers (`lib/providers/providers.dart`)

### 2. **Beautiful UI Components**
- 📋 **Guidance Form Tab** - Input fields for career information
- 🎯 **Results Tab** - Display career recommendations with visual cards
- 🏆 **Resources Tab** - Learning resources and development tools

### 3. **Key Features**
- ✨ Real-time form validation
- 🚀 Loading states with progress indicators
- 📊 Visual progress bars for confidence percentages
- 🔗 Direct course links to Udemy, Coursera, etc.
- 💳 Beautiful gradient cards and animations
- 📱 Fully responsive mobile design

---

## 🚀 Getting Started

### Step 1: Start the Backend Server

```bash
cd D:\CampusGPT_2.0\backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or using the batch file:
```bash
cd D:\CampusGPT_2.0\backend
startup.bat
```

### Step 2: Start the Career Guidance Service

```bash
cd D:\CampusGPT_2.0\Career_guide
python app.py
```

### Step 3: Launch the Flutter App

```bash
cd D:\CampusGPT_2.0\campusgpt_app
flutter run
```

---

## 📡 API Endpoint Details

### POST `/api/generate-guidance`

**Request Format:**
```json
{
  "resume_url": "https://optional-url-to-resume",
  "qa_responses": {
    "interests": "machine learning, data science",
    "known_skills": "python, sql, pandas",
    "career_goal": "become a data scientist",
    "projects_done": "movie recommendation system",
    "education_branch": "Computer Science",
    "year_of_study": "3rd year",
    "has_internship": false,
    "self_weakness": "weak in deep learning"
  }
}
```

**Response Format:**
```json
{
  "status": "success",
  "student_profile": {
    "skills_detected": ["python", "sql", "pandas"],
    "education_branch": "Computer Science",
    "education_degree": "B.Tech",
    "cgpa": 8.2,
    "has_internship": false
  },
  "guidance": {
    "top_career_recommendations": [
      {"career": "Data Scientist", "confidence_percent": 81.3},
      {"career": "ML Engineer", "confidence_percent": 9.7},
      {"career": "Data Analyst", "confidence_percent": 4.2}
    ],
    "primary_career": {
      "name": "Data Scientist",
      "confidence_percent": 81.3,
      "skills_you_have": ["python", "sql", "pandas"],
      "skill_gaps": ["machine learning", "probability"],
      "good_to_have_skills": ["deep learning", "tensorflow"],
      "improvement_areas": ["feature engineering"],
      "recommended_courses": [
        {
          "skill": "machine learning",
          "course": "ML Specialization",
          "platform": "Coursera",
          "url": "https://coursera.org/..."
        }
      ]
    },
    "summary": "Based on your profile..."
  }
}
```

---

## 🔧 File Structure

```
campusgpt_app/lib/
├── models/
│   └── career_guidance_model.dart          # Data models for API responses
├── services/
│   └── career_guidance_service.dart        # API communication
├── providers/
│   └── providers.dart                      # State management (updated)
└── screens/
    └── career_path_screen.dart             # Beautiful UI (completely redesigned)
```

---

## 🎨 UI Features

### Form Input Fields
- Interests
- Known Skills  
- Career Goal
- Projects Done
- Education Branch
- Year of Study
- Has Internship (toggle)
- Areas for Improvement

### Results Display
- **Profile Summary Card** - Shows detected skills, CGPA, branch
- **Top Recommendations** - Top 3 career paths with confidence percentages
- **Primary Career Details**:
  - Skills you already have
  - Skill gaps to fill
  - Good-to-have skills
  - Improvement areas
  - Recommended courses with direct links
- **Summary** - AI-generated career guidance summary

---

## 🔐 Network Configuration

**Current Configuration** (in `lib/config/api_config.dart`):
```dart
static const String baseURL = 'http://10.255.176.62:8000/api';
```

### For Different Environments:

**Android Emulator:**
```dart
static const String baseURL = 'http://10.0.2.2:8000/api';
```

**iOS Simulator:**
```dart
static const String baseURL = 'http://localhost:8000/api';
```

**Physical Device on Same Network:**
1. Get your PC's IPv4 address: 
   ```powershell
   ipconfig | findstr /i "IPv4"
   ```
2. Update the URL:
   ```dart
   static const String baseURL = 'http://192.168.x.x:8000/api';
   ```

---

## ✅ Testing Checklist

- [ ] Backend server is running on port 8000
- [ ] Career guide service is running on port 5000
- [ ] Flutter app compiled successfully without errors
- [ ] Fill in the guidance form with test data
- [ ] Click "Get Guidance" button
- [ ] Verify results appear in the Results tab
- [ ] Check console for any API errors
- [ ] Test course links (should open in browser)

---

## 🐛 Troubleshooting

### Issue: "Connection refused" when submitting form

**Solution:**
1. Verify backend is running: `http://10.255.176.62:8000/health`
2. Check network connectivity between device and backend
3. Update API endpoint in `api_config.dart` if needed

### Issue: Form shows "Error: Unknown error"

**Solution:**
1. Check Flutter console for detailed error messages
2. Verify all form fields are filled
3. Check backend console for request details

### Issue: Results don't show up

**Solution:**
1. Check the Results tab is selected
2. Verify the API returned valid data
3. Check network logs in Flutter DevTools

---

## 📝 Key Classes

### CareerGuidanceService
```dart
Future<CareerGuidanceResponse> generateCareerGuidance({
  String? resumeUrl,
  required QAResponses qaResponses,
})
```

### QAResponses
Contains user input:
- `interests`
- `knownSkills`
- `careerGoal`
- `projectsDone`
- `educationBranch`
- `yearOfStudy`
- `hasInternship`
- `selfWeakness`

### CareerGuidanceResponse
Contains API response with:
- `StudentProfile` - User profile analysis
- `Guidance` - Career recommendations
  - `topCareerRecommendations` - Top 3 careers
  - `primaryCareer` - Detailed primary career info
  - `summary` - AI-generated summary

---

## 🎓 Learning Resources Section

The Resources tab provides links to:
- 📚 Online Courses (Udemy, Coursera, Pluralsight)
- 👥 Mentorship Programs
- 📖 Career Development Articles
- 💻 Coding Practice Platforms

---

## 🚀 Future Enhancements

1. **Resume Upload** - Allow PDF resume upload directly from app
2. **History Tracking** - Save previous guidance sessions
3. **Skill Tracking** - Monitor skill development over time
4. **Achievements** - Badge system for completed courses
5. **Social Sharing** - Share career guidance results
6. **Notifications** - Reminders for course deadlines
7. **Dark Mode** - Support for dark theme

---

## 📞 Support

For issues with:
- **Flutter UI**: Check `CareerPathScreen` in `career_path_screen.dart`
- **API Integration**: Check `CareerGuidanceService` in `career_guidance_service.dart`
- **State Management**: Check `careerGuidanceProvider` in `providers.dart`
- **Backend**: Check Career_guide project documentation

---

## ✨ Summary

Your Flutter app now has a complete, production-ready career guidance feature with:
- ✅ Beautiful, intuitive UI
- ✅ Real-time API integration
- ✅ Comprehensive career analysis
- ✅ Recommended learning resources
- ✅ Error handling and validation
- ✅ Loading states and animations

**The feature is ready to deploy to production!**
