
/* Analog and Digital Input and Output Server for MATLAB     */
/* Giampiero Campa, Copyright 2013 The MathWorks, Inc        */

/* This file is meant to be used with the MATLAB arduino IO 
   package, however, it can be used from the IDE environment
   (or any other serial terminal) by typing commands like:
   
   0e0 : assigns digital pin #4 (e) as input
   0f1 : assigns digital pin #5 (f) as output
   0n1 : assigns digital pin #13 (n) as output   
   
   1c  : reads digital pin #2 (c) 
   1e  : reads digital pin #4 (e) 
   2n0 : sets digital pin #13 (n) low
   2n1 : sets digital pin #13 (n) high
   2f1 : sets digital pin #5 (f) high
   2f0 : sets digital pin #5 (f) low
   4j2 : sets digital pin #9 (j) to  50=ascii(2) over 255
   4jz : sets digital pin #9 (j) to 122=ascii(z) over 255
   3a  : reads analog pin #0 (a) 
   3f  : reads analog pin #5 (f) 

   R0    : sets analog reference to DEFAULT
   R1    : sets analog reference to INTERNAL
   R2    : sets analog reference to EXTERNAL
  
   X3    : roundtrip example case returning the input (ascii(3)) 
   99    : returns script type (0 adio.pde ... 3 motor.pde ) */
   
/* define internal for the MEGA as 1.1V (as as for the 328)  */
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#define INTERNAL INTERNAL1V1
#endif

/* 2D Stepper Motor Pulsed Spectrometer
 * 
 * Drives two stepper motors for a two-dimensional reach.
 * Also sends pulses to spectrometer for data collection,
 * spectrometer = Avaspec-3648
 *
 * Authors:
 * - Alex Beaman
 * - Samuel Cooper
 */

int xDirectPin = 7;   // pin # for x direction.
int zDirectPin = 9;   // pin # for z direction.
int xMotor = 6;  // pin # for x-axis motor.
int zMotor = 8;  // pin # for z-axis motor.
int xSteps = 0;  // # Steps to move in x-axis.
int zSteps = 0;  // # Steps to move in z-axis.
// 0 = 0th interrupt, but on pin 2.
// 1 = 1st interrupt, but on pin 3. [didn't work until using correct circuit - pull up resistors and such.
int limitSwitchWhite = 0;   //We will be using this pin for the limit switch motor stop function.  
int limitSwitchBlue = 1;
int trigger = 13;       //This pin will be used to trigger the spectrometer. 
int xDirectVar = 0;    // 0 = left, 1 = right.
int zDirectVar = 1;    // 1 = left, 0 = right.

int xDataPoints = 0;   // Defaults to 2 for testing.
int zScans = 0;        // Defaults to 2 for testing.

int DriverDelay = 10;
int SpectrumDelay = 100;

String varSet;
boolean varReady = false;

volatile boolean systemOkay = true; // volatile means variable could change at any moment.


void setup() {
  // Direction pins:
  pinMode(xDirectPin,OUTPUT);
  pinMode(zDirectPin,OUTPUT);
  // Stepper motor pins:
  pinMode(xMotor,OUTPUT);
  pinMode(zMotor,OUTPUT);
  // Interrupts for limit switches:
  //attachInterrupt(limitSwitchBlue, closeLimitHit, FALLING);
  //attachInterrupt(limitSwitchWhite, farLimitHit, FALLING);
  // Spectrometer pin:
  pinMode(trigger,OUTPUT);
  digitalWrite(trigger,LOW);
  delay(1000);
  
  /* initialize serial                                       */
  Serial.begin(115200);
}

