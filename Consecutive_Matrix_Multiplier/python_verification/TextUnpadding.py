def load_txt_to_array(filename):
    with open(filename, 'r') as f:
        data = f.readlines()
    data = [x.strip() for x in data]
    return data

def save_unpadded_hex_txt(data, filename, padding):
    unpadded_data = []
    for chunk in data:
        # 패딩 단위로 나누어 역순으로 정렬
        for i in range(0, len(chunk), padding * 2):  # 2 characters per hex digit
            unpadded_data.append(chunk[i:i + padding * 2])
    
    unpadded_data = unpadded_data[::-1]  # 원래 순서로 복원
    
    with open(filename, 'w') as f:
        for item in unpadded_data:
            f.write(f"{item}\n")

# 매개변수 설정
input_filename = 'C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/python/firstrow.txt'  # 패딩된 텍스트 파일 경로
output_filename = 'weight2_hexa_unpadded.txt'  # 복원된 텍스트 파일 경로
padding = 4  # 복원할 단위 (패딩 단위)

# 패딩된 텍스트 파일에서 데이터 불러오기
data = load_txt_to_array(input_filename)

# 데이터를 원래 순서로 복원하여 새로운 텍스트 파일로 저장
save_unpadded_hex_txt(data, output_filename, padding)
