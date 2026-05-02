# Fix Plan: Meeting Recording and Minutes Display Issues

## Issues to Fix:
1. **Not capturing all participants audio** - Bot only captures microphone, not meeting audio
2. **After meet end recording not stopping** - No automatic meeting end detection
3. **Not uploading the recording with voice** - Upload issues or empty audio
4. **Not displaying minutes** - Format mismatch between backend and Flutter app

## Plan:

### Phase 1: Fix Audio Capture (bot_server/jitsi_bot.py)
- Use Jitsi Meet JS API properly to get remote participant audio tracks
- Add meeting end detection via Jitsi events

### Phase 2: Fix Auto-Upload (bot_server/server.py)
- Ensure proper backend URL configuration
- Add better error handling for upload

### Phase 3: Fix Minutes Display (Flutter app)
- Fix the minutes parsing in main.dart to handle backend response format correctly

## Files to Modify:
1. `bot_server/jitsi_bot.py` - Fix audio capture and add meeting end detection
2. `bot_server/server.py` - Ensure auto-upload works properly
3. `Smartmeetingminutesgeneratojitsimeet/lib/main.dart` - Fix minutes parsing
