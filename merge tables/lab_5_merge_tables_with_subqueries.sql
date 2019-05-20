--1. Получить упорядоченный по возрастанию список идентификаторов поставщиков, поставляющих товары для горной линейки велосипедов

SELECT AccountNumber
FROM Purchasing.Vendor
WHERE VendorID = ANY 
	(SELECT VendorID
	FROM Purchasing.ProductVendor vendor
	JOIN Production.Product product
	ON product.ProductID = vendor.ProductID
	WHERE ProductLine = 'M')

--2. Получить упорядоченный по возрастанию список названий товаров, поставляемых поставщиком с ID 

SELECT Name
FROM Production.Product
WHERE ProductID <> ANY
	(SELECT ProductID
	FROM Purchasing.ProductVendor)

--3. Для каждого типа кредитного рейтинга посчитать количество поставщиков, которые находятся в городе ‘New York’

SELECT COUNT(*) 'Count', CreditRating
FROM Purchasing.Vendor
WHERE VendorID IN
	(SELECT v.VendorID
	FROM Purchasing.Vendor v
	JOIN Purchasing.VendorAddress vaddress
	ON v.VendorID = vaddress.VendorID
	JOIN Person.Address address
	ON vaddress.AddressID = address.AddressID
	WHERE address.City = 'New York')
GROUP BY CreditRating

--4. Получить идентификационные номера товаров и рекламных акций для заказов, сделанных 27 июля 2004 года

SELECT ProductID, SpecialOfferID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID IN
	(SELECT detail.SalesOrderID
	FROM Sales.SalesOrderDetail detail
	JOIN Sales.SalesOrderHeader header
	ON detail.SalesOrderID = header.SalesOrderID
	WHERE header.OrderDate = '27-07-2004')


--5. Получить список идентификационных номеров сотрудников, чье количество дней отпуска по болезни меньше, 
--чем среднее количество дней отпуска по болезни по занимаемой ими должности

SELECT EmployeeID, SickLeaveHours, Title
FROM HumanResources.Employee
WHERE SickLeaveHours < ANY
	(SELECT AVG(first.SickLeaveHours)
	FROM HumanResources.Employee first
	JOIN HumanResources.Employee second
	ON first.Title = second.Title) 

--6. Вычислить количество продуктов, для которых количества единиц товара в заказе 
--больше среднего количества единиц товара в заказе для рекламной акции с ID = 1

SELECT COUNT(*) 'Count'
FROM Sales.SalesOrderDetail
WHERE OrderQty > 
	(SELECT AVG(OrderQty)
	FROM Sales.SalesOrderDetail
	WHERE SpecialOfferID = 1) 

--7. Получить список городов, в которых есть хотя бы один поставщик с кредитным рейтингом 5

SELECT City
FROM Person.Address
WHERE AddressID = ANY
	(SELECT Person.Address.AddressID
	FROM Person.Address
	JOIN Purchasing.VendorAddress
	ON Person.Address.AddressID = Purchasing.VendorAddress.AddressID
	JOIN Purchasing.Vendor
	ON Purchasing.VendorAddress.VendorID = Purchasing.Vendor.VendorID
	WHERE CreditRating = 5)

--8. Получить список городов, в которых есть только один поставщик 

SELECT City
FROM Person.Address
WHERE City = ALL
	(SELECT Person.Address.City
	FROM Person.Address
	JOIN Purchasing.VendorAddress first
	ON Person.Address.AddressID = first.AddressID
	WHERE first.VendorID = ALL
		(SELECT second.VendorID
		FROM Purchasing.VendorAddress second)
	)
GROUP BY City

--9. Получить данные (идентификационный номер) о поставщиках, поставляющих больше одного продукта для дорожной линейки велосипедов

SELECT City
FROM Person.Address
WHERE City = ANY
	(SELECT Person.Address.City
	FROM Person.Address
	JOIN Purchasing.VendorAddress first
	ON Person.Address.AddressID = first.AddressID
	WHERE first.VendorID = ANY
		(SELECT second.VendorID
		FROM Purchasing.VendorAddress second)
	)
GROUP BY City

--10. Получить список идентификационных номеров покупателей,
--для которых город в адресе выставления счета не соответствует городу в адресе доставки товара (без использования IN)

SELECT CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID = ANY
	(SELECT CustomerID
	FROM Sales.SalesOrderHeader person
	JOIN Person.Address first
	ON first.AddressID = person.BillToAddressID
	JOIN Person.Address second
	ON second.AddressID = person.ShipToAddressID
	WHERE  first.AddressID <> second.AddressID)

--11. Получить данные (идентификационный номер) о заказчиках, 
--для которых средняя стоимость заказа выше стоимости заказа от 27.07.2004

SELECT customer.CustomerID
FROM Sales.SalesOrderHeader customer
JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderDetail.SalesOrderID = customer.SalesOrderID
WHERE LineTotal > ANY
	(SELECT LineTotal
	FROM Sales.SalesOrderHeader
	JOIN Sales.SalesOrderDetail
	ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
	WHERE customer.CustomerID = Sales.SalesOrderHeader.CustomerID AND OrderDate = '27-07-2004')

--12. Найти тех производителей (идентификационный номер) товаров горной линейки, которые не производят товары дорожной линейки

SELECT VendorID
FROM Purchasing.ProductVendor
JOIN Production.Product product
ON Purchasing.ProductVendor.ProductID = product.ProductID
WHERE product.ProductLine = 'M' AND NOT EXISTS 
	(SELECT *
	FROM Production.Product
	WHERE product.ProductID = Production.Product.ProductID AND Production.Product.ProductLine = 'R')

--13. Получить информацию о количестве заказов на суммы больше 150000 для каждого заказчика (идентификационный номер)

SELECT COUNT(*) 'Count', Sales.Customer.CustomerID
FROM Sales.Customer
WHERE CustomerID = ANY 
	(SELECT Sales.Customer.CustomerID
	FROM Sales.Customer
	JOIN Sales.SalesOrderHeader
	ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
	WHERE SubTotal > 150000)
GROUP BY CustomerID
