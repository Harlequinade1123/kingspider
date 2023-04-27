//public関数一覧
//KingSpider()
//writeCommand(String command)
//rotateRollPitchYaw(float roll, float pitch, float yaw)
//moveXY(float x, float y)
//setJointAngleValue(int joint_id, int value)
//setJointAngleValue(int joint_id, int value)
//setJointSpeedValue(int joint_id, int value)
//setJointSpeedValue(int value)
//setJointSpeed(int joint_id, float value)
//setJointSpeed(float value)
//setMovementSpeed(float value)
//setRPYSpeed(float value)

public class KingSpider extends PApplet
{
    //カメラ関係の変数
    private float old_mouse_x, old_mouse_y;
    private float camera_angle, camera_distance, camera_height;

    void mouseDragged()
    {
        camera_angle += (mouseX - old_mouse_x) / 2;
        if (camera_angle < -360)
        {
            camera_angle += 360;
        }
        else if (360 < camera_angle)
        {
            camera_angle -= 360;
        }
        if (keyPressed && keyCode == SHIFT)
        {
            camera_height -= old_mouse_y - mouseY;
            if (camera_height < 0)
            {
                camera_height = 0;
            }
            else if (800 < camera_height)
            {
                camera_height = 800;
            }
        }
        else
        {
            camera_distance += old_mouse_y - mouseY;
            if (camera_distance < 5)
            {
                camera_distance = 5;
            }
            else if (1500 < camera_distance)
            {
                camera_distance = 1500;
            }
        }
        old_mouse_x = mouseX;
        old_mouse_y = mouseY;
    }

    //ロボット関係の変数
    private float[][] pr;//脚先ベクトル
    private float[]   robot_base_size;
    private float[]   robot_base_postion;
    private float[][] leg_base_postions;
    private float[]   leg_base_rotation;
    private int[][]   leg_joint_indices;
    private boolean[] legs_are_grounded;
    private float[]   target_robot_xy;
    private float[]   present_robot_xy;
    private float     target_roll,  target_pitch,  target_yaw;
    private float     present_roll, present_pitch, present_yaw;
    private float     move_speed;
    private float     rpy_speed;

    private int[]     target_joint_values;
    private float[]   joint_speeds;
    private float[]   present_joint_angles;
    private float[][] link_vectors;

    private int old_time;

    //変数初期化＋ウィンドウ生成＋シミュレーション開始
    public KingSpider()
    {
        old_mouse_x = 0;
        old_mouse_y = 0;
        camera_angle    =   0.0;
        camera_distance = 700.0;
        camera_height   = 300.0;

        pr = new float[][]{ {0.0, 0.0, 0.0},
                            {0.0, 0.0, 0.0},
                            {0.0, 0.0, 0.0},
                            {0.0, 0.0, 0.0},
                            {0.0, 0.0, 0.0},
                            {0.0, 0.0, 0.0}};
        robot_base_size     = new float[] {65.0, 95.0, 30.0};
        robot_base_postion  = new float[] {0.0, 0.0, 0.0};
        leg_base_postions   = new float[][]{{ robot_base_size[0] / 2, -(robot_base_size[1] - 25) / 2, 0.0},
                                            { robot_base_size[0] / 2,  (robot_base_size[1] - 25) / 2, 0.0},
                                            {  0.0,  robot_base_size[1] / 2, 0.0},
                                            {-robot_base_size[0] / 2,  (robot_base_size[1] - 25) / 2, 0.0},
                                            {-robot_base_size[0] / 2, -(robot_base_size[1] - 25) / 2, 0.0},
                                            {  0.0, -robot_base_size[1] / 2, 0.0}};
        leg_base_rotation  = new float[] {0.0, 0.0, HALF_PI, PI, PI, -HALF_PI};
        leg_joint_indices  = new int[][]{{0, 2, 4}, {1, 3, 5}, {7, 9, 11}, {13, 15, 17}, {12, 14, 16}, {6, 8, 10}};
        legs_are_grounded  = new boolean[] {true, true, true, true, true, true};
        target_robot_xy    = new float[] {0.0, 0.0};
        present_robot_xy   = new float[] {0.0, 0.0};
        target_roll        =  0.0;
        target_pitch       =  0.0;
        target_yaw         =  0.0;
        present_roll       =  0.0;
        present_pitch      =  0.0;
        present_yaw        =  0.0;
        move_speed         =  0.0;
        rpy_speed          = 59.0;

        target_joint_values = new int[]{512, 512, 512,
                                        512, 512, 512,
                                        512, 512, 512,
                                        512, 512, 512,
                                        512, 512, 512,
                                        512, 512, 512};
        joint_speeds         = new float[] {59.0, 59.0, 59.0,
                                            59.0, 59.0, 59.0,
                                            59.0, 59.0, 59.0,
                                            59.0, 59.0, 59.0,
                                            59.0, 59.0, 59.0,
                                            59.0, 59.0, 59.0};
        present_joint_angles = new float[] {0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0,
                                            0.0, 0.0, 0.0};
        link_vectors       = new float[][] {{50.0, 0.0,   0.0},
                                            {45.0, 0.0, -15.0},
                                            {60.5, 0.0, -12.5},
                                            {10.0, 0.0, -91.0}};
        
        String[] args = new String[]{"KingSpider"};
        PApplet.runSketch(args, this);
    }

