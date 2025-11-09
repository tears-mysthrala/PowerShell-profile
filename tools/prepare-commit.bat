@echo off
REM Script to prepare repository for commit/push
REM Run this before git add/commit to ensure docs are updated

echo Generating function documentation...
pwsh -NoProfile -ExecutionPolicy Bypass -File tools/generate_function_docs.ps1

echo.
echo Docs updated. You can now add, commit, and push your changes.
echo.