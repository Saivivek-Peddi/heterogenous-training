import torch
from mpi4py import MPI
import time

# Initialize MPI
comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

# Function to multiply matrices using CUDA
def multiply_matrices_cuda(matrixA, matrixB):
    device = torch.device('cuda')
    A = torch.tensor(matrixA, dtype=torch.float32, device=device)
    B = torch.tensor(matrixB, dtype=torch.float32, device=device)
    start_time = time.time()
    C = torch.matmul(A, B)
    cuda_time = time.time() - start_time
    return C.cpu().numpy(), cuda_time

# Function to multiply matrices using ROCm
def multiply_matrices_rocm(matrixA, matrixB):
    device = torch.device('cuda')  # Assuming ROCm setup mimics CUDA in PyTorch
    A = torch.tensor(matrixA, dtype=torch.float32, device=device)
    B = torch.tensor(matrixB, dtype=torch.float32, device=device)
    start_time = time.time()
    C = torch.matmul(A, B)
    rocm_time = time.time() - start_time
    return C.cpu().numpy(), rocm_time

# Generate random matrices for demonstration
def generate_matrices(size):
    return (torch.randn(size, size), torch.randn(size, size))

# Perform reduction operation (summing matrices)
def reduce_matrices(matrix1, matrix2):
    return matrix1 + matrix2

# Main function to orchestrate operations
def main():
    matrix_size = 1024  # Example size of the matrix
    matrixA, matrixB = generate_matrices(matrix_size)
    
    if rank == 0:  # Nvidia node (Master)
        result_cuda, time_cuda = multiply_matrices_cuda(matrixA, matrixB)
        print(f"Nvidia node computed in {time_cuda:.2f} seconds.")
        
        # Send and receive data
        comm.send(result_cuda, dest=1, tag=11)
        start_comm_time = time.time()
        result_rocm = comm.recv(source=1, tag=12)
        comm_time = time.time() - start_comm_time
        
        # Reduction operation
        final_result = reduce_matrices(result_cuda, result_rocm)
        print(f"Communication time: {comm_time:.2f} seconds.")
        
        # Collect and log metrics
        # Assume some function save_metrics() to store or display metrics
        save_metrics({'Compute Time Nvidia': time_cuda, 'Communication Time': comm_time})
        print("Final result stored.")
        
    elif rank == 1:  # AMD node
        result_rocm, time_rocm = multiply_matrices_rocm(matrixA, matrixB)
        print(f"AMD node computed in {time_rocm:.2f} seconds.")
        
        # Send and receive data
        result_cuda = comm.recv(source=0, tag=11)
        comm.send(result_rocm, dest=0, tag=12)

if __name__ == "__main__":
    main()
