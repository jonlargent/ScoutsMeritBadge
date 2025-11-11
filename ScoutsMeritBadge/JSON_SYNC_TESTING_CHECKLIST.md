# JSON Sync Testing Checklist

Use this checklist to verify the JSON sync feature is working correctly.

## ✅ Initial Setup Tests

### Test 1: Fresh Install
- [ ] Delete app from device/simulator
- [ ] Build and run
- [ ] Verify all 140+ badges load
- [ ] Check console for "First run detected" message
- [ ] Verify hash is saved to UserDefaults

**Expected Output:**
```
📦 First run detected, loading initial data...
📊 JSON Sync Check:
   Current hash: [some hash]
   Last known hash: none
🔄 JSON file has changed, syncing...
📝 Sync Summary:
   ➕ Added: 140+ new badges
✅ JSON sync completed successfully
```

### Test 2: Second Launch (No Changes)
- [ ] Close app
- [ ] Relaunch app
- [ ] Verify sync is skipped
- [ ] Check badges still present

**Expected Output:**
```
📊 JSON Sync Check:
   Current hash: [hash]
   Last known hash: [same hash]
✓ JSON file unchanged, no sync needed
```

---

## 🔄 Sync Functionality Tests

### Test 3: Add New Badge
- [ ] Mark some badges with progress (dates, requirements)
- [ ] Stop the app
- [ ] Edit `merit_badges_lite.json`
- [ ] Add a new badge at the end:
```json
  {
    "name": "Testing",
    "category": "Test",
    "isEagleRequired": false,
    "resourceURL": "https://www.scouting.org/merit-badges/testing/"
  }
```
- [ ] Build and run
- [ ] Verify "Testing" badge appears
- [ ] Verify previous progress is intact
- [ ] Check console logs

**Expected Output:**
```
📊 JSON Sync Check:
   Current hash: [new hash]
   Last known hash: [old hash]
🔄 JSON file has changed, syncing...
📝 Sync Summary:
   ➕ Added: 1 new badges
   🔄 Updated: 0 badges
✅ JSON sync completed successfully
```

### Test 4: Update Badge Description
- [ ] Pick a badge (e.g., "Programming")
- [ ] Complete some requirements
- [ ] Stop the app
- [ ] Edit its description in JSON
- [ ] Build and run
- [ ] Find the badge
- [ ] Verify description updated
- [ ] Verify requirements still checked

**Expected Output:**
```
📝 Sync Summary:
   ➕ Added: 0 new badges
   🔄 Updated: 1 badges
```

### Test 5: Add Requirements to Existing Badge
- [ ] Pick a badge with progress
- [ ] Stop app
- [ ] Add a new requirement to that badge in JSON
- [ ] Build and run
- [ ] Navigate to badge detail
- [ ] Verify old requirements kept their status
- [ ] Verify new requirement is unchecked

**Expected Output:**
- Existing checked requirements → Still checked ✅
- New requirement → Unchecked ☐

### Test 6: Remove Non-Completed Badge from JSON
- [ ] Pick a badge without any progress
- [ ] Stop app
- [ ] Remove it from JSON
- [ ] Build and run
- [ ] Badge should be deleted from database
- [ ] Check console logs

**Expected Output:**
```
   🗑️ Removing badge: [badge name]
📝 Sync Summary:
   🗑️ Removed: 1 badges (not in JSON)
```

### Test 6b: Remove Completed Badge from JSON
- [ ] Pick a badge and mark it complete
- [ ] Verify completion date is set
- [ ] Stop app
- [ ] Remove it from JSON
- [ ] Build and run
- [ ] Badge should still be in database (achievement preserved)
- [ ] Check console logs

**Expected Output:**
```
   ⭐ Keeping completed badge: [badge name]
📝 Sync Summary:
   🗑️ Removed: 0 badges (not in JSON)
   ⭐ Kept: 1 completed badges (preserved achievements)
```

---

## 🔧 Manual Sync Tests

### Test 7: Manual Sync Button
- [ ] Launch app
- [ ] Edit JSON while app is running
- [ ] Tap ⓘ (info button)
- [ ] Select "Sync with JSON File"
- [ ] Watch console
- [ ] Verify changes appear

**Expected Output:**
```
🔄 Forcing resync...
✅ Manual sync completed
```

### Test 8: Manual Sync (No Changes)
- [ ] Launch app
- [ ] DON'T edit JSON
- [ ] Tap ⓘ → "Sync with JSON File"
- [ ] Verify sync runs anyway (forced)

**Expected Output:**
```
🔄 Forcing resync...
📝 Sync Summary:
   ➕ Added: 0 new badges
   🔄 Updated: 0 badges
✅ Manual sync completed
```

---

## 🐛 Error Handling Tests

### Test 9: Invalid JSON
- [ ] Stop app
- [ ] Break JSON syntax (remove a comma, add extra brace)
- [ ] Build and run
- [ ] Verify app doesn't crash
- [ ] Verify fallback kicks in
- [ ] Check console for error

**Expected Output:**
```
❌ Error during JSON sync: [error details]
```

### Test 10: Missing JSON File
This shouldn't happen in normal use, but tests error handling:
- [ ] Temporarily rename JSON file in bundle
- [ ] Build and run
- [ ] App should handle gracefully

**Expected Output:**
```
❌ JSON file not found: merit_badges_lite.json
```

---

## 📊 Progress Preservation Tests

### Test 11: Complete Badge, Then Update It
1. Setup:
   - [ ] Pick a badge (e.g., "First Aid")
   - [ ] Mark all requirements complete
   - [ ] Verify completion date is set
   
