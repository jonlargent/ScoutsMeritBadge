# Scout Theme Design Guide

## 🎨 Official Boy Scouts of America Colors

Your Merit Badge app now uses the **official BSA color palette** for an authentic Scouting experience!

### Primary Colors

| Color | Hex Code | Usage |
|-------|----------|-------|
| **BSA Red** | `#CE2029` | Primary brand color, headers, important actions |
| **BSA Blue** | `#002E5D` | Text, icons, navigation elements |
| **BSA Green** | `#005743` | Completed badges, success states |
| **BSA Tan** | `#CDAA7D` | Backgrounds, cards, secondary elements |
| **Scout Khaki** | `#DABB8E` | Uniform-inspired accents |
| **Eagle Gold** | `#B8860B` | Eagle Required badges, achievements |

### Design Philosophy

The app follows **Scout traditions** with:
- 🦅 **Fleur-de-lis** symbol (Scout emblem)
- ⭐ **Merit badge shaped** indicators
- 🏕️ **Outdoor/wilderness** color palette
- 🎖️ **Achievement-focused** design
- 📜 **Traditional yet modern** aesthetics

---

## 🎯 Visual Elements

### 1. Fleur-de-lis (Scout Symbol)

The **fleur-de-lis** appears throughout the app:
- **Header decorations** on list view
- **Empty state** in detail view
- **Section headers** and dividers
- Represents the **Scout movement worldwide**

**Where you'll see it:**
- Top of Merit Badges list (flanking "My Progress")
- Detail view when no badge is selected
- Section headers in badge details

### 2. Merit Badge Shape

Custom **12-pointed star shape** for badges:
- Reflects actual merit badge design
- Used for status indicators
- Appears in statistic cards
- Eagle Required indicator background

**Design Details:**
- 12 points (like real merit badges)
- Filled with status colors
- Shadow effects for depth
- Animated transitions

### 3. Scout Icons

Specialized icons for Scout activities:
- 🚶 `figure.hiking` - In Progress status
- 🚶‍♂️ `figure.walk` - Start badge action
- ✅ `checkmark.seal.fill` - Completed badges
- 🏆 `trophy.fill` - Completion celebrations
- ⭐ `star.circle.fill` - Eagle Required
- 🌹 `rosette` - Total badges
- 📋 `list.bullet.clipboard` - Requirements

---

## 🎨 Component Styling

### Statistics Cards

**Location:** Top of Merit Badges list

**Design:**
- Merit badge shaped backgrounds
- Color-coded by status
- Drop shadows for depth
- Tan/khaki background panel
- Fleur-de-lis decorations

**Colors:**
- Completed: BSA Green
- In Progress: BSA Blue
- Eagle Done: Eagle Gold

### Badge Rows

**Design:**
- Merit badge shape indicator (left side)
- White card background
- Subtle BSA Blue shadow
- Category in khaki capsule
- Eagle star for required badges

**Status Indicators:**
- Not Started: Gray circle
- In Progress (0%): Blue hiking figure
- In Progress (1-99%): Blue progress ring
- Completed: Green seal with checkmark

### Detail View

**Design Elements:**
- Large badge name in BSA Blue
- Category in khaki capsule
- Eagle badge with merit badge shape
- Progress bar with gradient
- Tan card backgrounds
- Requirement cards with borders
- Scout Red call-to-action button

**Progress Bar:**
- In Progress: Blue gradient
- Completed: Green gradient
- Rounded corners
- Drop shadow
- Percentage display

### Buttons

**Scout Button Styles:**

1. **Prominent** (filled):
   - Background: Solid color
   - Text: White
   - Use for primary actions
   - Example: "Mark Complete"

2. **Outlined** (bordered):
   - Background: Light tint
   - Border: Solid color
   - Text: Match border
   - Example: "Mark In Progress"

**Color Meanings:**
- Green: Complete/Success
- Blue: In Progress/Info
- Red: Reset/Warning
- Gray: Cancel/Secondary

---

## 🎨 Color Usage Guide

### Status Colors

| Status | Color | Icon | Usage |
|--------|-------|------|-------|
| **Completed** | BSA Green | Seal + checkmark | Done badges |
| **In Progress** | BSA Blue | Hiking figure | Active work |
| **Not Started** | Gray | Empty circle | Haven't begun |
| **Eagle** | Eagle Gold | Star | Required badges |
| **Warning** | BSA Red | Alert | Reset actions |

### Background Colors

- **Main Background:** Light blue-gray tint (categoryBackground)
- **Card Backgrounds:** White with shadows
- **Stat Cards:** Tan opacity (statCardBackground)
- **Headers:** Light red tint (headerBackground)
- **Accents:** Khaki for categories

---

## 🏕️ Scout-Themed Features

