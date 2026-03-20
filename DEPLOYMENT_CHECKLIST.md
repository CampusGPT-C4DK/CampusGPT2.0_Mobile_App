# ✅ DEPLOYMENT CHECKLIST - Flutter Career Guidance

## 📋 Pre-Deployment Checklist

### Backend Setup (Career Guide Flask)
- [ ] Flask server tested: `python app.py` runs without errors
- [ ] Foreign key constraint fixed in Supabase (see REAL_FIX_FOREIGN_KEY.md)
- [ ] Database connection verified in logs
- [ ] POST /api/generate-guidance endpoint tested
- [ ] GET /health endpoint returns 200
- [ ] CORS enabled for Flutter app origin
- [ ] Error handling working (test with invalid data)

### Flutter App Code
- [ ] All 5 new files created:
  - [x] `lib/models/career_guidance_model.dart`
  - [x] `lib/services/career_guidance_service.dart`
  - [x] `lib/providers/career_guidance_provider.dart`
  - [x] `lib/screens/career_form_and_guidance_screen.dart`
  - [x] `lib/screens/career_guidance_dashboard.dart`
- [ ] Code has no syntax errors
- [ ] All imports are correct
- [ ] No unused imports or variables

### Dependencies
- [ ] pubspec.yaml updated with:
  ```yaml
  dio: ^5.3.0
  url_launcher: ^6.1.0
  ```
- [ ] `flutter pub get` completed successfully
- [ ] No dependency conflicts
- [ ] iOS/Android minimum SDK versions compatible

### Configuration
- [ ] baseUrl updated to PC IP in CareerGuidanceService
  ```dart
  static const String baseUrl = 'http://192.168.1.100:5000';
  ```
- [ ] Route added to app_router.dart
- [ ] Navigation to career guidance screen tested
- [ ] Resume URL configured (or using demo URL)

### Network
- [ ] PC IP found: `ipconfig`
- [ ] Phone/emulator can ping PC IP
- [ ] Flask server accessible from phone: can reach http://IP:5000/health
- [ ] No firewall blocking port 5000
- [ ] WiFi/USB connection stable

### Permissions (iOS & Android)
- [ ] Android: Added INTERNET permission to AndroidManifest.xml
- [ ] iOS: (Optional) Added NSLocalNetworkUsageDescription to Info.plist
- [ ] All platform-specific configurations done

### Testing
- [ ] Form renders correctly on target device
- [ ] Form fields are interactive
- [ ] Submit button enabled after filling required fields
- [ ] Loading spinner shows during request
- [ ] Error state displays if connection fails
- [ ] Success state shows beautiful dashboard
- [ ] Course links open in browser
- [ ] "Get New Guidance" button returns to form

---

## 🚀 Deployment Steps

### Step 1: Prepare Flutter App
```bash
cd d:\CampusGPT_2.0\campusgpt_app

# Update dependencies
flutter pub get
flutter pub upgrade

# Check for errors
flutter analyze

# Test build
flutter build apk  # For Android
flutter build ios  # For iOS
```

### Step 2: Start Flask Backend
```bash
cd d:\CampusGPT_2.0\career_guide

# Activate environment (if using venv)
python -m venv venv
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
python app.py
```

Expected output:
```
✅ Successfully connected to Supabase!
 * Running on http://0.0.0.0:5000
 * Debug mode: on
```

### Step 3: Run Flutter App
```bash
flutter run

# Or specific device:
flutter run -d android
flutter run -d iphone
```

### Step 4: Test Navigation
```dart
// Navigate to career guidance
context.push('/career-guidance');
// OR
context.goNamed('careerGuidance');
```

### Step 5: Test Form Submission
1. Fill all required fields
2. Check submit button is enabled
3. Click "Get Career Guidance"
4. Verify loading spinner appears
5. Wait 6-10 seconds
6. Verify dashboard displays
7. Test course links
8. Test "Get New Guidance" button

---

## 🧪 Testing Scenarios

### Scenario 1: Happy Path
```
Input:
  Interests: "Machine Learning, Data Science"
  Skills: "Python, SQL, TensorFlow"
  Career Goal: "Data Scientist"
  Projects: "Movie recommendation system"
  Branch: "Computer Science"
  Year: "3"
  Internship: Yes
  Weakness: "Deep Learning"

Expected:
  ✅ Form validates
  ✅ Loading spinner shows (6-10s)
  ✅ Dashboard displays
  ✅ Primary career: Data Scientist (90%+)
  ✅ Top 3 careers shown with progress bars
  ✅ Skill gaps displayed in red
  ✅ Courses with links functional
```

### Scenario 2: Missing Required Field
```
Input:
  Interests: "" (empty)
  Skills: "Python"
  Career Goal: "Data Scientist"
  
Expected:
  ✅ Submit button disabled
  ✅ No API call made
  ✅ Error not shown yet
  ✅ Button becomes enabled when filled
```

### Scenario 3: Network Error
```
Setup:
  - Disconnect WiFi or turn off Flask server
  - Try to submit form

Expected:
  ✅ Shows "Connection refused" error
  ✅ "Try Again" button appears
  ✅ User can reconnect and retry
```

### Scenario 4: Invalid Response
```
Setup:
  - Modify resume_url to invalid URL
  - Send form

Expected:
  ✅ Error displayed on screen
  ✅ Stack trace in Flutter logs
  ✅ User can fix and retry
```

