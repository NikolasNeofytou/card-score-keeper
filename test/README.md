# Test Directory Structure

This directory contains tests for the Card Scorekeeper Flutter app.

## Structure

- **widget_test.dart** - Main widget/integration tests
- **unit/** - Unit tests for individual components
  - **models_test.dart** - Tests for domain models (Game, Player, Round)
- **integration/** - Integration tests for complete user flows

## Running Tests

```bash
# Run all tests
flutter test

# Run only unit tests
flutter test test/unit/

# Run with coverage
flutter test --coverage
```

## Test Guidelines

- Keep tests focused and isolated
- Use descriptive test names
- Mock external dependencies
- Test both happy path and edge cases