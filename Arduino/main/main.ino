#include <Dynamixel2Arduino.h>

//使用するマイコン（OpenCR, OpenCM or OpenRB）の種類に応じて変更
#if defined(ARDUINO_OpenCR)
    #define DXL_SERIAL Serial3
    const int DXL_DIR_PIN = 84;
#elif defined(ARDUINO_OpenCM904)
    #define DXL_SERIAL Serial3
    const int DXL_DIR_PIN = 22;
#elif defined(ARDUINO_OpenRB)
    #define DXL_SERIAL Serial1
    const int DXL_DIR_PIN = -1;
#endif

#define DXL_SERIAL Serial1
#define USB_SERIAL Serial
#define BT_SERIAL  Serial2

const uint8_t       DXL_MAX_CNT  = 255;   // モータの数
const unsigned long USB_BUADRATE = 57600;   // USBのボーレート
const unsigned long BT_BUADRATE  = 57600;   // Bluetoothデバイスのボーレート
const unsigned long DXL_BUADRATE = 1000000; // Dynamixelのボーレート

uint16_t DXL_INIT_VELOCITY;
uint16_t DXL_INIT_ACCELERATION;
uint16_t DXL_INIT_POSITION;
uint16_t DXL_MAX_POSITION_VALUE;
uint16_t DXL_MIN_POSITION_VALUE;

// =============== プロトコル1.0 ===============
uint16_t DXL_INIT_VELOCITY1      = 100; // モータの初期速度
uint16_t DXL_INIT_ACCELERATION1  = 100; // モータの初期加速度
uint16_t DXL_INIT_POSITION1      = 512; // モータの初期位置
uint16_t DXL_MAX_POSITION_VALUE1 = 850; // モータの最大値
uint16_t DXL_MIN_POSITION_VALUE1 = 150; // モータの最小値

// =============== プロトコル2.0 ===============
uint16_t DXL_INIT_VELOCITY2      = 100;  // モータの初期速度
uint16_t DXL_INIT_ACCELERATION2  = 100;  // モータの初期加速度
uint16_t DXL_INIT_POSITION2      = 2048; // モータの初期位置
uint16_t DXL_MAX_POSITION_VALUE2 = 4095; // モータの最大値
uint16_t DXL_MIN_POSITION_VALUE2 = 0;    // モータの最小値

// [e]コマンド時のDynamixelの目標位置
uint16_t g_dxl_e_pos[256];
uint16_t g_dxl_e_pos1[19] = { 512, 512, 512, 819, 205, 512, 512, 512, 512, 205, 819, 512, 512, 512, 512, 205, 819, 512, 512 };
uint16_t g_dxl_e_pos2[19] = { 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048, 2048 };

uint16_t g_dxl_present_vels[256]; // Dynamixelの速度
uint16_t g_dxl_present_accs[256]; // Dynamixelの加速度
uint16_t g_dxl_target_pos[256];   // Dynamixelの目標位置
bool     g_dxl_is_connected[256]; // Dynamixelが接続されているかどうか

//通信プロトコル 1.0 or 2.0 のDynamixelが存在するか
bool g_exists_protocols[3] = { false, false, false };

