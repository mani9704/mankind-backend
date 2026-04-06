#!/bin/bash

set -euo pipefail

LOG_DIR="${LOG_DIR:-/tmp/mankind-logs}"
SERVICE_DIR="/opt/mankind/services"

mkdir -p "$LOG_DIR"

export KEYCLOAK_PORT="${KEYCLOAK_PORT:-8080}"
export KEYCLOAK_URL="${KEYCLOAK_URL:-http://127.0.0.1:${KEYCLOAK_PORT}}"
export ADMIN_USERNAME="${ADMIN_USERNAME:-${KEYCLOAK_ADMIN:-admin}}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-${KEYCLOAK_ADMIN_PASSWORD:-admin}}"
export APP_SECURITY_OAUTH2_ENABLED="${APP_SECURITY_OAUTH2_ENABLED:-false}"
export APP_SECURITY_DEV_USER_ID="${APP_SECURITY_DEV_USER_ID:-1}"

export USER_SERVICE_URL="${USER_SERVICE_URL:-http://127.0.0.1:8081}"
export PRODUCT_SERVICE_URL="${PRODUCT_SERVICE_URL:-http://127.0.0.1:8080}"
export CART_SERVICE_URL="${CART_SERVICE_URL:-http://127.0.0.1:8082}"
export WISHLIST_SERVICE_URL="${WISHLIST_SERVICE_URL:-http://127.0.0.1:8083}"
export PAYMENT_SERVICE_URL="${PAYMENT_SERVICE_URL:-http://127.0.0.1:8084}"
export NOTIFICATION_SERVICE_URL="${NOTIFICATION_SERVICE_URL:-http://127.0.0.1:8086}"
export COUPON_SERVICE_URL="${COUPON_SERVICE_URL:-http://127.0.0.1:8087}"
export ORDER_SERVICE_URL="${ORDER_SERVICE_URL:-http://127.0.0.1:8088}"

export APP_CORS_ALLOWED_ORIGIN_PATTERNS="${APP_CORS_ALLOWED_ORIGIN_PATTERNS:-http://localhost:3000,http://127.0.0.1:3000,https://*.vercel.app,https://*.onrender.com}"

export START_USER_SERVICE="${START_USER_SERVICE:-false}"
export START_PRODUCT_SERVICE="${START_PRODUCT_SERVICE:-true}"
export START_CART_SERVICE="${START_CART_SERVICE:-true}"
export START_WISHLIST_SERVICE="${START_WISHLIST_SERVICE:-true}"
export START_PAYMENT_SERVICE="${START_PAYMENT_SERVICE:-false}"
export START_NOTIFICATION_SERVICE="${START_NOTIFICATION_SERVICE:-false}"
export START_COUPON_SERVICE="${START_COUPON_SERVICE:-false}"
export START_ORDER_SERVICE="${START_ORDER_SERVICE:-false}"

DEFAULT_JAVA_OPTS="${DEFAULT_JAVA_OPTS:- -Xms16m -Xmx48m -XX:MaxMetaspaceSize=48m -XX:+UseSerialGC }"
GATEWAY_JAVA_OPTS="${GATEWAY_JAVA_OPTS:- -Xms16m -Xmx72m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC }"
PRODUCT_JAVA_OPTS="${PRODUCT_JAVA_OPTS:- -Xms16m -Xmx72m -XX:MaxMetaspaceSize=64m -XX:+UseSerialGC }"
USER_JAVA_OPTS="${USER_JAVA_OPTS:- -Xms16m -Xmx56m -XX:MaxMetaspaceSize=48m -XX:+UseSerialGC }"

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

start_service() {
  local name="$1"
  local port="$2"
  local jar="$3"
  local java_opts="${4:-${DEFAULT_JAVA_OPTS}}"

  echo "Starting ${name} on port ${port}"
  java ${java_opts} -Dserver.port="${port}" -jar "${jar}" >"${LOG_DIR}/${name}.log" 2>&1 &
}

start_if_enabled() {
  local enabled="$1"
  local name="$2"
  local port="$3"
  local jar="$4"
  local java_opts="${5:-${DEFAULT_JAVA_OPTS}}"

  if [ "${enabled}" = "true" ]; then
    start_service "${name}" "${port}" "${jar}" "${java_opts}"
  else
    echo "Skipping ${name}"
  fi
}

start_if_enabled "${START_USER_SERVICE}" "user-service" "8081" "${SERVICE_DIR}/user-service.jar" "${USER_JAVA_OPTS}"
start_if_enabled "${START_PRODUCT_SERVICE}" "product-service" "8080" "${SERVICE_DIR}/product-service.jar" "${PRODUCT_JAVA_OPTS}"
start_if_enabled "${START_CART_SERVICE}" "cart-service" "8082" "${SERVICE_DIR}/cart-service.jar" "${DEFAULT_JAVA_OPTS}"
start_if_enabled "${START_WISHLIST_SERVICE}" "wishlist-service" "8083" "${SERVICE_DIR}/wishlist-service.jar" "${DEFAULT_JAVA_OPTS}"
start_if_enabled "${START_PAYMENT_SERVICE}" "payment-service" "8084" "${SERVICE_DIR}/payment-service.jar" "${DEFAULT_JAVA_OPTS}"
start_if_enabled "${START_NOTIFICATION_SERVICE}" "notification-service" "8086" "${SERVICE_DIR}/notification-service.jar" "${DEFAULT_JAVA_OPTS}"
start_if_enabled "${START_COUPON_SERVICE}" "coupon-service" "8087" "${SERVICE_DIR}/coupon-service.jar" "${DEFAULT_JAVA_OPTS}"
start_if_enabled "${START_ORDER_SERVICE}" "order-service" "8088" "${SERVICE_DIR}/order-service.jar" "${DEFAULT_JAVA_OPTS}"

echo "Starting lightweight Render stack without Keycloak"
echo "Starting gateway on Render port ${PORT:-8085}"
exec java ${GATEWAY_JAVA_OPTS} -Dserver.port="${PORT:-8085}" -jar "${SERVICE_DIR}/mankind-gateway-service.jar"
