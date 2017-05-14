int switchPin = 8;
int ledPin = 13;

void setup()
{
  pinMode(switchPin, INPUT);
  pinMode(ledPin, OUTPUT);
  
  Serial.begin(9600);

}

void loop()
{
  static boolean ledOn = false;
  static boolean buttonBuffer = false;
  static boolean state[3] = {0, 0 ,0};
  
  //Debounce Sequence
  state[0] = digitalRead(switchPin);
  Serial.write(state[0]? 'Y': 'N');
  delay(5);
  state[1] = digitalRead(switchPin);
  Serial.write(state[1]? 'Y': 'N');
  delay(5);
  state[2] = digitalRead(switchPin);
  Serial.write(state[2]? 'Y': 'N');
  Serial.println();
  
  //Posedge Detector
  boolean button = state[0] && state[1] && state[2]
  boolean temp = (buttonBuffer != button) && button;
  buttonBuffer = button;
  
  ledOn = ledOn != temp;
  
  digitalWrite(13, ledOn);
}