bool     g_torque_is_on = false; // Dynamixelがトルクオンかどうか
String   g_read_line    = "";    // シリアル通信で受け取るコマンド
char     g_cmd_word     = '\0';  // コマンドのキーワード
uint16_t g_cmd_args[512];        // コマンドの引数

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
        g_cmd_word             =  g_read_line.charAt(1);
        int8_t arg_max_index   = -1;
        int8_t elm_begin_index =  3;
        int8_t elm_end_index   =  3;
        
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
    while (!USB_SERIAL && !BT_SERIAL) {}
    delay(2000);

    dxl.begin(DXL_BUADRATE);

    // 通信プロトコルの推定
    for (int8_t protocol = 1; protocol < 3; protocol++)
    {
        dxl.setPortProtocolVersion((float)protocol);
        for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
        {
            g_exists_protocols[protocol] = g_exists_protocols[protocol] || dxl.ping(dxl_i);
            if (g_exists_protocols[protocol])
            {
                break;
            }
        }
    }

    // 通信プロトコルの設定
    if (g_exists_protocols[1]) dxl.setPortProtocolVersion(1.0);
    else                       dxl.setPortProtocolVersion(2.0);

    // 誤作動防止のためDynamixelが一つ以上認識されるまで待機する
    uint8_t dxl_id = 1;
    while (!dxl.ping(dxl_id))
    {
        dxl_id++;
        dxl_id %= DXL_MAX_CNT + 1;
        delay(5);
    }
    delay(100);

    // 接続されているDynamixelを確認する
    for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
    {
        if (dxl.ping(dxl_i)) g_dxl_is_connected[dxl_i] = true;
        else                 g_dxl_is_connected[dxl_i] = false;
    }

    // モータの初期設定
    if (g_exists_protocols[1])
    {
        DXL_INIT_VELOCITY      = DXL_INIT_VELOCITY1;
        DXL_INIT_ACCELERATION  = DXL_INIT_ACCELERATION1;
        DXL_INIT_POSITION      = DXL_INIT_POSITION1;
        DXL_MAX_POSITION_VALUE = DXL_MAX_POSITION_VALUE1;
        DXL_MIN_POSITION_VALUE = DXL_MIN_POSITION_VALUE1;
    }
    else
    {
        DXL_INIT_VELOCITY      = DXL_INIT_VELOCITY2;
        DXL_INIT_ACCELERATION  = DXL_INIT_ACCELERATION2;
        DXL_INIT_POSITION      = DXL_INIT_POSITION2;
        DXL_MAX_POSITION_VALUE = DXL_MAX_POSITION_VALUE2;
        DXL_MIN_POSITION_VALUE = DXL_MIN_POSITION_VALUE2;
    }
    
    // グローバル変数の初期設定
    for (int dxl_i = 0; dxl_i <= DXL_MAX_CNT; dxl_i++)
    {
        if (!g_dxl_is_connected[dxl_i])
        {
            continue;
        }
        g_dxl_present_vels[dxl_i] = DXL_INIT_VELOCITY;
        g_dxl_present_accs[dxl_i] = DXL_INIT_ACCELERATION;
        g_dxl_target_pos[dxl_i]   = DXL_INIT_POSITION;
        g_dxl_e_pos[dxl_i]        = DXL_INIT_POSITION;
        g_dxl_is_connected[dxl_i] = false;
    }

    if (g_exists_protocols[1])
    {
        int dxl_cnt = sizeof(g_dxl_e_pos1) / sizeof(g_dxl_e_pos1[0]);
        for (int dxl_i = 1; dxl_i < dxl_cnt; dxl_i++)
        {
            g_dxl_target_pos[dxl_i] = g_dxl_e_pos1[dxl_i];
        }
    }
    else
    {
        int dxl_cnt = sizeof(g_dxl_e_pos2) / sizeof(g_dxl_e_pos2[0]);
        for (int dxl_i = 1; dxl_i < dxl_cnt; dxl_i++)
        {
            g_dxl_target_pos[dxl_i] = g_dxl_e_pos2[dxl_i];
        }
    }

    // 接続されたDynamixelに対して初期設定を行い現在角度の表示する
    if (USB_SERIAL)
    {
        USB_SERIAL.println("----- DXL_DEFAULT_POSITION_VALUE ------");
    }
    for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
    {
        if (!g_dxl_is_connected[dxl_i])
        {
            continue;
        }
        dxl.torqueOff(dxl_i);
        dxl.setOperatingMode(dxl_i, OP_POSITION);
        dxl.torqueOn(dxl_i);
        if (g_exists_protocols[1])
        {
            dxl.writeControlTableItem(MOVING_SPEED, dxl_i, DXL_INIT_VELOCITY);
        }
        else
        {
            dxl.writeControlTableItem(PROFILE_VELOCITY, dxl_i, DXL_INIT_VELOCITY);
            dxl.writeControlTableItem(PROFILE_ACCELERATION, dxl_i, DXL_INIT_ACCELERATION);
        }

        g_dxl_target_pos[dxl_i] = constrain(uint16_t(dxl.getPresentPosition(dxl_i)), DXL_MIN_POSITION_VALUE, DXL_MAX_POSITION_VALUE);
        if (USB_SERIAL)
        {
            USB_SERIAL.print("[ID:");
            USB_SERIAL.print(dxl_i);
            USB_SERIAL.print(" Pos:");
            USB_SERIAL.print(g_dxl_target_pos[dxl_i]);
            USB_SERIAL.println("]");
        }
    }
    g_torque_is_on = true;
    if (USB_SERIAL)
    {
        USB_SERIAL.println("---------------------------------------");
    }
}

