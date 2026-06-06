-- 1. Создание последовательности (для задачи №2)
CREATE SEQUENCE IF NOT EXISTS lalala START WITH 100;

-- 2. Создание таблицы департаментов (для задач №14, №17, №18)
CREATE TABLE IF NOT EXISTS department
    (id SERIAL PRIMARY KEY,
    name TEXT,
    budget NUMERIC,
    head TEXT);

-- 3. Создание единой таблицы сотрудников
CREATE TABLE IF NOT EXISTS employees
    (id SERIAL PRIMARY KEY,
    name TEXT,
    salary NUMERIC,
    department_id INTEGER REFERENCES department(id));

-- Наполнение базовых таблиц тестовыми данными
INSERT INTO department (name, budget, head) 
VALUES 
    ('sales', 10000, 'Dima'), 
    ('data', 15000, 'Andy'), 
    ('marketing', 20000, 'Anna'), 
    ('finance', 5000, 'Masha'), 
    ('CFO', 18000, 'Stepan')
ON CONFLICT DO NOTHING;   

INSERT INTO employees (name, salary, department_id) 
VALUES 
    ('Дима', 5000, 4), 
    ('Андрей', 15000, 5), 
    ('Анна', 2000, 3), 
    ('Вадим', 4000, 4), 
    ('Арсений', 45000, 5), 
    ('Людмила', 3400, 4)
ON CONFLICT DO NOTHING;

-- ====================================================================
1. Write a program in PL/SQL to show the uses of static PL/SQL statement.
-- ====================================================================
DO $$
DECLARE 
    v_id INTEGER := 2;
    v_name TEXT;
    v_salary NUMERIC; 
BEGIN 
    SELECT name, salary
    INTO v_name, v_salary 
    FROM employees
    WHERE id = v_id; 
    
    RAISE NOTICE 'До повышения: сотрудник %, зарплата %', v_name, v_salary; 

    UPDATE employees
    SET salary = salary + 5000
    WHERE id = v_id; 

    SELECT salary
    INTO v_salary
    FROM employees
    WHERE id = v_id;

    RAISE NOTICE 'После повышения: сотрудник %, зарплата %', v_name, v_salary; 	
END;
$$;

DO $$
DECLARE
    emp_record RECORD;
BEGIN
    FOR emp_record IN
        SELECT id, name, salary
        FROM employees
        WHERE id IN (1, 2, 3)
    LOOP
        RAISE NOTICE 'Сотрудник % старая зп %', emp_record.name, emp_record.salary;
        
        UPDATE employees
        SET salary = emp_record.salary + 5000
        WHERE id = emp_record.id;
        
        RAISE NOTICE 'Новая зарплата %', emp_record.salary + 5000;
    END LOOP;
END;
$$;

-- ====================================================================
2. Write a program in PL/SQL to show the uses of CURRVAL and NEXTVAL with a sequence name.
-- ====================================================================
DO $$
DECLARE 
    v_generated NUMERIC;
    v_current NUMERIC;
BEGIN 
    v_generated := NEXTVAL('lalala');
    RAISE NOTICE 'Вызвали счетчик, %', v_generated;

    v_current := CURRVAL('lalala');
    RAISE NOTICE 'Текущее число на счетчике, %', v_current;

    v_generated := NEXTVAL('lalala');
    RAISE NOTICE 'Следующее число будет, %', v_generated;
END;
$$;

-- ====================================================================
3. Write a program in PL/SQL to find the number of rows affected by the use of SQL%ROWCOUNT attributes of an implicit cursor.
-- ====================================================================
DO $$
DECLARE 
    v_change INTEGER;
BEGIN 
    UPDATE employees
    SET salary = salary + 2000
    WHERE salary < 20000;
    
    GET DIAGNOSTICS v_change := ROW_COUNT;
    RAISE NOTICE 'Зп повысилась у % человек', v_change;
END;
$$;

-- ====================================================================
4. Write a program in PL/SQL to show the uses of implicit cursor without using any attribute.
-- ====================================================================
DO $$
BEGIN 
    UPDATE employees
    SET salary = 25000
    WHERE name = 'Дима';
    
    RAISE NOTICE 'Данные обновлены неявным курсором';
END;
$$;

-- ====================================================================
5. Write a program in PL/SQL to show the uses of SQL%FOUND to determine if a DELETE statement affected any rows.
-- ====================================================================
DO $$ 
BEGIN 
    DELETE FROM employees
    WHERE name = 'Арсений';

    IF FOUND THEN
        RAISE NOTICE 'Данные сотрудника были успешно удалены';
    ELSE
        RAISE NOTICE 'Такой сотрудник в таблице не найден';
    END IF;
END;
$$;

-- ====================================================================
6. Write a program in PL/SQL to show the uses of SQL%NOTFOUND to determine if an UPDATE statement affected any rows.
-- ====================================================================
DO $$ 
BEGIN 
    DELETE FROM employees
    WHERE name = 'Людмила';

    IF NOT FOUND THEN
        RAISE NOTICE 'Данные сотрудника не найдены';
    ELSE
        RAISE NOTICE 'Сотрудник удален';
    END IF;
END;
$$;

-- ====================================================================
7. Write a program in PL/SQL to create a table-based record using the %ROWTYPE attribute.
-- ====================================================================
DO $$
DECLARE 
    v_empl employees%ROWTYPE;
BEGIN 
    SELECT * INTO v_empl
    FROM employees
    WHERE id = 1;
    
    RAISE NOTICE 'Зарплата сотрудника % составляет %', v_empl.name, v_empl.salary;
END;
$$;

-- ====================================================================
8. Write a program in PL/SQL to display a table based detail information for the employee of ID 149 from the employees table.
-- ====================================================================
DO $$
DECLARE 
    v_empl employees%ROWTYPE;
