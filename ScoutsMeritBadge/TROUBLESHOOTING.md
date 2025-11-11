# Troubleshooting Guide

## SwiftData ModelContainer Error

If you're seeing: `Fatal error: Could not create ModelContainer: SwiftDataError`

### What Causes This?

This error occurs when:
1. The SwiftData model schema has changed since the last run
2. There's existing data that doesn't match the new model structure
3. The database files are corrupted

### ✅ Solution (Automatic)

The app now automatically handles this by:
1. Detecting the error
2. Printing diagnostic information to the console
3. Removing the old database files
4. Creating a fresh database

### 📝 What Happens When Database is Reset?

- ✅ All 126 merit badges will be loaded fresh from JSON
- ❌ Any completion progress will be lost
- ❌ Any checked-off requirements will be cleared
- ❌ Completion dates will be reset

### 🔍 Manual Fix (If needed)

If the automatic fix doesn't work, you can manually reset the database:

#### On iOS Simulator:
1. Stop the app
2. Go to **Device** → **Erase All Content and Settings**
3. Run the app again

#### On Physical Device (iOS):
1. Delete the app from your device
2. Reinstall from Xcode
3. All data will be fresh

#### Finding the Database Location:
Check the Xcode console for this line:
```
📂 Database location: /path/to/default.store
```

You can manually delete this file if needed.

### 🛠️ For Developers

If you're actively developing and changing the model:

**Option 1: Use In-Memory Storage (Testing)**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: true  // Data won't persist between launches
)
```

**Option 2: Version Your Schema**
When making breaking changes to the model, consider:
- Adding a version identifier
- Implementing migration logic
- Or accepting that users will need to reset

**Option 3: Change Database Name**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    url: URL.applicationSupportDirectory.appending(path: "merit_badges_v2.store")
)
```

### 🎯 Current Model Structure

The `MeritBadge` model includes:
- `id: UUID` - Unique identifier
- `name: String` - Badge name
- `badgeDescription: String` - Description
- `category: String` - Category
- `isEagleRequired: Bool` - Eagle requirement flag
- `requirements: [String]` - List of requirements
- `resourceURL: String?` - Link to Scouting.org
- `completedRequirements: [Bool]` - Completion checkmarks
- `dateStarted: Date?` - When user started
- `dateCompleted: Date?` - When user completed

### ⚠️ Making Schema Changes

If you modify the `MeritBadge` model:
1. The app will automatically reset the database on next launch
2. Check the console for confirmation messages
3. The JSON file will reload all badges automatically

### 📊 Console Messages

You should see one of these:
- ✅ `ModelContainer created successfully` - All good!
- ⚠️ `Failed to create ModelContainer` - Attempting auto-fix
- 🗑️ `Removing old database...` - Cleaning up
- ✅ `ModelContainer created successfully after cleanup` - Fixed!
- ❌ `Failed to create ModelContainer even after cleanup` - Manual intervention needed

### 🆘 Still Having Issues?

1. **Clean Build Folder**: Product → Clean Build Folder (Shift+Cmd+K)
2. **Delete Derived Data**: 
   - Xcode → Preferences → Locations → Derived Data
   - Click the arrow and delete the folder for your project
3. **Restart Xcode**
4. **Check Console**: Look for specific error messages

### 💡 Pro Tip

During active development, you can:
1. Keep the console open to see database messages
2. Add test badges quickly to verify functionality
3. Use the "Reset All Progress" feature in the Info menu to clear data without restarting

---

If you continue to have issues after trying these steps, the problem may be with the model definition itself. Check that all properties in `MeritBadge.swift` are compatible with SwiftData.
