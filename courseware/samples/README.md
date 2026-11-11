# Sample apps

The course works on four small, real codebases: two business domains, each written twice, once in .NET
and once in Java. They're ordinary projects with no course scaffolding in them, so Copilot sees what it
would see in your own repositories: a README, a solution or `pom.xml`, tests, a CI workflow, and a
`CHANGELOG.md`.

| Folder | Domain | Language | Who uses it |
|---|---|---|---|
| [`library-dotnet`](library-dotnet/README.md) | Library lending: books, members, loans, due dates, late fees | .NET 10, ASP.NET Core minimal API, xUnit v3 | The instructor, in the demos |
| [`library-java`](library-java/README.md) | Library lending | Java 21, Spring Boot 4, JUnit 6, Maven Wrapper | The instructor, in the demos |
| [`orders-dotnet`](orders-dotnet/README.md) | Orders: catalog, validation, discounts, sales tax | .NET 10, ASP.NET Core minimal API, xUnit v3 | You, in the activities |
| [`orders-java`](orders-java/README.md) | Orders | Java 21, Spring Boot 4, JUnit 6, Maven Wrapper | You, in the activities |

The demos and the activities use different domains on purpose. You watch an idea on the library app,
then apply it yourself to the orders app, where the code is new to you. Pick whichever language you
work in day to day; both versions of a domain behave the same way and the activities give commands
for both.

All four samples have no database (everything is in memory) and tests that pass as shipped. Each one
also has a `.github/workflows/copilot-setup-steps.yml` that prepares the Copilot cloud agent's
environment, which you'll look at in Module 3.

---

## Make your practice repo (do this during the welcome)

You'll work in **your own copy** of the orders app for the whole session, kept in a private repository
in your own GitHub account. Modules 1 and 2 happen on your machine; Modules 3 and 4 open pull
requests, so they need the repository on GitHub. It takes about five minutes, and the
[quick start](../setup/student-quick-start.md) has the same steps on one page.

Your instructor publishes both versions as public repositories,
[`coding-agent-harness-class/orders-dotnet`](https://github.com/coding-agent-harness-class/orders-dotnet)
and [`coding-agent-harness-class/orders-java`](https://github.com/coding-agent-harness-class/orders-java),
and posts their links in the meeting chat.

Your training account is an enterprise account, and those can't fork a repository from outside their
enterprise, so you copy the app instead: clone it, create an empty repository of your own, and push
your clone there. GitHub Actions and the Copilot cloud agent don't run in the personal repositories of
enterprise accounts, so CI and the cloud agent are the parts of the course your instructor shows in
the demos rather than you running them in your repository.

### 1. Sign in the GitHub CLI

```powershell
gh auth login --web --git-protocol https --scopes workflow
gh auth setup-git
```

The `workflow` scope lets you push the sample's `.github/workflows/` files, which GitHub refuses
without it, and `gh auth setup-git` makes Git push with the same sign-in. The
[Setup](../setup/README.md#sign-in) page has the other sign-in steps.

### 2. Copy the app into a repository of your own

Run the block for your language:

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

The repository is private because enterprise accounts can't create public ones. Swapping `origin` for your
own repository sends `git push` there, and `gh repo set-default` makes sure the issue and the pull
request you create from the terminal in Activities 03 and 04 go there too, rather than to your
instructor's original. `gh repo set-default --view` shows which repository `gh` is using.

### 3. Tell Git who you are

Your first commit is in Activity 02, and on a fresh VM Git will stop and ask who you are. Answer it
now, in the same window, with your account's no-reply address so your real email address stays private:

```powershell
git config --global user.name "$me"
git config --global user.email "$(gh api user -q .id)+$me@users.noreply.github.com"
```

### 4. Check it worked

`gh repo view --web` opens the repository, where you should see the app's files under your own
username. The **Actions** tab stays empty, because Actions doesn't run in an enterprise account's
personal repositories; that's expected.

Post your repository's URL in the meeting chat. It should start with `https://github.com/` followed by
your username. If `gh repo create` failed, tell your instructor and keep going with your local clone:
Modules 1 and 2 and most of Module 4 work without the repository on GitHub.

---

## If you fall behind

Activity 02's `assets/` folder holds the customization files that Activities 03 and 04 expect. Copy
them into your practice repo, commit, and push, and you can start either activity from there. Run the
block for your language from your practice repo's folder. Each one commits everything in the folder,
so choose **Keep** or **Undo** on any agent edits you've left pending first.

For .NET:

```powershell
Copy-Item -Recurse -Force "$HOME\copilot-course\courseware\activities\02_agent-mode-and-instructions\assets\dotnet\*" .
git add .; git commit -m "Add Copilot customization files"; git push
```

For Java:

```powershell
Copy-Item -Recurse -Force "$HOME\copilot-course\courseware\activities\02_agent-mode-and-instructions\assets\java\*" .
git add .; git commit -m "Add Copilot customization files"; git push
```
