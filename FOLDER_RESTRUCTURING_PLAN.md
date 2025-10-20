# 📁 FOLDER RESTRUCTURING PLAN - Gerobaks Project

## 🎯 Current Problem
- **100+ files di root folder** (sangat berantakan!)
- Documentation files scattered everywhere
- Test scripts tidak terorganisir
- Sulit find files yang dibutuhkan

## ✅ New Folder Structure (Proposed)

```
Gerobaks/
├── 📱 lib/                          # Flutter source code (KEEP AS IS - ALREADY GOOD)
│   ├── blocs/                       # State management
│   ├── config/
│   ├── constants/
│   ├── controllers/
│   ├── models/
│   ├── pages/
│   ├── providers/
│   ├── routes/
│   ├── screens/
│   ├── services/
│   ├── shared/
│   ├── ui/
│   ├── utils/
│   └── main.dart
│
├── 📚 docs/                         # ALL DOCUMENTATION HERE ⭐ NEW!
│   ├── api/                         # API Documentation
│   │   ├── API_DOCUMENTATION.md
│   │   ├── API_CREDENTIALS.md
│   │   ├── API_INTEGRATION_SUMMARY.md
│   │   ├── BACKEND_API_VERIFICATION.md
│   │   ├── PRODUCTION_API_IMPLEMENTATION.md
│   │   └── api_troubleshooting_guide.md
│   │
│   ├── implementation/              # Implementation Guides
│   │   ├── MVP_END_USER_IMPLEMENTATION_GUIDE.md
│   │   ├── MVP_FINAL_COMPLETE.md
│   │   ├── IMPLEMENTATION_COMPLETE.md
│   │   ├── IMPLEMENTATION_GUIDE_DETAILED.md
│   │   ├── mitra_api_implementation_summary.md
│   │   └── production_api_integration.md
│   │
│   ├── testing/                     # Testing Documentation
│   │   ├── MVP_TESTING_GUIDE.md
│   │   ├── QUICK_START_TESTING.md
│   │   ├── LOGIN_FIX_TESTING_GUIDE.md
│   │   ├── TEST_ANALYSIS_AFTER_FIXES.md
│   │   └── TEST_FINDINGS_REPORT.md
│   │
│   ├── features/                    # Feature-specific docs
│   │   ├── authentication/
│   │   │   ├── AUTHENTICATION_ISSUES_ANALYSIS.md
│   │   │   ├── SANCTUM_FIX_SUCCESS.md
│   │   │   └── MULTI_ROLE_SYSTEM.md
│   │   ├── balance/
│   │   │   ├── taxi_balance_feature_guide.md
│   │   │   └── local_storage_documentation.md
│   │   ├── chat/
│   │   │   └── chat_integration_summary.md
│   │   ├── google_maps/
│   │   │   ├── google_maps_fix_documentation.md
│   │   │   └── google_maps_navigation_guide.md
│   │   ├── notifications/
│   │   │   └── notification_sound_info.md
│   │   ├── payments/
│   │   │   └── payment_integration.md
│   │   ├── keluhan/
│   │   │   ├── keluhan_README.md
│   │   │   └── custom_dialog_guide.md
│   │   ├── schedule/
│   │   │   ├── add_schedule_fix_plan.md
│   │   │   ├── fixing_add_schedule_guide.md
│   │   │   └── jadwal_mitra_redesign_guide.md
│   │   └── tracking/
│   │       └── google_maps_navigation_guide.md
│   │
│   ├── architecture/                # Architecture & Design
│   │   ├── PRD-Gerobaks.md          # Product Requirements
│   │   ├── PSD-Gerobaks.md          # Product Specification
│   │   ├── UserFlow-Petugas.md
│   │   └── folder_structure_summary.md
│   │
│   ├── reports/                     # Analysis & Reports
│   │   ├── CROSSCHECK_ANALYSIS_REPORT.md
│   │   ├── FINAL_CROSSCHECK_REPORT.md
│   │   ├── SAFETY_CROSSCHECK_REPORT.md
│   │   ├── ERD_COMPLIANCE_FINAL.md
│   │   ├── RINGKASAN_ERD_100_PERSEN.md
│   │   ├── PROJECT_COMPLETION_SUMMARY.md
│   │   └── 100_PERCENT_ACHIEVEMENT.md
│   │
│   ├── fixes/                       # Bug Fixes Documentation
│   │   ├── android_build_fix.md
│   │   ├── android_gradle_deprecation_fix.md
│   │   ├── audio_service_fix.md
│   │   ├── logout_fix.md
│   │   └── service_integration_fix_summary.md
│   │
│   ├── guides/                      # Step-by-step Guides
│   │   ├── QUICK_START.md
│   │   ├── QUICK_SUMMARY_MVP.md
│   │   ├── PANDUAN_KONEKSI_API.md
│   │   └── NEXT_STEPS_CHECKLIST.md
│   │
│   └── changelog/                   # Change History
│       ├── CHANGELOG.md
│       ├── CHANGELOG_PROJECT.md
│       └── updates.md
│
├── 🧪 scripts/                      # ALL SCRIPTS HERE ⭐ NEW!
│   ├── test/                        # Test Scripts
│   │   ├── test-100-percent.ps1
│   │   ├── test-all-mobile-services.ps1
│   │   ├── test-local-api.ps1
│   │   ├── test-mobile-100-percent.ps1
│   │   ├── test-quick-fixed.ps1
│   │   ├── test-rating-endpoint.ps1
│   │   └── test-rating-mitra-id.ps1
│   │
│   ├── run/                         # Run Scripts
│   │   ├── run_flutter_app.bat
│   │   ├── run_flutter_debug.bat
│   │   ├── run_flutter_debug.sh
│   │   ├── run_gerobaks_debug.bat
│   │   ├── run_app_with_config.bat
│   │   ├── run_debug_*.bat         # All run_debug variants
│   │   └── run_laravel_server.bat
│   │
│   ├── setup/                       # Setup Scripts
│   │   ├── start-local-api.bat
│   │   ├── start-local-api.ps1
│   │   └── run-local-api-test.ps1
│   │
│   └── utils/                       # Utility Scripts
│       ├── fix-all-services.ps1
│       ├── diagnose_project.bat
│       └── test_api_connection.bat
│
├── 📊 test-results/                 # TEST RESULTS HERE ⭐ NEW!
│   └── *.json                       # All test-results-*.json files
│
├── 🗄️ database/                     # DATABASE RELATED ⭐ NEW!
│   ├── sql/
│   │   ├── gerobaks_database_complete.sql
│   │   ├── dumeg_gerobaks.sql
│   │   └── add_driver_user.sql
│   └── docs/
│       ├── LOCAL_API_SETUP.md
│       └── LOCAL_API_SETUP_SUCCESS.md
│
├── 🖼️ assets/                       # Assets (KEEP AS IS)
│   └── ...
│
├── 🔧 android/                      # Android config (KEEP AS IS)
│   └── ...
│
├── 🍎 ios/                          # iOS config (KEEP AS IS)
│   └── ...
│
├── 💻 backend/                      # Laravel backend (KEEP AS IS)
│   └── ...
│
├── 📦 local_packages/               # Local packages (KEEP AS IS)
│   └── ...
│
├── 🏗️ build/                        # Build output (KEEP AS IS)
│   └── ...
│
├── 🌐 web/                          # Web config (KEEP AS IS)
│   └── ...
│
├── 🪟 windows/                      # Windows config (KEEP AS IS)
│   └── ...
│
├── 🐧 linux/                        # Linux config (KEEP AS IS)
│   └── ...
│
├── 🍏 macos/                        # macOS config (KEEP AS IS)
│   └── ...
│
├── 🧪 test/                         # Unit tests (KEEP AS IS)
│   └── ...
│
├── 📝 temp/                         # Temporary files (KEEP AS IS)
│   └── ...
│
├── 📄 ROOT FILES (CLEANED UP)       # Only essential files
│   ├── README.md                    # Main README
│   ├── pubspec.yaml                 # Flutter dependencies
│   ├── pubspec.lock
│   ├── analysis_options.yaml
│   ├── .gitignore
│   ├── .env
│   ├── .env.example
│   ├── composer.json
│   ├── composer.lock
│   ├── LICENSE
│   ├── .metadata
│   └── devtools_options.yaml
│
└── 🖼️ screenshots/                  # IMAGES HERE ⭐ NEW!
    ├── flutter_01.png
    ├── flutter_02.png
    ├── flutter_03.png
    ├── flutter_04.png
    └── flutter_05.png
```

