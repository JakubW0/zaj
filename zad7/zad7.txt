include <avr/io.h>
 
 
//void main(void) __attribute__((noreturn))
 
uint8_t DIGITS[10]={0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F};
 
void DisplayDigit(uint8_t value, uint8_t miejsce)
{
    PORTB=(1<<miejsce);// POZYCJA A NIE WARTOSC
   
    uint8_t tmp=0xFF;
   
    if (value<10)
        tmp=DIGITS[value];
   
    PORTA=tmp;
}
 
void Keyboard(void)
{
    uint8_t x;
    uint8_t y=0;
 
    while (y<4)
    {
        x=PORTC;
        x=(x | 0xF0) ^ (1<<(y+5));
        PORTC=x;
        asm volatile("nop");
        x=PINC|PIND;
        if ((x&0xCC) != 0xCC)
        {
            if ((x&0x80)==0)
                x=0;
            else if ((x&0x40)==0)
                x=1;
            else if ((x&0x04)==0)
                x=2;
            else
                x=3;
            x=x+y*4;
            DisplayDigit(x,~y);
        }
        y++;
    }
}  
       
 
int main(void)
{
    DDRB=0xFF;
    DDRA=0xFF;
    DDRD=0xC0;
    DDRC=0xFC; 
    PORTD=0xC0;
    PORTC=0xFC;
   
   
    for (uint8_t i=0; i <10; i++)
        DIGITS[i]=~DIGITS[i];
 
    uint8_t key;
 
    while (1)
    {
        Keyboard();    
    }
    return 0;
}