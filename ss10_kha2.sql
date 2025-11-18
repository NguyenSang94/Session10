create table customers(
                          id serial primary key,
                          name varchar(100) not null,
                          credit_limit numeric(12,2) not null
);

create table orders(
                       id serial primary key,
                       customer_id int not null references customers(id),
                       order_amount numeric(12,2) not null
);

create or replace function check_credit_limit()
    returns trigger
    language plpgsql
as $$
declare
    current_limit numeric(12,2);
    total_orders numeric(12,2);
begin
    select credit_limit into current_limit
    from customers
    where id = new.customer_id;

    select coalesce(sum(order_amount), 0) into total_orders
    from orders
    where customer_id = new.customer_id;

    if total_orders + new.order_amount > current_limit then
        raise exception 'Vuot qua han muc tin dung!';
    end if;

    return new;
end;
$$;

create or replace trigger trg_check_credit
    before insert on orders
    for each row
execute function check_credit_limit();

insert into customers(name, credit_limit)
values
    ('Nguyen Van A', 50000),
    ('Tran Thi B', 20000),
    ('Le Van C', 10000);

insert into orders(customer_id, order_amount)
values (1, 15000);

insert into orders(customer_id, order_amount)
values (1, 20000);

insert into orders(customer_id, order_amount)
values (3, 9000);

-- THỬ CASE VƯỢT HẠN MỨC
-- insert bị chặn:
insert into orders(customer_id, order_amount)
values (1, 30000);

insert into orders(customer_id, order_amount)
values (3, 3000);

select * from orders;
