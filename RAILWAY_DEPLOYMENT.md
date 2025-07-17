# Railway Deployment Guide for Google Calendar MCP Server

## Prerequisites

1. **Google Cloud Setup** (Complete this first):
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select existing one
   - Enable Google Calendar API
   - Create OAuth 2.0 credentials (Desktop app type)
   - Download the credentials JSON file

2. **Railway Account**:
   - Sign up at [Railway.app](https://railway.app)
   - Connect your GitHub account

## Step 1: Prepare Your JSON Configuration

1. **Update `gcp-oauth.keys.json`** with your Google credentials:
   ```json
   {
       "installed": {
           "client_id": "your-actual-google-client-id.googleusercontent.com",
           "client_secret": "your-actual-google-client-secret",
           "redirect_uris": [
               "http://localhost:3000/oauth2callback",
               "https://google-calendar-mcp-666.up.railway.app/oauth2callback"
           ]
       }
   }
   ```

2. **Important**: Replace `your-railway-app` with your actual Railway app name after deployment.

## Step 2: Deploy to Railway

### Option A: Deploy from GitHub (Recommended)

1. **Push to GitHub**:
   ```bash
   git add .
   git commit -m "Prepare for Railway deployment"
   git push origin main
   ```

2. **Deploy on Railway**:
   - Go to [Railway Dashboard](https://railway.app/dashboard)
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Choose your repository
   - Railway will automatically detect the Node.js project

3. **Configure Environment Variables**:
   In Railway dashboard, go to Variables tab and add:
   ```
   TRANSPORT=http
   HOST=0.0.0.0
   NODE_ENV=production
   GOOGLE_OAUTH_CREDENTIALS=./gcp-oauth.keys.json
   ```

### Option B: Deploy with Railway CLI

1. **Install Railway CLI**:
   ```bash
   npm install -g @railway/cli
   ```

2. **Login and Deploy**:
   ```bash
   railway login
   railway init
   railway up
   ```

## Step 3: Configure OAuth Redirect URI

1. **Get your Railway URL**:
   - In Railway dashboard, go to Settings → Domains
   - Copy your generated Railway URL (e.g., `https://your-app-production-abcd.up.railway.app`)

2. **Update Google Cloud Console**:
   - Go to Google Cloud Console → Credentials
   - Edit your OAuth 2.0 client
   - Add the Railway URL to authorized redirect URIs:
     ```
     https://your-app-production-abcd.up.railway.app/oauth2callback
     ```

3. **Update your local `gcp-oauth.keys.json`**:
   ```json
   {
       "installed": {
           "client_id": "your-client-id",
           "client_secret": "your-client-secret",
           "redirect_uris": [
               "http://localhost:3000/oauth2callback",
               "https://your-app-production-abcd.up.railway.app/oauth2callback"
           ]
       }
   }
   ```

4. **Redeploy**:
   ```bash
   git add gcp-oauth.keys.json
   git commit -m "Update OAuth redirect URI for Railway"
   git push origin main
   ```

## Step 4: Initial Authentication

Since this is a server deployment, you'll need to handle the initial OAuth flow:

1. **Access your Railway app** at the generated URL
2. **Trigger authentication** by making a request to any calendar endpoint
3. **Complete OAuth flow** in the browser when redirected

## Step 5: Using the Deployed Server

### HTTP API Endpoints

Your deployed server will be available at: `https://your-app-production-abcd.up.railway.app`

Key endpoints:
- `GET /health` - Health check
- `POST /` - MCP protocol endpoint
- Various calendar endpoints for direct HTTP access

### Connect with Claude Desktop

Update your Claude Desktop configuration to use the HTTP transport:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%\\Claude\\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "google-calendar": {
      "command": "node",
      "args": ["-e", "
        const { spawn } = require('child_process');
        const proc = spawn('curl', [
          '-X', 'POST',
          '-H', 'Content-Type: application/json',
          '-d', JSON.stringify(process.argv.slice(1)),
          'https://your-app-production-abcd.up.railway.app'
        ], { stdio: 'inherit' });
        proc.on('close', code => process.exit(code));
      "]
    }
  }
}
```

## Troubleshooting

### Common Issues:

1. **OAuth Redirect Mismatch**:
   - Ensure Railway URL is added to Google Cloud Console
   - Check redirect URIs match exactly

2. **Port Issues**:
   - Railway automatically sets PORT environment variable
   - Don't hardcode port 3000

3. **File Permissions**:
   - Ensure `gcp-oauth.keys.json` is readable
   - Check token storage directory permissions

4. **Authentication Failures**:
   - Verify Google Calendar API is enabled
   - Check OAuth client type is "Desktop application"
   - Ensure test users are added in OAuth consent screen

### Logs and Debugging:

```bash
# View Railway logs
railway logs

# Check deployment status
railway status
```

## Environment Variables Reference

| Variable | Value | Description |
|----------|-------|-------------|
| `TRANSPORT` | `http` | **Required** - Must be HTTP for Railway |
| `HOST` | `0.0.0.0` | Listen on all interfaces |
| `PORT` | Auto-set by Railway | Server port |
| `NODE_ENV` | `production` | Environment mode |
| `GOOGLE_OAUTH_CREDENTIALS` | `./gcp-oauth.keys.json` | Path to OAuth credentials |

## Security Notes

- Railway provides HTTPS automatically
- OAuth credentials are included in the build (consider using Railway secrets for production)
- Token storage is handled by Railway's persistent storage
- Consider using environment variables for sensitive data in production

## Next Steps

After successful deployment:
1. Test all calendar operations
2. Monitor Railway logs for any issues
3. Set up monitoring and alerts
4. Consider setting up custom domains if needed
