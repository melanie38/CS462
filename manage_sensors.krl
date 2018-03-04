ruleset manage_sensors {

  meta {
    name "Manage Sensors"
    author "Melanie Lambson"

    shares name
    provides name
  }

  global {
    threshold = 80
    name = function() {
      ent:name
    }
    sensors = function() {
      ent:sensors.defaultsTo({});
    }
  }

  rule add_sensor {
    select when sensor new_sensor

    pre {
      name = event:attrs{"name"}
      exists = ent:sensors >< name
    }

    if not exists
    then
      noop()

    fired {
      raise wrangler event "child_creation" attributes {
        "name": name,
        "rids": ["temperature_store", "wovyn_base", "sensor_profile"]
      };
      ent:name := name;
    }
  }

  rule store_eci_sensor {
    select when wrangler child_initialized

    pre {
      eci = event:attrs{"eci"}
    }

    fired {
      ent:sensors := ent:sensors.defaultsTo({}).put(ent:name, eci).klog("Sensors list: ");
      raise sensor event "profile_updated" attributes {
        "name" : ent:name,
        "phone" : "+13853099608",
        "threshold" : threshold
      };
    }
  }

  rule sensor_already_exists {
    select when sensor new_sensor
    pre {
      name = event:attr("name")
      exists = ent:sensors >< name
    }
    if exists then
      send_directive("sensor_ready", {"name":section_id})
  }

  // rule child_pico_ready {
  //   select when sensor ready

  //   fired {
  //     raise sensor event "profile_updated" attributes {
  //       "name" : manager:name(),
  //       "phone" : "+13853099608",
  //       "threshold" : threshold
  //     };
  //   }
  // }

  rule delete_sensor {
    select when sensor unneeded_sensor

    pre {
      child_to_delete = event:attrs{"name"}
      exists = ent:sensors >< child_to_delete
    }

    if exists then
      send_directive("deleting_sensor", {"name":child_to_delete})
    fired {
      raise wrangler event "child_deletion"
        attributes {"name": child_to_delete};
      clear ent:sensors{[child_to_delete]}
    }
  }

  rule clear_sensors {
    select when sensor clear

    always {
      ent:sensors := {}
    }
  }

}
