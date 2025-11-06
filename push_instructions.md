Git / GitHub push instructions for `VAMPIRE` repo

1) Initialize the local repo (if not already):

   git init
   git add --all
   git commit -m "Initial import: NYC SQL, import script, Azure provisioning, CI"

2) Create GitHub repo (example using the `gh` CLI):

   gh repo create VAMPIRE --private --confirm

   # or create via web UI and then add remote. If you already created a repo, set remote:
   git remote add origin https://github.com/<your-org-or-username>/VAMPIRE.git

3) Push to GitHub (recommended to use a PAT or gh CLI auth):

   git branch -M main
   git push -u origin main

Notes
- Use a GitHub Personal Access Token (repo scope) or the `gh` CLI for authentication. Do NOT paste tokens into files.
- After pushing, add repository secrets: `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_DB`, `MYSQL_PWD` (for the Actions workflow). Then run the workflow from the Actions tab.
