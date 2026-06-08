#!/bash/bin/

echo "====Démarrage de Vault"

echo "Arrêt des instances existantes..."

pkill -f "vault server" 2>/dev/null

sleep 2

echo "Nettoyage des données"
rm -f vault.log 2>/dev/null

sleep 1

vault server -dev \
        -dev-listen-address="0.0.0.0:8200" \
        -dev-root-token-id="rootToken" \
&> vault.log &

echo "Attente du démarrage..."
sleep 5

export VAULT_PID=$!

export VAULT_ADDR="http://localhost:8200"
export VAULT_TOKEN="rootToken"

if vault status > /dev/null 2>&1; then
        echo "Connexion réusssis"
else
        echo "Connexion échoué"
fi

echo ""
echo "Vault démarrer sur : $VAULT_ADDR"
echo "Token root : $VAULT_TOKEN"
echo "PID : $VAULT_PID"
