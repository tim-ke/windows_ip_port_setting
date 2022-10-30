@echo off  

setlocal enabledelayedexpansion
set ip_range[0]=192.168.33.97
set ip_range[1]=192.168.34.97
set ip_range[2]=192.168.35.97
set ip_range[3]=192.168.36.97
set ip_range[4]=192.168.37.97
set ip_range[5]=192.168.38.97
set ip_range[6]=192.168.39.97
set ip_range[7]=192.168.40.97


set remotedesk_port=14004
set network_name=Ethernet0
set gateway=192.168.33.2
set netmask=255.255.255.224
set dns=8.8.8.8

::-------------------------------------------------------------------  
::設定連續IP
set ip_list_A=0
set ip_list_B=0
echo 設定為DHCP，清空IP表
netsh interface ip set address "Ethernet0" dhcp
timeout /t 2
setlocal EnableDelayed
echo 開始新增IP 
for /l %%i in (0,1,7) do (
  :: 陣列分割
  for /f "tokens=1,2,3,4 delims=." %%a in ("!ip_range[%%i]!") do (
	::錯誤的話可能是ip_list_A後面有空白
	set ip_list_A=%%a.%%b.%%c.
    set ip_list_B=%%d
    rem echo !ip_list_a!!ip_list_B!
  )
  for /l %%j in (1,1,29) do (
	 set /a ip_list_B+=1
	 netsh interface ip add address !network_name! !ip_list_A!!ip_list_B! !netmask! !gateway!
	 echo 新增IP:!ip_list_A!!ip_list_B! !netmask!
	 rem echo !ip_range[%%i]!
  )
)
echo 新增完成

::新增DNS
timeout /t 1
echo 新增DNS
netsh interface ip set dnsservers !network_name! static !dns! primary
echo 新增完成

::修改Remote Desk遠程端口(機碼)
timeout /t 1
echo 修改Remote Desk遠程端口
set rd_port1="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
set rd_port2="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp"
reg add %rd_port1% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
reg add %rd_port2% /v "PortNumber" /t REG_DWORD /d %remotedesk_port% /f
echo 修改完成

::啟用遠端桌面，允許連到此電腦(機碼)
timeout /t 1
echo 啟用遠端桌面，允許連到此電腦
set rd_start1="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server"
set rd_start2="HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
reg add %rd_start1% /v "fDenyTSConnections" /t REG_DWORD /d 0 /f
reg add %rd_start2% /v "UserAuthentication" /t REG_DWORD /d 0 /f
echo 啟用完成

::新增防火牆端口
timeout /t 1
echo 新增防火牆端口
netsh firewall delete portopening protocol=TCP port=%remotedesk_port%
timeout /t 1
netsh advfirewall firewall add rule name="RemoteDesk%remotedesk_port%" protocol=TCP dir=in localport=%remotedesk_port% action=allow
echo 新增完成

::重啟遠端連線
timeout /t 1
echo 重啟遠端連線
net stop "Remote Desktop Services" /y
timeout /t 2
net start "Remote Desktop Services"
echo 重啟完成

pause
