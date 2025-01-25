chmod +x power_monitor.sh
sudo cp power_monitor.service /etc/systemd/system/power_monitor.service
sudo systemctl enable power_monitor.service
sudo systemctl start power_monitor.service
sudo systemctl status power_monitor.service
sudo journalctl -u power_monitor.service -f

