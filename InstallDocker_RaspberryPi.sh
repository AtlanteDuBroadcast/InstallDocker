#!/bin/bash

# ============================================================
# Installation de Docker + Docker Compose
# Raspberry Pi OS / Debian
# ============================================================

set -e

echo ""
echo "============================================================"
echo "        INSTALLATION DE DOCKER - RASPBERRY PI"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# 1. Vérification des droits root
# ------------------------------------------------------------

echo "[1/9] Vérification des droits administrateur..."

if [ "$EUID" -ne 0 ]; then
    echo ""
    echo "ERREUR : ce script doit être exécuté avec sudo."
    echo ""
    echo "Exemple :"
    echo "  sudo bash InstallDocker_RaspberryPi.sh"
    echo ""
    exit 1
fi

echo "OK : droits administrateur détectés."
echo ""

# ------------------------------------------------------------
# 2. Détection du système
# ------------------------------------------------------------

echo "[2/9] Détection du système..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "ERREUR : impossible de détecter le système."
    exit 1
fi

echo "Système : $PRETTY_NAME"
echo "Version : $VERSION_ID"
echo "Architecture : $(dpkg --print-architecture)"
echo ""

# ------------------------------------------------------------
# 3. Vérification de l'architecture
# ------------------------------------------------------------

echo "[3/9] Vérification de l'architecture..."

ARCH=$(dpkg --print-architecture)

case "$ARCH" in
    arm64)
        echo "OK : architecture ARM64 détectée."
        ;;
    armhf)
        echo "OK : architecture ARMHF détectée."
        ;;
    *)
        echo "ATTENTION : architecture détectée : $ARCH"
        echo "Ce script est prévu pour les Raspberry Pi."
        ;;
esac

echo ""

# ------------------------------------------------------------
# 4. Mise à jour du système
# ------------------------------------------------------------

echo "[4/9] Mise à jour de la liste des paquets..."
echo ""

apt update

echo ""
echo "OK : liste des paquets mise à jour."
echo ""

# ------------------------------------------------------------
# 5. Installation des prérequis
# ------------------------------------------------------------

echo "[5/9] Installation des prérequis..."
echo ""

apt install -y \
    ca-certificates \
    curl

echo ""
echo "OK : prérequis installés."
echo ""

# ------------------------------------------------------------
# 6. Installation de Docker
# ------------------------------------------------------------

echo "[6/9] Installation de Docker..."
echo ""

# Utilisation du script officiel Docker
curl -fsSL https://get.docker.com -o /tmp/get-docker.sh

echo "Lancement de l'installation Docker..."
echo ""

sh /tmp/get-docker.sh

echo ""
echo "OK : Docker installé."
echo ""

# Suppression du script temporaire
rm -f /tmp/get-docker.sh

# ------------------------------------------------------------
# 7. Ajout de l'utilisateur au groupe Docker
# ------------------------------------------------------------

echo "[7/9] Configuration du groupe Docker..."
echo ""

# Récupération de l'utilisateur ayant lancé sudo
REAL_USER="${SUDO_USER:-}"

if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then

    echo "Utilisateur détecté : $REAL_USER"

    usermod -aG docker "$REAL_USER"

    echo "OK : $REAL_USER a été ajouté au groupe docker."

else

    echo "Aucun utilisateur normal détecté."
    echo "Le groupe docker ne sera pas modifié."

fi

echo ""

# ------------------------------------------------------------
# 8. Activation et démarrage de Docker
# ------------------------------------------------------------

echo "[8/9] Activation du service Docker..."
echo ""

systemctl enable docker
systemctl start docker

echo "Vérification du service..."

if systemctl is-active --quiet docker; then
    echo "OK : Docker est démarré."
else
    echo "ERREUR : Docker n'est pas démarré."
    systemctl status docker --no-pager
    exit 1
fi

echo ""

# ------------------------------------------------------------
# Installation / vérification de Docker Compose
# ------------------------------------------------------------

echo "Installation de Docker Compose..."

apt install -y docker-compose-plugin

echo ""
echo "OK : Docker Compose installé."
echo ""

# ------------------------------------------------------------
# 9. Vérification des versions
# ------------------------------------------------------------

echo "[9/9] Vérification de l'installation..."
echo ""

echo "------------------------------------------------------------"
echo "Version Docker"
echo "------------------------------------------------------------"

docker --version

echo ""

echo "------------------------------------------------------------"
echo "Version Docker Compose"
echo "------------------------------------------------------------"

docker compose version

echo ""

# ============================================================
# TEST HELLO WORLD
# ============================================================

echo "============================================================"
echo "        TEST DOCKER HELLO WORLD"
echo "============================================================"
echo ""

echo "Téléchargement de l'image hello-world..."
echo ""

docker run --rm hello-world

echo ""
echo "============================================================"
echo "        INSTALLATION TERMINÉE"
echo "============================================================"
echo ""

echo "Docker       : OK"
echo "Docker Compose : OK"
echo "Hello World  : OK"
echo ""

if [ -n "$REAL_USER" ] && [ "$REAL_USER" != "root" ]; then
    echo "IMPORTANT :"
    echo ""
    echo "L'utilisateur '$REAL_USER' a été ajouté au groupe docker."
    echo ""
    echo "Déconnectez-vous puis reconnectez-vous pour que"
    echo "le changement de groupe soit pris en compte."
    echo ""
    echo "Après reconnexion, vous pourrez utiliser :"
    echo ""
    echo "    docker ps"
    echo "    docker compose version"
    echo ""
fi

echo "============================================================"
echo ""