### 1. "My Progress" Header

**Design:**
- Fleur-de-lis on both sides
- Large, bold title in BSA Blue
- Three statistic cards below
- Tan background panel
- Shadow depth

### 2. Eagle Required Indicator

**Badge List:**
- Golden star icon
- Subtle glow effect

**Detail View:**
- Merit badge shaped background
- Large star icon
- "Eagle Required" text
- Eagle Gold color

### 3. Requirement Cards

**Design:**
- Individual rounded cards
- Numbered with "Requirement X"
- Khaki capsule for number
- Checkmark seal when complete
- Green tint for completed
- Smooth animations

### 4. Call-to-Action Link

**"View on Scouting.org":**
- Scout Red gradient background
- White text
- Safari icon
- Arrow indicator
- Prominent shadow
- Full-width button

---

## 🎯 Design Principles

### 1. **Traditional Colors**
- Uses official BSA palette
- Respects Scout brand
- Recognizable to Scouts

### 2. **Outdoor Aesthetic**
- Earth tones (tan, khaki, green)
- Nature-inspired
- Camping/hiking imagery

### 3. **Achievement Focus**
- Merit badge shapes
- Trophy/completion icons
- Progress visualization
- Celebration of milestones

### 4. **Clear Hierarchy**
- BSA Blue for headers
- Green for success
- Red for important actions
- Gray for secondary

### 5. **Consistent Iconography**
- Scout-themed SF Symbols
- Hiking/outdoor icons
- Merit badge imagery
- Achievement symbols

---

## 💡 Visual Enhancements

### Shadows & Depth

**Cards:** Subtle blue shadow for depth
**Buttons:** Colored shadow matching button
**Shapes:** Soft shadows for elevation

### Gradients

**Scout Gradient:** Red to lighter red
**Outdoor Gradient:** Green to blue
**Tan Gradient:** Light to medium khaki

**Usage:**
- Call-to-action buttons
- Progress bars
- Special indicators

### Animations

**Interactions:**
- Button press: Scale down
- Requirement toggle: Spring animation
- List updates: Smooth fades
- Progress: Animated fill

### Rounded Corners

**Consistency:**
- Small radius (8-10pt): Tags, pills
- Medium radius (12pt): Cards, badges
- Large radius (16pt): Main containers

---

## 🎨 Component Catalog

### FleurDeLis Shape
```
Custom Scout emblem shape
Used for branding
Appears in red or blue
```

### MeritBadgeShape
```
12-pointed star
Matches real badges
Used for indicators
```

### ScoutStatBadge
```
Statistics display
Merit badge shaped background
Color-coded values
```

### ScoutBadgeRow
```
Badge list item
Status indicator
Category capsule
Progress display
```

### ScoutButtonStyle
```
Custom button design
Prominent or outlined
Color-coded actions
Press animations
```

---

## 🏆 Status Visualization

### Not Started → In Progress → Complete

**Visual Journey:**

1. **Not Started**
   - Gray empty circle
   - No background color
   - Minimal visual weight

2. **Just Started (0% done)**
   - Blue hiking figure icon
   - Light blue background
   - "Started [date]" text

3. **In Progress (1-99%)**
   - Blue progress ring
   - Percentage in center
   - Progress bar in detail
   - Blue tint throughout

4. **Completed**
   - Green seal with checkmark
   - Green background tint
   - Trophy icon for date
   - Celebration styling

---

## 🎨 Accessibility

### Color Contrast

All colors meet **WCAG AA standards**:
- Text on backgrounds
- Icons on fills
- Status indicators

### Alternative Indicators

Beyond color, status shown by:
- Icons (checkmark, circle, figure)
- Text labels
- Shapes
- Progress percentages

### Dynamic Type Support

All text scales with system settings:
- Titles
- Body text
- Captions
- Button labels

---

## 📱 Platform Integration

### iOS Native Feel

- Standard navigation
- Native swipe actions
- SF Symbols icons
- System colors for secondary elements

### Scout Brand Identity

- Custom shapes and colors
- Themed components
- Outdoor imagery
- Achievement focus

### Balance

The design **balances**:
- ✅ Scout traditions
- ✅ Modern iOS design
- ✅ User familiarity
- ✅ Brand identity

---

## 🎯 Key Takeaways

1. **Official Colors** - Uses authentic BSA palette
2. **Scout Symbols** - Fleur-de-lis and merit badge shapes
3. **Status Colors** - Green (done), Blue (active), Gray (pending)
4. **Outdoor Theme** - Earth tones and nature icons
5. **Achievement Focus** - Celebrates progress and completion

The Scout theme makes the app feel **authentic, inspiring, and connected to Scouting traditions** while maintaining modern iOS design standards! 🏕️⭐
