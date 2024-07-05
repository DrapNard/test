#!/usr/bin/bash


# Initialize the status variables for each program
git_installed=0
wget_installed=0
qemu_full_installed=0
libvirt_installed=0
dnsmasq_installed=0
python_installed=0
virt_manager_installed=0
virsh_installed=0
python_pypresence_installed=0
nbd_installed=0

kernel_ok=1
cpu_ok=1
motherboard_virt_ok=1
motherboard_uefi_ok=1
ram_ok=1
disk_space_ok=1
wsl_ok=1

showLoading() {
    pid=$1
    delay=0.1
    spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to check if a program is installed
checkInstalledProgram() {
    if ! command -v "$1" &> /dev/null
    then
        echo -e "     \e[31m○\e[0m $1 is not installed"
        eval $2=0  # Set the corresponding variable to 0 if not installed
    else
        echo -e "     \e[32m●\e[0m $1 is installed"
        eval $2=1  # Set the corresponding variable to 1 if installed
    fi
}

checkInstalledlibvirt() {
    if ! sudo systemctl status libvirtd &> /dev/null
    then
        echo -e "     \e[31m○\e[0m $1 is not installed"
        eval $2=0  # Set the corresponding variable to 0 if not installed
    else
        echo -e "     \e[32m●\e[0m $1 is installed"
        eval $2=1  # Set the corresponding variable to 1 if installed
    fi
}

checkPipPackage(){
    if ! pip show $1 &> /dev/null
    then
        echo -e "     \e[31m○\e[0m $1 is not installed"
        eval $2=0  # Set the corresponding variable to 0 if not installed
    else
        echo -e "     \e[32m●\e[0m $1 is installed"
        eval $2=1  # Set the corresponding variable to 1 if installed
    fi
}

# Function to check kernel version
checkKernelVersion() {
    required_version=5
    kernel_version=$(uname -r | cut -d. -f1)
    if (( kernel_version >= required_version )); then
        echo -e "     \e[32m●\e[0m The Linux Kernel version is $kernel_version"
        kernel_ok=1
    else
        echo -e "     \e[31m○\e[0m The Linux Kernel version is $kernel_version, needs to be $required_version or higher"
        kernel_ok=0
    fi
}

# Function to check if virtualization is supported
checkVirtualization() {
    if grep -E -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
        echo -e "     \e[32m●\e[0m Virtualization is supported"
        motherboard_virt_ok=1
    else
        echo -e "     \e[31m○\e[0m Virtualization is not supported"
        motherboard_virt_ok=0
    fi
}

# Function to check if UEFI is supported
checkUEFI() {
    if [ -d /sys/firmware/efi ]; then
        echo -e "     \e[32m●\e[0m UEFI is supported"
        motherboard_uefi_ok=1
    else
        echo -e "     \e[31m○\e[0m UEFI is not supported"
        motherboard_uefi_ok=0
    fi
}

# Function to check CPU cores
checkCPUCores() {
    required_cores=2
    cpu_cores=$(nproc)
    if (( cpu_cores >= required_cores )); then
        echo -e "     \e[32m●\e[0m CPU has $cpu_cores cores"
        cpu_ok=1
    else
        echo -e "     \e[31m○\e[0m CPU has $cpu_cores cores, needs at least $required_cores"
        cpu_ok=0
    fi
}

# Function to check RAM
checkRAM() {
    required_ram=4
    total_ram=$(free -g | awk '/^Mem:/{print $2}')
    if (( total_ram >= required_ram )); then
        echo -e "     \e[32m●\e[0m System has $total_ram GB of RAM"
        ram_ok=1
    else
        echo -e "     \e[31m○\e[0m System has $total_ram GB of RAM, needs at least $required_ram GB"
        ram_ok=0
    fi
}

# Function to check disk space
checkDiskSpace() {
    required_space=40
    free_space=$(df -BG --output=avail / | tail -1 | sed 's/G//')
    if (( free_space >= required_space )); then
        echo -e "     \e[32m●\e[0m System has $free_space GB of free disk space"
        disk_space_ok=1
    else
        echo -e "     \e[31m○\e[0m System has $free_space GB of free disk space, needs at least $required_space GB"
        disk_space_ok=0
    fi
}

# Function to check if running on WSL
checkWSL() {
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null; then
        echo -e "     \e[31m○\e[0m Running on WSL is not supported"
        wsl_ok=0
    else
        echo -e "     \e[32m●\e[0m Not running on WSL"
        wsl_ok=1
    fi
}

clear
echo -e "⚠️ \033[1m\033[38;5;11mThis script requires superuser permission to install dependencies and check your system info.\033[0m ⚠️"
echo "Do you want to continue? (y/n)"
read -r Warn
if [[ ! "$Warn" =~ ^[Yy]$ ]]; then
    echo "Exiting."
    exit 1
fi
echo
echo
echo Requesting root permision
sudo echo ✅ Access Granted
clear  # Clear the terminal screen
echo ──────────────────────────────────────────────
echo ULTMOS
echo    Ultimate-macOS-KVM
echo        by Coopydood.
echo                                                Installation Script by DrapNard.
echo ──────────────────────────────────────────────
echo "Hardware Requirements:"
checkKernelVersion
checkVirtualization
checkUEFI
checkCPUCores
checkRAM
checkDiskSpace
checkWSL
echo ──────────────────────────────────────────────
echo "Required Dependencies :"
checkInstalledProgram git git_installed
checkInstalledProgram wget wget_installed
checkInstalledProgram qemu-system-x86_64 qemu_full_installed
checkInstalledlibvirt libvirt libvirt_installed
checkInstalledProgram dnsmasq dnsmasq_installed
checkInstalledProgram python3 python_installed
checkInstalledProgram pip python_installed
echo ──────────────────────────────────────────────
echo "Optional Dependencies :"
checkInstalledProgram virt-manager virt_manager_installed
checkInstalledProgram virsh virsh_installed
echo "           virt-manager, virsh: Virtual Machine Manager (GUI)"
checkPipPackage pypresence python_pypresence_installed
echo "           pypresence: Discord Rich Presence"
checkInstalledProgram nbd-client nbd_installed
echo "           Network Block Device: required for mounting the OpenCore image for editing on host system"
echo ──────────────────────────────────────────────
echo 

if [[ $kernel_ok -eq 0 || $cpu_ok -eq 0 || $motherboard_virt_ok -eq 0 || $motherboard_uefi_ok -eq 0 || $ram_ok -eq 0 || $disk_space_ok -eq 0 || $wsl_ok -eq 0 ]]
then 
    echo "Your installation does not match the required hardware. Are you sure you want to continue? (y/n)"
    read required_hardware
    if [[ "$required_hardware" =~ ^[Yy]$ ]]
    then
    echo
    else
    echo Exiting.
    exit 1
    fi
fi

# Detect the package manager
if command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
    INSTALL_CMD="sudo apt-get install -y"
    PACKAGE_CHECK_CMD="dpkg -s"
    ENABLE_SERVICE_CMD="sudo systemctl enable libvirtd"
elif command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    PACKAGE_CHECK_CMD="pacman -Qi"
    ENABLE_SERVICE_CMD="sudo systemctl enable libvirtd"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    PACKAGE_CHECK_CMD="rpm -q"
    ENABLE_SERVICE_CMD="sudo systemctl enable libvirtd"
else
    echo "Unsupported package manager. Please use a system with apt, pacman, or dnf."
    exit 1
fi

if [[ $git_installed -eq 1 && $wget_installed -eq 1 && $qemu_full_installed -eq 1 && $libvirt_installed -eq 1 && $dnsmasq_installed -eq 1 && $python_installed -eq 1 ]]
then
    echo
else
    echo "Install Required Dependencies? (required admin permission) (y/n)"
    read install_required

# Check user input for installing required dependencies
if [[ "$install_required" =~ ^[Yy]$ ]]
then
    clear
    echo "Requesting root permission"
    sudo echo "✅ Access Granted"
    clear
    echo ──────────────────────────────────────────────
    packages_to_install=(
        "git:git_installed"
        "wget:wget_installed"
        "dnsmasq:dnsmasq_installed"
        "python3-pip:python_installed"
    )
    for package in "${packages_to_install[@]}"; do
        pkg_name="${package%%:*}"
        var_name="${package##*:}"
        if [[ "${!var_name}" -eq 0 ]]; then
            echo
            echo "Installing $pkg_name"
            $INSTALL_CMD "$pkg_name" > /dev/null & showLoading $!
            checkInstalledProgram "$pkg_name" "$var_name"
            echo ────────────────────
        fi
    done
    if [[ $qemu_full_installed -eq 0 ]]; then
        echo
        echo "Installing QEMU"
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qemu-system > /dev/null & showLoading $!
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm qemu-full > /dev/null & showLoading $!
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y qemu > /dev/null & showLoading $!
        fi
        checkInstalledProgram qemu-system-x86_64 qemu_full_installed
        echo ────────────────────
    fi
    if [[ $libvirt_installed -eq 0 ]]; then
        echo
        echo "Installing libvirt"
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y libvirt-daemon-system > /dev/null & showLoading $!
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm libvirt > /dev/null & showLoading $!
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y libvirt > /dev/null & showLoading $!
        fi
        sudo systemctl enable libvirtd
        sudo systemctl start libvirtd
        checkInstalledlibvirt libvirt libvirt_installed
        if [[ $libvirt_installed -eq 0 ]] ; then
            sudo systemctl enable libvirtd
            checkInstalledlibvirt libvirt libvirt_installed
        fi
        echo ────────────────────
    fi
else
    echo "Required dependencies installation skipped. Exiting."
    exit 1
fi
fi

if [[ $virt_manager_installed -eq 1 && $virsh_installed -eq 1 && $python_pypresence_installed -eq 1 && $nbd_installed -eq 1 ]]
then
echo
else
echo
echo "Install Optional Dependencies? (required admin permission) (y/n)"
read install_optional

# Check user input for installing optional dependencies
if [[ "$install_optional" =~ ^[Yy]$ ]]
then
    clear
    echo Requesting root permision
    sudo echo ✅ Access Granted
    clear
    echo ──────────────────────────────────────────────
    if [[ $virt_manager_installed -eq 0 ]]; then
        echo
        echo "Installing Virt-Manager"
        $INSTALL_CMD virt-manager > /dev/null & showLoading $!
        checkInstalledProgram virt-manager virt_manager_installed
        echo ────────────────────
    fi
    if [[ $virsh_installed -eq 0 ]]; then
        echo
        echo "Installing virsh"
        $INSTALL_CMD virsh > /dev/null & showLoading $!
        checkInstalledProgram virsh virsh_installed
        echo ────────────────────
    fi
    if [[ $python_pypresence_installed -eq 0 ]]; then
        echo
        echo "Installing python pypresence"
        pip install pypresence > /dev/null & showLoading $!
        checkPipPackage pypresence python_pypresence_installed
        echo ────────────────────
    fi
    if [[ $nbd_installed -eq 0 ]]; then
        echo
        echo "Installing NBD"
        $INSTALL_CMD nbd-client > /dev/null & showLoading $!
        checkInstalledProgram nbd-client nbd_installed
        echo ────────────────────
    fi
    echo ──────────────────────────────────────────────
else
    echo "Optional dependencies installation skipped."
fi
fi

# Proceed to git clone and launch the main script if all required dependencies are installed
if [[ $git_installed -eq 1 && $wget_installed -eq 1 && $qemu_full_installed -eq 1 && $libvirt_installed -eq 1 && $dnsmasq_installed -eq 1 && $python_installed -eq 1 ]]
then
    echo ──────────────────────────────────────────────
    clear
    echo "Clone ultimate-macOS-KVM"
    git clone https://github.com/Coopydood/ultimate-macOS-KVM -q > /dev/null & showLoading $!
    cd ultimate-macOS-KVM || exit
    echo ──────────────────────────────────────────────
    clear
    echo ──────────────────────────────────────────────
    clear
    echo "Installation finished!"
    echo "The ULTMOS installation directory is: $PWD"
    echo "          Installation Script by DrapNard"
    echo ──────────────────────────────────────────────
    echo "Press Any Key to continue"
    read -r Finishing
    python3 main.py
else
    echo "Not all required dependencies are installed. Please install them and try again."
    exit 1
fi
