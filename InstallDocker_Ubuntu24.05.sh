#!/bin/bash

# ============================================================
# Installation Docker + Docker Compose sur Ubuntu
# Puis test avec le conteneur Hello World
# ============================================================

set -e

echo "============================================================"
echo " Installation de Docker sur Ubuntu"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# 1. Vérification des droits root
# ------------------------------------------------------------

echo "[1/7] Vérification des droits..."

if [ "$EUID" -ne 0 ]; then
    echo "ERREUR : ce script doit être lancé en root."
    echo "Exemple : sudo bash $0"
    exit 1
fi

echo "OK : script exécuté avec les droits root."
echo ""

# ------------------------------------------------------------
# 2. Affichage de la version Ubuntu
# ------------------------------------------------------------

echo "[2/7] Détection de la version Ubuntu..."

. /etc/os-release

echo "Distribution : $PRETTY_NAME"
echo "Codename     : $VERSION_CODENAME"
echo ""

# ------------------------------------------------------------
# 3. Mise à jour du système
# ------------------------------------------------------------

echo "[3/7] Mise à jour des paquets..."
echo ""

apt update

echo ""
echo "OK : système mis à jour."
echo ""

# ------------------------------------------------------------
# 4. Installation des prérequis
# ------------------------------------------------------------

echo "[4/7] Installation des prérequis..."
echo ""

apt install -y \
    ca-certificates \
    curl \
    gnupg

echo ""
echo "OK : prérequis installés."
echo ""

# ------------------------------------------------------------
# 5. Installation de la clé et du dépôt Docker
# ------------------------------------------------------------

echo "[5/7] Ajout du dépôt officiel Docker..."
echo ""

# Création du répertoire pour les clés
install -m 0755 -d /etc/apt/keyrings

# Téléchargement de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Ajout du dépôt officiel Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" \
  > /etc/apt/sources.list.d/docker.list

echo "Dépôt Docker ajouté :"
cat /etc/apt/sources.list.d/docker.list

echo ""

# Mise à jour des dépôts
apt update

echo ""
echo "OK : dépôt Docker configuré."
echo ""

# ------------------------------------------------------------
# 6. Installation de Docker + Docker Compose
# ------------------------------------------------------------

echo "[6/7] Installation de Docker et Docker Compose..."
echo ""

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo ""
echo "OK : Docker installé."
echo ""

# ------------------------------------------------------------
# 7. Activation du service Docker
# ------------------------------------------------------------

echo "[7/7] Activation et démarrage de Docker..."
echo ""

systemctl enable docker
systemctl start docker

echo "OK : Docker est démarré."
echo ""

# ============================================================
# Vérification des versions
# ============================================================

echo "============================================================"
echo " Vérification"
echo "============================================================"
echo ""

echo "Version Docker :"
docker --version

echo ""

echo "Version Docker Compose :"
docker compose version

echo ""

echo "État de Docker :"
systemctl is-active docker

echo ""

# ============================================================
# Test Hello World
# ============================================================

echo "============================================================"
echo " Test Docker Hello World"
echo "============================================================"
echo ""

echo "Lancement du conteneur hello-world..."
echo ""

docker run --rm hello-world

echo ""
echo "============================================================"
echo " Installation terminée avec succès !"
echo "============================================================"
echo ""
echo "Docker fonctionne correctement."
echo "Docker Compose est installé."
echo ""