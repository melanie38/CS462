ruleset wovyn_base {

  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on
  }

  global {
    temperature_threshold = 70
  }

  rule process_heartbeat {
    select when wovyn heartbeat where event:attrs{"genericThing"} != null

      pre {
        attributes = event:attrs{["genericThing", "data", "temperature"]}.klog("attrs")
        tempArray = attributes[0].klog("tempArray")
        temperature = tempArray{"temperatureF"}.klog("temperatureF")
        timestamp = time:now().klog("time")
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
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
    }

    send_directive("print", {"Temperature": temperature, "Timestamp": timestamp})

  }

  rule find_high_temps {
    select when wovyn new_temperature_reading

    pre {
      temperature = event:attr{"temperature"}
      message = (temperature > temperature_threshold) => "Temperature above threshold" | "Temperature normal"
    }

    send_directive("info", {"message": message.klog("message")})

    fired {
      raise wovyn event "threshold_violation" attributes {
        "temperature" : temperature,
        "timestamp" : timestamp
      };
    }
  }

}
