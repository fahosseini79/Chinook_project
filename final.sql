-- 1
select t.Name ,sum(i.Quantity * i.UnitPrice) as Income
from invoiceline i 
join track t on i.TrackId = t.TrackId 
group by t.Name 
order by Income desc
LIMIT 10;

-- 2
WITH GenreSales AS (
    SELECT
        g.Name AS Name,
        COUNT(i.Quantity) AS NumberOfSongsSold,
        SUM(i.Quantity * i.UnitPrice) AS TotalRevenue
    FROM
        Track t
            INNER JOIN (
                SELECT TrackId, Quantity, UnitPrice
                FROM InvoiceLine
            ) i ON t.TrackId = i.TrackId
            INNER JOIN (
                SELECT GenreId, Name
                FROM Genre
            ) g ON t.GenreId = g.GenreId
    GROUP BY
        g.Name
)
SELECT
    Name,
    NumberOfSongsSold,
    TotalRevenue
FROM (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY NumberOfSongsSold DESC, TotalRevenue DESC) AS TotalRank
    FROM
        GenreSales
) RankedGenres
WHERE
    TotalRank = 1;

-- 3
SELECT c.CustomerId
FROM customer c
LEFT JOIN Invoice i ON c.CustomerId = i.CustomerId
WHERE 
i.CustomerId IS NULL;

-- 4
select a.Title ,avg(t.Milliseconds) as AverageTime
from track t
join album a on t.AlbumId = a.AlbumId
group by a.title

-- 5
select e.EmployeeId, e.FirstName, e.LastName ,count(c.SupportRepId) as TotalSales
from customer c
join employee e on c.SupportRepId = e.EmployeeId
group by e.EmployeeId
order by TotalSales DESC
LIMIT 1;

-- 6
SELECT
    c.CustomerId,
    COUNT(DISTINCT t.GenreId) AS GenreCount
FROM
    Customer c
        INNER JOIN (
            SELECT CustomerId, InvoiceId
            FROM Invoice
        ) i ON c.CustomerId = i.CustomerId
        INNER JOIN (
            SELECT InvoiceId, TrackId
            FROM InvoiceLine
        ) l ON i.InvoiceId = l.InvoiceId
        INNER JOIN (
            SELECT TrackId, GenreId
            FROM Track
        ) t ON l.TrackId = t.TrackId
GROUP BY
    c.CustomerId
HAVING
    COUNT(DISTINCT t.GenreId) > 1;

-- 7
WITH RankedSongs AS (
    SELECT
        g.Name AS Genre,
        t.Name AS Song,
        SUM(i.UnitPrice * i.Quantity) AS Revenue,
        ROW_NUMBER() OVER (PARTITION BY g.Name ORDER BY SUM(i.UnitPrice * i.Quantity) DESC) AS RevenueRank
    FROM
        Genre g
            INNER JOIN (
                SELECT TrackId, GenreId, Name
                FROM Track
            ) t ON g.GenreId = t.GenreId
            INNER JOIN (
                SELECT TrackId, UnitPrice, Quantity
                FROM InvoiceLine
            ) i ON t.TrackId = i.TrackId
    GROUP BY
        g.Name, t.Name
)
SELECT
    Genre,
    Song,
    Revenue
FROM
    RankedSongs
WHERE
    RevenueRank <= 3
ORDER BY
    Genre, Revenue DESC;

-- 8
with AnnualSales as (
select year(inv.InvoiceDate) as SaleYear, sum(i.Quantity) as TotalSongsSold
from InvoiceLine i
join Invoice inv on i.InvoiceId = inv.InvoiceId
group by year(inv.InvoiceDate)
)
select SaleYear, sum(TotalSongsSold) over (order by SaleYear) as CumulativeSongsSold
from AnnualSales
order by SaleYear;

-- 9
select c.CustomerId, c.FirstName, c.LastName, sum(inv.Total) as TotalPurchase
from Customer c
join Invoice inv on c.CustomerId = inv.CustomerId
group by c.CustomerId
having sum(inv.Total) > (select avg(Total) from (select sum(Total) as Total from Invoice group by CustomerId) as UserTotals);
