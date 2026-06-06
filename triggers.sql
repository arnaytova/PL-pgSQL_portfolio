-- Таблица для задачи 1 
CREATE TABLE number1
    (id SERIAL PRIMARY KEY,
    name TEXT,
    last_modified TIMESTAMP);

-- Таблица для задач 2, 4, 5, 6, 7 
CREATE TABLE department
    (id SERIAL PRIMARY KEY,
    name TEXT,
    budget NUMERIC,
    head TEXT);

CREATE TABLE employees
    (id SERIAL PRIMARY KEY,
    name TEXT,
    salary NUMERIC,
    address TEXT,
    last_modified TIMESTAMP,
    department_id INTEGER REFERENCES department(id));

-- Таблица для задачи 3 и 8 
CREATE TABLE users
    (id SERIAL PRIMARY KEY,
    people TEXT,
    age NUMERIC,
    address TEXT);

CREATE TABLE users_log
    (id SERIAL PRIMARY KEY,
    name TEXT,
    time TIMESTAMP,
    old_val TEXT,
    new_val TEXT);

-- Таблица для задачи 9 (Подсчет running total)
CREATE TABLE products
    (id SERIAL PRIMARY KEY,
    name TEXT,
    price NUMERIC,
    address TEXT,
    total NUMERIC);

-- Наполнение таблиц тестовыми данными
INSERT INTO number1 (name) VALUES ('Маша'), ('Петя'), ('Дима'), ('Андрей'), ('Аня'), ('Людмила');
INSERT INTO department (name, budget, head) VALUES ('sales', 10000, 'Dima'), ('data', 15000, 'Andy');
INSERT INTO employees (name, salary, address, department_id) VALUES ('Маша', 5000, 'Belgrade', 1), ('Дима', 15000, 'Moscow', 2), ('Андрей', 55000, 'NY', 2);
INSERT INTO users (people, age, address) VALUES ('Дима', 15, 'Москва'), ('Андрей', 3, 'Белград'), ('Лимон', 38, 'Венгрия'), ('Апельсин', 30, 'Тайланд');
INSERT INTO products (name, price, address) VALUES ('машина', 100, 'Москва'), ('трактор', 400, 'Питер'), ('автобус', 300, 'Ростов'), ('вездеход', 50, 'Волгоград');


-- ====================================================================
1. Write a code in PL/SQL to create a trigger that automatically updates a 'last_modified' timestamp whenever a row in a specific table is updated.
-- ====================================================================
CREATE OR REPLACE FUNCTION update_last_modified_column()
RETURNS TRIGGER 
LANGUAGE plpgsql 
AS $$
BEGIN
    NEW.last_modified = NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_number1_timestamp
BEFORE UPDATE OR INSERT ON number1
FOR EACH ROW
EXECUTE FUNCTION update_last_modified_column();

-- ====================================================================
2. Write a code in PL/SQL to create a trigger that prevents updates on a certain column during specific hours of the day.
-- ====================================================================
CREATE OR REPLACE FUNCTION prevent_salary_update_by_time()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.salary IS DISTINCT FROM NEW.salary THEN
        IF CURRENT_TIME >= '09:00:00'::TIME AND CURRENT_TIME <= '18:00:00'::TIME THEN
            RAISE EXCEPTION 'Обновление зарплаты запрещено в рабочее время с 9:00 до 18:00';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_employees_salary_time
BEFORE UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION prevent_salary_update_by_time();

-- ====================================================================
3. Write a code in PL/SQL to create a trigger that logs changes to a sensitive column into an audit table.
-- ====================================================================
CREATE OR REPLACE FUNCTION log_user_address_changes()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO users_log (name, time, old_val, new_val) 
    VALUES (NEW.people, NOW(), OLD.address, NEW.address);
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_users_address_audit
AFTER UPDATE ON users
FOR EACH ROW
WHEN (OLD.address IS DISTINCT FROM NEW.address)
EXECUTE FUNCTION log_user_address_changes();

-- ====================================================================
4. Write a code in PL/SQL to implement a trigger that enforces a maximum limit on a numeric column (e.g., maximum salary).
-- ====================================================================
CREATE OR REPLACE FUNCTION enforce_max_salary_limit()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary > 80000 THEN 
        RAISE EXCEPTION 'Зарплата % превышает максимально допустимый лимит в 80 000', NEW.salary;
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_employees_max_salary
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION enforce_max_salary_limit();

-- ====================================================================
5. Write a code in PL/SQL to create a trigger that validates data formats (e.g., email or phone numbers) before inserting a row.
-- ====================================================================
CREATE OR REPLACE FUNCTION validate_employee_salary_positive()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary <= 0 THEN 
        RAISE EXCEPTION 'Зарплата должна быть больше нуля';
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_employees_salary_validation
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION validate_employee_salary_positive();

-- ====================================================================
6. Write a code in PL/SQL to create a trigger that prevents a row from being deleted if certain conditions are met.
-- ====================================================================
CREATE OR REPLACE FUNCTION prevent_high_salary_deletion()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.salary > 50000 THEN 
        RAISE EXCEPTION 'Запрещено удалять сотрудников с зарплатой выше 50 000';
    END IF;
    RETURN OLD;
END;
$$;

CREATE OR REPLACE TRIGGER trg_employees_prevent_delete
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION prevent_high_salary_deletion();

-- ====================================================================
7. Write a code in PL/SQL to implement a trigger that cascades updates from one table to another (e.g., custom cascading logic).
-- ====================================================================
CREATE OR REPLACE FUNCTION cascade_department_budget_update()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees 
    SET salary = salary * 1.10 
    WHERE department_id = NEW.id;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_department_cascade_budget
AFTER UPDATE ON department
FOR EACH ROW
WHEN (OLD.budget IS DISTINCT FROM NEW.budget)
EXECUTE FUNCTION cascade_department_budget_update();

-- ====================================================================
8. Write a code in PL/SQL to create a trigger that automatically archives old rows when they are updated.
-- ====================================================================
CREATE OR REPLACE FUNCTION archive_old_user_data()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO users_log (name, time, old_val, new_val) 
    VALUES (OLD.people, NOW(), OLD.address, 'ARCHIVED');
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_users_archive
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION archive_old_user_data();

-- ====================================================================
9. Write a code in PL/SQL to implement a trigger that automatically calculates and updates a running total column for a table whenever new rows are inserted.
-- ====================================================================
CREATE OR REPLACE FUNCTION calculate_running_total()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(price), 0) 
    INTO v_current_total 
    FROM products;

    NEW.total = v_current_total + NEW.price;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_products_running_total
BEFORE INSERT ON products
FOR EACH ROW
EXECUTE FUNCTION calculate_running_total();

-- ====================================================================
10. Write a code in PL/SQL to implement a conditional trigger that executes only when a specific column changes.
-- ====================================================================
CREATE OR REPLACE FUNCTION notify_salary_change()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Внимание! Зарплата сотрудника % изменилась с % на %', 
        NEW.name, OLD.salary, NEW.salary;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_employees_salary_conditional
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION notify_salary_change();
