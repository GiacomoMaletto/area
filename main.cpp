#include <stdio.h>
#include <array>
#include <math.h>

int main(){
  FILE *order = fopen("order.txt", "w");
  FILE *points = fopen("points.txt", "w");
  
  int N = 100;
  for(int i = 0; i < N-1; i++){
    for(int j = 0; j < N-1; j++){
      fprintf(order, "%d\n%d\n%d\n%d\n%d\n%d\n", N*i+j+1, N*(i+1)+j+1, N*i+j+2, N*i+j+2, N*(i+1)+j+1, N*(i+1)+j+2);
    }
  }
  for(int i = 0; i < N; i++){
    for(int j = 0; j < N; j++){
      float x = ((float)i)/N;
      float y = ((float)j)/N;
      float z = .2 * (sin(5.0*x) + sin(5.0*y));
      fprintf(points, "%f %f %f\n", x, y, z);
    }
  }
}