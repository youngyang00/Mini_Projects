import numpy as np
import tensorflow as tf

def load_txt_to_tensor(filename, m, n):
    """텍스트 파일에서 데이터를 읽어 m x n 텐서로 변환합니다."""
    with open(filename, 'r') as f:
        data = f.readlines()
    data = np.array([float(x.strip()) for x in data])
    tensor = tf.convert_to_tensor(data.reshape(m, n), dtype=tf.float32)
    return tensor

def calculate_error(matrix1, matrix2):
    """두 텐서 간의 요소별 오차를 계산합니다."""
    return tf.abs(matrix1 - matrix2)


def save_matrix_to_txt(matrix, filename):
    """행렬을 텍스트 파일에 저장합니다."""
    flattened_matrix = tf.reshape(matrix, [-1])
    with open(filename, 'w') as f:
        for elem in flattened_matrix:
            f.write(f"{elem.numpy()}\n")

# 파일 경로와 행렬 크기 설정
filename1 = 'C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/python/testbench_result_float.txt'
filename2 = 'C:/Users/sjh00/consecutive_mat_mul/consecutive_mat_mul.srcs/sources_1/new/python/final_result.txt'
m = 32  # 행 수
n = 8 # 열 수

# 텍스트 파일에서 텐서 불러오기
matrix1 = load_txt_to_tensor(filename1, m, n)
matrix2 = load_txt_to_tensor(filename2, m, n)

# 두 텐서 간의 오차 계산
error_matrix = calculate_error(matrix1, matrix2)

# 최대 오차 출력
max_error = tf.reduce_max(error_matrix).numpy()
print(f"Maximum error between the matrices: {max_error}")

# 요소별 오차 출력
print("Error matrix:")
print(error_matrix.numpy())

error_filename = 'error_matrix.txt'
save_matrix_to_txt(error_matrix, error_filename)
