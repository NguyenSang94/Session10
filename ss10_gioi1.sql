CREATE TABLE IF NOT EXISTS employees_log
(
    log_id      SERIAL PRIMARY KEY,
    employee_id INT,
    operation   VARCHAR(10) NOT NULL,
    old_data    JSONB,
    new_data    JSONB,
    change_time TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Bảng nhân viên mẫu
CREATE TABLE IF NOT EXISTS employees
(
    id       SERIAL PRIMARY KEY,
    name     TEXT NOT NULL,
    position TEXT,
    salary   NUMERIC(12, 2)
);

--tạo function
create or replace function nv_employee_changes()
    returns trigger
    language plpgsql
as
$$
begin
    if tg_op = 'insert' then
        insert into employees_log(employee_id, operation, old_data, new_data, change_time)
        values (new.id, 'insert', null, to_jsonb(new), now());
        return new;

    elsif tg_op = 'update' then
        insert into employees_log (employee_id, operation, old_data, new_data, change_time)
        values (new.id, 'update', to_jsonb(new), now());
        return new;

    elsif tg_op = 'delete' then
        insert into employees_log(employee_id, operation, old_data, new_data, change_time)
        values (old.id, 'delete', to_jsonb(old), now());
        return old;
    else
        return null;
    end if;
end;
$$;
-- tạo trigger
create or replace trigger nv_employee_audit
    after insert or update or delete
    on employees_log
    for each row
execute function nv_employee_changes();

-- chèn dữ liệu
insert into employees(name, position, salary)
values ('Nguyễn Văn A', 'Developer', 15000000),
       ('Trần Thị B', 'Tester', 12000000);

update employees set salary = 1600000 where name = 'Nguyễn Văn A';
delete from employees where id = 2;
select * from employees;