    public void writeCommand(String command)
    {
        int command_length = command.length();
        if (command.equals("[e]\n"))
        {
            target_joint_values[0]  = 512; target_joint_values[1]  = 512; target_joint_values[2]  = 819;
            target_joint_values[3]  = 205; target_joint_values[4]  = 512; target_joint_values[5]  = 512;
            target_joint_values[6]  = 512; target_joint_values[7]  = 512; target_joint_values[8]  = 205;
            target_joint_values[9]  = 819; target_joint_values[10] = 512; target_joint_values[11] = 512;
            target_joint_values[12] = 512; target_joint_values[13] = 512; target_joint_values[14] = 205;
            target_joint_values[15] = 819; target_joint_values[16] = 512; target_joint_values[17] = 512;
        }
        else if (command.equals("[i]\n"))
        {
            target_joint_values[0]  = 512; target_joint_values[1]  = 512; target_joint_values[2]  = 512;
            target_joint_values[3]  = 512; target_joint_values[4]  = 512; target_joint_values[5]  = 512;
            target_joint_values[6]  = 512; target_joint_values[7]  = 512; target_joint_values[8]  = 512;
            target_joint_values[9]  = 512; target_joint_values[10] = 512; target_joint_values[11] = 512;
            target_joint_values[12] = 512; target_joint_values[13] = 512; target_joint_values[14] = 512;
            target_joint_values[15] = 512; target_joint_values[16] = 512; target_joint_values[17] = 512;
        }
        if (4 < command_length && command.charAt(0) == '[' && command.charAt(command_length - 2) == ']' && command.charAt(command_length - 1) == '\n')
        {
            char    command_code       = command.charAt(1);
            IntList command_value_list = new IntList();
            String  command_value      = "";
            for (int i = 3; i < command_length - 1; i++)
            {
                if (i == command_length - 2)
                {
                    command_value_list.append(int(command_value));
                }
                else if ('0' <= command.charAt(i) && command.charAt(i) <= '9')
                {
                    command_value += command.charAt(i);
                }
                else if (command.charAt(i) == ',')
                {
                    command_value_list.append(int(command_value));
                    command_value = "";
                }
                else
                {
                    println("ERROR: writeCommand -> invalid command " + command);
                    return;
                }
            }

            int command_value_size = command_value_list.size();
            if (command.charAt(1) == 's' && 4 < command_length)
            {
                if (command_value_size < 2)
                {
                    return;
                }
                setJointAngleValue(int(command_value_list.get(0)), int(command_value_list.get(1)));
            }
            if (command.charAt(1) == 'm' && 4 < command_length)
            {
                for (int i = 0; i < command_value_size - 1; i+=2)
                {
                    setJointAngleValue(int(command_value_list.get(i)), int(command_value_list.get(i + 1)));
                }
            }
            if (command.charAt(1) == 'v' && 4 < command_length)
            {
                setJointSpeedValue(int(command_value_list.get(0)));
            }
        }
    }

