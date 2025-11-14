"""
Harry Potter Database App
CS5200 HW7.
xi zhao
"""

import pymysql

DB_NAME = "harry_potter_zhaox" 

def display_menu():
    # prompt the user with a menu of options, return the selected option (question 12)
    print("*************************************************************************")
    print("Menu:")
    print("1: display the spell types")
    print("2: disconnect from the database and close the application. ")
    
    choice = input("Enter your choice: ")
    while choice not in ['1', '2']:
        print("Invalid choice. Please try again.")
        choice = input("Enter your choice: ")
    
    return choice

def choose_type(connection):
    # prompt the user to choose a spell type from the spell_type table (question 13, 14,15)
    # question 14: display all available spell types
    types = set()
    try:
        with connection.cursor() as c:
            c.execute('SELECT * FROM spell_type')
            print("Available spell types:\n")
            num = 1
            for row in c.fetchall():
                tp = row['type_name'].lower()
                print(f'{num}.{tp}')
                num += 1
                types.add(tp)

    except pymysql.Error as e:
        code, msg = e.args
        print("Error retrieving data from the database", code, msg)
    

    # question 13: prompt the user to choose a type from those displayed
    chosen_type = input("Enter the spell type name (not the number) you want to see: ").lower()

    # question 15: validate the user input
    while chosen_type not in types:
        print("Invalid type selected. Please try again.")
        chosen_type = input("Enter the spell type you want to see: ").lower()

    return chosen_type

def show_spells_of_type(connection, chosen_type):
    # display all spells of the chosen type (question 16, 17)
    try:
        with connection.cursor() as c:
            c.callproc('spell_has_type', (chosen_type,))
            print(f"\nSpells of type '{chosen_type}':\n")
            num = 1
            for row in c.fetchall():
                print(f'{num}. Spell id: {row["id"]}, spell name: {row["name"]}, spell alias: {row["alias"]}')
                num += 1

    except pymysql.Error as e:
        code, msg = e.args
        print("Error retrieving data from the database", code, msg)
    

def login_to_db(db_name):
    login = False

    while not login:
        # question 10: Prompt the user
        username = input("Enter your MySQL username: ")
        pword = input("Enter your MySQL password: ")

        # question 11: Use the user provided username and password values to connect
        try:
            connection = pymysql.connect(host='localhost',
                                        user=username,
                                        password=pword,
                                        database=db_name,
                                        cursorclass=pymysql.cursors.DictCursor,
                                        autocommit=True)
            
            print("Connected to the database, welcome", username)
            login = True
    

        except pymysql.Error as e:
            print("Cannot connect to the database")
    
    return connection

def work(db_name):
    connection = login_to_db(db_name)

    choice = "0"
    while choice != "2":
        choice = display_menu()
        if choice == "1":
            chosen_type = choose_type(connection)
            show_spells_of_type(connection, chosen_type)
            
    # question 18, chose 2 so close the connection and exit
    connection.close()

if __name__ == "__main__":
    work(DB_NAME)
