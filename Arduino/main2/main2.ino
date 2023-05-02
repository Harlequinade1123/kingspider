#include <Dynamixel2Arduino.h>

//使用するマイコン（OpenCM or OpenRB）の種類に応じて変更
#if defined(ARDUINO_OpenCM904)
    #define DXL_SERIAL Serial3
    const int DXL_DIR_PIN = 22;
    const bool SENSOR_IS_AVAILABLE = false;
#elif defined(ARDUINO_OpenRB)
    #define DXL_SERIAL Serial1
    const int DXL_DIR_PIN = -1;
    const bool SENSOR_IS_AVAILABLE = true;
#endif

#define USB_SERIAL Serial
#define BT_SERIAL  Serial2

const uint8_t  DXL_CNT                = 18;  // モータの数
const float    DXL_PROTOCOL_VERSION   = 1.0; // モータの通信プロトコル（AX->1.0, XC->2.0）
const uint16_t DXL_INIT_VELOCITY      = 100; // モータの初期速度
const uint16_t DXL_INIT_ACCELERATION  = 100; // モータの初期加速度
const uint16_t DXL_MAX_POSITION_VALUE = 850; // モータの最大角
const uint16_t DXL_MIN_POSITION_VALUE = 150; // モータの最小角
const unsigned long USB_BUADRATE = 57600;   // USBのボーレート
const unsigned long BT_BUADRATE  = 57600;   // Bluetoothデバイスのボーレート
const unsigned long DXL_BUADRATE = 1000000; // Dynamixelのボーレート

uint16_t g_dxl_present_velocity      = 100; // Dynamixelの速度
uint16_t g_dxl_present_acceleration  = 100; // Dynamixelの加速度
// Dynamixelの目標位置
uint16_t g_dxl_pos[19]          = { 0, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512 };
// Dynamixelが接続されているかどうか
bool     g_dxl_is_connected[19] = { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
bool     g_torque_is_on = false; // Dynamixelがトルクオンかどうか
String   g_read_line    = "";    // シリアル通信で受け取るコマンド
char     g_cmd_word     = '\0';  // コマンドのキーワード
uint16_t g_cmd_args[128];        // コマンドの引数

// Dynamixel2Arduinoクラスのインスタンス化
Dynamixel2Arduino dxl(DXL_SERIAL, DXL_DIR_PIN);

using namespace ControlTableItem;

/**
 * g_read_lineを読み込み，g_cmd_wordとg_cmd_argsに値を格納する
 * @return g_cmd_argsの最大インデックス．何も格納されない場合は-1を返す
 */
int8_t readCommand()
{
    int read_line_length = g_read_line.length();
    if (3 <= read_line_length && g_read_line.charAt(0) == '[' && g_read_line.charAt(read_line_length - 1) == ']')
    {
        g_cmd_word           = g_read_line.charAt(1);
        int8_t arg_max_index   =-1;
        int8_t elm_begin_index = 3;
        int8_t elm_end_index   = 3;
        
        // カンマ区切りごとに数字を取り出す
        // カンマ，数字以外が含まれていた場合，エラーとして扱い-1を返す
        for (int line_i = 3; line_i < read_line_length; line_i++)
        {
            elm_end_index++;
            if (g_read_line.charAt(line_i) == ',' || line_i == read_line_length - 1)
            {
                arg_max_index++;
                g_cmd_args[arg_max_index] = g_read_line.substring(elm_begin_index, elm_end_index).toInt();
                elm_begin_index = elm_end_index;
            }
            else if (g_read_line.charAt(line_i) < '0' && '9' < g_read_line.charAt(line_i))
            {
                g_cmd_word = '\0';
                return -1;
            }
        }
        return arg_max_index;
    }
    g_cmd_word = '\0';
    return -1;
}

void setup()
{
    USB_SERIAL.begin(USB_BUADRATE);
    BT_SERIAL.begin(BT_BUADRATE);
    delay(2000);

    dxl.begin(DXL_BUADRATE);
    dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);

    dxl.torqueOff(3);
    dxl.setOperatingMode(3, OP_POSITION);
    dxl.torqueOn(3);
}

void loop()
{
    dxl.setGoalPosition(3, 520);
    delay(1000);
    dxl.setGoalPosition(3, 420);
    delay(1000);
    /**
    int array1[] = {0,338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array1[dxl_i]);
    }
    delay(50);
    int array2[] = {0,338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array2[dxl_i]);
    }
    delay(50);
    int array3[] = {0,338,685,308,714,321,701,512,512,715,307,707,315,700,338,720,308,744,321 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array3[dxl_i]);
    }
    delay(50);
    int array4[] = {0,338,685,295,727,311,711,512,512,728,294,717,305,700,338,733,295,754,311 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array4[dxl_i]);
    }
    delay(50);
    int array5[] = {0,338,685,282,740,302,720,512,512,741,281,726,296,700,338,746,282,764,302 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array5[dxl_i]);
    }
    delay(50);
    int array6[] = {0,338,685,269,753,292,730,512,512,754,268,736,286,700,338,760,269,774,292 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array6[dxl_i]);
    }
    delay(50);
    int array7[] = {0,338,685,257,765,283,739,512,512,767,255,745,277,700,338,773,257,783,283 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array7[dxl_i]);
    }
    delay(50);
    int array8[] = {0,338,685,269,753,292,730,512,512,754,268,736,286,700,338,760,269,774,292 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array8[dxl_i]);
    }
    delay(50);
    int array9[] = {0,338,685,282,740,302,720,512,512,741,281,726,296,700,338,746,282,764,302 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array9[dxl_i]);
    }
    delay(50);
    int array10[] = {0,338,685,295,727,311,711,512,512,728,294,717,305,700,338,733,295,754,311 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array10[dxl_i]);
    }
    delay(50);
    int array11[] = {0,338,685,308,714,321,701,512,512,715,307,707,315,700,338,720,308,744,321 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array11[dxl_i]);
    }
    delay(50);
    int array12[] = {0,338,685,321,702,332,690,512,512,702,320,696,325,700,338,707,321,734,332 };
    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.setGoalPosition(dxl_i, array12[dxl_i]);
    }
    delay(50);
    **/
}