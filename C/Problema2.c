#include<stdio.h>
#include<stdlib.h>

int main()
{
	printf("Insertion Sort\n\n");
	printf("Vetor de 10 posicoes\n");

	int f1, posicao, elem;
	
	int vetor[10];
	
	for(f1=0;f1<10;f1++)
	{
		printf("Posicao %d, valor: ", f1);
		scanf("%d",&vetor[f1]);
	}
	
	printf("\nOriginal: ");
	for(f1=0;f1<10;f1++)
	{
		printf("%d ",vetor[f1]);
	}
	
  for (f1=1;f1<10;f1++)
  {
    elem = vetor[f1];
    posicao = f1;
    
    while (posicao>0 && vetor[posicao-1] > elem)
    {
      vetor[posicao] = vetor[posicao-1];
      posicao--;
    }
    vetor[posicao] = elem;
  }
	
	printf("\nOrdenado: ");
	for(f1=0;f1<10;f1++)
	{
		printf("%d ",vetor[f1]);
	}
	printf("\n\n");

	system("pause");

	return 0;
}