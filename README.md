# ADAccounts
Щоб пачками обробляту акаунти АД. Змінювати паролі, вмикати акаунт, вимикати.   
За замовчуваням скріпт стартуе з правами адміністратора. В мене якщо скріпт стартовав на контроллері домена Active Directory, то потрібно стартовати з адміністратівними правами (Інакше недоступні кілька параметрів акаунта в Active Directory). Якщо на робочому компютері, то не обовязково. Для зміни ціеї поведінки дивись параметр -DisableCheckAdminRight.    

Спочатку у файл "accounts.txt" занести акаунти,  

Ivanenko.I.I  
Petrenko.P.P  
Sydorenko.S.S  

чи акаунти з паролем.  

Ivanenko.I.I password1  
Petrenko.P.P password2  
Sydorenko.S.S password3  

Увімкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -EnableADAccounts -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані  
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -DisableADAccounts -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані.    
В поле Description акаунта буде додан запис "Вимкнуто ПОТОЧНА_ДАТА згідно наказу Іванова"  
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -DisableADAccounts -DescriptionPostfix "згідно наказу Іванова" -Force

Вимкнути усі акаунти з файла accounts.txt. Якщо у файлі будуть паролі, вони будуть проігноровані. При старті вимкнути перевірку чи стартуе скріпт з правами адміністратора. Параметр -DisableCheckAdminRight вимикае цю перевірку.      
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -DisableADAccounts -DisableCheckAdminRight -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. У файлі повинні бути паролі  
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -ChangePasswordADAccounts -Force

Змінити паролі у всіх акаунтов з файла accounts.txt. І додатково поставити вимагати зміну пароля на наступному вході користувача. У файлі повинні бути паролі  
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -ChangePassword -ChangePasswordAtLogon -Force

Видалити з Active Directory усі акаунти з файла accounts.txt
.\ADAccounts.ps1 -AccountsFile "D:\accounts.txt" -DeleteADAccounts -Force

Встановити дату вимкненя акаунтів 10.01.2027. В прикладі нижче стоїть дата в буржуйському стилі. Спочатку місяць, потім день
Якщо у файлі будуть паролі, вони будуть проігноровані.
Зверніть увагу що во властивостях акаунта буде стояти дата попереднього дня 09.01.2027. Це нормально
.\ADAccounts.ps1 -AccountsFile .\accounts.txt -SetExpirationDate "01.10.2027"

Якщо параметр -Force буде відсутній, то виконаеться лише імітація роботи скріпта.
