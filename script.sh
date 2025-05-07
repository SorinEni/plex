#!/bin/bash

# Exit on any error
set -e

echo "=== Updating and installing packages ==="
sudo apt update
sudo apt upgrade -y
sudo apt install -y qbittorrent-nox screen nano wget

echo "=== Backing up and adjusting SSH configuration ==="
# Backup original sshd_config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Comment out all 'PasswordAuthentication no' lines in all config files under sshd_config.d
echo "Commenting out conflicting PasswordAuthentication directives..."
sudo find /etc/ssh/sshd_config.d/ -type f -exec sudo sed -i 's/^\s*PasswordAuthentication\s\+no/#PasswordAuthentication no/' {} +

# Create new config snippet to allow password SSH
echo -e "PasswordAuthentication yes\nChallengeResponseAuthentication no\nUsePAM yes" | \
sudo tee /etc/ssh/sshd_config.d/allowpassword.conf > /dev/null

# Restart SSH service to apply changes
sudo systemctl restart ssh

echo "=== Enabling and starting Plex ==="
sudo systemctl enable plexmediaserver
sudo systemctl start plexmediaserver

echo "=== Creating media folder and setting permissions ==="
mkdir -p ~/media
sudo chown -R plex:plex ~/media
chmod -R 777 ~/media

echo "=== Setup complete! ==="
echo "To run qBittorrent in a screen session:"
echo "    screen qbittorrent-nox"
echo
echo "To reconnect to a screen session later:"
echo "    screen -ls        # list"
echo "    screen -R <id>    # resume"
echo
echo "To claim your Plex server, run this from your local machine:"
echo "    ssh -L 8888:localhost:32400 username@your-server-ip"
echo "Then open this in your browser:"
echo "    http://localhost:8888/web"