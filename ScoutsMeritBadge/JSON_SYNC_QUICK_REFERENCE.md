# Quick Reference: JSON Sync Feature

## ⚡ Quick Start

### Want to add/update merit badges?

1. Edit `merit_badges_lite.json`
2. Restart the app (or tap ⓘ → "Sync with JSON File")
3. Done! Changes appear automatically with user progress preserved

## 📝 Common Tasks

### Add a New Merit Badge
```json
{
  "name": "Your Badge Name",
  "category": "Category Name",
  "isEagleRequired": false,
  "resourceURL": "https://www.scouting.org/merit-badges/badge-name/"
}
```
**Result**: Badge appears on next launch, no user data affected

### Update Badge Information
Change any field in JSON (except `name`)
**Result**: Changes sync automatically, user progress preserved

### Rename a Badge
⚠️ Renaming creates a new badge (name is the unique identifier)
**Workaround**: Database keeps the old badge with user's progress

## 🎯 Categories Available

- **Business**: American Business, American Labor, Entrepreneurship, Personal Management, Salesmanship, Truck Transportation
- **Citizenship**: American Cultures, American Heritage, Citizenship (4 types), Crime Prevention, Law
- **Health and Safety**: Dentistry, Emergency Preparedness, Fire Safety, First Aid, Health Care Professions, Lifesaving, Medicine, Public Health, Safety, Search and Rescue, Traffic Safety, Veterinary Medicine
- **Nature**: Animal Science, Astronomy, Bird Study, Dog Care, Environmental Science, Fish & Wildlife Management, Forestry, Gardening, Geology, Insect Study, Mammal Study, Nature, Oceanography, Pets, Plant Science, Reptile and Amphibian Study, Soil and Water Conservation, Sustainability, Weather
- **Outdoor Skills**: Backpacking, Camping, Climbing, Cooking, Exploration, Fishing, Fly Fishing, Geocaching, Hiking, Horsemanship, Orienteering, Pioneering, Whitewater, Wilderness Survival
- **Sports and Fitness**: Archery, Athletics, Canoeing, Cycling, Golf, Kayaking, Motorboating, Multisport, Personal Fitness, Rifle Shooting, Rowing, Scuba Diving, Shotgun Shooting, Skating, Small-Boat Sailing, Snow Sports, Sports, Swimming, Water Sports
- **STEM**: Artificial Intelligence, Aviation, Chemistry, Composite Materials, Cybersecurity, Digital Technology, Electricity, Electronics, Energy, Engineering, Inventing, Mining in Society, Nuclear Science, Programming, Pulp and Paper, Radio, Robotics, Space Exploration, Surveying
- **Arts and Hobbies**: Animation, Archaeology, Art, Basketry, Bugling, Chess, Coin Collecting, Collections, Game Design, Genealogy, Graphic Arts, Indian Lore, Leatherwork, Model Design and Building, Moviemaking, Music, Painting, Photography, Pottery, Railroading, Sculpture, Stamp Collecting, Textile, Theater, Wood Carving
- **Trades**: Architecture, Automotive Maintenance, Drafting, Farm Mechanics, Home Repairs, Landscape Architecture, Metalwork, Plumbing, Welding, Woodworking
- **Skills**: Communication, Disabilities Awareness, Family Life, Fingerprinting, Journalism, Public Speaking, Reading, Scholarship, Scouting Heritage, Signs Signals and Codes

## 🔧 Manual Sync

**In-App**: Tap ⓘ (top-right) → "Sync with JSON File"

**Result**: Immediate sync regardless of whether file changed

## 🐛 Debugging

### View Console Logs
Look for these emoji indicators:
- 📊 Sync check starting
- 🔄 Sync in progress
- ✅ Sync successful
- ❌ Sync error
- 📝 Sync summary with statistics

### Reset Everything
1. Tap ⓘ → "Reset All Progress" (keeps badges, clears progress)
2. Or use `JSONSyncDebugView` for full database control

### Clear Sync History
Use `JSONSyncDebugView` → "Clear Sync History"
Forces full resync on next launch

## 💾 What's Stored Where

### UserDefaults
- `lastJSONSyncHash`: SHA256 of last synced JSON
- `lastSyncDate`: Timestamp of last sync

### SwiftData Database
- All merit badge data
- User progress (dates, completions, requirements)

### JSON File (Bundle)
- Source of truth for badge definitions
- Read-only at runtime
- Edit in Xcode before build

## ⚙️ Sync Behavior Configuration

**Smart Deletion**: Non-completed badges removed from JSON are deleted. Completed badges are kept to preserve achievements.

### Change Deletion Behavior

**Current (Default)**: Keep completed badges, delete non-completed
```swift
// In MeritBadgeJSONSyncService.swift
for (_, badge) in existingBadgesByName {
    if badge.isCompleted {
        keptCompletedCount += 1  // Keep achievements
    } else {
        modelContext.delete(badge)  // Remove non-completed
        removedCount += 1
    }
}
```

**Option: Delete ALL removed badges** (including completed)
```swift
for (_, badge) in existingBadgesByName {
    modelContext.delete(badge)  // Delete everything
    removedCount += 1
}
```

**Option: Keep ALL removed badges**
```swift
// Don't delete anything - just count them
removedCount = existingBadgesByName.count
```

## 📊 Statistics

Track sync in console:
```
➕ Added: X new badges
🔄 Updated: X badges  
🗑️ Removed: X badges (not in JSON)
⭐ Kept: X completed badges (preserved achievements)
```

## ❓ FAQ

**Q: Does sync happen every launch?**  
A: Hash check happens every launch (~5ms), full sync only when file changes

**Q: What if JSON is invalid?**  
A: Error logged, app continues with existing database

**Q: Can I see sync in UI?**  
A: Currently console only, but check "Last sync" in stats menu

**Q: Will my progress be lost?**  
A: No, all user progress is preserved during sync

**Q: What triggers a sync?**  
A: Any edit to JSON file (add/remove/update badges)

**Q: Can I force sync while app is running?**  
A: Yes, use the manual sync button in info menu

## 🚀 Next Steps

1. **Try it**: Edit JSON → Restart app → See changes
2. **Monitor**: Watch console for sync logs
3. **Test**: Use `JSONSyncDebugView` for detailed testing
4. **Customize**: Adjust sync behavior in `MeritBadgeJSONSyncService.swift`

---

**Need Help?** Check these files:
- `JSON_SYNC_FEATURE.md` - Full documentation
- `IMPLEMENTATION_SUMMARY.md` - Technical details
- `MeritBadgeJSONSyncService.swift` - Source code with comments
