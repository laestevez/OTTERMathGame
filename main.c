////////////////////////////////////////////////////////////////////
///////
/////   Got VGA code from peripherals
/////   Modified by Luis, Audrey and Ryan
/////
/////////////////////////////////////////////////////////////////

#include <stdlib.h>

//establish colors
const int WHITE = 0xFF;
const int BLACK = 0x00;
const int RED = 0xE0;
const int GREEN = 0x1C;
const int BLUE = 0x03;
const int YELLOW = 0xFC;
const int PURPLE = 0x82;
const int ORANGE = 0xF4;

const int BG_COLOR = BLACK;  //set background to black
volatile int * const VG_ADDR = (int *)0x11100000;
volatile int * const VG_COLOR = (int *)0x11140000;

//establish functions
static void draw_horizontal_line(int X, int Y, int toX, int color);
static void draw_vertical_line(int X, int Y, int toY, int color);
static void draw_background();
static void draw_dot(int X, int Y, int color);
static void draw_plus(int X, int Y, int color);
static void draw_minus(int X, int Y, int color);
static void draw_mult(int X, int Y, int color);
static void draw_number(int X, int Y, int color, int num);
char pickOperator();
int * generateQuestion(char operator);
int _rand(int Max);



void main() {
    // fill screen
    draw_background();
    // test all
    int *n;
    int i;
    int temp;
    int button1 = 1;
    int button2 = 0;
    int button3 = 0;
    int num;

    char operator = pickOperator();
    n = generateQuestion(operator);
    for(i = 0; i < 7; i++){
        num = *(n + i);
        if(i == 0){
            draw_number(19,8,PURPLE, num);
        }
        if(i == 1){
            draw_number(26,8,PURPLE, num);
        }
        if(i == 2){
            draw_number(48,8,PURPLE, num);
        }
        if(i == 3){
            draw_number(55,8,PURPLE, num);
        }
        if(i == 4){
            if(num > 9){
                temp = num % 10;
                draw_number(16,40,YELLOW, temp); // second digit
                num = num / 10;
                draw_number(9,40,YELLOW, num); //first digit
            }else{
                draw_number(16,40,YELLOW, num); // second digit
                draw_number(9,40,YELLOW, 0); //first digit
            }
        }
        if(i == 5){
            if(num > 9){
                temp = num % 10;
                draw_number(40,40,YELLOW, temp); // second digit
                num = num / 10;
                draw_number(33,40,YELLOW, num); //first digit
            }else{
                draw_number(40,40,YELLOW, num); // second digit
                draw_number(33,40,YELLOW, 0); //first digit
            }
        }
        if(i == 6){
            if(num > 9){
                temp = num % 10;
                draw_number(64,40,YELLOW, temp); // second digit
                num = num / 10;
                draw_number(57,40,YELLOW, num); //first digit
            }else{
                draw_number(64,40,YELLOW, num); // second digit
                draw_number(57,40,YELLOW, 0); //first digit
            }
        }
    }

    while(1){
    }
}


static void draw_horizontal_line(int X, int Y, int toX, int color) {
    toX++;
    for (; X != toX; X++) {
        draw_dot(X, Y, color);
    }
}


static void draw_vertical_line(int X, int Y, int toY, int color) {
    toY++;
    for (; Y != toY; Y++) {
        draw_dot(X, Y, color);
    }
}

// fills the screen with BG_COLOR
static void draw_background() {
    for (int Y = 0; Y != 60; Y++) {
        draw_horizontal_line(0, Y, 79, BG_COLOR);
    }
}

// draws a small square (a single memory cell)
static void draw_dot(int X, int Y, int color) {
    *VG_ADDR = (Y << 7) | X;  // store into the address IO register
    *VG_COLOR = color;  // store into the color IO register, which triggers
    // the actual write to the framebuffer at the address
    // previously stored in the address IO register
}

