--1.	Получить список продуктов (название, цена), предназначенных для женщин, отсортированный по цене.
SELECT Name, ListPrice FROM Production.Product WHERE Style='W' ORDER BY ListPrice

--2.	Получить отсортированный список названий продуктов, закупаемых у сторонних поставщиков.
SELECT Name FROM Production.Product WHERE MakeFlag=0 ORDER BY Name 

--3.	Получить упорядоченный по алфавиту список лиц (имя, фамилия, отчество), получающих рекламную рассылку. 
SELECT FirstName, LastName, MiddleName FROM Person.Contact WHERE EmailPromotion=1 ORDER BY FirstName, LastName, MiddleName 

--4.	Получить список в обратном порядке названий поставщиков, имеющих отличный кредитный рейтинг.
SELECT Name FROM Purchasing.Vendor WHERE CreditRating=2 ORDER BY Name DESC 

--5.	Получить список продуктов (название, цвет), изготовленных в компании, упорядоченный по цвету, за исключением товаров, 
--для которых цвет не указан.
SELECT Name, Color FROM Production.Product WHERE Color IS NOT NULL ORDER BY Color 

--6.	Предоставить данные о среднем количестве дней на изготовление продуктов для каждой линейки товаров (дорожный, горный и т.д.).
SELECT ProductLine, AVG(DaysToManufacture) FROM Production.Product GROUP BY ProductLine

--7.	Указать среднюю цену закупаемых товаров.
SELECT AVG(ListPrice) FROM Production.Product WHERE MakeFlag = 0

--8.	Посчитать количество активно использующихся компаний-поставщиков по каждому типу кредитного рейтинга. 
--Указать тип рейтинга и количество поставщиков для него. 
SELECT CreditRating, COUNT(VendorID) FROM Purchasing.Vendor GROUP BY CreditRating

--9.	Отсортировать список товаров по суммарному количеству проданных единиц (название товара, число проданных экземпляров).
SELECT Name, COUNT(SalesOrderID) FROM Production.Product, Sales.SalesOrderDetail WHERE Production.Product.ProductID = Sales.SalesOrderDetail.ProductID GROUP BY Name ORDER BY COUNT(SalesOrderID)

--10.	Получить данные о количестве сотрудников-женщин, состоящих в браке.
SELECT COUNT(EmployeeID) FROM HumanResources.Employee WHERE MaritalStatus = 'M' AND Gender = 'F'

--11.	Определить суммарную продолжительность отпусков по болезни для женщин и для мужчин.
SELECT SUM(SickLeaveHours) FROM HumanResources.Employee 

--12.	Для каждого типа обращения к человеку посчитать число лиц его выбравших. 
--Отсортировать список по величине получившихся групп.
SELECT Title, COUNT(Title) FROM Person.Contact GROUP BY Title ORDER BY COUNT(Title)

--13.	Указать среднее значение минимального количества складских запасов для покупного и изготовленного в компании товаров.
SELECT MakeFlag, AVG(SafetyStockLevel) FROM Production.Product GROUP BY MakeFlag

--14.	Отсортировать производимые в компании продукты по продолжительности времени их изготовления. 
SELECT Name, DaysToManufacture FROM Production.Product ORDER BY DaysToManufacture

--15.	Указать среднюю стоимость товаров, предназначенных для мужчин и предназначенных для женщин.
SELECT Style, AVG(StandardCost) FROM Production.Product WHERE Style = 'W' OR Style = 'M' GROUP BY Style

--16.	Для каждого типа кредитного рейтинга определить количество активно использующихся поставщиков 
--и количество не использующихся поставщиков.
SELECT CreditRating, COUNT(ActiveFlag) FROM Purchasing.Vendor GROUP BY CreditRating

--17.	Определить минимальную отпускную цену за единицу продукции для каждого кода рекламной акции, 
--за исключением рекламной акции с кодом «1» и «8». Отсортировать по коду рекламной акции.
SELECT MIN(UnitPrice), SpecialOfferID FROM Sales.SalesOrderDetail WHERE SpecialOfferID <> '1' AND SpecialOfferID <> '8' GROUP BY SpecialOfferID ORDER BY SpecialOfferID 

--18.	Для каждого типа обращения к женщине получить количество лиц, выбравших его. 
SELECT Title, COUNT(ContactID) FROM Person.Contact WHERE Title IN ('Mrs.', 'Ms.', 'Ms', 'Sra.') GROUP BY Title
