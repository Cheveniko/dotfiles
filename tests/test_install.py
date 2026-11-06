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

    def test_help_and_invalid_option(self):
        self.run_install("--help")
        self.run_install("--invalid", success=False)
        self.assertEqual(list(self.home.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
