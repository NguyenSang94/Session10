create table library.products(
                                 id serial primary key ,
                                 name varchar(50) not null ,
                                 stock int not null check ( stock >= 0 )
);



create table library.orders(
                               id serial primary key ,
                               product_id int not null references library.products(id),
                               quantity int not null check (quantity > 0 ),
                               order_status varchar(20) not null
);

insert into library.products(name, stock)
values ('Iphone 16',50),
       ('oppo 15',40),
       ('SamSung Galaxy 15',30);

create or replace function check_insert_order()
    returns trigger language plpgsql as $$

declare product_stock int ;
begin
    select stock into product_stock from library.products where id = new.product_id ;
    if product_stock - new.quantity < 0 then
        raise exception 'So luong hang ton kho khong du ';
    else

        update library.products
        set stock = products.stock - new.quantity
        where products.id = new.product_id;
        return new ;
    end if;
end;

$$;


create or replace function check_update_order()
    returns trigger language plpgsql as $$

declare product_stock int ;
begin
    select stock into product_stock from library.products where id = new.product_id ;
    if product_stock - (new.quantity - old.quantity) < 0 then
        raise exception 'So luong hang ton kho khong du ';
    else
        update library.products
        set stock = products.stock - (new.quantity - old.quantity)
        where products.id = new.product_id;
        return new ;
    end if;
end;

$$;


create or replace function check_delete_order()
    returns trigger language plpgsql as $$

begin

    update library.products
    set stock = products.stock + old.quantity
    where products.id = old.product_id;

    return old;
end;

$$;

create or replace trigger trg_insert_order
    BEFORE insert on library.orders
    FOR each row
execute function check_insert_order();

create or replace trigger trg_update_order
    BEFORE update on library.orders
    FOR each row
execute function check_update_order();

create or replace trigger trg_delete_order
    BEFORE delete on library.orders
    FOR each row
execute function check_delete_order();

insert into library.orders(product_id, quantity, order_status)
values (1,40,'pending');
select *from library.products;
select * from library.orders ;

update library.orders
set quantity = 30 where id = 4 ;

delete from library.orders
where id = 3 ;