ruleset temperature_store {
  meta {
    name "Store Temperatures"
    author "Melanie Lambson"
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
      ent:temperatures := ent:temperatures.defaultsTo({}).put(newEntry).klog("temperatures map")
    }

  }
}
