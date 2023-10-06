 #
 #https://github.com/AlexandrGS/ADAccounts
 #
 #Скріпт для обробці разом купи акаунтов домена Active Directory
 #Программа отримуе файл з переліком акаунтов користувачів чи акаунтов і через пробіл паролі
 #У відповідності до вхідних [switch] скріпта щось робить з акааунтами - вмикае, вимикае, змінюе паролі
 #При деяких діях, змінюе поле "Description" акаунта
 #Реальні зміни виконуються тільки якщо в командному рядку присутній параметр -Force
 #Якщо потребуеться виконати дії, котрі не вимагають пароля (увімкнути-вимкнути акаунт), а в файле пароль присутній, то пароль ігноруеться
 #
 
 Param (
    #Файл с акаунтами у вигляді
    #Ivanov.I.I
    #Petrov.P.P
    #Чи акаунт з паролем розділені пробелом 
    #Sidorov.S.S Password1
    #Vasechkin.V.V Password2
    #Файл с акаунтами. Без пробелов на початку і у кінці рядка
    $accounts_file = ".\accounts.txt",
    #Увимкнути акаунти з $accounts_file
    [switch]$EnableADAccounts = $false,
    #Вимкнути акаунти з $accounts_file
    [switch]$DisableADAccounts = $false,
    #Змінити пароль акаунтов з $accounts_file
    [switch]$ChangePasswordADAccounts = $false,
    #Видаленя акаунтов
    [switch]$DeleteADAccounts = $false,
    #Додатково установити зміну пароля при наступному вході
    [switch]$ChangePasswordAtLogon = $false,
    #Реально застосувати зміни. Без цього параметра тільки імітація 
    [switch]$Force = $false,
    #При декотрих діях змінюе поле "Description" акаунта
    #Початок запису генеруеться в функції Init , а тут можливо додати якесь завершення
    #Повний запис виглядае десь так "Увімкнено 04.10.2023 згідно наказу Іванова". Те що починаеться зі слова "згідно" і передаеться через цей параметр
    [string]$DescriptionPostfix = "згідно ______",
    #При старте скріпт перевіряе чи запущен він з адміністративними правами
    #Цей switch вимикае цю перевірку
    [switch]$DisableCheckAdminRight = $false
)

[string]$DescriptionPrefix_Enable  = "Увімкнено"
[string]$DescriptionPrefix_Disable = "Вимкнено"
[string]$DescriptionPrefix_ChangePassword = "Змінено пароль"

#У кожен заблокований акаунт поле "Описание" встановлюеться в значення DescriptionProperty
#DescriptionProperty формуеться далі
$CurrentDate = Get-Date -Format "dd:MM:yyyy"
$Script:DescriptionProperty=""

$Script:CountReadingAccounts = 0
$Script:CountReadyAccount = 0
$Script:CountEnablingAccount = 0
$Script:CountDisablingAccount = 0
$Script:CountDeletedAccount = 0
$Script:CountChangePassword = 0
$Script:CountErrorByHandlingAccount = 0

Import-Module ActiveDirectory

#Вимкнути акаунт
function DisableADAccount($ADAccount){
    $SAMAccountName = $ADAccount.SAMAccountName

    if( ($ADAccount -eq "") -or ($ADAccount -eq $null) -or ($ADAccount -eq 0) ){
        Write-Error -Message "Функція DisableADAccount отримала пустий параметр $ADAccount" -Category InvalidArgument
        return
    }

    if($ADAccount.Enabled) {
        Write-Host  "Аккаунт " $SAMAccountName " увімкнен і може бути заблокован. Блокую" -NoNewline
        $Script:CountReadyAccount++
        try {
            if($Force){
                Disable-ADAccount -Identity $ADAccount
                Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty"
                if($ChangePasswordAtLogon){
                    Set-ADUser -Identity $ADAccount  -ChangePasswordAtLogon $true
                }
            }
            $Script:CountDisablingAccount++
            Write-Host " - успішно" -NoNewline
        }
        catch{
            $Script:CountErrorByHandlingAccount++
            Write-Host " - якась помилка" -NoNewline
        }
    }else{
        Write-Host "Аккаунт " $SAMAccountName " вже заблокован. Залишаю як е" -NoNewline
    }
}

