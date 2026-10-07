# TrustLens AI — Production Deployment Guide

This guide covers deployment options for **TrustLens AI**:
1. [Option 1: Unified Single-Service Deployment on Render (Recommended)](#option-1-unified-deployment-on-render-recommended)
2. [Option 2: Split Deployment (Frontend on Vercel + Backend on Render)](#option-2-split-deployment-vercel--render)
3. [Option 3: Universal Docker Container (Railway / Fly.io / Cloud Run / VPS)](#option-3-universal-docker-container)
4. [Environment Variables Reference](#environment-variables-reference)

---

## Option 1: Unified Deployment on Render (Recommended)

In this approach, Express serves both the backend API (`/api/*`) and the pre-built React production client (`client/dist`) from a single web service. This eliminates CORS complexities and keeps hosting on the free/starter tier.

### Steps:
1. **Push your code to GitHub**:
   ```bash
   git remote add origin https://github.com/<your-username>/<your-repo-name>.git
   git branch -M main
   git push -u origin main
   ```
2. **Create Web Service on Render**:
   - Go to [dashboard.render.com](https://dashboard.render.com/) and click **New +** > **Blueprint** (or **Web Service**).
   - If using **Blueprint**, connect your repository and Render will automatically detect [`render.yaml`](./render.yaml).
   - If setting up manually as a **Web Service**:
     - **Runtime**: `Node`
     - **Build Command**: `npm run build`
     - **Start Command**: `npm start`
     - **Plan**: Free / Starter
3. **Configure Environment Variables in Render**:
   - `NODE_ENV`: `production`
   - `PORT`: `5000` (or leave default assigned by Render)
   - `MONGODB_URI`: Your MongoDB Atlas connection string (or Render MongoDB)
   - `JWT_SECRET`: A long random secret string
   - `GEMINI_API_KEY`: Your Google Gemini API Key
4. Click **Deploy**. Once built, your entire full-stack app will be live at `https://<your-service>.onrender.com`.

---

## Option 2: Split Deployment (Vercel + Render)

### Backend on Render:
1. Deploy the backend as a Node Web Service:
   - **Root Directory**: `server`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Environment Variables**:
     - `NODE_ENV=production`
     - `MONGODB_URI=<your-mongodb-atlas-uri>`
     - `JWT_SECRET=<your-random-secret>`
     - `GEMINI_API_KEY=<your-gemini-key>`
     - `CLIENT_URL=https://<your-vercel-app>.vercel.app`
2. Copy your backend URL (e.g., `https://trustlens-api.onrender.com`).

### Frontend on Vercel:
1. Import your GitHub repository into [Vercel](https://vercel.com).
2. Set:
   - **Root Directory**: `client`
   - **Framework Preset**: `Vite`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
3. Add Environment Variable:
   - `VITE_API_URL`: `https://trustlens-api.onrender.com/api`
4. Deploy! The [`client/vercel.json`](./client/vercel.json) file will automatically route all SPA pages correctly.

---

## Option 3: Universal Docker Container

TrustLens AI comes pre-packaged with a multi-stage production [`Dockerfile`](./Dockerfile) and [`docker-compose.yml`](./docker-compose.yml).

### Local or VPS Deployment:
```bash
# Set your Gemini API key
export GEMINI_API_KEY=your_key_here

# Build and start services (App + MongoDB)
docker compose up -d --build
```
Your app will be accessible at `http://localhost:5000`.

### Railway / Fly.io / Google Cloud Run:
Simply point the platform to the root directory; it will detect the `Dockerfile`, build the optimized client bundle in stage 1, and run the lean server runtime in stage 2.

---

## Environment Variables Reference

| Variable | Required | Description | Example |
| :--- | :--- | :--- | :--- |
| `NODE_ENV` | Yes | App runtime mode | `production` |
| `PORT` | No | Server port (default: 5000) | `5000` |
| `MONGODB_URI` | Yes | MongoDB Connection URI | `mongodb+srv://...` |
| `JWT_SECRET` | Yes | Token signing secret | `32+ character random string` |
| `GEMINI_API_KEY` | Optional | Google Gemini API key (Heuristics work if unset) | `AIzaSy...` |
| `CLIENT_URL` | For Split | Allowed CORS Origin | `https://trustlens.vercel.app` |
| `VITE_API_URL` | For Split | Client API base URL | `https://api.yourdomain.com/api` |

---

## Verification Checklist

- [x] Production build tested and verified (`dist/` asset bundling)
- [x] Static SPA asset serving configured in Express
- [x] CORS properly configured for custom origins and localhost
- [x] Sensitive files (`.env`, `node_modules`) excluded via `.gitignore` and `.dockerignore`
- [x] Git repository initialized with clean initial commit
