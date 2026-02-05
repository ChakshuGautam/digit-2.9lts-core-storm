#!/bin/bash
# Smoke tests for DIGIT local development environment
set -e

BASE_URL="${BASE_URL:-http://localhost:18000}"
TENANT="${TENANT:-pg}"

echo "=== DIGIT Smoke Tests ==="
echo "Base URL: $BASE_URL"
echo ""

# Test MDMS
echo -n "MDMS v2 tenants... "
MDMS_RESULT=$(curl -sf "$BASE_URL/mdms-v2/v2/_search" -X POST -H "Content-Type: application/json" \
  -d '{"RequestInfo":{"apiId":"Rainmaker","ver":".01","action":"_search","msgId":"test"},"MdmsCriteria":{"tenantId":"'$TENANT'","schemaCode":"tenant.tenants"}}' \
  | jq -r '.mdms | length')
if [ "$MDMS_RESULT" -gt 0 ]; then echo "OK ($MDMS_RESULT tenants)"; else echo "FAIL"; exit 1; fi

# Test User service health
echo -n "User service health... "
curl -sf "$BASE_URL/user/health" > /dev/null && echo "OK" || { echo "FAIL"; exit 1; }

# Test Workflow service health
echo -n "Workflow service health... "
curl -sf "$BASE_URL/egov-workflow-v2/health" > /dev/null && echo "OK" || { echo "FAIL"; exit 1; }

# Test IDGen service health
echo -n "IDGen service health... "
curl -sf "$BASE_URL/egov-idgen/health" > /dev/null && echo "OK" || { echo "FAIL"; exit 1; }

# Test PGR service health
echo -n "PGR service health... "
curl -sf "$BASE_URL/pgr-services/health" > /dev/null && echo "OK" || { echo "FAIL"; exit 1; }

# Test Localization
echo -n "Localization service health... "
curl -sf "$BASE_URL/localization/actuator/health" > /dev/null && echo "OK" || { echo "FAIL"; exit 1; }

echo ""
echo "=== All smoke tests passed ==="
