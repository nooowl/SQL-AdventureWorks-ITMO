--1. Получить идентификационный номер заказчика, а также строку адреса улицы для выставления счета и строку адреса улицы доставки товара в том случае, когда два указанных значения не совпадают

SELECT Sales.Customer.AccountNumber, abill.AddressLine1, aship.AddressLine1
FROM Sales.SalesOrderHeader bill
JOIN Person.Address abill
ON bill.BillToAddressID = abill.AddressID
JOIN Person.Address aship
ON bill.ShipToAddressID = aship.AddressID
JOIN Sales.Customer
ON Sales.Customer.CustomerID = bill.CustomerID
WHERE bill.ShipToAddressID <> bill.BillToAddressID

--2. Получить пары номеров кредитных карт, принадлежащих одному и тому же заказчику (указать ContactID), исключая сочетание номера с самим собой

SELECT c.ContactID, c1.CardNumber, c2.CardNumber
FROM Sales.ContactCreditCard c
JOIN Sales.CreditCard c1
ON c.ContactID = c1.CreditCardID
JOIN Sales.CreditCard c2
ON c.ContactID = c2.CreditCardID
WHERE c1.CreditCardID <> c2.CreditCardID

--3. Получить список торговых представителей (указать идентификационные номера) с одинаковыми комиссионными, исключая повторяющиеся сочетания и сочетания с самими собой 

SELECT c1.AccountNumber, c2.AccountNumber, p1.CommissionPct
FROM Sales.SalesPerson p1
JOIN Sales.SalesPerson p2
ON p1.CommissionPct = p2.CommissionPct
JOIN Sales.SalesOrderHeader s1
ON s1.SalesPersonID = p1.SalesPersonID
JOIN Sales.Customer c1
ON s1.CustomerID = c1.CustomerID
JOIN Sales.SalesOrderHeader s2
ON s2.SalesPersonID = p2.SalesPersonID
JOIN Sales.Customer c2
ON s2.CustomerID = c2.CustomerID
WHERE c1.CustomerID < c2.CustomerID

--4. Получить единый список идентификационных номеров компонент для сборки продукта номер 400 и изделий, для производства которых он используется, с указанием ‘Component’ или ‘Product’.

SELECT 'Component', p.ProductNumber
FROM Production.BillOfMaterials m
JOIN Production.Product p
ON p.ProductID = m.ComponentID
WHERE m.ProductAssemblyID = 400
UNION
SELECT 'Product', p.ProductNumber
FROM Production.BillOfMaterials m
JOIN Production.Product p
ON p.ProductID = m.ProductAssemblyID
WHERE m.ComponentID = 400;

--5. Получить перечень изделий (идентификационный номер), для производства которых требуется а) 36 – 37 и б) 38 – 40 каких-либо деталей включительно с указанием соответствующего интервала.

SELECT p.ProductNumber, '36 - 37' Interval
FROM Production.BillOfMaterials m
JOIN Production.Product p
ON p.ProductID = m.ProductAssemblyID
WHERE m.PerAssemblyQty BETWEEN 36 AND 37
UNION
SELECT p.ProductNumber, '38 - 40' Interval
FROM Production.BillOfMaterials m
JOIN Production.Product p
ON p.ProductID = m.ProductAssemblyID
WHERE m.PerAssemblyQty BETWEEN 38 AND 40;

--6. Посчитать количество заказов, в которых было заказано от 1 до 3 единицы и от 4 до 6 единиц любого товара включительно с указанием соответствующего интервала

SELECT '1 - 3' Interval, COUNT(*)
FROM Sales.SalesOrderDetail s
WHERE s.OrderQty BETWEEN 1 AND 3
UNION
SELECT '4 - 6' Interval, COUNT(*)
FROM Sales.SalesOrderDetail s
WHERE s.OrderQty BETWEEN 4 AND 6;

--7. Получить пары заказчиков (указать идентификационные номера), располагающихся в одном и том же городе, исключая повторяющиеся сочетания и сочетания с самим собой

SELECT DISTINCT c1.AccountNumber, c2.AccountNumber, a2.City
FROM Sales.Customer c1
JOIN Sales.CustomerAddress ca1
ON ca1.CustomerID = c1.CustomerID
JOIN Person.Address a1
ON a1.AddressID = ca1.AddressID
JOIN Sales.Customer c2
ON c2.CustomerID <> c1.CustomerID
JOIN Sales.CustomerAddress ca2
ON ca2.CustomerID = c2.CustomerID
JOIN Person.Address a2
ON a2.AddressID = ca2.AddressID
WHERE c1.CustomerID < c2.CustomerID AND a1.City = a2.City;

--8. Посчитать для скольких компонентов единица измерения количества кодируется символами ‘EA’, а для скольких ‘OZ’ (не используя WHERE)

SELECT comp2.UnitMeasureCode, COUNT(*)
FROM Production.BillOfMaterials comp1
JOIN Production.BillOfMaterials comp2
ON comp1.BillOfMaterialsID = comp2.BillOfMaterialsID AND (comp2.UnitMeasureCode = 'EA' OR comp2.UnitMeasureCode = 'OZ')
GROUP BY comp2.UnitMeasureCode;

--9. Проверить, располагаются ли по одному и тому же адресу разные поставщики (указать идентификационные номера) 

SELECT DISTINCT v1.AccountNumber, v2.AccountNumber
FROM Purchasing.Vendor v1
JOIN Purchasing.VendorAddress AS va1
ON va1.VendorID = v1.VendorID
JOIN Person.Address AS a1
ON a1.AddressID = va1.AddressID
JOIN Purchasing.Vendor v2
ON v2.VendorID <> v1.VendorID
JOIN Purchasing.VendorAddress va2
ON va2.VendorID = v2.VendorID
JOIN Person.Address a2
ON a2.AddressID = va2.AddressID AND a2.AddressID = a1.AddressID
WHERE v1.VendorID < v2.VendorID;

--10. Получить идентификационные номера холостых (неженатые) сотрудников-руководителей, у которых в подчинении есть холостые (неженатые) сотрудники другого пола

SELECT DISTINCT employee.NationalIDNumber
FROM HumanResources.Employee boss
JOIN HumanResources.Employee employee
ON employee.ManagerID = boss.EmployeeID AND employee.MaritalStatus = 'S' AND employee.Gender <> boss.Gender
WHERE boss.MaritalStatus = 'S';