 #����� ��� ������� ����� ���� �������� ������ Active Directory
 #��������� ������� ���� � �������� �������� ������������ �� �������� � �����  ��� ������� � ����� ����� �����
 #� ���������� �� ������� [switch] ������ ���� ������ � ���������� - ������, �������, ����� �����
 #��� ������ ����, ������ ���� "Description" �������
 #������ ���� ����������� ����� ���� � ���������� ����� �������� �������� -Force
 #���� ������������ �������� 䳿, ���� �� ��������� ������ (��������-�������� ������), � � ����� ������ ��������, �� ������ �����������
 #
 
 Param (
    #���� � ��������� � ������
    #Ivanov.I.I
    #Petrov.P.P
    #�� ����� �������� ������ 
    #Sidorov.S.S Password1
    #Vasechkin.V.V Password2
    #���� � ���������. ��� �������� �� ������� � � ���� �����
    $accounts_file = ".\accounts.txt",
    #
    [string]$DescriptionPostfix = "����� ______",
    #��������� ������� � $accounts_file
    [switch]$Enable = $false,
    #�������� ������� � $accounts_file
    [switch]$Disable = $false,
    #������ ������ �������� � $accounts_file
    [switch]$ChangePassword = $false,
    #���� ������� $ChangePassword �� ��������� ���������� ���� ������ ��� ���������� ����
    [switch]$ChangePasswordAtLogon = $false,
    #������� ����������� ����. ��� ����� ��������� ����� ������� 
    [switch]$Force = $false
)

[string]$DescriptionPrefix_Enable  = "��������"
[string]$DescriptionPrefix_Disable = "��������"
[string]$DescriptionPrefix_ChangePassword = "������ ������"

#� ����� ������������ ������ ���� "��������" �������������� � �������� DescriptionProperty
#DescriptionProperty ���������� ���
$CurrentDate = Get-Date -Format "dd:MM:yyyy"
$Script:DescriptionProperty=""

$Script:CountReadingAccounts = 0
$Script:CountReadyAccount = 0
$Script:CountEnablingAccount = 0
$Script:CountDisablingAccount = 0
$Script:CountChangePassword = 0
$Script:CountErrorByHandlingAccount = 0

Import-Module ActiveDirectory

#�������� ������
function DisableADAccount($ADAccount){
    $SAMAccountName = $ADAccount.SAMAccountName
    if($ADAccount.Enabled) {
        Write-Host  "������� " $SAMAccountName " ������� � ���� ���� ����������. ������" -NoNewline
        $Script:CountReadyAccount++
        try {
            if($Force){
                Disable-ADAccount -Identity $ADAccount
                Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty"
            }
            $Script:CountDisablingAccount++
            Write-Host " - ������" -NoNewline
        }
        catch{
            $Script:CountErrorByHandlingAccount++
            Write-Host " - ����� �������" -NoNewline
        }
    }else{
        Write-Host "������� " $SAMAccountName " ��� ����������. ������� �� �" -NoNewline
    }
}

#�������� ������
function EnableADAccount($ADAccount){
    $SAMAccountName = $ADAccount.SAMAccountName
    if( -not $ADAccount.Enabled ) {
        Write-Host  "������� " $SAMAccountName " ������� � ���� ���� �������. ������" -NoNewline
        $Script:CountReadyAccount++
        try {
            if($Force){
                Enable-ADAccount -Identity $ADAccount
                Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty"
            }
            $Script:CountEnablingAccount++
            Write-Host " - ������" -NoNewline
        }
        catch{
            $Script:CountErrorByHandlingAccount++
            Write-Host " - ����� �������" -NoNewline
        }
    }else{
        Write-Host "������� " $SAMAccountName "��� �������. ������� �� �" -NoNewline
    }
}

