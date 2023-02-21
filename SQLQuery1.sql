--1. Truy van thong tin khach hang phan nan
select customerNumber, customerName, addressLine1, addressLine2, country
	from customers
	where phone ='+49 69 66 90 2555'

--2. Truy van thong tin don hang
select *
	from orders
	where customerNumber = 128
	and orderDate = '2003-01-09'

--3. Truy van nhan vien da cham soc khach hang cua don hang nay
select *
	from employees
	where employeeNumber in (
		select salesRepEmployeeNumber
		from customers
		where customerNumber = 128)

--4. Truy van thong tin san pham bi phan nan.
select *
	from products
	where productName like '%1928 Mercedes-Benz%'

--5. Kiem tra kho hang con san pham do khong.
 select quantityInStock
	from products
	where productCode = 'S18_2795'

--6. Tra ra nhung dong san pham co cung muc gia, chenh lech gia nho de tu van. (Nho hon 5 do)
select *
	from products
	where abs(buyPrice - (select buyprice from products where productCode = 'S18_2795')) <5
	and productCode != 'S18_2795'

--7. Tra ra nhung dong xe co cung mot so dac diem voi xe truoc.
select *
	from products
	where productLine = (select productLine from products where productCode = 'S18_2795')
	and productScale = (select productScale from products where productCode = 'S18_2795')
	and productCode != 'S18_2795'

--8. Truy van san pham moi ma khach hang yeu cau theo dac diem
select *
	from products
	where productDescription like '%white%' or productDescription like '%black%'
	and productDescription like '%opening hood%'

--9. Tim 1 nhan vien da co kinh nghiem de tu van cho khach hang.
select salesRepEmployeeNumber, count(salesRepEmployeeNumber) as RepCount
from customers
group by salesRepEmployeeNumber
order by RepCount desc

--10. Hien thi nhung khach hang da mua san pham nay de tien hanh khao sat chat luong. 
select customers.customerNumber, customerName, phone, addressLine1, country, orderdetails.productCode
from customers, orders, orderdetails
where customers.customerNumber = orders.customerNumber
and orders.orderNumber = orderdetails.orderNumber
and orderdetails.productCode = 'S18_2795'

--11. Hien thi top 5 khach hang co tong gia tri don hang lon nhat.
select top 5 customers.customerNumber, customerName, phone, addressLine1, country, SUM(quantityOrdered*priceEach) as total
from customers, orders, orderdetails
where customers.customerNumber = orders.customerNumber
and orders.orderNumber = orderdetails.orderNumber
group by customers.customerNumber, customerName, phone, addressLine1, country
order by total desc

--12. Hien thi top 5 san pham có ty le doanh so cao nhat
with total as (
	select SUM(priceEach*quantityOrdered) as total
	from orderdetails)
select top 5 productCode, round((priceEach*quantityOrdered)/total*100, 4) as tyleDT
from orderdetails,total
order by tyleDT desc

--13. Kiem tra giao van da dung thoi gian yeu cau chua, hien thi don hang giao tre.
select *
from orders
where datediff(day, requiredDate, shippedDate)>0

--14. Tra cac san pham khong co mat trong bat ki mot don hang nao.
select productCode
from products
where productCode not in (
	select productCode
	from orderdetails)

--15. Tra ra các san pham có so luong trong kho lon hon trung bình so luong trong kho cua các san pham cung loai.
with avg_stock as (
	select AVG(quantityInStock) as avg_stock
	from products
	group by productLine)
select productCode, productLine, quantityInStock
from products, avg_stock
where quantityInStock > avg_stock
group by productCode, productLine, quantityInStock


--16. Thong ke tong so luong san pham trong kho theo tung dong san pham của tung nha cung ung
select productVendor, productLine, sum(quantityInStock) as quantity
from products
group by productVendor, productLine
with rollup 

--17. Thong ke ra moi san pham duoc dat hang lan cuoi vao thoi gian nao va khach hang da dat hang
select customerNumber,
	   productCode, 
	   max(orderDate) over (partition by productCode) as Last_Order_Date
from orders, orderdetails
where orders.orderNumber = orderdetails.orderNumber