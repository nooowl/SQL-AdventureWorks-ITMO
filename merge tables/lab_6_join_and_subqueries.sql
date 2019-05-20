--1. Какова длительность исполнения заказов для клиента John P. Ault 
--(вывести идентификационные номер заказа, дату формирования и дату выполнения каждого заказа)

SELECT SalesOrderNumber, OrderDate, DueDate, FirstName, LastName, MiddleName
FROM Sales.SalesOrderHeader
JOIN Person.Contact
ON Person.Contact.ContactID = Sales.SalesOrderHeader.ContactID
WHERE FirstName = 'John' AND LastName = 'Ault' AND MiddleName = 'P.'

SELECT SalesOrderNumber, OrderDate, DueDate
FROM Sales.SalesOrderHeader
WHERE ContactID IN
	(SELECT ContactID
	FROM Person.Contact
	WHERE FirstName = 'John' AND LastName = 'Ault' AND MiddleName = 'P.')

--2. Найти номер заказа, дату формирования заказа, идентификационный номер заказчика и номера товаров, 
--для которых действовала рекламная акция номер 13

SELECT SalesOrderNumber, OrderDate, CustomerID, header.SalesOrderID
FROM Sales.SalesOrderHeader header
JOIN Sales.SalesOrderDetail detail
ON header.SalesOrderID = detail.SalesOrderID
WHERE detail.SpecialOfferID = 13

SELECT SalesOrderNumber, OrderDate, CustomerID, SalesOrderID
FROM Sales.SalesOrderHeader
WHERE SalesOrderID IN
	(SELECT SalesOrderID
	FROM Sales.SalesOrderDetail
	WHERE SpecialOfferID = 13)

--3. Кто из сотрудников был принят на работу позже, чем David R Campbell 
--(вывести фамилию, имя, должность, дату принятия на работу)

SELECT FirstName, LastName, employee.Title, HireDate
FROM Person.Contact person
JOIN HumanResources.Employee employee
ON person.ContactID = employee.ContactID
WHERE HireDate > 
	(SELECT HireDate
	FROM HumanResources.Employee
	JOIN Person.Contact
	ON HumanResources.Employee.ContactID =  Person.Contact.ContactID
	WHERE FirstName = 'David' AND LastName = 'Campbell' AND MiddleName = 'R')

--4. Найти всех покупателей и сотрудников, находящихся в городе Bellevue (вывести идентификационные номера)

SELECT CustomerID 'ID', City
FROM Person.Address
JOIN Sales.CustomerAddress
ON Sales.CustomerAddress.AddressID = Person.Address.AddressID
WHERE City = 'Bellevue'
UNION
SELECT EmployeeID 'ID', City
FROM Person.Address
JOIN HumanResources.EmployeeAddress
ON HumanResources.EmployeeAddress.AddressID = Person.Address.AddressID
WHERE City = 'Bellevue'


--5. Найти данные сотрудников – торговых представителей (указать фамилию, имя, отчество), 
--работающих на территории Канады (Canada)

SELECT FirstName, LastName, MiddleName
FROM HumanResources.Employee
JOIN Person.Contact
ON Person.Contact.ContactID = HumanResources.Employee.ContactID
JOIN HumanResources.EmployeeAddress
ON HumanResources.Employee.EmployeeID = HumanResources.EmployeeAddress.EmployeeID
JOIN Person.Address
ON HumanResources.EmployeeAddress.AddressID = Person.Address.AddressID
JOIN Person.StateProvince
ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID
JOIN Person.CountryRegion
ON Person.CountryRegion.CountryRegionCode = Person.StateProvince.CountryRegionCode
WHERE HumanResources.Employee.Title = 'Sales Representative' AND Person.CountryRegion.Name = 'Canada'

--6. Вывести список сотрудников (идентификационные номера), 
--планы продаж которых превышают планы продаж их руководителей

SELECT employee.EmployeeID
FROM HumanResources.Employee employee
JOIN HumanResources.Employee boss
ON boss.EmployeeID = employee.ManagerID
JOIN Sales.SalesPerson employeePlan
ON employee.EmployeeID = employeePlan.SalesPersonID
JOIN Sales.SalesPerson bossPlan
ON boss.EmployeeID = bossPlan.SalesPersonID
WHERE bossPlan.SalesQuota < employeePlan.SalesQuota OR (bossPlan.SalesQuota IS NULL AND employeePlan.SalesQuota IS NOT NULL)

