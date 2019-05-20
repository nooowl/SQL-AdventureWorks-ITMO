--1.	Получить список (названия компаний) всех активно использующихся поставщиков запчастей и других товаров

SELECT Name FROM Purchasing.Vendor WHERE ActiveFlag = 1

--2.	Получить список всех поставщиков запчастей и других товаров  с кредитным рейтингом от среднего до отличного включительно 
--(названия компаний и кредитный рейтинг)

SELECT Name, CreditRating FROM Purchasing.Vendor WHERE CreditRating >= 4

--3.	Получить список всех поставщиков запчастей и других товаров, для которых в БД хранятся данные об их Интернет-ресурсе 
--(названия компаний и адрес Интернет-ресурса)

SELECT Name, PurchasingWebServiceURL FROM Purchasing.Vendor WHERE PurchasingWebServiceURL IS NOT NULL

--4.	Получить список всех женских имен (без повторений) из таблицы контактной информации

SELECT DISTINCT FirstName, LastName FROM Person.Contact WHERE Title = 'Ms.' 

--5.	Получить полное имя (включая принятое обращение) и адреса электронной почты тех лиц, 
--которые согласились получать рекламную рассылку

SELECT Title, FirstName, MiddleName, LastName, Suffix, EmailAddress FROM Person.Contact WHERE EmailPromotion = 1

--6.	Получить полное имя (включая принятое обращение) и номера телефонов тех лиц, 
--у которых номер телефона содержит последовательность цифр «016»

SELECT Title, FirstName, MiddleName, LastName, Suffix, Phone FROM Person.Contact WHERE Phone LIKE '%016%'

--7.	Получить список всех должностей сотрудников

SELECT Title FROM HumanResources.Employee 

--8.	Получить список должностей сотрудников, занимаемых мужчинами

SELECT Title FROM HumanResources.Employee WHERE Gender = 'M'

--9.	Определить должности сотрудников, принятых на работу 4 января 2000 года

SELECT Title FROM HumanResources.Employee WHERE HireDate = '2000-01-04 00:00:00.000'

--10.	Получить перечень должностей сотрудников, принятых на работу в период с марта 1999 года по январь 2000 года включительно

SELECT Title FROM HumanResources.Employee WHERE HireDate BETWEEN '1999-03-01 00:00:00.000' AND '2000-01-31 00:00:00.000'

--11.	Получить перечень идентификационных номеров сотрудников (ИНН) у которых суммарный отпуск (в том числе по болезни) 
--составил более 100 часов

SELECT NationalIDNumber FROM HumanResources.Employee WHERE (VacationHours + SickLeaveHours) > 100

--12.	Получить список всех продаваемых продуктов (название), имеющих размер 40 сантиметров

SELECT Name FROM Production.Product WHERE Size = '40' AND SizeUnitMeasureCode = 'CM'

--13.	Получить перечень продуктов (название), используемых во всех линейках велосипедов кроме туристических

SELECT Name FROM Production.Product WHERE ProductLine <> 'T'

--14.	Получить перечень всех продуктов (название), изготовленных в компании, изготовление которых требует более 3 дней

SELECT Name FROM Production.Product WHERE DaysToManufacture > 3

--15.	Вывести неповторяющийся список размеров продуктов, закупленных у сторонних изготовителей

SELECT DISTINCT Size FROM Production.Product WHERE MakeFlag = 0