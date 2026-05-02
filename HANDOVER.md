# Smart Meeting Minutes – 2-Minute Handover (Client PC)

## What you receive
- Android app file: `app-release.apk`
- Project folder (contains server scripts)

## One-time setup (PC)
1. Install **Node.js (LTS)**
2. Install **Python 3.10+**
3. Connect phone and PC to the **same Wi-Fi**
4. (Optional but recommended) Allow Windows Firewall ports **3000** and **5000** if prompted

## Install app on phone (one time)
1. Copy `app-release.apk` to phone
2. Open APK and install
3. Allow “Install unknown apps” if Android asks

## Daily usage (before each meeting)
1. On PC, open project root folder
2. Double-click: `START_FOR_CLIENT.bat`
3. Keep that terminal window open
4. It will show:
   - Bot URL: `http://<PC_IP>:3000`
   - Backend URL: `http://<PC_IP>:5000`

## In mobile app
1. Open app
2. Enable **Bot recording**
3. Set Bot URL and Backend URL from terminal (or tap **Auto**)
4. Tap **Test** for bot server
5. Join meeting and use app normally

## If something fails
- Phone and PC must be on same Wi-Fi (no mobile data)
- Re-run `START_FOR_CLIENT.bat`
- Confirm in PC browser:
  - `http://localhost:3000/api/health` (should return JSON)
  - `http://localhost:5000` (should open page)
- If port blocked, run firewall rule script as Administrator from server folder

## Important
- For installed release APK, use `START_FOR_CLIENT.bat`.
- `START_DEV_ALL.bat` is for developer machines (starts Flutter run).