    public void rotateRollPitchYaw(float roll, float pitch, float yaw)
    {
        target_roll  = roll;
        target_pitch = pitch;
        target_yaw   = yaw;
    }

    public void moveXY(float x, float y)
    {
        target_robot_xy[0] = x;
        target_robot_xy[1] = y;
    }

    public void setJointAngleValue(int joint_id, int value)
    {
        if (joint_id < 1 || 18 < joint_id)
        {
            println("ERROR: setJointAngleValue -> ID" + str(joint_id) + " is not 1-18");
            return;
        }
        if (value < 0)
        {
            target_joint_values[joint_id - 1] = 0;
        }
        else if (1024 < value)
        {
            target_joint_values[joint_id - 1] = 1024;
        }
        else
        {
            target_joint_values[joint_id - 1] = value;
        }
    }

    public int getJointAngleValue(int joint_id)
    {
        if (joint_id < 1 || 18 < joint_id)
        {
            println("ERROR: getJointAngleValue -> ID" + str(joint_id) + " is not 1-18");
            return -1;
        }

        return int(1024.0 * (6.0 * present_joint_angles[joint_id - 1] / 5.0 / PI + 0.5));
    }

    public float[] getLegXYZ(int leg_id)
    {
        float[] ans;
        if (leg_id < 1 || 18 < leg_id)
        {
            println("ERROR: getLegXYZ -> Leg ID" + str(leg_id) + " is not 1-6");
            ans = new float[]{0.0, 0.0, 0.0};
            return ans;
        }

        ans = new float[]{pr[leg_id - 1][0], pr[leg_id - 1][1], pr[leg_id - 1][2]};
        return ans;
    }

    public void setJointSpeedValue(int joint_id, int value)
    {
        if (joint_id < 1 || 18 < joint_id)
        {
            println("ERROR: setJointSpeedValue -> ID" + str(joint_id) + " is not 1-18");
            return;
        }
        joint_speeds[joint_id - 1] = float(value) * 0.111;
        if (joint_speeds[joint_id - 1] < 0)
        {
            joint_speeds[joint_id - 1] = 0.0;
        }
        else if (59.0 < joint_speeds[joint_id - 1])
        {
            joint_speeds[joint_id - 1] = 59.0;
        }
    }

    public void setJointSpeedValue(int value)
    {
        for (int joint_id = 0; joint_id < 18; joint_id++)
        {
            joint_speeds[joint_id] = float(value) * 0.111;
            if (joint_speeds[joint_id] < 0)
            {
                joint_speeds[joint_id] = 0.0;
            }
            else if (59.0 < joint_speeds[joint_id])
            {
                joint_speeds[joint_id] = 59.0;
            }
        }
    }

    public void setJointSpeed(int joint_id, float value)
    {
        if (joint_id < 1 || 18 < joint_id)
        {
            println("ERROR: setJointSpeedValue ->  ID" + str(joint_id) + " is not 1-18");
            return;
        }
        joint_speeds[joint_id - 1] = value;
        if (joint_speeds[joint_id - 1] < 0)
        {
            joint_speeds[joint_id - 1] = 0.0;
        }
        else if (59.0 < joint_speeds[joint_id - 1])
        {
            joint_speeds[joint_id - 1] = 59.0;
        }
    }

    public void setJointSpeed(float value)
    {
        for (int joint_id = 0; joint_id < 18; joint_id++)
        {
            joint_speeds[joint_id] =value;
            if (joint_speeds[joint_id] < 0)
            {
                joint_speeds[joint_id] = 0.0;
            }
            else if (59.0 < joint_speeds[joint_id])
            {
                joint_speeds[joint_id] = 59.0;
            }
        }
    }

    public void setMovementSpeed(float value)
    {
        move_speed = value;
    }

    public void setRPYSpeed(float value)
    {
        rpy_speed = value;
    }

