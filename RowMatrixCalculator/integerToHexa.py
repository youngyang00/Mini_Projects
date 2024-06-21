import numpy as np

def load_txt_to_array(filename):
    with open(filename, 'r') as f:
        data = f.readlines()
    data = np.array([int(x.strip()) for x in data])
    return data

def save_array_to_hex_txt(data, filename, bits):
    hex_digits = bits // 4  # 비트 수에 따라 필요한 16진수 자리 수 계산
    with open(filename, 'w') as f:
        for num in data:
            # 2의 보수법으로 음수 처리
            if num < 0:
                num = (1 << bits) + num
            hex_value = hex(num)[2:].upper()  # 16진수로 변환하고 '0x' 제거
            hex_value = hex_value.zfill(hex_digits)  # 지정된 자리 수에 맞춰 0으로 패딩
            f.write(f"{hex_value}\n")

# 매개변수 설정
input_filename = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/weight.txt'  # 실제 경로로 변경
output_filename = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/output_hex.txt'
bits = 8  # 비트 수

# 텍스트 파일에서 데이터 불러오기
data = load_txt_to_array(input_filename)

# 데이터 배열을 16진수 텍스트 파일로 저장
save_array_to_hex_txt(data, output_filename, bits)
