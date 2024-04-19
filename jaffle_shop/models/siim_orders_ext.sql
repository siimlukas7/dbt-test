select ABS(FARM_FINGERPRINT(GENERATE_UUID())) AS dwh_id
    ,o.order_id
    ,count(distinct p.order_part_id) as distinct_part_id_cnt -- open question - what does "different parts" mean here?
    ,count(distinct p.material_name) as distinct_material_cnt -- open question - what does "different parts" mean here?
    ,countif(p.selected_process_type = 'cnc_machining') as cnc_part_cnt
    ,countif(p.selected_process_type = 'laser_cutting') as laser_part_cnt
    ,countif(p.has_bending = 1) as bending_part_cnt
    ,sum(p.bends_count) total_bends_cnt -- this could be a dq issue, part has_bending, but bends_count is null
    ,countif(p.has_surface_coating = true) as surface_coaring_part_cnt
    ,countif(p.has_insert_operations = true) as insert_operations_part_cnt
    ,string_agg(distinct spe.part_ral_code) as list_part_ral_code
    ,string_agg(distinct spe.part_ral_finish) as list_part_ral_finish
    ,string_agg(distinct spe.part_surface_primary_finish) as list_part_primary_finish
    ,string_agg(distinct spe.part_surface_secondary_finish) as list_part_secondary_finish
    ,CURRENT_TIMESTAMP() as dwh_inserted_ts_utc
    ,CURRENT_TIMESTAMP() as dwh_updated_ts_utc
from analytics_engineer_test_task.orders o
left join analytics_engineer_test_task.parts p on o.order_id = p.order_id
left join {{ ref('siim_parts_ext') }} spe on spe.order_part_id = p.order_part_id -- put the model ref here
group by o.order_id