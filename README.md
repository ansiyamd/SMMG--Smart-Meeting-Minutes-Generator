# 🧠 Smart Meeting Management Generator (SMMG)

SMMG is an AI-powered system that automates meeting documentation by converting speech into text and generating concise summaries with actionable insights.

---

## 🚀 Features
- 🎤 Speech-to-Text transcription
- 📝 Automatic meeting summarization (BART)
- 🧾 Key insights extraction (BERT)
- 📌 Action items & decision tracking
- 🔔 Real-time processing
- ☁️ Secure cloud storage (Firebase)
- 📱 User-friendly mobile interface (Flutter)

---

## 🛠️ Tech Stack
- **Frontend:** Flutter  
- **Backend:** FastAPI  
- **AI Models:** BART, BERT  
- **Database & Auth:** Firebase  

---

## 📌 How It Works
1. Capture meeting audio  
2. Convert speech to text  
3. Process text using NLP models  
4. Generate summary & extract key points  
5. Store and display results in app  

---



## ⚙️ Installation
```bash
# Clone the repository
git clone https://github.com/your-username/smmg.git

# Navigate to project
cd smmg

# Install dependencies (backend)
pip install -r requirements.txt

# Run backend
uvicorn main:app --reload

# Run Flutter app
flutter pub get
flutter run
