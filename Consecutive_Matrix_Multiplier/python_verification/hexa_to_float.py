import numpy as np

def load_hex_txt_to_array(filename):
    with open(filename, 'r') as f:
        data = f.readlines()
    data = [x.strip() for x in data]
    return data

def save_array_to_float(data, filename, int_bits, frac_bits):
    total_bits = int_bits + frac_bits  # 총 비트 수
    scale_factor = 1 << frac_bits  # 소수부 비트에 따른 스케일 팩터
    max_int = (1 << total_bits) - 1  # 총 비트로 표현할 수 있는 최대 정수 값
    max_pos_val = (1 << (total_bits - 1)) - 1  # 양수로 표현 가능한 최대 값
    min_neg_val = -1 << (total_bits - 1)  # 음수로 표현 가능한 최소 값

    float_data = []
    for hex_str in data:
        # 16진수를 정수로 변환
        fixed_point_val = int(hex_str, 16)
        # 음수 값 처리 (2의 보수법)
        if fixed_point_val > max_pos_val:
            fixed_point_val -= (1 << total_bits)
        # 고정 소수점을 부동 소수점으로 변환
        float_val = fixed_point_val / scale_factor
        float_data.append(float_val)
    
    # 부동 소수점 데이터를 파일에 저장
    with open(filename, 'w') as f:
        for num in float_data:
            f.write(f"{num}\n")

# 매개변수 설정
input_filename = 'C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/python/testbench_result_hexa.txt'  # 고정 소수점 16진수 텍스트 파일 경로
output_filename = 'output_float.txt'  # 부동 소수점 텍스트 파일 경로
int_bits = 16  # 정수부 비트 수
frac_bits = 16  # 소수부 비트 수

# 텍스트 파일에서 데이터 불러오기
data = load_hex_txt_to_array(input_filename)

# 16진수 데이터를 부동 소수점 배열로 변환하여 저장
save_array_to_float(data, output_filename, int_bits, frac_bits)
