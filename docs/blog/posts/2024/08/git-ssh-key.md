---
date: 2024-08-17
description: >
  Our new blog is built with the brand new built-in blog plugin. You can build
  a blog alongside your documentation or standalone
categories:
  - Development
  - Git
# links:
#   - setup/setting-up-a-blog.md
#   - plugins/blog.md
draft: false
---
# Connecting to Git with SSH 

Refer: [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

## First Generate a key

```powershell
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## Add it to the ssh-agent

Check agent is running:
```powershell
# start the ssh-agent in the background
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent
```

Add the key
```powershell
ssh-add ~/.ssh/id_ed25519
```

## Add they key to GitHub account.

Copy the key...
```powershell
cat ~/.ssh/id_ed25519.pub | clip
```

In the **SSH and GPG Keys** section of your GitHub settings, paste the result.

## Troubleshooting

After following [Testing your SSH connection](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection)
if that all passes, and still doesn't work with GitHub then possibly the cause is using a non-default name/location for the key.  If possible, use defaults, otherwise. The solution is to edit or create `~/.ssh/config` (OpenSSH docs for config and Configuring the Location of Identity Keys) to contain the following:

```text
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github-key
```

User must remain as `git` but change the IdentityFile to match.

