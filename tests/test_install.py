"""Exercise the installer in disposable homes, never in the real home directory."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "scripts/install.sh"
LINKS = {
    ".zshrc": ROOT / "zsh/.zshrc",
    ".wezterm.lua": ROOT / "wezterm/.wezterm.lua",
    ".config/nvim": ROOT / "nvim/.config/nvim",
    ".config/opencode/opencode.json": ROOT / "opencode/.config/opencode/opencode.json",
    ".config/opencode/cli.json": ROOT / "opencode/.config/opencode/cli.json",
    ".config/opencode/AGENTS.md": ROOT / "opencode/.config/opencode/AGENTS.md",
    ".claude/settings.json": ROOT / "claude/.claude/settings.json",
    ".claude/CLAUDE.md": ROOT / "claude/.claude/CLAUDE.md",
    ".ideavimrc": ROOT / "ideavim/.ideavimrc",
    ".gitconfig": ROOT / "git/.gitconfig",
    ".config/git/ignore": ROOT / "git/.config/git/ignore",
}


class InstallTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-test-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with spaces"
        self.home.mkdir()
        self.env = os.environ.copy()
        self.env["HOME"] = str(self.home)
        self.env.pop("XDG_STATE_HOME", None)

    def run_install(self, *args, success=True):
        result = subprocess.run(
            ["/bin/bash", str(INSTALLER), *args],
            env=self.env,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result

    def backups(self, state=None):
        state = state or self.home / ".local/state"
        return list((state / "dotfiles/backups").glob("*"))

    def test_dry_run_does_not_write(self):
        self.run_install("--dry-run")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_clean_install_and_repeat(self):
        self.run_install()
        self.run_install()
        for relative, source in LINKS.items():
            target = self.home / relative
            self.assertTrue(target.is_symlink())
            self.assertEqual(target.resolve(), source)
        self.assertEqual(self.backups(), [])

    def test_conflict_does_not_partially_install(self):
        target = self.home / ".wezterm.lua"
        target.write_text("keep original")
        self.run_install(success=False)
        self.assertEqual(target.read_text(), "keep original")
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertEqual(self.backups(), [])

    def test_backup_preview_and_preserved_file(self):
        target = self.home / ".wezterm.lua"
        target.write_text("keep original")
        self.run_install("--backup", "--dry-run")
        self.assertEqual(target.read_text(), "keep original")
        self.assertEqual(self.backups(), [])
        self.run_install("--backup")
        backups = self.backups()
        self.assertEqual(len(backups), 1)
        self.assertEqual((backups[0] / ".wezterm.lua").read_text(), "keep original")

    def test_directory_backup_and_private_files_untouched(self):
        config = self.home / ".config/nvim"
        config.mkdir(parents=True)
        (config / "init.lua").write_text("keep original nvim")
        private = self.home / ".local/share/db_ui"
        private.mkdir(parents=True)
        (private / "sentinel").write_text("untouched")
        self.run_install("--backup")
        self.assertEqual(
            (self.backups()[0] / ".config/nvim/init.lua").read_text(),
            "keep original nvim",
        )
        self.assertEqual((private / "sentinel").read_text(), "untouched")

    def test_broken_symlink_and_custom_state_directory(self):
        target = self.home / ".zshrc"
        missing = self.home / "does-not-exist"
        target.symlink_to(missing)
        state = Path(self.temp.name) / "state with spaces"
        self.env["XDG_STATE_HOME"] = str(state)
        self.run_install("--backup")
        backup = self.backups(state)[0] / ".zshrc"
        self.assertTrue(backup.is_symlink())
        self.assertEqual(os.readlink(backup), str(missing))
        self.assertEqual(target.resolve(), LINKS[".zshrc"])

    def test_ai_config_conflict_does_not_partially_install(self):
        target = self.home / ".claude/CLAUDE.md"
        target.parent.mkdir()
        target.write_text("keep original instructions")
        self.run_install(success=False)
        self.assertEqual(target.read_text(), "keep original instructions")
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse((self.home / ".config/opencode").exists())
        self.assertEqual(self.backups(), [])

    def test_ai_config_file_backups_preserve_application_data(self):
        original_configs = {
            ".config/opencode/opencode.json": '{"original": true}',
            ".config/opencode/cli.json": '{"theme": {"name": "original"}}',
            ".config/opencode/AGENTS.md": "original OpenCode instructions",
            ".claude/settings.json": '{"model": "original"}',
            ".claude/CLAUDE.md": "original Claude instructions",
        }
        private_files = {
            ".config/opencode/service.json": "private service state",
            ".local/share/opencode/auth.json": "private auth sentinel",
            ".local/share/opencode/opencode.db": "private session sentinel",
            ".claude.json": "private account sentinel",
            ".claude/.credentials.json": "private credential sentinel",
            ".claude/history.jsonl": "private history sentinel",
            ".claude/projects/example/session.jsonl": "private transcript sentinel",
            ".claude/skills/synced/example/SKILL.md": "account-managed skill sentinel",
        }
        for relative, content in {**original_configs, **private_files}.items():
            target = self.home / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)

        self.run_install("--backup", "--dry-run")
        for relative, content in {**original_configs, **private_files}.items():
            self.assertEqual((self.home / relative).read_text(), content)
        self.assertEqual(self.backups(), [])

        self.run_install("--backup")
        backups = self.backups()
        self.assertEqual(len(backups), 1)
        for relative, content in original_configs.items():
            target = self.home / relative
            self.assertTrue(target.is_symlink())
            self.assertEqual(target.resolve(), LINKS[relative])
            self.assertEqual((backups[0] / relative).read_text(), content)
        for relative, content in private_files.items():
            self.assertEqual((self.home / relative).read_text(), content)
            self.assertFalse((backups[0] / relative).exists())
        for relative in (".config/opencode", ".claude"):
            self.assertTrue((self.home / relative).is_dir())
            self.assertFalse((self.home / relative).is_symlink())

    def test_help_and_invalid_option(self):
        self.run_install("--help")
        self.run_install("--invalid", success=False)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_git_ignore_conflict_does_not_partially_install(self):
        target = self.home / ".config/git/ignore"
        target.parent.mkdir(parents=True)
        target.write_text("original ignore rule")
        self.run_install(success=False)
        self.assertEqual(target.read_text(), "original ignore rule")
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse((self.home / ".gitconfig").exists())
        self.assertEqual(self.backups(), [])

    def test_git_and_ideavim_backups_preserve_other_git_files(self):
        originals = {
            ".ideavimrc": "original IdeaVim mappings",
            ".gitconfig": "[user]\n\tname = original\n",
            ".config/git/ignore": "original ignore rule",
        }
        private_files = {
            ".git-credentials": "private credential sentinel",
            ".config/git/work.inc": "private work configuration sentinel",
        }
        for relative, content in {**originals, **private_files}.items():
            target = self.home / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
        self.run_install("--backup")
        backups = self.backups()
        self.assertEqual(len(backups), 1)
        for relative, content in originals.items():
            self.assertEqual((backups[0] / relative).read_text(), content)
            self.assertEqual((self.home / relative).resolve(), LINKS[relative])
        for relative, content in private_files.items():
            self.assertEqual((self.home / relative).read_text(), content)
            self.assertFalse((backups[0] / relative).exists())
        self.assertFalse((self.home / ".config/git").is_symlink())

    def test_git_reads_identity_and_default_global_ignore(self):
        self.run_install()
        env = self.env.copy()
        for key in tuple(env):
            if key.startswith("GIT_") or key == "XDG_CONFIG_HOME":
                env.pop(key)
        env["GIT_CONFIG_NOSYSTEM"] = "1"
        for key in ("user.name", "user.email"):
            expected = subprocess.check_output(
                ["git", "config", "--file", str(LINKS[".gitconfig"]), "--get", key],
                env=env,
                text=True,
            )
            actual = subprocess.check_output(
                ["git", "config", "--global", "--get", key], env=env, text=True
            )
            self.assertEqual(actual, expected)

        project = self.home / "project"
        project.mkdir()
        subprocess.run(["git", "init", "--quiet", str(project)], env=env, check=True)
        result = subprocess.run(
            ["git", "check-ignore", ".claude/settings.local.json"],
            cwd=project,
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), ".claude/settings.local.json")


if __name__ == "__main__":
    unittest.main()
