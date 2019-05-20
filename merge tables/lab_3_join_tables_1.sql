--1. Вывести фамилии, имена, должности и номера телефонов работников, 
--для которых есть сведения о номере телефона.

SELECT FirstName, LastName, HumanResources.Employee.Title, Phone 
FROM Person.Contact, HumanResources.Employee 
WHERE Person.Contact.ContactID = HumanResources.Employee.ContactID AND Phone <> 'NULL'

--2. Посчитать количество работников, для которых есть сведения об адресе электронной почты

SELECT COUNT(HumanResources.Employee.ContactID)
FROM Person.Contact
INNER JOIN HumanResources.Employee 
ON Person.Contact.ContactID = HumanResources.Employee.ContactID
WHERE EmailAddress <> 'NULL'

--3.  Вывести список контактных лиц поставщиков запчастей и других товаров (Фамилия, Имя, Адрес электронной почты), 
--отсортированный по названиям компаний-поставщиков.

SELECT Name, FirstName, LastName, EmailAddress
FROM Person.Contact
INNER JOIN Purchasing.VendorContact
ON Person.Contact.ContactID = Purchasing.VendorContact.ContactID 
INNER JOIN Purchasing.Vendor
ON Purchasing.VendorContact.VendorID = Purchasing.Vendor.VendorID 
ORDER BY Name

--4. Составить запрос, выводящий имена, фамилии и должности тех работников компании, 
--которые также являются представителями компаний-поставщиков деталей и других товаров.

SELECT FirstName, LastName, HumanResources.Employee.Title
FROM HumanResources.Employee
INNER JOIN Person.Contact
ON Person.Contact.ContactID = HumanResources.Employee.ContactID
AND HumanResources.Employee.Title LIKE '%Representative%'

--5. Получить отсортированный по алфавиту список (фамилия, имя, телефон) представителей поставщиков деталей и других товаров, 
--использующихся в горной линейке велосипедов. 

SELECT FirstName, LastName, Phone
FROM Person.Contact
INNER JOIN Purchasing.VendorContact
ON Person.Contact.ContactID = Purchasing.VendorContact.ContactID 
INNER JOIN Purchasing.Vendor
ON Purchasing.VendorContact.VendorID = Purchasing.Vendor.VendorID 
INNER JOIN Purchasing.ProductVendor
ON Purchasing.Vendor.VendorID = Purchasing.ProductVendor.VendorID
INNER JOIN Production.Product
ON Purchasing.ProductVendor.ProductID = Production.Product.ProductID  
AND ProductLine = 'M'
ORDER BY FirstName, LastName

--6. Получить список названий товаров туристической линейки. 
--Для тех из них, которые закупаются у сторонних поставщиков, указать названия компаний-поставщиков.

SELECT Production.Product.Name, Purchasing.Vendor.Name
FROM Production.Product
LEFT OUTER JOIN Purchasing.ProductVendor
ON Purchasing.ProductVendor.ProductID = Production.Product.ProductID
LEFT OUTER JOIN Purchasing.Vendor
ON Purchasing.Vendor.VendorID = Purchasing.ProductVendor.VendorID 
WHERE ProductLine = 'T'

--7. Определить среднюю стандартную стоимость для классов продукции, закупаемой у сторонних поставщиков. 
--Не учитывать товары, для которых класс не указан.

SELECT AVG(StandardCost)
FROM Production.Product
INNER JOIN Purchasing.ProductVendor
ON Purchasing.ProductVendor.ProductID = Production.Product.ProductID
INNER JOIN Purchasing.Vendor
ON Purchasing.Vendor.VendorID = Purchasing.ProductVendor.VendorID
WHERE MakeFlag = 0 AND Class <> 'NULL'

--8. Получить перечень названий продуктов, вошедших в заказы на продажу, созданные 1 февраля 2004 года.

SELECT Production.Product.Name
FROM Production.Product
INNER JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE OrderDate = '01-02-2004'

--9. Получить общее количество проданных единиц каждого товара по каждому наименованию за всю историю продаж

SELECT COUNT(Production.Product.Name), Production.Product.Name
FROM Production.Product
INNER JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
INNER JOIN Sales.SalesOrderHeader
ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
GROUP BY  Production.Product.Name

--10. Получить контактную информацию клиентов (имя, фамилия, телефон), 
--чьи заказы в настоящий момент находятся в стадии выполнения.

SELECT FirstName, LastName, Phone, Status
FROM Person.Contact
INNER JOIN Sales.SalesOrderHeader
ON Person.Contact.ContactID = Sales.SalesOrderHeader.ContactID
WHERE Status = 1
