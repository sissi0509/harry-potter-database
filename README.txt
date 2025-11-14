
Download and unzip the hwk7zhaox.zip and open the extracted folder.

Database Setup

1. Open and run harry_potter_dump_zhaox.sql in MySQL Workbench to create the database and all related database programming objects.
2. Verify that you can see all tables in your MySQL Workbench.

---

Python Setup

Host Language: Python 
Version: 3.13.7

Using python3 is standard on macOS/Linux.On Windows, use python in command line if python3 doesn’t work.

0. check your computer has python, download Python 3.13.7

1. Make sure you have the databaseapp.py

2. Install required packages in command line:
   python3 -m pip install PyMySQL
   python3 -m pip install cryptography 


3. Run the program in command line:
   python3 databaseapp.py

4. When prompted, enter your OWN MySQL username and password. Then just followed the prompts.

examples of interaction:
Enter your MySQL username: (here enter your username)
Enter your MySQL password: (here enter your password)
Press Return/Enter after each input.

  
If enter everything correct, it will show menu, and prompt 
Enter your choice: (here enter your choice 1 or 2)
If 2 end everything
If other than 1 or 2, it will keep asking you to enter the choice until you choose the right one.
If 1 display all spell types

If choose 1, it will prompt 
Enter the spell type name (not the number) you want to see: 
Here enter the type name (case insensitive) not the number.

It will display all spells of that type and then return to the main menu.