### Scenario 5: Course Link
```
Steps:
  1. View recommended courses
  2. Tap "View Course" on any course
  
Expected:
  ✅ Browser opens
  ✅ Coursera/Udemy/etc page loads
  ✅ User can enroll or preview
```

---

## 📊 Performance Benchmarks

| Metric | Expected | Actual |
|--------|----------|--------|
| Form load time | <1s | ☐ |
| Submit button response | <100ms | ☐ |
| API request time | 6-10s | ☐ |
| Loading spinner visible | Yes | ☐ |
| Dashboard render | <1s | ☐ |
| Course link open | 1-2s | ☐ |

---

## 🔍 Debugging Guide

### If Form Doesn't Display
```
Check:
1. Route correctly added to app_router.dart
2. Import statement for CareerFormAndGuidanceScreen
3. Flutter analysis passes (flutter analyze)
4. Hot reload/restart app
```

### If Submit Button Disabled
```
Check:
1. All required fields filled
2. Form state properly initialized
3. Provider setup correct
4. No console errors
```

### If API Request Fails
```
Check Flutter Logs:
1. BaseUrl correct (IP + :5000)
2. Phone can ping PC IP
3. Flask server running
4. Network connectivity
5. Check DioException message

Check Flask Logs:
1. Request logged in console
2. No errors during processing
3. Response generated
```

### If Dashboard Doesn't Display
```
Check:
1. API response is valid JSON
2. CareerGuidanceResponse parsing works
3. Guidance data is not null
4. Dashboard widgets render
```

### If Course Links Don't Work
```
Check:
1. url_launcher package installed
2. URLs are valid (contain http/https)
3. Platform permissions granted
4. Browser available on device
```

---

## 🔐 Production Checklist

### Security
- [ ] Disable debug mode: `flutter build release`
- [ ] Remove logging from production
- [ ] Validate all user inputs
- [ ] Use HTTPS in production (not HTTP)
- [ ] Store sensitive data encrypted
- [ ] Implement rate limiting on backend
- [ ] Add authentication if needed

### Performance
- [ ] Enable ProGuard/R8 (Android)
- [ ] Remove debug symbols (iOS)
- [ ] Optimize images
- [ ] Cache API responses
- [ ] Test on slow networks (3G)
- [ ] Monitor memory usage
- [ ] Test with large datasets

### Monitoring
- [ ] Add error tracking (Sentry, Firebase)
- [ ] Log API requests and responses
- [ ] Monitor crash rates
- [ ] Track user behavior
- [ ] Set up alerts for errors
- [ ] Monitor backend performance

### Documentation
- [ ] API documentation complete
- [ ] Code comments added
- [ ] Setup guide finalized
- [ ] Troubleshooting guide updated
- [ ] User guide created
- [ ] Release notes prepared

---

## 📱 Device Testing

### Android Testing
- [ ] Test on real Android device
- [ ] Test on Android emulator
- [ ] Test with different OS versions
- [ ] Test with different screen sizes
- [ ] Test on slow network
- [ ] Test app permissions
- [ ] Test app lifecycle (minimize, resume, close)

### iOS Testing
- [ ] Test on real iPhone/iPad
- [ ] Test on iOS simulator
- [ ] Test with different OS versions
- [ ] Test with different screen sizes
- [ ] Test on slow network
- [ ] Test app permissions
- [ ] Test app lifecycle

### Tablet Testing
- [ ] Test responsive design
- [ ] Test button sizes/spacing
- [ ] Test landscape orientation
- [ ] Test with keyboard
- [ ] Test split-screen mode

---

## 🚀 Go-Live Checklist

Before launching to users:

### Code Quality
- [ ] Code review completed
- [ ] No console errors or warnings
- [ ] No memory leaks
- [ ] Performance profiling done
- [ ] Unit tests pass (if applicable)
- [ ] Integration tests pass (if applicable)

### Deployment
- [ ] Flask backend deployed and stable
- [ ] Database backed up
- [ ] App uploaded to stores (if applicable)
- [ ] Release notes published
- [ ] Documentation accessible
- [ ] Support team trained

### Monitoring
- [ ] Error tracking enabled
- [ ] Performance monitoring active
- [ ] Analytics tracking setup
- [ ] Team notified of launch
- [ ] Support channels ready
- [ ] Rollback plan prepared

### User Communication
- [ ] Announce new feature
- [ ] Provide tutorial/guides
- [ ] Set support expectations
- [ ] Gather user feedback
- [ ] Plan for updates

---

## 📈 Success Metrics

After deployment, track:

| Metric | Goal | Current |
|--------|------|---------|
| Form completion rate | >80% | ☐ |
| API success rate | >99% | ☐ |
| Average response time | <10s | ☐ |
| Course click-through | >70% | ☐ |
| User satisfaction | 4.5+/5 | ☐ |
| Error rate | <1% | ☐ |
| Crash rate | <0.1% | ☐ |

---

## ✅ Final Checklist

- [ ] All code committed to version control
- [ ] Release candidate tested
- [ ] Documentation complete
- [ ] Team trained
- [ ] Support ready
- [ ] Monitoring configured
- [ ] Rollback plan documented
- [ ] Users notified
- [ ] Launch date confirmed
- [ ] Post-launch support scheduled

---

## 🎉 Launch!

When all checkboxes are complete, you're ready to launch!

```bash
# Final verification
flutter build release
python app.py

# Deploy to users
# Monitor logs and metrics
# Celebrate! 🎉
```

---

**Questions? Errors? Check CAREER_GUIDANCE_SETUP.md or IMPLEMENTATION_COMPLETE.md**