BEGIN 
    SELECT *
    INTO v_empl
    FROM employees 
    WHERE id = 1;
    
    RAISE NOTICE 'Данные о сотруднике %: зарплата составляет %', v_empl.name, v_empl.salary;
END;
$$;

-- ====================================================================
9. Write a program in PL/SQL to display a cursor based detail information of employees from employees table.
-- ====================================================================
DO $$
DECLARE 
    emp RECORD;
BEGIN 
    FOR emp IN 
        SELECT id, name, salary
        FROM employees
    LOOP 
        RAISE NOTICE 'ID: %, имя: %, зарплата: %', emp.id, emp.name, emp.salary;
    END LOOP;
END;
$$;

-- ====================================================================
10. Write a program in PL/SQL to retrieve the records from the employees table and display them using cursors.
-- ====================================================================
DO $$
DECLARE 
    emp_curs CURSOR FOR
        SELECT id, name, salary FROM employees;
    v_id INTEGER;
    v_name TEXT;
    v_salary NUMERIC;
BEGIN 
    OPEN emp_curs;
    LOOP
        FETCH NEXT FROM emp_curs INTO v_id, v_name, v_salary;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Сотрудник % % (зп %)', v_id, v_name, v_salary;
    END LOOP;
    CLOSE emp_curs;
END;
$$;

-- ====================================================================
11. Write a program in PL/SQL to declare a record datatype with same datatype of tables using %TYPE attribute.
-- ====================================================================
DO $$
DECLARE
    v_id employees.id%TYPE;
    v_name employees.name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN 
    SELECT id, name, salary 
    INTO v_id, v_name, v_salary
    FROM employees
    WHERE id = 1;

    RAISE NOTICE 'Сотрудник %, имя %, зарплата %', v_id, v_name, v_salary;	
END;
$$;

-- ====================================================================
12. Write a program in PL/SQL to create an implicit cursor with for loop.
-- ====================================================================
DO $$
DECLARE 
    empl RECORD;
BEGIN 
    FOR empl IN 
        SELECT id, name, salary FROM employees WHERE salary > 5000
    LOOP
        RAISE NOTICE 'Сотрудник % имеет зп больше 5000', empl.name;
    END LOOP;
END;
$$;

-- ====================================================================
13. Write a program in PL/SQL to create an explicit cursor with for loop.
-- ====================================================================
DO $$
DECLARE 
    empl RECORD; 
    empl_cursor CURSOR FOR SELECT name FROM employees WHERE salary < 6000;
BEGIN 
    FOR empl IN empl_cursor
    LOOP
        RAISE NOTICE 'У сотрудника % зп меньше 6000', empl.name;
    END LOOP;
END;
$$;

-- ====================================================================
14. Create a PL/SQL block to increase salary of employees in the department 50 using WHERE CURRENT OF clause.
-- ====================================================================
DO $$
DECLARE 
    v_empl RECORD;
    empl_curs CURSOR FOR 
        SELECT id, name, salary, department_id
        FROM employees
        FOR UPDATE;
BEGIN 
    OPEN empl_curs;
    LOOP
        FETCH NEXT FROM empl_curs INTO v_empl;
        EXIT WHEN NOT FOUND;
        
        IF v_empl.department_id = 4 THEN 
            UPDATE employees
            SET salary = salary + 2000
            WHERE CURRENT OF empl_curs;
            
            RAISE NOTICE 'Сотруднику % (отдел 4) подняли зп. Новая зп: %', v_empl.name, (v_empl.salary + 2000);
        END IF;
    END LOOP;
    CLOSE empl_curs;
END;
$$;

-- ====================================================================
15. Write a program in PL/SQL to FETCH single record and single column from a table.
-- ====================================================================
DO $$
DECLARE 
    v_name TEXT;
BEGIN 
    SELECT name INTO v_name FROM employees WHERE id = 1;
    RAISE NOTICE 'Сотрудника с id = 1 зовут %', v_name;
END;
$$;

-- ====================================================================
16. Write a program in PL/SQL to FETCH more than one record and single column from a table.
-- ====================================================================
DO $$
DECLARE 
    v_count INTEGER := 0;
    v_name TEXT;
BEGIN 
    FOR v_name IN 
        SELECT name FROM employees
    LOOP
        v_count := v_count + 1;
        RAISE NOTICE 'Сотрудник № % %', v_count, v_name;
    END LOOP;
END;
$$;

-- ====================================================================
17. Write a program in PL/SQL to FETCH multiple records and more than one columns from the same table.
-- ====================================================================
DO $$
DECLARE 
    v_empl RECORD;
BEGIN 
    FOR v_empl IN 
        SELECT id, name, salary, department_id 
        FROM employees
    LOOP 
        RAISE NOTICE 'Сотрудник % из департамента % получает зп %', v_empl.name, v_empl.department_id, v_empl.salary;
    END LOOP; 
END;
$$;

-- ====================================================================
18. Write a program in PL/SQL to FETCH multiple records and more than one columns from different tables.
-- ====================================================================
DO $$
DECLARE 
    v_dep RECORD;
BEGIN 
    FOR v_dep IN 
        SELECT 
            e.name AS emp_name,
            d.name AS dep_name,
            e.salary AS emp_salary,
            d.head AS dep_head
        FROM department d
        JOIN employees e ON d.id = e.department_id
    LOOP 
        RAISE NOTICE 'Сотрудник % работает в департаменте % под руководством % и получает зп %', 
            v_dep.emp_name, v_dep.dep_name, v_dep.dep_head, v_dep.emp_salary;
    END LOOP;
END;
$$;
