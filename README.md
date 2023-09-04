# ADAccounts
Щоб пачками обробляту акаунти АД. Змінювати паролі, вмикати акаунт, вимикати.
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Enable -Force
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -Disable -Force
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -Force
.\ADAccounts.ps1 -Accounts_File="D:\accounts.txt" -ChangePassword -ChangePasswordAtLogon -Force
