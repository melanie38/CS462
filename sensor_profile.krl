ruleset sensor_profile {

  meta {
    name "Sensor's Profile"
    author "Melanie Lambson"

    provides name, location, threshold, phone
    shares name, location, threshold, phone
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

}
