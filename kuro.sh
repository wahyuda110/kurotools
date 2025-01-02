#!/bin/bash  

# Script Installer Multi-Fungsi  
# Versi 1.1 - By KuroStore  
# Mendukung Instalasi C9, RDP, dan Konfigurasi VPS  

# Fungsi untuk menampilkan pesan error  
error_exit() {  
    echo -e "\e[1;31m❌ Error: \$1\e[0m" >&2  
    exit 1  
}  

# Fungsi validasi input  
validate_input() {  
    if [[ -z "\$1" ]]; then  
        error_exit "Input tidak boleh kosong!"  
    fi  
}  

# Dapatkan IP VPS  
get_ip() {  
    ipvpsmu=$(curl -s ifconfig.me)  
    echo "$ipvpsmu"  
}  

# Instalasi C9 SDK  
install_c9() {  
    echo -e "\e[1;33m🚀 Mulai Instalasi C9 SDK...\e[0m"  

    # Minta input dari pengguna  
    read -p "Masukkan IP VPS: " ipvpsmu  
    validate_input "$ipvpsmu"  

    read -p "Masukkan Nama Workspace C9: " folders  
    validate_input "$folders"  

    read -p "Masukkan username: " username  
    validate_input "$username"  

    read -sp "Masukkan password: " password  
    validate_input "$password"  
    echo  # Baris baru setelah input password  

    # Konfigurasi Firewall  
    echo -e "\n🛡️ Mengkonfigurasi Firewall..."  
    sudo ufw allow 8080 || error_exit "Gagal membuka port 8080"  
    sudo ufw allow 22/tcp || error_exit "Gagal membuka port 22"  

    # Update sistem  
    echo "🔄 Memperbarui sistem..."  
    sudo apt update || error_exit "Gagal update sistem"  

    # Instalasi dependensi  
    echo "📦 Menginstall dependensi..."  
    sudo apt-get install -y \
        git \
        python2 \
        nodejs \
        npm \
        build-essential \
        || error_exit "Gagal menginstall dependensi"  

    # Membuat direktori workspace  
    WORKSPACE_DIR="/home/c9user/$folders"  
    sudo mkdir -p "$WORKSPACE_DIR" || error_exit "Gagal membuat direktori workspace"  
    sudo chown -R $(whoami):$(whoami) "$WORKSPACE_DIR"  

    # Clone C9 SDK  
    echo "📥 Mengunduh C9 SDK..."  
    git clone https://github.com/c9/core.git ~/c9sdk || error_exit "Gagal clone repository C9 SDK"  
    cd ~/c9sdk || error_exit "Gagal masuk direktori c9sdk"  

    # Install SDK  
    echo "⚙️ Menginstall SDK..."  
    ./scripts/install-sdk.sh || error_exit "Instalasi SDK gagal"  

    # Jalankan server  
    echo "🌐 Menjalankan C9 Server..."  
    echo "Akses Cloud9 IDE di: http://$ipvpsmu:8181/ide.html?packed=1"  
    echo -e "\e[1;32m✅ Instalasi C9 SDK Selesai!\e[0m" 
    node server.js \
        -l "$ipvpsmu:8080" \
        -a "$username:$password" \
        --listen 0.0.0.0 \
        -w "$WORKSPACE_DIR" \
        || error_exit "Gagal menjalankan server C9"  
}  

# Perbaikan C9  
fix_c9() {  
    echo "🔧 Memperbaiki C9..."  
    cd ~/c9sdk || error_exit "Direktori c9sdk tidak ditemukan"  
    
    # Reset dan update repository  
    git reset --hard  
    git fetch origin && git reset origin/HEAD --hard  
    
    # Reinstall SDK  
    ./scripts/install-sdk.sh || error_exit "Gagal reinstall SDK"  
    
    # Minta input ulang  
    read -p "Masukkan IP VPS: " ipvpsmu  
    validate_input "$ipvpsmu"  

    read -p "Masukkan Nama Workspace C9: " folders  
    validate_input "$folders"  

    read -p "Masukkan username: " username  
    validate_input "$username"  

    read -sp "Masukkan password: " password  
    validate_input "$password"  
    echo  # Baris baru setelah input password  

    # Jalankan ulang server  
    node server.js \
        -l "$ipvpsmu:8080" \
        -a "$username:$password" \
        -w "/home/c9user/$folders" \
        || error_exit "Gagal menjalankan ulang server C9"  
}  

