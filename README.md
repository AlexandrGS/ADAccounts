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
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -EnableADAccounts -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -DisableADAccounts -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані. В поле Description акаунта буде додан запис "Вимкнуто ПОТОЧНА_ДАТА згідно наказу Іванова"  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -DisableADAccounts -DescriptionPostfix "згідно наказу Іванова" -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані. При старті вимкнути перевіркучи стартуе скріпт з правами адміністратора. Параметр -DisableCheckAdminRight вимикае цю перевірку.    
В мене якщо скріпт стартовав на контроллері домена Active Directory, то потрібно стартовати з адміністратівними правами.  
Якщо на робочому компютері, то ні
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -DisableADAccounts -DisableCheckAdminRight -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePasswordADAccounts -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. І додатково поставити вимагати зміну пароля на наступному вході користувача. У файлі повинні бути паролі  
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -ChangePasswordAtLogon -Force

Видалити всі акаунти з з файла accounts.txt
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -DeleteADAccounts -Force

Якщо параметр -Force буде відсутній, то виконаеться лише імітація роботи скріпта.
