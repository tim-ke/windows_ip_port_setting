@echo off

setlocal enabledelayedexpansion
set ip_range[0]=154.31.216.193
set ip_range[1]=154.31.217.193
set ip_range[2]=154.31.218.193
set ip_range[3]=154.31.219.193
set ip_range[4]=154.31.220.193
set ip_range[5]=154.31.221.193
set ip_range[6]=154.31.222.193
set ip_range[7]=154.31.223.193


set remotedesk_port=20306
set network_name="Ethernet0"
set gateway=154.31.216.1
set netmask=255.255.255.0
set dns=8.8.8.8

::-------------------------------------------------------------------
::setting multiple IP
set ip_list_A=0
set ip_list_B=0
echo setting  DHCP clear IP 
netsh interface ip set address %network_name% dhcp
timeout /t 2
setlocal EnableDelayed
echo add IP
for /l %%i in (0,1,7) do (
  rem array split
  for /f "tokens=1,2,3,4 delims=." %%a in ("!ip_range[%%i]!") do (
     rem ip_list_A if last space is error 
     set ip_list_A=%%a.%%b.%%c.
     set ip_list_B=%%d
     rem echo !ip_list_A!!ip_list_B!
  )
  for /l %%j in (1,1,29) do (
     set /a ip_list_B+=1
     netsh interface ip add address !network_name! !ip_list_A!!ip_list_B! !netmask! !gateway!
     echo add IP: !ip_list_A!!ip_list_B! !netmask!
     rem echo !ip_range[%%i]!
  )
)
echo add IP Finish

::add DNS
timeout /t 1
echo add DNS
netsh interface ip set dnsservers !network_name! static !dns! primary
echo add DNS Finish

::modify Remote Desk port(regedit)
timeout /t 1
echo modify Remote Desk port(regedit)
set rd_port1="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
set rd_port2="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp"
reg add %rd_port1% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
reg add %rd_port2% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
echo modify Remote Desk port(regedit) Finish

::Enable Remote Desk connect as local PC (regedit)
timeout /t 1
echo Enable Remote Desk connect as local PC (regedit)
set rd_start1="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server"
set rd_start2="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
reg add %rd_start1% /v "fDenyTSConnections" /t REG_DWORD /d 0 /f
reg add %rd_start2% /v "UserAuthentication" /t REG_DWORD /d 0 /f
echo Enable Remote Desk connect as local PC (regedit) Finish

::add Firewall port
timeout /t 1
echo add Firewall port
netsh firewall delete portopening protocol=TCP port=%remotedesk_port%
timeout /t 1
netsh advfirewall firewall add rule name="RemoteDesk%remotedesk_port%" protocol=TCP dir=in localport=%remotedesk_port% action=allow
echo add Firewall port Finish

::Restart Remote Desk
timeout /t 1
echo Restart Remote Desk
net stop "Remote Desktop Services" /y
timeout /t 2
net start "Remote Desktop Services"
echo Restart Remote Desk Finish

pause
