memsql Cookbook
===============
This cookbook installs and configures MemSQL, a fast in-memory RDBMS that emulates MySQL.

Requirements
------------

At the time of this writing, this cookbook works only with Ubuntu 12.04, though it probably works fine with later Ubuntu releases.

#### cookbooks
- `apt` - because Ubuntu/Debian.

Attributes
----------
TODO: List you cookbook attributes here.

e.g.
#### memsql::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['memsql']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
------

This cookbook uses the following roles to infer what is installed and where. By default, if you assign aggregator and
leaf roles, they will be woven into a cluster that span a `chef_environment`.

#### roles

Please assign only one of these roles per node.

- `memsql_standalone` - installs `memsql` in standalone mode, running on port 3306, and `memsql-ops` on port 9000.
- `memsql_master_aggregator` - installs `memsql` running as a master aggregator. There should only ever be one of these 
  in a cluster.
- `memsql_child_aggregator` - installs `memsql` running as a child aggregator under the master.
- `memsql_leaf` - installs `memsql` running as a leaf.

There's one more role, too:

- `memsql_ops` - installs `memsql-ops`, the pretty monitoring dashboard. You'll only want one of these per cluster. It can   be installed two ways.
  - If installed on the same node that has the `memsql_master_aggregator` role, it will use the cluster itself for its own    storage. This is not recommended on any cluster wheere you care about optimal performance (e.g. production) or 
  recording the activity that led up to a crash or other Unfortunate Event (e.g. production).
  - If installed on its own node, it will also install its own dedicated standalone instance of `memsql` for use by Ops.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: TODO: List authors
