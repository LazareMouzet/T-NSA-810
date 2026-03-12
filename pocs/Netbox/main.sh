#!/bin/bash

TOKEN_API_NETBOX=""
NETBOX_BASE_URL=""
ip_regex='^((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\/([0-9]|[12][0-9]|3[0-2]))?$'
NETBOX_DATA=""
allIps=""
idToIp=""
ipToHydrate=""
statusToHydrate=""
isIpExist=""
ipSelect=""
statusToIp=""

showError(){
    local code=$1
    local ref=$2

    case "$code" in
        0) return 0;;
        10) echo "Variable vide ou inexistante - (ref $ref)"; exit 10;;
        20) echo "Impossible d'accèder à la ressource - (ref $ref)"; exit 20 ;;
        21) echo "Impossible de terminer le processus de modification - (ref $ref)"; exit 21 ;;
        30) echo "Adresse IP invalide - (ref $ref)"; exit 30 ;;
        40) echo "Choix incorrecte - (ref $ref)"; exit 40 ;;
        *) echo "Erreur s'est produite $code - (ref $ref)"; exit $code
    esac
}

fetchAndApplyRequestApi() {
    local url="$1"
    local verbHttp="$2"
    local objectData="$3"

    if [[ -z "$url" || -z "$verbHttp" ]]; then
        showError 10 "fetchAndApplyRequestApi"
        return 1
    fi

    local response
    local http_code

    case "$verbHttp" in
        GET|DELETE)
            response=$(curl -s -w "%{http_code}" \
                -X "$verbHttp" \
                -H "Authorization: Token $TOKEN_API_NETBOX" \
                -H "Content-Type: application/json" \
                "$url")

            ;;
        POST|PATCH)
            response=$(curl -s -w "%{http_code}" \
                -X "$verbHttp" \
                -H "Authorization: Token $TOKEN_API_NETBOX" \
                -H "Content-Type: application/json" \
                "$url" \
                -d "$objectData")
            ;;
        *)
            showError 40 "fetchAndApplyRequestApi"
            return 1
            ;;
    esac

    http_code="${response: -3}"
    NETBOX_DATA="${response::-3}"

    if [[ "$http_code" =~ ^2 ]]; then
        return 0
    else
        showError "$http_code" "fetchAndApplyRequestApi"
        return 1
    fi
}

checkIpExist(){
    local ip=$1
    if [[ -n "$allIps" && -n "$ip" ]]; then
        local getIp="$(echo "$allIps" | grep "$ip" | cut -d ' ' -f 2)"
        if [[ -n "$getIp" ]]; then
            isIpExist="true"
        else
            isIpExist="false"
        fi
    else
        showError 10 "checkIpExist"
    fi
}

getStatusToIp(){
    local ip=$1
    if [[ -n "$allIps" && -n "$ip" ]]; then
        statusToIp="$(echo "$allIps" | grep "$ip" | cut -d ' ' -f 3)"
    else
        showError 10 "getIdToIp"
    fi
}

switchCaseStatus(){
    echo "===CHOIX STATUS==="
    echo "1) active"
    echo "2) Réservé"
    echo "3) Obsolète"
    echo "4) DHCP"
    echo "5) SLAAC"

    read -p "Entrez votre choix [1-5] : " choix
    case "$choix" in
        1) statusToHydrate="active";;
        2) statusToHydrate="Réservé";;
        3) statusToHydrate="Obsolète";;
        4) statusToHydrate="DHCP";;
        5) statusToHydrate="SLAAC";;
        *) showError 40 "switchCaseStatus"
    esac
}

hydrateObjectForPatch(){
    local ip=$1
    read -e -i "$ip" -p "Adresse IP : " ipToPatch
    if [[ -n "$ipToPatch" && "$ipToPatch" =~ $ip_regex ]]; then
        if [[ "$ip" != "$ipToPatch" ]]; then
            checkIpExist "$ipToPatch"
            if [[ "$isIpExist" == "false" ]]; then
                echo "ipToPatch $ipToPatch"
                ipToHydrate="$ipToPatch"
                echo "ipToHydrate $ipToHydrate"
            else
                echo "Cette IP existe déjà"
                patchIp
            fi
        else
            ipToHydrate="$ip"
        fi
    else
        showError 30 "hydrateObjectForPatch"
    fi

    if [[ "$ip" != "$ipToPatch" ]]; then
        switchCaseStatus
    else
        getStatusToIp "$ip"
        if [[ -n "$statusToIp" ]]; then
            echo "Status actuel de l'IP : $statusToIp"
            switchCaseStatus
        else
            showError 10 "hydrateObjectForPatch"
        fi
    fi
}

