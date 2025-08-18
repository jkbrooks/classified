# 🚀 Running ElizaOS in GitHub Codespaces

This guide explains how to run the ElizaOS application in GitHub Codespaces, including proper URL handling and multiple server components.

## 📋 Architecture Overview

ElizaOS consists of multiple components:

1. **PostgreSQL Database** - Port 5432 (internal)
2. **AgentServer (Backend)** - Port 7777 (main API)
3. **Vite Frontend** - Port 5173 (React UI)
4. **Tauri Desktop App** - Wraps the frontend (development mode)

## 🔧 Initial Setup

### 1. First Time Setup

After opening the Codespace, you'll need to rebuild the devcontainer to activate PostgreSQL:

```bash
# In VS Code Command Palette (Ctrl+Shift+P):
> Dev Containers: Rebuild Container
```

This will:
- Start PostgreSQL with pgvector extension
- Install all dependencies (Bun, Rust, Cargo, Tauri)
- Configure environment variables

### 2. Verify Setup

```bash
./verify-setup.sh
```

## 🌐 Running the Application

### Option 1: Full Development Mode (Recommended)

This runs both the backend and frontend with hot reload:

```bash
cd packages/game
bun run dev
```

This command:
1. Builds the agentserver backend
2. Starts Vite frontend on port 5173
3. Starts Tauri in development mode

### Option 2: Backend Only

If you just want to test the API:

```bash
cd packages/agentserver
bun run dev
```

This starts the AgentServer on port 7777.

### Option 3: Frontend Only

If the backend is already running:

```bash
cd packages/game
bun vite dev --host 0.0.0.0 --port 5173
```

## 🌍 Accessing the Application in Codespaces

### Important: URLs for Codespace Access

Since you're in a Codespace, **localhost URLs won't work**. Use these instead:

#### Frontend (React UI)
```
https://<codespace-name>-5173.app.github.dev
```

#### Backend API
```
https://<codespace-name>-7777.app.github.dev
```

#### PostgreSQL (for external tools)
```
<codespace-name>-5432.app.github.dev
```

### Finding Your Codespace URLs

1. **Automatic Port Forwarding**: GitHub Codespaces automatically forwards ports
2. **Ports Panel**: In VS Code, open the "Ports" panel to see forwarded URLs
3. **Browser Access**: Click the globe icon next to each port to open in browser

## 🔌 Port Configuration

The application uses these ports:

| Service | Port | Purpose | Codespace URL Pattern |
|---------|------|---------|----------------------|
| PostgreSQL | 5432 | Database | `<codespace>-5432.app.github.dev` |
| Vite Frontend | 5173 | React UI | `<codespace>-5173.app.github.dev` |
| AgentServer | 7777 | Backend API | `<codespace>-7777.app.github.dev` |
| WebSocket | 7777 | Real-time comms | `wss://<codespace>-7777.app.github.dev/ws` |

## 🛠️ Environment Variables

The devcontainer automatically sets:

```bash
POSTGRES_URL=postgresql://postgres:postgres@db:5432/eliza
DATABASE_URL=postgresql://postgres:postgres@db:5432/eliza
NODE_ENV=development
```

For API keys, create a `.env` file in the project root:

```bash
# Optional: Add your API keys for AI models
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here
GROQ_API_KEY=your_key_here
```

## 🧪 Testing the Setup

### 1. Test Backend API

```bash
# Replace <codespace-name> with your actual codespace name
curl https://<codespace-name>-7777.app.github.dev/api/server/ping
```

Expected response:
```json
{"status":"ok","timestamp":"2024-01-01T00:00:00.000Z"}
```

### 2. Test PostgreSQL Connection

```bash
psql "postgresql://postgres:postgres@db:5432/eliza"
```

### 3. Test Frontend

Open `https://<codespace-name>-5173.app.github.dev` in your browser.

## 🚨 Common Issues & Solutions

### Issue: "Connection Refused"
- **Cause**: Service not started or wrong URL
- **Solution**: Use the Codespace URL format, not localhost

### Issue: "Database Connection Failed"
- **Cause**: PostgreSQL not running
- **Solution**: Rebuild devcontainer or run `docker-compose up -d db`

### Issue: "Port Already in Use"
- **Cause**: Previous process still running
- **Solution**: 
  ```bash
  pkill -f "node\|bun\|tauri"
  # Then restart the service
  ```

### Issue: "Tauri Dev Mode Fails"
- **Cause**: Tauri requires desktop environment
- **Solution**: In Codespaces, focus on the web UI at port 5173

## 🔄 Development Workflow

### Typical Development Session

1. **Start the backend**:
   ```bash
   cd packages/agentserver
   bun run dev
   ```

2. **Start the frontend** (in new terminal):
   ```bash
   cd packages/game
   bun vite dev --host 0.0.0.0 --port 5173
   ```

3. **Access the UI**: Open the forwarded port 5173 URL in your browser

4. **API Testing**: Use the forwarded port 7777 URL for API calls

### Hot Reload

- Frontend changes reload automatically
- Backend changes require restart
- Database schema changes may require `RESET_DB=true bun run dev`

## 📝 Useful Commands

```bash
# View running processes
ps aux | grep -E "(node|bun|postgres)"

# Check port usage
netstat -tlnp | grep -E "(5173|7777|5432)"

# View logs
tail -f ~/.pm2/logs/*.log  # If using PM2
journalctl -f  # System logs

# Database management
psql "postgresql://postgres:postgres@db:5432/eliza" -c "\\l"  # List databases
psql "postgresql://postgres:postgres@db:5432/eliza" -c "\\dt" # List tables
```

## 🎯 Next Steps

1. **Configure AI Models**: Add API keys to `.env`
2. **Customize Agent**: Modify character files in `packages/agentserver/src/character.ts`
3. **Add Plugins**: Explore the plugin system in `packages/plugin-*`
4. **Run Tests**: Use `bun run test` to run the test suite

## 🆘 Getting Help

If you encounter issues:

1. Run `./verify-setup.sh` to check your environment
2. Check the Ports panel in VS Code for forwarded URLs
3. Look at the terminal output for error messages
4. Ensure you're using Codespace URLs, not localhost

Happy coding! 🎉
