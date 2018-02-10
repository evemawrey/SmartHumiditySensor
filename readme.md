# Smart Humidity Sensor

## What

The Smart Humidity Sensor is an ESP8266 programmed in Arduino with a DHT11 digital temperature and humidity sensor. Data collected about the room can be viewed on a [ThingSpeak Channel](https://thingspeak.com/channels/418058) that provides realtime information about the ideal humidity for the room.

## How

Using ThingSpeak, a scheduled MATLAB Analysis compares the data collected by the ESP8266 to the outside temperature to determine the comfort level of the room. A second ThingSpeak Analysis is used to trigger notifications when the room is deemed "uncomfortable" (i.e. too dry or too humid).

These notifications are sent through IFTTT using the Webhooks service. The push notification triggered by the Webhook can easily be swapped out for any IFTTT service, such as an IoT power plug powering a (de)humidifier.

There is a detailed writeup/tutorial on [Hackster](https://www.hackster.io/matlab-iot/thingspeak-matlab-and-ifttt-smart-humidity-sensor-1a8495). The guide covers setup and [Part 5](https://www.hackster.io/matlab-iot/thingspeak-matlab-and-ifttt-smart-humidity-sensor-1a8495#toc-part-5--how-it-works-4) of the story provides an overview of each of the three code snippets.

## Why

The project was done during my internship at MathWorks. The tutorial serves primarily as an example of the current IFTTT and ThingSpeak workflow. The project is also a simple example of condition monitioring, which is common application of IoT devices.