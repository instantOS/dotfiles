#!/usr/bin/env python3
import re
import subprocess
import os

config_path = os.path.expanduser("~/.config/sheldon/plugins.toml")

if not os.path.exists(config_path):
    print(f"Error: Config file not found at {config_path}")
    exit(1)

with open(config_path, "r") as f:
    lines = f.readlines()

new_lines = []
current_plugin = None
current_github = None
has_rev = False

for line in lines:
    # Match plugin section headers
    m_header = re.match(r"^\[plugins\.([^\]]+)\]", line)
    if m_header:
        if current_github and not has_rev:
            # Fetch and insert missing rev line
            sha = (
                subprocess.check_output(
                    ["git", "ls-remote", f"https://github.com/{current_github}", "HEAD"]
                )
                .decode()
                .split()[0]
            )
            new_lines.append(f'rev = "{sha}"\n')
            print(f"📌 Added pin for {current_plugin}: {sha[:7]}")

        current_plugin = m_header.group(1)
        current_github = None
        has_rev = False
        new_lines.append(line)
        continue

    # Match github repo configuration
    m_github = re.match(r'^\s*github\s*=\s*"([^"]+)"', line)
    if m_github:
        current_github = m_github.group(1)
        new_lines.append(line)
        continue

    # Match existing rev configuration
    m_rev = re.match(r'^\s*rev\s*=\s*"([^"]+)"', line)
    if m_rev and current_github:
        has_rev = True
        # Fetch latest commit
        sha = (
            subprocess.check_output(
                ["git", "ls-remote", f"https://github.com/{current_github}", "HEAD"]
            )
            .decode()
            .split()[0]
        )
        new_lines.append(f'rev = "{sha}"\n')
        if sha != m_rev.group(1):
            print(f"🚀 Bumped {current_plugin}: {m_rev.group(1)[:7]} -> {sha[:7]}")
        else:
            print(f"✨ {current_plugin} is up to date: {sha[:7]}")
        continue

    new_lines.append(line)

# Handle the last plugin in the file
if current_github and not has_rev:
    sha = (
        subprocess.check_output(
            ["git", "ls-remote", f"https://github.com/{current_github}", "HEAD"]
        )
        .decode()
        .split()[0]
    )
    new_lines.append(f'rev = "{sha}"\n')
    print(f"📌 Added pin for {current_plugin}: {sha[:7]}")

with open(config_path, "w") as f:
    f.writelines(new_lines)
