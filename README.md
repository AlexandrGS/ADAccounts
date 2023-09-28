# ADAccounts
Щоб пачками обробляту акаунти АД. Змінювати паролі, вмикати акаунт, вимикати.   
Скріпт потрібно запускати з правами адміністратора. Інакше недоступні кілька параметрів акаунта в Active Directory.  
Спочатку у файл "accounts.txt" занести акаунти,  

Ivanenko.I.I  
Petrenko.P.P  
Sydorenko.S.S  

чи акаунти з паролем через пробел.  

Ivanenko.I.I password1  
Petrenko.P.P password2  
Sydorenko.S.S password3  

Увімкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Enable -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Disable -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. І додатково поставити вимагати зміну пароля на наступному вході користувача. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -ChangePasswordAtLogon -Force

Якщо параметр -Force буде відсутній, то виконаеться лише імітація роботи скріпта.
