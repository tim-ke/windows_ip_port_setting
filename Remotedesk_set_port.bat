@echo off  

set remotedesk_port=30306

::---------------------------------------------------------------

timeout /t 1
echo "modify remotedesk port"
set rd_port1="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
set rd_port2="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp"
reg add %rd_port1% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
reg add %rd_port2% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
echo "finish"



timeout /t 1
echo "firewall add"
netsh firewall delete portopening protocol=TCP port=%remotedesk_port%
timeout /t 1
netsh advfirewall firewall add rule name="RemoteDesk%remotedesk_port%" protocol=TCP dir=in localport=%remotedesk_port% action=allow
echo "finish"


timeout /t 1
echo "restart remotedesk"
net stop "Remote Desktop Services" /y
timeout /t 2
net start "Remote Desktop Services"
echo "finish"

pause
