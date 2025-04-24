#include <DHT11.h>


// Inicjalizacja trzech czujników
DHT11 dht1(2);
DHT11 dht2(3);
DHT11 dht3(4);

// Definicja pinów sterujących mostkiem H
int pwmR = 7;  // PWM - grzanie
int pwmL = 8;  // PWM - chłodzenie
int rEn = 9;   // Sterowanie kierunkiem grzanie
int lEn = 10;  // Sterowanie kierunkiem chłodzenie

void setup() {
  Serial.begin(9600); // Uruchomienie komunikacji szeregowej

  // Ustawienie pinów jako wyjścia
  pinMode(pwmR, OUTPUT);
  pinMode(pwmL, OUTPUT);
  pinMode(rEn, OUTPUT);
  pinMode(lEn, OUTPUT);

  // Wyłączenie mostka na starcie
  digitalWrite(pwmR, LOW);
  digitalWrite(pwmL, LOW);
  analogWrite(rEn, 0);
  analogWrite(lEn, 0);

  // Nagłówki CSV
  Serial.println("t1,t2,t3,Tavg,h1,h2,h3,Havg,Status");
}

void loop() {
  int t1 = 0, t2 = 0, t3 = 0;
  int h1 = 0, h2 = 0, h3 = 0;
  String status = "";

  // Odczyt temperatury i wilgotności z trzech czujników
  int result1 = dht1.readTemperatureHumidity(t1, h1);
  int result2 = dht2.readTemperatureHumidity(t2, h2);
  int result3 = dht3.readTemperatureHumidity(t3, h3);

  // Sprawdzenie poprawności pomiarów
  if (result1 == 0 && result2 == 0 && result3 == 0) {
    // Obliczanie uśrednionej temperatury i wilgotności
    float Tavg = (t1 + t2 + t3) / 3.0;
    float Havg = (h1 + h2 + h3) / 3.0;

    // Decyzja o grzaniu lub chłodzeniu na podstawie średniej temperatury
    if (Tavg < 40) {
      // Włącz grzanie
      digitalWrite(pwmR, HIGH);
      digitalWrite(pwmL, LOW);
      analogWrite(rEn, 255); // 100% mocy grzania
      analogWrite(lEn, 255);
      status = "Heating";
    } else if (Tavg > 10) {
      // Włącz chłodzenie
      digitalWrite(pwmR, LOW);
      digitalWrite(pwmL, HIGH);
      analogWrite(rEn, 255);
      analogWrite(lEn, 255); // 100% mocy chłodzenia
      status = "Cooling";
    } else {
      // Tryb spoczynku
      digitalWrite(pwmR, LOW);
      digitalWrite(pwmL, LOW);
      analogWrite(rEn, 0);
      analogWrite(lEn, 0);
      status = "Idle";
    }

    // Wyślij dane w formacie CSV przez port szeregowy
    Serial.print(t1);
    Serial.print(",");
    Serial.print(t2);
    Serial.print(",");
    Serial.print(t3);
    Serial.print(",");
    Serial.print(Tavg);
    Serial.print(",");
    Serial.print(h1);
    Serial.print(",");
    Serial.print(h2);
    Serial.print(",");
    Serial.print(h3);
    Serial.print(",");
    Serial.print(Havg);
    Serial.print(",");
    Serial.println(status);
  } else {
    Serial.println("Błąd odczytu z jednego lub więcej czujników!");
  }

  delay(2000); // Odczyt temperatury co 2 sekundy
}
