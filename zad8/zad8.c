#include <avr/io.h>
#include <util/delay.h>
#include "HD44780.h"
#include <string.h>


char space = ' ';

char table [1] = { 'J' , 'D'};


uint8_t keyPressed()
{ 
uint8_t y=0;
uint8_t x;
 while (y<4)
    {
        x=PORTC;
        x=(x | 0xF0) ^ (1<<(y+5));
        PORTC=x;
        _delay_ms(10);
        x=PINC|PIND;
        if ((x&0xCC) != 0xCC)
        {
         return 1;
        }
        y++;
}
 return 0;
}

void indexJD(uint8_t i){
 LCD_GoTo(i+1,0); //jd
		LCD_WriteData(table[0]);

		LCD_GoTo(i+2,0); //jd
		LCD_WriteData(table[1]);
}

void indexSpace(uint8_t i){
        LCD_GoTo(i,0);//spacje
		LCD_WriteData(space);
}

void writeJD() {
     int i ;
for(i=0; i<14; i++) {
      indexSpace(i);
      indexJD(i);
       if( i==13 ){
         while(KeyPressed()==0){
          continue;
           }
            for( int j = 13; j<2; j--) {
             indexSpace(i);
             indexJD(i);
             indexSpace(i-2);
		     if( i==1 ){
               while(KeyPressed()==0){
                continue;
                   }
 i=0;
    }
  }    
 }
	_delay_ms(100);
}

int main()
{
	DDRA=0xFF;
	PORTA=0x00;
	DDRB=0xFF;
	PORTB=0x0E;

//DDRB = 0x0f;
//PORTB = 0x0e;

	DDRC = 0xf0;
	PORTC = 0xff;
	DDRD = 0x3f;
	PORTD = 0xc0;

	LCD_Initalize();

	LCD_Home();

   while(1){
                  writeJD();
}