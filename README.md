# SystemCleaner 🧹

Ultimate Windows cleaning tool by **Fox1cek**. One command to clean temp files, browser cache, Windows bloat, and free up gigabytes of space.

## ⚡ Quick Start (One Line)

```powershell
irm https://raw.githubusercontent.com/Fox1cek/SystemCleaner/main/cleaner.ps1 | iex
```

## 📊 What Gets Cleaned

| Category | What It Does |
|----------|-------------|
| **System Temp** | Windows Temp, User Temp, System temp folders |
| **Browser Data** | Chrome, Edge, Firefox cache & code cache |
| **Windows Update** | Old update downloads, Delivery Optimization |
| **Event Logs** | Clears all Windows event logs |
| **Recycle Bin** | Empties trash |
| **Prefetch** | Old unused prefetch files (30+ days) |
| **DNS Cache** | Flushes DNS resolver cache |
| **Thumbnail Cache** | Windows explorer thumbnail database |
| **Recent Files** | Recent documents history |
| **Crash Dumps** | Application and system crash logs |
| **Error Reports** | Windows Error Reporting (WER) files |
| **Font Cache** | Corrupted/cached font data |
| **Component Store** | Analyzes reclaimable WinSxS space |

## 🚀 Features

- **Safe** - Only removes cache/temp files, never personal data
- **Fast** - Takes 30-60 seconds
- **Informative** - Shows exactly how much space was freed
- **Deep Clean Option** - Optional aggressive mode for more space

## 📋 Example Output

```
==========================================
   SystemCleaner - Ultimate PC Cleaner
              by Fox1cek
==========================================

--- Windows System Temp ---
[CLEAN] Windows Temp 1.24 GB
[CLEAN] User Temp 856.45 MB

--- Browser Data ---
[CLEAN] Chrome Cache 324.12 MB

...

==========================================
   CLEANUP COMPLETE!
==========================================

Total Space Freed: 3.42 GB
Items Cleaned: 12
```

## 🔒 Safety

- ✅ No personal files touched
- ✅ No installed apps removed
- ✅ No Windows settings changed
- ✅ Only cache, temp, and logs cleaned

## 🎯 When To Use

- Before installing large games
- When disk space is low
- Monthly maintenance
- Before Windows updates
- When PC feels sluggish

## ⚙️ Requirements

- Windows 10/11
- Administrator rights (auto-requests)
- Internet (for one-line install only)

## 🤝 Like It?

Star ⭐ the repo on GitHub!

## 📄 License

MIT - Use freely, modify as needed.
