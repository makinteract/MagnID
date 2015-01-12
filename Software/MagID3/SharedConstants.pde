// 1. MODIFIABLE DEFAULT VALUES (change them in config.xml)

// TOKENS
static int FFT_SIZE = 128;
static int SAMPLIG_FREQ= 100;
static int FFT_WINDOW= 1024;
static int FIX_FREQ_TOKEN_TIME_FILTER_WINDOW_MS=100;
static float LOW_STRENGHT_SIGNAL=10;
static float HIGH_STRENGHT_SIGNAL=30;

static int CALIBRATION_TOKEN= 1; // ID 1, location 2
static int TOT_CALIBRATION_POINTS= 100;

static int REFRESH_MS = 250;


// NETWORK
static int SERIAL_PORT=8;
static int OSC_PORT= 5204;
static String MULTICAST_ADDRESS="239.0.0.1";

// SERIAL
static int BAUD_RATE= 115200; 

// FILE
static String WORKSPACE_DIR="Workspace/";
static String FILTERS_DIR="Filters/";


// 2. CONSTANTS NOT MODIFIABLE

// MAIN INTERFACE
final int WIDTH=1000;
final int HEIGHT=500;
final int HOME_BUTTON_WIDTH=200;
final int HOME_BUTTON_HEIGHT=80;
final int TOKEN_SIZE=200;
final int NUMBER_OF_TOKENS=8;
final int STATUS_BAR_HEIGHT= 15;

// COLORS
final color RED= color(255, 0, 0);
final color GREEN= color(0, 255, 0);
final color BLUE= color(0, 0, 255);
final color YELLOW= color(255, 255, 0);
final color BLACK= color(0, 0, 0);
final color WHITE= color(255, 255, 255);
final color PURPLE= color(255, 0, 255);
final color DARK_GREY= color(30, 30, 30);
final color GREY= color(128, 128, 128);
final color LIGHT_GREY= color(200, 200, 200);
final color DARK_GREEN= color(0, 163, 26);
