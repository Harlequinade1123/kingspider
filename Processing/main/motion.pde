//掃き出し法による逆行列計算
void inverse(float[][] matrix, float[][] inverse_matrix)
{
    int matrix_size = matrix.length;
    for (int diag = 0; diag < matrix_size; diag++)
    {
        if (matrix[diag][diag] == 0.0)
        {
            for (int switched_row = diag + 1; switched_row < matrix_size; switched_row++)
            {
                if (matrix[switched_row][diag] != 0.0)
                {
                    for (int switched_col = 0; switched_col < matrix_size; switched_col++)
                    {
                        float tmp_inverse_matrix_elm               = inverse_matrix[switched_row][switched_col];
                        inverse_matrix[switched_row][switched_col] = inverse_matrix[diag][switched_col];
                        inverse_matrix[diag][switched_col]         = tmp_inverse_matrix_elm;
                        float tmp_matrix_elm               = matrix[switched_row][switched_col];
                        matrix[switched_row][switched_col] = matrix[diag][switched_col];
                        matrix[diag][switched_col]         = tmp_matrix_elm;
                    }
                }
            }
        }

        for (int div_col = 0; div_col < matrix_size; div_col++)
        {
            if (div_col == diag)
            {
                continue;
            }
            inverse_matrix[diag][div_col] /= matrix[diag][diag];
            matrix[diag][div_col]         /= matrix[diag][diag];
        }
        inverse_matrix[diag][diag] /= matrix[diag][diag];
        matrix[diag][diag]         /= matrix[diag][diag];

        for (int sub_row = 0; sub_row < matrix_size; sub_row++)
        {
            if (sub_row == diag)
            {
                continue;
            }
            for (int sub_col = diag + 1; sub_col < matrix_size; sub_col++)
            {
                matrix[sub_row][sub_col] -= matrix[diag][sub_col] * matrix[sub_row][diag];
            }
            for (int sub_col = 0; sub_col < matrix_size; sub_col++)
            {
                inverse_matrix[sub_row][sub_col] -= inverse_matrix[diag][sub_col] * matrix[sub_row][diag];
            }
            matrix[sub_row][diag] -= matrix[diag][diag] * matrix[sub_row][diag];
        }

    }
}

void posture6_1()
{
    float[][] jacobian         = new float[3][3];
    float[][] inverse_jacobian = new float[3][3];
    float     det_jacobian;
    float[][] link_vectors     = new float[][]{{50.0, 0.0, 0.0}, {45.0, 0.0, -15.0}, {60.5, 0.0, -12.5}, {10.0, 0.0, -91.0}};
    ArrayList<float[]> leg_angles_list = new ArrayList<float[]>();
    float[] leg_angles = new float[3];
    leg_angles[0] = (float(king_spider.getJointAngleValue(1))  / 1024.0 - 0.5) * 5.0 * PI / 6.0;
    leg_angles[1] = (float(king_spider.getJointAngleValue(3))  / 1024.0 - 0.5) * 5.0 * PI / 6.0;
    leg_angles[2] = (float(king_spider.getJointAngleValue(15)) / 1024.0 - 0.5) * 5.0 * PI / 6.0;
    //leg_angles_list.add(leg_angles);

    float sinTh1 = sin(leg_angles[0]), cosTh1 = cos(leg_angles[0]);
    float sinTh2 = sin(leg_angles[1]), cosTh2 = cos(leg_angles[1]);
    float sinTh3 = sin(leg_angles[2]), cosTh3 = cos(leg_angles[2]);
    float sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
    float cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;

    float[] present_pr = new float[3];
    present_pr[0] = link_vectors[0][0] + cosTh1 * link_vectors[1][0] 
                  + cosTh1 * cosTh2  * link_vectors[2][0] + cosTh1 * sinTh2  * link_vectors[2][2]
                  + cosTh1 * cosTh23 * link_vectors[3][0] + cosTh1 * sinTh23 * link_vectors[3][2];
    present_pr[1] =                      sinTh1 * link_vectors[1][0]
                  + sinTh1 * cosTh2  * link_vectors[2][0] + sinTh1 * sinTh2  * link_vectors[2][2]
                  + sinTh1 * cosTh23 * link_vectors[3][0] + sinTh1 * sinTh23 * link_vectors[3][2];
    present_pr[2] =                               link_vectors[1][2]
                  - sinTh2  * link_vectors[2][0] + cosTh2  * link_vectors[2][2]
                  - sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];

    ArrayList<float[]> target_pr_list  = new ArrayList<float[]>();
    for (int i = 0; i <= 10; i++)
    {
        float[] target_pr = new float[3];
        target_pr[0] = present_pr[0] + i * 2;
        target_pr[1] = present_pr[1];
        target_pr[2] = present_pr[2] + i * 5;
        target_pr_list.add(target_pr);
    }

    for (int i = 0; i <= 5; i++)
    {
        float[] target_pr = new float[3];
        target_pr[0] = present_pr[0] + 20;
        target_pr[1] = present_pr[1];
        target_pr[2] = present_pr[2] + 50;
        target_pr_list.add(target_pr);
    }

    for (int i = 0; i <= 50; i++)
    {
        float[] target_pr = new float[3];
        target_pr[0] = present_pr[0] + 20;
        target_pr[1] = present_pr[1] - 25 + 25 * cos(2 * PI / 50 * i);
        target_pr[2] = present_pr[2] + 50 + 25 * sin(2 * PI / 50 * i);
        target_pr_list.add(target_pr);
    }

    for (int i = 0; i <= 5; i++)
    {
        float[] target_pr = new float[3];
        target_pr[0] = present_pr[0] + 20;
        target_pr[1] = present_pr[1];
        target_pr[2] = present_pr[2] + 50;
        target_pr_list.add(target_pr);
    }

    for (int i = 0; i <= 10; i++)
    {
        float[] target_pr = new float[3];
        target_pr[0] = present_pr[0] + 20 - i * 2;
        target_pr[1] = present_pr[1];
        target_pr[2] = present_pr[2] + 50 - i * 5;
        target_pr_list.add(target_pr);
    }

    int target_pr_list_size = target_pr_list.size();
    for (int list_i = 0; list_i < target_pr_list_size; list_i++)
    {
        float[] error = new float[3];
        error[0] = target_pr_list.get(list_i)[0] - present_pr[0];
        error[1] = target_pr_list.get(list_i)[1] - present_pr[1];
        error[2] = target_pr_list.get(list_i)[2] - present_pr[2];
        float abs_error = sqrt(error[0] * error[0] + error[1] * error[1] + error[2] * error[2]);
        //ニュートン法による数値計算
        for (int count = 0; count < 10000; count++)
        {
            if (abs_error < 0.001)
            {
                //println(list_i, abs_error);
                break;
            }
            for (int row = 0; row < 3; row++)
            {
                for (int col = 0; col < 3; col++)
                {
                    jacobian[row][col] = 0.0;
                    if (row == col)
                    {
                        inverse_jacobian[row][col] = 1.0;
                    }
                    else
                    {
                        inverse_jacobian[row][col] = 0.0;
                    }
                }
            }

            sinTh1 = sin(leg_angles[0]); cosTh1 = cos(leg_angles[0]);
            sinTh2 = sin(leg_angles[1]); cosTh2 = cos(leg_angles[1]);
            sinTh3 = sin(leg_angles[2]); cosTh3 = cos(leg_angles[2]);
            sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
            cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;

            present_pr[0] = cosTh1  * cosTh23 * link_vectors[3][0] + cosTh1 * sinTh23 * link_vectors[3][2];
            present_pr[1] = sinTh1  * cosTh23 * link_vectors[3][0] + sinTh1 * sinTh23 * link_vectors[3][2];
            present_pr[2] =-sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];
            jacobian[0][2] =-cosTh1 * present_pr[2];
            jacobian[1][2] =-sinTh1 * present_pr[2];
            jacobian[2][2] = sinTh1 * present_pr[1] + cosTh1 * present_pr[0];

            present_pr[0] += cosTh1 * cosTh2  * link_vectors[2][0] + cosTh1 * sinTh2  * link_vectors[2][2];
            present_pr[1] += sinTh1 * cosTh2  * link_vectors[2][0] + sinTh1 * sinTh2  * link_vectors[2][2];
            present_pr[2] +=-sinTh2 * link_vectors[2][0] + cosTh2 * link_vectors[2][2];
            jacobian[0][1] = cosTh1 * present_pr[2];
            jacobian[1][1] = sinTh1 * present_pr[2];
            jacobian[2][1] =-sinTh1 * present_pr[1] - cosTh1 * present_pr[0];

            present_pr[0] += cosTh1 * link_vectors[1][0];
            present_pr[1] += sinTh1 * link_vectors[1][0];
            present_pr[2] += link_vectors[1][2];
            jacobian[0][0] = -present_pr[1];
            jacobian[1][0] =  present_pr[0];
            jacobian[2][0] =  0.0;

            present_pr[0] += link_vectors[0][0];
            
            det_jacobian  = jacobian[0][0] * (jacobian[1][1] * jacobian[2][2] - jacobian[1][2] * jacobian[2][1]);
            det_jacobian -= jacobian[1][0] * (jacobian[0][1] * jacobian[2][2] - jacobian[0][2] * jacobian[2][1]);
            if (det_jacobian == 0.0)
            {
                println("singular");
                break;
            }

            inverse(jacobian, inverse_jacobian);

            error[0] = target_pr_list.get(list_i)[0] - present_pr[0];
            error[1] = target_pr_list.get(list_i)[1] - present_pr[1];
            error[2] = target_pr_list.get(list_i)[2] - present_pr[2];

            leg_angles[0] += inverse_jacobian[0][0] * error[0] + inverse_jacobian[0][1] * error[1] + inverse_jacobian[0][2] * error[2];
            leg_angles[1] += inverse_jacobian[1][0] * error[0] + inverse_jacobian[1][1] * error[1] + inverse_jacobian[1][2] * error[2];
            leg_angles[2] += inverse_jacobian[2][0] * error[0] + inverse_jacobian[2][1] * error[1] + inverse_jacobian[2][2] * error[2];

            abs_error = sqrt(error[0] * error[0] + error[1] * error[1] + error[2] * error[2]);
        }

        leg_angles_list.add(new float[]{leg_angles[0], leg_angles[1], leg_angles[2]});
    }

    int leg_angles_list_size = leg_angles_list.size();
    for (int list_i = 0; list_i < leg_angles_list_size; list_i++)
    {
        int old_time = millis();
        int command1_val = int(1024.0 * (6.0 * leg_angles_list.get(list_i)[0] / 5.0 / PI + 0.5));
        int command2_val = int(1024.0 * (6.0 * leg_angles_list.get(list_i)[1] / 5.0 / PI + 0.5));
        int command3_val = int(1024.0 * (6.0 * leg_angles_list.get(list_i)[2] / 5.0 / PI + 0.5));

        if (command1_val < 0 || 1024 < command1_val)
        {
            return;
        }
        if (command2_val < 0 || 1024 < command2_val)
        {
            return;
        }
        if (command3_val < 0 || 1024 < command3_val)
        {
            return;
        }

        String command1 = "[s,1,"  + str(command1_val) + "]\n";
        String command2 = "[s,3," + str(command2_val) + "]\n";
        String command3 = "[s,5," + str(command3_val) + "]\n";
        king_spider.writeCommand(command1);
        king_spider.writeCommand(command2);
        king_spider.writeCommand(command3);
        while (millis() - old_time < 50) {}
    }
}

