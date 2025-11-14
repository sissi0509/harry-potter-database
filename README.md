# Harry Potter Database

A MySQL database application featuring stored procedures, functions, triggers, and a Python CLI for querying Harry Potter universe data.

## Overview

This project implements a relational database for the Harry Potter universe, including characters, spells, books, houses, and their relationships. The application demonstrates advanced database programming techniques including stored procedures, user-defined functions, triggers, and cursor-based operations.

## Database Schema

![Entity Relationship Diagram](erd.png)

The database consists of 10 tables modeling:

- **Characters** (role_trimmed) - 700+ characters with attributes like house, gender, patronus
- **Spells** - 300+ spells with types, aliases, and descriptions
- **Books** - All 7 Harry Potter books
- **Relationships** - Character appearances in books, spell usage, house affiliations

## Features

### Database Programming Objects

- **Stored Procedures**

  - `get_role_in_book(book_number)` - Retrieves all characters appearing in a specific book
  - `get_spell_instance_details(spell_name)` - Returns detailed information about spell usage
  - `get_house_affiliation(house_name)` - Finds characters affiliated with a Hogwarts house
  - `set_num_spell_count(role_name)` - Updates spell count for a character
  - `update_all_roles_num_spells()` - Batch updates spell counts for all characters

- **User-Defined Functions**

  - `num_spells_with_type(spell_type)` - Counts spells of a specific type
  - `more_books(role1, role2)` - Compares character book appearances

- **Triggers**
  - `spell_cnt_update_after_role_to_spell_insert` - Automatically updates spell counts when new spell usage is recorded

### Python CLI Application

Interactive command-line interface for database queries with:

- User authentication (MySQL credentials)
- Browse spell types
- Query spells by type
- Input validation and error handling

## Tech Stack

- **Database:** MySQL 8.0+
- **Programming Language:** Python 3.13
- **Libraries:** PyMySQL, cryptography

## Installation

### Prerequisites

- MySQL 8.0 or higher
- Python 3.13+
- pip package manager

### Database Setup

1. **Import the database:**

```bash
   mysql -u your_username -p < hwk7_potter_dump_zhaox.sql
```

Or open `hwk7_potter_dump_zhaox.sql` in MySQL Workbench and execute it.

2. **Verify tables were created:**

```sql
   USE harry_potter_zhaox;
   SHOW TABLES;
```

3. **Load stored procedures and functions:**

```bash
   mysql -u your_username -p harry_potter_zhaox < hwk7_dbos_zhaox.sql
```

### Python Application Setup

1. **Install required packages:**

```bash
   python3 -m pip install PyMySQL
   python3 -m pip install cryptography
```

2. **Run the application:**

```bash
   python3 databaseapp.py
```

## Usage

### Starting the Application

```bash
python3 databaseapp.py
```

### Sample Interaction

```
Enter your MySQL username: root
Enter your MySQL password: ****

Connected to the database, welcome root

*************************************************************************
Menu:
1: display the spell types
2: disconnect from the database and close the application.

Enter your choice: 1

Available spell types:

1. charm
2. curse
3. jinx
4. transfiguration
...

Enter the spell type name (not the number) you want to see: charm

Spells of type 'charm':

1. Spell id: 1, spell name: Aberto, spell alias:
2. Spell id: 2, spell name: Accio, spell alias: Summoning Charm
...
```
