# HELA - Sri Lanka Smart Tourism Platform

This is the root workspace for the **HELA** Smart Tourism application.

```
hela-mobile/
├── hela-mobile/       # Frontend Application (Flutter Mobile App)
└── hela-backend/      # Backend Application (InsForge BaaS, Database, REST API & Edge Functions)
```

## 📱 Frontend (`hela-mobile/`)
The Flutter mobile application providing:
- **Smart Tour Planner**: AI-powered day-by-day customized travel itineraries.
- **Fair Ride**: Transparent Tuk-Tuk and taxi fare estimator to prevent tourist overcharging.
- **Cultural Guide**: Curated insights, travel etiquette, and local stories.
- **Haven Stays**: Unique boutique hotels, chalets, and eco-resorts.
- **Authentication**: Seamless user accounts via InsForge BaaS and OAuth.

To run the Flutter app:
```bash
cd hela-mobile
flutter pub get
flutter run
```

---

## ⚙️ Backend (`hela-backend/`)
The backend service and BaaS integration containing:
- **InsForge Database**: PostgreSQL schema and tables for profiles, destinations, tours, stays, and fair rides.
- **REST API**: Express.js endpoints for mobile/web clients.
- **Edge Functions**: Serverless functions for AI planning and ride calculations.
- **MCP Integration**: InsForge MCP server for intelligent agent tools.

To run the backend server:
```bash
cd hela-backend
npm install
npm start
```
