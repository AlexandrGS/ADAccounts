# ADAccounts
Щоб пачками обробляту акаунти АД. Змінювати паролі, вмикати акаунт, вимикати.
Спочатку у файл "accounts.txt" занести акаунти,  

Ivanov.I.I  
Petrov.P.P  
Sydorov.S.S  

чи акаунти з паролем через пробел.  

Ivanov.I.I password1  
Petrov.P.P password2  
Sydorov.S.S password3  

Увімкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Enable -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Disable -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. І додатково поставити вимагати зміну пароля на наступному вході користувача. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -ChangePasswordAtLogon -Force

Якщо параметр -Force буде відсутній, то виконаеться лише імітація роботи скріпта.
