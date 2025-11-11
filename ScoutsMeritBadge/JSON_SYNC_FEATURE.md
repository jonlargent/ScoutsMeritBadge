# JSON Sync Feature

## Overview

The app now automatically checks if the `merit_badges_lite.json` file has been changed on startup and syncs the changes with the database while **preserving all user progress**.

## How It Works

### 1. Automatic Sync on Startup

When the app launches, it:
- Calculates a SHA256 hash of the JSON file
- Compares it with the last known hash (stored in UserDefaults)
- If different, performs a smart sync that:
  - **Adds** new badges from JSON
  - **Updates** existing badges (description, category, requirements, etc.)
  - **Preserves** user progress (completion status, dates, completed requirements)
  - **Removes** badges not in JSON, UNLESS they are completed (achievements preserved)
  - **Keeps** completed badges even if removed from JSON (to honor user accomplishments)

### 2. Smart Progress Preservation

When requirements are updated:
- The system tries to match old requirements with new ones
- If a requirement text matches exactly, its completion status is preserved
- If requirements are added, they start as incomplete
- If all requirements are still complete, the completion date is maintained

### 3. Manual Sync Option

Users can force a sync by:
1. Tapping the info button (ⓘ) in the top-right corner
2. Selecting "Sync with JSON File"

## Implementation Details

### MeritBadgeJSONSyncService

The sync service handles:
- **Hash Calculation**: Uses CryptoKit's SHA256 to detect file changes
- **Merge Logic**: Intelligently merges JSON data with database records
- **Progress Preservation**: Maintains all user progress during updates
- **Error Handling**: Falls back to safe defaults if sync fails

### Storage

Sync metadata is stored in UserDefaults:
- `lastJSONSyncHash`: SHA256 hash of last synced JSON
- `lastSyncDate`: Date of last successful sync

## Usage Example

### Adding New Badges

1. Edit `merit_badges_lite.json` to add new badges:
```json
{
  "name": "Medicine",
  "category": "Health and Safety",
  "isEagleRequired": false,
  "resourceURL": "https://www.scouting.org/merit-badges/medicine/"
}
```

2. Restart the app or tap "Sync with JSON File"
3. The new badge appears automatically
4. All existing user progress remains intact

### Updating Badge Information

1. Edit existing badge in JSON (e.g., change description or add requirements)
2. App automatically syncs on next launch
3. User progress on that badge is intelligently preserved

### Removed Badges

Badges removed from JSON are handled intelligently:
- **Non-completed badges**: Deleted from database
- **Completed badges**: Kept to preserve user achievements

This means users keep their earned badges even if they're removed from the official list, honoring their accomplishments.

To change this behavior and delete ALL removed badges (including completed), modify `MeritBadgeJSONSyncService.swift`:

```swift
for (_, badge) in existingBadgesByName {
    // Remove the if statement to delete all
    modelContext.delete(badge)
    removedCount += 1
}
```

## Console Output

The sync process logs helpful information:

```
📊 JSON Sync Check:
   Current hash: a1b2c3d4...
   Last known hash: x9y8z7w6...
🔄 JSON file has changed, syncing...
📝 Sync Summary:
   ➕ Added: 5 new badges
   🔄 Updated: 3 badges
   🗑️ Removed: 2 badges (not in JSON)
   ⭐ Kept: 1 completed badges (preserved achievements)
✅ JSON sync completed successfully
   Last sync: Nov 11, 2025 at 3:45 PM
```

## Testing

### Force a Resync
```swift
let syncService = MeritBadgeJSONSyncService(modelContext: modelContext)
try await syncService.forceResync()
```

### Clear Sync History
```swift
let syncService = MeritBadgeJSONSyncService(modelContext: modelContext)
syncService.clearSyncHistory()
```

### Check Last Sync Date
```swift
let syncService = MeritBadgeJSONSyncService(modelContext: modelContext)
if let lastSync = syncService.getLastSyncDate() {
    print("Last synced: \(lastSync)")
}
```

## Benefits

✅ **Automatic Updates**: Changes to JSON automatically appear in the app
✅ **Progress Preservation**: User data is never lost during updates
✅ **Performance**: Hash comparison is fast - only syncs when needed
✅ **Transparent**: Clear console logging shows what's happening
✅ **Manual Control**: Users can force sync if needed
✅ **Safe**: Falls back gracefully if sync fails

## Future Enhancements

Potential improvements:
- Visual feedback during sync (loading indicator)
- Notification when new badges are added
- Sync statistics in the UI
- Option to restore deleted badges
- Cloud sync integration