void posture6_2()
{
    int[] joint_ids            = new int[]{1, 3, 5, 2, 4, 6, 8, 10, 12, 14, 16, 18, 13, 15, 17, 7, 9, 11};
    float[] leg_base_rotation  = new float[] {0.0, 0.0, HALF_PI, PI, PI, -HALF_PI};
    float[][] link_vectors     = new float[][] {{50.0, 0.0, 0.0}, {45.0, 0.0, -15.0}, {60.5, 0.0, -12.5}, {10.0, 0.0, -91.0}};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();



    int division_number = 10;
    //各脚先の目標値（相対移動距離）
    leg_translations_list.add(new float[][]{
        {-20.0, -50.0, 30.0}, {-20.0, 50.0, 30.0}, {0.0, 0.0, 30.0}, {20.0, 50.0, 30.0}, {20.0, -50.0, 30.0}, {0.0, 0.0, 30.0}
    });
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}
    });
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}
    });

    for (int i = 0; i < 2; i++)
    {
        leg_translations_list.add(new float[][]{
            {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}
        });
        leg_translations_list.add(new float[][]{
            {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}
        });
        leg_translations_list.add(new float[][]{
            {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}
        });
        leg_translations_list.add(new float[][]{
            {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}
        });
    }

    leg_translations_list.add(new float[][]{
        {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}
    });
    leg_translations_list.add(new float[][]{
        {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}
    });



    ArrayList<float[]> joint_angles_list = new ArrayList<float[]>();
    float[] joint_angles = new float[18];
    for (int joint_i = 0; joint_i < 18; joint_i++)
    {
        joint_angles[joint_i] = (float(king_spider.getJointAngleValue(joint_ids[joint_i])) / 1024.0 - 0.5) * 5.0 * PI / 6.0;
    }
    joint_angles_list.add(new float[]{
        joint_angles[0],  joint_angles[1],  joint_angles[2],  joint_angles[3],  joint_angles[4],  joint_angles[5], 
        joint_angles[6],  joint_angles[7],  joint_angles[8],  joint_angles[9],  joint_angles[10], joint_angles[11], 
        joint_angles[12], joint_angles[13], joint_angles[14], joint_angles[15], joint_angles[16], joint_angles[17]
    });

    float[][] forward_kinematics = new float[6][3];

    ArrayList<float[]> target_positions_list = new ArrayList<float[]>();
    float[] target_positions = new float[18];
    for (int leg_i = 0; leg_i < 6; leg_i++)
    {
        float sinTh0 = sin(leg_base_rotation[leg_i]),  cosTh0 = cos(leg_base_rotation[leg_i]);
        float sinTh1 = sin(joint_angles[leg_i * 3 + 0]), cosTh1 = cos(joint_angles[leg_i * 3 + 0]);
        float sinTh2 = sin(joint_angles[leg_i * 3 + 1]), cosTh2 = cos(joint_angles[leg_i * 3 + 1]);
        float sinTh3 = sin(joint_angles[leg_i * 3 + 2]), cosTh3 = cos(joint_angles[leg_i * 3 + 2]);
        if (leg_i == 1 || leg_i == 4 || leg_i == 5)
        {
            sinTh2 *= -1;
            sinTh3 *= -1;
        }
        float sinTh01 = sinTh0 * cosTh1 + cosTh0 * sinTh1;
        float cosTh01 = cosTh0 * cosTh1 - sinTh0 * sinTh1;
        float sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
        float cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;
        target_positions[leg_i * 3 + 0] = cosTh0  * link_vectors[0][0] - sinTh0  * link_vectors[0][1]
                                        + cosTh01 * link_vectors[1][0] - sinTh01 * link_vectors[1][1]
                                        + cosTh01 * cosTh2  * link_vectors[2][0] - sinTh01 * link_vectors[2][1] + cosTh01 * sinTh2  * link_vectors[2][2]
                                        + cosTh01 * cosTh23 * link_vectors[3][0] - sinTh01 * link_vectors[3][1] + cosTh01 * sinTh23 * link_vectors[3][2];
        target_positions[leg_i * 3 + 1] = sinTh0  * link_vectors[0][0] + cosTh0  * link_vectors[0][1]
                                        + sinTh01 * link_vectors[1][0] + cosTh01 * link_vectors[1][1]
                                        + sinTh01 * cosTh2  * link_vectors[2][0] + cosTh01 * link_vectors[2][1] + sinTh01 * sinTh2  * link_vectors[2][2]
                                        + sinTh01 * cosTh23 * link_vectors[3][0] + cosTh01 * link_vectors[3][1] + sinTh01 * sinTh23 * link_vectors[3][2];
        target_positions[leg_i * 3 + 2] = link_vectors[0][2] + link_vectors[1][2]
                                        - sinTh2  * link_vectors[2][0] + cosTh2  * link_vectors[2][2]
                                        - sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];
        forward_kinematics[leg_i][0]    = target_positions[leg_i * 3 + 0];
        forward_kinematics[leg_i][1]    = target_positions[leg_i * 3 + 1];
        forward_kinematics[leg_i][2]    = target_positions[leg_i * 3 + 2];
    }
    target_positions_list.add(new float[]{
        target_positions[0],  target_positions[1],  target_positions[2],
        target_positions[3],  target_positions[4],  target_positions[5],
        target_positions[6],  target_positions[7],  target_positions[8],
        target_positions[9],  target_positions[10], target_positions[11],
        target_positions[12], target_positions[13], target_positions[14],
        target_positions[15], target_positions[16], target_positions[17]
    });

    int leg_translations_list_size = leg_translations_list.size();
    for (int list_i = 0; list_i < leg_translations_list_size; list_i++)
    {
        for (int div_i = 0; div_i < division_number; div_i++)
        {
            for (int leg_i = 0; leg_i < 6; leg_i++)
            {
                target_positions[leg_i * 3 + 0] += leg_translations_list.get(list_i)[leg_i][0] / float(division_number);
                target_positions[leg_i * 3 + 1] += leg_translations_list.get(list_i)[leg_i][1] / float(division_number);
                target_positions[leg_i * 3 + 2] += leg_translations_list.get(list_i)[leg_i][2] / float(division_number);
            }
            target_positions_list.add(new float[]{
                target_positions[0],  target_positions[1],  target_positions[2],
                target_positions[3],  target_positions[4],  target_positions[5],
                target_positions[6],  target_positions[7],  target_positions[8],
                target_positions[9],  target_positions[10], target_positions[11],
                target_positions[12], target_positions[13], target_positions[14],
                target_positions[15], target_positions[16], target_positions[17]
            });
        }
    }
    
    //3自由度×6本の脚＝18自由度->18次行列のヤコビ行列
    float[][] jacobian         = new float[18][18];
    float[][] inverse_jacobian = new float[18][18];
    float     det_jacobian     = 1.0;

    int target_positions_list_size = target_positions_list.size();
    for (int list_i = 0; list_i < target_positions_list_size; list_i++)
    {
        float[] error = new float[18];
        for (int error_i = 0; error_i < 18; error_i++)
        {
            error[error_i] = target_positions_list.get(list_i)[error_i] - forward_kinematics[error_i / 3][error_i % 3];
        }
        float abs_error = abs_error = 0.0;
        for (int error_i = 0; error_i < 18; error_i++)
        {
            abs_error += error[error_i] * error[error_i];
        }
        abs_error = sqrt(abs_error);
        //ニュートン法による数値計算
        for (int loop = 0; loop <= 10000; loop++)
        {
            if (abs_error < 0.001)
            {
                //println(abs_error);
                break;
            }
            for (int row = 0; row < 18; row++)
            {
                for (int col = 0; col < 18; col++)
                {
                    jacobian[row][col] = 0.0;
                    if (row == col)
                    {
                        inverse_jacobian[row][col] = 1.0;
                    }
                    else
                    {
                        inverse_jacobian[row][col] = 0.0;
                    }
                }
            }
            det_jacobian = 1.0;

            for (int leg_i = 0; leg_i < 6; leg_i++)
            {
                float sinTh0 = sin(leg_base_rotation[leg_i]),    cosTh0 = cos(leg_base_rotation[leg_i]);
                float sinTh1 = sin(joint_angles[leg_i * 3 + 0]), cosTh1 = cos(joint_angles[leg_i * 3 + 0]);
                float sinTh2 = sin(joint_angles[leg_i * 3 + 1]), cosTh2 = cos(joint_angles[leg_i * 3 + 1]);
                float sinTh3 = sin(joint_angles[leg_i * 3 + 2]), cosTh3 = cos(joint_angles[leg_i * 3 + 2]);
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    sinTh2 *= -1;
                    sinTh3 *= -1;
                }
                float sinTh01 = sinTh0 * cosTh1 + cosTh0 * sinTh1;
                float cosTh01 = cosTh0 * cosTh1 - sinTh0 * sinTh1;
                float sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
                float cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;

                //Link3 => Pr - P3
                forward_kinematics[leg_i][0] = cosTh01 * cosTh23 * link_vectors[3][0] - sinTh01 * link_vectors[3][1] + cosTh01 * sinTh23 * link_vectors[3][2];
                forward_kinematics[leg_i][1] = sinTh01 * cosTh23 * link_vectors[3][0] + cosTh01 * link_vectors[3][1] + sinTh01 * sinTh23 * link_vectors[3][2];
                forward_kinematics[leg_i][2] =-sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];
                //S3 × (Pr - P3)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 2] =-cosTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 2] =-sinTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 2] = sinTh01 * forward_kinematics[leg_i][1] + cosTh01 * forward_kinematics[leg_i][0];
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    jacobian[leg_i * 3 + 0][leg_i * 3 + 2] *= -1;
                    jacobian[leg_i * 3 + 1][leg_i * 3 + 2] *= -1;
                    jacobian[leg_i * 3 + 2][leg_i * 3 + 2] *= -1;
                }

                //Link2->Link3 => Pr - P2
                forward_kinematics[leg_i][0] += cosTh01 * cosTh2  * link_vectors[2][0] - sinTh01 * link_vectors[2][1] + cosTh01 * sinTh2  * link_vectors[2][2];
                forward_kinematics[leg_i][1] += sinTh01 * cosTh2  * link_vectors[2][0] + cosTh01 * link_vectors[2][1] + sinTh01 * sinTh2  * link_vectors[2][2];
                forward_kinematics[leg_i][2] +=-sinTh2  * link_vectors[2][0] + cosTh2  * link_vectors[2][2];
                //S2 × (Pr - P2)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 1] = cosTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 1] = sinTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 1] =-sinTh01 * forward_kinematics[leg_i][1] - cosTh01 * forward_kinematics[leg_i][0];
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    jacobian[leg_i * 3 + 0][leg_i * 3 + 1] *= -1;
                    jacobian[leg_i * 3 + 1][leg_i * 3 + 1] *= -1;
                    jacobian[leg_i * 3 + 2][leg_i * 3 + 1] *= -1;
                }

                //Link1->Link2->Link3 => Pr - P1
                forward_kinematics[leg_i][0] += cosTh01 * link_vectors[1][0] - sinTh01 * link_vectors[1][1];
                forward_kinematics[leg_i][1] += sinTh01 * link_vectors[1][0] + cosTh01 * link_vectors[1][1];
                forward_kinematics[leg_i][2] += link_vectors[1][2];
                //S1 × (Pr - P1)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 0] =-forward_kinematics[leg_i][1];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 0] = forward_kinematics[leg_i][0];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 0] = 0.0;

                //Link0->Link1->Link2->Link3 => Pr - P0
                forward_kinematics[leg_i][0] += cosTh0  * link_vectors[0][0] - sinTh0  * link_vectors[0][1];
                forward_kinematics[leg_i][1] += sinTh0  * link_vectors[0][0] + cosTh0  * link_vectors[0][1];
                forward_kinematics[leg_i][2] += link_vectors[0][2];

                det_jacobian *= jacobian[leg_i * 3 + 0][leg_i * 3 + 0] * jacobian[leg_i * 3 + 1][leg_i * 3 + 1] * jacobian[leg_i * 3 + 2][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 1] * jacobian[leg_i * 3 + 1][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 1] * jacobian[leg_i * 3 + 1][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 2] * jacobian[leg_i * 3 + 1][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 1];
            }

            if (det_jacobian == 0.0)
            {
                println("singular");
                break;
            }

            inverse(jacobian, inverse_jacobian);

            for (int error_i = 0; error_i < 18; error_i++)
            {
                error[error_i] = target_positions_list.get(list_i)[error_i] - forward_kinematics[error_i / 3][error_i % 3];
            }

            for (int joint_i = 0; joint_i < 18; joint_i++)
            {
                for (int error_i = 0; error_i < 18; error_i++)
                {
                    joint_angles[joint_i] += inverse_jacobian[joint_i][error_i] * error[error_i];
                }
            }

            abs_error = 0.0;
            for (int error_i = 0; error_i < 18; error_i++)
            {
                abs_error += error[error_i] * error[error_i];
            }
            abs_error = sqrt(abs_error);
        }
        joint_angles_list.add(new float[]{
            joint_angles[0],  joint_angles[1],  joint_angles[2],  joint_angles[3],  joint_angles[4],  joint_angles[5], 
            joint_angles[6],  joint_angles[7],  joint_angles[8],  joint_angles[9],  joint_angles[10], joint_angles[11], 
            joint_angles[12], joint_angles[13], joint_angles[14], joint_angles[15], joint_angles[16], joint_angles[17]
        });
    }

    int joint_angles_list_size = joint_angles_list.size();
    for (int list_i = 0; list_i < joint_angles_list_size; list_i++)
    {
        int old_time = millis();

        int[] joint_angle_values = new int[18];
        for (int joint_i = 0; joint_i < 18; joint_i++)
        {
            joint_angle_values[joint_ids[joint_i] - 1] = int(1024.0 * (6.0 * joint_angles_list.get(list_i)[joint_i] / 5.0 / PI + 0.5));
            if (joint_angle_values[joint_ids[joint_i] - 1] < 0 || 1024 < joint_angle_values[joint_ids[joint_i] - 1])
            {
                return;
            }
        }

        String command = "[m,";
        for (int joint_i = 0; joint_i < 18; joint_i++)
        {
            command += str(joint_angle_values[joint_i]);
            if (joint_i != 17)
            {
                command += ",";
            }
        }
        command += "]\n";
        king_spider.writeCommand(command);
        println(command);
        
        while (millis() - old_time < 25) {}
    }
}

