/*
    Confectionary business scenario implementation in T-SQL.
    The script creates a single table that captures orders for cakes, cookies, and cupcakes,
    enforces the business rules, loads the provided sample data, and produces the required reports.
*/

/* Drop and recreate the table to keep the script idempotent while testing */
IF OBJECT_ID('dbo.BakeryOrders', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.BakeryOrders;
END;
GO

CREATE TABLE dbo.BakeryOrders
(
    OrderID             INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName        NVARCHAR(100)      NOT NULL,
    Branch              NVARCHAR(50)       NOT NULL CHECK (Branch IN ('Brooklyn', 'Lakewood')),
    OrderDate           DATE               NOT NULL,
    ItemType            NVARCHAR(10)       NOT NULL CHECK (ItemType IN ('Cake', 'Cookie', 'Cupcake')),
    BaseFlavor          NVARCHAR(50)       NOT NULL,
    Topping             NVARCHAR(50)       NULL,
    HasPhoto            BIT                NOT NULL,
    CustomSpecifications NVARCHAR(500)     NULL,
    Occasion            NVARCHAR(100)      NOT NULL,
    Quantity            INT                NOT NULL,
    UnitPrice AS (
        CASE ItemType
            WHEN 'Cake' THEN CAST(50.0
                                   + CASE WHEN BaseFlavor = 'Strawberry shortcake' THEN 5.0 ELSE 0.0 END
                                   + CASE WHEN HasPhoto = 1 THEN 8.0 ELSE 0.0 END AS DECIMAL(10,2))
            WHEN 'Cupcake' THEN CAST(3.0 AS DECIMAL(10,2))
            WHEN 'Cookie' THEN CAST(3.5 + CASE WHEN HasPhoto = 1 THEN 1.5 ELSE 0.0 END AS DECIMAL(10,2))
        END
    ) PERSISTED,
    TotalPrice AS (
        CAST(Quantity AS DECIMAL(10,2)) *
        CASE ItemType
            WHEN 'Cake' THEN CAST(50.0
                                   + CASE WHEN BaseFlavor = 'Strawberry shortcake' THEN 5.0 ELSE 0.0 END
                                   + CASE WHEN HasPhoto = 1 THEN 8.0 ELSE 0.0 END AS DECIMAL(10,2))
            WHEN 'Cupcake' THEN CAST(3.0 AS DECIMAL(10,2))
            WHEN 'Cookie' THEN CAST(3.5 + CASE WHEN HasPhoto = 1 THEN 1.5 ELSE 0.0 END AS DECIMAL(10,2))
        END
    ) PERSISTED,
    CONSTRAINT CK_BakeryOrders_PhotoOnCupcakes CHECK (ItemType <> 'Cupcake' OR HasPhoto = 0),
    CONSTRAINT CK_BakeryOrders_CookieQuantity CHECK (ItemType <> 'Cookie' OR (Quantity BETWEEN 24 AND 500)),
    CONSTRAINT CK_BakeryOrders_CupcakeQuantity CHECK (ItemType <> 'Cupcake' OR (Quantity BETWEEN 12 AND 500)),
    CONSTRAINT CK_BakeryOrders_CakeQuantity CHECK (ItemType <> 'Cake' OR (Quantity BETWEEN 1 AND 500))
);
GO

/* Load the provided sample data */
INSERT INTO dbo.BakeryOrders
    (CustomerName, Branch, OrderDate, ItemType, BaseFlavor, Topping, HasPhoto, CustomSpecifications, Occasion, Quantity)
VALUES
    (N'Chaim Green',          N'Lakewood', '2022-01-04', N'Cake',    N'Strawberry shortcake', N'None',            0, N'Please make sure they both look the same',        N'Baby',        2),
    (N'Rivky Shapiro',        N'Lakewood', '2021-07-22', N'Cake',    N'Chocolate',            N'Caramel',         0, N'Write Happy birthday on cake',                    N'Birthday',    1),
    (N'Leah Gross',           N'Brooklyn', '2021-06-11', N'Cookie',  N'Sugar',                N'Royal icing',     1, N'Graduation cap shape of picture I emailed',       N'Graduation', 70),
    (N'Baruch Goldberg',      N'Brooklyn', '2021-09-12', N'Cookie',  N'Sugar',                N'Royal icing',     0, N'Shape of a mask and write thank you for keeping everyone safe and company logo', N'Company logo', 500),
    (N'Binyamin Stein',       N'Lakewood', '2021-02-15', N'Cake',    N'Vanilla',              N'Chocolate',       1, N'Write Happy 85th birthday on bottom of the attached photo', N'Birthday', 3),
    (N'Batsheva Golden',      N'Lakewood', '2021-08-14', N'Cake',    N'Chocolate peanut butter', N'Peanut butter', 1, N'Write Shloimy and the number 3 on pic',            N'Birthday',    1),
    (N'Rena Stern',           N'Brooklyn', '2021-10-11', N'Cookie',  N'Sugar',                N'Fondant',         0, N'Pink background with glitter and shape of balloon with word Sori', N'Bas mitzvah', 75),
    (N'Layala Katz',          N'Lakewood', '2021-09-05', N'Cupcake', N'Vanilla',              N'Strawberry',      0, N'Make it look nice!',                               N'Birthday',   28),
    (N'Sara Leah Levy',       N'Brooklyn', '2021-05-18', N'Cupcake', N'Vanilla',              N'Coconut',         0, N'none',                                            N'Engagement',100),
    (N'Devorah Friedman',     N'Brooklyn', '2021-07-04', N'Cake',    N'Strawberry shortcake', N'None',            0, N'none',                                            N'Wedding',    15),
    (N'Kaufman',              N'Lakewood', '2021-11-09', N'Cake',    N'Chocolate peanut butter', N'Chocolate',    0, N'none',                                            N'Bar mitzvah', 3),
    (N'Chana Cohen',          N'Lakewood', '2021-07-04', N'Cake',    N'Banana',               N'Vanilla',         1, N'Attached photo',                                   N'Anniversary', 1),
    (N'Ahuva Licht',          N'Lakewood', '2021-06-22', N'Cookie',  N'Sugar',                N'Royal icing',     0, N'Write Chaim and Devorah',                         N'Engagement', 75),
    (N'Tziporah Markowitz',   N'Lakewood', '2021-03-16', N'Cake',    N'Strawberry shortcake', N'None',            0, N'no',                                              N'Baby',        3),
    (N'David Fried',          N'Lakewood', '2021-10-01', N'Cake',    N'Chocolate peanut butter', N'Chocolate',   0, N'no',                                              N'Bar mitzvah', 2),
    (N'Moshe Abrams',         N'Brooklyn', '2021-08-23', N'Cupcake', N'Vanilla',              N'Peanut butter',   0, N'Write 3 on it',                                   N'Birthday',  150),
    (N'Rachel Bernstein',     N'Lakewood', '2021-02-28', N'Cookie',  N'Sugar',                N'Fondant',         1, N'Attached photo of daughter',                      N'Bas mitzvah', 80),
    (N'Faiga Berg',           N'Brooklyn', '2021-10-12', N'Cupcake', N'Chocolate',            N'Chocolate',       0, N'Add a pecan on each one',                         N'Event',     350),
    (N'Dena Bergman',         N'Brooklyn', '2021-06-08', N'Cookie',  N'Sugar',                N'Royal icing',     0, N'Write Shimon and Leah',                           N'Engagement', 75),
    (N'Asher Yechiel Eisen',  N'Brooklyn', '2021-12-31', N'Cookie',  N'Sugar',                N'Royal icing',     0, N'In shape of thirteen',                            N'Bar mitzvah',175),
    (N'Mendy Fischer',        N'Lakewood', '2021-07-04', N'Cupcake', N'Banana',               N'Vanilla',         0, N'For new baby',                                    N'Baby',     100),
    (N'Chaya Kaplan',         N'Lakewood', '2021-01-01', N'Cupcake', N'Chocolate',            N'Vanilla',         0, N'Make it taste great please',                      N'Birthday', 100),
    (N'Sarala Schwartz',      N'Brooklyn', '2021-06-09', N'Cupcake', N'Chocolate',            N'Vanilla',         0, N'none',                                            N'Baby',      50),
    (N'Sarah Braunstein',     N'Brooklyn', '2021-10-24', N'Cookie',  N'Sugar',                N'Royal icing',     1, N'See attached picture of my house',                 N'Family party',110);
GO

/* The data, complete with computed pricing columns */
SELECT *
FROM dbo.BakeryOrders
ORDER BY OrderDate, OrderID;
GO

/*
    Report 1: Sum of how many of each type of cake/cupcake/cookie is sold per branch.
    Includes the item type, base flavor, and the total quantity per branch.
*/
SELECT
    Branch,
    ItemType,
    BaseFlavor,
    SUM(Quantity) AS TotalItemsSold
FROM dbo.BakeryOrders
GROUP BY Branch, ItemType, BaseFlavor
ORDER BY Branch, ItemType, BaseFlavor;
GO

/*
    Report 2: Number of orders per season, occasion, and branch.
    Seasons follow the custom definitions provided in the requirements.
*/
WITH SeasonBuckets AS
(
    SELECT
        CASE
            WHEN MONTH(OrderDate) IN (7, 8) THEN 'Summer'
            WHEN MONTH(OrderDate) IN (9, 10) THEN 'Holiday time'
            WHEN MONTH(OrderDate) IN (11, 12, 1, 2, 3, 4) THEN 'Winter'
            WHEN MONTH(OrderDate) IN (5, 6) THEN 'Spring'
        END AS Season,
        Occasion,
        Branch
    FROM dbo.BakeryOrders
)
SELECT
    Season,
    Occasion,
    Branch,
    COUNT(*) AS OrdersPlaced
FROM SeasonBuckets
GROUP BY Season, Occasion, Branch
ORDER BY Season, Occasion, Branch;
GO

/*
    Report 3: Monthly revenue per branch.
*/
SELECT
    Branch,
    DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS RevenueMonth,
    SUM(TotalPrice) AS MonthlyRevenue
FROM dbo.BakeryOrders
GROUP BY Branch, DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
ORDER BY RevenueMonth, Branch;
GO

/*
    Report 4: Monthly order counts per branch.
*/
SELECT
    Branch,
    DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS OrderMonth,
    COUNT(*) AS OrdersPlaced
FROM dbo.BakeryOrders
GROUP BY Branch, DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
ORDER BY OrderMonth, Branch;
GO

/* Earliest order date */
SELECT MIN(OrderDate) AS EarliestOrderDate
FROM dbo.BakeryOrders;
GO
