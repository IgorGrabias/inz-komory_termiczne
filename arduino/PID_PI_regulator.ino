#include <DHT11.h>

// Inicjalizacja czujników
DHT11 dht1(2);
DHT11 dht2(3);
DHT11 dht3(4);

// Mostek H
int pwmR = 7;
int pwmL = 8;
int rEn = 9;
int lEn = 10;


// Parametry PI 
float Kp = 4.8512; 
float Ki = 0.0394;  
float Kd = 0;     

/*
// Parametry PID 
float Kp = 6.4683; 
float Ki = 0.0789; 
float Kd = 132.6;     
*/

float setpoint = 50.0;
float integral = 0;
float lastError = 0;

unsigned long lastTime = 0;

void setup() {
  Serial.begin(9600);

  pinMode(pwmR, OUTPUT);
  pinMode(pwmL, OUTPUT);
  pinMode(rEn, OUTPUT);
  pinMode(lEn, OUTPUT);

  // Wyłączenie mostka na start
  digitalWrite(pwmR, LOW);
  digitalWrite(pwmL, LOW);
  analogWrite(rEn, 0);
  analogWrite(lEn, 0);

  // Inicjalizacja czasu
  lastTime = millis();

  Serial.println("t1,t2,t3,Tavg,h1,h2,h3,Havg,PID_raw,PWM");
}

void loop() {
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;

  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  delay(2000);

  if (result1 == 0 && result2 == 0 && result3 == 0) {
    float Tavg = (t1 + t2 + t3) / 3.0;
    float Havg = (h1 + h2 + h3) / 3.0;

    float error = setpoint - Tavg;

    unsigned long currentTime = millis();
    float deltaTime = (currentTime - lastTime) / 1000.0;
    if (deltaTime <= 0) return;
    lastTime = currentTime;

    float derivative = (error - lastError) / deltaTime;
    float tentativeIntegral = integral + error * deltaTime;

    float P = Kp * error;
    float I = Ki * tentativeIntegral;
    // Wstępna wartość PID
    float rawOutput = Kp * error + Ki * tentativeIntegral + Kd * derivative;
    lastError = error;
    // Ograniczenie wartości wyjścia

    float output = constrain(rawOutput, 0, 255);

    // Anti-windup: aktualizacja całki tylko jeśli nie nasycamy
    if (output == rawOutput) {
     integral = tentativeIntegral;
    }




    // Grzanie
    digitalWrite(pwmR, LOW);
    digitalWrite(pwmL, HIGH);
    analogWrite(rEn, (int)output);
    analogWrite(lEn, (int)output);


    // Serial log
    Serial.print(t1); Serial.print(",");
    Serial.print(t2); Serial.print(",");
    Serial.print(t3); Serial.print(",");
    Serial.print(Tavg); Serial.print(",");
    Serial.print(h1); Serial.print(",");
    Serial.print(h2); Serial.print(",");
    Serial.print(h3); Serial.print(",");
    Serial.print(Havg); Serial.print(",");
    Serial.print(rawOutput); Serial.print(",");
    Serial.println((int)output);
  } else {
    Serial.println("Błąd odczytu z czujników!");
  }

  
}
