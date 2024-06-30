import numpy as np
import tensorflow as tf

def load_txt_to_tensor(filename, m, n):
    with open(filename, 'r') as f:
        data = f.readlines()
    # 데이터 읽어서 numpy 배열로 변환 후 텐서로 변환
    data = np.array([int(x.strip()) for x in data])
    tensor = tf.convert_to_tensor(data.reshape(m, n), dtype=tf.int32)
    return tensor

def save_tensor_to_txt(tensor, filename):
    flattened_tensor = tf.reshape(tensor, [-1])
    with open(filename, 'w') as f:
        for elem in flattened_tensor:
            f.write(f"{elem.numpy()}\n")

filename = 'matmul.txt'  # 저장할 파일명
inputname = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/input.txt'  # 실제 경로로 변경
weightname = 'C:/Users/sjh00/Matrix_multiplication_recursive_architecture/Matrix_multiplication_recursive_architecture.srcs/sources_1/new/weight.txt'  # 실제 경로로 변경

# 텍스트 파일에서 텐서로 불러오기
tensor_a = load_txt_to_tensor(inputname, 8, 4)
tensor_b = load_txt_to_tensor(weightname, 4, 8)

# 행렬 곱셈 수행
result_tensor = tf.matmul(tensor_a, tensor_b)

# 결과 텐서를 텍스트 파일에 저장
save_tensor_to_txt(result_tensor, filename)
