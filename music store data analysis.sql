-- Who is the senior most employee based on job title?

Select * from employee
ORDER BY levels desc
Limit 1music_database

--Which countries have the most invoices?

Select count (*) as c,billing_country
from invoice
group by billing_country
order by c desc

--What are the top 3 values of the invoice?

SELECT total FROM INVOICE
ORDER BY total desc
limit 3

--Which city has the best customers?Based on highest sum of invoice totals.

SELECT SUM(total)as invoice_total,billing_city
FROM INVOICE
group by billing_city
order by invoice_total desc

--who is the best customer?Person who has spent the most money will be declared the best customer

SELECT customer.customer_id,customer.first_name,customer.last_name,sum(invoice.total)as total
from customer
JOIN invoice ON customer.customer_id=invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--Return email,first name,last name & genre of all rock music listeners.Return your list ordered alphabetically by email starting with A

SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice on customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
     SELECT track_id FROM track
     JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name LIKE 'Rock')
ORDER BY email; 

--Invite artists who have written the most rock music in our dataset.
--Write a query that returns the artist name and total track count of the top 10 rock bands

SELECT artist.artist_id,artist.name,COUNT(artist.artist_id)AS number_of_songs
FROM track
JOIN album ON album.album_id=track.album_id
JOIN artist ON artist.artist_id=album.artist_id
JOIN genre ON genre.genre_id=track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
limit 10;

--Return the track names that have a song length longer than the average song length
--Return the name and milliseconds for each track
--Order by the song length with the longest songs listed first

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
        SELECT AVG(milliseconds)AS avg_track_length
        FROM track)
	ORDER BY milliseconds DESC;
	

--Find how much amount is spent by each customer on artists
--Retrun customer name,artist name and total spent 

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

--Most popular genre for each country based on the highest amount of purchases

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
		FROM invoice_line
		JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


