
use harry_potter_zhaox;
-- 1.Write a function num_spells_with_type(spell_type_p) 
-- that takes a spell type as a parameter and 
-- returns the number of spells with the spell type. (5 points) 

-- solution
DELIMITER $$
CREATE FUNCTION num_spells_with_type(spell_type_p VARCHAR(64)) 
	RETURNS INT DETERMINISTIC
    READS SQL DATA 
    BEGIN
    DECLARE spell_num INT DEFAULT 0;
    
    SELECT COUNT(id) into spell_num 
		from spell 
        where spell_type = spell_type_p;
	
    return (spell_num);
    end $$

DELIMITER ; 

-- test code
SELECT num_spells_with_type("charm");  -- 157 
SELECT num_spells_with_type("conjuration"); -- 7 
SELECT num_spells_with_type("");  -- 0
SELECT num_spells_with_type(null);  -- 0


-- 2. Write a procedure get_role_in_book(book_number_p) 
-- that takes a book number as parameter and 
-- returns a result set of all role (characters) names 
-- and the corresponding book title. 
-- Order the results by the book title, followed by the character_name in ascending order. (5 points) 

-- solution
DELIMITER $$
CREATE PROCEDURE get_role_in_book(book_number_p int) 
BEGIN
select title, name as character_name from book 
	inner join role_in_book 
    on book_number = book_id
    inner join role_trimmed
    on role_id = id
    where book_number = book_number_p
    order by character_name;
END$$
DELIMITER ; 

-- test code
Call get_role_in_book(1); -- 172 rows
Call get_role_in_book(2); -- 134 rows
Call get_role_in_book(7); -- 269 rows

-- 3. Write a procedure named get_spell_instance_details(spell_name_p)
-- that takes a spell name as an argument and 
-- returns the role id, the role name, the spell name, the spell type, 
-- and the book title where the spell may have occurred. 
-- Order the results in ascending order by the character name and the spell name. (5 points)

-- solution
DELIMITER $$
CREATE PROCEDURE get_spell_instance_details(spell_name_p varchar(64))
BEGIN
select r.id, r.name as role_name, s.name as spell_name, spell_type, title as book_title
	from spell as s
    inner join role_to_spell as rts
    on s.id = spell_id
    inner join role_trimmed as r
    on rts.role_id = r.id
    inner join role_in_book as rib
    on r.id = rib.role_id
    inner join book
    on book_number = rib.book_id
    where s.name = spell_name_p
    order by r.name, s.name;
END$$
DELIMITER ; 

-- test
-- select name from spell; -- try to find some spell name
call get_spell_instance_details("Accio"); -- return 17 rows 
call get_spell_instance_details("Aberto"); -- return 0 row
call get_spell_instance_details("Brackium Emendo"); -- return 12 rows


-- 4. Write a function named more_books(role1_p, role2_p). 
-- It takes 2 role names as parameters and 
-- returns 1 if role1_p has appeared in more books than role2, 
-- 0 if they appear in the same number of books ,
-- and -1 if role2_p appears in more books than role1. 
-- If the procedure is given an unknown role name (one not found in the role_trimmed table) , 
-- use SIGNAL with error number 45000, to mark the error. (5 points)
DELIMITER $$
CREATE FUNCTION more_books(role1_p varchar(64), role2_p varchar(64))
RETURNS INT DETERMINISTIC
READS SQL DATA 
BEGIN
declare count1 int; 
declare count2 int;

if not exists (select name from role_trimmed 
	where name = role1_p)
    or not exists(select name from role_trimmed 
	where name = role2_p)
then signal sqlstate '45000'
	set message_text = 'unknown role name';
end if;

select count(distinct book_id) into count1 
	from role_trimmed
	inner join role_in_book
    on id = role_id
    where name = role1_p;
    
select count(distinct book_id) into count2 
	from role_trimmed
	inner join role_in_book
    on id = role_id
    where name = role2_p;

if (count1 > count2)
	then return 1;
elseif(count1 = count2)
	then return 0;
else
	 return -1;
end if;

end$$
DELIMITER ;


-- test
-- select name from role_trimmed;
select more_books('Aberforth Dumbledore', 'Abraxas Malfoy'); -- 1
select more_books('Aberforth Dumbledore', 'Aberforth Dumbledore'); -- 0
select more_books('Hermione Granger', 'Albus Dumbledore'); -- 0
select more_books('Abraxas Malfoy', 'Aberforth Dumbledore'); -- -1
select more_books('Abraxas', 'Aberforth Dumbledore'); -- error
select more_books('Abraxas Malfoy', 'Aberforth'); -- error
select more_books(null, null); -- error
select more_books(null, 'Abraxas Malfoy'); -- error
select more_books('Abraxas Malfoy', null); -- error
-- 


