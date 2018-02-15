ruleset temperature_store {

  meta {
    name "Store Temperatures"
    author "Melanie Lambson"

    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures
  }

  global {
    temperature_threshold = 70

    temperatures = function() {
      ent:all_temperatures
    }

    threshold_violations = function() {
      ent:violations
    }

    inrange_temperatures = function() {
      ent:all_temperatures.difference(ent:violations)
    }

  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading where event:attrs{"genericThing"} != null

    pre {
      attributes = event:attrs{["genericThing", "data", "temperature"]}
      tempArray = attributes[0]
      temperature = tempArray{"temperatureF"}
      timestamp = time:now()
      newEntry = {"timestamp" : timestamp, "temperature" : temperature}
      data = temperatures().klog("all temperatures")
      data2 = inrange_temperatures().klog("in range temperatures")
    }

    fired {
      ent:index := 1 + ent:index.defaultsTo(-1);
      ent:all_temperatures := ent:all_temperatures.defaultsTo({}).put(ent:index, newEntry);

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
      ent:violations := ent:violations.defaultsTo({}).put(ent:violation_index, newEntry);

      threshold_violations().klog("out of range temperatures");
    }
  }

  rule clear_temperatures {
    select when sensor reading_reset

    always {
      clear ent:index;
      clear ent:temperatures;
      clear ent:violation_index;
      clear ent:violations;
    }
  }

}
