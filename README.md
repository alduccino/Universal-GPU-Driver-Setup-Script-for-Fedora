# Universal GPU Driver Setup Script for Fedora

Automatically detects Intel, AMD, or NVIDIA GPUs and installs optimal drivers for Fedora.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Fedora](https://img.shields.io/badge/Fedora-43-blue.svg)](https://getfedora.org/)

## Features

- 🔍 **Automatic GPU Detection** - Intelligently detects Intel, AMD, and NVIDIA GPUs
- 🖥️ **Multi-GPU Support** - Handles hybrid graphics (e.g., Intel iGPU + NVIDIA dGPU in laptops)
- 📦 **Optimal Driver Installation** - Installs the best drivers for each GPU manufacturer
- 🎮 **Gaming Optimizations** - Includes GameMode and MangoHud for performance
- ✅ **Verification** - Tests Vulkan and video acceleration after installation
- 🔧 **AMD GPU Control** - Installs LACT for AMD GPU monitoring and tuning

## Supported GPUs

| Manufacturer | Driver Type | Additional Tools |
|-------------|-------------|------------------|
| **Intel** | Mesa (open-source) | VA-API acceleration |
| **AMD** | Mesa AMDGPU (open-source) | LACT, optional ROCm |
| **NVIDIA** | Proprietary from RPM Fusion | Optional CUDA support |

## Requirements

- Fedora
- Internet connection
- sudo/root privileges

## Installation

### Quick Install

```bash
# Download the script
wget https://raw.githubusercontent.com/alduccino/Universal-GPU-Driver-Setup-Script-for-Fedora/main/universal_gpu_setup.sh

# Make it executable
chmod +x universal_gpu_setup.sh

# Run the script
./universal_gpu_setup.sh
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/alduccino/Universal-GPU-Driver-Setup-Script-for-Fedora.git
   cd Universal-GPU-Driver-Setup-Script-for-Fedora
   ```

2. Make the script executable:
   ```bash
   chmod +x universal_gpu_setup.sh
   ```

3. Run the script:
   ```bash
   ./universal_gpu_setup.sh
   ```

## What Gets Installed

### For Intel GPUs
- Mesa DRI drivers
- Intel media driver
- VA-API support
- Vulkan drivers
- 32-bit libraries for gaming

### For AMD GPUs
- Mesa AMDGPU drivers
- VA-API and VDPAU video acceleration
- Vulkan support
- LACT (Linux AMDGPU Control Tool)
- Optional: ROCm for compute workloads
- 32-bit libraries for gaming

### For NVIDIA GPUs
- Proprietary NVIDIA drivers (akmod)
- NVIDIA CUDA support (optional)
- NVIDIA VA-API driver
- 32-bit libraries for gaming
- Automatic kernel module building

### Gaming Tools (All GPUs)
- **GameMode** - Automatic performance optimizations
- **MangoHud** - FPS overlay and performance monitoring

## Usage Examples

### Verify Installation

```bash
# Check GPU driver status
lspci -k | grep -iE 'VGA|3D' -A 3

# Test Vulkan support
vulkaninfo --summary

# Test video acceleration
vainfo
```

### Gaming with Performance Tools

**For Steam games**, add to launch options:
```
gamemoderun mangohud %command%
```

**For standalone games**:
```bash
gamemoderun mangohud ./game_executable
```

### AMD GPU Control (LACT)

If you have an AMD GPU, launch the LACT control panel:
```bash
lact gui
```

Features include:
- Real-time GPU monitoring (temps, clocks, power)
- Custom fan curves
- Power limit adjustments
- Overclocking capabilities

## Post-Installation Notes

### NVIDIA Users - IMPORTANT! ⚠️

**You MUST reboot after installation** for NVIDIA drivers to work properly:
```bash
sudo reboot
```

### Hybrid Graphics (Optimus Laptops)

If you have both Intel and NVIDIA GPUs, the script detects this configuration. Consider:
- Using `prime-run` to launch games on the NVIDIA GPU
- Installing `envycontrol` for easier GPU switching
- Setting power profiles for better battery life

### Troubleshooting

**Black screen after reboot (NVIDIA)**:
- Boot into recovery mode
- Run: `sudo akmods --force && sudo dracut --force`
- Reboot

**Vulkan not working**:
- Ensure your GPU supports Vulkan
- Check: `vulkaninfo | grep deviceName`

**Video acceleration issues**:
- Verify with: `vainfo`
- Install additional codecs if needed

## Tested On

- ✅ Fedora 43 KDE Edition
- ✅ AMD Radeon RX 7900 XT
- ✅ NVIDIA RTX series (with RPM Fusion)
- ✅ Intel integrated graphics (11th gen and newer)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Areas for Improvement
- Support for older Fedora versions
- Additional GPU vendors
- More gaming optimizations
- Better error handling

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [RPM Fusion](https://rpmfusion.org/) for NVIDIA driver packaging
- [LACT](https://github.com/ilya-zlobintsev/LACT) for AMD GPU control
- [GameMode](https://github.com/FeralInteractive/gamemode) by Feral Interactive
- [MangoHud](https://github.com/flightlessmango/MangoHud) for performance overlay

## Disclaimer

This script modifies system drivers and configurations. While tested on Fedora 43, use at your own risk. Always backup important data before running system modification scripts.

---

**Made with ❤️ for the Fedora Linux community**
