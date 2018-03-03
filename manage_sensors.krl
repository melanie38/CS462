ruleset manage_sensors {

  meta {
    name "Manage Sensors"
    author "Melanie Lambson"
  }

  rule add_sensor {
    select when sensor new_sensor

    pre {
      name = event:attrs{"name"}
    }

    fired {
      raise wrangler event "child_creation" attributes {
        "name": name,
        "rids": ["temperature_store", "wovyn_base", "sensor_profile"]
      };
    }
  }

}
