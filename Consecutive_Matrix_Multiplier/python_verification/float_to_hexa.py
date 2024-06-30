import numpy as np

def load_txt_to_array(filename):
    with open(filename, 'r') as f:
        data = f.readlines()
    data = np.array([float(x.strip()) for x in data])
    return data

def save_array_to_fixed_point_hex(data, filename, int_bits, frac_bits):
    total_bits = int_bits + frac_bits  # 총 비트 수
    max_int = (1 << total_bits) - 1  # 총 비트로 표현할 수 있는 최대 정수 값
    scale_factor = 1 << frac_bits  # 소수부 비트에 따른 스케일 팩터
    hex_digits = (total_bits + 3) // 4  # 비트 수에 따라 필요한 16진수 자리 수 계산

    with open(filename, 'w') as f:
        for num in data:
            # 스케일 팩터를 곱하여 고정 소수점으로 변환
            fixed_point_val = int(round(num * scale_factor))
            # 2의 보수법으로 음수 처리
            if fixed_point_val < 0:
                fixed_point_val = (1 << total_bits) + fixed_point_val
            # 값이 범위를 초과하는 경우 처리
            fixed_point_val = max(0, min(fixed_point_val, max_int))
            hex_value = hex(fixed_point_val)[2:].upper()  # 16진수로 변환하고 '0x' 제거
            hex_value = hex_value.zfill(hex_digits)  # 지정된 자리 수에 맞춰 0으로 패딩
            f.write(f"{hex_value}\n")

# 매개변수 설정
input_filename = 'C:/Users/sjh00/Consecutive_Mat_Mul/Consecutive_Mat_Mul.srcs/sources_1/new/data/input_float.txt'  # 실제 경로로 변경
output_filename = 'output_fixed_point_hex.txt'
int_bits = 8  # 정수부 비트 수
frac_bits = 8  # 소수부 비트 수

# 텍스트 파일에서 데이터 불러오기
data = load_txt_to_array(input_filename)

# 데이터 배열을 signed fixed-point 16진수 텍스트 파일로 저장
save_array_to_fixed_point_hex(data, output_filename, int_bits, frac_bits)