void loop() {
  
  /* variables declaration and initialization                */
  
  static int  s   = -1;    /* state                          */
  static int  pin = 13;    /* generic pin number             */
 
  int  val =  0;           /* generic value read from serial */
  int  agv =  0;           /* generic analog value           */
  int  dgv =  0;           /* generic digital value          */


  /* The following instruction constantly checks if anything 
     is available on the serial port. Nothing gets executed in
     the loop if nothing is available to be read, but as soon 
     as anything becomes available, then the part coded after 
     the if statement (that is the real stuff) gets executed */

  if (Serial.available() >0) {

    /* whatever is available from the serial is read here    */
    val = Serial.read();
    
    /* This part basically implements a state machine that 
       reads the serial port and makes just one transition 
       to a new state, depending on both the previous state 
       and the command that is read from the serial port. 
       Some commands need additional inputs from the serial 
       port, so they need 2 or 3 state transitions (each one
       happening as soon as anything new is available from 
       the serial port) to be fully executed. After a command 
       is fully executed the state returns to its initial 
       value s=-1                                            */

    switch (s) {

      /* s=-1 means NOTHING RECEIVED YET ******************* */
      case -1:      

      /* calculate next state                                */
      if (val>47 && val<90) {
	  /* the first received value indicates the mode       
           49 is ascii for 1, ... 90 is ascii for Z          
           s=0 is change-pin mode;
           s=10 is DI;  s=20 is DO;  s=30 is AI;  s=40 is AO; 
           s=90 is query script type (1 basic, 2 motor);
           s=340 is change analog reference;
           s=400 example echo returning the input argument;
                                                             */
        s=10*(val-48);
      }
      
      /* the following statements are needed to handle 
         unexpected first values coming from the serial (if 
         the value is unrecognized then it defaults to s=-1) */
      if ((s>40 && s<90) || (s>90 && s!=340 && s!=400)) {
        s=-1;
      }

      /* the break statements gets out of the switch-case, so
      /* we go back and wait for new serial data             */
      break; /* s=-1 (initial state) taken care of           */


     
      /* s=0 or 1 means CHANGE PIN MODE                      */
      
      case 0:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('¦')=166, pin 69    */
      if (val>98 && val<167) {
        pin=val-97;                /* calculate pin          */
        s=1; /* next we will need to get 0 or 1 from serial  */
      } 
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=0 taken care of                            */


      case 1:
      /* the third received value indicates the value 0 or 1 */
      if (val>47 && val<50) {
        /* set pin mode                                      */
        if (val==48) {
          pinMode(pin,INPUT);
        }
        else {
          pinMode(pin,OUTPUT);
        }
      }
      s=-1;  /* we are done with CHANGE PIN so go to -1      */
      break; /* s=1 taken care of                            */
      


      /* s=10 means DIGITAL INPUT ************************** */
      
      case 10:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('¦')=166, pin 69    */
      if (val>98 && val<167) {
        pin=val-97;                /* calculate pin          */
        dgv=digitalRead(pin);      /* perform Digital Input  */
        Serial.println(dgv);       /* send value via serial  */
      }
      s=-1;  /* we are done with DI so next state is -1      */
      break; /* s=10 taken care of                           */

      

      /* s=20 or 21 means DIGITAL OUTPUT ******************* */
      
      case 20:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('¦')=166, pin 69    */
      if (val>98 && val<167) {
        pin=val-97;                /* calculate pin          */
        s=21; /* next we will need to get 0 or 1 from serial */
      } 
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=20 taken care of                           */

      case 21:
      /* the third received value indicates the value 0 or 1 */
      if (val>47 && val<50) {
        dgv=val-48;                /* calculate value        */
	digitalWrite(pin,dgv);     /* perform Digital Output */
      }
      s=-1;  /* we are done with DO so next state is -1      */
      break; /* s=21 taken care of                           */


	
      /* s=30 means ANALOG INPUT *************************** */
      
      case 30:
      /* the second received value indicates the pin 
         from abs('a')=97, pin 0, to abs('p')=112, pin 15    */
      if (val>96 && val<113) {
        pin=val-97;                /* calculate pin          */
        agv=analogRead(pin);       /* perform Analog Input   */
	Serial.println(agv);       /* send value via serial  */
      }
      s=-1;  /* we are done with AI so next state is -1      */
      break; /* s=30 taken care of                           */



      /* s=40 or 41 means ANALOG OUTPUT ******************** */
      
      case 40:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('¦')=166, pin 69    */
      if (val>98 && val<167) {
        pin=val-97;                /* calculate pin          */
        s=41; /* next we will need to get value from serial  */
      }
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=40 taken care of                           */


      case 41:
      /* the third received value indicates the analog value */
      analogWrite(pin,val);        /* perform Analog Output  */
      s=-1;  /* we are done with AO so next state is -1      */
      break; /* s=41 taken care of                           */
      
      
      
      /* s=90 means Query Script Type: 
         (0 adio, 1 adioenc, 2 adiosrv, 3 motor)             */
      
      case 90:
      if (val==57) { 
        /* if string sent is 99  send script type via serial */
        Serial.println(0);
      }
      s=-1;  /* we are done with this so next state is -1    */
      break; /* s=90 taken care of                           */



      /* s=340 or 341 means ANALOG REFERENCE *************** */
      
      case 340:
      /* the second received value indicates the reference,
         which is encoded as is 0,1,2 for DEFAULT, INTERNAL  
         and EXTERNAL, respectively. Note that this function 
         is ignored for boards not featuring AVR or PIC32    */
         
#if defined(__AVR__) || defined(__PIC32MX__)

      switch (val) {
        
        case 48:
        analogReference(DEFAULT);
        break;        
        
        case 49:
        analogReference(INTERNAL);
        break;        
                
        case 50:
        analogReference(EXTERNAL);
        break;        
        
        default:                 /* unrecognized, no action  */
        break;
      } 

#endif

      s=-1;  /* we are done with this so next state is -1    */
      break; /* s=341 taken care of                          */



      /* s=400 roundtrip example function (returns the input)*/
      
      case 400:
      /* the second value (val) can really be anything here  */
      
      Serial.println(val); /* Must be here to tell MATLAB
                                the roundTrip worked         */
                                
      // boolean varReady begins FALSE.
      if (varReady) {
        moveMotor(1, xDirectPin, 25, xMotor);
        setVal(val);
        varReady = false;
      } else {
        if (val >= 11 && val <= 18) {     // setting variables
          varReady = true;
          switch (val) {
            case 11:
              varSet = "xSteps";
              break;
            case 12:
              varSet = "xDirectVar";
              break;
            case 13:
              varSet = "xDataPoints";
              break;
            case 14:
              varSet = "zSteps";
              break;
            case 15:
              varSet = "zDirectVar";
              break;
            case 16:
              varSet = "zScans";
              break;
            case 17:
              varSet = "SpectrumDelay";
              break;
            case 18:
              varSet = "DriverDelay";
              break;
            default:
              // this should never hit since ever case is accounted for,
              //   but just in case, we make sure nothing weird happens.
              varReady = false;
              break;
          }
        } else {
          switch (val) {
            case 21:
              ExecuteMeasurement();
              break;
            case 22: // take spectrum at current location.
              specTrigger();
              break;
            case 23:
              RunXMeasurement();
              break;
            case 24:
              RunZMeasurement();
              break;
            case 25:
              varSet = "addXSteps";
              varReady = true;
              break;
            case 26:
              varSet = "addZSteps";
              varReady = true;
              break;
            case 42:
              moveMotor(xDirectVar,xDirectPin,xSteps,xMotor);
              break;
            default:
              break;
          }
        }
      }
      
      s=-1;  /* we are done with the aux function so -1      */
      break; /* s=400 taken care of                          */

      /* ******* UNRECOGNIZED STATE, go back to s=-1 ******* */
      
      default:
      /* we should never get here but if we do it means we 
         are in an unexpected state so whatever is the second 
         received value we get out of here and back to s=-1  */
      
      s=-1;  /* go back to the initial state, break unneeded */



    } /* end switch on state s                               */

  } /* end if serial available                               */
  
} /* end loop statement                                      */

