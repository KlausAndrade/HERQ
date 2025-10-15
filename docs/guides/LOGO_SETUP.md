# HERQ Logo Setup Instructions

## ✅ Code Updated

The About HERQ screen has been updated to display the HERQ logo image.

## 📁 Save the Logo Image

**Please save the HERQ logo image to:**

```
assets/images/herq_logo.png
```

### Steps:

1. Save the HERQ logo image (the one with the HQ monogram and text) to your computer
2. Move/Copy it to: `assets/images/herq_logo.png`
3. The image should be:
   - **Format**: PNG (with transparency if possible)
   - **Recommended size**: 560x280 pixels (or similar 2:1 ratio)
   - **Background**: Transparent or dark (will be displayed on a gradient background)

### What the Code Does:

- Displays the logo at 280x140 points (scales 2x for retina)
- Includes rounded corners (12px radius)
- Has a fallback to the fitness icon if image is not found
- Centers the logo in a beautiful card container

### Current State:

✅ Code is ready and waiting for the image
🔄 Logo will display automatically once you save the image to `assets/images/herq_logo.png`
⚠️ If image is not found, it will show the fitness icon as fallback

---

## 🎨 Logo Display

The logo will appear:
- In a gradient background container
- With subtle shadow effects
- Centered on the About HERQ screen
- Above the brand story text

## 🚀 After Saving the Image

No code changes needed! Just:
1. Save the logo to `assets/images/herq_logo.png`
2. Run `flutter pub get` (optional, assets are auto-detected)
3. Hot reload the app

The logo will appear automatically!