#Увімкнути акаунт
function EnableADAccount($ADAccount){
    $SAMAccountName = $ADAccount.SAMAccountName

    if( ($ADAccount -eq "") -or ($ADAccount -eq $null) -or ($ADAccount -eq 0) ){
        Write-Error -Message "Функція EnableADAccount отримала пустий параметр $ADAccount" -Category InvalidArgument
        return
    }

    if( -not $ADAccount.Enabled ) {
        Write-Host  "Аккаунт " $SAMAccountName " вимкнен и може бути увімкнен. Вмикаю" -NoNewline
        $Script:CountReadyAccount++
        try {
            if($Force){
                Enable-ADAccount -Identity $ADAccount
                Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty"
                if($ChangePasswordAtLogon){
                    Set-ADUser -Identity $ADAccount  -ChangePasswordAtLogon $true
                }
            }
            $Script:CountEnablingAccount++
            Write-Host " - успішно" -NoNewline
        }
        catch{
            $Script:CountErrorByHandlingAccount++
            Write-Host " - якась помилка" -NoNewline
        }
    }else{
        Write-Host "Аккаунт " $SAMAccountName "вже увімкнен. Залишаю як е" -NoNewline
    }
}

#
function DeleteADAccount($ADAccount){
    $SAMAccountName = $ADAccount.SAMAccountName

    if( ($ADAccount -eq "") -or ($ADAccount -eq $null) -or ($ADAccount -eq 0) ){
        Write-Error -Message "Функція DeleteADAccount отримала пустий параметр $ADAccount" -Category InvalidArgument
        return
    }

    if(($ADAccount -ne $null) -and ($ADAccount -ne "") ){
        Write-Host  "Аккаунт " $SAMAccountName " видаляю" -NoNewline
        $Script:CountReadyAccount++
        try {
            if($Force){
                Remove-ADUser -Identity $ADAccount -Confirm:$False | Out-Nul
            }
            $Script:CountDeletedAccount++
            Write-Host " - успішно" -NoNewline
        }
        catch{
            $Script:CountErrorByHandlingAccount++
            Write-Host " - якась помилка" -NoNewline
        }
    }else{
        $Msg = "Функція DeleteADAccount: вхідний параметр пуст"
        Write-Error -Message $Msg -Category InvalidArgument
    }

}

#Змінити пароль акаунта
function ChangeADAccountPassword($ADAccount, $Password){
    $SAMAccountName = $ADAccount.SAMAccountName

    if( ($ADAccount -eq "") -or ($ADAccount -eq $null) -or ($ADAccount -eq 0) ){
        Write-Error -Message "Функція ChangeADAccountPassword отримала пустий параметр $ADAccount" -Category InvalidArgument
        return
    }

    if($Password -eq "" -or $Password -eq $null){
        Write-Error -Message "Функція ChangeADAccountPassword отримала пароль нульової довжини" -Category InvalidArgument
        return
    }

    if( -not $ADAccount.Enabled ) {
        $Msg = "Акаунт " + $SAMAccountName +" вже вимкнен. Залишаю як е"
        Write-Error -Message $Msg -Category InvalidArgument
    }

    Write-Host  "Аккаунт " $SAMAccountName " пароль змінено" -NoNewline
    $Script:CountReadyAccount++

    try {
        if($Force){
            Set-ADAccountPassword -Identity $ADAccount  -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -Force -Verbose) –PassThru
#            Set-ADUser -Identity $ADAccount -Description "$Script:DescriptionProperty" #При зміні пароля не потрібно міняти поле Description акаунта
            if($ChangePasswordAtLogon){
                Set-ADUser -Identity $ADAccount  -ChangePasswordAtLogon $true
            }
        }
        $Script:CountChangePassword++
        Write-Host " - успішно" -NoNewline
    }
    catch{
        $Script:CountErrorByHandlingAccount++
        Write-Host " - якась помилка" -NoNewline
    }
}

