#!/bin/bash

# ============================================================
# Installation de Docker + Docker Compose
# Debian 13 (Trixie)
# ============================================================

set -e

echo "============================================================"
echo " Installation de Docker et Docker Compose"
echo " Debian 13 (Trixie)"
echo "============================================================"
echo ""

# ------------------------------------------------------------
# 1. Vérification des droits root
# ------------------------------------------------------------

echo "[1/8] Vérification des droits root..."

if [ "$EUID" -ne 0 ]; then
    echo "ERREUR : ce script doit être exécuté en root."
    echo "Utilisez : sudo bash $0"
    exit 1
fi

echo "OK : droits root détectés."
echo ""

# ------------------------------------------------------------
# 2. Vérification de la version Debian
# ------------------------------------------------------------

echo "[2/8] Vérification du système..."

. /etc/os-release

echo "Système détecté : $PRETTY_NAME"
echo "Codename       : $VERSION_CODENAME"
echo ""

if [ "$VERSION_ID" != "13" ]; then
    echo "ATTENTION : ce script est prévu pour Debian 13."
    echo "Version détectée : Debian $VERSION_ID"
    echo ""
fi

# ------------------------------------------------------------
# 3. Mise à jour des paquets
# ------------------------------------------------------------

echo "[3/8] Mise à jour des paquets..."
echo ""

apt update

echo ""
echo "OK : paquets mis à jour."
echo ""

# ------------------------------------------------------------
# 4. Suppression des anciens paquets Docker éventuels
# ------------------------------------------------------------

echo "[4/8] Vérification des anciens paquets Docker..."
echo ""

apt remove -y \
    docker.io \
    docker-compose \
    docker-doc \
    podman-docker \
    containerd \
    runc \
    2>/dev/null || true

echo ""
echo "OK : anciens paquets traités."
echo ""

# ------------------------------------------------------------
# 5. Installation des prérequis
# ------------------------------------------------------------

echo "[5/8] Installation des prérequis..."
echo ""

apt install -y \
    ca-certificates \
    curl

echo ""
echo "OK : prérequis installés."
echo ""

# ------------------------------------------------------------
# 6. Ajout du dépôt officiel Docker
# ------------------------------------------------------------

echo "[6/8] Configuration du dépôt officiel Docker..."
echo ""

# Création du dossier des clés
install -m 0755 -d /etc/apt/keyrings

# Téléchargement de la clé GPG officielle Docker
curl -fsSL \
    https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc

# Permissions de lecture de la clé
chmod a+r /etc/apt/keyrings/docker.asc

# Création du dépôt Docker
cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

echo "Dépôt Docker configuré :"
cat /etc/apt/sources.list.d/docker.sources

echo ""

# Mise à jour avec le dépôt Docker
apt update

echo ""
echo "OK : dépôt officiel Docker configuré."
echo ""

# ------------------------------------------------------------
# 7. Installation de Docker et Docker Compose
# ------------------------------------------------------------

echo "[7/8] Installation de Docker..."
echo ""

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

echo ""
echo "OK : Docker et Docker Compose installés."
echo ""

# ------------------------------------------------------------
# 8. Activation et démarrage de Docker
# ------------------------------------------------------------

echo "[8/8] Activation du service Docker..."
echo ""

systemctl enable docker
systemctl start docker

echo ""
echo "OK : Docker est démarré."
echo ""

# ============================================================
# Vérifications
# ============================================================

echo "============================================================"
echo " Vérification de l'installation"
echo "============================================================"
echo ""

echo "Version Docker :"
docker --version

echo ""

echo "Version Docker Compose :"
docker compose version

echo ""

echo "État du service Docker :"
systemctl --no-pager status docker

echo ""

# ============================================================
# Test Hello World
# ============================================================

echo "============================================================"
echo " Test Docker Hello World"
echo "============================================================"
echo ""

echo "Téléchargement et lancement de hello-world..."
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