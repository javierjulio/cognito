#!/bin/bash
RUBY_VERSIONS=(2.2.5 2.3.1)
CIRCLE_NODE_RUBY_VERSION="${RUBY_VERSIONS[$CIRCLE_NODE_INDEX]}"
NUM_RUBIES=${#RUBY_VERSIONS[@]}
METRICS_BUILD_RUBY_VERSION="2.3.1"

if [ "$CIRCLE_NODE_TOTAL" -le "$NUM_RUBIES" ]; then
  echo "Cannot test $NUM_RUBIES ruby versions and metrics on $CIRCLE_NODE_TOTAL containers"
  exit 1
fi

# Exit early if there are more containers than ruby versions to test
if [ "$CIRCLE_NODE_INDEX" -gt "$NUM_RUBIES" ]; then
  echo "Ignoring extra container"
  exit 0
fi

# Determine current build type (metrics or tests)
if [ "$CIRCLE_NODE_INDEX" -eq $((CIRCLE_NODE_TOTAL-1)) ]; then
  BUILD="metrics"
  CIRCLE_NODE_RUBY_VERSION=$METRICS_BUILD_RUBY_VERSION
else
  BUILD="tests"
fi

if [[ "$1" = "build" ]]; then
  echo "Bundle installing for $CIRCLE_NODE_RUBY_VERSION"
  rvm-exec $CIRCLE_NODE_RUBY_VERSION bundle install;
elif [[ "$1" = "spec" && "$BUILD" = "tests" ]]; then
  echo "Running tests for $CIRCLE_NODE_RUBY_VERSION"
  rvm-exec $CIRCLE_NODE_RUBY_VERSION rspec;
elif [[ "$1" = "spec" && "$BUILD" = "metrics" ]]; then
  echo "Running metrics for $CIRCLE_NODE_RUBY_VERSION"
  rvm-exec $CIRCLE_NODE_RUBY_VERSION bundle exec rake ci;
fi
