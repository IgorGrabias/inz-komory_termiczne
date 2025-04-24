#include <DHT11.h>

DHT11 dht1(2);
DHT11 dht2(3);
DHT11 dht3(4);

int pwmR = 7;
int pwmL = 8;
int rEn = 9;
int lEn = 10;

const float tempSetpoint = 50.0;    // Temperatura zadana
const float tolerance = 2.0;       // Histereza
const float tempMin = 19.0;
const float tempMax = 55.0;

bool initialized = false;
float tempAmbient = 0;
String mode = "";

void setup() {
  Serial.begin(9600);
  pinMode(pwmR, OUTPUT);
  pinMode(pwmL, OUTPUT);
  pinMode(rEn, OUTPUT);
  pinMode(lEn, OUTPUT);

  digitalWrite(pwmR, LOW);
  digitalWrite(pwmL, LOW);
  analogWrite(rEn, 0);
  analogWrite(lEn, 0);

  Serial.println("T1,T2,T3,Tavg,H1,H2,H3,Havg,Status");
}

void loop() {
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;

  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  if (result1 == 0 && result2 == 0 && result3 == 0) {
    float Tavg = (t1 + t2 + t3) / 3.0;
    float Havg = (h1 + h2 + h3) / 3.0;
    String status = "Idle";

    if (!initialized) {
      // Sprawdzenie zakresu temperatury zadanej
      if (tempSetpoint < tempMin || tempSetpoint > tempMax) {
        Serial.println("BŁĄD: Zadana temperatura poza dopuszczalnym zakresem.");
        while (true);  // Zatrzymanie programu
      }

      tempAmbient = Tavg;
      mode = (tempSetpoint > tempAmbient) ? "heating" : "cooling";
      initialized = true;
    }

    // Regulacja histerezowa
    if (mode == "heating") {
      if (Tavg < tempSetpoint - tolerance) {
        digitalWrite(pwmR, LOW);
        digitalWrite(pwmL, HIGH);
        analogWrite(rEn, 255);
        analogWrite(lEn, 255);
        status = "Heating";
      } else if (Tavg >= tempSetpoint - 1) {
        digitalWrite(pwmR, LOW);
        digitalWrite(pwmL, LOW);
        analogWrite(rEn, 0);
        analogWrite(lEn, 0);
        status = "Idle"; 
      } else if (digitalRead(pwmL) == HIGH){
        // Przekroczyło — wyłączamy
        status = "Heating";
      }
    } else if (mode == "cooling") {
      if (Tavg > tempSetpoint + tolerance) {
        digitalWrite(pwmR, HIGH);
        digitalWrite(pwmL, LOW);
        analogWrite(rEn, 0);
        analogWrite(lEn, 0);
        status = "Cooling";
      } else if (Tavg <= tempSetpoint) {
        digitalWrite(pwmR, LOW);
        digitalWrite(pwmL, LOW);
        analogWrite(rEn, 0);
        analogWrite(lEn, 0);
        status = "Idle";
      } else if (digitalRead(pwmR) == HIGH) {
        status = "Cooling";
      }
    }
    Serial.print(t1); Serial.print(",");
    Serial.print(t2); Serial.print(",");
    Serial.print(t3); Serial.print(",");
    Serial.print(Tavg); Serial.print(",");
    Serial.print(h1); Serial.print(",");
    Serial.print(h2); Serial.print(",");
    Serial.print(h3); Serial.print(",");
    Serial.print(Havg); Serial.print(",");
    Serial.println(status);
  } else {
    Serial.println("Błąd odczytu z czujników.");
  }

  delay(2000);
}