---

## 📋 Migration Steps

### Phase 1: Create New Folders ✅
```powershell
# Create new folder structure
mkdir docs\api, docs\implementation, docs\testing, docs\features, docs\architecture
mkdir docs\reports, docs\fixes, docs\guides, docs\changelog
mkdir docs\features\authentication, docs\features\balance, docs\features\chat
mkdir docs\features\google_maps, docs\features\notifications, docs\features\payments
mkdir docs\features\keluhan, docs\features\schedule, docs\features\tracking
mkdir scripts\test, scripts\run, scripts\setup, scripts\utils
mkdir test-results, database\sql, database\docs, screenshots
```

### Phase 2: Move Documentation Files
```powershell
# API Docs
Move-Item API_*.md docs\api\
Move-Item BACKEND_API_VERIFICATION.md docs\api\
Move-Item PRODUCTION_API_IMPLEMENTATION.md docs\api\
Move-Item api_troubleshooting_guide.md docs\api\
Move-Item production_api_integration.md docs\api\

# Implementation Docs
Move-Item MVP_*.md docs\implementation\
Move-Item IMPLEMENTATION_*.md docs\implementation\
Move-Item mitra_api_implementation_summary.md docs\implementation\

# Testing Docs
Move-Item *TEST*.md docs\testing\
Move-Item LOGIN_FIX_TESTING_GUIDE.md docs\testing\

# Feature Docs (authentication)
Move-Item AUTHENTICATION_ISSUES_ANALYSIS.md docs\features\authentication\
Move-Item SANCTUM_*.md docs\features\authentication\
Move-Item MULTI_ROLE_SYSTEM.md docs\features\authentication\

# Feature Docs (other features)
Move-Item taxi_balance_feature_guide.md docs\features\balance\
Move-Item local_storage_documentation.md docs\features\balance\
Move-Item chat_integration_summary.md docs\features\chat\
Move-Item google_maps_*.md docs\features\google_maps\
Move-Item notification_sound_info.md docs\features\notifications\
Move-Item payment_integration.md docs\features\payments\
Move-Item keluhan_README.md docs\features\keluhan\
Move-Item custom_dialog_guide.md docs\features\keluhan\
Move-Item *schedule*.md docs\features\schedule\
Move-Item jadwal_mitra_redesign_guide.md docs\features\schedule\

# Architecture
Move-Item PRD-Gerobaks.md docs\architecture\
Move-Item PSD-Gerobaks.md docs\architecture\
Move-Item UserFlow-Petugas.md docs\architecture\
Move-Item folder_structure_summary.md docs\architecture\

# Reports
Move-Item *CROSSCHECK*.md docs\reports\
Move-Item *ERD*.md docs\reports\
Move-Item PROJECT_COMPLETION_SUMMARY.md docs\reports\
Move-Item 100_PERCENT_ACHIEVEMENT.md docs\reports\

# Fixes
Move-Item android_build_fix.md docs\fixes\
Move-Item android_gradle_deprecation_fix.md docs\fixes\
Move-Item audio_service_fix.md docs\fixes\
Move-Item logout_fix.md docs\fixes\
Move-Item service_integration_fix_summary.md docs\fixes\

# Guides
Move-Item QUICK_START*.md docs\guides\
Move-Item PANDUAN_*.md docs\guides\
Move-Item NEXT_STEPS_CHECKLIST.md docs\guides\

# Changelog
Move-Item CHANGELOG*.md docs\changelog\
Move-Item updates.md docs\changelog\
```

