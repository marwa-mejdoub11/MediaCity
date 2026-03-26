# 🚀 MediaCite - Quick Start Guide

## Installation & Setup (5 minutes)

### Step 1: Update Firebase in Firestore Console
1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project: **mediacite-8ce11**
3. Go to **Firestore Database**
4. Click on **Rules** tab
5. Replace all rules with content from `FIRESTORE_RULES.txt`
6. Click **Publish**

### Step 2: Run the App
```bash
# Get to project directory
cd c:\coursfluter\mediacite

# Install dependencies (if needed)
flutter pub get

# Run the app
flutter run

# Or on specific device
flutter run -d <device-name>
```

### Step 3: Create Account
1. Tap "Register now" on Login screen
2. Enter email and password (min 6 characters)
3. Confirm password
4. Tap "Create Account"

### Step 4: Login
1. Use your registered email
2. Enter password
3. Tap "Login"

---

## 📚 Using the App

### Add Media (Auto-Saves!)
1. Tap **+** button (floating action button)
2. Enter **Title**: e.g., "The Three-Body Problem"
3. Enter **Type**: e.g., "Science Fiction"
4. Toggle **Available** if needed
5. Tap **Add Media**
6. ✅ Data automatically saves to cloud!

### Edit Media (Auto-Saves!)
1. Long-tap or tap menu (⋮) on a media item
2. Select **Edit**
3. Modify title, type, or availability
4. Tap **Update Media**
5. ✅ Changes instantly reflect in database!

### Toggle Availability
1. Open menu (⋮) on a media item
2. Select **Toggle Availability**
3. ✅ Status updates instantly!

### Delete Media
1. Open menu (⋮) on a media item
2. Select **Delete**
3. Confirm deletion
4. ✅ Removed from database!

### Logout
1. Tap **Logout** button (top right)
2. Confirm logout
3. Return to Login screen

---

## ✨ Auto-Save Features

✅ **Automatic Cloud Sync** - No "Save" button needed
✅ **Real-time Updates** - See changes on other devices instantly
✅ **Offline Support** - Changes sync when back online
✅ **Auto Timestamps** - Created and updated dates are automatic
✅ **User Isolation** - Only you can see your data
✅ **Error Handling** - Network issues are handled gracefully

---

## 📊 How Data is Stored

```
Firebase Firestore
└── users
    └── [your-user-id]
        ├── email: your@email.com
        ├── createdAt: timestamp
        └── media (your collection)
            ├── Media 1
            │   ├── title: "Book Title"
            │   ├── type: "Book"
            │   ├── available: true
            │   ├── createdAt: 2024-03-26...
            │   └── updatedAt: 2024-03-26...
            └── Media 2
                └── [same structure]
```

---

## 🆘 Troubleshooting

### App won't start?
```bash
flutter clean
flutter pub get
flutter run
```

### Can't see data in app?
- Check: Are you logged in?
- Check: Did you wait 2-3 seconds for Firestore to initialize?
- Check: Is Firestore running (no error message)?

### Changes don't appear?
- Check: Are you online?
- Check: Same Firebase account on both devices?
- Check: Security rules are correct?

### Error: "Permission denied"
- Solution: Update Firestore rules (Step 1 above)

### Error: "User not authenticated"
- Solution: Make sure you're logged in first

---

## 🔐 Your Data is Secure

✅ Only you can access your data
✅ Passwords encrypted by Firebase Auth
✅ Firestore rules prevent unauthorized access
✅ All data encrypted in transit (HTTPS)

---

## 📱 Multiple Devices?

Same account, multiple phones/tablets:

1. Install app on Device B
2. Register OR login with same email
3. Add media on Device A
4. Device B sees it appear automatically! ⚡

---

## 💾 Your Data is Always Saved

- ✅ Add media on phone → saved to cloud
- ✅ Close and reopen app → same data
- ✅ Switch devices → all data appears
- ✅ No internet → data syncs when back online
- ✅ Lost phone → sign in on new phone, data is there!

---

## 📞 Need Help?

### Check Firebase Console:
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select "mediacite-8ce11"
3. Firestore Database → Data tab
4. Look in `users/[your-id]/media/` for your entries

### Check App Logs:
```bash
flutter logs
```

### Review Detailed Guides:
- Full features: See `FEATURES.md`
- Auto-save details: See `AUTO_SAVE_GUIDE.md`
- Security rules: See `FIRESTORE_RULES.txt`

---

## ✅ You're Ready!

1. ✅ App code is complete
2. ✅ Firebase configured
3. ✅ Auto-save enabled
4. ✅ Security rules set
5. ✅ Ready to use!

**Next Step:** Run `flutter run` and create your first account! 🎉

