#���� � ��������� ����
#Ivanov.A.S
#Petrov.D.F
#���� � ���������. ��� �������� � ������ � ����� ������
$accounts_file = "D:\Install\VPNOtchet\Disable_Accounts\disable_accounts.txt"
$enabled_accounts_file = "D:\Install\VPNOtchet\Disable_Accounts\enabled_accounts.csv"
$disabled_accounts_file = "D:\Install\VPNOtchet\Disable_Accounts\disabled_accounts.csv"

$CountReadingAccounts = 0

$EnabledAccounts = @()
$DisabledAccounts= @()

Import-Module ActiveDirectory

ForEach($UserName in Get-Content $accounts_file){
    $CountReadingAccounts++
    $Account = 0
    $Do = $true

    if(){
        $User= $Line.split(" ")[0]
    }

    try {
        $Account = Get-ADUser -Identity $UserName  -Properties *
    }
    catch {
        Write-Host "������ ��� ��������� ������ �������� " $UserName
        $Do = $false
    }
    if($Do) {

        $OneAccountData  = New-Object -Type PSObject -Property ([ordered]@{
            SamAccountName = $Account.SamAccountName;
            Name = $Account.Name;
            Organization = "";
        })

        $OneAccountData.Organization = $Account.Company
        if($Account.Company -ne $Account.Department){
            $OneAccountData.Organization += "," + $Account.Department
        }

        if($Account.Enabled) {
#            Write-Host  $UserName " ��������" -NoNewline
            $EnabledAccounts += $OneAccountData
        }else{
#            Write-Host  $UserName " ���������" -NoNewline
            $DisabledAccounts += $OneAccountData
        }

    } #if($Do) {
}

Write-Host "�������� ������� �������"
$EnabledAccounts | Export-CSV -Path $enabled_accounts_file -Delimiter ';' -Encoding UTF8 -NoTypeInformation
Write-Host "�������� ������� �������"
$DisabledAccounts | Export-CSV -Path $disabled_accounts_file -Delimiter ';' -Encoding UTF8 -NoTypeInformation 

#$EnabledAccounts
#Write-Host ""
#$DisabledAccounts


Write-Host "---------------------------------------------------------"
Write-Host "����� �� ����� ���������" $CountReadingAccounts "��������"
Write-Host "�� ���" $EnabledAccounts.Count " ���������"
Write-Host " � " $DisabledAccounts.Count " ����������"

# $Object | Export-CSV -Path $FileName -Delimiter ';' -Encoding UTF8 -NoTypeInformation -Append
