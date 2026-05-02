# Recording and Minutes Generation

## Architecture

1. **Bot** (Puppeteer) joins Jitsi as a participant and records meeting audio.
2. **Upload** – Bot uploads recorded audio to the Flask backend.
3. **Transcription** – Whisper converts audio to text.
4. **Speaker diarization** – Pyannote (optional) separates speakers in mixed audio.
5. **Minutes** – Topics, decisions, action items, summary.

## How the bot records

- **Primary**: Captures audio from Jitsi `<video>` / `<audio>` elements via `captureStream`. No user interaction required when other participants are in the meeting.
- **Fallback**: If capture fails, uses `getDisplayMedia` – you must click **Share** on the bot’s browser window and select the Jitsi tab (with “Share tab audio” enabled).

## Speaker separation and participant names

- Mixed audio (all participants) is recorded as one stream.
- **Pyannote** (optional): Set `PYANNOTE_AUTH_TOKEN` and install `pyannote-audio` to separate Speaker 1, Speaker 2, etc. from the mixed audio.
- **Participant names**: Use the **in-app** Jitsi view (not “Open in Jitsi app”). Participant names are then passed to the backend for mapping (e.g. Speaker 1 → real name).

### Enable pyannote for better speaker separation

```bash
pip install pyannote-audio
```

1. Create a Hugging Face account and accept the pyannote model terms: https://huggingface.co/pyannote/speaker-diarization  
2. Create an access token: https://huggingface.co/settings/tokens  
3. Set before running `app.py`:

   ```powershell
   $env:PYANNOTE_AUTH_TOKEN = "your_huggingface_token"
   python app.py
   ```

## Checklist for reliable recording and minutes

- [ ] `app.py` running (bot + Flask backend)
- [ ] Bot Server URL = `http://YOUR_PC_IP:3000`
- [ ] Backend URL = `http://YOUR_PC_IP:5000`
- [ ] Phone and PC on same Wi‑Fi
- [ ] Firewall allows ports 3000 and 5000
- [ ] Use in-app Jitsi (not “Open in Jitsi app”) for participant names
- [ ] Optional: `PYANNOTE_AUTH_TOKEN` for speaker diarization