2. Update JSON:
   - [ ] Stop app
   - [ ] Add one new requirement to that badge
   - [ ] Build and run
   
3. Verify:
   - [ ] Old requirements still checked
   - [ ] New requirement unchecked
   - [ ] Badge no longer marked complete (because of new req)
   - [ ] Start date preserved
   - [ ] Completion date cleared (because incomplete)

### Test 12: In Progress Badge with Dates
1. Setup:
   - [ ] Pick a badge
   - [ ] Mark it "In Progress" (swipe right)
   - [ ] Check some (not all) requirements
   - [ ] Note the start date
   
2. Update JSON:
   - [ ] Stop app
   - [ ] Change badge description
   - [ ] Build and run
   
3. Verify:
   - [ ] Start date unchanged
   - [ ] Checked requirements still checked
   - [ ] Description updated
   - [ ] Still marked "In Progress"

### Test 13: Eagle Required Status Change
1. Setup:
   - [ ] Pick a non-Eagle badge
   - [ ] Add progress to it
   
2. Update JSON:
   - [ ] Change `isEagleRequired: false` to `true`
   - [ ] Build and run
   
3. Verify:
   - [ ] Badge now shows star ⭐
   - [ ] Progress preserved
   - [ ] Eagle count in stats increased

---

## 🎯 Performance Tests

### Test 14: Startup Time
- [ ] Cold start the app
- [ ] Time from launch to badges visible
- [ ] Should be < 1 second total
- [ ] Check console for timing info

### Test 15: Large Update Performance
- [ ] Add 10+ badges at once
- [ ] Build and run
- [ ] Sync should complete quickly (< 500ms)

### Test 16: Hash Check Speed
- [ ] Launch app (no changes)
- [ ] Hash check should be nearly instant (< 10ms)
- [ ] Check console timestamps

---

## 📱 UI Tests

### Test 17: Statistics Update
1. Before sync:
   - [ ] Note badge count in stats
   
2. Add badges:
   - [ ] Add 3 new badges to JSON
   - [ ] Sync
   
3. Verify:
   - [ ] Total count increased by 3
   - [ ] Statistics accurate
   - [ ] Filtering still works

### Test 18: Search After Sync
- [ ] Add a uniquely named badge
- [ ] Sync
- [ ] Use search to find it
- [ ] Verify it appears in results

### Test 19: Detail View After Sync
- [ ] Update a badge's description
- [ ] Sync
- [ ] Navigate to that badge's detail view
- [ ] Verify new description shows

---

## 🔍 Debug View Tests

### Test 20: Debug View Stats
- [ ] Uncomment or add `JSONSyncDebugView` to navigation
- [ ] Open debug view
- [ ] Verify stats shown correctly
- [ ] Try each button

### Test 21: Clear Sync History
- [ ] Open debug view
- [ ] Tap "Clear Sync History"
- [ ] Restart app
- [ ] Should force full sync
- [ ] Verify in console

### Test 22: Clear Database
- [ ] Open debug view
- [ ] Tap "Clear All Badges"
- [ ] Verify count goes to 0
- [ ] Restart app
- [ ] Should reload from JSON

---

## ✨ Edge Cases

### Test 23: Duplicate Badge Names
- [ ] Add two badges with same name to JSON
- [ ] Sync
- [ ] Only first should be used (name is unique)
- [ ] Second should be ignored or update first

### Test 24: Empty Requirements
- [ ] Create badge with empty requirements array
- [ ] Sync
- [ ] Badge should load correctly
- [ ] Progress should be 0%

### Test 25: Special Characters
- [ ] Create badge with special characters in name
- [ ] Example: "Photography & Video"
- [ ] Sync
- [ ] Verify it loads and displays correctly

### Test 26: Very Long Badge Name
- [ ] Create badge with 100+ character name
- [ ] Sync
- [ ] Verify UI handles it gracefully
- [ ] Text should truncate properly

---

## 📝 Documentation Tests

### Test 27: Console Logs Accuracy
- [ ] Review all console output
- [ ] Verify emojis render correctly
- [ ] Verify counts are accurate
- [ ] Verify timestamps present

### Test 28: Statistics Accuracy
- [ ] Manually count badges in JSON
- [ ] Compare to "Total Badges" in app
- [ ] Should match exactly
- [ ] Verify Eagle required count

---

## 🚀 Production Readiness

### Final Checklist
- [ ] All tests pass
- [ ] No crashes observed
- [ ] Console logs clear and helpful
- [ ] Performance acceptable
- [ ] User progress always preserved
- [ ] Error handling graceful
- [ ] Documentation complete
- [ ] Code commented
- [ ] Ready to ship! 🎉

---

## Notes Section

Use this space to record any issues or observations:

```
Date: ___________
Tester: ___________

Issues Found:
1. 
2. 
3. 

Observations:
- 
- 
- 

Performance Notes:
- Startup time: ___ ms
- Sync time: ___ ms
- Hash check: ___ ms
```

---

## Quick Test Script

For rapid testing, run through this minimal set:

1. **Fresh Start**: Delete app → Install → Verify 140+ badges load
2. **Add Badge**: Edit JSON → Add one → Restart → Verify appears
3. **Keep Progress**: Mark progress → Update JSON → Restart → Verify kept
4. **Manual Sync**: Edit JSON while running → Tap sync → Verify works
5. **Stats Check**: Verify counts match reality

If all 5 pass: ✅ Core functionality working!
