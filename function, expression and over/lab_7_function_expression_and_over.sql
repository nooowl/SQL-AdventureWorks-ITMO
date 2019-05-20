--1. Найти долю продаж каждого продукта (цена продукта * количество продукта), на каждый чек, в денежном выражении

SELECT SalesOrderID, ProductID, OrderQty, 
	LineTotal/SUM(LineTotal) OVER(PARTITION BY SalesOrderID) AS 'Part'
FROM Sales.SalesOrderDetail
ORDER BY SalesOrderID, ProductID

--2. Найти долю затрат каждого покупателя, на каждый купленный им продукт, среди общих его затрат в данной сети магазинов. 
--Можно использовать обобщенное табличное выражение.

SELECT header.CustomerID, detail.SalesOrderID, ProductID, 
	SUM(OrderQty) OVER(PARTITION BY CustomerID, ProductID) AS 'OrderQty', 
	LineTotal/SUM(LineTotal) OVER(PARTITION BY CustomerID) AS 'Part'
FROM Sales.SalesOrderHeader AS header
JOIN Sales.SalesOrderDetail AS detail
ON header.SalesOrderID = detail.SalesOrderID

--3. Вывести на экран список продуктов, их стоимость, а тек же разницу между стоимостью этого продукта и 
--стоимостью самого дешевого продукта в той же подкатегории, к которой относится продукт

SELECT Name, StandardCost, ProductSubcategoryID,
	StandardCost - MIN(StandardCost) OVER(PARTITION BY ProductSubcategoryID)
FROM Production.Product

--4. Для одного выбранного покупателя вывести для каждой покупки (чека) разницу в деньгах между этой и следующей покупкой.

SELECT SalesOrderID, 
	SubTotal,
	SubTotal - LEAD(SubTotal, 1, 0) OVER(ORDER BY SalesOrderID)
FROM Sales.Customer customer
INNER JOIN Sales.SalesOrderHeader header
ON customer.CustomerID = header.CustomerID
WHERE customer.AccountNumber = 'AW00000002'

--5. Вывести следующую информацию: номер покупателя, номер чека этого покупателя отсортированные по покупателям, номерам чека. 
--Третья колонка должна содержать в каждой своей строке сумму текущего чека покупателя и всем предыдущим чекам этого покупателя.

SELECT customer.AccountNumber, 
	SalesOrderID, SubTotal,
	SUM(SubTotal) OVER(PARTITION BY customer.AccountNumber 
	ORDER BY customer.AccountNumber ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM Sales.Customer customer
INNER JOIN Sales.SalesOrderHeader header
ON customer.CustomerID = header.CustomerID
ORDER BY customer.AccountNumber, SalesOrderID 

--6. Вывести три колонки: номер покупателя, номер чека покупателя (отсортированный по возрастанию даты чека), 
--и искусственно введенный порядковый номер текущего чека, начиная с 1, для каждого покупателя.

SELECT customer.AccountNumber, 
	SalesOrderID, 
	COUNT(SalesOrderID) OVER(PARTITION BY customer.AccountNumber ORDER BY customer.AccountNumber 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Number
FROM Sales.Customer customer
INNER JOIN Sales.SalesOrderHeader header
ON customer.CustomerID = header.CustomerID
ORDER BY customer.AccountNumber, ShipDate 

--7. Вывести номера продуктов, таких что, их цена выше средней цены продукта в подкатегории, которой относится продукт. 
--Запрос реализовать двумя способами. В одном из решений допускается использование обобщенного табличного выражения.

SELECT product.ProductNumber 
FROM Production.Product product
WHERE product.StandardCost > 
	(SELECT AVG(products.StandardCost)
	FROM Production.Product products
	WHERE product.ProductSubcategoryID = products.ProductSubcategoryID
	GROUP BY products.ProductSubcategoryID)

WITH Category_AVG(ProductSubcategoryID, Category_AVG)
	AS (SELECT ProductSubcategoryID, AVG(StandardCost)
	FROM Production.Product
	GROUP BY ProductSubcategoryID)
SELECT categoryAVG.ProductSubcategoryID, categoryAVG.Category_AVG
FROM Category_AVG categoryAVG
JOIN Production.Product product
ON product.ProductSubcategoryID = categoryAVG.ProductSubcategoryID
WHERE product.StandardCost > Category_AVG