void loop()
{
    // シリアル通信によりコマンドの取得を行う
    int8_t arg_max_index = -1;
    if (0 < USB_SERIAL.available())
    {
        g_read_line   = USB_SERIAL.readStringUntil('\n');
        arg_max_index = readCommand();
    }
    else if (0 < BT_SERIAL.available())
    {
        g_read_line   = BT_SERIAL.readStringUntil('\n');
        arg_max_index = readCommand();
    }

    /**
     * 取得したコマンドによって以下の操作を行う
     * [s,ID,POS] -> 指定したモータ1つの位置制御
     * [m,ID1,POS1,ID2,POS2,...] -> 指定したモータ複数の位置制御
     * [i] -> 初期姿勢にする
     * [e] -> 片付けの姿勢にする
     * [f] -> トルクオフ
     * [n] -> トルクオン
     * [c] -> モータの速度の設定値を30にする
     * [v] -> モータの速度の設定値を60にする
     * [b] -> モータの速度の設定値を100にする
     * 以下は追加コマンド
     * [a,POS1,POS2,..., POS_DXL_MAX_CNT] -> 全てのモータの位置制御（初期型のmコマンド）
     * [v,VEL] -> 全てのモータの速度の設定値をVELにする
     * [v,ID1,VEL1,ID2,VEL2,...] -> 指定したモータ複数の速度設定
     * [k,ACC] -> 全てのモータの加速度の設定値をACCにする
     * [k,ID1,ACC1,ID2,ACC2,...] -> 指定したモータ複数の加速度設定
     * [p] -> モータの現在位置を取得する
     */
    switch (g_cmd_word)
    {
        case 's': // g_cmd_args -> { ID, POS }
            if (1 <= arg_max_index)
            {
                g_dxl_target_pos[g_cmd_args[0]] = constrain(g_cmd_args[1], DXL_MIN_POSITION_VALUE, DXL_MAX_POSITION_VALUE);
            }
            break;
        case 'm': // g_cmd_args -> { ID1, POS1, ID2, POS2, ... }
            for (int arg_i = 0; arg_i < arg_max_index; arg_i+=2)
            {
                if (0 < arg_i <= DXL_MAX_CNT)
                {
                    if (!g_dxl_is_connected[g_cmd_args[arg_i]])
                    {
                        continue;
                    }
                    g_dxl_target_pos[g_cmd_args[arg_i]] = constrain(g_cmd_args[arg_i + 1], DXL_MIN_POSITION_VALUE, DXL_MAX_POSITION_VALUE);
                }
            }
            break;
        case 'i': // g_cmd_args -> { } 
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                g_dxl_target_pos[dxl_i] = DXL_INIT_POSITION;
            }
            break;
        case 'e': // g_cmd_args -> { }
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                g_dxl_target_pos[dxl_i] = g_dxl_e_pos[dxl_i];
            }
            break;
        case 'f': // g_cmd_args -> { }
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                dxl.torqueOff(dxl_i);
                g_torque_is_on = false;
            }
            break;
        case 'n': // g_cmd_args -> { }
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                dxl.torqueOn(dxl_i);
                g_torque_is_on = true;
            }
            break;
        case 'c': // g_cmd_args -> { }
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                g_dxl_present_vels[dxl_i] = 30;
            }
            break;
        case 'v': // g_cmd_args -> { ID1, VEL1, ID2, VEL2, ... }, { VEL } or { }
            if (1 <= arg_max_index)
            {
                for (int arg_i = 0; arg_i < arg_max_index; arg_i+=2)
                {
                    if (0 < g_cmd_args[arg_i] && g_cmd_args[arg_i] <= DXL_MAX_CNT)
                    {
                        if (!g_dxl_is_connected[g_cmd_args[arg_i]])
                        {
                            continue;
                        }
                        g_dxl_present_vels[g_cmd_args[arg_i]] = g_cmd_args[arg_i + 1];
                    }
                }
            }
            else if (0 == arg_max_index)
            {
                for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
                {
                    if (!g_dxl_is_connected[dxl_i])
                    {
                        continue;
                    }
                    g_dxl_present_vels[dxl_i] = g_cmd_args[0];
                }
            }
            else
            {
                for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
                {
                    if (!g_dxl_is_connected[dxl_i])
                    {
                        continue;
                    }
                    g_dxl_present_vels[dxl_i] = 60;
                }
            }
            break;
        case 'b': // g_cmd_args -> { }
            for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
            {
                if (!g_dxl_is_connected[dxl_i])
                {
                    continue;
                }
                g_dxl_present_vels[dxl_i] = 100;
            }
            break;
        case 'a': // g_cmd_args -> { POS1, POS2, ..., POS_DXL_MAX_CNT }
            if (arg_max_index == DXL_MAX_CNT - 1)
            {
                for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
                {
                    if (!g_dxl_is_connected[dxl_i])
                    {
                        continue;
                    }
                    g_dxl_target_pos[dxl_i] = constrain(g_cmd_args[dxl_i - 1], DXL_MIN_POSITION_VALUE, DXL_MAX_POSITION_VALUE);
                }
            }
        case 'k': // g_cmd_args -> { ID1, ACC1, ID2, ACC2, ... } or { ACC }
            if (1 <= arg_max_index)
            {
                for (int arg_i = 0; arg_i < arg_max_index; arg_i+=2)
                {
                    if (0 < g_cmd_args[arg_i] && g_cmd_args[arg_i] <= DXL_MAX_CNT)
                    {
                        if (!g_dxl_is_connected[g_cmd_args[arg_i]])
                        {
                            continue;
                        }
                        g_dxl_present_accs[g_cmd_args[arg_i]] = g_cmd_args[arg_i + 1];
                    }
                }
            }
            else if (0 == arg_max_index)
            {
                for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
                {
                    if (!g_dxl_is_connected[dxl_i])
                    {
                        continue;
                    }
                    g_dxl_present_accs[dxl_i] = g_cmd_args[0];
                }
            }
            break;
        case 'p': // g_cmd_args -> { }
            {
                String dxl_pos_msg = "[";
                for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
                {
                    if (!g_dxl_is_connected[dxl_i])
                    {
                        continue;
                    }
                    if (g_dxl_is_connected[dxl_i])
                    {
                        dxl_pos_msg += String(uint16_t(dxl.getPresentPosition(dxl_i)));
                    }
                    else
                    {
                        dxl_pos_msg += "-1";
                    }
                    if (dxl_i < DXL_MAX_CNT)
                    {
                        dxl_pos_msg += ",";
                    }
                }
                dxl_pos_msg += "]";
                USB_SERIAL.println(dxl_pos_msg);
                BT_SERIAL.println(dxl_pos_msg);
                USB_SERIAL.flush();
                BT_SERIAL.flush();
                break;
            }
        default:
            break;
    }

    // トルクオン -> 接続されているDynamixelに対して速度（加速度），目標位置の入力
    // トルクオフ -> 現在位置を読み込み，g_dxl_posを更新（トルクオン時に突然動き出すことを防止するため）
    if (g_torque_is_on)
    {
        for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
        {
            if (!g_dxl_is_connected[dxl_i])
            {
                continue;
            }
            if (g_exists_protocols[1])
            {
                dxl.writeControlTableItem(MOVING_SPEED, dxl_i, g_dxl_present_vels[dxl_i]);
            }
            else
            {
                dxl.writeControlTableItem(PROFILE_VELOCITY, dxl_i, g_dxl_present_vels[dxl_i]);
                dxl.writeControlTableItem(PROFILE_ACCELERATION, dxl_i, g_dxl_present_accs[dxl_i]);
            }
        }
        for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
        {
            if (!g_dxl_is_connected[dxl_i])
            {
                continue;
            }
            dxl.setGoalPosition(dxl_i, g_dxl_target_pos[dxl_i]);
        }
    }
    else
    {
        for (int dxl_i = 1; dxl_i <= DXL_MAX_CNT; dxl_i++)
        {
            if (!g_dxl_is_connected[dxl_i])
            {
                continue;
            }
            g_dxl_target_pos[dxl_i] = constrain(uint16_t(dxl.getPresentPosition(dxl_i)), DXL_MIN_POSITION_VALUE, DXL_MAX_POSITION_VALUE);
        }
    }
    g_cmd_word = '\0';
    delay(5);
}
