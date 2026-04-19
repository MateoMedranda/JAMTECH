# 🤖 JAMTECH: Lupita AI Business Assistant

![JAMTECH Banner](./docs/assets/banner.png)

[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-%234ea94b.svg?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![LangChain](https://img.shields.io/badge/LangChain-1C3C3C?style=for-the-badge&logo=langchain&logoColor=white)](https://langchain.com/)
[![ElevenLabs](https://img.shields.io/badge/ElevenLabs-Voice_AI-orange?style=for-the-badge)](https://elevenlabs.io/)

**JAMTECH** is a cutting-edge Business Intelligence platform featuring **Lupita**, an advanced AI Assistant designed to empower commerce owners with real-time analytics, financial summaries, and natural voice interaction.

---

## ✨ Key Features

### 🧠 Intelligent Business RAG
Powered by LangChain and ChromaDB, Lupita understands your business data deeply. Ask about sales, trends, or specific transactions, and get instant, context-aware answers.

### 📊 Real-time Visual Analytics
Dynamic chart generation directly in the chat interface. Visualize **Gains vs Losses**, monthly trends, and customer metrics with sleek, interactive graphs powered by `fl_chart`.

### 🎙️ Multi-modal Interaction
- **Voice-to-Text (STT)**: Talk to Lupita naturally.
- **Text-to-Speech (TTS)**: Lupita responds with high-quality, realistic voices via ElevenLabs integration.

### 💼 Financial Insights
- **Financial Summaries**: Automatic calculation of Gross Income, Fixed/Variable Expenses, and Net Profit.
- **Client Metrics**: Insights into buyer personas, average ticket size, and customer retention.

---

## 🛠️ Tech Stack

### Frontend (Flutter)
- **State Management**: Provider
- **UI Components**: Google Fonts, Material Design 3
- **Charts**: fl_chart
- **Voice**: audioplayers, record

### Backend (FastAPI)
- **Framework**: FastAPI (Python 3.10+)
- **Database**: MongoDB (Storage) & ChromaDB (Vector Store)
- **AI Orchestration**: LangChain, Groq/OpenAI
- **Voice AI**: ElevenLabs SDK

---

## 🚀 Quick Start

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/MateoMedranda/JAMTECH.git
cd JAMTECH
```

### 2️⃣ Backend Setup
```bash
cd BACKEND
pip install -r requirements.txt
# Configure your .env with MONGO_URI, ELEVENLABS_API_KEY, etc.
python main.py
```

### 3️⃣ Frontend Setup
```bash
cd FRONTEND
flutter pub get
flutter run
```

---

## 📁 Project Structure

```bash
JAMTECH/
├── BACKEND/             # FastAPI Server, AI Services, & Database Logic
│   ├── routers/         # API Endpoints (BusinessBot, Analytics)
│   ├── services/        # AI Agents & Bot Tools
│   └── database/        # MongoDB & ChromaDB connections
├── FRONTEND/            # Flutter Application
│   ├── lib/views/       # UI Screens (Home, Chat, Analytics)
│   ├── lib/config/      # Constants & Theme
│   └── assets/          # Project Images & Fonts
└── docs/                # Project Documentation & Assets
```

---

## 🛡️ License
Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">
  Developed with ❤️ by the JAMTECH Team
</p>
