# TW3GhostMode
1. Unpacked resource files for easy editing with [W3Edit](https://drive.google.com/file/d/0B3axqSlhNHOOYmpkWk83TXRkZmM/view) by Saracen. [CDPR forum topic about the editor](https://forums.cdprojektred.com/forum/en/the-witcher-series/the-witcher-3-wild-hunt/mod-discussions/58758-mod-editor).
2. Scripts.
3. Localization files.
4. Menu.
5. Design documents (not very well structured, not 100% accurate, part English, part Russian).

Using this repository requires intermediate modding knowledge: you need [W3Edit](https://drive.google.com/file/d/0B3axqSlhNHOOYmpkWk83TXRkZmM/view) set up and working and [w3strings encoder](https://www.nexusmods.com/witcher3/mods/1055/?).

Using "Clone or download" button above you can download the whole repository as a zip package. And if you have [GitHub desktop utility](https://desktop.github.com/), you can use "Open in Desktop" link to sync cloud repository with your local one.

Either way, you'll get a folder with a structure similar to that of the repository. Open modGhostMode.w3modproj with W3Edit and press "Pack and install mod" icon to install it into your Mods folder. Then go inside "[Your Local GM Repository]\modGhostMode" folder and manually copy "scripts" folder into your "[The Witcher 3 folder]\Mods\modGhostMode\content" folder, replacing the existing "scripts" folder. Then update the menu by copying "[Your Local GM Repository]\modGhostMode\menu\modSignsConfig.xml" file to the "[The Witcher 3 folder]\bin\config\r4game\user_config_matrix\pc" folder. After that open "[Your Local GM Repository]\modGhostMode\localization" folder and compile (encode) proper localization file (see encoding-help.txt, I'm assuming English localization below) with w3strings encoder:

```
w3strings.exe --encode en.csv --id-space 992
```

You can place w3strings.exe directly into the "[Your Local GM Repository]\modGhostMode\localization" folder. Successful encoding will produce several files, the one you need is en.csv.w3strings: rename it to en.w3strings and copy it to the "[The Witcher 3 folder]\Mods\modGhostMode\content" folder, replacing the existing file.

Run Script Merger/Mod Merger to fix your current merges.