    void settings()
    {
        size(800, 800, P3D);
    }

    void setup()
    {
        frameRate(100);
        old_time = millis();
    }

    void draw()
    {
        old_mouse_x = mouseX;
        old_mouse_y = mouseY;
        background(200);

        camera( camera_distance*cos(radians(camera_angle)),
                camera_distance*sin(radians(camera_angle)),
                camera_height,
                0.0, 0.0, 0.0,
                0.0, 0.0, -1.0);

        //グリッドの描画
        drawGrid();

        //ロボットの描画
        updateRobot();
        drawRobot();

        //各関節の角度表示
        showJointValues();
        //各脚先の座標を表示
        showLegXYZ();
    }

    private void drawGrid()
    {
        stroke(200, 0, 0);
        strokeWeight(1);
        line(-1000, 0, 1000, 0);
        stroke(0, 200, 0);
        line(0, -1000, 0, 1000);
        stroke(0, 0, 200);
        line(0, 0, 0, 0, 0, 1000);
        stroke(120);
        for (int i = -10; i <= 10; i++)
        {
            if (i == 0)
            {
                continue;
            }
            line(-1000, 100 * i, 1000, 100 * i);
            line(100 * i, -1000, 100 * i, 1000);
        }
    }

    private void showJointValues()
    {
        pushMatrix();
        camera();
        hint(DISABLE_DEPTH_TEST);
        noLights();
        noStroke();
        fill(250, 90);
        rect(25, 20, 130, 450);
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
        fill(0);
        textSize(24);
        for (int joint_id = 0; joint_id < 18; joint_id++)
        {
            int joint_value = int(1024.0 * (6.0 * present_joint_angles[joint_id] / 5.0 / PI + 0.5));
            showText3d("ID" + str(joint_id + 1), 40, 50 + 24 * joint_id);
            showText3d(":", 90, 50 + 24 * joint_id);
            showText3d(str(joint_value), 105, 50 + 24 * joint_id);
        }
    }

    private void showLegXYZ()
    {
        pushMatrix();
        camera();
        hint(DISABLE_DEPTH_TEST);
        noLights();
        noStroke();
        fill(250, 90);
        rect(25, 670, 750, 120);
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
        fill(0);
        textSize(24);
        for (int leg_i = 0; leg_i < 6; leg_i++)
        {
            showText3d("Leg " + str(leg_i + 1), 60 + 120 * leg_i, 700);
            showText3d("x : " + str(float(round(100 * pr[leg_i][0])) / 100), 60 + 120 * leg_i, 730 + 24 * 0);
            showText3d("y : " + str(float(round(100 * pr[leg_i][1])) / 100), 60 + 120 * leg_i, 730 + 24 * 1);
            showText3d("z : " + str(float(round(100 * (robot_base_postion[2] + pr[leg_i][2]))) / 100), 60 + 120 * leg_i, 730 + 24 * 2);
        }
    }

    private void updateRobot()
    {
        float delta_time  = float(millis() - old_time);
        updateMovement(delta_time);
        updateRollPitchYaw(delta_time);
        updateJointAngle(delta_time);
        old_time = millis();
    }

    private void updateMovement(float delta_time)
    {
        if (move_speed < 0.001)
        {
            present_robot_xy[0] = target_robot_xy[0];
            present_robot_xy[1] = target_robot_xy[1];
            return;
        }
        float x_error = target_robot_xy[0] - present_robot_xy[0];
        float y_error = target_robot_xy[1] - present_robot_xy[1];
        float delta_xy = move_speed * delta_time / 1000.0;
        if (abs(x_error) < delta_xy) present_robot_xy[0] = target_robot_xy[0];
        else if (0 < x_error)        present_robot_xy[0] += delta_xy;
        else                         present_robot_xy[0] -= delta_xy;
        if (abs(y_error) < delta_xy) present_robot_xy[1] = target_robot_xy[1];
        else if (0 < y_error)        present_robot_xy[1] += delta_xy;
        else                         present_robot_xy[1] -= delta_xy;
    }

