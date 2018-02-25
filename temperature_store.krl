ruleset temperature_store {

  meta {
    name "Store Temperatures"
    author "Melanie Lambson"

    provides temperatures, threshold_violations, inrange_temperatures,
      name, location, threshold, phone
    shares temperatures, threshold_violations, inrange_temperatures,
      name, location, threshold, phone
  }

  global {

    temperatures = function() {
      ent:all_temperatures
    }

    threshold_violations = function() {
      ent:violations
    }

    inrange_temperatures = function() {
      ent:all_temperatures.difference(ent:violations)
    }

    name = function() {
      ent:sensor_name.defaultsTo("Wovyn")
    }

    location = function() {
      ent:sensor_location.defaultsTo("Salt Lake City")
    }

    threshold = function() {
      ent:sensor_threshold.defaultsTo(80)
    }

    phone = function() {
    ent:sensor_phone.defaultsTo("+13853099608")
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
      } if (temperature > threshold);
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

  rule sensor_profile {
    select when sensor profile_updated

    pre {
      name = event:attr("name")
      location = event:attr("location")
      threshold = event:attr("threshold")
      phone = event:attr("phone")
    }

    fired {
      ent:sensor_name = name;
      ent:sensor_location = location;
      ent:sensor_threshold = threshold;
      ent:sensor_phone = phone;
    }

  }

}
