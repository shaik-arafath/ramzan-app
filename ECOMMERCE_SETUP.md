# Ramadan App E-Commerce System Setup Guide

## 📋 Overview

This is a complete real-time e-commerce system for the Ramadan Planner app with:
- User authentication (Login/Registration)
- Admin dashboard for managing products, offers, posts, and orders
- Real-time data synchronization with Supabase
- Role-based access control (Admin vs User)

## 🗄️ Database Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up and create a new project
3. Copy your project URL and anon key
4. Update the credentials in `lib/main.dart`

### Step 2: Run Database Schema

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `lib/database/schema.sql`
4. Paste and run the SQL script

This will create the following tables:
- `products` - Store product information
- `offers` - Store promotional offers
- `posts` - Store blog posts/announcements
- `orders` - Store customer orders
- `order_items` - Store items in each order
- `user_profiles` - Store user information and roles

### Step 3: Create First Admin User

After setting up the database, you need to create an admin user:

1. Run this SQL in Supabase SQL Editor:
```sql
-- Create a test admin user (replace with your email)
INSERT INTO user_profiles (user_id, full_name, role)
VALUES (
  (SELECT id FROM auth.users WHERE email = 'your-email@example.com'),
  'Admin Name',
  'admin'
);
```

Or manually update a user's role after they sign up:
```sql
UPDATE user_profiles SET role = 'admin' WHERE user_id = 'user-uuid';
```

## 🔧 Configuration

### Update Supabase Credentials

Edit `lib/main.dart` and update:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

## 🚀 Running the App

### Install Dependencies
```bash
flutter pub get
```

### Run on Web
```bash
flutter run -d chrome
```

### Build for Web
```bash
flutter build web
```

### Run the Web Server
```bash
cd build/web
python -m http.server 8080
```

## 📱 Features

### User Features
- **Authentication**: Sign up and login with email/password
- **Shop**: Browse products with categories
- **Cart**: Add items to cart and checkout
- **Orders**: View order history

### Admin Features
- **Products Management**: Add, edit, delete products
- **Offers Management**: Create promotional offers with dates
- **Posts Management**: Create blog posts and announcements
- **Orders Management**: View and update order status

## 🔐 Role-Based Access

### User Role
- Can browse products
- Can add items to cart
- Can place orders
- Can view their own orders

### Admin Role
- All user permissions
- Can manage products (CRUD)
- Can manage offers (CRUD)
- Can manage posts (CRUD)
- Can view all orders
- Can update order status

## 🎨 UI/UX Features

- Dark theme with gold accents (#E8B931)
- Animated buttons and cards
- Real-time data updates
- Responsive design
- Professional admin dashboard

## 📦 File Structure

```
lib/
├── database/
│   └── schema.sql              # Database schema
├── models/
│   └── product.dart            # Product model
├── providers/
│   ├── auth_provider.dart      # Authentication state
│   └── cart_provider.dart      # Shopping cart state
├── screens/
│   ├── login_screen.dart       # Login screen
│   ├── register_screen.dart    # Registration screen
│   ├── admin_dashboard_screen.dart    # Admin main screen
│   ├── admin_products_screen.dart    # Product management
│   ├── admin_offers_screen.dart      # Offer management
│   ├── admin_posts_screen.dart       # Post management
│   ├── admin_orders_screen.dart      # Order management
│   ├── shop_screen.dart        # Shop screen
│   ├── cart_screen.dart        # Cart screen
│   └── home_screen.dart        # Home screen
└── services/
    ├── auth_service.dart       # Authentication API calls
    └── supabase_content_service.dart  # Content API calls
```

## 🔍 Testing

### Test User Flow
1. Open app
2. Click login icon (settings icon)
3. Register a new account
4. Browse products
5. Add items to cart
6. Checkout

### Test Admin Flow
1. Sign in with admin account
2. Click settings icon (should show admin icon)
3. Navigate to Admin Dashboard
4. Add a new product
5. Create an offer
6. Add a post
7. View orders

## 🚢 Deployment

### Deploy to Netlify

1. Build the web app:
```bash
flutter build web
```

2. Install Netlify CLI:
```bash
npm install -g netlify-cli
```

3. Deploy:
```bash
netlify deploy --dir=build/web
```

### Deploy to Vercel

1. Build the web app:
```bash
flutter build web
```

2. Install Vercel CLI:
```bash
npm install -g vercel
```

3. Deploy:
```bash
vercel --prod
```

## 📝 Notes

- The app uses Supabase for backend services
- Row Level Security (RLS) is enabled for data protection
- Real-time updates are supported via Supabase subscriptions
- All data is stored in the cloud

## 🐛 Troubleshooting

### Database Connection Issues
- Check Supabase URL and anon key in `main.dart`
- Ensure Supabase project is active
- Verify database schema is applied

### Authentication Issues
- Check email confirmation settings in Supabase
- Ensure user_profiles table has the user record
- Verify role is set correctly for admin access

### Build Errors
- Run `flutter clean` then `flutter pub get`
- Check for missing dependencies in pubspec.yaml
- Ensure Flutter SDK is up to date

## 📞 Support

For issues or questions:
1. Check Supabase dashboard for errors
2. Review browser console for client-side errors
3. Verify database schema is correctly applied
