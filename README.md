# My dotfiles

Distro: Arch Linux
WM: Sway (swayidle, swaybg, swaylock-effects)
Bar: Waybar
Colors: pywal (waybar, wofi, sway borders and swaylock follow the wallpaper)
Font: GoogleSansCode Nerd Font (Medium)
Icons: Papirus
Editor: NeoVim
Terminal: Alacritty w/ Starship
Launcher: Wofi
Notifications: SwayNC
OSD: SwayOSD (pywal colors)
Monitor Manager: Kanshi

# Install
```bash
# Core
sudo pacman -S sway swayidle swaybg waybar wofi alacritty kanshi swaync swayosd \
  stow zsh neovim starship

# Fonts and icons sudo pacman -S ttf-googlesanscode-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
  papirus-icon-theme

# Waybar media module (mediaplayer.py), volume, brightness, screenshots
sudo pacman -S playerctl python-gobject libpulse pavucontrol brightnessctl \
  grim slurp wl-clipboard satty imagemagick htop   # imagemagick: runcat frames

# AUR: lock screen with blur and clock; pywal
yay -S swaylock-effects python-pywal16
```

# Setup
```bash
git clone git@github.com:geerizzle/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow */          # not `stow *`: that also matches README.md

# Generate the pywal colors before the first sway start.
# Sway, waybar, wofi and swaylock read from ~/.cache/wal/.
~/.local/bin/wallpaper ~/Pictures/some-image.png
```

- Only NVIDIA (proprietary driver): hide sway's unsupported GPU warning:
  `echo 'SWAY_UNSUPPORTED_GPU=true' | sudo tee -a /etc/environment`

# Scripts (`scripts/.local/bin`)
- `wallpaper [image]`: sets the wallpaper and runs pywal. It reloads sway and waybar
  and updates the lock screen background. With no argument, it picks a random image from `~/Pictures`.
- `waybar/.config/waybar/runcat.py`: RunCat CPU module; the cat runs faster with CPU load (frames: GPL-3, see `runcat/NOTICE.md`).
- `wallpaper-picker`: wofi menu of `~/Pictures` with thumbnails that runs `wallpaper` on the choice (Super+Shift+W).
- `waybar/.config/waybar/weather.py`: weather from wttr.in; click it to pick a city (`auto` = detect by IP).
- `powermenu`: wofi menu to lock, log out, suspend, reboot or shut down (Super+Shift+E).

Sway starts without `~/.local/bin` in `PATH`. Bind the scripts with their full path
(`exec ~/.local/bin/...`).

# Notes
- Swaylock is a pywal template: edit `wal/.config/wal/templates/swaylock`,
  not `~/.config/swaylock/config` (that file links to the rendered copy in `~/.cache/wal/`).
- If Papirus is installed by hand in `~/.local/share/icons`, build its icon cache, or wofi opens slowly:
  `gtk-update-icon-cache -f ~/.local/share/icons/Papirus`
