import numpy as np

def load_txt_to_array(filename):
    with open(filename, 'r') as f:
        data = f.readlines()
    data = [x.strip() for x in data]
    return data

def save_padded_hex_txt(data, filename, padding):
    padded_data = []
    for i in range(0, len(data), padding):
        chunk = data[i:i + padding]
        # 역순으로 배치하여 하나의 문자열로 결합
        padded_data.append(''.join(chunk[::-1]))
    
    with open(filename, 'w') as f:
        for item in padded_data:
            f.write(f"{item}\n")

# 매개변수 설정
input_filename = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/WEIGHT_hex.txt'  # 실제 경로로 변경
output_filename = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/WEIGHT_hex_padded.txt'
padding = 8  # 패딩 수

# 텍스트 파일에서 데이터 불러오기
data = load_txt_to_array(input_filename)

# 데이터 배열을 패딩하여 새로운 텍스트 파일로 저장
save_padded_hex_txt(data, output_filename, padding)
