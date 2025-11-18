CREATE TABLE products
(
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(255)   NOT NULL,
    price         NUMERIC(10, 2) NOT NULL,
    last_modified TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);
INSERT INTO products (name, price)
VALUES ('Laptop Dell XPS', 25000000.00),
       ('Monitor LG 27 inch', 5500000.00),
       ('Bàn phím cơ Filco', 3800000.00);
--1. tạo function
create or replace function update_last_modified()
    returns trigger
    language plpgsql
as
$$
begin
    new.last_modified := now();
    return new;
end;
$$;
--2. tringger
create or replace trigger trg_update_last_modified
    before update on products
    for each row
    execute function update_last_modified();
update products
set price = 490000
where id = 1;
select * from products;