// Functions from our old test arduino program:

void setVal(byte val) {
  // Create character array with enough space to fit String varSet:
  // - not sure why, but getting rid of the +1 made strcmp NOT WORK!!
  char charBuff[varSet.length()+1];
  // Push characters of String varSet into array charBuff:
  varSet.toCharArray(charBuff, varSet.length()+1);
  // Compare char array charBuff with variable names:
  if (strcmp(charBuff, "zSteps") == 0) {
    zSteps = val;
  } else if (strcmp(charBuff, "xSteps") == 0) {
    xSteps = val;
  } else if (strcmp(charBuff, "zDirectVar") == 0) {
    zDirectVar = val;
  } else if (strcmp(charBuff, "xDirectVar") == 0) {
    xDirectVar = val;
  } else if (strcmp(charBuff, "zScans") == 0) {
    zScans = val;
  } else if (strcmp(charBuff, "xDataPoints") == 0) {
    xDataPoints = val;
  } else if (strcmp(charBuff, "DriverDelay") == 0) {
    DriverDelay = val;
  } else if (strcmp(charBuff, "SpectrumDelay") == 0) {
    SpectrumDelay = val;
  } else if (strcmp(charBuff, "addXSteps") == 0) {
    xSteps += val;
  } else if (strcmp(charBuff, "addZSteps") == 0) {
    zSteps += val;
  }
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  EXECUTE CODE
   
  This function sets up the 2D scan & spectrometer triggering.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void ExecuteMeasurement() {
  for (int i = zScans; i > 0; i--) {
    for (int j = xDataPoints; j > 0; j--) {
      moveMotor(xDirectVar,xDirectPin,xSteps,xMotor);
      specTrigger();
    }
    
    returnMotor(xDirectVar,xDirectPin,xSteps,xDataPoints,xMotor);
    moveMotor(zDirectVar,zDirectPin,zSteps,zMotor);
  }
  
  returnMotor(zDirectVar,zDirectPin,zSteps,zScans,zMotor);
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  RUNS MEASUREMENT IN Z AXIS ONLY
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void RunZMeasurement() {
  for (int i = zScans; i > 0; i--) {
    moveMotor(zDirectVar,zDirectPin,zSteps,zMotor);
    specTrigger();
  }
  returnMotor(zDirectVar,zDirectPin,zSteps,zScans,zMotor);
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  RUNS MEASUREMENT IN X AXIS ONLY
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void RunXMeasurement() {
  for (int j = xDataPoints; j > 0; j--) {
    moveMotor(xDirectVar,xDirectPin,xSteps,xMotor);
    specTrigger();
  }

  returnMotor(xDirectVar,xDirectPin,xSteps,xDataPoints,xMotor);
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 MOVE MOTOR
 
 This function is what pulses the motor drivers to make the motors step.
 Arguments:
 dir         = the direction to move,
 dirPin      = pin to set direction on,
 numSteps    = the number of steps to take,
 motorChoice = which motor we are moving (x or z motor). 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void moveMotor(int dir, int dirPin, int numSteps, int motorChoice) {
  digitalWrite(dirPin,dir);
  delay(DriverDelay);
  for (int i = numSteps; i > 0; i--) {
    if (systemOkay) { // systemOkay is the variable to make sure the motor is not going to hit and end.
      digitalWrite(motorChoice,HIGH);
      delay(DriverDelay);
      digitalWrite(motorChoice,LOW);
      delay(DriverDelay);
    }
  }
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 SPECTROMETER TRIGGER
 
 The following function creates the trigger pulse to the spectrometer.
 A pulse will be sent out after every call to the function.
 Delays should be used to give spectrometer time to take data.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void specTrigger() {
  delay(SpectrumDelay);
  if (systemOkay) {
    digitalWrite(trigger,HIGH);
    delay(SpectrumDelay);                  
    digitalWrite(trigger,LOW);
    delay(SpectrumDelay);
  }
}

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 RETURN MOTOR
 
 Returns the motor the the previous position before measurements were taken.
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
void returnMotor(int dir,int dirPin, int stepNumber, int dataPoints, int motorChoice) {
  int stepLength = stepNumber * dataPoints;
  int newDir = !dir; // reverse direction of motor.
  moveMotor(newDir,dirPin,stepLength,motorChoice);
}

/*void closeLimitHit() {
  systemOkay = false;
  Serial.println("\n\n========Close Limit Hit!!!!!!!==========\n\n");
}

void farLimitHit() {
  systemOkay = false;
  Serial.println("\n\n========Far Limit Hit!!!!!!!==========\n\n");
}*/

