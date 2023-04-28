#include <Dynamixel2Arduino.h>
#include <Wire.h>

#if defined(ARDUINO_OpenCM904)
    #define DXL_SERIAL Serial3
    const int DXL_DIR_PIN = 22;
#elif defined(ARDUINO_OpenCR)
    #define DXL_SERIAL Serial3
    const int DXL_DIR_PIN = 84;
#elif defined(ARDUINO_OpenRB)
    #define DXL_SERIAL Serial1
    const int DXL_DIR_PIN = -1;
#endif

#define USB_SERIAL Serial
#define BT_SERIAL  Serial2

#define ADDRE_TOF  0x52

const uint8_t DXL_CNT               = 18;
const float   DXL_PROTOCOL_VERSION  = 1.0;
const int32_t DXL_INIT_VELOCITY     = 100;
const int32_t DXL_INIT_ACCELERATION = 100;
const unsigned long USB_BUADRATE = 57600;
const unsigned long BT_BUADRATE  = 57600;
const unsigned long DXL_BUADRATE = 1000000;

int32_t  g_dxl_present_velocity      = 100;
int32_t  g_dxl_present_acceleration  = 100;
String   g_read_line = "";
char     g_cmd_word  = '\0';
uint16_t g_cmd_buf[255];
uint16_t g_dxl_pos[19] = { 0, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512, 512 };

bool g_torque_is_on  = false;

Dynamixel2Arduino dxl(DXL_SERIAL, DXL_DIR_PIN);

using namespace ControlTableItem;

uint8_t readCommand()
{
    int read_line_length = g_read_line.length();
    if (3 <= read_line_length && g_read_line.charAt(0) == '[' && g_read_line.charAt(read_line_length - 1) == ']')
    {
        g_cmd_word          = g_read_line.charAt(1);
        uint8_t buf_index   =-1;
        int val_begin_index = 3;
        int val_end_index   = 3;
        for (int line_i = 3; line_i < read_line_length; line_i++)
        {
            val_end_index++;
            if (g_read_line.charAt(line_i) == ',' || line_i == read_line_length - 1)
            {
                buf_index++;
                g_cmd_buf[buf_index] = g_read_line.substring(val_begin_index, val_end_index).toInt();
                val_begin_index = val_end_index;
            }
            else if (g_read_line.charAt(line_i) < '0' && '9' < g_read_line.charAt(line_i))
            {
                g_cmd_word = '\0';
                return -1;
            }
        }
        return buf_index;
    }
    g_cmd_word = '\0';
    return -1;
}

uint16_t readToF()
{
    Wire.beginTransmission(ADDRE_TOF);
    Wire.write(0xD3);
    Wire.endTransmission(false);
    Wire.requestFrom(ADDRE_TOF, 2);
    uint16_t dist = Wire.read();
    dist = (dist << 8) | Wire.read();
    return (dist);
}

void setup()
{
    Wire.begin();
    USB_SERIAL.begin(USB_BUADRATE);
    BT_SERIAL.begin(BT_BUADRATE);
    while (!USB_SERIAL && !BT_SERIAL) {}

    dxl.begin(DXL_BUADRATE);
    dxl.setPortProtocolVersion(DXL_PROTOCOL_VERSION);

    bool dxl_is_connected = false;
    while (dxl_is_connected)
    {
        dxl_is_connected = dxl.ping(1);
        for (int dxl_i = 2; dxl_i <= DXL_CNT; dxl_i++)
        {
            bool ping = dxl.ping(dxl_i);
            dxl_is_connected = dxl_is_connected && ping;
            if (USB_SERIAL)
            {
                USB_SERIAL.print(dxl_i);
                USB_SERIAL.print("->");
                if (ping)
                {
                    USB_SERIAL.println("connected");
                }
                else
                {
                    USB_SERIAL.println("failed");
                }
            }
        }
    }

    for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
    {
        dxl.torqueOff(dxl_i);
        dxl.setOperatingMode(dxl_i, OP_POSITION);
        dxl.torqueOn(dxl_i);
        if (1.5 <= DXL_PROTOCOL_VERSION)
        {
            dxl.writeControlTableItem(PROFILE_VELOCITY, dxl_i, DXL_INIT_VELOCITY);
            dxl.writeControlTableItem(PROFILE_ACCELERATION, dxl_i, DXL_INIT_ACCELERATION);
        }
        else
        {
            dxl.writeControlTableItem(MOVING_SPEED, dxl_i, DXL_INIT_VELOCITY);
        }
        g_dxl_pos[dxl_i] = int(dxl.getPresentPosition(dxl_i));
    }
    g_torque_is_on = true;
}

