#include <SoftwareSerial.h>
#include <Servo.h>
#include <ArduinoJson.h>

SoftwareSerial hc06(2, 3);
Servo baseMotor;
Servo pinceMotor;
Servo leftMotor;
Servo rightMotor;
//{"base":180,"pince":180,"left":180,"right":180}
void setup() {
  // Initialize Serial Monitor
  Serial.begin(9600);
  Serial.println("ENTER AT Commands:");
  
  // Initialize Bluetooth Serial Port
  hc06.begin(9600);

  // Initialize Servo Motors
  baseMotor.attach(9);    // Assuming base motor is connected to pin 9
  pinceMotor.attach(10); // Assuming pince motor is connected to pin 10
  leftMotor.attach(11); // Assuming left motor is connected to pin 11
  rightMotor.attach(12);// Assuming right motor is connected to pin 12
}

void loop() {
  // Write data from HC06 to Serial Monitor
  if (hc06.available()) {
    String jsonString = hc06.readStringUntil('\n');

    // Parse JSON
    DynamicJsonDocument doc(200);
    DeserializationError error = deserializeJson(doc, jsonString);

    if (error) {
      Serial.print("JSON parsing failed! ");
      Serial.println(error.c_str());
      return;
    }

    // Control Servo Motors based on JSON values
    int baseAngle = doc["base"];
    int pinceAngle = doc["pince"];
    int leftAngle = doc["left"];
    int rightAngle = doc["right"];

    baseMotor.write(constrain(baseAngle, 0, 180));
    pinceMotor.write(constrain(pinceAngle, 0, 180));
    leftMotor.write(constrain(leftAngle, 0, 180));
    rightMotor.write(constrain(rightAngle, 0, 180));

    Serial.println("Servo Motors controlled - Base:" + String(baseAngle) + ", Pince:" + String(pinceAngle) + ", Left:" + String(leftAngle) + ", Right:" + String(rightAngle));
  }
}