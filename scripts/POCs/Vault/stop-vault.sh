#!/bin/bash
VAULT_ADDR=$1
VAULT_TOKEN=$2
VAULT_PID=$3

if [[ $# -lt 3 ]]; then
    echo "Il manque des arguments"
    exit 1
fi

if !pgrep -f "vault server" > /dev/null 2>&1; then
        echo "Vault n'est pas en cours d'execution"
        exit 0
fi

read -p "Voulez-vous arrêter Vault (y/n)" res

case "$res" in

y|Y)
        if [[ -n "$VAULT_ADDR" && -n "$VAULT_TOKEN" ]]; then
                echo "Suppression des données ..."
                unset VAULT_ADDR
                unset VAULT_TOKEN
        else
                echo "⚠️ Variables Vault absentes - nettoyage ignoré"
                continue
        fi

        echo "Vault est en cours d'arrêt ..."
        if kill -TERM $VAULT_PID > /dev/null 2>&1; then
                echo "✅ Arrêt de Vault réussis"
                exit 0
        else
                echo "❌ Echec lors de l'arrêt de Vault"
                echo ""
                echo "Interruption des processus en cours ..."
                pkill -f "vault server"
                exit 0
        fi;;
n|N)
        echo "⚠️ Vault est toujours en cours d'execution ..."
        exit 0;;
*)
        echo "Touche incorrecte"
esac
