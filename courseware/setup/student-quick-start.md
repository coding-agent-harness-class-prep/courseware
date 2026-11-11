# Start Here: Your Practice Repository

You'll do every activity in your own copy of a small orders app, kept in a private repository in your
own GitHub account. Setting it up takes about ten minutes, and you do all of it on your training VM.
Pick one language and use it all session: **.NET** (`orders-dotnet`) or **Java** (`orders-java`).

---

## 1. Sign in to GitHub

Open the browser on your VM, go to <https://github.com/login>, and sign in with the enterprise account
you were given for the training. It signs in through Microsoft, so you enter the Microsoft account
credentials you were given on a Microsoft sign-in page. Use that training account for every step
below, never a personal one.

## 2. Sign in from the terminal

Open **PowerShell** and run these two commands. The first shows a one-time code: press Enter, paste the
code into the browser page that opens, and approve the request. If it asks whether to authenticate Git
with your GitHub credentials, answer **Yes**.

```powershell
gh auth login --web --git-protocol https --scopes workflow
gh auth setup-git
```

## 3. Copy the orders app into your own repository

Your enterprise account can't fork a repository from outside its enterprise, so you copy the app
instead. The block for your language clones the course's copy, creates an empty private repository in
your account, points your clone at it, and pushes. Stay in the same PowerShell window and run the
block.

```powershell
# .NET
$me = gh api user -q .login
$repo = "$me/orders-dotnet"
git clone https://github.com/coding-agent-harness-class/orders-dotnet.git "$HOME\orders-dotnet"
Set-Location "$HOME\orders-dotnet"
gh repo create $repo --private
git remote remove origin
git remote add origin "https://github.com/$repo.git"
git push -u origin main
gh repo set-default $repo
```

```powershell
# Java
$me = gh api user -q .login
$repo = "$me/orders-java"
git clone https://github.com/coding-agent-harness-class/orders-java.git "$HOME\orders-java"
Set-Location "$HOME\orders-java"
gh repo create $repo --private
git remote remove origin
git remote add origin "https://github.com/$repo.git"
git push -u origin main
gh repo set-default $repo
```

Then tell Git who you are, in the same window:

```powershell
git config --global user.name "$me"
git config --global user.email "$(gh api user -q .id)+$me@users.noreply.github.com"
```

## 4. Check your repository

Open your new repository in the browser:

```powershell
gh repo view --web
```

You should see the app's files under your own username. GitHub Actions doesn't run in the personal
repositories of enterprise accounts, so the **Actions** tab won't show any runs. That's expected, and
your instructor shows the parts of the course that need Actions.

## 5. Sign in to the Copilot CLI

Still in your project folder, start the CLI:

```powershell
copilot
```

If it asks whether to trust the folder, say yes. If it asks you to sign in, type `/login` and finish in
the browser. Type `/exit` to leave.

## 6. Open the project in VS Code and sign in to Copilot

Open your project folder in VS Code from the same window:

```powershell
code .
```

If VS Code asks whether you trust the authors of the files in this folder, choose to trust them. Then
sign in to Copilot:

1. Hover over the **Copilot** icon in the Status Bar at the bottom of the window, and select
   **Use AI Features**.
2. In the sign-in dialog, choose to continue with **GitHub** (not GHE.com).
3. Your browser opens. Check that it's signed in with your training account, then approve the request
   from Visual Studio Code.
4. If the browser asks to open Visual Studio Code, allow it. You're back in VS Code and signed in.

To check it worked, select the **Accounts** icon (the person at the bottom of the Activity Bar on the
left) and make sure it shows your training account. Then open Chat with **Ctrl+Alt+I** and ask
*"What does this project do?"*. If you get an answer, you're ready.

If VS Code says it signed you up for Copilot Free, or the Accounts menu shows a different account, you
signed in with the wrong one. In the **Accounts** menu choose **Sign out**, then sign in again from the
Copilot icon in the Status Bar, using your training account in the browser.

## 7. Tell us you're done

Paste your repository's address in the meeting chat. It should start with `https://github.com/`
followed by your username.

---

## If something goes wrong

- If `gh repo create` says you can't create a repository, tell your instructor, and keep going with
  your local clone: Modules 1 and 2 and most of Module 4 work without the repository on GitHub.
- If `git remote add` says `origin` already exists, run `git remote remove origin`, then run the rest
  of the block from `git remote add` onward.
- If `git push` is refused because the token lacks the `workflow` scope, run
  `gh auth refresh --scopes workflow` and push again.
- If `git push` asks for a user name or password, run `gh auth setup-git` and push again.
- If the browser signs you in as someone else, sign out of GitHub, sign back in with the training
  account, and repeat the step.

Anything else, say so in the meeting chat. The longer version of these steps, with the reasons behind
them, is in [Make your practice repo](../samples/README.md#make-your-practice-repo-do-this-during-the-welcome).