hydrateObjectForPost(){
    read -p "Renseignez l'ip de votre choix : " ipUser
    if [[ -n "$ipUser" && "$ipUser" =~ $ip_regex ]]; then
        checkIpExist "$ipUser"
        if [[ "$isIpExist" == "false" ]]; then
            ipToHydrate="$ipUser"
        else
            echo "Cette IP existe déjà"
            postIp
        fi
    else
        showError 30 "hydrateObjectForPost"
    fi
    switchCaseStatus
}

getIpsAndIdDataOnly(){
    fetchAndApplyRequestApi "$NETBOX_BASE_URL/" "GET"

    allIps="$(echo "$NETBOX_DATA" | jq -r '.results[] | "\(.id) \(.address) \(.status.value)"')"
    if [[ -z "$allIps" ]]; then
        showError 10 "getIpsAndIdDataOnly"
    fi
    return 0
}

getIdToIp(){
    local ip=$1
    if [[ -n "$allIps" && -n "$ip" ]]; then
        idToIp="$(echo "$allIps" | grep "$ip" | cut -d ' ' -f 1)"
    else
        showError 10 "getIdToIp"
    fi
}

postIp(){
    hydrateObjectForPost
    local objectPostData=$(printf '{"address": "%s", "status": "%s"}' "$ipToHydrate" "$statusToHydrate")
    fetchAndApplyRequestApi "$NETBOX_BASE_URL/" "POST" "$objectPostData"
    showError $? "postIp"
}

selectIp() {
    local action=$1
    readarray -t ips <<< "$(echo "$allIps" | cut -d ' ' -f2)"

    echo "Sélectionner l'IP à "$action" : "

    select ip in "${ips[@]}"; do
        if [[ -n "$ip" ]]; then
            ipSelect="$ip"
            break
        else
            showError 40 "selectIpToPatch"
        fi
    done
}

patchIp(){
    local action="modifier"
    selectIp "$action"
    getIdToIp "$ipSelect"
    hydrateObjectForPatch "$ipSelect"
    if [[ -n "$idToIp" ]]; then
        local id="$idToIp"
        echo "$ipToHydrate"
        local objectPatchData=$(printf '{"address": "%s", "status": "%s"}' "$ipToHydrate" "$statusToHydrate")
        fetchAndApplyRequestApi "$NETBOX_BASE_URL/$id/" "PATCH" "$objectPatchData"
    else
        showError 10 "patchIp"
    fi
}

deleteIp(){
    local action="supprimer"
    selectIp "$action"
    getIdToIp "$ipSelect"
    if [[ -n "$idToIp" ]]; then
        local id="$idToIp"
        fetchAndApplyRequestApi "$NETBOX_BASE_URL/$id/" "DELETE"
        showError $? "deleteIp"
    else
        showError 10 "deleteIp"
    fi
}

main(){
    getIpsAndIdDataOnly
    showError $? "getIpsAndIdDataOnly"

    echo "======MENU========="
    echo "1) Afficher toute les ips disponibles"
    echo "2) Ajouter une nouvelle ip"
    echo "3) Mettre à jour une ip"
    echo "4) Supprimer une ip"
    echo "5) Quitter"

    read -p "Entrez votre choix [1-5] : " option
    case "$option" in
        1)
            if fetchAndApplyRequestApi "$NETBOX_BASE_URL/" "GET"; then
                echo "$NETBOX_DATA"
            else
                showError $? "main"
            fi
            ;;
        2)
            if postIp; then
                echo "Ip $ip ajouté avec succès"
                echo "$NETBOX_DATA"
            else
                showError $? "main"
            fi
            ;;
        3)
            if patchIp; then
                echo "Ip $ipToHydrate mis à jour avec succès"
                echo "$NETBOX_DATA"
            else
                showError $? "main"
            fi
            ;;
        4)
            if deleteIp; then
                echo "IP $ip supprimé avec succés"
                return 0
            else
                showError $? "main"
            fi
            ;;
        5) exit 0;;
        *) showError 40 "main"
    esac
}

main