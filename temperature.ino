#include <Arduino.h>
#include <DHTesp.h>
#include <ESP8266WiFi.h>
#include "FirebaseESP8266.h"

void InitFirebase(const String &host, const String &auth_key) {
  Firebase.begin(host, auth_key);
  Firebase.reconnectWiFi(true);
}

void InitWiFi(const String &ssid, const String &password) {
 WiFi.begin(ssid, password);
 while (WiFi.status() != WL_CONNECTED) delay(300);
 Serial.println("Connected with IP: " + WiFi.localIP().toString());
}

DHTesp dht;

void setup() {
  Serial.begin(115200);
  dht.setup(12, DHTesp::DHT22);
  pinMode(14, OUTPUT);
  InitWiFi("brosenan", "boazeladnoam");
  InitFirebase("brosenan-iot.firebaseio.com", "VzWe4d6w69z3z7YukXfszqdgafERqOUYRSbmo7VP");
}

FirebaseData data;
String path = "/brosenan/";

void loop() {
  TempAndHumidity temp_humidity = dht.getTempAndHumidity();
  if (!Firebase.setDouble(data, path + "indicator:Temperature", temp_humidity.temperature)) {
    Serial.println("Unable to write to database");
    delay(1000);
    return;
  }
  Firebase.setDouble(data, path + "indicator:Humidity", temp_humidity.humidity);
  bool onoff;
  if (!Firebase.getBool(data, path + "switch:Lights", onoff)) {
    Firebase.setBool(data, path + "switch:Lights", false);
  }
  digitalWrite(14, onoff ? HIGH : LOW);
  delay(1000);
}