#������ ������ �������
function ChangeADAccountPassword($ADAccount, $Password){
    $SAMAccountName = $ADAccount.SAMAccountName

    if($Password -eq "" -or $Password -eq $null){
        Write-Error -Message "������� ChangeADAccountPassword �������� ������ ������� �������" -Category InvalidArgument
        return
    }

    if( -not $ADAccount.Enabled ) {
        $Msg = "������ " + $SAMAccountName +" ��� �������. ������� �� �"
        Write-Error -Message $Msg -Category InvalidArgument
    }

    Write-Host  "������� " $SAMAccountName " ������ ������" -NoNewline
    $Script:CountReadyAccount++

    try {
        if($Force){
            Set-ADAccountPassword -Identity $ADAccount  -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -Force -Verbose) �PassThru
#            Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty"
            if($ChangePasswordAtLogon){
                Set-ADUser -Identity $ADAccount  -ChangePasswordAtLogon $true
            }
        }
        $Script:CountChangePassword++
        Write-Host " - ������" -NoNewline
    }
    catch{
        $Script:CountErrorByHandlingAccount++
        Write-Host " - ����� �������" -NoNewline
    }
}

function InitOk(){
    #����� ������� ���� ��������� � ������� ������������
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Error " ���������� ���� ��� �������� ������. ������� ������ � ������� ������������ � ������ �� ���"
        Return $False
    }

    if( $Enable -or $Disable -or $ChangePassword){
#    
    }else{
        $Msg = "���������� ������� ���� �� ������� �������� Enable �� Disable �� ChangePassword"
        Write-Error -Message $Msg -Category InvalidArgument
        Return $False
    }

    if($Enable){
        $Script:DescriptionProperty = $DescriptionPrefix_Enable
    }else{
        if($Disable){
            $Script:DescriptionProperty = $DescriptionPrefix_Disable
        }else{
            if($ChangePassword){
                $Script:DescriptionProperty = $DescriptionPrefix_ChangePassword
            }
        }
    }
    $Script:DescriptionProperty +=  " " + $CurrentDate + " " + $DescriptionPostfix

    Return $True
}

if (-not (InitOk)) {
    $Msg = "������� ��� ����������� ��������"
    Write-Error -Message $Msg -Category InvalidArgument
    Return
}

ForEach($Line in Get-Content $accounts_file){

    $Script:CountReadingAccounts++
    $ADAccount = 0
    $Do = $True

    $UserName = $Line.split(" ")[0]
    $Password = $Line.split(" ")[1] #���� ������ � ���������� ���� �� ����, �� ��� ������ �����

    try {
        $ADAccount = Get-ADUser $UserName
    }

    catch {
        $Msg = "������� ��� �������� ������ �������" + $UserName
        Write-Error -Message $Msg -Category ReadError
        $Do = $false
    }

    if($Do) {
        if($Enable){
            EnableADAccount $ADAccount 
        } else {
            if($Disable){
                DisableADAccount $ADAccount
            } else {
                if($ChangePassword){
                    ChangeADAccountPassword $ADAccount $Password
                }#if($ChangePassword){
            }#if($Disable){
        }#if($Enable)

        Write-Host ""

    } #if($Do) {

}#ForEach($Line in Get-Conten

    Write-Host "---------------------------------------------------------"
    Write-Host "������ � ����� ���������      " $Script:CountReadingAccounts        " ��������"
    Write-Host "� ��� " $Script:CountReadyAccount " ����� � ������ ���� ��������"
    Write-Host "������ ��������� ��������    " $Script:CountEnablingAccount        " ��������"
    Write-Host "������ ��������� �����������  " $Script:CountDisablingAccount       " ��������"
    Write-Host "������ ��������� ������� ������ " $Script:CountChangePassword       " ��������"
    Write-Host "�� ������� �������� "           $Script:CountErrorByHandlingAccount " ��������"
    Write-Host "---------------------------------------------------------"

    if(-not $Force){
        Write-Warning "�������� ���� �������� �� ����. ���� ������� �������� ��� ������� �������� -Force"
    }