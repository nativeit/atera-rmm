# |  #   #   #   #   #   #   #   #   #   #   #   #   #   __//    N A T I V E . I T    //__    #   #   #   #   #   #   #   #   #   #   #   |
# |                                                                                                                                       |
# |  This script checks for Chocolatey and installs it if needed. It then installs FusionInventory for a GPLI server                      |
# |  specified by [{fusion_server_uri}]. A local report directory is added at C:\Support\FusionInventory.                                 |
# |                                                                                                                                       |
# |  This script was revised, tested, and approved on 2021-11-18.                                                                         |
# |                                                                                                                                       |
# |  #   #   #   #   #   #   #   #   #   #   #   #   #   __//    desk.nativeit.net     //__   #   #   #   #   #   #   #   #   #   #   #   |

# Must be run as admin/system

# Create directory for Fusion Inventory reports
mkdir C:\Support\FusionInventory

# Set install params and adjust permissions on C:\Support\FusionInventory
$fi_server = [{fusion_server_uri}] # ie: https://glpi.hostname.com/plugins/fusioninventory/ or https://hostname.com/glpi/plugins/fusioninventory/
$localdir = "C:\Support\FusionInventory"
$local_acl = Get-Acl $localdir
$local_aclentry = "Everyone","FullControl","Allow"
$acl_accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($local_aclentry)
$local_acl.SetAccessRule($acl_accessrule)
Get-ChildItem -Path "$localdir" -Recurse -Force | Set-Acl -AclObject $local_acl -Verbose

# Be sure choco.exe is added to $PATH
$choco = Join-Path -Path $env:ProgramData -ChildPath "chocolatey\choco.exe"

# Check for choco.exe, if not found, install it.
if (!(Test-Path $choco)) {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}else {
  Write-Host "Chocolatey Found!"
}

# Install Fusion Inventory agent with arguments and [{tag}]
choco install fusioninventory-agent --yes --no-progress --installargs "/execmode=service /delaytime=3600 /server='$fi_server' /local=$localdir /debug=1 /no-start-menu /tag='deploy-test' /add-firewall-exception /runnow"
