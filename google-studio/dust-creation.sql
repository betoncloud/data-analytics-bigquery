WITH outputs_unnested AS (
SELECT case when epoch_no >=0 and epoch_no <= 207 then "Byron" 
when epoch_no >=208 and epoch_no <= 235 then "Shelly"
when epoch_no >=236 and epoch_no <= 249 then "Allegra"  
when epoch_no >=250 and epoch_no <= 290 then "Mary"
when epoch_no >=290 and epoch_no <= 364 then "Alonzo"  
when epoch_no >=365 then "Vasil" end as Hardfork, 
  epoch_no, CAST(JSON_VALUE(o, '$.out_value') AS INT64) as out_value_lovelace, CAST(JSON_VALUE(o, '$.out_value') AS INT64)/1000000 AS out_value_ada 
FROM cardano_mainnet.tx_in_out  LEFT JOIN   UNNEST(JSON_EXTRACT_ARRAY(outputs, "$")
) AS o 
WHERE  case when @epoch_no = 0 then epoch_no >=0  else  epoch_no = @epoch_no end
)
SELECT   max(current_epoch_no) as current_epoch_no, Any_value(Hardfork) as Hardfork, epoch_no as Epoch_No, count(*) as Count, SUM(out_value_ada) AS Total_Dust_Created_In_ADA, MIN(out_value_ada) AS Min_Dust_Created_In_ADA, AVG(out_value_ada) AS Avg_Dust_Created_In_ADA
FROM outputs_unnested LEFT join cardano_mainnet.vw_current_epoch_no c on epoch_no = c.current_epoch_no
where out_value_lovelace < 1000000 
group by  epoch_no 
