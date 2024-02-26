-- Заказчики
create table Customers
(
   row_id int identity not null,
   name nvarchar(max) not null,           -- наименование заказчика

   constraint PK_Customers
      primary key nonclustered(row_id)
);
go

-- Заказы
create table Orders
(
   row_id int identity not null,
   parent_id int,                         -- row_id родительской группы
   group_name nvarchar(max),              -- наименование группы заказов
   customer_id int,                       -- row_id заказчика
   registered_at date                     -- дата регистрации заказа

   constraint PK_Orders
      primary key nonclustered (row_id),
   constraint FK_Orders_Folder 
      foreign key (parent_id) 
      references Orders(row_id)
      on delete no action
      on update no action,
   constraint FK_Customers
      foreign key (customer_id)
      references Customers(row_id)
      on delete cascade
      on update cascade
);
go

-- Позиции заказов
create table OrderItems
(
   row_id int identity not null,
   order_id int not null,                 -- row_id заказа
   name nvarchar(max) not null,           -- наименование позиции
   price int not null,                    -- стоимость позиции в рублях

   constraint PK_OrderItems
      primary key nonclustered (row_id),
   constraint FK_OrderItems_Orders
      foreign key (order_id) 
      references Orders(row_id)
      on delete cascade
      on update cascade
);
go

insert into Customers                                                               -- 1
values(N'Иванов');
insert into Customers                                                               -- 2
values(N'Петров');
insert into Customers                                                               -- 3
values(N'Сидоров');
insert into Customers                                                               -- 4
values(N'ИП Федоров');


insert into Orders(parent_id, group_name, customer_id, registered_at)               -- 1
values (null, N'Все заказы', null, null);

   insert into Orders(parent_id, group_name, customer_id, registered_at)            -- 2
   values (1, N'Частные лица', null, null);

      insert into Orders(parent_id, group_name, customer_id, registered_at)         -- 3
      values (2, N'Оргтехника', null, null);

         insert into Orders(parent_id, group_name, customer_id, registered_at)      -- 4
         values (3, null, 1, '2019/10/02');

         insert into Orders(parent_id, group_name, customer_id, registered_at)      -- 5
         values (3, null, 1, '2020/05/17');

       insert into Orders(parent_id, group_name, customer_id, registered_at)        -- 6
         values (3, null, 1, '2020/04/28');

       insert into Orders(parent_id, group_name, customer_id, registered_at)        -- 7
         values (3, null, 2, '2019/08/05');

       insert into Orders(parent_id, group_name, customer_id, registered_at)        -- 8
         values (3, null, 2, '2020/05/17');

       insert into Orders(parent_id, group_name, customer_id, registered_at)        -- 9
         values (3, null, 2, '2020/02/11');

      insert into Orders(parent_id, group_name, customer_id, registered_at)         -- 10
      values (2, N'Канцелярия', null, null);

         insert into Orders(parent_id, group_name, customer_id, registered_at)      -- 11
         values (10, null, 3, '2020/04/09');

   insert into Orders(parent_id, group_name, customer_id, registered_at)            -- 12
   values (1, N'Юридические лица', null, null);

      insert into Orders(parent_id, group_name, customer_id, registered_at)         -- 13
      values (12, null, 4, '2020/06/25');


insert into OrderItems(order_id, name, price)
values (4, N'Принтер', 30);
insert into OrderItems(order_id, name, price)
values (4, N'Факс', 20);


insert into OrderItems(order_id, name, price)
values (5, N'Принтер', 50);
insert into OrderItems(order_id, name, price)
values (5, N'Кассовый аппарат', 40);
insert into OrderItems(order_id, name, price)
values (5, N'Факс', 30);


insert into OrderItems(order_id, name, price)
values (6, N'Кассовый аппарат', 30);
insert into OrderItems(order_id, name, price)
values (6, N'Кассовый аппарат', 40);


insert into OrderItems(order_id, name, price)
values (7, N'Копировальный аппарат', 50);
insert into OrderItems(order_id, name, price)
values (7, N'Калькулятор', 10);
insert into OrderItems(order_id, name, price)
values (7, N'Кассовый аппарат', 60);


insert into OrderItems(order_id, name, price)
values (8, N'Принтер', 50);
insert into OrderItems(order_id, name, price)
values (8, N'Калькулятор', 10);


insert into OrderItems(order_id, name, price)
values (9, N'Телефонный аппарат', 50);
insert into OrderItems(order_id, name, price)
values (9, N'Кассовый аппарат', 40);


insert into OrderItems(order_id, name, price)
values (11, N'Бумага', 2);
insert into OrderItems(order_id, name, price)
values (11, N'Ручки', 1);


insert into OrderItems(order_id, name, price)
values (13, N'Кулер', 100);
insert into OrderItems(order_id, name, price)
values (13, N'Стулья', 70);
insert into OrderItems(order_id, name, price)
values (13, N'Факс', 20);
go

CREATE FUNCTION ordersByItemName(@name NVARCHAR(max))
RETURNS TABLE
AS
RETURN
(
    SELECT order_id, Customers.name, COUNT(*) AS items_count
	FROM OrderItems
	JOIN Orders ON order_id = Orders.row_id
	JOIN Customers ON Orders.customer_id = Customers.row_id
	WHERE OrderItems.name = @name
	GROUP BY order_id, Customers.name
);
go

DROP FUNCTION IF EXISTS ordersByItemName;
go

SELECT * FROM ordersByItemName('Кассовый аппарат');
go

SELECT Customers.name 
FROM Customers
JOIN Orders ON Orders.customer_id = Customers.row_id
JOIN OrderItems ON Orders.row_id = OrderItems.order_id
WHERE YEAR(Orders.registered_at) = 2020 AND OrderItems.name = 'Кассовый аппарат';