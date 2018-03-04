ruleset sensor_profile {

  meta {
    name "Sensor's Profile"
    author "Melanie Lambson"

    provides name, location, threshold, phone
    shares name, location, threshold, phone

    use module manage_sensors alias manager
  }

  global {

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
      "+1" + ent:sensor_phone.defaultsTo("3853099608")
    }

  }

  rule update_profile {
    select when sensor profile_updated

    pre {
      name = event:attr("name").klog("name: ")
      location = event:attr("location").klog("location: ")
      threshold = event:attr("threshold").klog("threshold: ")
      phone = event:attr("phone").klog("phone: ")
    }

    fired {
      ent:sensor_name := name;
      ent:sensor_location := location;
      ent:sensor_threshold := threshold.as("Number");
      ent:sensor_phone := phone;
    }
  }

  rule ruleset_installed {
    select when wrangler ruleset_added

    pre {
      name = event:attrs{"name"}
    }

    always {
      raise sensor event "ready";
      raise sensor event "profile_updated" attributes {
        "name" : name,
        "phone" : "+13853099608",
        "threshold" : manager:threshold
      };
    }
  }

}
