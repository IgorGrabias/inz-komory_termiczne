#include <DHT11.h>

// Czujniki
DHT11 dht1(2);
DHT11 dht2(3);
DHT11 dht3(4);

// Mostek H
int pwmR = 7;
int pwmL = 8;
int rEn = 9;
int lEn = 10;

float setpoint = 35.00;

float delta = 0.3;
float deltaX = 0.5;

float delta1 = 0;
float delta2 = 0;

bool heating = true;
bool cooling = false; // na start grzejemy
float prevTavg = 0;

void setup() {
  Serial.begin(9600);

  pinMode(pwmR, OUTPUT);
  pinMode(pwmL, OUTPUT);
  pinMode(rEn, OUTPUT);
  pinMode(lEn, OUTPUT);

  // Wyłączone na starcie (zostanie zaraz załączone)
  digitalWrite(pwmR, LOW);
  digitalWrite(pwmL, LOW);
  analogWrite(rEn, 0);
  analogWrite(lEn, 0);

  Serial.println("t1,t2,t3,Tavg,h1,h2,h3,Havg,Status");
}

float before_peak = true;

void loop() {
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;

  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  if (result1 == 0 && result2 == 0 && result3 == 0) {
    float Tavg = (t1 + t2 + t3) / 3.0;
    float Havg = (h1 + h2 + h3) / 3.0;
    String status;
    //Logika on/off z chłodzeniem
    if (Tavg < prevTavg){
      before_peak = false;
    }
    if (Tavg == setpoint || (Tavg >= setpoint && before_peak == false)){
      heating = false;
      cooling = false;
      }
    else if (Tavg > setpoint + delta) {
      heating = false;
      cooling = true;
    }
    else if(Tavg < setpoint - delta){
      heating = true;
      cooling = false;
      before_peak = true;
    }
    
    /*
    // Logika przełączania
    if (heating) {
      if (Tavg >= setpoint - delta1 && prevTavg < setpoint - delta1) {
        heating = false;
      }
    } else {
      if (Tavg <= setpoint + delta2 && prevTavg > setpoint + delta2) {
        heating = true;
      }
    }*/

    // Sterowanie
    if (heating) {
      digitalWrite(pwmR, LOW);
      digitalWrite(pwmL, HIGH);
      analogWrite(rEn, 255);
      analogWrite(lEn, 255);
      status = "Heating";
    } else if (cooling) {
      digitalWrite(pwmR, HIGH);
      digitalWrite(pwmL, LOW);
      analogWrite(rEn, 255);
      analogWrite(lEn, 255);
      status = "Cooling";
    } else {
      digitalWrite(pwmR, LOW);
      digitalWrite(pwmL, LOW);
      analogWrite(rEn, 0);
      analogWrite(lEn, 0);
      status = "Idle";
    }

    prevTavg = Tavg;

    // Serial log
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
    Serial.println("Błąd odczytu z czujników!");
  }

  delay(2000);
}
