# Simple Deployment Script for Bangmio (PowerShell)
# Run in PowerShell: .\deploy-simple.ps1

$ErrorActionPreference = "Stop"

Write-Host "=== Bangmio Simple Deployment ===" -ForegroundColor Cyan

# Function to log messages
function Write-Log {
    param([string]$Message, [string]$Color = "White")
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor $Color
}

# 1. Check prerequisites
Write-Log "Checking prerequisites..." "Green"

# Check Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Git is not installed. Please install Git from https://git-scm.com/" "Red"
    exit 1
}

# Check Node.js and npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Log "Node.js is not installed. Please install Node.js from https://nodejs.org/" "Red"
    exit 1
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Log "npm is not installed (should come with Node.js)" "Red"
    exit 1
}

Write-Log "All prerequisites are satisfied" "Green"

# 2. Check Git configuration
Write-Log "Checking Git configuration..." "Green"
$gitName = git config user.name
$gitEmail = git config user.email

if ([string]::IsNullOrEmpty($gitName) -or [string]::IsNullOrEmpty($gitEmail)) {
    Write-Log "Git user information is not configured." "Yellow"
    $gitName = Read-Host "Enter your GitHub username"
    $gitEmail = Read-Host "Enter your GitHub email"
    git config user.name $gitName
    git config user.email $gitEmail
    Write-Log "Git user configured: $gitName <$gitEmail>" "Green"
} else {
    Write-Log "Git user configured: $gitName <$gitEmail>" "Green"
}

# 3. Check remote repository
Write-Log "Checking remote repository..." "Green"
$remoteUrl = ""
try {
    $remoteUrl = git remote get-url origin
    Write-Log "Remote repository: $remoteUrl" "Green"
} catch {
    Write-Log "No remote repository configured." "Red"
    Write-Log "Please add remote repository first:" "Yellow"
    Write-Log "  git remote add origin https://github.com/sparkmio/Bangmio.git" "Yellow"
    Write-Log "Or if using SSH: git remote add origin git@github.com:sparkmio/Bangmio.git" "Yellow"
    exit 1
}

# 4. Add, commit, and push changes
Write-Log "Checking for changes to commit..." "Green"
git add .
$status = git status --porcelain

if ($status) {
    Write-Log "Found changes to commit:" "Green"
    git status --short
    
    $commitMessage = Read-Host "Enter commit message (or press Enter for default)"
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "Update Bangmio website"
    }
    
    git commit -m $commitMessage
    Write-Log "Changes committed" "Green"
} else {
    Write-Log "No changes to commit" "Yellow"
}

# 5. Push to GitHub
Write-Log "Pushing to GitHub..." "Green"
Write-Log "Note: If authentication fails, you may need to:" "Yellow"
Write-Log "1. Use a Personal Access Token (PAT)" "Yellow"
Write-Log "2. Configure SSH keys" "Yellow"
Write-Log "3. Use Git Credential Manager" "Yellow"
Write-Log "See DEPLOY_GUIDE.md for details" "Yellow"

$choice = Read-Host "Continue with push? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    try {
        git push origin master
        Write-Log "Successfully pushed to GitHub!" "Green"
    } catch {
        Write-Log "Push failed. Please check authentication." "Red"
        Write-Log "You can manually push using:" "Yellow"
        Write-Log "  git push origin master" "Yellow"
        Write-Log "Or configure authentication first." "Yellow"
    }
} else {
    Write-Log "Push skipped. You can manually push later." "Yellow"
}

# 6. Build frontend
Write-Log "Building frontend..." "Green"
Set-Location frontend
npm run build
Set-Location ..
Write-Log "Frontend built successfully" "Green"

# 7. Deploy to GitHub Pages
Write-Log "Deploying to GitHub Pages..." "Green"
Write-Log "Creating gh-pages branch..." "Green"

# Check if we're on master branch
$currentBranch = git branch --show-current
if ($currentBranch -ne 'master') {
    Write-Log "Switching to master branch..." "Yellow"
    git checkout master
}

# Create orphan branch for GitHub Pages
git checkout --orphan gh-pages
git rm -rf .

# Copy built files
Copy-Item -Path "frontend\dist\*" -Destination "." -Recurse -Force
if (Test-Path "frontend\dist\.gitignore") {
    Copy-Item -Path "frontend\dist\.gitignore" -Destination "."
}

# Add and commit
git add .
git commit -m "Deploy to GitHub Pages"

Write-Log "To complete GitHub Pages deployment:" "Cyan"
Write-Log "1. Push gh-pages branch: git push -u origin gh-pages" "Cyan"
Write-Log "2. Go to GitHub repository Settings > Pages" "Cyan"
Write-Log "3. Select source: gh-pages branch, root folder" "Cyan"
Write-Log "4. Your site will be at: https://sparkmio.github.io/Bangmio/" "Cyan"

$pushPages = Read-Host "Push gh-pages branch now? (Y/N)"
if ($pushPages -eq 'Y' -or $pushPages -eq 'y') {
    try {
        git push -u origin gh-pages
        Write-Log "GitHub Pages deployed!" "Green"
    } catch {
        Write-Log "Failed to push gh-pages branch. Push manually later." "Red"
    }
}

# Switch back to master
git checkout master
Write-Log "Switched back to master branch" "Green"

Write-Host "=== Deployment Steps Complete ===" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. If pushes failed, check DEPLOY_GUIDE.md for authentication help" -ForegroundColor Yellow
Write-Host "2. Enable GitHub Pages in repository Settings" -ForegroundColor Yellow
Write-Host "3. Test your site at https://sparkmio.github.io/Bangmio/" -ForegroundColor Yellow