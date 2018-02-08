ruleset wovyn_base {

  meta {
    name "Lab 3 - Wovyn"
    author "Melanie Lambson"
    logging on

    use module twilio_keys
    use module lab2 alias twilio
        with account_sid = keys:twilio("account_sid")
             auth_token = keys:twilio("auth_token")
  }

  global {
    temperature_threshold = 80
    recipient = +13853099608
    sender = +15308028023
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
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading

    pre {
      temperature = event:attrs{"temperature"}
      message = (temperature > temperature_threshold) => "Temperature above threshold" | "Temperature normal"
    }

    send_directive("info", {"message": message.klog("message")})

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
    }

    twilio:send_sms(recipient,
                    sender,
                    message
                    )
  }

}
