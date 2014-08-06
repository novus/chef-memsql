name "memsql_standalone"
description "Role for what it says"
run_list(
         "recipe[memsql::install]",
         "recipe[memsql::ops]"
)
default_attributes(

)
