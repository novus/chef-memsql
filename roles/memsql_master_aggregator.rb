name "memsql_master_aggregator"
description "Role for what it says"
run_list(
         "recipe[memsql::install]"
)
default_attributes(

)
