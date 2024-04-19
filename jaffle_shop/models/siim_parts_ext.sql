
select ABS(FARM_FINGERPRINT(GENERATE_UUID())) AS dwh_id
,psfc.order_part_id
,max(case
when process_name = 'SURFACE_FINISH'
then replace(JSON_EXTRACT(process_config, '$.value'), '"', '')
end) as part_surface_primary_finish
,max(case
when process_name = 'SECONDARY_SURFACE_FINISH'
then replace(JSON_EXTRACT(process_config, '$.value'), '"', '')
end) as part_surface_secondary_finish
,max(case
when process_name = 'SECONDARY_SURFACE_FINISH_RAL'
then replace(JSON_EXTRACT(process_config, '$.ralCode'), '"', '')
end) as part_ral_code
,max(case
when process_name = 'SECONDARY_SURFACE_FINISH_RAL'
then replace(JSON_EXTRACT(process_config, '$.ralFinish'), '"', '')
end) as part_ral_finish
,CURRENT_TIMESTAMP() as dwh_inserted_ts_utc
,CURRENT_TIMESTAMP() as dwh_updated_ts_utc
from analytics_engineer_test_task.parts p
left join analytics_engineer_test_task.parts_surface_finish_config psfc on p.order_part_id = psfc.order_part_id
group by psfc.order_part_id
--limit 10000