$ObsidianPublic = "E:\Obsidian\Vault_EvanCao\04_public"
$QuartzDir = "C:\Users\caoji\quartz"
$QuartzContent = "$QuartzDir\content"

Write-Host "Syncing Public to Quartz content..."

robocopy $ObsidianPublic $QuartzContent /MIR /XD ".obsidian" ".trash" /XF ".DS_Store" "Thumbs.db"

Set-Location $QuartzDir

Write-Host "Building Quartz locally..."
npx quartz build

Write-Host "Committing changes..."
git add .
git commit -m "sync public notes"

Write-Host "Pushing to GitHub..."
git push

Write-Host "Done. Cloudflare Pages will deploy automatically."