void calcIKAndSendCommand(ArrayList<float[][]> leg_translations, int[] initial_angle_values, int division_number)
{
    int[] joint_ids            = new int[]{1, 3, 5, 2, 4, 6, 8, 10, 12, 14, 16, 18, 13, 15, 17, 7, 9, 11};
    float[] leg_base_rotation  = new float[] {0.0, 0.0, HALF_PI, PI, PI, -HALF_PI};
    float[][] link_vectors     = new float[][] {{50.0, 0.0, 0.0}, {45.0, 0.0, -15.0}, {60.5, 0.0, -12.5}, {10.0, 0.0, -91.0}};
    ArrayList<float[][]> leg_translations_list = leg_translations;

    ArrayList<float[]> joint_angles_list = new ArrayList<float[]>();
    float[] joint_angles = new float[18];
    for (int joint_i = 0; joint_i < 18; joint_i++)
    {
        //joint_angles[joint_i] = (float(king_spider.getJointAngleValue(joint_ids[joint_i])) / 1024.0 - 0.5) * 5.0 * PI / 6.0;
        joint_angles[joint_i] = (float(initial_angle_values[joint_ids[joint_i] - 1]) / 1024.0 - 0.5) * 5.0 * PI / 6.0;
    }
    joint_angles_list.add(new float[]{
        joint_angles[0],  joint_angles[1],  joint_angles[2],  joint_angles[3],  joint_angles[4],  joint_angles[5], 
        joint_angles[6],  joint_angles[7],  joint_angles[8],  joint_angles[9],  joint_angles[10], joint_angles[11], 
        joint_angles[12], joint_angles[13], joint_angles[14], joint_angles[15], joint_angles[16], joint_angles[17]
    });

    float[][] forward_kinematics = new float[6][3];

    ArrayList<float[]> target_positions_list = new ArrayList<float[]>();
    float[] target_positions = new float[18];
    for (int leg_i = 0; leg_i < 6; leg_i++)
    {
        float sinTh0 = sin(leg_base_rotation[leg_i]),  cosTh0 = cos(leg_base_rotation[leg_i]);
        float sinTh1 = sin(joint_angles[leg_i * 3 + 0]), cosTh1 = cos(joint_angles[leg_i * 3 + 0]);
        float sinTh2 = sin(joint_angles[leg_i * 3 + 1]), cosTh2 = cos(joint_angles[leg_i * 3 + 1]);
        float sinTh3 = sin(joint_angles[leg_i * 3 + 2]), cosTh3 = cos(joint_angles[leg_i * 3 + 2]);
        if (leg_i == 1 || leg_i == 4 || leg_i == 5)
        {
            sinTh2 *= -1;
            sinTh3 *= -1;
        }
        float sinTh01 = sinTh0 * cosTh1 + cosTh0 * sinTh1;
        float cosTh01 = cosTh0 * cosTh1 - sinTh0 * sinTh1;
        float sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
        float cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;
        target_positions[leg_i * 3 + 0] = cosTh0  * link_vectors[0][0] - sinTh0  * link_vectors[0][1]
                                        + cosTh01 * link_vectors[1][0] - sinTh01 * link_vectors[1][1]
                                        + cosTh01 * cosTh2  * link_vectors[2][0] - sinTh01 * link_vectors[2][1] + cosTh01 * sinTh2  * link_vectors[2][2]
                                        + cosTh01 * cosTh23 * link_vectors[3][0] - sinTh01 * link_vectors[3][1] + cosTh01 * sinTh23 * link_vectors[3][2];
        target_positions[leg_i * 3 + 1] = sinTh0  * link_vectors[0][0] + cosTh0  * link_vectors[0][1]
                                        + sinTh01 * link_vectors[1][0] + cosTh01 * link_vectors[1][1]
                                        + sinTh01 * cosTh2  * link_vectors[2][0] + cosTh01 * link_vectors[2][1] + sinTh01 * sinTh2  * link_vectors[2][2]
                                        + sinTh01 * cosTh23 * link_vectors[3][0] + cosTh01 * link_vectors[3][1] + sinTh01 * sinTh23 * link_vectors[3][2];
        target_positions[leg_i * 3 + 2] = link_vectors[0][2] + link_vectors[1][2]
                                        - sinTh2  * link_vectors[2][0] + cosTh2  * link_vectors[2][2]
                                        - sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];
        forward_kinematics[leg_i][0]    = target_positions[leg_i * 3 + 0];
        forward_kinematics[leg_i][1]    = target_positions[leg_i * 3 + 1];
        forward_kinematics[leg_i][2]    = target_positions[leg_i * 3 + 2];
    }
    target_positions_list.add(new float[]{
        target_positions[0],  target_positions[1],  target_positions[2],
        target_positions[3],  target_positions[4],  target_positions[5],
        target_positions[6],  target_positions[7],  target_positions[8],
        target_positions[9],  target_positions[10], target_positions[11],
        target_positions[12], target_positions[13], target_positions[14],
        target_positions[15], target_positions[16], target_positions[17]
    });

    int leg_translations_list_size = leg_translations_list.size();
    for (int list_i = 0; list_i < leg_translations_list_size; list_i++)
    {
        for (int div_i = 0; div_i < division_number; div_i++)
        {
            for (int leg_i = 0; leg_i < 6; leg_i++)
            {
                target_positions[leg_i * 3 + 0] += leg_translations_list.get(list_i)[leg_i][0] / float(division_number);
                target_positions[leg_i * 3 + 1] += leg_translations_list.get(list_i)[leg_i][1] / float(division_number);
                target_positions[leg_i * 3 + 2] += leg_translations_list.get(list_i)[leg_i][2] / float(division_number);
            }
            target_positions_list.add(new float[]{
                target_positions[0],  target_positions[1],  target_positions[2],
                target_positions[3],  target_positions[4],  target_positions[5],
                target_positions[6],  target_positions[7],  target_positions[8],
                target_positions[9],  target_positions[10], target_positions[11],
                target_positions[12], target_positions[13], target_positions[14],
                target_positions[15], target_positions[16], target_positions[17]
            });
        }
    }
    
    //3自由度×6本の脚＝18自由度->18次行列のヤコビ行列
    float[][] jacobian         = new float[18][18];
    float[][] inverse_jacobian = new float[18][18];
    float     det_jacobian     = 1.0;

    int target_positions_list_size = target_positions_list.size();
    for (int list_i = 0; list_i < target_positions_list_size; list_i++)
    {
        float[] error = new float[18];
        for (int error_i = 0; error_i < 18; error_i++)
        {
            error[error_i] = target_positions_list.get(list_i)[error_i] - forward_kinematics[error_i / 3][error_i % 3];
        }
        float abs_error = abs_error = 0.0;
        for (int error_i = 0; error_i < 18; error_i++)
        {
            abs_error += error[error_i] * error[error_i];
        }
        abs_error = sqrt(abs_error);
        //ニュートン法による数値計算
        for (int loop = 0; loop <= 10000; loop++)
        {
            if (abs_error < 0.001)
            {
                //println(abs_error);
                break;
            }
            for (int row = 0; row < 18; row++)
            {
                for (int col = 0; col < 18; col++)
                {
                    jacobian[row][col] = 0.0;
                    if (row == col)
                    {
                        inverse_jacobian[row][col] = 1.0;
                    }
                    else
                    {
                        inverse_jacobian[row][col] = 0.0;
                    }
                }
            }
            det_jacobian = 1.0;

            for (int leg_i = 0; leg_i < 6; leg_i++)
            {
                float sinTh0 = sin(leg_base_rotation[leg_i]),    cosTh0 = cos(leg_base_rotation[leg_i]);
                float sinTh1 = sin(joint_angles[leg_i * 3 + 0]), cosTh1 = cos(joint_angles[leg_i * 3 + 0]);
                float sinTh2 = sin(joint_angles[leg_i * 3 + 1]), cosTh2 = cos(joint_angles[leg_i * 3 + 1]);
                float sinTh3 = sin(joint_angles[leg_i * 3 + 2]), cosTh3 = cos(joint_angles[leg_i * 3 + 2]);
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    sinTh2 *= -1;
                    sinTh3 *= -1;
                }
                float sinTh01 = sinTh0 * cosTh1 + cosTh0 * sinTh1;
                float cosTh01 = cosTh0 * cosTh1 - sinTh0 * sinTh1;
                float sinTh23 = sinTh2 * cosTh3 - cosTh2 * sinTh3;
                float cosTh23 = cosTh2 * cosTh3 + sinTh2 * sinTh3;

                //Link3 => Pr - P3
                forward_kinematics[leg_i][0] = cosTh01 * cosTh23 * link_vectors[3][0] - sinTh01 * link_vectors[3][1] + cosTh01 * sinTh23 * link_vectors[3][2];
                forward_kinematics[leg_i][1] = sinTh01 * cosTh23 * link_vectors[3][0] + cosTh01 * link_vectors[3][1] + sinTh01 * sinTh23 * link_vectors[3][2];
                forward_kinematics[leg_i][2] =-sinTh23 * link_vectors[3][0] + cosTh23 * link_vectors[3][2];
                //S3 × (Pr - P3)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 2] =-cosTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 2] =-sinTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 2] = sinTh01 * forward_kinematics[leg_i][1] + cosTh01 * forward_kinematics[leg_i][0];
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    jacobian[leg_i * 3 + 0][leg_i * 3 + 2] *= -1;
                    jacobian[leg_i * 3 + 1][leg_i * 3 + 2] *= -1;
                    jacobian[leg_i * 3 + 2][leg_i * 3 + 2] *= -1;
                }

                //Link2->Link3 => Pr - P2
                forward_kinematics[leg_i][0] += cosTh01 * cosTh2  * link_vectors[2][0] - sinTh01 * link_vectors[2][1] + cosTh01 * sinTh2  * link_vectors[2][2];
                forward_kinematics[leg_i][1] += sinTh01 * cosTh2  * link_vectors[2][0] + cosTh01 * link_vectors[2][1] + sinTh01 * sinTh2  * link_vectors[2][2];
                forward_kinematics[leg_i][2] +=-sinTh2  * link_vectors[2][0] + cosTh2  * link_vectors[2][2];
                //S2 × (Pr - P2)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 1] = cosTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 1] = sinTh01 * forward_kinematics[leg_i][2];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 1] =-sinTh01 * forward_kinematics[leg_i][1] - cosTh01 * forward_kinematics[leg_i][0];
                if (leg_i == 1 || leg_i == 4 || leg_i == 5)
                {
                    jacobian[leg_i * 3 + 0][leg_i * 3 + 1] *= -1;
                    jacobian[leg_i * 3 + 1][leg_i * 3 + 1] *= -1;
                    jacobian[leg_i * 3 + 2][leg_i * 3 + 1] *= -1;
                }

                //Link1->Link2->Link3 => Pr - P1
                forward_kinematics[leg_i][0] += cosTh01 * link_vectors[1][0] - sinTh01 * link_vectors[1][1];
                forward_kinematics[leg_i][1] += sinTh01 * link_vectors[1][0] + cosTh01 * link_vectors[1][1];
                forward_kinematics[leg_i][2] += link_vectors[1][2];
                //S1 × (Pr - P1)
                jacobian[leg_i * 3 + 0][leg_i * 3 + 0] =-forward_kinematics[leg_i][1];
                jacobian[leg_i * 3 + 1][leg_i * 3 + 0] = forward_kinematics[leg_i][0];
                jacobian[leg_i * 3 + 2][leg_i * 3 + 0] = 0.0;

                //Link0->Link1->Link2->Link3 => Pr - P0
                forward_kinematics[leg_i][0] += cosTh0  * link_vectors[0][0] - sinTh0  * link_vectors[0][1];
                forward_kinematics[leg_i][1] += sinTh0  * link_vectors[0][0] + cosTh0  * link_vectors[0][1];
                forward_kinematics[leg_i][2] += link_vectors[0][2];

                det_jacobian *= jacobian[leg_i * 3 + 0][leg_i * 3 + 0] * jacobian[leg_i * 3 + 1][leg_i * 3 + 1] * jacobian[leg_i * 3 + 2][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 1] * jacobian[leg_i * 3 + 1][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 1] * jacobian[leg_i * 3 + 1][leg_i * 3 + 2]
                              + jacobian[leg_i * 3 + 0][leg_i * 3 + 2] * jacobian[leg_i * 3 + 1][leg_i * 3 + 0] * jacobian[leg_i * 3 + 2][leg_i * 3 + 1];
            }

            if (det_jacobian == 0.0)
            {
                println("singular");
                break;
            }

            inverse(jacobian, inverse_jacobian);

            for (int error_i = 0; error_i < 18; error_i++)
            {
                error[error_i] = target_positions_list.get(list_i)[error_i] - forward_kinematics[error_i / 3][error_i % 3];
            }

            for (int joint_i = 0; joint_i < 18; joint_i++)
            {
                for (int error_i = 0; error_i < 18; error_i++)
                {
                    joint_angles[joint_i] += inverse_jacobian[joint_i][error_i] * error[error_i];
                }
            }

            abs_error = 0.0;
            for (int error_i = 0; error_i < 18; error_i++)
            {
                abs_error += error[error_i] * error[error_i];
            }
            abs_error = sqrt(abs_error);
        }
        joint_angles_list.add(new float[]{
            joint_angles[0],  joint_angles[1],  joint_angles[2],  joint_angles[3],  joint_angles[4],  joint_angles[5], 
            joint_angles[6],  joint_angles[7],  joint_angles[8],  joint_angles[9],  joint_angles[10], joint_angles[11], 
            joint_angles[12], joint_angles[13], joint_angles[14], joint_angles[15], joint_angles[16], joint_angles[17]
        });
    }

    int joint_angles_list_size = joint_angles_list.size();
    for (int list_i = 0; list_i < joint_angles_list_size; list_i++)
    {
        int old_time = millis();

        int[] joint_angle_values = new int[18];
        for (int joint_i = 0; joint_i < 18; joint_i++)
        {
            joint_angle_values[joint_ids[joint_i] - 1] = int(1024.0 * (6.0 * joint_angles_list.get(list_i)[joint_i] / 5.0 / PI + 0.5));
            if (joint_angle_values[joint_ids[joint_i] - 1] < 0 || 1024 < joint_angle_values[joint_ids[joint_i] - 1])
            {
                return;
            }
        }

        String command = "[m,";
        for (int joint_i = 0; joint_i < 18; joint_i++)
        {
            command += str(joint_i + 1);
            command += ",";
            command += str(joint_angle_values[joint_i]);
            if (joint_i != 17)
            {
                command += ",";
            }
        }
        command += "]\n";
        king_spider.writeCommand(command);
        myPort.write(command);
        print(command);
        
        while (millis() - old_time < 50) {}
    }
}

