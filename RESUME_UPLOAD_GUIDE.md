# 🎯 Career Guidance - Resume Upload & Backend Setup Guide

## ✅ WHAT'S NEW

### 1. **Resume File Selection Added** ✨
- Users can now select resume files from their device
- Supports: `.txt`, `.pdf`, `.doc`, `.docx`
- Resume content is extracted and sent to backend
- **Optional** - users can submit form without resume

### 2. **Backend Fix** 🔧
- Backend now accepts `resume_text` in JSON request
- No longer requires Supabase URL
- Works with local file content

### 3. **UI Improvements** 🎨
- Beautiful resume picker UI
- Shows selected filename
- Clear button to remove selection
- Updated form layout

---

## 🚀 QUICK START (3 Terminals)

### **Terminal 1: Main Backend** (Port 8000)
```powershell
cd D:\CampusGPT_2.0\backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
**Expected**: `Uvicorn running on http://0.0.0.0:8000`

### **Terminal 2: Career Guide Backend** (Port 5000) ⭐

**First Time Only - Setup:**
```powershell
cd D:\CampusGPT_2.0\Career_guide

# Generate training data (one-time)
python data/generate_dataset.py

# Train ML model (one-time, takes 1-3 minutes)
python ml/train.py

# Or run combined setup
python data/generate_dataset.py && python ml/train.py
```

**Start the service:**
```powershell
cd D:\CampusGPT_2.0\Career_guide
python app.py
```
**Expected**: `Running on http://0.0.0.0:5000`

### **Terminal 3: Flutter App**
```powershell
cd D:\CampusGPT_2.0\campusgpt_app
flutter run
```

---

## 📋 How Resume Selection Works

### User Flow
1. **Fill Form** - Enter interests, skills, goals, etc. (all required)
2. **Select Resume** (Optional)
   - Tap "Select Resume from Device"
   - Choose .txt or other supported file
   - Filename appears in form
3. **Submit** - Click "Get Guidance"
4. **Backend Processing**
   - Resume text is extracted and sent
   - ML model processes resume + Q&A
   - Returns career recommendations

### What Backend Does With Resume
```
Resume Text + Q&A Responses
    ↓
Resume Parser extracts:
  - Skills from text
  - Education degree/branch
  - CGPA (if found)
  - Internship presence
  - Projects done
    ↓
Feature Builder combines:
  - Extracted resume data
  - User Q&A responses
    ↓
ML Model predicts:
  - Top 3 career paths
  - Confidence percentages
  - Skill gaps
  - Required courses
```

---

## 📱 Updated API Request/Response

### API Request (Now with resume_text)
```json
{
  "resume_text": "John Doe, Python, SQL, Flask...",  // NEW: Resume content
  "qa_responses": {
    "interests": "AI, Data Science",
    "known_skills": "Python, SQL",
    "career_goal": "Data Scientist",
    "projects_done": "ML models",
    "education_branch": "Computer Science",
    "year_of_study": "3rd year",
    "has_internship": true,
    "self_weakness": "Statistics"
  }
}
```

### Backend Response (Same as before)
```json
{
  "status": "success",
  "student_profile": {
    "skills_detected": ["python", "sql", ...],
    "education_branch": "Computer Science",
    "education_degree": "B.Tech",
    "cgpa": 8.2,
    "has_internship": true
  },
  "guidance": {
    "top_career_recommendations": [
      { "career": "Data Scientist", "confidence_percent": 81.3 }
    ],
    "primary_career": { ... },
    "summary": "..."
  }
}
```

---

## 🧪 Test Backend (Before Running App)

### Quick Test with Python
```powershell
cd D:\CampusGPT_2.0\Career_guide
python test_backend.py
```

This verifies:
- ✅ Health endpoint working
- ✅ Career guidance endpoint working
- ✅ Response format correct

### Manual Test with curl (After starting backend)
```bash
curl -X POST http://localhost:5000/api/generate-guidance ^
  -H "Content-Type: application/json" ^
  -d "{\"resume_text\": \"Python, SQL, Flask developer\", \"qa_responses\": {\"interests\": \"AI\", \"known_skills\": \"Python\", \"career_goal\": \"Engineer\", \"projects_done\": \"None\", \"education_branch\": \"CS\", \"year_of_study\": \"3\", \"has_internship\": false, \"self_weakness\": \"None\"}}"
```

