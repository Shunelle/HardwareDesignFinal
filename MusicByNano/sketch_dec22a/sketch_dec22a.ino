#define PIN_INIT 2  // FPGA 的第一個輸出 pin 連接到 D2
#define PIN_GAME 3  // FPGA 的第二個輸出 pin 連接到 D3
#define PIN_WIN  4  // FPGA 的第三個輸出 pin 連接到 D4
#define PIN_LOSE 5  // FPGA 的第四個輸出 pin 連接到 D5

void setup() {
  pinMode(PIN_INIT, INPUT);
  pinMode(PIN_GAME, INPUT);
  pinMode(PIN_WIN, INPUT);
  pinMode(PIN_LOSE, INPUT);

  Serial.begin(9600);  // 初始化 Serial 通訊
}

void loop() {
  int signal = 0;

  if (digitalRead(PIN_INIT) == HIGH) signal = 8;  // 1000 -> 8
  else if (digitalRead(PIN_GAME) == HIGH) signal = 4;  // 0100 -> 4
  else if (digitalRead(PIN_WIN) == HIGH) signal = 2;  // 0010 -> 2
  else if (digitalRead(PIN_LOSE) == HIGH) signal = 1;  // 0001 -> 1

  if (signal > 0) {
    Serial.println(signal);  // 傳送訊號給電腦
    delay(1000);  // 延遲避免過多訊號重複
  }
}
