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
float Kp = 25 ;
float Ki = 0.2;  // Startowa wartość Ki
float Kd = 0;

float setpoint = 35.0;
float integral = 0;
float lastError = 0;

unsigned long lastTime = 0;
unsigned long testStartTime = 0;

int currentTest = 1;
const int maxTests = 10;  // Ile testów chcesz wykonać
const unsigned long testDuration = 3000UL * 1000; // sekund w milisekundach

bool coolingPhase = false;

void setup() {
  Serial.begin(9600);

  pinMode(pwmR, OUTPUT);
  pinMode(pwmL, OUTPUT);
  pinMode(rEn, OUTPUT);
  pinMode(lEn, OUTPUT);

  stopHeating();

  lastTime = millis();
  testStartTime = millis();

  Serial.println("test,Kp,Ki,t1,t2,t3,Tavg,h1,h2,h3,Havg,PID_raw,PWM");
}

void loop() {
  // Odczyt czujników
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;

  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  delay(2000); // Odstęp między próbkami

  if (result1 != 0 || result2 != 0 || result3 != 0) {
    Serial.println("Błąd odczytu z czujników!");
    return;
  }

  float Tavg = (t1 + t2 + t3) / 3.0;
  float Havg = (h1 + h2 + h3) / 3.0;

  unsigned long currentTime = millis();
  float deltaTime = (currentTime - lastTime) / 1000.0;
  if (deltaTime <= 0) return;
  lastTime = currentTime;

  if (!coolingPhase) {
    // === FAZA TESTU ===
    float error = setpoint - Tavg;
    float derivative = (error - lastError) / deltaTime;
    float tentativeIntegral = integral + error * deltaTime;

    float rawOutput = Kp * error + Ki * tentativeIntegral + Kd * derivative;
    float output = constrain(rawOutput, 0, 255);
    if (output == rawOutput) {
      integral = tentativeIntegral;
    }
    lastError = error;

    // Grzanie
    digitalWrite(pwmR, LOW);
    digitalWrite(pwmL, HIGH);
    analogWrite(rEn, (int)output);
    analogWrite(lEn, (int)output);

    // Zapis danych
    Serial.print(currentTest); Serial.print(",");
    Serial.print(Kp); Serial.print(",");
    Serial.print(Ki); Serial.print(",");
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

    // Sprawdzenie zakończenia testu
    if (currentTime - testStartTime >= testDuration) {
      coolingPhase = true;
      stopHeating();
    }

  } else {
    // === FAZA CHŁODZENIA ===
    stopHeating();
    if (Tavg <= 24) {
      // Przejdź do kolejnego testu
      currentTest++;
      if (currentTest > maxTests) {
        Serial.println("Wszystkie testy zakończone.");
        while (true); // zatrzymanie programu
      }

      // Reset regulatora
      Ki -= 0.02;
      integral = 0;
      lastError = 0;
      testStartTime = millis();
      coolingPhase = false;
    }
  }
}

void stopHeating() {
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;

  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  delay(2000); // Odstęp między próbkami

  if (result1 != 0 || result2 != 0 || result3 != 0) {
    Serial.println("Błąd odczytu z czujników!");
    return;
  }

  float Tavg = (t1 + t2 + t3) / 3.0;
  
  digitalWrite(pwmR, HIGH);
  digitalWrite(pwmL, LOW);
  analogWrite(rEn, 255);
  analogWrite(lEn, 255);

  Serial.println(Tavg);
}
