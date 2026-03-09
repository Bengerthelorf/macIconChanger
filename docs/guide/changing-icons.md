# Changing Icons

## Using the GUI

### Search Online

1. Select an app from the sidebar.
2. Browse the icons from [macOSicons.com](https://macosicons.com/) in the main area.
3. Use the **Style** dropdown to filter by style (e.g., Liquid Glass).
4. Click an icon to apply it.

![Searching for icons](/images/search-icons.png)

### Choose a Local File

Click **Choose from the Local** (or press <kbd>Cmd</kbd>+<kbd>O</kbd>) to open a file picker. Supported formats: PNG, JPEG, ICNS, TIFF, HEIC, WebP, BMP, GIF, SVG.

### Drag & Drop

Drag an image file from Finder directly onto the app's icon area. A blue highlight will appear to confirm the drop zone.

![Drag and drop](/images/drag-drop.png)

### Restore Default Icon

To restore an app's original icon:
- Click the **Restore Default** button (or press <kbd>Cmd</kbd>+<kbd>Delete</kbd>)
- Or right-click the app in the sidebar and select **Restore Default Icon**

## Escape Squircle Jail (macOS Tahoe)

macOS 26 Tahoe forces all app icons into a squircle (rounded square) shape. Apps with non-conforming icons get shrunk and placed on a gray squircle background.

IconChanger can fix this by re-applying an app's own bundled icon as a custom icon, which bypasses macOS's squircle enforcement.

### Per App

Right-click an app in the sidebar and select **Escape Squircle Jail**.

### All Apps at Once

Click the **⋯** menu in the toolbar and select **Escape Squircle Jail (All Apps)**. This processes all apps that don't already have custom icons.

::: tip
Custom icons set this way do **not** support macOS Tahoe's Clear, Tinted, or Dark icon modes — they remain static. This is a system limitation.
:::

::: info
Your background service will automatically re-apply icons after app updates, keeping them out of squircle jail.
:::

## Icon Caching

When you apply a custom icon, it is automatically cached. This means:
- Your custom icons can be restored after app updates
- The background service can reapply them on a schedule
- You can export and import your icon configurations

Manage cached icons in **Settings** > **Icon Cache**.

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| <kbd>Cmd</kbd>+<kbd>O</kbd> | Choose a local icon file |
| <kbd>Cmd</kbd>+<kbd>Delete</kbd> | Restore default icon |
| <kbd>Cmd</kbd>+<kbd>R</kbd> | Refresh icon display |

## Tips

- If no icons are found for an app, try [setting an alias](./aliases) with a simpler name.
- The counter (e.g., "12/15") shows how many icons loaded successfully out of the total found.
- Icons are sorted by popularity (download count) by default.