function InitOk(){
    if( -not $DisableCheckAdminRight ){
        #Скріпт повинен бути запущений з правами адміністратора
        if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
            Write-Error " Недосттньо прав для виконаня скріпта. Потрібен запуск з правами адміністратора"
            Return $False
        }
    }

    if( -not (Test-Path -Path $accounts_file) ){
        $Msg = "Файл " + $accounts_file + " з акаунтами не знайдено"
        Write-Error $Msg  -Category InvalidArgument
        return $false
    }

    if( $EnableADAccounts -or $DisableADAccounts -or $DeleteADAccounts -or $ChangePasswordADAccounts){
#    
    }else{
        $Msg = "Обовязково повинен бути чи вхідний параметр EnableADAccounts чи DisableADAccounts чи DeleteADAccounts чи ChangePasswordADAccounts"
        Write-Error -Message $Msg -Category InvalidArgument
        Return $False
    }

    if($EnableADAccounts){
        $Script:DescriptionProperty = $DescriptionPrefix_Enable
    }else{
        if($DisableADAccounts){
            $Script:DescriptionProperty = $DescriptionPrefix_Disable
        }else{
            if($ChangePasswordADAccounts){
                $Script:DescriptionProperty = $DescriptionPrefix_ChangePassword
            }
        }
    }
    $Script:DescriptionProperty +=  " " + $CurrentDate + " " + $DescriptionPostfix

    Return $True
}

if (-not (InitOk)) {
    $Msg = "Помилка при ініціалізації програми"
    Write-Error -Message $Msg -Category InvalidArgument
    Return
}

ForEach($Line in Get-Content $accounts_file){

    $Script:CountReadingAccounts++
    $ADAccount = 0
    $Do = $True

    $UserName = $Line.Trim().Split(" ")[0]
    $Password = $Line.Trim().split(" ")[1] #Якщо пароля в текстовому файлі не буде, то тут пустий рядок

    try {
        $ADAccount = Get-ADUser -Identity $UserName
    }

    catch {
        $Msg = "Помилка при отриманні данних акаунта " + $UserName
        Write-Error -Message $Msg -Category ReadError
        $Do = $false
    }

    if($Do) {
        if($EnableADAccounts){
            EnableADAccount $ADAccount 
        } else {
            if($DisableADAccounts){
                DisableADAccount $ADAccount
            } else {
                if($ChangePasswordADAccounts){
                    ChangeADAccountPassword $ADAccount $Password
                }else{
                    if($DeleteADAccounts){
                        DeleteADAccount $ADAccount
                    }
                }#if($ChangePassword){
            }#if($Disable){
        }#if($Enable)

        Write-Host ""

    } #if($Do) {

}#ForEach($Line in Get-Conten

    Write-Host "---------------------------------------------------------"
    Write-Host "Усього з файла прочитано          " $Script:CountReadingAccounts        " акаунтов"
    Write-Host "З них                             " $Script:CountReadyAccount           " готові і можуть бути оброблені"
    Write-Host "Усього намагався увімкнути        " $Script:CountEnablingAccount        " акаунтов"
    Write-Host "Усього намагався заблокувати      " $Script:CountDisablingAccount       " акаунтов"
    Write-Host "Усього намагався видалити         " $Script:CountDeletedAccount         " акаунтов"
    Write-Host "Усього намагався зминити пароль   " $Script:CountChangePassword         " акаунтов"
    Write-Host "Не вдалося обробити               " $Script:CountErrorByHandlingAccount " акаунтов"
    Write-Host "---------------------------------------------------------"

    if(-not $Force){
        Write-Warning "Реальной зміни акаунтов не було. Якщо бажаете реальних змін додайте параметр -Force"
    }
