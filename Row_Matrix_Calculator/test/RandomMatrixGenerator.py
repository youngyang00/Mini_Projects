import numpy as np

def save_random_matrix_to_txt(m, n, min_val, max_val, filename):
    # m x n 행렬을 min_val 과 max_val 범위 내의 랜덤 정수로 생성
    matrix = np.random.randint(min_val, max_val + 1, size=(m, n))
    
    # 텍스트 파일에 저장
    with open(filename, 'w') as f:
        for row in matrix:
            for elem in row:
                f.write(f"{elem}\n")

# 매개변수 예시
m = 8  # 행의 수
n = 4  # 열의 수
min_val = 1  # 랜덤 정수 최소값
max_val = 10  # 랜덤 정수 최대값
filename = 'matrix.txt'  # 저장할 파일명

# 함수 호출
save_random_matrix_to_txt(m, n, min_val, max_val, filename)
