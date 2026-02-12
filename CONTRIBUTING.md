# Contributing

We welcome contributions! Here's how to get started:

## Development Setup

1. **Fork & Clone**
   ```bash
   git clone https://github.com/YOUR_FORK/attendance-tracker.git
   cd attendance-tracker
   ```

2. **Set up your environment**
   - Follow [SETUP.md](SETUP.md) for backend and frontend setup

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Code Guidelines

### Python (Backend)
- Follow PEP 8 style guide
- Use type hints where possible
- Add docstrings to functions
- Test scraper changes against live ETLab site

### Dart (Frontend)
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `Provider` for state management (no BLoC or Riverpod)
- Keep widgets small and focused
- Use proper error handling with try-catch blocks

## Areas for Contribution

### High Priority
- [ ] ETLab HTML parser improvements (handle edge cases)
- [ ] Better error messages in UI
- [ ] Unit and widget tests
- [ ] Performance optimizations

### Medium Priority
- [ ] Dark mode theme customization
- [ ] Additional calculators (e.g., "What if I skip this many classes?")
- [ ] Timetable sync with calendar apps
- [ ] Offline mode with cached attendance

### Nice to Have
- [ ] Multi-language support (Malayalam, Hindi, etc.)
- [ ] Cloud backup of timetables
- [ ] Push notifications for attendance warnings
- [ ] Class attendance analytics and trends

## Testing

### Backend
```bash
cd backend
# Activate venv
python test_fetch.py  # Test scraper
```

### Frontend
```bash
cd app
flutter test  # Run unit/widget tests
flutter run   # Manual testing
```

## Submitting Changes

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request**
   - Title: "feat: Clear description" or "fix: Bug description"
   - Description: What changed and why
   - Reference related issues: "Closes #123"

3. **Code Review**
   - Maintainers will review and suggest changes
   - Be open to feedback

## Reporting Bugs

Found a bug? Create an [Issue](../../issues) with:
- **Title**: Clear description of the problem
- **Environment**: Python version, Flutter version, OS, device
- **Steps to reproduce**: Detailed steps
- **Expected vs actual**: What should happen vs what happens
- **Screenshots**: If UI-related

## Pull Request Process

1. Update documentation if needed
2. Add comments for complex logic
3. Ensure both backend and frontend are working
4. Keep commits atomic (one feature per commit)
5. Use present tense in commit messages ("Add feature" not "Added feature")

## Questions?

- Open an [Issue](../../issues) with your question
- Start discussion in [Discussions](../../discussions)
- Check existing issues/PRs first

---

**Thank you for contributing!** 🎉
