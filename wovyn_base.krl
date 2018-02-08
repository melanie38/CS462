ruleset wovyn_base {

  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  rule process_heartbeat {
    select when wovyn heartbeat

    pre {
      temperature = event:attr(["genericThing", "data", "temperatureF"]).klog("attrs")
      timestamp = time.now().klog("time")
    }

    fired {
      raise wovyn event "new_temperature_reading" attributes {
        "temperature" : temperature,
        "timestamp" : timestamp
      };
    }

  }

  rule read_temperature {
    select when wovyn new_temperature_reading

    pre {
      temperature = event:attr{"temperature"}
      timestamp = event:attr{"timestamp"}
    }

    send_directive("print", {"Temperature": temperature, "Timestamp": timestamp})

  }

}
