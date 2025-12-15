cd ~/Documents/vault_01
cat > YOUR-WORKFLOW.md << 'EOF'
# My Backend Workflow

## Morning Start
```
git checkout backend/database-setup
git pull origin develop
git merge develop
```

## Save Work
```
git add .
git commit -m "feat: description"
git push origin backend/database-setup
```

## Finish Feature
```
# Push final version
git push origin backend/database-setup
# Create Pull Request on GitHub
# Wait for review
# Merge to develop
```
EOF