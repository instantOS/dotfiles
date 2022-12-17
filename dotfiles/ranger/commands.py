#... all target ~/.config/ranger/commands.py
#... main begin
#... main hash EB44CB3CA5BA93B077C00E05C213572D46E727BB78B5E2EC112498E055CD5FC9
# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import absolute_import, division, print_function

import os

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

class fzf_select(Command):
    def execute(self):
        import subprocess
        import os
        from ranger.ext.get_executables import get_executables

        if "fzf" not in get_executables():
            self.fm.notify("Could not find fzf in the PATH.", bad=True)
            return

        env = os.environ.copy()
        env["FZF_DEFAULT_COMMAND"] = "fd"
        env[
            "FZF_DEFAULT_OPTS"
        ] = '--height=40% --layout=reverse --ansi --preview="{}"'.format(
            """
            (
                batcat --color=always {} ||
                bat --color=always {} ||
                cat {} ||
                tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
            ) 2>/dev/null | head -n 100
        """
        )

        fzf = self.fm.execute_command(
            "fzf --no-multi", env=env, universal_newlines=True, stdout=subprocess.PIPE
        )
        stdout, _ = fzf.communicate()
        if fzf.returncode == 0:
            selected = os.path.abspath(stdout.strip())
            if os.path.isdir(selected):
                self.fm.cd(selected)
            else:
                self.fm.select_file(selected)


class zoxide(Command):
    def execute(self):
        results = self.query(self.args[1:])
        if not results:
            return
        if os.path.isdir(results[0]):
            self.fm.cd(results[0])

    def query(self, args):
        from subprocess import PIPE

        try:
            zoxide = self.fm.execute_command(
                f"zoxide query {' '.join(self.args[1:])}", stdout=PIPE
            )
            stdout, stderr = zoxide.communicate()

            if zoxide.returncode == 0:
                output = stdout.decode("utf-8").strip()
                return output.splitlines()
            elif zoxide.returncode == 1:  # nothing found
                return None
            elif zoxide.returncode == 130:  # user cancelled
                return None
            else:
                output = (
                    stderr.decode("utf-8").strip()
                    or f"zoxide: unexpected error (exit code {zoxide.returncode})"
                )
                self.fm.notify(output, bad=True)
        except Exception as e:
            self.fm.notify(e, bad=True)

    def tab(self, tabnum):
        results = self.query(self.args[1:])
        if isinstance(results, list):
            return ["z {}".format(x) for x in results]


#... main end
