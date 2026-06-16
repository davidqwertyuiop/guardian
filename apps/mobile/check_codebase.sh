#!/bin/bash

# Script to verify that:
# 1. No .dart file under lib/ exceeds 100 lines (or list any that do).
# 2. flutter analyze passes without errors.

echo "=== CHECKING DART FILE LINE COUNTS (100 LINE LIMIT) ==="
FAILED=0
OVER_LIMIT_FILES=()

# Find all .dart files in lib/
while IFS= read -r file; do
  # Skip generated/dependency files if any exist in the future
  if [[ "$file" == *".g.dart"* || "$file" == *".freezed.dart"* ]]; then
    continue
  fi
  
  # Count lines
  line_count=$(wc -l < "$file")
  
  # Check limit
  if [ "$line_count" -gt 100 ]; then
    # We will flag it. Note: some pre-existing files might be over 100 lines,
    # but we must ensure all new/modified files stay under 100 lines.
    echo "⚠️  [WARNING] $file has $line_count lines (exceeds 100 lines)"
    # If the file is in auth feature (where we are working), we treat it as a failure
    if [[ "$file" == *"lib/features/auth"* ]]; then
      OVER_LIMIT_FILES+=("$file ($line_count lines)")
      FAILED=1
    fi
  else
    echo "✅ $file: $line_count lines"
  fi
done < <(find lib -name "*.dart")

if [ $FAILED -ne 0 ]; then
  echo ""
  echo "❌ Error: The following files in lib/features/auth exceed the 100-line limit:"
  for f in "${OVER_LIMIT_FILES[@]}"; do
    echo "  - $f"
  done
else
  echo ""
  echo "🎉 All auth feature Dart files are within the 100-line limit!"
fi

echo ""
echo "=== RUNNING FLUTTER ANALYZE ==="
flutter analyze
ANALYZE_STATUS=$?

if [ $ANALYZE_STATUS -eq 0 ] && [ $FAILED -eq 0 ]; then
  echo ""
  echo "🚀 All checks passed successfully!"
  exit 0
else
  echo ""
  echo "❌ Some checks failed."
  exit 1
fi
