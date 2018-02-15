ruleset temperature_store {

  meta {
    name "Store Temperatures"
    author "Melanie Lambson"
  }

  global {
    temperature_threshold = 70
  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading where event:attrs{"genericThing"} != null

    pre {
      attributes = event:attrs{["genericThing", "data", "temperature"]}.klog("attrs")
      tempArray = attributes[0].klog("tempArray")
      temperature = tempArray{"temperatureF"}.klog("temperatureF")
      timestamp = time:now().klog("time")
      newEntry = {"timestamp" : timestamp, "temperature" : temperature}
    }

    fired {
      ent:index := 1 + ent:index.defaultsTo(-1);
      ent:temperatures := ent:temperatures.defaultsTo({}).put(ent:index, newEntry).klog("temperatures map");

      raise wovyn event "threshold_violation" attributes {
        "temperature" : temperature,
        "timestamp" : timestamp
      } if (temperature > temperature_threshold);
    }
  }

  rule collect_threshold_violations {
    select when wovyn threshold_violation

    pre {
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
      newEntry = {"timestamp" : timestamp, "temperature" : temperature}
    }

    fired {
      ent:violation_index := 1 + ent:violation_index.defaultsTo(-1);
      ent:violations := ent:violations.defaultsTo({}).put(ent:violation_index, newEntry).klog("out of range temperatures");
    }
  }

  rule clear_temeratures {
    select when sensor reading_reset

    always {
      clear ent:index;
      clear ent:temperatures;
      clear ent:violation_index;
      clear ent:violations;
    }
  }

}
