#!/bin/bash

# ============================================================
# Installation Docker + Docker Compose sur Ubuntu
# Compatible Ubuntu 24.04 / 26.04
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
# 2. Détection Ubuntu
# ------------------------------------------------------------

echo "[2/7] Détection de la version Ubuntu..."

. /etc/os-release

echo "Distribution : $PRETTY_NAME"
echo "Codename     : $VERSION_CODENAME"
echo "Architecture : $(dpkg --print-architecture)"
echo ""

if [ "$ID" != "ubuntu" ]; then
    echo "ERREUR : ce script est prévu pour Ubuntu."
    exit 1
fi

# Vérification des versions supportées par Docker
case "$VERSION_CODENAME" in
    noble|resolute|jammy)
        echo "OK : version Ubuntu supportée par Docker."
        ;;
    *)
        echo "ATTENTION : cette version Ubuntu n'est pas"
        echo "explicitement supportée par Docker."
        ;;
esac

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
    curl

echo ""
echo "OK : prérequis installés."
echo ""

# ------------------------------------------------------------
# 5. Dépôt officiel Docker
# ------------------------------------------------------------

echo "[5/7] Ajout du dépôt officiel Docker..."
echo ""

# Création du répertoire des clés
install -m 0755 -d /etc/apt/keyrings

# Clé GPG Docker
curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Dépôt Docker au nouveau format .sources
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Dépôt Docker configuré :"
echo ""

cat /etc/apt/sources.list.d/docker.sources

echo ""

apt update

echo ""
echo "OK : dépôt Docker configuré."
echo ""

# ------------------------------------------------------------
# 6. Installation Docker + Docker Compose
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
# Vérification
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