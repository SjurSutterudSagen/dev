# How to set Nvidia GPU power limit permanently

## Add power level service

1. Copy /linux/etc/systemd/system/nvidia-power-limit.service to /etc/systemd/system/nvidia-power-limit.service

2. Activate the service to set the power level on boot
- sudo systemctl enable nvidia-power-limit.service

## Activate power level manually

- Check current power level
nvidia-smi -q -d POWER

- Set power level
sudo nvidia-smi -pl 200