-- 5. Write a procedure named get_house_affiliation(house_name_p) 
-- that takes a house name as a parameter
-- and returns the roles that are affiliated with the house. 
-- The four house names you are matching are: “Gryffindor” “Ravenclaw” “HufflePuff” and “Slytherin”
-- The result should contain the role id, role name, gender, eye color, hair color 
-- from the role_trimmed table as well as a derived column named "confidence_level" 
-- that represents the confidence that the person is associated with the house. 
-- The confidence level field should contain the value “Definitely” 
-- if the house name is an exact match for one of the four Hogwarts houses; 
-- the value “Highly likely” if the house name contains likely; 
-- and “Possibly” if the house name contains the term possibly or any other house name. 
-- If the procedure is given an unknown house name (one other than “Gryffindor”, 
-- “Ravenclaw”, “HufflePuff” and “Slytherin”) , 
-- use SIGNAL with error number 45000, to mark the error. (5 points)

-- solution
DELIMITER $$
CREATE PROCEDURE get_house_affiliation(house_name_p varchar(64))
BEGIN

IF house_name_p NOT IN ('Gryffindor', 'Ravenclaw', 'Hufflepuff', 'Slytherin') 
or house_name_p is null
THEN SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'unknown house name';
END IF;

SELECT id, r.name, gender, eye_color, hair_color,
	CASE WHEN r.house = house_name_p THEN 'Definitely'
		WHEN r.house LIKE '%likely%' THEN 'Highly likely'
		ELSE 'Possibly'
        END AS confidence_level
	FROM role_trimmed AS r
	INNER JOIN hogwart_house AS h
    ON house = h.name
    WHERE house LIKE CONCAT('%', house_name_p, '%');
END $$
DELIMITER ;


-- test 
-- select distinct house from role_trimmed;
-- select distinct name from hogwart_house;
-- 'Gryffindor', 'Ravenclaw', 'Hufflepuff', 'Slytherin'
call get_house_affiliation('Gryffindor');
call get_house_affiliation('Ravenclaw');
call get_house_affiliation('Hufflepuff');
call get_house_affiliation('Slytherin');
call get_house_affiliation('Slyth'); -- error
call get_house_affiliation('likely'); -- error
call get_house_affiliation(null);-- error


-- 6. Modify(ALTER)  the role_trimmed  table 
-- to contain a field called num_spells of type INTEGER 
-- and write a procedure called set_num_spell_count(role_p)  
-- that accepts a role_trimmed  name 
-- and  initializes the num_spells field to the number of spells the role has performed. 
-- If the procedure is given an  unknown role  name (one not found in the role_trimmed  table) , 
-- use SIGNAL with error number 45000, to mark the error. 
-- The role_trimmed table modification can 
-- occur outside or inside of the procedure but must be executed only once. (5 points)

-- solution
-- first add the num_spells filed into the role_trimmed table
ALTER TABLE role_trimmed
	ADD COLUMN num_spells INTEGER;


DELIMITER $$
CREATE PROCEDURE set_num_spell_count(role_p VARCHAR(64))
BEGIN
DECLARE spell_count int;

if (role_p) not in (select name from role_trimmed)
or role_p is null
	then SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'unknown role name';
END IF;

SELECT COUNT(spell_id) into spell_count FROM role_trimmed AS r
	left join role_to_spell as rts
    on r.id = rts.role_id
    where name = role_p;
    
update role_trimmed
	set num_spells = spell_count
    where name = role_p;
    
END $$
DELIMITER ;

-- test
call set_num_spell_count("Euan Abercrombie"); -- 0
call set_num_spell_count("Agnes"); -- 0
call set_num_spell_count("Harry Potter"); -- 51
call set_num_spell_count("Hermione Granger"); -- 36
call set_num_spell_count("Euan"); -- error
call set_num_spell_count(null); -- error

-- use the following to check result
select id, name, num_spells from role_trimmed;


-- 7. Create a procedure named update_all_roles_num_spells( ) 
-- that assigns the role_trimmed.num_spells  to the correct value. 
-- The correct value is determined by the number of spells performed by the character role. 
-- Use the procedure from problem 6 to complete this procedure. 
-- You will need a cursor and a handler to complete this procedure (5 points)

-- solution
DELIMITER $$
CREATE PROCEDURE update_all_roles_num_spells() 
BEGIN
declare role_name_p varchar(64);
declare row_not_found BOOL DEFAULT FALSE;

DECLARE role_cursor cursor for 
	select name from role_trimmed;
