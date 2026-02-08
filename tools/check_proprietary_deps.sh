#!/usr/bin/env bash
set -euo pipefail

CONFIG="${1:-fossReleaseRuntimeClasspath}"

PATTERN='com\.google\.android\.gms|com\.google\.firebase|com\.google\.mlkit|com\.google\.android\.play'

echo "==> Checking Gradle configuration: ${CONFIG}"
echo "==> Pattern: ${PATTERN}"
echo

pushd android >/dev/null

OUT="$(./gradlew :app:dependencies --configuration "${CONFIG}")"

if echo "${OUT}" | grep -E "${PATTERN}" >/dev/null; then
  echo "❌ FAIL: Proprietary-looking dependencies found in ${CONFIG}"
  echo
  echo "${OUT}" | grep -E "${PATTERN}"
  popd >/dev/null
  exit 1
fi

popd >/dev/null
echo "✅ PASS: No proprietary-looking dependencies found in ${CONFIG}"