boolean walking = false;

boolean running = false;

void walk()
{
    if (running)
    {
        return;
    }
    else
    {
        running = true;
    }

    println("running", running);
    println("walking", walking);
    
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    int[] initial_angle_values;
    if (!walking)
    {
        initial_angle_values = new int[]{512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512};
        leg_translations_list.add(new float[][]{
            {-20.0, -50.0, 30.0}, {-20.0, 50.0, 30.0}, {0.0, 0.0, 30.0}, {20.0, 50.0, 30.0}, {20.0, -50.0, 30.0}, {0.0, 0.0, 30.0}
        });
        walking = true;
    }
    else
    {
        initial_angle_values = new int[]{323,700,322,701,260,763,512,512,699,324,719,304,700,323,701,322,763,260};
        leg_translations_list.add(new float[][]{
            {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}
        });
        leg_translations_list.add(new float[][]{
            {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}
        });

        for (int i = 0; i < 2; i++)
        {
            leg_translations_list.add(new float[][]{
                {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}
            });
            leg_translations_list.add(new float[][]{
                {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}
            });
            leg_translations_list.add(new float[][]{
                {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}
            });
            leg_translations_list.add(new float[][]{
                {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}
            });
        }

        leg_translations_list.add(new float[][]{
            {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}
        });
        leg_translations_list.add(new float[][]{
            {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}
        });
    }
    
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 10);

    running = false;
}

