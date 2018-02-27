ruleset wovyn_base {

  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on

    use module twilio_keys
    use module lab2 alias twilio
        with account_sid = keys:twilio("account_sid")
             auth_token = keys:twilio("auth_token")
    use module temperature_store alias store
  }

  global {
    temperature_threshold = 80
    recipient = store:phone()
    sender = +15308028023
  }

  rule process_heartbeat {
    select when wovyn heartbeat where event:attrs{"genericThing"} != null

      pre {
        attributes = event:attrs{["genericThing", "data", "temperature"]}
        tempArray = attributes[0]
        temperature = tempArray{"temperatureF"}
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
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading

    pre {
      temperature = event:attrs{"temperature"}
      timestamp = event:attrs{"timestamp"}
      message = (temperature > temperature_threshold) => "Temperature above threshold" | "Temperature normal"
    }

    fired {
      raise wovyn event "threshold_violation" attributes {
        "temperature" : temperature,
        "timestamp" : timestamp
      } if (temperature > temperature_threshold);
    }
  }

  rule threshold_notification {
    select when wovyn threshold_violation

    pre {
      message = "The temperature (" + event:attrs{"temperature"} + ") " + "detected at " + event:attrs{"timestamp"} + " is above the threshold."
      recipient = store:phone()
    }

    twilio:send_sms("+" + recipient.klog("Phone number: "),
                    sender,
                    message
                    )
  }

  rule display {
    select when wovyn display_results

    always {
      temperatures = store:temperatures().klog("all temperatures");
      violations = store:threshold_violations().klog("out of range temperatures");
      inrange = store:inrange_temperatures().klog("in range temperatures");
    }
  }

}
