CREATE TABLE products
(
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100),
    stock INT
);
CREATE TABLE orders
(
    id         SERIAL PRIMARY KEY,
    product_id INT REFERENCES products (id),
    quantity   INT
);

-- tạo function
create or replace function check_insert_order()
    returns trigger
    language plpgsql
as
$$
declare
    check_token int;
begin
    select stock
    into check_token
    from products
    where id = new.product_id;
    if check_token - new.quantity < 0 then
        raise exception 'So lương hang tôn kho khong du';
    else
        update products
        set stock = stock - new.quantity
        where id = new.product_id;
        return new;
    end if;
end;
$$;
--update
create or replace function check_update_order()
returns trigger
language plpgsql
as $$
    declare current int;
    begin
        select stock into current
        from products
        where id = old.product_id;

        update products
        set stock = stock + old.quantity
        where id = old.quanity;

        select stock into  current
        from products
        where id = new.product_id;

        if current - new.quantity < 0 then
            raise exception 'số lượng tồn kho không đủ';
            else
            update products
            set stock = stock - new.quantity
            where id = new.product_id;
        end if;
        return new;
    end;
    $$;
create or replace function check_delete_order()
returns trigger
language plpgsql
as $$
    begin
    update products
        set stock = stock + old.quantity
        where id = old.quantity;
    return old;
    end;
    $$;
-- tạo trigger
create trigger trg_insert_stock_order
before insert  on orders
    for each row
    execute function  check_insert_order();

create trigger trg_update_stock_order
    before update  on orders
    for each row
execute function  check_update_order();

create trigger trg_delete_stock_order
    before delete  on orders
    for each row
execute function  check_delete_order();

INSERT INTO products(name, stock)
VALUES ('Iphone 15', 100),
       ('Laptop Dell', 50);

-- Bán 10 iPhone
INSERT INTO orders(product_id, quantity)
VALUES (1, 10);
SELECT * FROM products;

-- Đổi từ 10 → 15
UPDATE orders
SET quantity = 15
WHERE id = 1;