boolean robot_is_initialized   = false;
boolean robot_is_walking_right = false;
boolean robot_is_walking_left  = false;
boolean robot_is_turning_right = false;
boolean robot_is_turning_left  = false;

void planMotion()
{
    if (running)
    {
        return;
    }
    else
    {
        running = false;
    }

    if (!robot_is_initialized)
    {
        initialize();
        robot_is_initialized = true;
    }
    else if (keyPressed && key == CODED && keyCode == UP && !robot_is_walking_right && !robot_is_walking_left)
    {
        walkstart();
        robot_is_walking_right = true;
    }
    else if (keyPressed && key == CODED && keyCode == UP && !robot_is_walking_right && robot_is_walking_left)
    {
        walkRight();
        robot_is_walking_right = true;
        robot_is_walking_left  = false;
    }
    else if (keyPressed && key == CODED && keyCode == UP && robot_is_walking_right && !robot_is_walking_left)
    {
        walkLeft();
        robot_is_walking_right = false;
        robot_is_walking_left  = true;
    }
    else if ((!keyPressed || key != CODED || keyCode != UP) && !robot_is_walking_right && robot_is_walking_left)
    {
        walkEndRight();
        robot_is_walking_right = false;
        robot_is_walking_left  = false;
    }
    else if ((!keyPressed || key != CODED || keyCode != UP) && robot_is_walking_right && !robot_is_walking_left)
    {
        walkEndLeft();
        robot_is_walking_right = false;
        robot_is_walking_left  = false;
    }
    else if (keyPressed && key == CODED && keyCode == RIGHT && !robot_is_walking_right && !robot_is_walking_left)
    {
        turnRight();
    }
    else if (keyPressed && key == CODED && keyCode == LEFT && !robot_is_walking_right && !robot_is_walking_left)
    {
        turnLeft();
    }
    else if (keyPressed && key == CODED && keyCode == DOWN && !robot_is_walking_right && !robot_is_walking_right)
    {
        perform();
    }

    running = false;
}

