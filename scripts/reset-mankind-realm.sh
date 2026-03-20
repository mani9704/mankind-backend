#!/bin/bash

# --- CONFIGURATION ---
KEYCLOAK_URL="http://localhost:8180"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
REALM="mankind"
REALM_JSON="keycloak/mankind-realm.json"
KCADM="./keycloak-26.0.5/bin/kcadm.sh"

# --- LOGIN ---
$KCADM config credentials --server $KEYCLOAK_URL --realm master --user $ADMIN_USER --password $ADMIN_PASSWORD

# --- DELETE REALM ---
echo "Deleting realm '$REALM'..."
$KCADM delete realms/$REALM

# --- RE-IMPORT REALM ---
echo "Re-importing realm from $REALM_JSON..."
$KCADM create realms -f $REALM_JSON

echo "Done! Realm '$REALM' has been reset and re-imported." 