void loop()
{
    uint8_t buf_index = -1;
    if (0 < USB_SERIAL.available())
    {
        g_read_line = USB_SERIAL.readStringUntil('\n');
        buf_index   = readCommand();
    }
    else if (0 < BT_SERIAL.available())
    {
        g_read_line = BT_SERIAL.readStringUntil('\n');
        buf_index   = readCommand();
    }
    switch (g_cmd_word)
    {
        case 's':
            if (1 <= buf_index)
            {
                g_dxl_pos[g_cmd_buf[0]] = g_cmd_buf[1];
            }
            break;
        case 'm':
            for (int buf_i = 0; buf_i < buf_index; buf_i+=2)
            {
                if (0 < buf_i <= DXL_CNT)
                {
                    g_dxl_pos[g_cmd_buf[buf_i]] = g_cmd_buf[buf_i + 1];
                }
            }
            break;
        case 'i':
            for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
            {
                g_dxl_pos[dxl_i] = 512;
            }
            break;
        case 'e':
            g_dxl_pos[1]  = 512; g_dxl_pos[2]  = 512; g_dxl_pos[3]  = 819; g_dxl_pos[4]  = 205; g_dxl_pos[5]  = 512; g_dxl_pos[6]  = 512;
            g_dxl_pos[7]  = 512; g_dxl_pos[8]  = 512; g_dxl_pos[9]  = 205; g_dxl_pos[10] = 819; g_dxl_pos[11] = 512; g_dxl_pos[12] = 512;
            g_dxl_pos[13] = 512; g_dxl_pos[14] = 512; g_dxl_pos[15] = 205; g_dxl_pos[16] = 819; g_dxl_pos[17] = 512; g_dxl_pos[18] = 512;
            break;
        case 'f':
            for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
            {
                dxl.torqueOff(dxl_i);
                g_torque_is_on = false;
            }
            break;
        case 'n':
            for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
            {
                dxl.torqueOn(dxl_i);
                g_torque_is_on = true;
            }
            break;
        case 'c':
            g_dxl_present_velocity = 30;
            break;
        case 'v':
            g_dxl_present_velocity = 60;
            break;
        case 'b':
            g_dxl_present_velocity = 100;
            break;
        case 'h':
            g_dxl_present_velocity = 200;
            break;
        case 'a':
            g_dxl_present_acceleration = g_cmd_buf[0];
            break;
        case 'd':
            {
                uint16_t distance = readToF();
                USB_SERIAL.println(distance);
                BT_SERIAL.println(distance);
                break;
            }
        case 'p':
            {
                String dxl_pos_msg = "[";
                for (int dxl_i = 1; dxl_i < DXL_CNT; dxl_i++)
                {
                    dxl_pos_msg += String(int(dxl.getPresentPosition(dxl_i)));
                    dxl_pos_msg += ",";
                }
                dxl_pos_msg += String(int(dxl.getPresentPosition(DXL_CNT)));
                dxl_pos_msg += "]";
                USB_SERIAL.println(dxl_pos_msg);
                BT_SERIAL.println(dxl_pos_msg);
                break;
            }
        default:
            break;
    }
    if (g_torque_is_on)
    {
        for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
        {
            if (1.5 <= DXL_PROTOCOL_VERSION)
            {
                dxl.writeControlTableItem(PROFILE_VELOCITY, dxl_i, g_dxl_present_velocity);
                dxl.writeControlTableItem(PROFILE_ACCELERATION, dxl_i, g_dxl_present_acceleration);
            }
            else
            {
                dxl.writeControlTableItem(MOVING_SPEED, dxl_i, g_dxl_present_velocity);
            }
        }
        for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
        {
            dxl.setGoalPosition(dxl_i, g_dxl_pos[dxl_i]);
        }
    }
    else
    {
        for (int dxl_i = 1; dxl_i <= DXL_CNT; dxl_i++)
        {
            g_dxl_pos[dxl_i] = int(dxl.getPresentPosition(dxl_i));
        }
    }
    g_cmd_word = '\0';
    delay(5);
}