DECLARE CONTINUE HANDLER FOR NOT FOUND 
   SET row_not_found = TRUE; 

open role_cursor;
role_loop: LOOP
	fetch role_cursor into role_name_p;
	if row_not_found then
		leave role_loop;
	end if;
    call set_num_spell_count(role_name_p);
end loop;
close role_cursor;

END $$
DELIMITER ;

-- test
call update_all_roles_num_spells(); -- update 706 rows, role_id 2 has 0 num spells
select * from role_Trimmed;

select * from spell;
insert into role_to_spell (role_id, spell_id)
	values(2, 2); -- alter the table then updata again
select * from role_to_spell;
call update_all_roles_num_spells(); -- role_id 2 has 1 num spell


-- 8. Write a trigger that updates the role_trimmed.num_spells field 
-- when a tuple is inserted into the role_to_spell table. 
-- The trigger will need to compute the correct value 
-- for the num_spells for the role associated with the inserted role_to_spell tuple.
-- Name the trigger spell_cnt_update_after_role_to_spell_insert. 
-- Test the trigger by  inserting 2 instances of 
-- Tom Riddle performing the Avada Kedavra spell.  
-- Create another test case involving any other character role 
-- performing any other spell.  (10 points)

-- solution
DROP TRIGGER IF EXISTS spell_cnt_update_after_role_to_spell_insert;

DELIMITER $$ 
CREATE TRIGGER spell_cnt_update_after_role_to_spell_insert
	after insert on role_to_spell
    for each row
    begin
		declare new_role_name varchar(64);
        
        select name into new_role_name from role_trimmed
            where id = new.role_id;
            
		call set_num_spell_count(new_role_name);
	END $$
DELIMITER ;

-- test
select id, name, num_spells from role_trimmed where name like 'Tom Riddle%';   
-- id:350, name: Tom Riddle (Voldemort), num_spells:0,  
-- id:351, name: Tom Riddle Senior, num_spells:0

-- let Tom Riddle (Voldemort) perform Avada Kedavra spell
select id from spell where name = 'Avada Kedavra'; -- id:23
insert into role_to_spell (role_id, spell_id)
	values(350, 23);
select num_spells, id, name from role_trimmed where id = 350; 
-- num_spells:1

-- let Tom Riddle Senior perform Avada Kedavra spell
insert into role_to_spell (role_id, spell_id)
	values(351, 23);
select num_spells, id, name from role_trimmed where id = 351; 


-- role_id = 1 :Euan Abercrombie
-- insert Euan Abercrombie performing the Aberto spell
select num_spells from role_trimmed where name = 'Euan Abercrombie';  -- 0

insert into role_to_spell (role_id, spell_id)
	values(1, 1);
    
select num_spells from role_trimmed where name = 'Euan Abercrombie';  -- 1


-- 9.  Create and execute a prepared statement from the SQL workbench 
-- that calls the function num_spells_with_type(spell_type_p) . 
-- Use a user session variable to pass the spell type name to the function. 
-- Pass the value  “Hex” as the spell type. 
-- Please provide at least 2 other test cases as well. (5 points)

-- solution
prepare stmt1 from 'select num_spells_with_type(?)';

set @type1 = 'Hex';
execute stmt1 using @type1; -- 21

-- test
set @type2 = 'charm';
execute stmt1 using @type2; -- 157

set @type3 = 'conjuration';
execute stmt1 using @type3; -- 7

set @type4 = '%';
execute stmt1 using @type4; -- 0

-- 16.    Use the spell type  value provided by the user as an argument to the spell_has_type(stype_p) . 
-- Call the procedure. 
-- Here is a description of the needed procedure: spell_has_type(type_p)  
-- takes a spell type as parameter 
-- and  returns a result set of the spells with that type. 
-- The result should contain the spell id , the spell name, and the spell alias. 
-- If the user provides a spell type that is not found in the spell_type table, 
-- generate an error from the procedure stating that the passed spell type is not valid 
-- and use SIGNAL command to throw error ‘45000’. 
-- (please include this procedure in your .sql file for part 1)  (5 points) 

-- solution
DELIMITER $$ 
create procedure spell_has_type(type_p varchar(64))
begin
	if type_p not in (select type_name from spell_type)
    or type_p is null
		then signal sqlstate '45000'
			set message_text = 'unknown type';
	end if;
    
    select id, name, alias from spell
		where spell_type = type_p;
end$$

delimiter ;

call spell_has_type('Vanishment'); -- 301
call spell_has_type('spell'); -- 10
call spell_has_type('Transfiguration Jinx'); -- 2
call spell_has_type('Transfiguratio'); -- error
call spell_has_type(null); -- error

	


