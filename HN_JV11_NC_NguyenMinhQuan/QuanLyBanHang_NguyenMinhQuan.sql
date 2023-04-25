create database QuanLyBanHang_test;
use QuanLyBanHang_test;
drop database QuanLyBanHang_test;
-- Tạo các bảng
create table customer(
cid smallint primary key,
cname varchar(50),
cage smallint
);
create table orders(
oId smallint primary key,
cId smallint,
oDate datetime,
ototalPrice float
);
create table product(
pId int primary key,
pName varchar(50),
pPrice float
);
create table orderDetail(
oId smallint,
pId int,
odQTY int
);
-- thêm khóa ngoại
alter table orders add foreign key (cId) references customer(cid);
alter table orderDetail add foreign key (oId) references orders(oId);
alter table orderDetail add foreign key (pId) references product(pid);
-- chèn dữ liệu cho các bảng
insert into customer values
(1,"Minh Quan",10),
(2,"Ngoc Oanh",20),
(3,"Hong Ha",50);
insert into orders values
(1,1,"2006-3-21",null),
(2,2,"2006-3-23",null),
(3,1,"2006-3-16",null);
insert into product values
(1,"may giat",3),
(2,"tu lanh",5),
(3,"dieu hoa",7),
(4,"quat",1),
(5,"bep dien",2);
insert into orderDetail values
(1,1,3),
(1,3,7),
(1,4,2),
(2,1,1),
(3,1,8),
(2,5,4),
(2,3,3);
-- . Hiển thị các thông tin gồm oID, oDate, oPrice của tất cả các hóa đơn
-- trong bảng Order, danh sách phải sắp xếp theo thứ tự ngày tháng, hóa
-- đơn mới hơn nằm trên
select * from orders order by odate desc;
-- 3. Hiển thị tên và giá của các sản phẩm có giá cao nhất như sau:
select pname,pprice from product where pprice = (select max(pprice) from product);
-- 4. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản
-- phẩm được mua bởi các khách đó
select customer.cname,product.pname from
customer join orders on customer.cid = orders.cId
join orderDetail on orders.oId = orderDetail.oId
join product on product.pid = orderDetail.pId;
-- 5. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
select customer.cname from customer where cid not in
(select customer.cid from
customer join orders on customer.cid = orders.cId);
-- 6. Hiển thị chi tiết của từng hóa đơn
select orders.oId, odate, orderdetail.odqty,product.pname,pprice from
orders join orderDetail on orders.oId = orderdetail.oId
join product on product.pid = orderDetail.pId;
-- 7. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
select orders.oId, odate, sum(pprice * odqty) as total from
orders join orderDetail on orders.oId = orderdetail.oId
join product on product.pid = orderDetail.pId
group by orders.oId;
-- 8. Tạo một view tên là Sales để hiển thị tổng doanh thu của siêu thị
create view tong_doanh_thu as select sum(pprice * odqty) as Sales from 
orders join orderDetail on orders.oId = orderdetail.oId
join product on product.pid = orderDetail.pId;
select * from tong_doanh_thu;
-- 9. Xóa tất cả các ràng buộc khóa ngoại, khóa chính của tất cả các bảng
alter table orders drop constraint orders_ibfk_1;
alter table orderdetail drop constraint orderdetail_ibfk_1;
alter table orderdetail drop constraint orderdetail_ibfk_1;
alter table customer drop primary key;
alter table product drop primary key;
alter table orders drop primary key;
-- 10.Tạo một trigger tên là cusUpdate trên bảng Customer, sao cho khi sửa
-- mã khách (cID) thì mã khách trong bảng Order cũng được sửa theo:
delimiter //
create trigger cusUpdate
after update on customer
for each row
begin
 update orders set cId = new.cId where cId = old.cId;
end//
delimiter ;
-- 11.Tạo một stored procedure tên là delProduct nhận vào 1 tham số là tên của 
-- một sản phẩm, strored procedure này sẽ xóa sản phẩm có tên được truyên 
-- vào thông qua tham số, và các thông tin liên quan đến sản phẩm đó ở trong 
-- bảng OrderDetail
alter table product add primary key (pId);
alter table orderdetail add foreign key (pId) references product(pId);
delimiter //
create procedure delProduct(
in newPName varchar(50)
)
begin
delete from product where pName = newPName;
delete from orderDetail where pId = (select pId from product where pName = newPName);
end
//delimiter ;
drop procedure delProduct;
call delProduct("tu lanh");