### Phase 3: Move Scripts
```powershell
# Test scripts
Move-Item test-*.ps1 scripts\test\

# Run scripts
Move-Item run_*.bat scripts\run\
Move-Item run_*.sh scripts\run\

# Setup scripts
Move-Item start-*.bat scripts\setup\
Move-Item start-*.ps1 scripts\setup\

# Utils
Move-Item fix-all-services.ps1 scripts\utils\
Move-Item diagnose_project.bat scripts\utils\
Move-Item test_api_connection.bat scripts\utils\
```

### Phase 4: Move Test Results & Database Files
```powershell
# Test results
Move-Item test-results-*.json test-results\

# Database files
Move-Item *.sql database\sql\
Move-Item LOCAL_API_SETUP*.md database\docs\
```

### Phase 5: Move Screenshots
```powershell
Move-Item flutter_*.png screenshots\
```

---

## ✅ Benefits After Restructuring

1. **Easy Navigation** 🎯
   - Find docs instantly: `docs/api/`, `docs/testing/`, etc.
   - All scripts in one place: `scripts/`
   - Clean root folder (only 15 files vs 100+)

2. **Better Organization** 📁
   - Grouped by purpose (api, features, testing)
   - Easy to maintain
   - Easy for new developers

3. **Professional Structure** 💼
   - Industry standard folder layout
   - Similar to popular projects
   - Easy CI/CD integration

4. **Improved Git History** 📊
   - Cleaner commit logs
   - Easier to track changes by category
   - Better for code review

---

## 🚨 Important Notes

- **DON'T TOUCH** these folders (already good):
  - `lib/` (Flutter source)
  - `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`
  - `backend/` (Laravel)
  - `assets/`, `build/`, `test/`

- **Update imports** if any code references moved files

- **Update README.md** with new folder structure

---

## 🎯 Execution Priority

1. **HIGH**: Create new folders (5 minutes)
2. **HIGH**: Move documentation files (10 minutes)
3. **MEDIUM**: Move scripts (5 minutes)
4. **MEDIUM**: Move test results & DB files (5 minutes)
5. **LOW**: Move screenshots (2 minutes)

**Total Time**: ~30 minutes

---

## 📝 Next Steps After Restructuring

1. Update `README.md` with new folder structure
2. Create `docs/README.md` as documentation index
3. Test that app still runs: `flutter run`
4. Commit changes: `git add . && git commit -m "Restructure: Organize project folders"`

---

**Ready to restructure?** Say the word and I'll execute! 🚀
