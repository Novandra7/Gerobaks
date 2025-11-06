# Gerobaks Project Maintenance Checklist

## Debug Console Configuration

- [x] Update VS Code `launch.json` with proper console settings
- [x] Add critical flags to Flutter run configuration:
  - `--enable-software-rendering`
  - `--dart-flags=--no-disable-service-port-fallback`
  - `--no-dds`
- [x] Create dedicated debug batch script with all required flags

## Map Component Issues

- [x] Fix `CachedTileProvider` missing store parameter
- [x] Create `TileProviderService` to properly manage map tile providers
- [x] Update `navigation_page.dart` to use the service

## Audio Services

- [x] Create missing `chat_audio_service.dart` implementation
- [x] Add proper audio recording and playback functionality
- [x] Handle audio permissions correctly

## Android Build Fixes

- [x] Document solutions for audioplayers_android Gradle issues
- [x] Create audioplayers_android_fix.gradle file
- [x] Provide multiple options for resolving build problems

## Future Improvements

- [ ] Optimize map loading performance
- [ ] Reduce app size by optimizing asset usage
- [ ] Improve error handling throughout the app
- [ ] Add comprehensive error logging
- [ ] Update dependencies to latest compatible versions

## Regular Maintenance

- [ ] Run `flutter doctor` to check environment health
- [ ] Check for outdated packages with `flutter pub outdated`
- [ ] Run `flutter analyze` to find code issues
- [ ] Test on multiple screen sizes and devices
- [ ] Verify all features work correctly after updates

## Project Health Guidelines

1. Before pushing changes, run `diagnose_project.bat` to verify everything works
2. Use `run_gerobaks_debug.bat` for reliable debugging sessions
3. Refer to `android_build_fix.md` if encountering audioplayers build issues
4. Keep VS Code and Flutter SDK updated to latest stable versions
5. Document any non-standard configurations or workarounds
