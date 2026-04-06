#!/bin/bash

set -euo pipefail

LOG_DIR="${LOG_DIR:-/tmp/mankind-logs}"
SERVICE_DIR="/opt/mankind/services"

mkdir -p "$LOG_DIR"

export KEYCLOAK_PORT="${KEYCLOAK_PORT:-8180}"
export KEYCLOAK_URL="${KEYCLOAK_URL:-http://127.0.0.1:${KEYCLOAK_PORT}}"
export ADMIN_USERNAME="${ADMIN_USERNAME:-${KEYCLOAK_ADMIN:-admin}}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-${KEYCLOAK_ADMIN_PASSWORD:-admin}}"
export KEYCLOAK_ADMIN="${KEYCLOAK_ADMIN:-${ADMIN_USERNAME}}"
export KEYCLOAK_ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-${ADMIN_PASSWORD}}"
export KC_BOOTSTRAP_ADMIN_USERNAME="${KC_BOOTSTRAP_ADMIN_USERNAME:-${KEYCLOAK_ADMIN}}"
export KC_BOOTSTRAP_ADMIN_PASSWORD="${KC_BOOTSTRAP_ADMIN_PASSWORD:-${KEYCLOAK_ADMIN_PASSWORD}}"
export KC_HEALTH_ENABLED="${KC_HEALTH_ENABLED:-true}"
export JAVA_OPTS_KC_HEAP="${JAVA_OPTS_KC_HEAP:--XX:InitialRAMPercentage=10 -XX:MaxRAMPercentage=25}"

export USER_SERVICE_URL="${USER_SERVICE_URL:-http://127.0.0.1:8081}"
export PRODUCT_SERVICE_URL="${PRODUCT_SERVICE_URL:-http://127.0.0.1:8080}"
export CART_SERVICE_URL="${CART_SERVICE_URL:-http://127.0.0.1:8082}"
export WISHLIST_SERVICE_URL="${WISHLIST_SERVICE_URL:-http://127.0.0.1:8083}"
export PAYMENT_SERVICE_URL="${PAYMENT_SERVICE_URL:-http://127.0.0.1:8084}"
export NOTIFICATION_SERVICE_URL="${NOTIFICATION_SERVICE_URL:-http://127.0.0.1:8086}"
export COUPON_SERVICE_URL="${COUPON_SERVICE_URL:-http://127.0.0.1:8087}"
export ORDER_SERVICE_URL="${ORDER_SERVICE_URL:-http://127.0.0.1:8088}"

export APP_CORS_ALLOWED_ORIGIN_PATTERNS="${APP_CORS_ALLOWED_ORIGIN_PATTERNS:-http://localhost:3000,http://127.0.0.1:3000,https://*.vercel.app,https://*.onrender.com}"

COMMON_JAVA_OPTS="${COMMON_JAVA_OPTS:- -Xms16m -Xmx96m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC }"

for required_var in DB_HOST DB_NAME DB_USERNAME DB_PASSWORD; do
  if [ -z "${!required_var:-}" ]; then
    echo "Missing required environment variable: ${required_var}" >&2
    exit 1
  fi
done

cleanup() {
  for pid in $(jobs -p); do
    kill "${pid}" >/dev/null 2>&1 || true
  done
}

trap cleanup EXIT

wait_for_tcp_port() {
  local host="$1"
  local port="$2"
  local label="$3"
  local attempt=0

  while [ "${attempt}" -lt 60 ]; do
    if (echo >"/dev/tcp/${host}/${port}") >/dev/null 2>&1; then
      echo "${label} is reachable on ${host}:${port}"
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  echo "${label} did not open ${host}:${port} in time" >&2
  return 1
}

wait_for_http_ok() {
  local host="$1"
  local port="$2"
  local path="$3"
  local label="$4"
  local attempt=0

  while [ "${attempt}" -lt 60 ]; do
    if exec 3<>"/dev/tcp/${host}/${port}" 2>/dev/null; then
      printf 'GET %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n' "${path}" "${host}" >&3
      if IFS= read -r response <&3 && [[ "${response}" == *"200"* ]]; then
        exec 3<&-
        exec 3>&-
        echo "${label} responded with HTTP 200 on ${path}"
        return 0
      fi
      exec 3<&-
      exec 3>&-
    fi
    attempt=$((attempt + 1))
    sleep 2
  done

  echo "${label} did not become ready on ${path}" >&2
  return 1
}

start_service() {
  local name="$1"
  local port="$2"
  local jar="$3"

  echo "Starting ${name} on port ${port}"
  java ${COMMON_JAVA_OPTS} -Dserver.port="${port}" -jar "${jar}" >"${LOG_DIR}/${name}.log" 2>&1 &
}

echo "Starting Keycloak on port ${KEYCLOAK_PORT}"
export KC_DB="${KC_DB:-mysql}"
export KC_DB_URL="${KC_DB_URL:-jdbc:mysql://${DB_HOST}:${DB_PORT:-3306}/${DB_NAME}?useSSL=${DB_USE_SSL:-false}&allowPublicKeyRetrieval=${DB_ALLOW_PUBLIC_KEY_RETRIEVAL:-true}&serverTimezone=${DB_SERVER_TIMEZONE:-UTC}&autoReconnect=${DB_AUTO_RECONNECT:-true}}"
export KC_DB_USERNAME="${KC_DB_USERNAME:-${DB_USERNAME:-}}"
export KC_DB_PASSWORD="${KC_DB_PASSWORD:-${DB_PASSWORD:-}}"

/opt/keycloak/bin/kc.sh start-dev \
  --import-realm \
  --http-enabled=true \
  --hostname-strict=false \
  --http-port="${KEYCLOAK_PORT}" >"${LOG_DIR}/keycloak.log" 2>&1 &

wait_for_http_ok "127.0.0.1" "${KEYCLOAK_PORT}" "/realms/mankind/.well-known/openid-configuration" "Keycloak"

start_service "user-service" "8081" "${SERVICE_DIR}/user-service.jar"
start_service "product-service" "8080" "${SERVICE_DIR}/product-service.jar"
start_service "cart-service" "8082" "${SERVICE_DIR}/cart-service.jar"
start_service "wishlist-service" "8083" "${SERVICE_DIR}/wishlist-service.jar"
start_service "payment-service" "8084" "${SERVICE_DIR}/payment-service.jar"
start_service "notification-service" "8086" "${SERVICE_DIR}/notification-service.jar"
start_service "coupon-service" "8087" "${SERVICE_DIR}/coupon-service.jar"
start_service "order-service" "8088" "${SERVICE_DIR}/order-service.jar"

wait_for_tcp_port "127.0.0.1" "8081" "user-service"
wait_for_tcp_port "127.0.0.1" "8080" "product-service"
wait_for_tcp_port "127.0.0.1" "8082" "cart-service"
wait_for_tcp_port "127.0.0.1" "8083" "wishlist-service"
wait_for_tcp_port "127.0.0.1" "8084" "payment-service"
wait_for_tcp_port "127.0.0.1" "8086" "notification-service"
wait_for_tcp_port "127.0.0.1" "8087" "coupon-service"
wait_for_tcp_port "127.0.0.1" "8088" "order-service"

echo "Starting gateway on Render port ${PORT:-8085}"
exec java ${COMMON_JAVA_OPTS} -Dserver.port="${PORT:-8085}" -jar "${SERVICE_DIR}/mankind-gateway-service.jar"
