# Obsidian Vault Backup

## Description

This project provides a set of scripts to backup your Obsidian vault on GitHub.
It offers functionality to save, load, list, and automate backups of your Obsidian vault.
You are free to use this for yourself.

## Installation

To set up this backup system for your Obsidian vault, follow these steps:

1. Fork this repository on GitHub:

   - Go to the original repository page.
   - Click the "Fork" button in the top-right corner.
   - Choose your account to create a fork.

2. Clone your forked repository to your local machine:

   ```sh
   git clone https://github.com/your-username/obsidian-vault-backup.git
   cd obsidian-vault-backup
   ```

3. Set up the `.env` file:

   - Copy the `.env.template` file to `.env`:

     ```sh
     cp .env.template .env
     ```

   - Edit the `.env` file and set your Obsidian vault path and a secret key:

     ```sh
     BACKUP_SOURCE=path/to/your/vault
     BACKUP_SECRET=your-secret-key-here
     ```

4. Add the `main.sh` script to your shell configuration:

   - Open your shell configuration file (e.g., `~/.zshrc` for Zsh):

     ```sh
     vim ~/.zshrc
     ```

   - Add the following line at the end of the file:

     ```sh
     alias vault-backup="$HOME/Workspaces/backup-obsidian/bin/main.sh"
     ```

   - Save the file and reload your shell configuration:

     ```sh
     source ~/.zshrc
     ```

## Usage

### Save a vault

To create a backup of your Obsidian vault:

```sh
main.sh save -p ~/path/to/your/vault
```

This will create an encrypted backup in the `backups` directory and commit it to your Git repository.

### Load a vault

To restore a backup:

```sh
main.sh load -n backup-name -o ~/path/to/output/directory
```

Replace `backup-name` with the name of the backup you want to restore, and specify the output directory where you want to extract the backup.

### List available backups

To see a list of available backups:

```sh
main.sh list
```

### Automate backups

To set up automatic daily backups:

```sh
main.sh automate start
```

To stop automatic backups:

```sh
main.sh automate stop
```

## Notes

- Ensure you have the required dependencies installed: `tar`, `split`, `git`, `openssl`, and `crontab`.
- Keep your `BACKUP_SECRET` secure, as it's used to encrypt and decrypt your backups.
- The automation feature uses cron to schedule daily backups.