void initialize()
{
    int[] initial_angle_values = new int[]{512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512,512};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {-10.0, -50.0, 30.0}, {-10.0, 50.0, 30.0}, {0.0, 0.0, 30.0}, {10.0, 50.0, 30.0}, {20.0, -50.0, 30.0}, {0.0, 0.0, 30.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void walkstart()
{
    //初期姿勢
    int[] initial_angle_values = new int[]{338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}
    });
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void walkRight()
{
    //左前
    int[] initial_angle_values = new int[]{280,649,321,651,220,524,610,610,699,322,677,344,659,280,674,321,586,220};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}
    });
    leg_translations_list.add(new float[][]{
        {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void walkLeft()
{
    //右前
    int[] initial_angle_values = new int[]{372,740,370,700,497,802,412,412,699,323,677,345,766,372,689,370,828,497};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}, {-30.0, 0.0, -10.0}, {30.0, 0.0, 20.0}
    });
    leg_translations_list.add(new float[][]{
        {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}, {-30.0, 0.0, 10.0}, {30.0, 0.0, -20.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void walkEndRight()
{
    //左前
    int[] initial_angle_values = new int[]{280,649,321,651,220,524,610,610,699,322,677,344,659,280,674,321,586,220};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}
    });
    leg_translations_list.add(new float[][]{
        {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void walkEndLeft()
{
    //右前
    int[] initial_angle_values = new int[]{372,740,370,700,497,802,412,412,699,323,677,345,766,372,689,370,828,497};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    leg_translations_list.add(new float[][]{
        {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}, {-15.0, 0.0, -10.0}, {15.0, 0.0, 20.0}
    });
    leg_translations_list.add(new float[][]{
        {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}, {-15.0, 0.0, 10.0}, {15.0, 0.0, -20.0}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

void turnRight()
{
    //初期姿勢
    int[] initial_angle_values = new int[]{338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332};
    float division_number = 5.0;
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {leg_lengths[0][0] * (cos(leg_lengths[0][1] + radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[0][1] + radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[0][0] * (sin(leg_lengths[0][1] + radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[0][1] + radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number},
            {0.0, 0.0, 20.0 / division_number},
            {leg_lengths[2][0] * (cos(leg_lengths[2][1] + radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[2][1] + radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[2][0] * (sin(leg_lengths[2][1] + radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[2][1] + radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number},
            {0.0, 0.0, 20.0 / division_number},
            {leg_lengths[4][0] * (cos(leg_lengths[4][1] + radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[4][1] + radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[4][0] * (sin(leg_lengths[4][1] + radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[4][1] + radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number},
            {0.0, 0.0, 20.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {leg_lengths[0][0] * (cos(leg_lengths[0][1] + radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[0][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[0][0] * (sin(leg_lengths[0][1] + radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[0][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number},
            {0.0, 0.0,-20.0 / division_number},
            {leg_lengths[2][0] * (cos(leg_lengths[2][1] + radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[2][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[2][0] * (sin(leg_lengths[2][1] + radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[2][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number},
            {0.0, 0.0,-20.0 / division_number},
            {leg_lengths[4][0] * (cos(leg_lengths[4][1] + radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[4][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[4][0] * (sin(leg_lengths[4][1] + radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[4][1] + radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number},
            {0.0, 0.0,-20.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {leg_lengths[0][0] * (cos(leg_lengths[0][1] + radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[0][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[0][0] * (sin(leg_lengths[0][1] + radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[0][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number},
            {0.0, 0.0, -10.0 / division_number},
            {leg_lengths[2][0] * (cos(leg_lengths[2][1] + radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[2][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[2][0] * (sin(leg_lengths[2][1] + radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[2][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number},
            {0.0, 0.0, -10.0 / division_number},
            {leg_lengths[4][0] * (cos(leg_lengths[4][1] + radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[4][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[4][0] * (sin(leg_lengths[4][1] + radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[4][1] + radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number},
            {0.0, 0.0, -10.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {leg_lengths[0][0] * (cos(leg_lengths[0][1] + radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[0][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[0][0] * (sin(leg_lengths[0][1] + radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[0][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number},
            {0.0, 0.0, 10.0 / division_number},
            {leg_lengths[2][0] * (cos(leg_lengths[2][1] + radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[2][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[2][0] * (sin(leg_lengths[2][1] + radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[2][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number},
            {0.0, 0.0, 10.0 / division_number},
            {leg_lengths[4][0] * (cos(leg_lengths[4][1] + radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[4][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[4][0] * (sin(leg_lengths[4][1] + radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[4][1] + radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number},
            {0.0, 0.0, 10.0 / division_number}
        });
    }
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 1);
}

void turnLeft()
{
    //初期姿勢
    int[] initial_angle_values = new int[]{338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332};
    float division_number = 5.0;
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {0.0, 0.0, 20.0 / division_number},
            {leg_lengths[1][0] * (cos(leg_lengths[1][1] - radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[1][1] - radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[1][0] * (sin(leg_lengths[1][1] - radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[1][1] - radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number},
            {0.0, 0.0, 20.0 / division_number},
            {leg_lengths[3][0] * (cos(leg_lengths[3][1] - radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[3][1] - radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[3][0] * (sin(leg_lengths[3][1] - radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[3][1] - radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number},
            {0.0, 0.0, 20.0 / division_number},
            {leg_lengths[5][0] * (cos(leg_lengths[5][1] - radians(float(i) * 7.5 / division_number)) - cos(leg_lengths[5][1] - radians(float(i - 1) * 7.5 / division_number))), 
             leg_lengths[5][0] * (sin(leg_lengths[5][1] - radians(float(i) * 7.5 / division_number)) - sin(leg_lengths[5][1] - radians(float(i - 1) * 7.5 / division_number))),-10.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {0.0, 0.0, -20.0 / division_number},
            {leg_lengths[1][0] * (cos(leg_lengths[1][1] - radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[1][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[1][0] * (sin(leg_lengths[1][1] - radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[1][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number},
            {0.0, 0.0, -20.0 / division_number},
            {leg_lengths[3][0] * (cos(leg_lengths[3][1] - radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[3][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[3][0] * (sin(leg_lengths[3][1] - radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[3][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number},
            {0.0, 0.0, -20.0 / division_number},
            {leg_lengths[5][0] * (cos(leg_lengths[5][1] - radians(7.5 + float(i) * 7.5 / division_number)) - cos(leg_lengths[5][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 
             leg_lengths[5][0] * (sin(leg_lengths[5][1] - radians(7.5 + float(i) * 7.5 / division_number)) - sin(leg_lengths[5][1] - radians(7.5 + float(i - 1) * 7.5 / division_number))), 10.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {0.0, 0.0, -10.0 / division_number},
            {leg_lengths[1][0] * (cos(leg_lengths[1][1] - radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[1][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[1][0] * (sin(leg_lengths[1][1] - radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[1][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number},
            {0.0, 0.0, -10.0 / division_number},
            {leg_lengths[3][0] * (cos(leg_lengths[3][1] - radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[3][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[3][0] * (sin(leg_lengths[3][1] - radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[3][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number},
            {0.0, 0.0, -10.0 / division_number},
            {leg_lengths[5][0] * (cos(leg_lengths[5][1] - radians(15.0 - float(i) * 7.5 / division_number)) - cos(leg_lengths[5][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[5][0] * (sin(leg_lengths[5][1] - radians(15.0 - float(i) * 7.5 / division_number)) - sin(leg_lengths[5][1] - radians(15.0 - float(i - 1) * 7.5 / division_number))), 20.0 / division_number}
        });
    }
    for (int i = 1; i <= int(division_number); i++)
    {
        leg_translations_list.add(new float[][]{
            {0.0, 0.0, 10.0 / division_number},
            {leg_lengths[1][0] * (cos(leg_lengths[1][1] - radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[1][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[1][0] * (sin(leg_lengths[1][1] - radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[1][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number},
            {0.0, 0.0 , 10.0 / division_number},
            {leg_lengths[3][0] * (cos(leg_lengths[3][1] - radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[3][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[3][0] * (sin(leg_lengths[3][1] - radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[3][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number},
            {0.0, 0.0, 10.0 / division_number},
            {leg_lengths[5][0] * (cos(leg_lengths[5][1] - radians(7.5 - float(i) * 7.5 / division_number)) - cos(leg_lengths[5][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))), 
             leg_lengths[5][0] * (sin(leg_lengths[5][1] - radians(7.5 - float(i) * 7.5 / division_number)) - sin(leg_lengths[5][1] - radians(7.5 - float(i - 1) * 7.5 / division_number))),-20.0 / division_number}
        });
    }
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 1);
}

void perform()
{
    //初期姿勢
    int[] initial_angle_values = new int[]{338,685,321,702,332,691,512,512,703,320,697,326,700,338,707,321,734,332};
    ArrayList<float[][]> leg_translations_list = new ArrayList<float[][]>();
    float delta = 10;
    leg_translations_list.add(new float[][]{
        {0.0, 0.0, delta}, {0.0, 0.0, delta}, {0.0, 0.0, delta}, {0.0, 0.0, delta}, {0.0, 0.0, delta}, {0.0, 0.0, delta}
    });
    leg_translations_list.add(new float[][]{
        {0.0, 0.0,-delta}, {0.0, 0.0,-delta}, {0.0, 0.0,-delta}, {0.0, 0.0,-delta}, {0.0, 0.0,-delta}, {0.0, 0.0,-delta}
    });
    calcIKAndSendCommand(leg_translations_list, initial_angle_values, 5);
}

float[][] leg_lengths = new float[6][4];
void setLegLengths()
{
    leg_lengths[0][0] = sqrt(177.93 * 177.93 + 85.07 * 85.07);
    leg_lengths[0][1] = atan2(-85.07, 177.93);
    leg_lengths[0][2] = sin(leg_lengths[0][1]);
    leg_lengths[0][3] = cos(leg_lengths[0][1]);
    leg_lengths[1][0] = sqrt(178.1 * 178.1 + 84.85 * 84.85);
    leg_lengths[1][1] = atan2(84.85, 178.1);
    leg_lengths[1][2] = sin(leg_lengths[1][1]);
    leg_lengths[1][3] = cos(leg_lengths[1][1]);
    leg_lengths[2][0] = 213.14;
    leg_lengths[2][1] = atan2(213.14, 0.0);
    leg_lengths[2][2] = sin(leg_lengths[2][1]);
    leg_lengths[2][3] = cos(leg_lengths[2][1]);
    leg_lengths[3][0] = sqrt(177.93 * 177.93 + 85.07 * 85.07);
    leg_lengths[3][1] = atan2(85.07, -177.93);
    leg_lengths[3][2] = sin(leg_lengths[3][1]);
    leg_lengths[3][3] = cos(leg_lengths[3][1]);
    leg_lengths[4][0] = sqrt(178.1 * 178.1 + 84.85 * 84.85);
    leg_lengths[4][1] = atan2(-84.85, -178.1);
    leg_lengths[4][2] = sin(leg_lengths[4][1]);
    leg_lengths[4][3] = cos(leg_lengths[4][1]);
    leg_lengths[5][0] = 213.19;
    leg_lengths[5][1] = atan2(-213.19, 0.0);
    leg_lengths[5][2] = sin(leg_lengths[5][1]);
    leg_lengths[5][3] = cos(leg_lengths[5][1]);
}