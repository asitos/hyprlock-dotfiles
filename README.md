# hyprlock config

a lightweight [hyprlock](https://wiki.hyprland.org/Hyprland/hyprlock/) configuration inspired by the [ly](https://github.com/fairyglade/ly) TUI display manager, featuring a dynamic ASCII login box, retro big clock, and a Spotify/MPRIS media player widget.

<div align="center">

![hyprlock_showcase](assets/hyprlock_showcase.png)
*idle hyprlock screen*

</div>

---

## requirements

### 1. terminess nerd font (required)
this configuration relies on **terminess nerd font** (`terminess nerd font mono`) for its TUI box borders, retro typography, and media player glyphs. Without this font, the ASCII boxes and alignment will not render correctly.

#### install terminess nerd font:

- **arch linux**:
  ```bash
  sudo pacman -S ttf-terminus-nerd
  ```

- **fedora**:
  ```bash
  sudo dnf install terminus-fonts-nerd-fonts
  ```

- **debian / ubuntu / other distros (manual)**:
  ```bash
  mkdir -p ~/.local/share/fonts/TerminessNerdFont
  curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Terminus.tar.xz
  tar -xf Terminus.tar.xz -C ~/.local/share/fonts/TerminessNerdFont
  rm Terminus.tar.xz
  fc-cache -fv
  ```

verify the font is available:
```bash
fc-list : family | grep -i "Terminess"
```

### 2. dependencies
- **[hyprlock](https://wiki.hyprland.org/Hyprland/hyprlock/)**: screen locker for Hyprland.
- **playerctl**: Fetches media player metadata for the now-playing bar.
  - arch: `sudo pacman -S playerctl`
  - debian/ubuntu: `sudo apt install playerctl`
  - fedora: `sudo dnf install playerctl`

---

## installation

### automated install (recommended)

1. clone the repository into `~/.config/hyprlock`:
   ```bash
   git clone https://github.com/asitos/hyprlock-dotfiles.git ~/.config/hyprlock
   cd ~/.config/hyprlock
   ```

2. run the install script:
   ```bash
   ./script/install.sh
   ```
   *(or `./scripts/install.sh`)*

#### what the installer does:
- links `hyprlock.conf` to `~/.config/hypr/hyprlock.conf` (automatically backing up any existing config).
- sets proper executable permissions on all helper scripts.
- checks if **terminess nerd font** is installed and offers automated installation if missing.
- verifies system dependencies (`hyprlock`, `playerctl`).
- uses absolute `$HOME/.config/hyprlock/` paths so hyprlock functions reliably regardless of launch directory.

---

### manual install

if you prefer installing manually:

1. clone or copy this repository to `~/.config/hyprlock`:
   ```bash
   git clone https://github.com/asitos/hyprlock-dotfiles.git ~/.config/hyprlock
   ```

2. make scripts executable:
   ```bash
   chmod +x ~/.config/hyprlock/scripts/*.sh
   ```

3. symlink `hyprlock.conf` to hyprland's default config path:
   ```bash
   mkdir -p ~/.config/hypr
   ln -sf ~/.config/hyprlock/hyprlock.conf ~/.config/hypr/hyprlock.conf
   ```

4. install the required `ttf-terminus-nerd` font (see instructions above).

---

## usage

lock your screen manually to test:
```bash
hyprlock
```

to lock automatically via Hyprland keybind, add to `~/.config/hypr/hyprland.lua`:
```lua
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
```
