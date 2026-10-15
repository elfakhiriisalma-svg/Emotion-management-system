#!/bin/bash
# Script simple pour exécuter le backend Spring Boot (Git Bash / Linux)

echo "=== Démarrage du Backend Spring Boot ==="

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pom.xml" ]; then
    echo "❌ Erreur: pom.xml non trouvé!"
    echo "Veuillez exécuter ce script depuis le répertoire backend"
    echo "Répertoire actuel: $(pwd)"
    exit 1
fi

# Ajouter mvnd au PATH (Windows Git Bash)
export PATH="$PATH:/c/Users/Dell/Desktop/maven-mvnd-1.0.3-windows-amd64/maven-mvnd-1.0.3-windows-amd64/bin"

# Vérifier Java
echo ""
echo "Vérification de Java..."
if ! command -v java &> /dev/null; then
    echo "❌ Java non trouvé!"
    exit 1
fi
java -version

# Vérifier Maven/mvnd
echo ""
echo "Vérification de Maven/mvnd..."
if command -v mvnd &> /dev/null; then
    echo "✅ Utilisation de mvnd (Maven Daemon)"
    MAVEN_CMD="mvnd"
elif command -v mvn &> /dev/null; then
    echo "✅ Utilisation de mvn standard"
    MAVEN_CMD="mvn"
else
    echo "❌ Maven/mvnd non trouvé!"
    echo "Veuillez installer Maven ou configurer mvnd"
    exit 1
fi

# Afficher les informations
echo ""
echo "=== Informations du Projet ==="
echo "Répertoire: $(pwd)"
echo "Commande Maven: $MAVEN_CMD"
echo ""
echo "L'application sera disponible sur: http://localhost:8080"
echo "Appuyez sur Ctrl+C pour arrêter"
echo ""

# Exécuter le backend
echo "=== Démarrage de l'application ==="
$MAVEN_CMD spring-boot:run


