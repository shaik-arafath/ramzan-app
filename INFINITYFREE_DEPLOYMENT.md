# InfinityFree Deployment Guide

## Hosting Details
- **Username**: if0_43104994
- **Hosting Plan**: Free
- **Home Directory**: /home/vol17_1/infinityfree.com/if0_43104994
- **Website**: Islamicworldpro.free.nf

## Step 1: Build Flutter Web

```powershell
flutter build web
```

## Step 2: Upload to InfinityFree

### Option A: Using File Manager (Recommended)
1. Log in to InfinityFree control panel
2. Go to "Online File Manager"
3. Navigate to: `htdocs/`
4. Delete all existing files in htdocs
5. Upload all files from `build/web/` folder to `htdocs/`

### Option B: Using FTP
1. Use FileZilla or any FTP client
2. FTP Host: ftpupload.infinityfree.com
3. Username: if0_43104994
4. Password: Arafath143
5. Port: 21
6. Upload all files from `build/web/` to `htdocs/`

## Step 3: Access Your Website

After upload, your app will be available at:
- http://islamicworldpro.free.nf

## Database Setup

### MySQL Details
- **Host**: sql110.infinityfree.com
- **Port**: 3306
- **Username**: if0_43104994
- **Password**: Arafath143

### Create Database
1. Go to InfinityFree Control Panel
2. Click "MySQL Databases"
3. Click "Create Database"
4. Name it: `if0_43104994_ramzan_app`
5. Click "Create"

### Backend API Required
Flutter web cannot directly connect to MySQL for security reasons. You need a backend API. Options:

#### Option 1: PHP Backend (Simple)
Create PHP files in `htdocs/api/` folder to handle database operations.

#### Option 2: Supabase (Recommended - Already Configured)
Your app already uses Supabase. Continue using Supabase for:
- Authentication
- Database
- Real-time features

Supabase is better than MySQL for this use case because:
- Free tier available
- Built-in authentication
- Real-time subscriptions
- Easier integration with Flutter

## Recommended Approach

**Keep using Supabase** for backend and just deploy the Flutter web build to InfinityFree for hosting.

## Notes
- InfinityFree is free hosting with limitations
- For production, consider paid hosting for better performance
- Supabase free tier is sufficient for most use cases