    private void updateRollPitchYaw(float delta_time)
    {
        if (rpy_speed < 0.001)
        {
            present_roll  = target_roll;
            present_pitch = target_pitch;
            present_yaw   = target_yaw;
            return;
        }
        float roll_error  = target_roll - present_roll;
        float pitch_error = target_pitch - present_pitch;
        float yaw_error   = target_yaw - present_yaw;
        float delta_angle = rpy_speed * PI / 30.0 * delta_time / 1000.0;
        if (abs(roll_error) < delta_angle) present_roll = target_roll;
        else if (0 < roll_error)           present_roll += delta_angle;
        else                               present_roll -= delta_angle;
        if (abs(pitch_error) < delta_angle) present_pitch = target_pitch;
        else if (0 < pitch_error)           present_pitch += delta_angle;
        else                                present_pitch -= delta_angle;
        if (abs(yaw_error) < delta_angle) present_yaw = target_yaw;
        else if (0 < yaw_error)           present_yaw += delta_angle;
        else                              present_yaw -= delta_angle;
    }

    private void updateJointAngle(float delta_time)
    {
        for (int joint_id = 0; joint_id < 18; joint_id++)
        {
            float target_joint_angle = (float(target_joint_values[joint_id]) / 1024.0 - 0.5) * 5.0 * PI / 6.0;
            float joint_speed = joint_speeds[joint_id];
            if (joint_speed < 0.001)
            {
                present_joint_angles[joint_id] = target_joint_angle;
                continue;
            }
            float error       = target_joint_angle - present_joint_angles[joint_id];
            float delta_angle = joint_speed * PI / 30.0 * delta_time / 1000.0;
            if (abs(error) < delta_angle)
            {
                present_joint_angles[joint_id] = target_joint_angle;
            }
            else if (0 < error)
            {
                present_joint_angles[joint_id] += delta_angle;
            }
            else
            {
                present_joint_angles[joint_id] -= delta_angle;
            }
        }
    }

    private void drawRobot()
    {
        calcRobotPosition();
        rightHandedTranslate(robot_base_postion[0], robot_base_postion[1], robot_base_postion[2]);
        rightHandedRotateX(present_roll);
        rightHandedRotateY(present_pitch);
        rightHandedRotateZ(present_yaw);
        fill(220);
        stroke(0);
        strokeWeight(1);
        box(robot_base_size[0], robot_base_size[1], robot_base_size[2]);
        pushMatrix();
        rightHandedTranslate(robot_base_size[0] / 2, 0.0, 0.0);
        rightHandedTranslate(12.5, 0.0, 0.0);
        fill(20);
        stroke(0);
        box(25.0);
        popMatrix();
        pushMatrix();
        rightHandedTranslate(0.0, 0.0, robot_base_size[2] / 2);
        rightHandedTranslate(0.0, 0.0, 1.0);
        fill(43, 115, 163);
        box(68.0, 66.5, 2.0);
        rightHandedTranslate(12.5, 0.0, 3.5);
        fill(20);
        box(2.0, 66.5, 5.0);
        rightHandedTranslate(-25.0, 0.0, 0.0);
        box(2.0, 66.5, 5.0);
        rightHandedTranslate(12.5, 0.0, 3.5);
        fill(43, 115, 163);
        box(27.0, 66.5, 2.0);
        popMatrix();
        for (int leg_i = 0; leg_i < 6; leg_i++)
        {
            pushMatrix();
            rightHandedTranslate(leg_base_postions[leg_i][0], leg_base_postions[leg_i][1], leg_base_postions[leg_i][2]);
            rightHandedRotateZ(leg_base_rotation[leg_i]);
            noStroke();
            fill(20);
            makeLinkX(link_vectors[0][0], link_vectors[0][1], link_vectors[0][2], 25.0);
            
            fill(20);
            stroke(200);
            makeCylinderZ(25.0, 25.0);
            stroke(200);
            makeCylinderZ(10.0, 30.0);
            stroke(200);
            makeCylinderZ(10.0, 25.0);
            rightHandedRotateZ(present_joint_angles[leg_joint_indices[leg_i][0]]);
            
            fill(220);
            stroke(0);
            strokeWeight(1);
            makeLinkX(link_vectors[1][0], link_vectors[1][1], link_vectors[1][2], 22.0);
            
            fill(20);
            stroke(200);
            makeCylinderY(25.0, 25.0);
            stroke(200);
            makeCylinderY(10.0, 30.0);
            stroke(200);
            makeCylinderY(10.0, 25.0);
            if (leg_i == 0 || leg_i == 2 || leg_i == 3)
            {
                rightHandedRotateY(present_joint_angles[leg_joint_indices[leg_i][1]]);
            }
            else
            {
                rightHandedRotateY(-present_joint_angles[leg_joint_indices[leg_i][1]]);
            }
            
            fill(20);
            makeLinkX(36.0, 0.0, 0.0, 25.0);
            fill(220);
            stroke(0);
            makeLinkX(link_vectors[2][0] - 12.5 - 36.0, 0.0, 0.0, 26.0);
            fill(20);
            noStroke();
            makeLinkX(12.5, 0.0, 0.0, 25.0);
            box(25.0);
            makeLinkZ(0.0, 0.0, link_vectors[2][2], 25.0);
            
            fill(20);
            stroke(200);
            makeCylinderY(25.0, 25.0);
            stroke(200);
            makeCylinderY(10.0, 30.0);
            stroke(200);
            makeCylinderY(10.0, 25.0);
            if (leg_i == 0 || leg_i == 2 || leg_i == 3)
            {
                rightHandedRotateY(-present_joint_angles[leg_joint_indices[leg_i][2]]);
            }
            else
            {
                rightHandedRotateY(present_joint_angles[leg_joint_indices[leg_i][2]]);
            }
            rightHandedTranslate(link_vectors[3][0], 0.0, 0.0);
            fill(220);
            stroke(0);
            makeEndEffectorZ(link_vectors[3][2], 25.0);
            popMatrix();
        }
    }

