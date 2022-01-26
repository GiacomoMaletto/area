#include <stdio.h>
#include <array>
#include <math.h>

int main(){
  FILE *output = fopen("output.txt", "w");
  
  int N = 300;
  for(int i = 0; i < N; i++){
    for(int j = 0; j < N; j++){
      float x = ((float)i)/N;
      float y = ((float)j)/N;
      float z = .2 * (sin(5.0*x) + sin(5.0*y));
      fprintf(output, "%f %f %f\n", x, y, z);
    }
  }

  fclose(output);
}