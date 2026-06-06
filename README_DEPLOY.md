# Deploy Rytto to Vercel

## Quick Deploy Steps

### 1. Build the Flutter Web App Locally
Before deploying, build your Flutter web app:

```bash
flutter build web --release --web-renderer canvaskit
```

This creates optimized files in the `build/web` folder.

### 2. Push to GitHub
1. Create a new repository on GitHub (e.g., `rytto-app`)
2. Initialize git in your project (if not already done):
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/rytto-app.git
git push -u origin main
```

### 3. Deploy to Vercel

#### Option A: Using Vercel Dashboard (Easiest)
1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "Add New Project"
3. Import your GitHub repository
4. Configure the project:
   - **Framework Preset**: Other
   - **Build Command**: `flutter build web --release --web-renderer canvaskit`
   - **Output Directory**: `build/web`
   - **Install Command**: Leave empty (or add Flutter install if needed)
5. Click "Deploy"

#### Option B: Using Vercel CLI
1. Install Vercel CLI:
```bash
npm i -g vercel
```

2. Login to Vercel:
```bash
vercel login
```

3. Deploy (from project root):
```bash
vercel
```

4. For production deployment:
```bash
vercel --prod
```

### 4. Manual Build & Deploy (Alternative)
If Vercel has issues building Flutter, build locally and deploy the build folder:

1. Build locally:
```bash
flutter build web --release --web-renderer canvaskit
```

2. Deploy only the build folder:
```bash
cd build/web
vercel --prod
```

## Environment Variables (if needed)
If you need to add environment variables in Vercel:
1. Go to your project settings
2. Navigate to "Environment Variables"
3. Add your variables

## Custom Domain (Optional)
1. Go to your project settings in Vercel
2. Navigate to "Domains"
3. Add your custom domain
4. Follow the DNS configuration instructions

## Troubleshooting

### Flutter not found during build
- Use the manual build method (build locally, deploy build/web)
- Or deploy from a pre-built version

### Base href issues
Make sure `web/index.html` has:
```html
<base href="/">
```

### Large bundle size
- The web build might be large (~20MB)
- Vercel free tier supports up to 100MB

## Your App URL
After deployment, Vercel will give you a URL like:
`https://rytto-app.vercel.app`

Share this URL to access your app from anywhere!
