ruleset temperature_store {

  meta {
    name "Store Temperatures"
    author "Melanie Lambson"

    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures
  }

  global {
    temperature_threshold = 80

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
    }

    fired {
      ent:all_temperatures := ent:all_temperatures.defaultsTo([]).append(newEntry);

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
      ent:violations := ent:violations.defaultsTo([]).append(newEntry);
    }
  }

  rule clear_temperatures {
    select when sensor reading_reset

    always {
      clear ent:all_temperatures;
      clear ent:violations;
    }
  }

}
