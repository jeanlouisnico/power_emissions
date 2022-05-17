WITH cte AS (
    SELECT 
        id,
        date_time, 
        source, 
        fromcountry, 
        tocountry, 
        ROW_NUMBER() OVER (
            PARTITION BY 
                date_time, 
                source, 
                fromcountry, 
                tocountry
            ORDER BY 
                date_time, 
                source, 
                fromcountry, 
                tocountry
        ) row_num
     FROM 
        xchange
)
DELETE FROM cte
WHERE row_num > 1;