static void draw_plus(int X, int Y, int color){
    int xLeft = X - 2;
    int yUp = Y - 3;
    draw_horizontal_line(xLeft, Y, X + 2, color);
    draw_vertical_line(X, yUp, Y + 3, color);
}
static void draw_minus(int X, int Y, int color){
    int xLeft = X - 2;
    draw_horizontal_line(xLeft, Y, X + 2, color);
}
static void draw_mult(int X, int Y, int color){
    int xLeft = X - 2;
    int yUp = Y - 3;
    int cross[8][2] = {{X-1, Y-1},{X-2, Y-2},
                       {X-1, Y+1},{X-2, Y+2},
                       {X+1, Y-1},{X+2, Y-2},
                       {X+1, Y+1},{X+2, Y+2}};
    draw_horizontal_line(xLeft, Y, X + 2, color);
    draw_vertical_line(X, yUp, Y + 3, color);
    for(int i = 0; i < 8; i++){
        draw_dot(cross[i][0], cross[i][1], color);
    }
}


static void draw_number(int X, int Y, int color, int num){
//initialize shift variables
    int xup5 = X + 5;
    int ydown5 = Y + 5;
    int ydown10 = Y + 10;
    //establish code for lighting up seven segments
    if (num == 1){

        draw_vertical_line(X,ydown5,ydown10,color);
        draw_vertical_line(X,Y,ydown5,color);
    }
    if (num == 2){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 3){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 4){
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_vertical_line(X,Y,ydown5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 5){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,Y,ydown5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 6){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,ydown5,ydown10,color);
        draw_vertical_line(X,Y,ydown5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 7){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
    }
    if (num == 8){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,ydown5,ydown10,color);
        draw_vertical_line(X,Y,ydown5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 9){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,Y,ydown5,color);
        draw_horizontal_line(X,ydown5,xup5,color);
    }
    if (num == 0){
        draw_horizontal_line(X,Y,xup5,color);
        draw_vertical_line(xup5,Y,ydown5,color);
        draw_vertical_line(xup5,ydown5,ydown10,color);
        draw_horizontal_line(X,ydown10,xup5,color);
        draw_vertical_line(X,ydown5,ydown10,color);
        draw_vertical_line(X,Y,ydown5,color);
    }
}


int _rand(int Max){
    return rand() % Max;
}
int * generateQuestion(char operator){
    int num1;
    int num2;
    int temp;
    static int nums [7];
    switch (operator) {
        case '+':
            num1 = _rand(21);
            num2 = _rand(21);
            nums[5] = num1 + num2;
            nums[4] = _rand(15);
            nums[6] = _rand(15);
            break;
        case '-':
            num1 = _rand(21);
            num2 = _rand(21);
            nums[5] = num1 - num2;
            nums[4] = _rand(15);
            nums[6] = _rand(15);
            break;
        case '*':
            num1 = _rand(10);
            num2 = _rand(10);
            nums[5] = num1 * num2;
            nums[4] = _rand(100);
            nums[6] = _rand(100);
            break;
        default: // assume default is addition
            num1 = _rand(21);
            num2 = _rand(21);
            break;
    }

    if (num1 > 9){
        temp = num1 % 10;
        num1 = num1 / 10;
        nums[1] = temp;
        nums[0] = num1;
    }else{
        nums[0] = 0;
        nums[1] = num1;
    }
    if(num2 > 9){
        temp = num2 % 10;
        num2 = num2 / 10;
        nums[3] = temp;
        nums[2] = num2;
    }else{
        nums[2] = 0;
        nums[3] = num2;
    }
    return nums;
}


char pickOperator() {
    char operator = ' ';
    int i = _rand(3);
    if(i == 0){
        operator = '+';
        draw_plus(39, 14, GREEN);
    }
    if(i == 1){
        operator = '-';
        draw_minus(39, 14, GREEN);
    }
    if(i == 2){
        operator = '*';
        draw_mult(39, 14, GREEN);
    }
    return operator;
}