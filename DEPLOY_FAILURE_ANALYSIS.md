# Deploy Failure Analysis: herq-web

## Summary
**Status:** Issue Resolved ✅  
**Last Failed Deploy:** Run #35 (October 20, 2025, 20:01 UTC)  
**Current Deploy Status:** Run #47 (Success)

## What Went Wrong

### The Issue
The deployment to `herq-web` failed on **October 20, 2025** during the Flutter web build step. The build process exited with code 1 due to a **Dart type error** in the database initialization code.

### Root Cause
**Location:** `lib/src/core/database/database.dart`, line 1104

**Error Message:**
```
The argument type 'List<String>' can't be assigned to the parameter type 'String'.
```

**Problematic Code:**
```dart
equipment: Value(
  List<String>.from(variantData['equipment']! as List<dynamic>),
)
```

The code was attempting to pass a `List<String>` to the `equipment` field, but the database schema expected a single `String` value.

### Impact
- **Build Status:** Failed
- **Deployment:** Blocked
- **Affected Runs:** Runs #31-35 (October 16-20, 2025)
- **Error Type:** Compile-time type mismatch (not a runtime error)
- **Build Tool:** dart2js (Dart-to-JavaScript compiler)

## Timeline of Failed Deploys

| Run # | Date | Commit Message | Status |
|-------|------|----------------|--------|
| 47 | Oct 30, 2025 19:04 | Merge branch 'tracking' | ✅ Success |
| 46 | Oct 30, 2025 18:08 | wip | ✅ Success |
| 36 | Oct 20, 2025 20:53 | fuckeup | ✅ Success |
| **35** | **Oct 20, 2025 20:01** | **fuckeup** | **❌ Failed** |
| 34 | Oct 17, 2025 11:54 | swipe to back | ❌ Failed |
| 33 | Oct 17, 2025 09:54 | Auto login | ❌ Failed |
| 32 | Oct 17, 2025 09:20 | email templates | ❌ Failed |
| 31 | Oct 16, 2025 18:37 | new apk | ❌ Failed |

## How It Was Fixed

The issue was resolved between runs #35 and #36. The fix involved:

1. **Corrected the equipment field** to use a single `String` value instead of a `List<String>`
2. **Current code** (line 1170 in `database.dart`):
   ```dart
   equipment: Value(variantData['equipment']! as String),
   ```

### Technical Details

**Database Schema:** The `exercises` table's `equipment` column is defined as a single TEXT field, not an array.

**Flutter Build Process:**
- Flutter stable 3.35.6
- Build command: `flutter build web --release`
- Compiler: dart2js (Dart-to-JavaScript)

**Additional Warning (Non-Fatal):**
During the build, there was also a "Unexpected wasm dry run failure (252)" warning, but this was not the cause of the failure. This could be suppressed with `--no-wasm-dry-run` flag if desired.

## Current Status

✅ **Deployment is now working correctly**
- Last successful deploy: Run #47 (October 30, 2025)
- Build duration: ~4 minutes
- All steps completed successfully

## Recommendations

### Immediate Actions
None required - issue is resolved.

### Future Prevention
1. **Add Pre-Commit Hooks:** Run `dart analyze` before allowing commits
2. **CI Pipeline Enhancement:** Add static type checking step before build
3. **Local Testing:** Developers should run `flutter build web` locally before pushing changes
4. **Code Review:** Pay special attention to database schema changes

### Monitoring
- Watch for similar type mismatches in database operations
- Monitor build times for performance regressions
- Set up alerts for failed deployments

## Related Files
- `lib/src/core/database/database.dart` - Database schema and migrations
- `.github/workflows/deploy-web.yml` - Deployment workflow
- Build logs available at: https://github.com/KlausAndrade/HERQ/actions/runs/18663406363

## Conclusion

The deployment failures were caused by a simple type mismatch where a list was being passed to a field expecting a string. This issue has been successfully resolved, and the current deployment pipeline is functioning correctly. The error was caught during compilation rather than at runtime, which is actually beneficial as it prevented a broken build from being deployed.

---
*Generated on: 2025-10-31*  
*Last Deploy Status: ✅ Success (Run #47)*
