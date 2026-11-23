# HELA Backend

Backend API service, InsForge BaaS integration, PostgreSQL database schema, and Edge Functions for the **HELA Sri Lanka Tourism & Smart Travel App**.

---

## 🏗️ Architecture Overview

The project is structured under the main workspace:
```
hela-mobile/ (Main Workspace Root)
├── hela-mobile/       # Frontend: Flutter Mobile Application
└── hela-backend/      # Backend: InsForge BaaS, Database Schemas, API Endpoints, Edge Functions
```

---

## 📁 Backend Directory Structure

```
hela-backend/
├── .agents/
│   └── mcp_config.json      # InsForge MCP configuration for AI agent tools
├── .vscode/
│   └── mcp.json             # InsForge MCP server config for VS Code
├── config/
│   ├── db.js                # Database query runner for InsForge PostgreSQL
│   └── insforge.js          # InsForge REST client & auth headers
├── controllers/
│   ├── authController.js    # User authentication & profile management
│   ├── destinationController.js # Sri Lankan curated attractions & search
│   ├── rideController.js    # Fair Ride estimation & overcharge protection
│   ├── stayController.js    # Haven Stays & accommodations
│   └── tourController.js    # Smart Tour planning with Google Gemini AI
├── database/
│   ├── schema.sql           # Complete PostgreSQL schema (profiles, tour_plans, destinations, etc.)
│   └── seed.sql             # Curated seed data for Sri Lankan tourism spots
├── functions/
│   ├── tour-planner/        # Edge function for AI Tour generation
│   └── fair-ride/           # Edge function for Fair Ride fare calculation
├── routes/
│   ├── authRoutes.js        # /api/auth
│   ├── destinationRoutes.js # /api/destinations
│   ├── rideRoutes.js        # /api/rides
│   ├── stayRoutes.js        # /api/stays
│   └── tourRoutes.js        # /api/tours
├── scripts/
│   └── migrate.js           # Automated database migration runner
├── .env                     # Environment variables & InsForge API keys
├── .env.example             # Template environment configuration
├── package.json             # Node.js project manifest
├── server.js                # Express REST API Server
└── README.md                # Documentation
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment
Verify `.env` has your valid InsForge credentials:
```env
INSFORGE_BASE_URL=https://tvf24g8r.us-east.insforge.app
INSFORGE_API_KEY=ik_cab32e75750979d7ab16c1684a35affe
INSFORGE_ANON_KEY=anon_4ac1cdd3569c8ba96ee190681daac2c8e6f773475692bd59bb4a0365e6c09aae
GEMINI_API_KEY=AQ.Ab8RN6LcBcIS8jiH2GzAdjwITZJtC1IXTrvgdQnvky5gXnv4CA
PORT=5000
```

### 3. Run Database Migrations
To initialize or refresh tables on InsForge:
```bash
npm run migrate
```

### 4. Start the Backend Server
```bash
npm start
# or for live reloading:
npm run dev
```

---

## 📡 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/health` | Service health status check |
| `GET` | `/api/auth/session` | Validate current user token with InsForge |
| `GET` | `/api/auth/profile/:userId` | Get user profile information |
| `POST` | `/api/auth/profile/sync` | Sync / update user profile data |
| `GET` | `/api/destinations` | List all Sri Lanka attractions (filter by region/category) |
| `GET` | `/api/destinations/:id` | Get single destination details |
| `POST` | `/api/tours/generate` | Generate AI itinerary using Gemini AI |
| `POST` | `/api/tours/save` | Save customized tour plan to user account |
| `GET` | `/api/tours/user/:userId` | Get saved tour plans for a user |
| `POST` | `/api/rides/calculate-fare` | Fair ride distance fare calculator & quote comparison |
| `GET` | `/api/rides/history/:userId` | Get user's ride calculation history |
| `GET` | `/api/stays` | Explore haven stays and accommodations |
