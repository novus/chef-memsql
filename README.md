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

There are quite a few attributes you can set. You're strongly encouraged to look over `attributes/default.rb`.

Because of the way MemSQL is distributed, you will absolutely want to set a value for `default[:memsql][:license]` in your environment or wrapper cookbook,
and you'll want to make sure the value of `default[:memsql][:version]` is correct for your license key. If you're new to MemSQL and don't have a license already,
please get that squared away first.

If your organization already has a licensed version hosted on a local file repository, you can use the `url`, `version` and `license` attributes to have the cookbook
fetch it from there instead.

Usage
------

This cookbook uses the following roles to infer what is installed and where. By default, if you assign aggregator and
leaf roles, they will be woven into a cluster that span a `chef_environment`.

#### roles

The roles below can be found in the `roles/` subdirectory of this cookbook. You'll want to install them on your Chef server if you plan to use this cookbook's
ability to organize clusters automagically.

Please assign only one of these roles per node.

- `memsql_standalone` - installs `memsql` in standalone mode, running on port 3306, and `memsql-ops` on port 9000.
- `memsql_master_aggregator` - installs `memsql` running as a master aggregator. There should only ever be one of these
  in a cluster.
- `memsql_child_aggregator` - installs `memsql` running as a child aggregator under the master.
- `memsql_leaf` - installs `memsql` running as a leaf.

There's one more role, too:

- `memsql_ops` - installs `memsql-ops`, the pretty monitoring dashboard. You'll only want one of these per cluster. It can
   be installed two ways.
  - If installed on the same node that has the `memsql_master_aggregator` role, it will use the cluster itself for its own
  storage. This is not recommended on any cluster wheere you care about optimal performance (e.g. production) or
  recording the activity that led up to a crash or other Unfortunate Event (e.g. production).
  - If installed on its own node, it will also install its own dedicated standalone instance of `memsql` for use by Ops.

Pleaae note, however, that adding and attaching leaves to the master aggregator, assigning redundancy group (if you're using them) and other post-installation steps
still need to be done as described in the MemSQL documentation.

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
