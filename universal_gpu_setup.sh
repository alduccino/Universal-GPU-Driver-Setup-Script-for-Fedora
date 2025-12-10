#!/bin/bash

# Universal GPU Driver Setup Script for Fedora 43 KDE
# Automatically detects Intel, AMD, or NVIDIA GPUs and installs optimal drivers
# Supports multiple GPUs (e.g., Intel iGPU + NVIDIA dGPU laptops)

set -e  # Exit on error

echo "=========================================="
echo "Universal GPU Driver Setup"
echo "For Fedora 43"
echo "=========================================="
echo ""

# Function to detect GPU vendors
detect_gpus() {
    echo "Detecting GPU hardware..."
    echo ""
    
    # Check for Intel GPU
    if lspci | grep -iE "VGA|3D" | grep -iq "Intel"; then
        HAS_INTEL=true
        INTEL_GPU=$(lspci | grep -iE "VGA|3D" | grep -i "Intel")
        echo "✓ Intel GPU detected:"
        echo "  $INTEL_GPU"
    else
        HAS_INTEL=false
    fi
    
    # Check for AMD GPU
    if lspci | grep -iE "VGA|3D" | grep -iq "AMD\|ATI"; then
        HAS_AMD=true
        AMD_GPU=$(lspci | grep -iE "VGA|3D" | grep -iE "AMD|ATI")
        echo "✓ AMD GPU detected:"
        echo "  $AMD_GPU"
    else
        HAS_AMD=false
    fi
    
    # Check for NVIDIA GPU
    if lspci | grep -iE "VGA|3D" | grep -iq "NVIDIA"; then
        HAS_NVIDIA=true
        NVIDIA_GPU=$(lspci | grep -iE "VGA|3D" | grep -i "NVIDIA")
        echo "✓ NVIDIA GPU detected:"
        echo "  $NVIDIA_GPU"
    else
        HAS_NVIDIA=false
    fi
    
    echo ""
    
    # Check if any GPU was detected
    if [[ "$HAS_INTEL" == false && "$HAS_AMD" == false && "$HAS_NVIDIA" == false ]]; then
        echo "⚠ Warning: No recognized GPU detected!"
        echo "This script supports Intel, AMD, and NVIDIA GPUs."
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to install Intel drivers
install_intel_drivers() {
    echo "=========================================="
    echo "Installing Intel GPU Drivers"
    echo "=========================================="
    echo ""
    
    echo "Installing Intel Mesa drivers and media support..."
    sudo dnf install -y mesa-dri-drivers intel-media-driver libva-intel-driver
    
    echo "Installing Intel Vulkan drivers..."
    sudo dnf install -y mesa-vulkan-drivers vulkan-tools
    
    echo "Installing video acceleration..."
    sudo dnf install -y libva libva-utils mesa-va-drivers
    
    echo "Installing 32-bit libraries for gaming..."
    sudo dnf install -y mesa-dri-drivers.i686 mesa-vulkan-drivers.i686
    
    echo "✓ Intel drivers installed successfully"
    echo ""
}

# Function to install AMD drivers
install_amd_drivers() {
    echo "=========================================="
    echo "Installing AMD GPU Drivers"
    echo "=========================================="
    echo ""
    
    echo "Installing Mesa AMDGPU drivers..."
    sudo dnf install -y mesa-dri-drivers mesa-vulkan-drivers vulkan-tools
    
    echo "Installing hardware video acceleration..."
    sudo dnf install -y mesa-va-drivers mesa-vdpau-drivers libva-utils
    
    echo "Installing 32-bit libraries for gaming..."
    sudo dnf install -y mesa-dri-drivers.i686 mesa-vulkan-drivers.i686
    
    echo "Installing LACT (AMD GPU control tool)..."
    if ! dnf copr list | grep -q "ilyaz/LACT"; then
        sudo dnf copr enable ilyaz/LACT -y
    fi
    sudo dnf install -y lact
    sudo systemctl enable --now lactd
    echo "  Launch LACT with: lact gui"
    
    # Optional ROCm for compute workloads
    read -p "Install ROCm for GPU compute workloads (AI/rendering)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing ROCm..."
        sudo dnf install -y rocm-opencl rocm-hip
        echo "✓ ROCm installed"
    fi
    
    echo "✓ AMD drivers installed successfully"
    echo ""
}

# Function to install NVIDIA drivers
install_nvidia_drivers() {
    echo "=========================================="
    echo "Installing NVIDIA GPU Drivers"
    echo "=========================================="
    echo ""
    
    echo "Adding RPM Fusion repositories (required for NVIDIA drivers)..."
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    echo "Installing NVIDIA proprietary drivers..."
    sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
    
    echo "Installing NVIDIA CUDA support (optional for compute workloads)..."
    read -p "Install NVIDIA CUDA for GPU compute? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo dnf install -y xorg-x11-drv-nvidia-cuda
        echo "✓ CUDA support installed"
    fi
    
    echo "Installing 32-bit NVIDIA libraries for gaming..."
    sudo dnf install -y xorg-x11-drv-nvidia-libs.i686
    
    echo "Installing video acceleration for NVIDIA..."
    sudo dnf install -y nvidia-vaapi-driver libva-utils
    
    echo "Building NVIDIA kernel modules (this may take a few minutes)..."
    sudo akmods --force
    sudo dracut --force
    
    echo ""
    echo "✓ NVIDIA drivers installed successfully"
    echo "⚠ IMPORTANT: You MUST reboot for NVIDIA drivers to take effect!"
    echo ""
}

# Function to install common gaming tools
install_gaming_tools() {
    echo "=========================================="
    echo "Installing Gaming Optimization Tools"
    echo "=========================================="
    echo ""
    
    echo "Installing GameMode..."
    sudo dnf install -y gamemode gamemode.i686
    
    echo "Installing MangoHud..."
    sudo dnf install -y mangohud mangohud.i686
    
    echo "✓ Gaming tools installed"
    echo ""
}

# Function to verify installation
verify_installation() {
    echo "=========================================="
    echo "Verifying Installation"
    echo "=========================================="
    echo ""
    
    # Check for loaded GPU drivers
    echo "Checking loaded GPU drivers..."
    lspci -k | grep -iE "VGA|3D" -A 3
    echo ""
    
    # Check Vulkan
    echo "Checking Vulkan support..."
    if vulkaninfo --summary 2>/dev/null | grep -q "deviceName"; then
        echo "✓ Vulkan is working:"
        vulkaninfo --summary 2>/dev/null | grep "deviceName"
    else
        echo "⚠ Vulkan may not be configured properly"
    fi
    echo ""
    
    # Check VA-API
    echo "Checking hardware video acceleration..."
    if vainfo 2>/dev/null | grep -q "VAProfile"; then
        echo "✓ VA-API hardware acceleration is working"
    else
        echo "⚠ VA-API may need configuration"
    fi
    echo ""
}

# Function to display final instructions
show_final_instructions() {
    echo "=========================================="
    echo "Installation Complete!"
    echo "=========================================="
    echo ""
    echo "INSTALLED COMPONENTS:"
    
    if [[ "$HAS_INTEL" == true ]]; then
        echo "✓ Intel GPU drivers (Mesa + media acceleration)"
    fi
    
    if [[ "$HAS_AMD" == true ]]; then
        echo "✓ AMD GPU drivers (Mesa AMDGPU)"
        echo "✓ LACT GPU control application"
    fi
    
    if [[ "$HAS_NVIDIA" == true ]]; then
        echo "✓ NVIDIA proprietary drivers"
        echo "✓ NVIDIA video acceleration"
    fi
    
    echo "✓ Vulkan support"
    echo "✓ Hardware video acceleration"
    echo "✓ 32-bit gaming libraries"
    echo "✓ GameMode for performance boost"
    echo "✓ MangoHud for FPS overlay"
    echo ""
    
    echo "USAGE TIPS:"
    echo "• Use GameMode: gamemoderun <game>"
    echo "• Use MangoHud overlay: mangohud <game>"
    echo "• Combine both: gamemoderun mangohud %command%"
    
    if [[ "$HAS_AMD" == true ]]; then
        echo "• Launch LACT (AMD control): lact gui"
    fi
    
    echo ""
    echo "For Steam games, add to launch options:"
    echo "  gamemoderun mangohud %command%"
    echo ""
    
    echo "VERIFICATION COMMANDS:"
    echo "• Check GPU info: lspci -k | grep -iE 'VGA|3D' -A 3"
    echo "• Test Vulkan: vulkaninfo --summary"
    echo "• Test VA-API: vainfo"
    echo ""
    
    if [[ "$HAS_NVIDIA" == true ]]; then
        echo "=========================================="
        echo "⚠ NVIDIA USERS: REBOOT REQUIRED!"
        echo "=========================================="
        echo "Your system MUST be rebooted for NVIDIA drivers"
        echo "to load properly. Reboot now with: sudo reboot"
        echo ""
    fi
    
    if [[ "$HAS_INTEL" == true && "$HAS_NVIDIA" == true ]]; then
        echo "=========================================="
        echo "HYBRID GRAPHICS DETECTED"
        echo "=========================================="
        echo "You have both Intel and NVIDIA GPUs (Optimus laptop)."
        echo "Consider installing 'envycontrol' or using 'prime-run' to"
        echo "switch between GPUs for better battery life."
        echo ""
    fi
}

# Main execution flow
main() {
    # Detect GPUs
    detect_gpus
    
    # Install drivers based on detected hardware
    if [[ "$HAS_INTEL" == true ]]; then
        install_intel_drivers
    fi
    
    if [[ "$HAS_AMD" == true ]]; then
        install_amd_drivers
    fi
    
    if [[ "$HAS_NVIDIA" == true ]]; then
        install_nvidia_drivers
    fi
    
    # Install common gaming tools
    install_gaming_tools
    
    # Verify installation
    verify_installation
    
    # Show final instructions
    show_final_instructions
}

# Run main function
main
