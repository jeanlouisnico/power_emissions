DELETE FROM xchange
WHERE id IN
    (SELECT id
    FROM 
        (SELECT id,
         ROW_NUMBER() OVER( PARTITION BY date_time,
         source,
         fromcountry, 
         tocountry
        ORDER BY  id ) AS row_num
        FROM xchange ) t
        WHERE t.row_num > 1 );