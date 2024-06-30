import numpy as np

def generate_primes(limit):
    """에라토스테네스의 체를 사용하여 주어진 범위까지의 소수를 생성합니다."""
    sieve = np.ones(limit + 1, dtype=bool)
    sieve[0:2] = False
    for num in range(2, int(np.sqrt(limit)) + 1):
        if sieve[num]:
            sieve[num*num:limit+1:num] = False
    return np.nonzero(sieve)[0]

def generate_random_signed_prime_matrix(m, n, prime_limit):
    """m x n 행렬을 소수와 부호 랜덤으로 채웁니다."""
    primes = generate_primes(prime_limit)
    matrix = np.random.choice(primes, size=(m, n))
    signs = np.random.choice([-1, 1], size=(m, n))
    signed_matrix = matrix * signs
    return signed_matrix

def convert_matrix_to_floats(matrix, decimal_places):
    """정수 행렬을 소수 행렬로 변환합니다."""
    float_matrix = matrix.astype(float) / (10 ** decimal_places)
    return float_matrix

def save_matrix_to_txt(matrix, filename):
    """행렬을 텍스트 파일에 저장합니다."""
    flattened_matrix = matrix.flatten()
    with open(filename, 'w') as f:
        for elem in flattened_matrix:
            f.write(f"{elem:.{decimal_places}f}\n")

# 매개변수 설정
m = 32  # 행 수
n = 64  # 열 수
prime_limit = 100  # 소수 범위 (0 ~ prime_limit 까지의 소수)
decimal_places = 2  # 소수점 이하 자릿수
filename = 'random_signed_prime_matrix.txt'

# 랜덤 signed 소수 행렬 생성
integer_matrix = generate_random_signed_prime_matrix(m, n, prime_limit)

# 정수 행렬을 소수 행렬로 변환
float_matrix = convert_matrix_to_floats(integer_matrix, decimal_places)

# 행렬을 텍스트 파일에 저장
save_matrix_to_txt(float_matrix, filename)