---

## 🐛 Troubleshooting

### ❌ Error: "Provide either resume_url or resume_text"
**Cause**: Flutter app didn't send resume file content
**Fix**:
1. Check Terminal 3 (Flutter) shows: `📄 Reading resume file...`
2. Make sure text file is not empty
3. Try uploading a .txt file first for testing

### ❌ Error: "Connection refused" on port 5000
**Fix**:
1. Verify Terminal 2 is running with `python app.py`
2. Check: `curl http://localhost:5000/health`
3. Should return: `{"status": "ok", "service": "Career Guidance API"}`

### ❌ Error: "career_classifier.pkl not found"
**Fix**:
```powershell
cd D:\CampusGPT_2.0\Career_guide
python ml/train.py
```
Wait for training to complete (1-3 minutes)

### ❌ "Cannot read file: File not found"
**Cause**: Flutter app path is wrong
**Fix**:
1. Use `.txt` files for initial testing
2. Check file permissions
3. Try absolute path instead of relative

### ❌ First request takes 20+ seconds
**This is NORMAL!** ✅
- ML model startup: 10-15 seconds (first time only)
- Resume parsing: 2-5 seconds
- Model inference: 3-5 seconds
- Total: 15-25 seconds (first request)
- Next requests: 5-10 seconds
- Max timeout: 180 seconds

---

## 📁 Updated Files (What Changed)

| File | Change | Status |
|---|---|---|
| `lib/models/career_guidance_model.dart` | Added `resumeText` field | ✅ Updated |
| `lib/services/career_guidance_service.dart` | Added file reading + `resumeFilePath` param | ✅ Updated |
| `lib/screens/career_path_screen.dart` | Added resume file picker UI | ✅ Updated |
| `Career_guide/test_backend.py` | NEW test script | ✅ Created |

All other files remain unchanged ✅

---

## 🎯 Complete Workflow

```
User App (Terminal 3)
    ↓ (fill form + select resume)
    ↓
Send: resume_text + qa_responses
    ↓
Career Guide Backend (Terminal 2)
    ↓ (parse resume + extract features)
    ↓
ML Model
    ↓ (predict careers + skills)
    ↓
Return: guidance response
    ↓
Display: Results in app
```

---

## ✨ Features Implemented

- ✅ File picker for resume selection
- ✅ Resume text extraction (local files)
- ✅ Beautiful UI for file selection
- ✅ Filename display in form
- ✅ Remove file button
- ✅ Optional resume (form works without it)
- ✅ Backend accepts resume_text
- ✅ ML model processes resume + Q&A
- ✅ Full error handling
- ✅ Test script for backend verification

---

## 🚀 Next Steps

1. **Start all 3 terminals** in order
2. **Test Backend** with `python test_backend.py`
3. **Open Flutter App** and navigate to Career Path
4. **Fill Form** (all 8 Q&A fields required)
5. **Select Resume** (optional - just tap button)
6. **Click "Get Guidance"** and wait
7. **View Results** in Results tab

---

## 📞 Support

**Common Issues & Solutions:**

1. **Backend not responding?**
   - Terminal 2 running? Type: `python app.py`
   - Port 5000 in use? Check with: `netstat -ano | findstr :5000`

2. **Resume file not being read?**
   - Use `.txt` file for testing
   - Check file exists and has content
   - Look at Flutter logs for: `📄 Reading resume file...`

3. **ML model not found?**
   - Run: `python ml/train.py` in Career_guide folder
   - Wait for completion
   - Files created: `ml/career_classifier.pkl`

4. **Slow response?**
   - First request: Normal! 15-25 seconds
   - Next requests: 5-10 seconds
   - Check logs for `[TEST INFERENCE]` messages

---

**Status**: ✅ **READY TO TEST**
**Last Updated**: March 2026
**Version**: 2.0 (Resume Upload)