SELECT employee.EmployeeID
FROM HumanResources.Employee employee
JOIN Sales.SalesPerson employeePlan
ON employee.EmployeeID = employeePlan.SalesPersonID
WHERE employee.ManagerID IN
	(SELECT boss.EmployeeID
	FROM HumanResources.Employee boss
	WHERE boss.EmployeeID IN
		(SELECT bossPlan.SalesPersonID
		FROM Sales.SalesPerson bossPlan
		WHERE bossPlan.SalesQuota < employeePlan.SalesQuota OR 
			(bossPlan.SalesQuota IS NULL AND employeePlan.SalesQuota IS NOT NULL)))

--7. Каков средний план продаж и средний объем продаж для Франции (France)?

SELECT AVG(SalesQuota), AVG(Sales.SalesPerson.SalesYTD)
FROM Sales.SalesPerson
JOIN Sales.SalesTerritory
ON Sales.SalesPerson.TerritoryID = Sales.SalesTerritory.TerritoryID
JOIN Person.StateProvince
ON Sales.SalesTerritory.TerritoryID = Person.StateProvince.TerritoryID
JOIN Person.CountryRegion
ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE Person.CountryRegion.Name = 'France'

SELECT AVG(SalesQuota), AVG(Sales.SalesPerson.SalesYTD)
FROM Sales.SalesPerson
WHERE Sales.SalesPerson.TerritoryID IN
	(SELECT Sales.SalesTerritory.TerritoryID
	FROM Sales.SalesTerritory
	WHERE Sales.SalesTerritory.TerritoryID IN
		(SELECT Person.StateProvince.TerritoryID
		FROM Person.StateProvince
		WHERE Person.StateProvince.CountryRegionCode IN
			(SELECT Person.CountryRegion.CountryRegionCode
			FROM Person.CountryRegion
			WHERE Person.CountryRegion.Name = 'France')))

--8. Для каждой территории, на которой работают два и более человек, определить общий план продаж и общий фактический объем продаж

SELECT Sales.SalesTerritory.TerritoryID, SUM(first.SalesQuota) + SUM(second.SalesQuota) 'SalesQuota', 
	SUM(first.SalesYTD) + SUM(second.SalesYTD) 'SalesYTD'
FROM Sales.SalesTerritory
JOIN Sales.SalesPerson first
ON first.TerritoryID = Sales.SalesTerritory.TerritoryID
JOIN Sales.SalesPerson second
ON second.TerritoryID = Sales.SalesTerritory.TerritoryID
WHERE first.SalesPersonID <> second.SalesPersonID
GROUP BY Sales.SalesTerritory.TerritoryID

--9. Вывести список служащих (фамилия, имя, отчество), чей план продаж больше 7% от общего плана продаж

SELECT FirstName, LastName, MiddleName
FROM Person.Contact
JOIN HumanResources.Employee
ON Person.Contact.ContactID = HumanResources.Employee.ContactID
JOIN Sales.SalesPerson
ON Sales.SalesPerson.SalesPersonID = HumanResources.Employee.EmployeeID
WHERE Sales.SalesPerson.SalesQuota > 
	(SELECT SUM(Sales.SalesPerson.SalesQuota) * 0.07
	FROM Sales.SalesPerson)

--10. Определить, есть ли территория (вывести идентификационный номер), 
--суммарный план продаж сотрудников которой превышает 20% общего плана продаж

SELECT DISTINCT TerritoryID
FROM Sales.SalesPerson
WHERE TerritoryID IN
	(SELECT TerritoryID
	FROM Sales.SalesPerson
	GROUP BY TerritoryID
	HAVING SUM(Sales.SalesPerson.SalesQuota) > 
		(SELECT SUM(Sales.SalesPerson.SalesQuota) * 0.2
		FROM Sales.SalesPerson))

--11. Вывести неповторяющийся список территорий (идентификационный номер), для которых объем фактических продаж 
--каждого служащего больше, чем плановый объем продаж территории с идентификационным номером 1

SELECT DISTINCT TerritoryID
FROM Sales.SalesPerson
WHERE SalesYTD > ALL
	(SELECT SalesYTD
	FROM Sales.SalesPerson
	WHERE TerritoryID = 1)

--12. Вывести список клиентов (идентификационный номер, фамилия, имя, отчество), 
--сделавших, по крайней мере, один заказ стоимостью более 150 000

SELECT FirstName, LastName, MiddleName
FROM Person.Contact
WHERE ContactID IN
	(SELECT ContactID
	FROM Sales.SalesOrderHeader
	WHERE SubTotal > ALL
		(SELECT SubTotal
		FROM Sales.SalesOrderHeader
		WHERE SubTotal = 150000))