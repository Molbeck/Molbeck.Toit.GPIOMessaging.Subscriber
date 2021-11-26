import pubsub
import gpio_messaging
import serialization
import encoding.json
import gpio

topic ::= "cloud:Testing001"

main:
  message_validator := gpio_messaging.gpio_message_validator
  message_service := gpio_messaging.gpio_trigger_message_service
  pubsub.subscribe topic --blocking=false: | msg/pubsub.Message |
    sender := ?
    print "Message received. Will try to process it. Type: $msg.topic.type"
    try:
      serializer := gpio_messaging.GpioTriggerMessageSerializer
      gpiomessage := serializer.deserialize_bytearray msg.payload
      if not message_validator.is_valid gpiomessage:
        print "The given message is not valid. Message: $gpiomessage.stringify"
        return
      message_service.handle_gpio_message gpiomessage
    finally:
      msg.acknowledge