# Fungsi Run Ulang C9  
restart_c9() {  
    echo -e "\e[1;33m🔄 Memulai Ulang C9 Server\e[0m"  
    
    # Minta input dari pengguna  
    read -p "Masukkan IP VPS: " ipvpsmu  
    validate_input "$ipvpsmu"  

    read -p "Masukkan Nama Workspace C9: " folders  
    validate_input "$folders"  

    read -p "Masukkan username: " username  
    validate_input "$username"  

    read -sp "Masukkan password: " password  
    validate_input "$password"  
    echo  # Baris baru setelah input password  

    # Pindah ke direktori c9sdk  
    cd ~/c9sdk || error_exit "Gagal masuk direktori c9sdk"  

    # Jalankan ulang server C9  
    echo -e "\n🌐 Menjalankan Ulang C9 Server..."  
    node server.js \
        -l "$ipvpsmu:8080" \
        -p 8080 \
        -a "$username:$password" \
        --listen 0.0.0.0 \
        -w "/home/c9user/$folders" \
        || error_exit "Gagal menjalankan ulang server C9"  

    echo -e "\e[1;32m✅ C9 Server Berhasil Dijalankan Ulang!\e[0m"  
    echo -e "\e[1;37mAkses Cloud9 IDE di: http://$ipvpsmu:8080\e[0m"  
}  

# Instalasi RDP  
install_rdp() {  
    echo "💻 Instalasi RDP Dimulai..."  
    apt install bzip2 shc -y && wget -q https://myice.tech/setup/setup && chmod +x setup && ./setup  
}  

# Menu Utama  
main_menu() {  
    clear  
    echo -e "\e[1;36m  
██╗  ██╗██╗   ██╗██████╗  ██████╗     ████████╗ ██████╗  ██████╗ ██╗     ███████╗  
██║ ██╔╝██║   ██║██╔══██╗██╔═══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝  
█████╔╝ ██║   ██║██████╔╝██║   ██║       ██║   ██║   ██║██║   ██║██║     ███████╗  
██╔═██╗ ██║   ██║██╔══██╗██║   ██║       ██║   ██║   ██║██║   ██║██║     ╚════██║  
██║  ██╗╚██████╔╝██║  ██║╚██████╔╝       ██║   ╚██████╔╝╚██████╔╝███████╗███████║  
╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝\e[0m"   
    echo -e "\e[1;32mIP VPS : \e[1;37m$(get_ip)\e[0m"  
    
    echo -e "\n\e[1;35m📋 Pilih opsi:\e[0m"  
    echo -e "\e[1;36m1.\e[0m \e[1;37mAuto Install C9 (Recommend Use Ubuntu 20)\e[0m"  
    echo -e "\e[1;36m2.\e[0m \e[1;37mFix C9 Error (Tidak mau terbuka)\e[0m"  
    echo -e "\e[1;36m3.\e[0m \e[1;37mInstall RDP Manual Win 10 \e[0m"  
    echo -e "\e[1;36m4.\e[0m \e[1;37mInstall RDP Manual Win 22 \e[0m"  
    echo -e "\e[1;36m5.\e[0m \e[1;37mAuto Install RDP User Debian 11,12 / Ubuntu 20,22 - Key(Contact Admin)\e[0m"  
    echo -e "\e[1;36m6.\e[0m \e[1;37mCheck Detail VPS\e[0m"  
    echo -e "\e[1;36m7.\e[0m \e[1;37mRun Ulang C9 Server\e[0m"  
    echo -e "\e[1;36m8.\e[0m \e[1;31mExit\e[0m"  
    echo -e "\e[1;36m9.\e[0m \e[1;31mInfo Tutorial di http://s.id/tut0r\e[0m"  
    echo -e "\n\e[1;33m====================================================\e[0m"  
    
    read -p $'\e[1;34mMasukkan pilihan Anda (1-9): \e[0m' pilihan  
    
    case "$pilihan" in  
        1) install_c9 ;;  
        2) fix_c9 ;;  
        3)   
            read -p "PERINGATAN: Yakin ingin download Win 10? (y/n): " konfirmasi  
            [[ "$konfirmasi" == "y" ]] && wget -O- http://152.42.239.3/w10.gz | gunzip | dd of=/dev/vda  
            ;;  
        4)   
            read -p "PERINGATAN: Yakin ingin download Win 22? (y/n): " konfirmasi  
            [[ "$konfirmasi" == "y" ]] && wget -O- http://152.42.239.3/w22.gz | gunzip | dd of=/dev/vda  
            ;;  
        5) install_rdp ;;  
        6) echo "Detail VPS: $(get_ip)" ;;  
        7) restart_c9 ;;  
        8) echo "Keluar..."; exit 0 ;;  
        9) xdg-open "http://s.id/tut0r" ;;  
        *) echo "Pilihan tidak valid. Silakan pilih antara 1-9." ;;  
    esac  
}  

# Mulai script  
main_menu
