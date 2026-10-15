#!/bin/bash

# Script de test automatique pour l'API Medical Emotion Monitoring
# Usage: ./test-api.sh

BASE_URL="http://localhost:8080/api"
EMAIL="test.user@example.com"
PASSWORD="testpassword123"
FULL_NAME="Test User"

echo "=========================================="
echo "Test de l'API Medical Emotion Monitoring"
echo "=========================================="
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
    fi
}

# 1. Test d'inscription
echo "1. Test d'inscription..."
REGISTER_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"fullName\": \"$FULL_NAME\",
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\"
  }")

HTTP_CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
BODY=$(echo "$REGISTER_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 201 ]; then
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    print_result 0 "Inscription réussie"
    echo "Token reçu: ${TOKEN:0:50}..."
else
    print_result 1 "Inscription échouée (Code: $HTTP_CODE)"
    echo "Réponse: $BODY"
    exit 1
fi

echo ""

# 2. Test de connexion
echo "2. Test de connexion..."
LOGIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\"
  }")

HTTP_CODE=$(echo "$LOGIN_RESPONSE" | tail -n1)
BODY=$(echo "$LOGIN_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    print_result 0 "Connexion réussie"
    echo "Token: ${TOKEN:0:50}..."
else
    print_result 1 "Connexion échouée (Code: $HTTP_CODE)"
    exit 1
fi

echo ""

# 3. Test de validation du token
echo "3. Test de validation du token..."
VALIDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/auth/validate" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$VALIDATE_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "Token valide"
else
    print_result 1 "Token invalide (Code: $HTTP_CODE)"
fi

echo ""

# 4. Test de création d'émotion
echo "4. Test de création d'émotion..."
EMOTION_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/emotions" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "emotionType": "HAPPY",
    "confidence": 0.85
  }')

HTTP_CODE=$(echo "$EMOTION_RESPONSE" | tail -n1)
BODY=$(echo "$EMOTION_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 201 ]; then
    EMOTION_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    print_result 0 "Emotion créée (ID: $EMOTION_ID)"
else
    print_result 1 "Création d'émotion échouée (Code: $HTTP_CODE)"
    echo "Réponse: $BODY"
fi

echo ""

# 5. Test de récupération d'émotion
if [ ! -z "$EMOTION_ID" ]; then
    echo "5. Test de récupération d'émotion (ID: $EMOTION_ID)..."
    GET_EMOTION_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/emotions/$EMOTION_ID" \
      -H "Authorization: Bearer $TOKEN")
    
    HTTP_CODE=$(echo "$GET_EMOTION_RESPONSE" | tail -n1)
    if [ "$HTTP_CODE" -eq 200 ]; then
        print_result 0 "Récupération d'émotion réussie"
    else
        print_result 1 "Récupération échouée (Code: $HTTP_CODE)"
    fi
    echo ""
fi

# 6. Test de récupération de l'historique
echo "6. Test de récupération de l'historique..."
HISTORY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/emotions/patient/1" \
  -H "Authorization: Bearer $TOKEN")

HTTP_CODE=$(echo "$HISTORY_RESPONSE" | tail -n1)
if [ "$HTTP_CODE" -eq 200 ]; then
    print_result 0 "Récupération de l'historique réussie"
else
    print_result 1 "Récupération de l'historique échouée (Code: $HTTP_CODE)"
fi

echo ""

# 7. Test de création de 3 émotions SAD pour déclencher une alerte
echo "7. Test du système d'alerte (3 SAD consécutives)..."
for i in {1..3}; do
    echo "  Création de l'émotion SAD #$i..."
    curl -s -X POST "$BASE_URL/emotions" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "emotionType": "SAD",
        "confidence": 0.8
      }' > /dev/null
    sleep 1
done

print_result 0 "3 émotions SAD créées (vérifiez les logs pour l'alerte)"
echo ""

# 8. Test d'accès sans token (devrait échouer)
echo "8. Test de sécurité (accès sans token)..."
NO_AUTH_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/emotions")
HTTP_CODE=$(echo "$NO_AUTH_RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result 0 "Sécurité: Accès refusé sans token (attendu)"
else
    print_result 1 "Sécurité: Problème (Code: $HTTP_CODE, attendu: 401)"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Tests terminés!${NC}"
echo "=========================================="
echo ""
echo "Vérifiez les logs de l'application pour voir:"
echo "  - Les requêtes SQL"
echo "  - Les alertes créées"
echo "  - Les erreurs éventuelles"

