ruleset wovyn_base {

  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  rule process_heartbeat {
    select when wovyn heartbeat

    pre {
      attributes = event:attrs("genericThing").klog("attrs")
      temperature = attributes{"temperature"}
      timestamp = attributes{"timestamp"}
    }

    raise wovyn event "new_temperature_reading" attributes {
      "temperature" : temperature,
      "timestamp" : timestamp
    } if (event:attrs("genericThing" != null));

  }

  rule read_temperature {
    select when wovyn new_temperature_reading

    pre {
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
    }

    send_directive("print", {"Temperature": temperature, "Timestamp": timestamp})

  }

}
