@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ==========================================
echo  Auto Deploy to GitHub (Trigger Netlify)
echo ==========================================
echo.

:: 检查 Git 仓库
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Not in a Git repository.
    pause
    exit /b 1
)

:: 显示当前状态
echo Current status:
git status --short
echo.

:: 询问是否继续
set /p confirm="Commit and push all changes? (y/n): "
if /i not "%confirm%"=="y" (
    echo Aborted.
    pause
    exit /b 0
)

:: 生成提交信息（含时间戳）
for /f "tokens=1-3 delims=/- " %%a in ('date /t') do set today=%%a-%%b-%%c
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set now=%%a:%%b
set commit_msg="Auto deploy at %today% %now%"

:: 如果输入了参数则使用参数作为提交信息
if not "%1"=="" set commit_msg=%1

echo.
echo Adding all changes (add, modify, delete)...
git add -A

echo Committing with message: %commit_msg%
git commit -m %commit_msg%

echo Pushing to origin/master...
git push origin master

if errorlevel 1 (
    echo [ERROR] Push failed. Please check your network/credentials.
) else (
    echo.
    echo ==========================================
    echo  Success! Netlify will auto-deploy soon.
    echo ==========================================
)

pause