    private void calcRobotPosition()
    {
        robot_base_postion[0] = present_robot_xy[0];
        robot_base_postion[1] = present_robot_xy[1];

        float max_height = 0.0;
        for (int leg_i = 0; leg_i < 6; leg_i++)
        {
            float[] sinThs = {sin(present_joint_angles[leg_joint_indices[leg_i][0]]),
                            sin(present_joint_angles[leg_joint_indices[leg_i][1]]),
                            sin(present_joint_angles[leg_joint_indices[leg_i][2]])};
            float[] cosThs = {cos(present_joint_angles[leg_joint_indices[leg_i][0]]),
                            cos(present_joint_angles[leg_joint_indices[leg_i][1]]),
                            cos(present_joint_angles[leg_joint_indices[leg_i][2]])};
            if (leg_i == 1 || leg_i == 4 || leg_i == 5)
            {
                sinThs[1] *= -1;
                sinThs[2] *= -1;
            }

            float sinBase  = sin(leg_base_rotation[leg_i]), cosBase  = cos(leg_base_rotation[leg_i]);
            float sinRoll  = sin(present_roll),             cosRoll  = cos(present_roll);
            float sinPitch = sin(present_pitch),            cosPitch = cos(present_pitch);
            float sinYaw   = sin(present_yaw),              cosYaw   = cos(present_yaw);

            //BaseLink
            pr[leg_i][0]  = cosPitch * cosYaw * leg_base_postions[leg_i][0] -
                            cosPitch * sinYaw * leg_base_postions[leg_i][1] +
                            sinPitch * leg_base_postions[leg_i][2];
            pr[leg_i][1]  = (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * leg_base_postions[leg_i][0] +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * leg_base_postions[leg_i][1] -
                             cosPitch * sinRoll * leg_base_postions[leg_i][2];
            pr[leg_i][2]  = (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * leg_base_postions[leg_i][0] +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * leg_base_postions[leg_i][1] +
                             cosRoll * cosPitch * leg_base_postions[leg_i][2];
            max_height = max(-pr[leg_i][2], max_height);
            
            //BaseLink->Link0
            float link_element0, link_element1, link_element2;
            float link_element0_rot, link_element1_rot, link_element2_rot;
            link_element0 = link_vectors[0][0];
            link_element1 = link_vectors[0][1];
            link_element2 = link_vectors[0][2];
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);

            //BaseLink->Link0->Link1xy
            link_element0 = link_vectors[1][0] * cosThs[0] - link_vectors[1][1] * sinThs[0];
            link_element1 = link_vectors[1][0] * sinThs[0] + link_vectors[1][1] * cosThs[0];
            link_element2 = 0.0;
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);

            //BaseLink->Link0->Link1xy->Link1z
            link_element0 = 0.0;
            link_element1 = 0.0;
            link_element2 = link_vectors[1][2];
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);

            //BaseLink->Link0->Link1xy->Link1z->Link2xy
            link_element0 = link_vectors[2][0] * cosThs[0] * cosThs[1] -
                            link_vectors[2][1] * sinThs[0];
            link_element1 = link_vectors[2][0] * sinThs[0] * cosThs[1] +
                            link_vectors[2][1] * cosThs[0];
            link_element2 =-link_vectors[2][0] * sinThs[1];
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);

            //BaseLink->Link0->Link1xy->Link1z->Link2xy->Link2z
            link_element0 = link_vectors[2][2] * cosThs[0] * sinThs[1];
            link_element1 = link_vectors[2][2] * sinThs[0] * sinThs[1];
            link_element2 = link_vectors[2][2] * cosThs[1];
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);

            //BaseLink->Link0->Link1xy->Link1z->Link2xy->Link2z->Link3
            float sinTh23 = sinThs[1] * cosThs[2] - sinThs[2] * cosThs[1];
            float cosTh23 = cosThs[1] * cosThs[2] + sinThs[1] * sinThs[2];
            link_element0 = link_vectors[3][0] * cosThs[0] * cosTh23 -
                            link_vectors[3][1] * sinThs[0] +
                            link_vectors[3][2] * cosThs[0] * sinTh23;
            link_element1 = link_vectors[3][0] * sinThs[0] * cosTh23 +
                            link_vectors[3][1] * cosThs[0] +
                            link_vectors[3][2] * sinThs[0] * sinTh23;
            link_element2 =-link_vectors[3][0] * sinTh23 +
                            link_vectors[3][2] * cosTh23;
            link_element0_rot = cosBase * link_element0 - sinBase * link_element1;
            link_element1_rot = sinBase * link_element0 + cosBase * link_element1;
            link_element2_rot = link_element2;
            pr[leg_i][0] += cosPitch * cosYaw * link_element0_rot -
                            cosPitch * sinYaw * link_element1_rot +
                            sinPitch * link_element2_rot;
            pr[leg_i][1] += (cosRoll * sinYaw + cosYaw * sinRoll * sinPitch) * link_element0_rot +
                            (cosRoll * cosYaw - sinRoll * sinPitch * sinYaw) * link_element1_rot -
                             cosPitch * sinRoll * link_element2_rot;
            pr[leg_i][2] += (sinRoll * sinYaw - cosRoll * sinPitch * cosYaw) * link_element0_rot +
                            (sinRoll * cosYaw + cosRoll * sinPitch * sinYaw) * link_element1_rot +
                             cosRoll * cosPitch * link_element2_rot;
            max_height = max(-pr[leg_i][2], max_height);
        }
        robot_base_postion[2] = max_height;

        for (int leg_i = 0; leg_i < 6; leg_i++)
        {
            if (max_height + pr[leg_i][2] < 5)
            { 
                legs_are_grounded[leg_i] = true;
            }
            else
            {
                legs_are_grounded[leg_i] = false;
            }
            pushMatrix();
            rightHandedTranslate(robot_base_postion[0] + pr[leg_i][0], robot_base_postion[1] + pr[leg_i][1], robot_base_postion[2] + pr[leg_i][2]);
            noStroke();
            fill(100);
            if (legs_are_grounded[leg_i])
            {
                fill(250, 217, 0);
            }
            sphere(4);
            popMatrix();
        }
    }

    private void showText3d(String str, int x, int y)
    {
        pushMatrix();
        camera();
        hint(DISABLE_DEPTH_TEST);
        noLights();
        textMode(MODEL);
        text(str, x, y);
        hint(ENABLE_DEPTH_TEST);
        popMatrix();
    }

    private void rightHandedTranslate(float x, float y, float z)
    {
        translate(x, -y, z);
    }

    private void rightHandedRotateX(float rad_angle)
    {
        rotateX(-rad_angle);
    }

    private void rightHandedRotateY(float rad_angle)
    {
        rotateY(rad_angle);
    }

    private void rightHandedRotateZ(float rad_angle)
    {
        rotateZ(-rad_angle);
    }

    private void makeLinkX(float x, float y, float z, float size)
    {
        rightHandedTranslate(x / 2, y / 2, z / 2);
        box(abs(x), size, size);
        rightHandedTranslate(x / 2, y / 2, z / 2);
    }

    private void makeLinkY(float x, float y, float z, float size)
    {
        rightHandedTranslate(x / 2, y / 2, z / 2);
        box(size, abs(y), size);
        rightHandedTranslate(x / 2, y / 2, z / 2);
    }

    private void makeLinkZ(float x, float y, float z, float size)
    {
        rightHandedTranslate(x / 2, y / 2, z / 2);
        box(size, size, abs(z));
        rightHandedTranslate(x / 2, y / 2, z / 2);
    }

    private void makeCylinderX(float diameter, float joint_length)
    {
        rightHandedRotateY(HALF_PI);
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, -joint_length);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        rightHandedRotateY(-HALF_PI);
        noStroke();
        beginShape(QUAD_STRIP);
        for (int deg = 0; deg <= 360; deg++)
        {
            float y = diameter * cos(radians(deg)) / 2;
            float z = diameter * sin(radians(deg)) / 2;
            vertex( joint_length / 2, y, z);
            vertex(-joint_length / 2, y, z);
        }
        endShape();
    }

    private void makeCylinderY(float diameter, float joint_length)
    {
        rightHandedRotateX(HALF_PI);
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, -joint_length);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        rightHandedRotateX(-HALF_PI);
        noStroke();
        beginShape(QUAD_STRIP);
        for (int deg = 0; deg <= 360; deg++)
        {
            float x = diameter * cos(radians(deg)) / 2;
            float z = diameter * sin(radians(deg)) / 2;
            vertex(x,  joint_length / 2, z);
            vertex(x, -joint_length / 2, z);
        }
        endShape();
    }

    private void makeCylinderZ(float diameter, float joint_length)
    {
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, -joint_length);
        circle(0.0, 0.0, diameter);
        rightHandedTranslate(0.0, 0.0, joint_length / 2);
        noStroke();
        beginShape(QUAD_STRIP);
        for (int deg = 0; deg <= 360; deg++)
        {
            float x = diameter * cos(radians(deg)) / 2;
            float y = diameter * sin(radians(deg)) / 2;
            vertex(x, y,  joint_length / 2);
            vertex(x, y, -joint_length / 2);
        }
        endShape();
    }

    private void makeEndEffectorZ(float length, float size)
    {
        beginShape(TRIANGLES);
        vertex( 0.0,       0.0,      length);
        vertex( size / 2,  size / 2, 0.0);
        vertex( size / 2, -size / 2, 0.0);
        vertex( 0.0,       0.0,      length);
        vertex(-size / 2,  size / 2, 0.0);
        vertex(-size / 2, -size / 2, 0.0);
        vertex( 0.0,       0.0,      length);
        vertex( size / 2,  size / 2, 0.0);
        vertex(-size / 2,  size / 2, 0.0);
        vertex( 0.0,       0.0,      length);
        vertex( size / 2, -size / 2, 0.0);
        vertex(-size / 2, -size / 2, 0.0);
        endShape();
        rect(-size / 2, -size / 2, size, size);
    }
};